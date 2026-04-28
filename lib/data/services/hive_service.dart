import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/recurring_transaction_model.dart';
import '../models/goal_model.dart';
import '../models/contribution_model.dart';
import '../../features/budget/model/budget_model.dart';

class HiveService {
  static const String boxName = 'transactions';
  static const String categoryBoxName = 'categories';
  static const String recurringBoxName = 'recurring_transactions';
  static const String budgetBoxName = 'budgets';
  static const String goalBoxName = 'goals';
  static const String contributionBoxName = 'contributions';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(RecurringTransactionModelAdapter());
    Hive.registerAdapter(BudgetModelAdapter());
    Hive.registerAdapter(BudgetPeriodAdapter());
    Hive.registerAdapter(GoalModelAdapter());
    Hive.registerAdapter(ContributionModelAdapter());

    await Hive.openBox<TransactionModel>(boxName);
    await Hive.openBox<CategoryModel>(categoryBoxName);
    await Hive.openBox<RecurringTransactionModel>(recurringBoxName);
    await Hive.openBox<BudgetModel>(budgetBoxName);
    await Hive.openBox<GoalModel>(goalBoxName);
    await Hive.openBox<ContributionModel>(contributionBoxName);
  }

  static Box<TransactionModel> get box => Hive.box<TransactionModel>(boxName);
  static Box<CategoryModel> get categoryBox =>
      Hive.box<CategoryModel>(categoryBoxName);
  static Box<RecurringTransactionModel> get recurringBox =>
      Hive.box<RecurringTransactionModel>(recurringBoxName);

  static Future<void> addTransaction(TransactionModel tx) async {
    await box.put(tx.id, tx);
  }

  static List<TransactionModel> getAll() {
    return box.values.toList();
  }

  static Future<void> deleteTransaction(String id) async {
    await box.delete(id);
  }

  static Future<void> clearAll() async {
    await box.clear();
  }

  // Categories Functionality
  static Future<void> addCategory(CategoryModel cat) async {
    await categoryBox.put(cat.id, cat);
  }

  static List<CategoryModel> getCustomCategories(String type) {
    return categoryBox.values.where((c) => c.type == type).toList();
  }

  static Future<void> deleteCategory(String id) async {
    await categoryBox.delete(id);
  }

  // Recurring Transactions Functionality
  static Future<void> addRecurringTransaction(
      RecurringTransactionModel tx) async {
    await recurringBox.put(tx.id, tx);
  }

  static List<RecurringTransactionModel> getAllRecurring() {
    return recurringBox.values.toList();
  }

  static Future<void> deleteRecurringTransaction(String id) async {
    await recurringBox.delete(id);
  }

  // Budget Functionality
  static Box<BudgetModel> get budgetBox => Hive.box<BudgetModel>(budgetBoxName);

  static Future<void> addBudget(BudgetModel budget) async {
    await budgetBox.put(budget.id, budget);
  }

  static List<BudgetModel> getAllBudgets() {
    return budgetBox.values.toList();
  }

  static Future<void> deleteBudget(String id) async {
    await budgetBox.delete(id);
  }

  // Financial Goals Functionality
  static Box<GoalModel> get goalBox => Hive.box<GoalModel>(goalBoxName);
  static Box<ContributionModel> get contributionBox => Hive.box<ContributionModel>(contributionBoxName);

  static Future<void> addGoal(GoalModel goal) async {
    await goalBox.put(goal.id, goal);
  }

  static List<GoalModel> getAllGoals() {
    return goalBox.values.toList();
  }

  static Future<void> deleteGoal(String id) async {
    await goalBox.delete(id);
  }

  static Future<void> addContribution(ContributionModel contribution) async {
    await contributionBox.put(contribution.id, contribution);
  }

  static List<ContributionModel> getContributionsForGoal(String goalId) {
    return contributionBox.values.where((c) => c.goalId == goalId).toList();
  }

  static Future<void> deleteContributionsByGoalId(String goalId) async {
    final contributions = contributionBox.values.where((c) => c.goalId == goalId).toList();
    for (var c in contributions) {
      await c.delete();
    }
  }
}
