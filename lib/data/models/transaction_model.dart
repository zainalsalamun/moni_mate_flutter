import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 1)
class TransactionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String type; // 'income' atau 'expense'

  @HiveField(2)
  String category;

  @HiveField(3)
  double amount;

  @HiveField(4)
  String description;

  @HiveField(5)
  DateTime date;

  @HiveField(6)
  DateTime? updatedAt;

  @HiveField(7, defaultValue: false)
  bool isSynced;

  @HiveField(8, defaultValue: '')
  String walletId;

  TransactionModel({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
    this.updatedAt,
    this.isSynced = false,
    this.walletId = '',
  });
}
