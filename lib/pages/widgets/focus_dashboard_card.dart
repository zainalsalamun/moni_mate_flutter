import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/ai_insights/controllers/predictive_insight_controller.dart';
import '../../features/ai_insights/views/predictive_insight_card.dart';
import '../../features/ai_insights/views/predictive_insight_page.dart';

class FocusDashboardCard extends StatelessWidget {
  const FocusDashboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<PredictiveInsightController>()) {
      Get.put(PredictiveInsightController());
    }
    final controller = Get.find<PredictiveInsightController>();

    return Obx(() {
      if (controller.isLoading.value && controller.insights.isEmpty) {
        return const SizedBox.shrink();
      }
      if (controller.insights.isEmpty) {
        return const SizedBox.shrink();
      }

      final insight = controller.insights.first; // Top priority insight

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fokus Hari Ini',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                TextButton(
                  onPressed: () => Get.to(() => const PredictiveInsightPage()),
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            PredictiveInsightCard(insight: insight),
          ],
        ),
      );
    });
  }
}
