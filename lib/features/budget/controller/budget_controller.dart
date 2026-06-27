import 'package:get/get.dart';
import 'package:monimate/data/controller/transaction_controller.dart';
import 'package:monimate/data/services/hive_service.dart';
import 'package:monimate/data/services/notification_service.dart';
import 'package:monimate/data/controller/sync_controller.dart';
import 'package:monimate/features/financial_inbox/services/financial_notification_service.dart';
import '../model/budget_model.dart';
import '../engine/budget_engine.dart';
import 'package:uuid/uuid.dart';

class BudgetController extends GetxController {
  final RxList<BudgetModel> budgets = <BudgetModel>[].obs;
  final RxList<BudgetUsage> budgetUsages = <BudgetUsage>[].obs;
  final RxList<BudgetInsight> insights = <BudgetInsight>[].obs;
  final RxBool isStrictMode = false.obs;

  final TransactionController txController = Get.find<TransactionController>();

  @override
  void onInit() {
    super.onInit();
    loadBudgets();
    checkAndResetBudgets();

    // Listen to transaction changes to update usage
    ever(txController.transactions, (_) => updateUsage());
  }

  void loadBudgets() {
    budgets.assignAll(HiveService.getAllBudgets());
    updateUsage();
  }

  void updateUsage() {
    budgetUsages.assignAll(
        BudgetEngine.calculateUsage(budgets, txController.transactions));
    insights.assignAll(
        BudgetEngine.generateInsights(txController.transactions, budgetUsages));
    checkAlerts();
  }

  void addBudget(String categoryId, double limit,
      {BudgetPeriod period = BudgetPeriod.monthly}) {
    // Check if budget for this category already exists
    final existingIndex = budgets.indexWhere(
        (b) => b.categoryId.toLowerCase() == categoryId.toLowerCase());
    if (existingIndex != -1) {
      final existing = budgets[existingIndex];
      existing.monthlyLimit = limit;
      existing.period = period;
      existing.updatedAt = DateTime.now();
      existing.isSynced = false;
      existing.save();
      budgets[existingIndex] = existing;
    } else {
      final budget = BudgetModel(
        id: const Uuid().v4(),
        categoryId: categoryId,
        monthlyLimit: limit,
        startMonth: DateTime.now(),
        period: period,
      );
      HiveService.addBudget(budget);
      budgets.add(budget);
    }
    updateUsage();
    if (Get.isRegistered<SyncController>()) Get.find<SyncController>().notifyDataChanged();
  }

  void deleteBudget(String id) {
    HiveService.deleteBudget(id);
    budgets.removeWhere((b) => b.id == id);
    updateUsage();
    if (Get.isRegistered<SyncController>()) Get.find<SyncController>().notifyDataChanged();
  }

  // Set alert flags to prevent multiple notifications in one session
  final Map<String, bool> _alert80Sent = {};
  final Map<String, bool> _alert100Sent = {};

  void checkAlerts() {
    for (var usage in budgetUsages) {
      final key80 = "${usage.budget.id}_80";
      final key100 = "${usage.budget.id}_100";

      if (usage.percentage >= 100 && !(_alert100Sent[key100] ?? false)) {
        NotificationService.showNotification(
          id: usage.budget.hashCode + 100,
          title: 'Budget Terlampaui! 🚨',
          body:
              'Kamu sudah melewati budget kategori ${usage.budget.categoryId}',
        );
        if (Get.isRegistered<FinancialNotificationService>()) {
          Get.find<FinancialNotificationService>().sendBudgetAlert(usage.budget.categoryId, usage.percentage);
        }
        _alert100Sent[key100] = true;
      } else if (usage.percentage >= 80 &&
          usage.percentage < 100 &&
          !(_alert80Sent[key80] ?? false)) {
        NotificationService.showNotification(
          id: usage.budget.hashCode + 80,
          title: 'Budget Hampir Habis ⚠️',
          body:
              'Budget ${usage.budget.categoryId} sudah terpakai ${usage.percentage.toStringAsFixed(0)}%',
        );
        if (Get.isRegistered<FinancialNotificationService>()) {
          Get.find<FinancialNotificationService>().sendBudgetAlert(usage.budget.categoryId, usage.percentage);
        }
        _alert80Sent[key80] = true;
      }
    }
  }

  // Advanced: Auto Suggest Budget
  double suggestBudget(String categoryId) {
    final now = DateTime.now();
    final longAgo = DateTime(now.year, now.month - 3);

    final categoryTransactions = txController.transactions.where((t) {
      return t.type == 'expense' &&
          t.category.toLowerCase() == categoryId.toLowerCase() &&
          t.date.isAfter(longAgo);
    }).toList();

    if (categoryTransactions.isEmpty) return 0;

    final total = categoryTransactions.fold(0.0, (sum, t) => sum + t.amount);
    // Rough average per month
    final avg = total / 3;
    if (avg == 0) return 0;

    return (avg * 1.1).roundToDouble(); // Suggest 10% more than average
  }

  // Reset logic (called on app start or periodically)
  void checkAndResetBudgets() {
    final now = DateTime.now();
    bool changed = false;
    for (var budget in budgets) {
      if (budget.startMonth.month != now.month ||
          budget.startMonth.year != now.year) {
        budget.startMonth = DateTime(now.year, now.month, 1);
        budget.save();
        changed = true;
      }
    }
    if (changed) {
      updateUsage();
    }
  }
}
