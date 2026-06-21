import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/financial_health_model.dart';
import '../services/financial_health_service.dart';

class FinancialHealthController extends GetxController {
  final Rx<FinancialHealthScore?> score = Rx<FinancialHealthScore?>(null);
  final RxBool isLoading = false.obs;
  final RxString selectedCategory = ''.obs;

  void calculateScore() {
    isLoading.value = true;
    try {
      score.value = FinancialHealthService.calculate();
    } catch (e) {
      score.value = null;
    }
    isLoading.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    calculateScore();
  }

  // Helper getters
  double get totalScore => score.value?.totalScore ?? 0;
  String get category => score.value?.category ?? 'Unknown';
  List<String> get insights => score.value?.insights ?? [];
  double get budgetScore => score.value?.budgetScore ?? 0;
  double get goalScore => score.value?.goalScore ?? 0;
  double get savingScore => score.value?.savingScore ?? 0;
  double get trendScore => score.value?.trendScore ?? 0;
  double get emergencyScore => score.value?.emergencyScore ?? 0;

  static Color getScoreColor(double score) {
    if (score >= 90) return const Color(0xFF10B981); // Emerald
    if (score >= 75) return const Color(0xFF22C55E); // Green
    if (score >= 60) return const Color(0xFFF59E0B); // Amber
    if (score >= 40) return const Color(0xFFF97316); // Orange
    return const Color(0xFFEF4444); // Red
  }

  static String getScoreEmoji(double score) {
    if (score >= 90) return '🏆';
    if (score >= 75) return '💪';
    if (score >= 60) return '👍';
    if (score >= 40) return '⚠️';
    return '🚨';
  }

  static String getScoreLabel(double score) {
    if (score >= 90) return 'Luar Biasa';
    if (score >= 75) return 'Sehat';
    if (score >= 60) return 'Cukup';
    if (score >= 40) return 'Perlu Perbaikan';
    return 'Kritis';
  }
}
