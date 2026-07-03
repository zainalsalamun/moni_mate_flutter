import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../data/services/hive_service.dart';
import '../../wallet/data/models/wallet_model.dart';
import '../../emergency_fund/controllers/emergency_fund_controller.dart';
import '../../financial_health/services/financial_health_service.dart';
import '../../gamification/controllers/gamification_controller.dart';
import '../models/monthly_report_model.dart';
import '../views/report_image_template.dart';

class MonthlyReportService {
  static final ScreenshotController _screenshotController =
      ScreenshotController();

  static Future<MonthlyReportModel?> generateReport(int month, int year) async {
    // Check if already exists and files are present
    final existing = HiveService.getAllMonthlyReports()
        .where((r) => r.month == month && r.year == year)
        .toList();
    if (existing.isNotEmpty) {
      final report = existing.first;
      bool pdfExists =
          report.pdfPath != null && await File(report.pdfPath!).exists();
      bool imageExists =
          report.imagePath != null && await File(report.imagePath!).exists();

      if (pdfExists && imageExists) {
        return report;
      } else {
        // Files missing (e.g. synced from cloud), so we delete and regenerate
        await HiveService.deleteMonthlyReport(report.id);
      }
    }

    final now = DateTime.now();
    final transactions = HiveService.getAll()
        .where((t) => t.date.month == month && t.date.year == year)
        .toList();

    // 1. Financial Summary
    double income = 0;
    double expense = 0;
    final Map<String, double> expenseByCategory = {};
    for (var t in transactions) {
      if (t.type == 'income') {
        income += t.amount;
      } else {
        expense += t.amount;
        expenseByCategory[t.category] =
            (expenseByCategory[t.category] ?? 0) + t.amount;
      }
    }
    double saving = income - expense;
    double savingRate = income > 0 ? (saving / income) : 0;

    // 2. Financial Health
    final healthScore = FinancialHealthService.calculate();

    // 3. Net Worth & Growth
    final wallets = HiveService.getAllWallets();
    double netWorth = wallets.fold(0.0, (sum, w) => sum + w.balance);
    double prevNetWorth = netWorth - saving;
    double growth = prevNetWorth > 0 ? (saving / prevNetWorth) : 0;

    final snapshots = HiveService.getAllNetWorthSnapshots();
    double ath = netWorth;
    for (var s in snapshots) {
      if (s.netWorth > ath) ath = s.netWorth;
    }

    // 4. Budget Summary
    final budgets = HiveService.getAllBudgets();
    int overbudgetCount = 0;
    String bestCategory = '-';
    String worstCategory = '-';
    double bestUsage = double.infinity;
    double worstUsage = -1;

    for (var budget in budgets) {
      double spent = expenseByCategory[budget.categoryId] ?? 0;
      double percentage = spent / budget.monthlyLimit;
      if (percentage > 1.0) overbudgetCount++;

      if (percentage < bestUsage) {
        bestUsage = percentage;
        bestCategory = budget.categoryId;
      }
      if (percentage > worstUsage) {
        worstUsage = percentage;
        worstCategory = budget.categoryId;
      }
    }

    // 5. Goals Summary
    final goals =
        HiveService.getAllGoals().where((g) => g.status == 'active').toList();
    int activeGoalsCount = goals.length;
    String closestGoal = '-';
    double closestProgress = 0;
    for (var g in goals) {
      if (g.progressPercentage > closestProgress) {
        closestProgress = g.progressPercentage;
        closestGoal = g.title;
      }
    }

    // 6. Top Spending
    final sortedExpenses = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = sortedExpenses
        .take(5)
        .map((e) => {'name': e.key, 'amount': e.value})
        .toList();

    // 7. Wallet Distribution
    double cash = 0, bank = 0, ewallet = 0, investment = 0;
    WalletModel? biggestWallet;
    for (var w in wallets) {
      if (biggestWallet == null || w.balance > biggestWallet.balance) {
        biggestWallet = w;
      }
      if (w.type == 'cash') {
        cash += w.balance;
      } else if (w.type == 'bank')
        bank += w.balance;
      else if (w.type == 'ewallet')
        ewallet += w.balance;
      else if (w.type == 'investment') investment += w.balance;
    }

    // 8. AI Insights (Algorithmic)
    List<String> insights = [];
    if (savingRate >= 0.2) {
      insights.add(
          "Tabungan kamu mencapai ${(savingRate * 100).toStringAsFixed(0)}% dari pendapatan. Sangat baik!");
    } else if (savingRate < 0.05)
      insights.add(
          "Tabungan bulan ini cukup rendah. Yuk kurangi pengeluaran yang tidak perlu.");

    if (growth > 0) {
      insights.add(
          "Net worth bertumbuh ${(growth * 100).toStringAsFixed(1)}% dibanding bulan lalu.");
    } else if (growth < 0)
      insights.add(
          "Net worth menurun. Pastikan pengeluaran tidak lebih besar dari pendapatan.");

    if (overbudgetCount > 0) {
      insights.add(
          "Ada $overbudgetCount kategori pengeluaran yang melebihi budget.");
    } else if (budgets.isNotEmpty)
      insights
          .add("Luar biasa! Tidak ada pengeluaran yang overbudget bulan ini.");

    // 9. Badges
    List<String> badges = [];
    if (savingRate >= 0.3) badges.add("Saving Master");
    if (overbudgetCount == 0 && budgets.isNotEmpty) badges.add("Budget Master");
    if (closestProgress >= 0.9) badges.add("Goal Hunter");
    if (badges.isEmpty) badges.add("Consistent Saver");

    // 10. Emergency Fund Tracker
    double emergencyCurrent = 0;
    double emergencyTarget = 0;
    double emergencyMonths = 0;
    String emergencyStatus = 'N/A';
    double emergencyProgress = 0;

    if (Get.isRegistered<EmergencyFundController>()) {
      final metrics = Get.find<EmergencyFundController>().metrics.value;
      emergencyCurrent = metrics.currentFund;
      emergencyTarget = metrics.targetFund;
      emergencyMonths = metrics.monthsCovered;
      emergencyStatus = metrics.readinessStatus;
      emergencyProgress = metrics.progressPercent;
    }

    // 11. Gamification & Financial Journey
    int level = 1;
    String rank = 'Financial Starter';
    int xp = 0;
    int streak = 0;
    List<String> monthlyAchievements = [];

    if (Get.isRegistered<GamificationController>()) {
      final gc = Get.find<GamificationController>();
      final progress = gc.progress.value;
      level = progress.currentLevel;
      rank = progress.currentRank;
      xp = progress.totalXpEarned;
      streak = progress.currentStreak;

      final recent = gc.achievements
          .where((a) {
            if (a.unlockedAt == null) return false;
            return a.unlockedAt!.month == month && a.unlockedAt!.year == year;
          })
          .map((a) => a.title)
          .toList();
      monthlyAchievements = recent;
    }

    // Serialize Summary Data
    final summaryData = {
      'income': income,
      'expense': expense,
      'saving': saving,
      'savingRate': savingRate,
      'healthScore': healthScore.totalScore,
      'healthCategory': healthScore.category,
      'netWorth': netWorth,
      'ath': ath,
      'growth': growth,
      'bestCategory': bestCategory,
      'bestUsage': bestUsage,
      'worstCategory': worstCategory,
      'worstUsage': worstUsage,
      'overbudgetCount': overbudgetCount,
      'activeGoalsCount': activeGoalsCount,
      'closestGoal': closestGoal,
      'closestProgress': closestProgress,
      'topCategories': topCategories,
      'cash': cash,
      'bank': bank,
      'ewallet': ewallet,
      'investment': investment,
      'biggestWalletName': biggestWallet?.name ?? '-',
      'biggestWalletBalance': biggestWallet?.balance ?? 0,
      'insights': insights,
      'badges': badges,
      'emergencyCurrent': emergencyCurrent,
      'emergencyTarget': emergencyTarget,
      'emergencyMonths': emergencyMonths,
      'emergencyStatus': emergencyStatus,
      'emergencyProgress': emergencyProgress,
      'gamificationLevel': level,
      'gamificationRank': rank,
      'gamificationXp': xp,
      'gamificationStreak': streak,
      'gamificationAchievements': monthlyAchievements,
    };

    // GENERATE PDF
    final pdfBytes = await _generatePdf(month, year, summaryData);
    final pdfFile = await _saveFile(pdfBytes,
        'MoniMate_Report_${year}_${month.toString().padLeft(2, '0')}.pdf');

    // GENERATE IMAGE (Using Screenshot)
    Uint8List? imageBytes;
    File? imageFile;
    try {
      imageBytes = await _screenshotController.captureFromWidget(
        MediaQuery(
          data: const MediaQueryData(),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Material(
              child: ReportImageTemplate(data: summaryData, month: month, year: year),
            ),
          ),
        ),
        delay: const Duration(milliseconds: 200),
        targetSize: const Size(1080, 1920),
      );
      imageFile = await _saveFile(imageBytes,
          'MoniMate_Report_${year}_${month.toString().padLeft(2, '0')}.png');
    } catch (e, stackTrace) {
      debugPrint('=============================================');
      debugPrint('ERROR GENERATING REPORT IMAGE: $e');
      debugPrint('STACKTRACE: $stackTrace');
      debugPrint('=============================================');
    }

