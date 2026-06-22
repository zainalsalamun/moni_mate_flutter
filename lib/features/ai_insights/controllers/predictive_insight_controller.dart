import 'dart:async';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/controller/transaction_controller.dart';
import '../../../data/services/hive_service.dart';
import '../../budget/controller/budget_controller.dart';
import '../../financial_goals/controllers/goals_controller.dart';

import '../../financial_health/services/financial_health_service.dart';
import '../../wallet/controllers/wallet_controller.dart';
import '../../wallet/data/models/wallet_model.dart';
import '../../../data/controller/recurring_controller.dart';
import '../models/financial_context_model.dart';
import '../models/predictive_insight_model.dart';
import '../services/ai_insight_api_service.dart';
import '../services/local_insight_engine.dart';

class PredictiveInsightController extends GetxController {
  final RxList<PredictiveInsightModel> insights = <PredictiveInsightModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isOfflineMode = false.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    _loadCachedInsights();
    // Delay first fetch so all other controllers are ready
    Future.delayed(const Duration(seconds: 2), () {
      refreshInsights(forceApi: false);
    });
  }

  void _loadCachedInsights() {
    final cached = HiveService.getAllPredictiveInsights();
    if (cached.isNotEmpty) {
      _sortAndSetInsights(cached);
    }
  }

  void refreshInsights({bool forceApi = false}) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      await _generateInsights(forceApi: forceApi);
    });
  }

  Future<void> _generateInsights({required bool forceApi}) async {
    isLoading.value = true;
    try {
      final cached = HiveService.getAllPredictiveInsights();
      bool shouldCallApi = forceApi;

      if (!forceApi && cached.isNotEmpty) {
        // Find newest cache
        final newest = cached.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b);
        final diff = DateTime.now().difference(newest.createdAt);
        if (diff.inHours >= 6) {
          shouldCallApi = true;
        } else {
          // Cache is still fresh, just return local updates + cached API updates
          _sortAndSetInsights(cached);
          isOfflineMode.value = !cached.any((element) => element.source == 'ai_api');
          return;
        }
      } else if (cached.isEmpty) {
        shouldCallApi = true;
      }

      // Build Context
      final contextModel = _buildFinancialContext();
      
      // Generate Local
      final localInsights = LocalInsightEngine.generateInsights(contextModel);

      List<PredictiveInsightModel> finalInsights = List.from(localInsights);
      isOfflineMode.value = true;

      if (shouldCallApi) {
        try {
          // Call AI API
          final aiInsights = await AiInsightApiService.generateCoachInsights(contextModel);
          if (aiInsights.isNotEmpty) {
            isOfflineMode.value = false;
            
            final Map<String, PredictiveInsightModel> merged = {};
            
            // Add local first
            for (var item in localInsights) {
              merged[item.type] = item;
            }
            
            // AI overwrites local if same type
            for (var item in aiInsights) {
              merged[item.type] = item;
            }

            finalInsights = merged.values.toList();
          }
        } catch (e) {
          print("PredictiveInsight API Error: \$e");
          isOfflineMode.value = true;
          // finalInsights remains equal to localInsights
        }
      }

      _sortAndSetInsights(finalInsights);
      await HiveService.savePredictiveInsights(finalInsights);

    } catch (e) {
      print("PredictiveInsight Critical Error: \$e");
    } finally {
      isLoading.value = false;
    }
  }

  void _sortAndSetInsights(List<PredictiveInsightModel> list) {
    // Severity Priority: danger > warning > success > info
    int severityScore(String s) {
      if (s == 'danger') return 4;
      if (s == 'warning') return 3;
      if (s == 'success') return 2;
      return 1; // info
    }

    list.sort((a, b) {
      final scoreA = severityScore(a.severity);
      final scoreB = severityScore(b.severity);
      if (scoreA != scoreB) return scoreB.compareTo(scoreA); // Descending severity
      return b.createdAt.compareTo(a.createdAt); // Newest first
    });

    insights.value = list;
  }

  FinancialContextModel _buildFinancialContext() {
    final now = DateTime.now();
    final String monthName = DateFormat('MMMM', 'id_ID').format(now);
    
    double totalIncome = 0;
    double totalExpense = 0;
    List<Map<String, dynamic>> topExpenseCategories = [];
    
    if (Get.isRegistered<TransactionController>()) {
      final tc = Get.find<TransactionController>();
      totalIncome = tc.totalIncome.value;
      totalExpense = tc.totalExpense.value;
      
      // Top categories
      final Map<String, double> catExpense = {};
      for (var tx in tc.transactions) {
        if (tx.type == 'expense' && tx.date.month == now.month && tx.date.year == now.year) {
          catExpense[tx.category] = (catExpense[tx.category] ?? 0) + tx.amount;
        }
      }
      final sortedCats = catExpense.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      topExpenseCategories = sortedCats.take(5).map((e) => {'category': e.key, 'amount': e.value}).toList();
    }

    double savingAmount = totalIncome - totalExpense;
    double savingRate = totalIncome > 0 ? (savingAmount / totalIncome) : 0;

    // Budget Risk
    List<Map<String, dynamic>> budgetRiskCategories = [];
    if (Get.isRegistered<BudgetController>()) {
      final bc = Get.find<BudgetController>();
      for (var usage in bc.budgetUsages) {
        budgetRiskCategories.add({
          'category': usage.budget.categoryId,
          'limit': usage.budget.monthlyLimit,
          'spent': usage.currentUsage,
          'usagePercent': usage.percentage,
        });
      }
    }

    // Goal Summary
    List<Map<String, dynamic>> activeGoalsSummary = [];
    if (Get.isRegistered<GoalsController>()) {
      final gc = Get.find<GoalsController>();
      final activeGoals = gc.goals.where((g) => g.status == 'active').toList();
      for (var g in activeGoals) {
        final totalDays = g.targetDate.difference(g.createdAt).inDays;
        final elapsedDays = now.difference(g.createdAt).inDays;
        final expectedProgress = totalDays > 0 ? (elapsedDays / totalDays) * 100 : 0;
        final actualProgress = g.progressPercentage * 100;

        activeGoalsSummary.add({
          'title': g.title,
          'progressPercent': actualProgress,
          'prediction': actualProgress >= expectedProgress ? 'on_track' : 'behind',
        });
      }
    }

    // Recurring Next Month
    Map<String, double> recurringSummary = {'income': 0, 'expense': 0};
    if (Get.isRegistered<RecurringController>()) {
      final rc = Get.find<RecurringController>();
      for (var r in rc.recurrings) {
        if (r.isActive) {
          if (r.type == 'income') recurringSummary['income'] = (recurringSummary['income'] ?? 0) + r.amount;
          if (r.type == 'expense') recurringSummary['expense'] = (recurringSummary['expense'] ?? 0) + r.amount;
        }
      }
    }

    // Wallet Summary
    Map<String, String> walletSummary = {};
    double netWorth = 0;
    if (Get.isRegistered<WalletController>()) {
      final wc = Get.find<WalletController>();
      WalletModel? largest;
      // In a real scenario active is tracked by tx count, here we simplify to largest = active
      for (var w in wc.wallets) {
        netWorth += w.balance;
        if (largest == null || w.balance > largest.balance) {
          largest = w;
        }
      }
      walletSummary['largestWalletName'] = largest?.name ?? '';
      walletSummary['mostActiveWalletName'] = largest?.name ?? '';
    }

    // Health Score
    final healthScore = FinancialHealthService.calculate();
    
    // Growth (Simple approx based on saving vs networth)
    final prevNetWorth = netWorth - savingAmount;
    final growth = prevNetWorth > 0 ? (savingAmount / prevNetWorth) : 0.0;

    return FinancialContextModel(
      month: monthName,
      year: now.year,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      savingAmount: savingAmount,
      savingRate: savingRate * 100,
      financialHealthScore: healthScore.totalScore,
      netWorth: netWorth,
      netWorthGrowthPercent: growth,
      topExpenseCategories: topExpenseCategories,
      budgetRiskCategories: budgetRiskCategories,
      activeGoalsSummary: activeGoalsSummary,
      recurringNextMonthSummary: recurringSummary,
      walletSummary: walletSummary,
      behaviorFlags: [],
    );
  }
}
