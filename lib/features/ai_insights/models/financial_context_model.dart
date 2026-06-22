class FinancialContextModel {
  final String month;
  final int year;
  final double totalIncome;
  final double totalExpense;
  final double savingAmount;
  final double savingRate;
  final double financialHealthScore;
  final double netWorth;
  final double netWorthGrowthPercent;
  final List<Map<String, dynamic>> topExpenseCategories;
  final List<Map<String, dynamic>> budgetRiskCategories;
  final List<Map<String, dynamic>> activeGoalsSummary;
  final Map<String, double> recurringNextMonthSummary;
  final Map<String, String> walletSummary;
  final List<String> behaviorFlags;

  FinancialContextModel({
    required this.month,
    required this.year,
    required this.totalIncome,
    required this.totalExpense,
    required this.savingAmount,
    required this.savingRate,
    required this.financialHealthScore,
    required this.netWorth,
    required this.netWorthGrowthPercent,
    required this.topExpenseCategories,
    required this.budgetRiskCategories,
    required this.activeGoalsSummary,
    required this.recurringNextMonthSummary,
    required this.walletSummary,
    required this.behaviorFlags,
  });

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'year': year,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'savingRate': savingRate,
      'financialHealthScore': financialHealthScore,
      'netWorth': netWorth,
      'netWorthGrowthPercent': netWorthGrowthPercent,
      'topExpenseCategories': topExpenseCategories,
      'budgetRiskCategories': budgetRiskCategories,
      'activeGoalsSummary': activeGoalsSummary,
      'recurringNextMonthSummary': recurringNextMonthSummary,
      'walletSummary': walletSummary,
    };
  }
}
