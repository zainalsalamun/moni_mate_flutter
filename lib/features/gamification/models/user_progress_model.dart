import 'package:hive/hive.dart';

part 'user_progress_model.g.dart';

@HiveType(typeId: 13)
class UserProgressModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  int currentXp;

  @HiveField(2)
  int currentLevel;

  @HiveField(3)
  int totalXpEarned;

  @HiveField(4)
  int longestStreak;

  @HiveField(5)
  int currentStreak;

  @HiveField(6)
  String currentRank;

  @HiveField(7)
  DateTime? lastTransactionDate;

  @HiveField(8)
  DateTime updatedAt;

  UserProgressModel({
    required this.id,
    this.currentXp = 0,
    this.currentLevel = 1,
    this.totalXpEarned = 0,
    this.longestStreak = 0,
    this.currentStreak = 0,
    this.currentRank = 'Financial Starter',
    this.lastTransactionDate,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'currentXp': currentXp,
      'currentLevel': currentLevel,
      'totalXpEarned': totalXpEarned,
      'longestStreak': longestStreak,
      'currentStreak': currentStreak,
      'currentRank': currentRank,
      'lastTransactionDate': lastTransactionDate?.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    return UserProgressModel(
      id: json['id'] as String,
      currentXp: json['currentXp'] as int? ?? 0,
      currentLevel: json['currentLevel'] as int? ?? 1,
      totalXpEarned: json['totalXpEarned'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      currentRank: json['currentRank'] as String? ?? 'Financial Starter',
      lastTransactionDate: json['lastTransactionDate'] != null
          ? DateTime.parse(json['lastTransactionDate'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}
