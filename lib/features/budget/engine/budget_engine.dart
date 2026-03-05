import 'package:monimate/data/models/transaction_model.dart';
import '../model/budget_model.dart';

class BudgetUsage {
  final BudgetModel budget;
  final double currentUsage;
  final List<TransactionModel> transactions;

  BudgetUsage({
    required this.budget,
    required this.currentUsage,
    required this.transactions,
  });

  double get percentage =>
      budget.monthlyLimit == 0 ? 0 : (currentUsage / budget.monthlyLimit) * 100;

  bool get isOverBudget => currentUsage > budget.monthlyLimit;
}

class BudgetInsight {
  final String title;
  final String description;
  final String type; // 'warning', 'info', 'success'

  BudgetInsight(
      {required this.title, required this.description, required this.type});
}

class BudgetEngine {
  static List<BudgetUsage> calculateUsage(
    List<BudgetModel> budgets,
    List<TransactionModel> allTransactions,
  ) {
    final now = DateTime.now();
    final currentMonthTransactions = allTransactions.where((t) {
      return t.type == 'expense' &&
          t.date.year == now.year &&
          t.date.month == now.month;
    }).toList();

    return budgets.map((budget) {
      final categoryTransactions = currentMonthTransactions.where((t) {
        return t.category.toLowerCase() == budget.categoryId.toLowerCase();
      }).toList();

      final totalUsage =
          categoryTransactions.fold(0.0, (sum, t) => sum + t.amount);

      return BudgetUsage(
        budget: budget,
        currentUsage: totalUsage,
        transactions: categoryTransactions,
      );
    }).toList();
  }

  static List<BudgetInsight> generateInsights(
    List<TransactionModel> allTransactions,
    List<BudgetUsage> usages,
  ) {
    final insights = <BudgetInsight>[];
    final now = DateTime.now();

    // 1. Compare month over month
    for (var usage in usages) {
      final lastMonthDate = DateTime(now.year, now.month - 1);
      final lMonth = lastMonthDate.month;
      final lYear = lastMonthDate.year;

      final lastMonthTransactions = allTransactions.where((t) {
        return t.type == 'expense' &&
            t.category.toLowerCase() == usage.budget.categoryId.toLowerCase() &&
            t.date.year == lYear &&
            t.date.month == lMonth;
      }).toList();

      final lastMonthTotal =
          lastMonthTransactions.fold(0.0, (sum, t) => sum + t.amount);

      if (lastMonthTotal > 0) {
        final increase =
            ((usage.currentUsage - lastMonthTotal) / lastMonthTotal) * 100;
        if (increase > 10) {
          insights.add(BudgetInsight(
            title: 'Kenaikan Pengeluaran',
            description:
                'Pengeluaran ${usage.budget.categoryId} naik ${increase.toStringAsFixed(0)}% dari bulan lalu.',
            type: 'warning',
          ));
        } else if (increase < -10) {
          insights.add(BudgetInsight(
            title: 'Penghematan!',
            description:
                'Kamu berhasil menghemat ${(increase.abs()).toStringAsFixed(0)}% di kategori ${usage.budget.categoryId} dibanding bulan lalu.',
            type: 'success',
          ));
        }
      }
    }

    // 2. Weekend spending
    final weekendTransactions = allTransactions.where((t) {
      return t.type == 'expense' &&
          (t.date.weekday == DateTime.saturday ||
              t.date.weekday == DateTime.sunday) &&
          t.date.year == now.year &&
          t.date.month == now.month;
    }).toList();

    final weekendTotal =
        weekendTransactions.fold(0.0, (sum, t) => sum + t.amount);
    final monthTotal = allTransactions
        .where((t) =>
            t.type == 'expense' &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);

    if (monthTotal > 0 && (weekendTotal / monthTotal) > 0.4) {
      insights.add(BudgetInsight(
        title: 'Boros Akhir Pekan',
        description:
            'Kamu sering belanja di akhir pekan (${((weekendTotal / monthTotal) * 100).toStringAsFixed(0)}% dari total).',
        type: 'info',
      ));
    }

    // 3. Category breakdown keywords
    final coffeeTransactions = allTransactions.where((t) {
      final desc = t.description.toLowerCase();
      return t.type == 'expense' &&
          (desc.contains('kopi') || desc.contains('coffee'));
    }).toList();

    final coffeeTotal =
        coffeeTransactions.fold(0.0, (sum, t) => sum + t.amount);
    if (coffeeTotal > 20000) {
      // Show only if it's significant
      insights.add(BudgetInsight(
        title: 'Insight Kopi',
        description:
            'Kategori kopi menyumbang Rp ${coffeeTotal.toStringAsFixed(0)} dari pengeluaranmu bulan ini.',
        type: 'info',
      ));
    }

    return insights;
  }
}
