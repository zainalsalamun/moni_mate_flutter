import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'contribution_model.g.dart';

@HiveType(typeId: 7)
class ContributionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String goalId;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String note;

  @HiveField(5)
  DateTime? updatedAt;

  @HiveField(6, defaultValue: false)
  bool isSynced;

  ContributionModel({
    String? id,
    required this.goalId,
    required this.amount,
    required this.date,
    this.note = '',
    this.updatedAt,
    this.isSynced = false,
  })  : id = id ?? const Uuid().v4();
}
