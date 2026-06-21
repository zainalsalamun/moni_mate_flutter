import 'package:get/get.dart';
import 'package:monimate/data/controller/transaction_controller.dart';
import 'package:monimate/data/models/transaction_model.dart';
import 'package:monimate/features/budget/controller/budget_controller.dart';
import 'package:monimate/features/financial_goals/controllers/goals_controller.dart';
import 'package:monimate/features/wallet/controllers/wallet_controller.dart';
import 'package:monimate/features/wallet/data/models/wallet_model.dart';
import '../models/financial_health_model.dart';

class FinancialHealthService {
  /// Main entry point: calculate the full Financial Health Score
  static FinancialHealthScore calculate() {
    final txController = Get.find<TransactionController>();
    final transactions = txController.transactions;

    final budgetScore = _calculateBudgetScore();
    final goalScore = _calculateGoalScore();
    final savingScore = _calculateSavingScore(transactions);
    final trendScore = _calculateTrendScore(transactions);
    final emergencyScore = _calculateEmergencyScore(transactions);

    final totalScore =
        budgetScore + goalScore + savingScore + trendScore + emergencyScore;
    final category = FinancialHealthScore.getCategory(totalScore);
    final insights = _generateInsights(
      transactions: transactions,
      budgetScore: budgetScore,
      goalScore: goalScore,
      savingScore: savingScore,
      trendScore: trendScore,
      emergencyScore: emergencyScore,
      totalScore: totalScore,
    );

    return FinancialHealthScore(
      totalScore: totalScore,
      budgetScore: budgetScore,
      goalScore: goalScore,
      savingScore: savingScore,
      trendScore: trendScore,
      emergencyScore: emergencyScore,
      category: category,
      insights: insights,
      calculatedAt: DateTime.now(),
    );
  }

  // =========================================================================
  // 1. BUDGET COMPLIANCE (max 30 points)
  // =========================================================================
  static double _calculateBudgetScore() {
    if (!Get.isRegistered<BudgetController>()) return 0;
    final budgetCtrl = Get.find<BudgetController>();
    final usages = budgetCtrl.budgetUsages;

    if (usages.isEmpty) return 15; // No budgets set → neutral score

    int compliant = 0;
    for (var usage in usages) {
      if (usage.percentage <= 100) compliant++;
    }

    final ratio = compliant / usages.length;
    return ratio * 30;
  }

  // =========================================================================
  // 2. GOAL PROGRESS (max 25 points)
  // =========================================================================
  static double _calculateGoalScore() {
    if (!Get.isRegistered<GoalsController>()) return 0;
    final goalsCtrl = Get.find<GoalsController>();
    final activeGoals =
        goalsCtrl.goals.where((g) => g.status == 'active').toList();

    if (activeGoals.isEmpty) return 0; // No goals → 0 points

    double totalProgress = 0;
    for (var goal in activeGoals) {
      totalProgress += goal.progressPercentage;
    }
    final avgProgress = totalProgress / activeGoals.length;
    return avgProgress * 25;
  }

