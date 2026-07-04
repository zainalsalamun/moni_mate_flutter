import 'package:flutter/material.dart';
import 'package:monimate/features/ai_insights/views/predictive_insight_dashboard_section.dart';
import 'package:monimate/features/budget/view/budget_section.dart';
import 'package:monimate/features/net_worth/views/net_worth_card.dart';
import 'package:monimate/features/net_worth/views/wealth_timeline_dashboard_card.dart';
import 'package:monimate/features/financial_health/views/financial_health_dashboard_card.dart';
import 'package:monimate/features/emergency_fund/views/emergency_fund_dashboard_card.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PredictiveInsightDashboardSection(),
            const SizedBox(height: 20),
            const FinancialHealthDashboardCard(),
            const SizedBox(height: 20),
            const EmergencyFundDashboardCard(),
            const SizedBox(height: 20),
            const NetWorthCard(),
            const SizedBox(height: 20),
            const WealthTimelineDashboardCard(),
            const SizedBox(height: 20),
            const BudgetSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
