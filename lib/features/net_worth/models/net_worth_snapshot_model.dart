import 'package:hive/hive.dart';

part 'net_worth_snapshot_model.g.dart';

@HiveType(typeId: 12)
class NetWorthSnapshotModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int year;

  @HiveField(2)
  final int month;

  @HiveField(3)
  final DateTime snapshotDate;

  @HiveField(4)
  final double totalAssets;

  @HiveField(5)
  final double totalLiabilities;

  @HiveField(6)
  final double netWorth;

  @HiveField(7)
  final double growthPercentMoM;

  @HiveField(8)
  final double growthPercentYoY;

  @HiveField(9)
  final DateTime createdAt;

  NetWorthSnapshotModel({
    required this.id,
    required this.year,
    required this.month,
    required this.snapshotDate,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netWorth,
    required this.growthPercentMoM,
    required this.growthPercentYoY,
    required this.createdAt,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'year': year,
      'month': month,
      'snapshotDate': snapshotDate.toIso8601String(),
      'totalAssets': totalAssets,
      'totalLiabilities': totalLiabilities,
      'netWorth': netWorth,
      'growthPercentMoM': growthPercentMoM,
      'growthPercentYoY': growthPercentYoY,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory NetWorthSnapshotModel.fromJson(Map<String, dynamic> json) {
    return NetWorthSnapshotModel(
      id: json['id'] as String,
      year: json['year'] as int,
      month: json['month'] as int,
      snapshotDate: DateTime.parse(json['snapshotDate'] as String),
      totalAssets: (json['totalAssets'] as num).toDouble(),
      totalLiabilities: (json['totalLiabilities'] as num).toDouble(),
      netWorth: (json['netWorth'] as num).toDouble(),
      growthPercentMoM: (json['growthPercentMoM'] as num).toDouble(),
      growthPercentYoY: (json['growthPercentYoY'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
