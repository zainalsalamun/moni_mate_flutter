import 'package:hive/hive.dart';

part 'monthly_report_model.g.dart';

@HiveType(typeId: 9)
class MonthlyReportModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int month;

  @HiveField(2)
  final int year;

  @HiveField(3)
  final DateTime generatedAt;

  @HiveField(4)
  final String? pdfPath;

  @HiveField(5)
  final String? imagePath;

  @HiveField(6)
  final String summaryDataJson; // Store aggregated stats as JSON string

  MonthlyReportModel({
    required this.id,
    required this.month,
    required this.year,
    required this.generatedAt,
    this.pdfPath,
    this.imagePath,
    required this.summaryDataJson,
  });
}