    final report = MonthlyReportModel(
      id: const Uuid().v4(),
      month: month,
      year: year,
      generatedAt: now,
      pdfPath: pdfFile.path,
      imagePath: imageFile?.path,
      summaryDataJson: jsonEncode(summaryData),
    );

    await HiveService.addMonthlyReport(report);

    // GAMIFICATION Trigger
    if (Get.isRegistered<GamificationController>()) {
      final gc = Get.find<GamificationController>();
      gc.addXp(30, 'Generate laporan bulanan');

      final reportsCount = HiveService.getAllMonthlyReports().length;
      if (reportsCount == 1) {
        gc.unlockAchievement('report_first');
      }
      if (reportsCount >= 12) {
        gc.unlockAchievement('report_collector');
      }
    }

    return report;
  }

  static Future<File> _saveFile(Uint8List bytes, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future<Uint8List> _generatePdf(
      int month, int year, Map<String, dynamic> data) async {
    final pdf = pw.Document();

    // Formatting helpers
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final percentFormat = NumberFormat.percentPattern('id_ID');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                    level: 0,
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('MoniMate Monthly Report',
                            style: pw.TextStyle(
                                fontSize: 24,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromHex('#48C6EF'))),
                        pw.Text(
                            DateFormat('MMMM yyyy', 'id_ID')
                                .format(DateTime(year, month)),
                            style: const pw.TextStyle(
                                fontSize: 18, color: PdfColors.grey700)),
                      ],
                    )),
                pw.SizedBox(height: 20),

                // Financial Summary
                pw.Text('Financial Summary',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Divider(),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPdfStat(
                          'Income',
                          currencyFormat.format(data['income']),
                          PdfColors.green700),
                      _buildPdfStat(
                          'Expense',
                          currencyFormat.format(data['expense']),
                          PdfColors.red700),
                      _buildPdfStat(
                          'Saving',
                          currencyFormat.format(data['saving']),
                          PdfColors.blue700),
                      _buildPdfStat(
                          'Saving Rate',
                          percentFormat.format(data['savingRate']),
                          PdfColors.purple700),
                    ]),
                pw.SizedBox(height: 20),

                // Health & Net Worth
                pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                          child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                            pw.Text('Financial Health',
                                style: pw.TextStyle(
                                    fontSize: 18,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Divider(),
                            pw.Text(
                                '${data['healthScore'].toStringAsFixed(0)} / 100',
                                style: pw.TextStyle(
                                    fontSize: 24,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text(data['healthCategory'],
                                style: const pw.TextStyle(
                                    fontSize: 14, color: PdfColors.grey700)),
                          ])),
                      pw.SizedBox(width: 20),
                      pw.Expanded(
                          child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                            pw.Text('Net Worth',
                                style: pw.TextStyle(
                                    fontSize: 18,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Divider(),
                            pw.Text(currencyFormat.format(data['netWorth']),
                                style: pw.TextStyle(
                                    fontSize: 24,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text(
                                'Growth: ${(data['growth'] * 100).toStringAsFixed(1)}% vs last month',
                                style: pw.TextStyle(
                                    fontSize: 14,
                                    color: data['growth'] >= 0
                                        ? PdfColors.green700
                                        : PdfColors.red700)),
                            pw.Text(
                                'All-Time High: ${currencyFormat.format(data['ath'] ?? data['netWorth'])}',
                                style: const pw.TextStyle(
                                    fontSize: 12, color: PdfColors.grey700)),
                          ])),
                    ]),
                pw.SizedBox(height: 20),

                // Emergency Fund
                if (data['emergencyTarget'] > 0) ...[
                  pw.Text('Emergency Fund Status',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Divider(),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        _buildPdfStat(
                            'Current Fund',
                            currencyFormat.format(data['emergencyCurrent']),
                            PdfColors.blue700),
                        _buildPdfStat(
                            'Target Fund',
                            currencyFormat.format(data['emergencyTarget']),
                            PdfColors.grey700),
                        _buildPdfStat(
                            'Months Covered',
                            '${data['emergencyMonths'].toStringAsFixed(1)} Months',
                            PdfColors.orange700),
                        _buildPdfStat('Readiness', data['emergencyStatus'],
                            PdfColors.green700),
                        _buildPdfStat(
                            'Progress',
                            percentFormat.format(data['emergencyProgress']),
                            PdfColors.purple700),
                      ]),
                  pw.SizedBox(height: 20),
                ],

                // AI Insights
                pw.Text('AI Insight Summary',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Divider(),
                ...List<pw.Widget>.generate((data['insights'] as List).length,
                    (index) {
                  return pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 8),
                      child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('• ',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 16)),
                            pw.Expanded(
                                child: pw.Text(data['insights'][index],
                                    style: const pw.TextStyle(fontSize: 14))),
                          ]));
                }),
              ]);
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPdfStat(String label, String value, PdfColor color) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label,
              style:
                  const pw.TextStyle(color: PdfColors.grey700, fontSize: 12)),
          pw.SizedBox(height: 4),
          pw.Text(value,
              style: pw.TextStyle(
                  color: color, fontSize: 16, fontWeight: pw.FontWeight.bold)),
        ]);
  }
}
