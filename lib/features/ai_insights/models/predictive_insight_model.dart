import 'package:hive/hive.dart';

part 'predictive_insight_model.g.dart';

@HiveType(typeId: 10)
class PredictiveInsightModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String message;

  @HiveField(3)
  String type; // budget_prediction, goal_prediction, recurring_impact, wallet_health, net_worth, spending_behavior, saving_advice

  @HiveField(4)
  String severity; // info, success, warning, danger

  @HiveField(5)
  String source; // local, ai_api, hybrid

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  String actionLabel;

  @HiveField(8)
  String actionRoute;

  PredictiveInsightModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.severity,
    required this.source,
    required this.createdAt,
    this.actionLabel = '',
    this.actionRoute = '',
  });

  factory PredictiveInsightModel.fromJson(Map<String, dynamic> json) {
    return PredictiveInsightModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'info',
      severity: json['severity'] ?? 'info',
      source: json['source'] ?? 'ai_api',
      actionLabel: json['actionLabel'] ?? '',
      actionRoute: json['actionRoute'] ?? '',
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'severity': severity,
      'source': source,
      'actionLabel': actionLabel,
      'actionRoute': actionRoute,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
