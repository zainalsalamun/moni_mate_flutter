import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 2)
class CategoryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String type; // 'income' atau 'expense'

  @HiveField(2)
  String name; // nama kategori 'Makan', 'Gaji'

  @HiveField(3)
  String emoji; // icon/emoji kategori '🍲', '💼'

  @HiveField(4)
  bool isCustom; // default category (false) or user created (true)

  @HiveField(5)
  DateTime? updatedAt;

  @HiveField(6, defaultValue: false)
  bool isSynced;

  CategoryModel({
    required this.id,
    required this.type,
    required this.name,
    required this.emoji,
    this.isCustom = false,
    this.updatedAt,
    this.isSynced = false,
  });
}
