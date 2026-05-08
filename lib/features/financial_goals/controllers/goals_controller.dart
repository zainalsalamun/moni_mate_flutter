import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/goal_model.dart';
import '../../../data/models/contribution_model.dart';
import '../../../data/services/hive_service.dart';
import 'package:monimate/data/controller/sync_controller.dart';

class AchievementItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isUnlocked;

  AchievementItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isUnlocked = false,
  });
}

class GoalsController extends GetxController {
  var goals = <GoalModel>[].obs;
  var filteredGoals = <GoalModel>[].obs;

  var currentFilter = 'Semua Goals'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchGoals();
  }

  void fetchGoals() {
    goals.assignAll(HiveService.getAllGoals());
    applyFilter(currentFilter.value);
  }

  void applyFilter(String filter) {
    currentFilter.value = filter;
    if (filter == 'Semua Goals') {
      filteredGoals.assignAll(goals);
    } else if (filter == 'Aktif') {
      filteredGoals.assignAll(goals.where((g) => g.status == 'active'));
    } else if (filter == 'Selesai') {
      filteredGoals.assignAll(goals.where((g) => g.status == 'completed'));
    }
  }

  // Calculate Summaries for Header
  int get totalGoals => goals.length;
  double get totalCollected =>
      goals.fold(0.0, (sum, item) => sum + item.currentAmount);
  int get goalsAchieved => goals.where((g) => g.status == 'completed').length;
  int get totalAchievements =>
      achievementsList.where((a) => a.isUnlocked).length;

  List<AchievementItem> get achievementsList {
    return [
      AchievementItem(
        title: 'Getting Started',
        subtitle: 'Buat target pertama',
        icon: Icons.stars,
        color: Colors.teal,
        isUnlocked: goals.isNotEmpty,
      ),
      AchievementItem(
        title: 'First Save',
        subtitle: 'Lakukan tabungan pertama',
        icon: Icons.savings,
        color: Colors.purple,
        isUnlocked: goals.any((g) => g.currentAmount > 0),
      ),
      AchievementItem(
        title: 'Halfway There',
        subtitle: 'Capai 50% dari salah satu target',
        icon: Icons.lock_open,
        color: Colors.orange,
        isUnlocked: goals.any((g) => g.progressPercentage >= 0.5),
      ),
      AchievementItem(
        title: 'Goal Achieved',
        subtitle: 'Selesaikan 1 target',
        icon: Icons.emoji_events,
        color: Colors.amber,
        isUnlocked: goalsAchieved > 0,
      ),
      AchievementItem(
        title: 'Financial Guru',
        subtitle: 'Selesaikan 5 target',
        icon: Icons.diamond,
        color: Colors.blueAccent,
        isUnlocked: goalsAchieved >= 5,
      ),
    ];
  }

  // Method to add new Goal
  Future<void> addGoal(GoalModel goal) async {
    await HiveService.addGoal(goal);
    fetchGoals();
    if (Get.isRegistered<SyncController>()) Get.find<SyncController>().notifyDataChanged();
  }

  // Method to delete Goal
  Future<void> deleteGoal(String goalId) async {
    await HiveService.deleteGoal(goalId);
    await HiveService.deleteContributionsByGoalId(goalId);
    fetchGoals();
    if (Get.isRegistered<SyncController>()) Get.find<SyncController>().notifyDataChanged();
  }

  // Method to add Contribution
  Future<void> addContribution(
      String goalId, double amount, String note) async {
    final goalIndex = goals.indexWhere((g) => g.id == goalId);
    if (goalIndex != -1) {
      final goal = goals[goalIndex];
      goal.currentAmount += amount;

      if (goal.currentAmount >= goal.targetAmount) {
        goal.status = 'completed';
      }

      goal.updatedAt = DateTime.now();
      goal.isSynced = false;
      await goal.save(); // Save changes to Hive

      final contribution = ContributionModel(
        goalId: goalId,
        amount: amount,
        date: DateTime.now(),
        note: note,
      );
      await HiveService.addContribution(contribution);

      fetchGoals();
      if (Get.isRegistered<SyncController>()) Get.find<SyncController>().notifyDataChanged();
    }
  }

  // UI Helpers
  double calculateRequiredMonthly(GoalModel goal) {
    if (goal.status == 'completed') return 0;

    final now = DateTime.now();
    final target = goal.targetDate;

    // Calculate difference in months
    int monthsDiff = (target.year - now.year) * 12 + target.month - now.month;
    if (monthsDiff <= 0) monthsDiff = 1; // At least 1 month

    final remainingAmount = goal.targetAmount - goal.currentAmount;
    if (remainingAmount <= 0) return 0;

    return remainingAmount / monthsDiff;
  }
}
