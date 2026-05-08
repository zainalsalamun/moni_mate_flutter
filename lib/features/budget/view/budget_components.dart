import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monimate/utils/format_currency.dart';
import '../engine/budget_engine.dart';
import 'package:monimate/data/controller/transaction_controller.dart';

class BudgetProgressBar extends StatelessWidget {
  final BudgetUsage usage;

  const BudgetProgressBar({super.key, required this.usage});

  @override
  Widget build(BuildContext context) {
    final double percent = usage.percentage / 100;
    final double clampedPercent = percent.clamp(0.0, 1.0);

    Color color;
    if (usage.percentage < 70) {
      color = const Color(0xFF48C6EF); // Toska
    } else if (usage.percentage < 90) {
      color = Colors.orange; // Orange
    } else {
      color = Colors.redAccent; // Red
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: usage.percentage >= 100 ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, shakeValue, child) {
        // Simple shake calculation
        final double offset = usage.percentage >= 100
            ? (shakeValue < 0.2
                ? 5.0
                : (shakeValue < 0.4
                    ? -5.0
                    : (shakeValue < 0.6
                        ? 3.0
                        : (shakeValue < 0.8 ? -3.0 : 0.0))))
            : 0.0;

        return Transform.translate(
          offset: Offset(offset, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        Get.find<TransactionController>().getCategoryName(usage.budget.categoryId),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      _buildBadge(usage),
                    ],
                  ),
                  Text(
                    '${(usage.percentage).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${CurrencyFormat.format(usage.currentUsage)} / ${CurrencyFormat.format(usage.budget.monthlyLimit)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    height: 12,
                    width: (MediaQuery.of(context).size.width - 40) *
                        clampedPercent,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.7), color],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              if (usage.percentage >= 100)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    '🚨 Kamu sudah melewati budget!',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadge(BudgetUsage usage) {
    if (usage.percentage < 50 && usage.currentUsage > 0) {
      return const _BadgeChip(label: 'Hemat Master', color: Colors.green);
    } else if (usage.percentage < 90 && usage.currentUsage > 0) {
      return const _BadgeChip(label: 'On Track', color: Colors.blue);
    }
    return const SizedBox.shrink();
  }
}

class _BadgeChip extends StatelessWidget {
  final String label;
  final Color color;

  const _BadgeChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class InsightCard extends StatelessWidget {
  final BudgetInsight insight;

  const InsightCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (insight.type) {
      case 'warning':
        color = Colors.orange;
        icon = Icons.warning_amber_rounded;
        break;
      case 'success':
        color = Colors.green;
        icon = Icons.check_circle_outline_rounded;
        break;
      default:
        color = const Color(0xFF48C6EF);
        icon = Icons.info_outline_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
