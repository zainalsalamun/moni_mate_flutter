import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'daily_financial_brief_model.g.dart';

@HiveType(typeId: 16)
enum DailyBriefPriority {
  @HiveField(0)
  info,
  @HiveField(1)
  success,
  @HiveField(2)
  warning,
  @HiveField(3)
  danger,
}

@HiveType(typeId: 17)
enum DailyBriefCategory {
  @HiveField(0)
  budget,
  @HiveField(1)
  goal,
  @HiveField(2)
  emergency,
  @HiveField(3)
  wealth,
  @HiveField(4)
  gamification,
  @HiveField(5)
  health,
  @HiveField(6)
  general,
}

@HiveType(typeId: 15)
class DailyFinancialBriefModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String summary;

  @HiveField(4)
  final DailyBriefPriority priority;

  @HiveField(5)
  final DailyBriefCategory category;

  @HiveField(6)
  final DateTime generatedAt;

  @HiveField(7)
  bool isRead;

  DailyFinancialBriefModel({
    String? id,
    required this.date,
    required this.title,
    required this.summary,
    required this.priority,
    required this.category,
    DateTime? generatedAt,
    this.isRead = false,
  })  : id = id ?? const Uuid().v4(),
        generatedAt = generatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'summary': summary,
      'priority': priority.index,
      'category': category.index,
      'generatedAt': generatedAt.toIso8601String(),
      'isRead': isRead,
    };
  }
}
