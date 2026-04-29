import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'goal_model.g.dart';

@HiveType(typeId: 6)
class GoalModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double targetAmount;

  @HiveField(3)
  double currentAmount;

  @HiveField(4)
  DateTime targetDate;

  @HiveField(5)
  String status; // 'active' or 'completed'

  @HiveField(6)
  String iconPath; 
  
  @HiveField(7)
  String colorHex;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime? updatedAt;

  @HiveField(10, defaultValue: false)
  bool isSynced;

  GoalModel({
    String? id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.targetDate,
    this.status = 'active',
    this.iconPath = '', 
    this.colorHex = '#E1F5FE',
    DateTime? createdAt,
    this.updatedAt,
    this.isSynced = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();
        
  double get progressPercentage => targetAmount > 0 ? (currentAmount / targetAmount) : 0.0;
}
