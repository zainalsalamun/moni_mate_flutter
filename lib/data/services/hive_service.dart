import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/recurring_transaction_model.dart';
import '../../features/budget/model/budget_model.dart';

class HiveService {
  static const String boxName = 'transactions';
  static const String categoryBoxName = 'categories';
  static const String recurringBoxName = 'recurring_transactions';
  static const String budgetBoxName = 'budgets';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(RecurringTransactionModelAdapter());
    Hive.registerAdapter(BudgetModelAdapter());
    Hive.registerAdapter(BudgetPeriodAdapter());

    await Hive.openBox<TransactionModel>(boxName);
    await Hive.openBox<CategoryModel>(categoryBoxName);
    await Hive.openBox<RecurringTransactionModel>(recurringBoxName);
    await Hive.openBox<BudgetModel>(budgetBoxName);
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
}
