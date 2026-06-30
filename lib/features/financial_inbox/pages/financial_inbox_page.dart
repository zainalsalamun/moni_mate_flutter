import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../controllers/financial_inbox_controller.dart';
import '../models/financial_notification_model.dart';
import '../widgets/financial_notification_card.dart';
import '../widgets/inbox_empty_state.dart';
import '../widgets/notification_filter_chip.dart';

class FinancialInboxPage extends StatelessWidget {
  const FinancialInboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure timeago uses Indonesian locale
    timeago.setLocaleMessages('id', timeago.IdMessages());
    
    final controller = Get.find<FinancialInboxController>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Inbox',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              'Semua aktivitas finansial Anda',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Future: Inbox settings
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card
          _buildSummaryCard(context, controller),
          
          // Filter Chips
          _buildFilters(context, controller),
          
          // List
          Expanded(
            child: Obx(() {
              if (controller.notifications.isEmpty) {
                return const InboxEmptyState();
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: controller.notifications.length,
                itemBuilder: (context, index) {
                  final notif = controller.notifications[index];
                  return FinancialNotificationCard(notification: notif);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, FinancialInboxController controller) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ]
      ),
      child: Obx(() {
        final unreadCount = controller.notifications.where((n) => !n.isRead).length;
        final criticalCount = controller.notifications.where((n) => n.priority == NotificationPriority.critical && !n.isRead).length;
        final achievementCount = controller.notifications.where((n) => n.category == NotificationCategory.achievement).length;
        final insightCount = controller.notifications.where((n) => n.category == NotificationCategory.aiCoach).length;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSummaryItem(context, 'Total\nNotifikasi', unreadCount.toString(), Icons.email_rounded, Colors.blue),
            _buildSummaryItem(context, 'Critical', criticalCount.toString(), Icons.error_rounded, Colors.red),
            _buildSummaryItem(context, 'Achievement', achievementCount.toString(), Icons.emoji_events_rounded, Colors.green),
            _buildSummaryItem(context, 'AI Insight', insightCount.toString(), Icons.auto_awesome_rounded, Colors.purple),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context, FinancialInboxController controller) {
    return Container(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Obx(() {
          return Row(
            children: [
              NotificationFilterChip(
                label: 'Semua',
                isSelected: controller.selectedFilter.value == null,
                onTap: () => controller.setFilter(null),
              ),
              const SizedBox(width: 8),
              NotificationFilterChip(
                label: 'AI Coach',
                isSelected: controller.selectedFilter.value == NotificationCategory.aiCoach,
                icon: Icon(Icons.smart_toy_rounded, 
                  size: 16, 
                  color: controller.selectedFilter.value == NotificationCategory.aiCoach ? Colors.white : Colors.blue
                ),
                onTap: () => controller.setFilter(NotificationCategory.aiCoach),
              ),
              const SizedBox(width: 8),
              NotificationFilterChip(
                label: 'Budget',
                isSelected: controller.selectedFilter.value == NotificationCategory.budgetAlert,
                icon: Icon(Icons.pie_chart_rounded, 
                  size: 16, 
                  color: controller.selectedFilter.value == NotificationCategory.budgetAlert ? Colors.white : Colors.orange
                ),
                onTap: () => controller.setFilter(NotificationCategory.budgetAlert),
              ),
              const SizedBox(width: 8),
              NotificationFilterChip(
                label: 'Goals',
                isSelected: controller.selectedFilter.value == NotificationCategory.goalReminder,
                icon: Icon(Icons.track_changes_rounded, 
                  size: 16, 
                  color: controller.selectedFilter.value == NotificationCategory.goalReminder ? Colors.white : Colors.green
                ),
                onTap: () => controller.setFilter(NotificationCategory.goalReminder),
              ),
              const SizedBox(width: 8),
              NotificationFilterChip(
                label: 'Achievement',
                isSelected: controller.selectedFilter.value == NotificationCategory.achievement,
                icon: Icon(Icons.emoji_events_rounded, 
                  size: 16, 
                  color: controller.selectedFilter.value == NotificationCategory.achievement ? Colors.white : Colors.purple
                ),
                onTap: () => controller.setFilter(NotificationCategory.achievement),
              ),
            ],
          );
        }),
      ),
    );
  }
}
