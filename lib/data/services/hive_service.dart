import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';

class HiveService {
  static const String boxName = 'transactions';
  static const String categoryBoxName = 'categories';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(CategoryModelAdapter());
    await Hive.openBox<TransactionModel>(boxName);
    await Hive.openBox<CategoryModel>(categoryBoxName);
  }

  static Box<TransactionModel> get box => Hive.box<TransactionModel>(boxName);
  static Box<CategoryModel> get categoryBox =>
      Hive.box<CategoryModel>(categoryBoxName);

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
}