  // =========================================================================
  // 3. SAVING RATIO (max 20 points)
  // =========================================================================
  static double _calculateSavingScore(List<TransactionModel> transactions) {
    final now = DateTime.now();
    final monthTx = transactions.where((t) {
      return t.date.year == now.year && t.date.month == now.month;
    }).toList();

    double income = 0;
    double expense = 0;
    for (var t in monthTx) {
      if (t.type == 'income') {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }

    if (income <= 0) return 0;

    final ratio = (income - expense) / income;

    if (ratio >= 0.30) return 20;
    if (ratio >= 0.20) return 15;
    if (ratio >= 0.10) return 10;
    if (ratio > 0) return 5;
    return 0;
  }

  // =========================================================================
  // 4. SPENDING TREND (max 15 points)
  // =========================================================================
  static double _calculateTrendScore(List<TransactionModel> transactions) {
    final now = DateTime.now();

    // Current month expenses
    final currentMonthExpenses = transactions
        .where((t) =>
            t.type == 'expense' &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);

    // Previous month expenses
    final prevMonth = now.month == 1 ? 12 : now.month - 1;
    final prevYear = now.month == 1 ? now.year - 1 : now.year;
    final prevMonthExpenses = transactions
        .where((t) =>
            t.type == 'expense' &&
            t.date.year == prevYear &&
            t.date.month == prevMonth)
        .fold(0.0, (sum, t) => sum + t.amount);

    // No previous month data → neutral
    if (prevMonthExpenses == 0) return 10;

    final change =
        (currentMonthExpenses - prevMonthExpenses) / prevMonthExpenses;

    // Spending went down → good
    if (change <= -0.10) return 15;
    // Stable (within ±20%)
    if (change.abs() <= 0.20) return 10;
    // Increased > 20% but <= 40%
    if (change <= 0.40) return 5;
    // Increased > 40%
    return 0;
  }

  // =========================================================================
  // 5. EMERGENCY FUND READINESS (max 10 points)
  // =========================================================================
  static double _calculateEmergencyScore(
      List<TransactionModel> transactions) {
    if (!Get.isRegistered<WalletController>()) return 0;
    final walletCtrl = Get.find<WalletController>();

    // Cash + Bank wallet balances
    double liquidFunds = 0;
    for (var wallet in walletCtrl.wallets) {
      if (wallet.type == 'cash' || wallet.type == 'bank') {
        liquidFunds += wallet.balance;
      }
    }

    // Check for emergency goal
    if (Get.isRegistered<GoalsController>()) {
      final goalsCtrl = Get.find<GoalsController>();
      final emergencyGoal = goalsCtrl.goals.firstWhereOrNull(
        (g) =>
            g.name.toLowerCase().contains('darurat') ||
            g.name.toLowerCase().contains('emergency'),
      );
      if (emergencyGoal != null) {
        liquidFunds += emergencyGoal.currentAmount;
      }
    }

    // Calculate average monthly expenses (last 3 months)
    final now = DateTime.now();
    double totalExpense3Months = 0;
    for (int i = 0; i < 3; i++) {
      final m = now.month - i;
      final y = m <= 0 ? now.year - 1 : now.year;
      final month = m <= 0 ? m + 12 : m;

      totalExpense3Months += transactions
          .where((t) =>
              t.type == 'expense' &&
              t.date.year == y &&
              t.date.month == month)
          .fold(0.0, (sum, t) => sum + t.amount);
    }

    final avgMonthlyExpense = totalExpense3Months / 3;
    if (avgMonthlyExpense <= 0) return 10; // No expenses → fully covered

    final monthsCovered = liquidFunds / avgMonthlyExpense;

    if (monthsCovered >= 3) return 10;
    if (monthsCovered >= 2) return 7;
    if (monthsCovered >= 1) return 5;
    return 0;
  }

  // =========================================================================
  // INSIGHT GENERATOR
  // =========================================================================
  static List<String> _generateInsights({
    required List<TransactionModel> transactions,
    required double budgetScore,
    required double goalScore,
    required double savingScore,
    required double trendScore,
    required double emergencyScore,
    required double totalScore,
  }) {
    final insights = <String>[];
    final now = DateTime.now();

    // Budget insights
    if (budgetScore >= 27) {
      insights.add('Kamu berhasil menjaga budget bulan ini! 💪');
    } else if (budgetScore < 15) {
      insights.add('Banyak budget yang terlampaui. Coba kurangi pengeluaran di kategori yang melebihi batas.');
    }

    // Saving ratio insights
    final monthTx = transactions.where((t) {
      return t.date.year == now.year && t.date.month == now.month;
    }).toList();
    double income = 0;
    double expense = 0;
    for (var t in monthTx) {
      if (t.type == 'income') {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }
    if (income > 0) {
      final ratio = (income - expense) / income;
      if (ratio >= 0.25) {
        insights.add(
            'Saving ratio kamu berada di ${(ratio * 100).toStringAsFixed(0)}%. Hebat! 🎉');
      } else if (ratio < 0.10) {
        insights.add(
            'Saving ratio kamu hanya ${(ratio * 100).toStringAsFixed(0)}%. Coba tingkatkan tabungan.');
      }
    }

    // Trend insights
    final currentMonthExpenses = transactions
        .where((t) =>
            t.type == 'expense' &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);
    final prevMonth = now.month == 1 ? 12 : now.month - 1;
    final prevYear = now.month == 1 ? now.year - 1 : now.year;
    final prevMonthExpenses = transactions
        .where((t) =>
            t.type == 'expense' &&
            t.date.year == prevYear &&
            t.date.month == prevMonth)
        .fold(0.0, (sum, t) => sum + t.amount);

    if (prevMonthExpenses > 0) {
      final change =
          (currentMonthExpenses - prevMonthExpenses) / prevMonthExpenses;
      if (change > 0.20) {
        insights.add(
            'Pengeluaran meningkat ${(change * 100).toStringAsFixed(0)}% dibanding bulan lalu.');
      } else if (change < -0.10) {
        insights.add(
            'Pengeluaran turun ${(change.abs() * 100).toStringAsFixed(0)}% dari bulan lalu. Bagus! 📉');
      }
    }

    // Goal insights
    if (goalScore >= 20) {
      insights.add('Progres target keuangan kamu sangat baik! 🏆');
    } else if (goalScore == 0 &&
        Get.isRegistered<GoalsController>() &&
        Get.find<GoalsController>().goals.isNotEmpty) {
      insights.add('Yuk mulai berkontribusi ke target keuangan kamu.');
    }

    // Emergency fund insights
    if (emergencyScore >= 10) {
      insights.add('Dana darurat kamu sudah aman untuk 3 bulan ke depan. 🛡️');
    } else if (emergencyScore == 0) {
      insights.add(
          'Dana darurat belum mencukupi. Sisihkan minimal 10% penghasilan untuk dana darurat.');
    }

    // Overall
    if (totalScore >= 90) {
      insights.add(
          'Kondisi keuangan kamu luar biasa! Pertahankan! ✨');
    }

    // Return max 3 insights, prioritize by importance
    return insights.take(3).toList();
  }
}
