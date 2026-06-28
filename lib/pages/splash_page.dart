import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart'; // ⬅️ Tambahkan import ini
import 'package:monimate/data/controller/theme_controller.dart';
import 'package:monimate/data/controller/transaction_controller.dart';
import 'package:monimate/data/controller/recurring_controller.dart';
import 'package:monimate/data/controller/sync_controller.dart';
// import 'package:monimate/data/services/seeder_service.dart';
import 'package:monimate/data/services/hive_service.dart';
import 'package:monimate/data/services/notification_service.dart';
import 'package:monimate/features/budget/controller/budget_controller.dart';
import 'package:monimate/features/wallet/controllers/wallet_controller.dart';
import 'package:monimate/features/emergency_fund/controllers/emergency_fund_controller.dart';
import 'package:monimate/features/financial_health/controllers/financial_health_controller.dart';
import 'package:monimate/features/net_worth/controllers/net_worth_controller.dart';
import 'package:monimate/features/net_worth/services/wealth_timeline_service.dart';
import 'package:monimate/features/net_worth/controllers/wealth_timeline_controller.dart';
import 'package:monimate/features/gamification/controllers/gamification_controller.dart';
import 'package:monimate/features/ai_insights/services/ai_insight_api_service.dart';
import 'package:monimate/features/financial_inbox/services/financial_notification_service.dart';
import 'package:monimate/features/financial_inbox/controllers/financial_inbox_controller.dart';
import 'package:monimate/features/daily_brief/services/daily_coach_service.dart';
import 'package:monimate/data/controller/quick_actions_controller.dart';
import 'package:monimate/data/controller/user_controller.dart';

import 'shell.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initEverything();
  }

  Future<void> _initEverything() async {
    try {
      await initializeDateFormatting('id_ID', null);

      await NotificationService.init();
      await HiveService.init();

      Get.put(TransactionController(), permanent: true);
      Get.put(RecurringController(), permanent: true);
      Get.put(ThemeController(), permanent: true);
      Get.put(BudgetController(), permanent: true);
      Get.put(SyncController(), permanent: true);
      Get.put(WalletController(), permanent: true);
      Get.put(EmergencyFundController(), permanent: true);
      Get.put(FinancialHealthController(), permanent: true);
      Get.put(NetWorthController(), permanent: true);
      Get.put(WealthTimelineService(), permanent: true);
      Get.put(WealthTimelineController(), permanent: true);
      Get.put(GamificationController(), permanent: true);
      Get.put(AiInsightApiService(), permanent: true);
      Get.put(FinancialNotificationService(), permanent: true);
      Get.put(FinancialInboxController(), permanent: true);
      Get.put(QuickActionsController(), permanent: true);
      Get.put(UserController(), permanent: true);
      final coachService = Get.put(DailyCoachService(), permanent: true);
      await coachService.init();

      // Seed dummy transaction data
      // await SeederService.seedTransactions();

      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint('Init error: $e');
    }

    Timer(const Duration(milliseconds: 900), () {
      Get.offAll(() => const Shell());
    });
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF48C6EF);
    return Scaffold(
      backgroundColor: primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/monimate_logo.png',
                width: 140,
                height: 140,
              ),
              const SizedBox(height: 18),
              const Text(
                'MoniMate',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const SizedBox(
                width: 60,
                height: 6,
                child: LinearProgressIndicator(
                  color: Colors.white,
                  backgroundColor: Colors.white24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
