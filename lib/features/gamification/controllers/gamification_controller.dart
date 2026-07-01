import 'package:get/get.dart';
import 'package:monimate/data/services/hive_service.dart';
import 'package:monimate/data/services/notification_service.dart';
import 'package:monimate/features/gamification/models/achievement_model.dart';
import 'package:monimate/features/gamification/models/user_progress_model.dart';
import 'package:monimate/features/gamification/utils/xp_calculator.dart';

class GamificationController extends GetxController {
  final Rx<UserProgressModel> progress =
      UserProgressModel(id: '', updatedAt: DateTime.now()).obs;
  final RxList<AchievementModel> achievements = <AchievementModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  void _loadData() {
    progress.value = HiveService.getUserProgress();

    final savedAchievements = HiveService.getAllAchievements();
    if (savedAchievements.isEmpty) {
      _seedDefaultAchievements();
    } else {
      achievements.value = savedAchievements;
    }
  }

  void _seedDefaultAchievements() {
    final defaultAchievements = [
      // Streak
      AchievementModel(
          id: 'streak_7',
          title: '7 Days',
          description: 'Streak pencatatan selama 7 hari',
          icon: 'local_fire_department',
          colorHex: '#FF5722',
          category: 'streak'),
      AchievementModel(
          id: 'streak_30',
          title: '30 Days',
          description: 'Streak pencatatan selama 30 hari',
          icon: 'local_fire_department',
          colorHex: '#FF9800',
          category: 'streak'),
      AchievementModel(
          id: 'streak_60',
          title: '60 Days',
          description: 'Streak pencatatan selama 60 hari',
          icon: 'whatshot',
          colorHex: '#E91E63',
          category: 'streak'),
      AchievementModel(
          id: 'streak_100',
          title: '100 Days',
          description: 'Konsistensi emas 100 hari!',
          icon: 'hotel_class',
          colorHex: '#FFC107',
          category: 'streak'),
      AchievementModel(
          id: 'streak_365',
          title: '365 Days',
          description: '1 Tahun tanpa bolong!',
          icon: 'military_tech',
          colorHex: '#9C27B0',
          category: 'streak'),

      // Goals
      AchievementModel(
          id: 'goal_first',
          title: 'First Goal',
          description: 'Membuat tujuan keuangan pertama',
          icon: 'flag',
          colorHex: '#4CAF50',
          category: 'goals'),
      AchievementModel(
          id: 'goal_finisher',
          title: 'Goal Finisher',
          description: 'Menyelesaikan 1 tujuan keuangan',
          icon: 'emoji_events',
          colorHex: '#8BC34A',
          category: 'goals'),
      AchievementModel(
          id: 'goal_master',
          title: 'Goal Master',
          description: 'Menyelesaikan 5 tujuan keuangan',
          icon: 'diamond',
          colorHex: '#00BCD4',
          category: 'goals'),

      // Budget
      AchievementModel(
          id: 'budget_keeper',
          title: 'Budget Keeper',
          description: 'Tidak overbudget selama 1 bulan',
          icon: 'account_balance_wallet',
          colorHex: '#03A9F4',
          category: 'budget'),
      AchievementModel(
          id: 'budget_champion',
          title: 'Budget Champion',
          description: 'Semua budget aman selama 3 bulan',
          icon: 'verified',
          colorHex: '#3F51B5',
          category: 'budget'),

      // Emergency Fund
      AchievementModel(
          id: 'ef_ready',
          title: 'Emergency Ready',
          description: 'Mencapai 25% Dana Darurat',
          icon: 'health_and_safety',
          colorHex: '#F44336',
          category: 'emergency_fund'),
      AchievementModel(
          id: 'ef_master',
          title: 'Emergency Master',
          description: 'Mencapai 100% Dana Darurat',
          icon: 'security',
          colorHex: '#E91E63',
          category: 'emergency_fund'),

      // Net Worth
      AchievementModel(
          id: 'nw_10',
          title: '10M Club',
          description: 'Net Worth mencapai 10 Juta',
          icon: 'trending_up',
          colorHex: '#009688',
          category: 'net_worth'),
      AchievementModel(
          id: 'nw_25',
          title: '25M Club',
          description: 'Net Worth mencapai 25 Juta',
          icon: 'show_chart',
          colorHex: '#4CAF50',
          category: 'net_worth'),
      AchievementModel(
          id: 'nw_50',
          title: '50M Club',
          description: 'Net Worth mencapai 50 Juta',
          icon: 'star',
          colorHex: '#FFEB3B',
          category: 'net_worth'),
      AchievementModel(
          id: 'nw_100',
          title: '100M Club',
          description: 'Net Worth mencapai 100 Juta',
          icon: 'stars',
          colorHex: '#FFC107',
          category: 'net_worth'),
      AchievementModel(
          id: 'nw_1000',
          title: 'Millionaire Journey',
          description: 'Net Worth mencapai 1 Miliar',
          icon: 'monetization_on',
          colorHex: '#FF9800',
          category: 'net_worth'),

      // Reports
      AchievementModel(
          id: 'report_first',
          title: 'First Report',
          description: 'Mencetak laporan bulanan pertama',
          icon: 'picture_as_pdf',
          colorHex: '#607D8B',
          category: 'reports'),
      AchievementModel(
          id: 'report_collector',
          title: 'Report Collector',
          description: 'Mencetak 12 laporan bulanan',
          icon: 'library_books',
          colorHex: '#795548',
          category: 'reports'),
    ];

    for (var ach in defaultAchievements) {
      HiveService.saveAchievement(ach);
    }
    achievements.value = defaultAchievements;
  }

