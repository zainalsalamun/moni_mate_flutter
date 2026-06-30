import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monimate/utils/format_currency.dart';
import '../controllers/financial_health_controller.dart';
import '../../emergency_fund/controllers/emergency_fund_controller.dart';
import '../../net_worth/controllers/net_worth_controller.dart';
import 'financial_health_page.dart';

class FinancialSnapshotCard extends StatelessWidget {
  const FinancialSnapshotCard({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<FinancialHealthController>() ||
        !Get.isRegistered<EmergencyFundController>() ||
        !Get.isRegistered<NetWorthController>()) {
      return const SizedBox.shrink();
    }

    final fhc = Get.find<FinancialHealthController>();
    final efc = Get.find<EmergencyFundController>();
    final nwc = Get.find<NetWorthController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Get.to(() => const FinancialHealthPage()),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Financial Snapshot',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Obx(() {
                final score = fhc.totalScore;
                final efProgress = efc.metrics.value.progressPercent * 100;
                final netWorth = nwc.netWorth.value;
                final nwGrowth = nwc.monthlyGrowth.value;

                return Row(
                  children: [
                    _buildSnapshotItem(
                      context,
                      icon: Icons.favorite_rounded,
                      iconColor: FinancialHealthController.getScoreColor(score),
                      title: 'Health Score',
                      value: '${score.toStringAsFixed(0)} / 100',
                      subtitle: FinancialHealthController.getScoreLabel(score),
                      subtitleColor: FinancialHealthController.getScoreColor(score),
                    ),
                    _buildDivider(context),
                    _buildSnapshotItem(
                      context,
                      icon: Icons.shield_rounded,
                      iconColor: Colors.green,
                      title: 'Dana Darurat',
                      value: '${efProgress.toStringAsFixed(0)}%',
                      subtitle: '${efc.metrics.value.monthsCovered.toStringAsFixed(1)} / ${efc.profile.value.multiplier} Bulan',
                      subtitleColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                    _buildDivider(context),
                    _buildSnapshotItem(
                      context,
                      icon: Icons.diamond_rounded,
                      iconColor: Colors.deepPurpleAccent,
                      title: 'Net Worth',
                      value: CurrencyFormat.format(netWorth).replaceAll('Rp', '').trim(),
                      subtitle: nwGrowth >= 0 ? '+${nwGrowth.toStringAsFixed(1)}%' : '${nwGrowth.toStringAsFixed(1)}%',
                      subtitleColor: nwGrowth >= 0 ? Colors.green : Colors.red,
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Theme.of(context).dividerColor.withOpacity(0.5),
    );
  }

  Widget _buildSnapshotItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    required Color subtitleColor,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: subtitleColor, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
