import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';

class HiveService {
  static const String boxName = 'transactions';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionModelAdapter());
    await Hive.openBox<TransactionModel>(boxName);
  }

  static Box<TransactionModel> get box => Hive.box<TransactionModel>(boxName);

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
}