  void addXp(int amount, String reason) {
    if (amount <= 0) return;

    final user = progress.value;
    user.currentXp += amount;
    user.totalXpEarned += amount;
    user.updatedAt = DateTime.now();

    final newLevel = XpCalculator.calculateLevel(user.totalXpEarned);
    final newRank = XpCalculator.getRank(newLevel);

    bool leveledUp = false;
    if (newLevel > user.currentLevel) {
      user.currentLevel = newLevel;
      leveledUp = true;
    }

    if (newRank != user.currentRank) {
      user.currentRank = newRank;
    }

    HiveService.saveUserProgress(user);
    progress.refresh();

    if (leveledUp) {
      NotificationService.showNotification(
        id: 999,
        title: '🎉 Level Up!',
        body: 'Kamu naik ke Level $newLevel. Rank: $newRank unlocked!',
      );
    }
  }

  void recordActivity() {
    final user = progress.value;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (user.lastTransactionDate != null) {
      final lastDate = DateTime(user.lastTransactionDate!.year,
          user.lastTransactionDate!.month, user.lastTransactionDate!.day);
      final difference = today.difference(lastDate).inDays;

      if (difference == 1) {
        user.currentStreak += 1;
      } else if (difference > 1) {
        user.currentStreak = 1; // reset
      }
    } else {
      user.currentStreak = 1;
    }

    if (user.currentStreak > user.longestStreak) {
      user.longestStreak = user.currentStreak;
    }
    user.lastTransactionDate = now;
    user.updatedAt = now;

    HiveService.saveUserProgress(user);
    progress.refresh();

    _checkStreakAchievements(user.currentStreak);
  }

  void unlockAchievement(String id) {
    final achIndex = achievements.indexWhere((a) => a.id == id);
    if (achIndex != -1) {
      final ach = achievements[achIndex];
      if (ach.status != 'unlocked' && ach.status != 'completed') {
        ach.status = 'unlocked';
        ach.unlockedAt = DateTime.now();
        HiveService.saveAchievement(ach);
        achievements.refresh();

        NotificationService.showNotification(
          id: 1000 + achIndex,
          title: '🏆 Achievement Unlocked',
          body: ach.title,
        );
      }
    }
  }

  void _checkStreakAchievements(int streak) {
    if (streak >= 7) unlockAchievement('streak_7');
    if (streak >= 30) unlockAchievement('streak_30');
    if (streak >= 60) unlockAchievement('streak_60');
    if (streak >= 100) unlockAchievement('streak_100');
    if (streak >= 365) unlockAchievement('streak_365');
  }
}
