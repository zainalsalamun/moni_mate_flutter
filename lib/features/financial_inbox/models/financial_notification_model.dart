import 'package:hive/hive.dart';

part 'financial_notification_model.g.dart';

@HiveType(typeId: 19)
enum NotificationCategory {
  @HiveField(0)
  aiCoach,
  @HiveField(1)
  budgetAlert,
  @HiveField(2)
  goalReminder,
  @HiveField(3)
  emergencyFund,
  @HiveField(4)
  achievement,
  @HiveField(5)
  monthlyReport,
  @HiveField(6)
  recurringTransaction,
  @HiveField(7)
  smartSpending,
}

@HiveType(typeId: 20)
enum NotificationPriority {
  @HiveField(0)
  critical,
  @HiveField(1)
  warning,
  @HiveField(2)
  success,
  @HiveField(3)
  info,
}

@HiveType(typeId: 18)
class FinancialNotificationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String message;

  @HiveField(3)
  final NotificationCategory category;

  @HiveField(4)
  final NotificationPriority priority;

  @HiveField(5)
  final String? actionRoute;

  @HiveField(6)
  final String? actionPayload;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  bool isRead;

  @HiveField(9)
  bool isDismissed;

  FinancialNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.priority,
    this.actionRoute,
    this.actionPayload,
    required this.createdAt,
    this.isRead = false,
    this.isDismissed = false,
  });

  FinancialNotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationCategory? category,
    NotificationPriority? priority,
    String? actionRoute,
    String? actionPayload,
    DateTime? createdAt,
    bool? isRead,
    bool? isDismissed,
  }) {
    return FinancialNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      actionRoute: actionRoute ?? this.actionRoute,
      actionPayload: actionPayload ?? this.actionPayload,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      isDismissed: isDismissed ?? this.isDismissed,
    );
  }
}
