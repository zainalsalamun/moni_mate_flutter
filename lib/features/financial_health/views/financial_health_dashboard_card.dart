import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/financial_health_controller.dart';
import 'financial_health_page.dart';

class FinancialHealthDashboardCard extends StatelessWidget {
  const FinancialHealthDashboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<FinancialHealthController>()) {
      return const SizedBox.shrink();
    }
    final fhc = Get.find<FinancialHealthController>();

    return Obx(() {
      final score = fhc.totalScore;
      final color = FinancialHealthController.getScoreColor(score);
      final emoji = FinancialHealthController.getScoreEmoji(score);
      final label = FinancialHealthController.getScoreLabel(score);

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: GestureDetector(
          onTap: () => Get.to(() => const FinancialHealthPage()),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color ??
                  Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2D3748)
                    : const Color(0xFFEDF2F7),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: CircularProgressIndicator(
                          value: score / 100,
                          strokeWidth: 6,
                          backgroundColor: color.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Text(
                        score.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Kesehatan Keuangan',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 6),
                          Text(emoji, style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      if (fhc.insights.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          fhc.insights.first,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
