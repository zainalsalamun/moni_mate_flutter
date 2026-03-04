import 'package:hive/hive.dart';

part 'recurring_transaction_model.g.dart';

@HiveType(typeId: 3)
class RecurringTransactionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String category;

  @HiveField(4)
  String type; // 'income' or 'expense'

  @HiveField(5)
  String repeatType; // 'daily', 'weekly', 'monthly', 'yearly'

  @HiveField(6)
  DateTime startDate;

  @HiveField(7)
  DateTime? endDate;

  @HiveField(8)
  int interval;

  @HiveField(9)
  DateTime nextExecutionDate;

  @HiveField(10)
  bool isActive;

  RecurringTransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.repeatType,
    required this.startDate,
    this.endDate,
    required this.interval,
    required this.nextExecutionDate,
    required this.isActive,
  });
}
