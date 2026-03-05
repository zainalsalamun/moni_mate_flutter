import 'package:hive/hive.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 5)
enum BudgetPeriod {
  @HiveField(0)
  weekly,
  @HiveField(1)
  monthly
}

@HiveType(typeId: 4)
class BudgetModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String categoryId;

  @HiveField(2)
  double monthlyLimit;

  @HiveField(3)
  DateTime startMonth;

  @HiveField(4)
  bool isActive;

  @HiveField(5)
  BudgetPeriod period;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.monthlyLimit,
    required this.startMonth,
    this.isActive = true,
    this.period = BudgetPeriod.monthly,
  });
}
