import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../models/daily_financial_brief_model.dart';
import '../../../data/services/hive_service.dart';
import '../../ai_insights/services/ai_insight_api_service.dart';
import '../../../data/services/notification_service.dart';

import 'package:get_storage/get_storage.dart';

import 'package:monimate/features/financial_health/controllers/financial_health_controller.dart'
    as monimate_health;
import 'package:monimate/features/emergency_fund/controllers/emergency_fund_controller.dart'
    as monimate_ef;

class DailyCoachService extends GetxService {
  final _storage = GetStorage();

  Future<DailyCoachService> init() async {
    _scheduleNotifications();
    _checkAndGenerateDailyBriefs();
    return this;
  }

  void _scheduleNotifications() {
    final morningEnabled = _storage.read<bool>('morning_brief_enabled') ?? true;
    final eveningEnabled = _storage.read<bool>('evening_brief_enabled') ?? true;

    if (morningEnabled) {
      NotificationService.scheduleDailyNotification(
        id: 800,
        title: '☀️ Waktunya Cek Keuangan!',
        body: 'Selamat pagi! Ada insight finansial baru untukmu hari ini.',
        hour: 8,
        minute: 0,
      );
    } else {
      NotificationService.cancelNotification(800);
    }

    if (eveningEnabled) {
      NotificationService.scheduleDailyNotification(
        id: 2000,
        title: '🌙 Ringkasan Hari Ini',
        body: 'Cek progress keuanganmu setelah seharian beraktivitas.',
        hour: 20,
        minute: 0,
      );
    } else {
      NotificationService.cancelNotification(2000);
    }
  }

  Future<void> _checkAndGenerateDailyBriefs() async {
    final now = DateTime.now();
    final briefs = HiveService.getAllDailyBriefs();

    // Check morning brief
    if (now.hour >= 8) {
      final hasMorning = briefs.any((b) =>
          b.title.contains('Morning') &&
          b.date.year == now.year &&
          b.date.month == now.month &&
          b.date.day == now.day);

      if (!hasMorning &&
          (_storage.read<bool>('morning_brief_enabled') ?? true)) {
        await generateMorningBrief();
      }
    }

    // Check evening brief
    if (now.hour >= 20) {
      final hasEvening = briefs.any((b) =>
          b.title.contains('Evening') &&
          b.date.year == now.year &&
          b.date.month == now.month &&
          b.date.day == now.day);

      if (!hasEvening &&
          (_storage.read<bool>('evening_brief_enabled') ?? true)) {
        await generateEveningBrief();
      }
    }
  }

  Map<String, dynamic> _gatherContext() {
    final budgets = HiveService.budgetBox.values.toList();
    final goals = HiveService.goalBox.values.toList();
    final progress = HiveService.getUserProgress();
    final nw = HiveService.netWorthSnapshotBox.values.isNotEmpty
        ? HiveService.netWorthSnapshotBox.values.last
        : null;

    double healthScore = 0;
    if (Get.isRegistered<monimate_health.FinancialHealthController>()) {
      healthScore =
          Get.find<monimate_health.FinancialHealthController>().totalScore;
    }

    double efTarget = 0;
    double efCurrent = 0;
    if (Get.isRegistered<monimate_ef.EmergencyFundController>()) {
      efTarget = Get.find<monimate_ef.EmergencyFundController>()
          .metrics
          .value
          .targetFund;
      efCurrent = Get.find<monimate_ef.EmergencyFundController>()
          .metrics
          .value
          .currentFund;
    }

    return {
      "netWorth": nw?.netWorth ?? 0,
      "healthScore": healthScore,
      "level": progress.currentLevel,
      "xp": progress.currentXp,
      "streak": progress.currentStreak,
      "activeGoals": goals.length,
      "activeBudgets": budgets.length,
      "emergencyFundTarget": efTarget,
      "emergencyFundCurrent": efCurrent,
    };
  }

