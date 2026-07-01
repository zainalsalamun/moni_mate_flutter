import 'package:hive/hive.dart';

part 'achievement_model.g.dart';

@HiveType(typeId: 14)
class AchievementModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String icon; // We can store Icons.codePoint or just a string representation

  @HiveField(4)
  final String colorHex;

  @HiveField(5)
  String status; // 'locked', 'unlocked', 'completed'

  @HiveField(6)
  final String category; // 'streak', 'goals', 'budget', 'emergency_fund', 'net_worth', 'reports'

  @HiveField(7)
  DateTime? unlockedAt;

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.colorHex,
    this.status = 'locked',
    required this.category,
    this.unlockedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'colorHex': colorHex,
      'status': status,
      'category': category,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      colorHex: json['colorHex'] as String,
      status: json['status'] as String? ?? 'locked',
      category: json['category'] as String,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
    );
  }
}
