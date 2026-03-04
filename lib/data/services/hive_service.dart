import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/recurring_transaction_model.dart';

class HiveService {
  static const String boxName = 'transactions';
  static const String categoryBoxName = 'categories';
  static const String recurringBoxName = 'recurring_transactions';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(RecurringTransactionModelAdapter());
    await Hive.openBox<TransactionModel>(boxName);
    await Hive.openBox<CategoryModel>(categoryBoxName);
    await Hive.openBox<RecurringTransactionModel>(recurringBoxName);
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
}
