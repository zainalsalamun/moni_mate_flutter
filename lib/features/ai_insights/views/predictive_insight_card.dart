import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/predictive_insight_model.dart';
import '../../financial_goals/views/financial_goals_page.dart';
import '../../budget/view/budget_manage_page.dart';
import '../../emergency_fund/views/emergency_fund_page.dart';
import '../../wallet/views/wallet_manage_page.dart';
import '../../../pages/recurring_manager_page.dart';

class PredictiveInsightCard extends StatelessWidget {
  final PredictiveInsightModel insight;

  const PredictiveInsightCard({super.key, required this.insight});

  Color _getSeverityColor(BuildContext context) {
    switch (insight.severity) {
      case 'danger':
        return Colors.redAccent;
      case 'warning':
        return Colors.orangeAccent;
      case 'success':
        return const Color(0xFF48C6EF); // Ocean Toska
      case 'info':
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  IconData _getIcon() {
    switch (insight.type) {
      case 'budget_prediction':
        return Icons.pie_chart_outline;
      case 'goal_prediction':
        return Icons.flag_outlined;
      case 'recurring_impact':
        return Icons.autorenew;
      case 'net_worth':
        return Icons.trending_up;
      case 'wallet_health':
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.lightbulb_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getSeverityColor(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.3), width: 1.5),
      ),
      color: color.withOpacity(0.05),
      child: InkWell(
        onTap: insight.actionRoute.isNotEmpty
            ? () {
                if (insight.actionRoute == '/budget') {
                  Get.to(() => const BudgetManagePage());
                } else if (insight.actionRoute == '/emergency_fund') {
                  Get.to(() => const EmergencyFundPage());
                } else if (insight.actionRoute == '/wallet') {
                  Get.to(() => const WalletManagePage());
                } else if (insight.actionRoute == '/recurring') {
                  Get.to(() => const RecurringManagerPage());
                } else if (insight.actionRoute == '/goals') {
                  Get.to(() => const FinancialGoalsPage());
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Membuka ${insight.actionLabel}...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_getIcon(), color: color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      insight.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ),
                  if (insight.source == 'local')
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Local AI',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                insight.message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.8),
                    ),
              ),
              if (insight.actionLabel.isNotEmpty) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    insight.actionLabel,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
