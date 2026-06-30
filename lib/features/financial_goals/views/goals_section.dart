import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/goals_controller.dart';
import '../../../data/models/goal_model.dart';
import 'create_goal_page.dart';
import 'add_contribution_sheet.dart';


class GoalsSection extends StatelessWidget {
  GoalsSection({super.key});

  final GoalsController controller = Get.put(GoalsController());
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Financial Goals',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Capai tujuan finansialmu dengan konsisten 🎯',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Color(0xFF0288D1), size: 28),
                onPressed: () {
                  Get.to(() => const CreateGoalPage());
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(),
          const SizedBox(height: 20),
          _buildFilterTabs(),
          const SizedBox(height: 20),
          Obx(() => ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.filteredGoals.length,
                itemBuilder: (context, index) {
                  return _buildGoalCard(controller.filteredGoals[index], context);
                },
              )),
          const SizedBox(height: 12),
        ],
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
          BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _summaryItem(Icons.track_changes, 'Total Goals', '${controller.totalGoals}', Colors.blue),
              _summaryItem(Icons.trending_up, 'Total Terkumpul', currencyFormat.format(controller.totalCollected), Colors.green),
              _summaryItem(Icons.calendar_today, 'Goal Tercapai', '${controller.goalsAchieved}', Colors.orange),
            ],
          )),
    );
  }

  Widget _summaryItem(IconData icon, String label, String value, Color color, {bool showArrow = false}) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 9)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(child: Text(value, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13))),
              if (showArrow) const Icon(Icons.chevron_right, size: 14, color: Colors.grey),
            ],
          ),
        ],
      ),
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
                      color: isSelected ? const Color(0xFF4FC3F7) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[600],
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          )),
    );
  }

  IconData _getIconForGoal(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('motor') || lowerTitle.contains('kendaraan')) {
      return Icons.two_wheeler;
    } else if (lowerTitle.contains('mobil')) {
      return Icons.directions_car;
    } else if (lowerTitle.contains('darurat') || lowerTitle.contains('kesehatan')) {
      return Icons.health_and_safety;
    } else if (lowerTitle.contains('liburan') || lowerTitle.contains('travel') || lowerTitle.contains('jalan')) {
      return Icons.flight_takeoff;
    } else if (lowerTitle.contains('rumah') || lowerTitle.contains('kpr')) {
      return Icons.home;
    } else if (lowerTitle.contains('nikah') || lowerTitle.contains('wedding')) {
      return Icons.favorite;
    } else if (lowerTitle.contains('pendidikan') || lowerTitle.contains('sekolah') || lowerTitle.contains('kuliah')) {
      return Icons.school;
    } else if (lowerTitle.contains('gadget') || lowerTitle.contains('hp') || lowerTitle.contains('laptop') || lowerTitle.contains('macbook')) {
      return Icons.laptop_mac;
    }
    return Icons.savings; // Default icon
  }

  Widget _buildGoalCard(GoalModel goal, BuildContext context) {
    final progress = goal.progressPercentage;
    final requiredMonthly = controller.calculateRequiredMonthly(goal);

    return GestureDetector(
      onTap: () => Get.to(() => CreateGoalPage(editGoal: goal)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
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
                  color: Color(int.parse(goal.colorHex.replaceFirst('#', '0xFF'))),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getIconForGoal(goal.title), size: 30, color: Colors.blue[800]), // Auto-generated icon
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(goal.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis)),
                        Text(currencyFormat.format(goal.currentAmount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text('Target: ${DateFormat('dd MMM yyyy').format(goal.targetDate)}', style: TextStyle(color: Colors.grey[600], fontSize: 12), overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 4),
                        Text('/ ${currencyFormat.format(goal.targetAmount)}', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
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
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0288D1)),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${(progress * 100).toInt()}%', style: const TextStyle(color: Color(0xFF0288D1), fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              if (goal.status != 'completed') {
                Get.bottomSheet(AddContributionSheet(goal: goal), isScrollControlled: true);
              } else {
                Get.snackbar('Selesai', 'Target ini sudah tercapai!', backgroundColor: Colors.orange, colorText: Colors.white);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: goal.status == 'completed' ? Colors.green[50] : const Color(0xFFE1F5FE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(goal.status == 'completed' ? Icons.check_circle : Icons.add_card, size: 16, color: goal.status == 'completed' ? Colors.green : const Color(0xFF0288D1)),
                      const SizedBox(width: 8),
                      Text(
                        goal.status == 'completed' 
                          ? 'Target Selesai!' 
                          : 'Isi tabungan (${currencyFormat.format(requiredMonthly)} / bulan)', 
                        style: TextStyle(
                          color: goal.status == 'completed' ? Colors.green[800] : const Color(0xFF0288D1), 
                          fontSize: 11, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                    ],
                  ),
                  Icon(goal.status == 'completed' ? Icons.stars : Icons.add_circle, size: 20, color: goal.status == 'completed' ? Colors.green : const Color(0xFF0288D1)),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

}
