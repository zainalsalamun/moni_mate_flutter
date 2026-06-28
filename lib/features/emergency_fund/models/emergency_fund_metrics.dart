class EmergencyFundMetrics {
  final double currentFund;
  final double targetFund;
  final double progressPercent; // 0.0 to 1.0 or more
  final double readinessScore; // 0 to 100
  final String readinessStatus; // Critical, Low, Developing, Almost Ready, Fully Ready
  final double monthsCovered;
  final double averageMonthlyExpense;
  final int multiplier;

  EmergencyFundMetrics({
    required this.currentFund,
    required this.targetFund,
    required this.progressPercent,
    required this.readinessScore,
    required this.readinessStatus,
    required this.monthsCovered,
    required this.averageMonthlyExpense,
    required this.multiplier,
  });

  factory EmergencyFundMetrics.empty() {
    return EmergencyFundMetrics(
      currentFund: 0,
      targetFund: 0,
      progressPercent: 0,
      readinessScore: 0,
      readinessStatus: 'Critical',
      monthsCovered: 0,
      averageMonthlyExpense: 0,
      multiplier: 3,
    );
  }

  // Get color based on status
  int get statusColorHex {
    if (progressPercent >= 1.0) return 0xFF10B981; // Fully Ready (Green)
    if (progressPercent >= 0.75) return 0xFF22C55E; // Almost Ready
    if (progressPercent >= 0.50) return 0xFFF59E0B; // Developing (Yellow)
    if (progressPercent >= 0.25) return 0xFFF97316; // Low (Orange)
    return 0xFFEF4444; // Critical (Red)
  }
}
