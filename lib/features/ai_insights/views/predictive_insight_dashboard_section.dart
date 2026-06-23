import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/predictive_insight_controller.dart';
import 'predictive_insight_card.dart';
import 'predictive_insight_page.dart';

class PredictiveInsightDashboardSection extends StatelessWidget {
  PredictiveInsightDashboardSection({super.key}) {
    if (!Get.isRegistered<PredictiveInsightController>()) {
      Get.put(PredictiveInsightController());
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PredictiveInsightController>();

    return Obx(() {
      if (controller.isLoading.value && controller.insights.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.insights.isEmpty) {
        return const SizedBox.shrink();
      }

      // Ambil maksimal 3 untuk dashboard
      final displayInsights = controller.insights.take(3).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.psychology,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Predictive Coach',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => Get.to(() => const PredictiveInsightPage()),
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...displayInsights.map((insight) => PredictiveInsightCard(insight: insight)),
        ],
      );
    });
  }
}
