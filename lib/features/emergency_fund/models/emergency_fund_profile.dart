import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'emergency_fund_profile.g.dart';

@HiveType(typeId: 11)
class EmergencyFundProfile extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String type; // 'single', 'married', 'freelancer', 'custom'

  @HiveField(2)
  int customMultiplier;

  @HiveField(3)
  DateTime updatedAt;

  @HiveField(4, defaultValue: false)
  bool isSynced;

  EmergencyFundProfile({
    String? id,
    this.type = 'single',
    this.customMultiplier = 3,
    DateTime? updatedAt,
    this.isSynced = false,
  })  : id = id ?? const Uuid().v4(),
        updatedAt = updatedAt ?? DateTime.now();

  int get multiplier {
    switch (type) {
      case 'single':
        return 3;
      case 'married':
        return 6;
      case 'freelancer':
        return 9;
      case 'custom':
        return customMultiplier;
      default:
        return 3;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'customMultiplier': customMultiplier,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory EmergencyFundProfile.fromJson(Map<String, dynamic> json) {
    return EmergencyFundProfile(
      id: json['id'],
      type: json['type'] ?? 'single',
      customMultiplier: json['customMultiplier'] ?? 3,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      isSynced: true,
    );
  }
}
