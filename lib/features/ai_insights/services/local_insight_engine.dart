import 'package:uuid/uuid.dart';
import 'package:get/get.dart';
import '../../emergency_fund/controllers/emergency_fund_controller.dart';
import '../../../utils/format_currency.dart';
import '../models/financial_context_model.dart';
import '../models/predictive_insight_model.dart';

class LocalInsightEngine {
  static List<PredictiveInsightModel> generateInsights(FinancialContextModel context) {
    final List<PredictiveInsightModel> insights = [];

    // 1. Budget Prediction
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month == 12 ? 1 : now.month + 1, 0).day;
    final currentDay = now.day;

    for (var budget in context.budgetRiskCategories) {
      final String category = budget['category'];
      final double usagePercent = budget['usagePercent'];
      final double limit = budget['limit'];
      final double spent = budget['spent'];

      if (currentDay > 0) {
        final double dailyBurnRate = spent / currentDay;
        final double projectedMonthlyExpense = dailyBurnRate * daysInMonth;
        final double projectedUsagePercent = (projectedMonthlyExpense / limit) * 100;

        if (projectedUsagePercent > 100) {
          final remainingBudget = limit - spent;
          final estimatedDaysLeft = dailyBurnRate > 0 ? (remainingBudget / dailyBurnRate).floor() : 999;

          if (estimatedDaysLeft <= 7 && estimatedDaysLeft >= 0) {
            insights.add(PredictiveInsightModel(
              id: const Uuid().v4(),
              title: 'Budget ${category.capitalizeFirst ?? category} Terancam Habis',
              message: 'Berdasarkan pengeluaran harianmu, budget $category kemungkinan akan habis dalam $estimatedDaysLeft hari.',
              type: 'budget_prediction',
              severity: 'danger',
              source: 'local',
              actionLabel: 'Lihat Budget',
              actionRoute: '/budget',
              createdAt: DateTime.now(),
            ));
          } else if (usagePercent > 80) {
            insights.add(PredictiveInsightModel(
              id: const Uuid().v4(),
              title: 'Penggunaan Budget ${category.capitalizeFirst ?? category} Tinggi',
              message: 'Kamu sudah menggunakan ${usagePercent.toStringAsFixed(0)}% dari budget $category bulan ini.',
              type: 'budget_prediction',
              severity: 'warning',
              source: 'local',
              actionLabel: 'Lihat Budget',
              actionRoute: '/budget',
              createdAt: DateTime.now(),
            ));
          }
        }
      }
    }

    // 2. Goal Prediction
    final List<String> behindGoals = [];
    final List<String> nearGoals = [];

    for (var goal in context.activeGoalsSummary) {
      final String title = goal['title'];
      final double progressPercent = goal['progressPercent'];
      final String prediction = goal['prediction'];

      if (prediction == 'behind') {
        behindGoals.add(title);
      } else if (progressPercent >= 90) {
        nearGoals.add(title);
      }
    }

    if (behindGoals.isNotEmpty) {
      final titleText = behindGoals.length == 1 
          ? 'Goal "${behindGoals.first}" Sedikit Tertinggal'
          : '${behindGoals.length} Goal Sedikit Tertinggal';
      final messageText = behindGoals.length == 1
          ? 'Pencapaian goal "${behindGoals.first}" masih di bawah target waktu. Yuk sisihkan lebih banyak!'
          : 'Pencapaian goal ${behindGoals.join(", ")} masih di bawah target waktu. Yuk sisihkan lebih banyak!';
          
      insights.add(PredictiveInsightModel(
        id: const Uuid().v4(),
        title: titleText,
        message: messageText,
        type: 'goal_prediction_behind',
        severity: 'warning',
        source: 'local',
        actionLabel: 'Lihat Goals',
        actionRoute: '/goals',
        createdAt: DateTime.now(),
      ));
    }

    if (nearGoals.isNotEmpty) {
      final titleText = nearGoals.length == 1
          ? 'Hampir Tercapai: ${nearGoals.first}'
          : '${nearGoals.length} Goal Hampir Tercapai!';
      final messageText = nearGoals.length == 1
          ? 'Luar biasa! Goal "${nearGoals.first}" sudah mencapai progres lebih dari 90%. Sedikit lagi!'
          : 'Luar biasa! Goal ${nearGoals.join(", ")} sudah mencapai progres lebih dari 90%. Sedikit lagi!';

      insights.add(PredictiveInsightModel(
        id: const Uuid().v4(),
        title: titleText,
        message: messageText,
        type: 'goal_prediction_near',
        severity: 'success',
        source: 'local',
        actionLabel: 'Lihat Goals',
        actionRoute: '/goals',
        createdAt: DateTime.now(),
      ));
    }

    // 3. Recurring Impact
    final double recurringExpense = context.recurringNextMonthSummary['expense'] ?? 0;
    if (context.totalIncome > 0) {
      if (recurringExpense > (context.totalIncome * 0.4)) {
        insights.add(PredictiveInsightModel(
          id: const Uuid().v4(),
          title: 'Beban Rutin Bulan Depan Tinggi',
          message: 'Pengeluaran rutinmu diprediksi melebihi 40% dari rata-rata pemasukan bulan ini.',
          type: 'recurring_impact',
          severity: 'warning',
          source: 'local',
          actionLabel: 'Lihat Tagihan',
          actionRoute: '/recurring',
          createdAt: DateTime.now(),
        ));
      }
    }

