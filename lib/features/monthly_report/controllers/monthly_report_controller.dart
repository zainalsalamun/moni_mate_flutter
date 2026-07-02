import 'dart:io';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/services/hive_service.dart';
import '../models/monthly_report_model.dart';
import '../services/monthly_report_service.dart';

class MonthlyReportController extends GetxController {
  final RxList<MonthlyReportModel> reports = <MonthlyReportModel>[].obs;
  final RxBool isGenerating = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadReports();
    _checkAndGeneratePreviousMonth();
  }

  void _loadReports() {
    final list = HiveService.getAllMonthlyReports();
    // Sort descending by date (newest first)
    list.sort((a, b) {
      if (a.year != b.year) return b.year.compareTo(a.year);
      return b.month.compareTo(a.month);
    });
    reports.value = list;
  }

  Future<void> _checkAndGeneratePreviousMonth() async {
    final now = DateTime.now();
    int prevMonth = now.month == 1 ? 12 : now.month - 1;
    int prevYear = now.month == 1 ? now.year - 1 : now.year;

    // Check if report for prev month exists
    bool exists =
        reports.any((r) => r.month == prevMonth && r.year == prevYear);
    if (!exists) {
      await generateReport(prevMonth, prevYear);
    }
  }

  Future<void> generateReport(int month, int year) async {
    isGenerating.value = true;
    try {
      final report = await MonthlyReportService.generateReport(month, year);
      if (report != null) {
        _loadReports();
      }
    } catch (e) {
      print("Failed to generate report: \$e");
    } finally {
      isGenerating.value = false;
    }
  }

  Future<void> shareReport(MonthlyReportModel report,
      {bool shareImage = false}) async {
    isGenerating.value = true;
    try {
      String? path = shareImage ? report.imagePath : report.pdfPath;

      // If path is missing or file doesn't exist (e.g., synced from another device), regenerate it
      if (path == null || path.isEmpty || !await File(path).exists()) {
        final newReport = await MonthlyReportService.generateReport(
            report.month, report.year);
        if (newReport != null) {
          path = shareImage ? newReport.imagePath : newReport.pdfPath;
        }
      }

      if (path == null || path.isEmpty) {
        Get.snackbar('Error', 'Gagal memuat file laporan.');
        return;
      }

      final XFile file = XFile(path);

      await Share.shareXFiles(
        [file],
        text:
            'Laporan Keuangan MoniMate saya untuk ${report.month}/${report.year}!',
      );
    } finally {
      isGenerating.value = false;
    }
  }

  Future<void> deleteReport(String id) async {
    await HiveService.deleteMonthlyReport(id);
    _loadReports();
  }
}
