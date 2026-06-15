import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/budget_controller.dart';
import 'budget_components.dart';
import 'budget_manage_page.dart';

class BudgetSection extends StatelessWidget {
  const BudgetSection({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<BudgetController>()) {
      return const SizedBox.shrink();
    }
    final budgetC = Get.find<BudgetController>();

    return Obx(() {
      if (budgetC.budgetUsages.isEmpty) {
        return _buildEmptyBudget(context);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Budget Monitoring',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                GestureDetector(
                  onTap: () => Get.to(() => const BudgetManagePage()),
                  child: Row(
                    children: [
                      Text(
                        'Set Budget',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary),
                    ],
                  ),
                )
              ],
            ),
          ),
          ...budgetC.budgetUsages.map((usage) => Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: BudgetProgressBar(usage: usage),
              )),
          if (budgetC.insights.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text(
                'AI Insights 🧠',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            SizedBox(
              height: 140,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: budgetC.insights.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    margin: const EdgeInsets.only(right: 12),
                    child: InsightCard(insight: budgetC.insights[index]),
                  );
                },
              ),
            ),
          ]
        ],
      );
    });
  }

  Widget _buildEmptyBudget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: InkWell(
        onTap: () => Get.to(() => const BudgetManagePage()),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                style: BorderStyle.solid),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.track_changes_rounded,
                    color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Aktifkan Smart Budget',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Kontrol pengeluaranmu lebih efektif dengan AI.',
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
