import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/goals_controller.dart';
import '../../../data/models/goal_model.dart';

class GoalsDashboardView extends StatelessWidget {
  GoalsDashboardView({super.key});

  final GoalsController controller = Get.put(GoalsController());
  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF), // Light background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Financial Goals',
                style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.bold)),
            Text('Capai tujuan finansialmu dengan konsisten 🎯',
                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFE1F5FE),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Color(0xFF0288D1)),
              onPressed: () {
                // TODO: Open Create Goal Sheet
              },
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(),
              const SizedBox(height: 20),
              _buildFilterTabs(),
              const SizedBox(height: 20),
              Obx(() => ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.filteredGoals.length,
                    itemBuilder: (context, index) {
                      return _buildGoalCard(controller.filteredGoals[index]);
                    },
                  )),
              const SizedBox(height: 80), // Padding for bottom nav if needed
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.blue.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _summaryItem(Icons.track_changes, 'Total Goals',
                  '${controller.totalGoals}', Colors.blue),
              _summaryItem(
                  Icons.trending_up,
                  'Total Terkumpul',
                  currencyFormat.format(controller.totalCollected),
                  Colors.green),
              _summaryItem(Icons.calendar_today, 'Goal Tercapai',
                  '${controller.goalsAchieved}', Colors.orange),
            ],
          )),
    );
  }

  Widget _summaryItem(IconData icon, String label, String value, Color color,
      {bool showArrow = false}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(value,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 14)),
            if (showArrow)
              const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Obx(() => Row(
            children: ['Semua Goals', 'Aktif', 'Selesai'].map((filter) {
              final isSelected = controller.currentFilter.value == filter;
              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.applyFilter(filter),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4FC3F7)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[600],
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          )),
    );
  }

  Widget _buildGoalCard(GoalModel goal) {
    final progress = goal.progressPercentage;
    final requiredMonthly = controller.calculateRequiredMonthly(goal);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.blue.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color:
                      Color(int.parse(goal.colorHex.replaceFirst('#', '0xFF'))),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.image,
                    size: 30, color: Colors.grey), // Placeholder for image
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(goal.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(currencyFormat.format(goal.currentAmount),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            'Target: ${DateFormat('dd MMM yyyy').format(goal.targetDate)}',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12)),
                        Text('/ ${currencyFormat.format(goal.targetAmount)}',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF0288D1)),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${(progress * 100).toInt()}%',
                            style: const TextStyle(
                                color: Color(0xFF0288D1),
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE1F5FE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.savings,
                        size: 16, color: Color(0xFF0288D1)),
                    const SizedBox(width: 8),
                    Text(
                        'Perlu menabung ${currencyFormat.format(requiredMonthly)} / bulan',
                        style: const TextStyle(
                            color: Color(0xFF0288D1),
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const Icon(Icons.chevron_right,
                    size: 16, color: Color(0xFF0288D1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