  Future<void> generateMorningBrief() async {
    try {
      final contextData = _gatherContext();

      final prompt = '''
Buat briefing finansial pagi yang singkat maksimal 100 kata.
Gunakan bahasa Indonesia yang hangat, positif, dan memotivasi.
JANGAN memberikan saran investasi. JANGAN menghakimi.
Berikut adalah status ringkas user:
Net Worth: Rp ${contextData['netWorth']}
Health Score: ${contextData['healthScore']}/100
Level: ${contextData['level']}
XP: ${contextData['xp']}
Dana Darurat: Rp ${contextData['emergencyFundCurrent']} dari Rp ${contextData['emergencyFundTarget']}
''';

      String response = await AiInsightApiService.getBriefText(prompt);

      if (response.isEmpty) {
        throw Exception("API returned empty");
      }

      final brief = DailyFinancialBriefModel(
        date: DateTime.now(),
        title: '☀️ Morning Financial Brief',
        summary: response,
        priority: DailyBriefPriority.info,
        category: DailyBriefCategory.general,
      );

      await HiveService.saveDailyBrief(brief);
      _showNotification(brief.title, 'Ketuk untuk melihat insight pagimu!');
    } catch (e) {
      debugPrint("Morning brief offline fallback: $e");
      final brief = DailyFinancialBriefModel(
        date: DateTime.now(),
        title: '☀️ Morning Financial Brief',
        summary:
            'Selamat pagi! Yuk cek status keuanganmu hari ini dan pertahankan kebiasaan baikmu. Net Worth saat ini: Rp ${_gatherContext()['netWorth']}.',
        priority: DailyBriefPriority.info,
        category: DailyBriefCategory.general,
      );
      await HiveService.saveDailyBrief(brief);
      _showNotification(brief.title, 'Ketuk untuk melihat insight pagimu!');
    }
  }

  Future<void> generateEveningBrief() async {
    try {
      final contextData = _gatherContext();
      final today = DateTime.now();
      final txs = HiveService.getAll()
          .where((t) =>
              t.date.year == today.year &&
              t.date.month == today.month &&
              t.date.day == today.day &&
              t.type == 'expense')
          .toList();

      double totalExpense = txs.fold(0.0, (sum, t) => sum + t.amount);

      final prompt = '''
Buat briefing finansial malam yang singkat maksimal 100 kata.
Gunakan bahasa Indonesia yang santai, positif. JANGAN menghakimi.
Berikut adalah aktivitas hari ini:
Total Pengeluaran Hari Ini: Rp $totalExpense dari ${txs.length} transaksi.
Streak Pencatatan: ${contextData['streak']} hari berturut-turut.
Level: ${contextData['level']}
''';

      String response = await AiInsightApiService.getBriefText(prompt);

      if (response.isEmpty) {
        throw Exception("API returned empty");
      }

      final brief = DailyFinancialBriefModel(
        date: DateTime.now(),
        title: '🌙 Evening Financial Brief',
        summary: response,
        priority: DailyBriefPriority.info,
        category: DailyBriefCategory.general,
      );

      await HiveService.saveDailyBrief(brief);
      _showNotification(brief.title, 'Cek ringkasan keuangan hari ini!');
    } catch (e) {
      debugPrint("Evening brief offline fallback: $e");
      final today = DateTime.now();
      final txs = HiveService.getAll()
          .where((t) =>
              t.date.year == today.year &&
              t.date.month == today.month &&
              t.date.day == today.day &&
              t.type == 'expense')
          .toList();
      double totalExpense = txs.fold(0.0, (sum, t) => sum + t.amount);

      final brief = DailyFinancialBriefModel(
        date: DateTime.now(),
        title: '🌙 Evening Financial Brief',
        summary:
            'Hari ini kamu mencatat ${txs.length} transaksi pengeluaran dengan total Rp $totalExpense. Streak kamu sekarang ${_gatherContext()['streak']} hari. Terus pertahankan!',
        priority: DailyBriefPriority.info,
        category: DailyBriefCategory.general,
      );
      await HiveService.saveDailyBrief(brief);
      _showNotification(brief.title, 'Cek ringkasan keuangan hari ini!');
    }
  }

  void _showNotification(String title, String body) {
    NotificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
    );
  }

  Future<void> generateBudgetAlerts() async {
    // Logic for budget alerts
  }

  Future<void> generateGoalAlerts() async {
    // Logic for goals
  }

  Future<void> generateEmergencyInsights() async {
    // Logic for emergency fund alerts
  }

  Future<void> generateGamificationInsights() async {
    // Logic for gamification alerts
  }
}