    // 4. Net Worth Insight
    if (context.netWorthGrowthPercent >= 0.05) { // 5% growth
      insights.add(PredictiveInsightModel(
        id: const Uuid().v4(),
        title: 'Kekayaan Bertumbuh Cepat!',
        message: 'Net worth kamu naik ${(context.netWorthGrowthPercent * 100).toStringAsFixed(1)}% bulan ini. Pertahankan momentumnya!',
        type: 'net_worth',
        severity: 'success',
        source: 'local',
        createdAt: DateTime.now(),
      ));
    } else if (context.netWorthGrowthPercent < -0.05) {
      insights.add(PredictiveInsightModel(
        id: const Uuid().v4(),
        title: 'Penurunan Net Worth',
        message: 'Kekayaan bersihmu turun ${(context.netWorthGrowthPercent.abs() * 100).toStringAsFixed(1)}%. Cek kembali arus kas bulan ini.',
        type: 'net_worth',
        severity: 'warning',
        source: 'local',
        createdAt: DateTime.now(),
      ));
    }

    // 5. Wallet Health
    final String largestWallet = context.walletSummary['largestWalletName'] ?? '';
    final String activeWallet = context.walletSummary['mostActiveWalletName'] ?? '';
    
    if (activeWallet.isNotEmpty && largestWallet.isNotEmpty && activeWallet != largestWallet) {
       insights.add(PredictiveInsightModel(
        id: const Uuid().v4(),
        title: 'Aktivitas Dompet: $activeWallet',
        message: '$activeWallet menjadi dompet paling aktif bulan ini. Pastikan saldo tercukupi agar transaksi lancar.',
        type: 'wallet_health',
        severity: 'info',
        source: 'local',
        actionLabel: 'Cek Dompet',
        actionRoute: '/wallet',
        createdAt: DateTime.now(),
      ));
    }

    // 6. Emergency Fund Prediction & Wealth Integration
    if (Get.isRegistered<EmergencyFundController>()) {
      final emergencyMetrics = Get.find<EmergencyFundController>().metrics.value;
      
      // Integration: Check if Net Worth can cover Emergency Fund
      if (context.netWorth > 0 && emergencyMetrics.targetFund > 0) {
        final double requiredPercent = (emergencyMetrics.targetFund / context.netWorth) * 100;
        if (requiredPercent < 100 && emergencyMetrics.progressPercent < 1.0) {
          insights.add(PredictiveInsightModel(
            id: const Uuid().v4(),
            title: 'Potensi Dana Darurat',
            message: 'Hanya ${requiredPercent.toStringAsFixed(0)}% dari Net Worth kamu saat ini sudah cukup untuk menutup sisa kebutuhan dana darurat.',
            type: 'wealth_emergency_fund',
            severity: 'info',
            source: 'local',
            actionLabel: 'Isi Dana Darurat',
            actionRoute: '/emergency_fund',
            createdAt: DateTime.now(),
          ));
        }
      }

      if (emergencyMetrics.progressPercent < 0.25) {
        insights.add(PredictiveInsightModel(
          id: const Uuid().v4(),
          title: 'Dana Darurat Kritis',
          message: 'Dana darurat kamu hanya mencukupi untuk ${emergencyMetrics.monthsCovered.toStringAsFixed(1)} bulan. Segera buat target untuk mencapai ideal ${emergencyMetrics.multiplier} bulan.',
          type: 'emergency_fund',
          severity: 'danger',
          source: 'local',
          actionLabel: 'Lihat Dana Darurat',
          actionRoute: '/emergency_fund',
          createdAt: DateTime.now(),
        ));
      } else if (emergencyMetrics.progressPercent < 0.75) {
        insights.add(PredictiveInsightModel(
          id: const Uuid().v4(),
          title: 'Perkembangan Dana Darurat',
          message: 'Kamu masih membutuhkan Rp ${CurrencyFormat.format(emergencyMetrics.targetFund - emergencyMetrics.currentFund).replaceAll('Rp ', '').trim()} untuk mencapai target ideal ${emergencyMetrics.multiplier} bulan.',
          type: 'emergency_fund',
          severity: 'warning',
          source: 'local',
          actionLabel: 'Lihat Dana Darurat',
          actionRoute: '/emergency_fund',
          createdAt: DateTime.now(),
        ));
      } else if (emergencyMetrics.progressPercent < 1.0) {
        insights.add(PredictiveInsightModel(
          id: const Uuid().v4(),
          title: 'Dana Darurat Hampir Tercapai',
          message: 'Dana darurat kamu saat ini cukup untuk ${emergencyMetrics.monthsCovered.toStringAsFixed(1)} bulan pengeluaran. Sedikit lagi menuju target ideal!',
          type: 'emergency_fund',
          severity: 'info',
          source: 'local',
          actionLabel: 'Lihat Dana Darurat',
          actionRoute: '/emergency_fund',
          createdAt: DateTime.now(),
        ));
      } else {
        insights.add(PredictiveInsightModel(
          id: const Uuid().v4(),
          title: 'Dana Darurat Optimal',
          message: 'Luar biasa! Dana darurat kamu sudah cukup untuk menghadapi kondisi darurat selama ${emergencyMetrics.multiplier} bulan.',
          type: 'emergency_fund',
          severity: 'success',
          source: 'local',
          actionLabel: 'Lihat Dana Darurat',
          actionRoute: '/emergency_fund',
          createdAt: DateTime.now(),
        ));
      }
    }

    // Default encouragement if everything is fine and no warnings exist
    if (insights.isEmpty) {
      insights.add(PredictiveInsightModel(
        id: const Uuid().v4(),
        title: 'Semua Terkendali',
        message: 'Arus kas, budget, dan tagihan bulan ini dalam kondisi aman.',
        type: 'spending_behavior',
        severity: 'success',
        source: 'local',
        createdAt: DateTime.now(),
      ));
    }

    return insights;
  }
}
