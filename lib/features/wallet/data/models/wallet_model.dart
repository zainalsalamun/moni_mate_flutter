import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'wallet_model.g.dart';

@HiveType(typeId: 8)
class WalletModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String type; // 'cash', 'bank', 'ewallet', 'investment', 'other'

  @HiveField(3)
  double balance;

  @HiveField(4)
  String icon; // emoji

  @HiveField(5)
  String colorHex;

  @HiveField(6)
  bool isDefault;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime? updatedAt;

  @HiveField(9, defaultValue: false)
  bool isSynced;

  WalletModel({
    String? id,
    required this.name,
    required this.type,
    this.balance = 0.0,
    this.icon = '💰',
    this.colorHex = '#0288D1',
    this.isDefault = false,
    DateTime? createdAt,
    this.updatedAt,
    this.isSynced = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();
}
