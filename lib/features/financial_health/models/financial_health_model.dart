class FinancialHealthScore {
  final double totalScore;
  final double budgetScore;
  final double goalScore;
  final double savingScore;
  final double trendScore;
  final double emergencyScore;
  final String category;
  final List<String> insights;
  final DateTime calculatedAt;

  FinancialHealthScore({
    required this.totalScore,
    required this.budgetScore,
    required this.goalScore,
    required this.savingScore,
    required this.trendScore,
    required this.emergencyScore,
    required this.category,
    required this.insights,
    required this.calculatedAt,
  });

  static String getCategory(double score) {
    if (score >= 90) return 'Excellent';
    if (score >= 75) return 'Good';
    if (score >= 60) return 'Fair';
    if (score >= 40) return 'Needs Improvement';
    return 'Critical';
  }
}
