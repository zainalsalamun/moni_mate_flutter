import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/financial_notification_model.dart';
import '../controllers/financial_inbox_controller.dart';

class FinancialNotificationCard extends StatelessWidget {
  final FinancialNotificationModel notification;

  const FinancialNotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FinancialInboxController>();
    
    return Dismissible(
      key: Key(notification.id),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: Colors.blue,
        child: const Icon(Icons.mark_email_read_rounded, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await controller.markAsRead(notification.id);
          return false; // Don't dismiss, just mark read
        } else if (direction == DismissDirection.endToStart) {
          await controller.deleteNotification(notification.id);
          return true; // Dismiss
        }
        return false;
      },
      child: GestureDetector(
        onTap: () {
          controller.markAsRead(notification.id);
          // Handle route navigation here if actionRoute is present
          if (notification.actionRoute != null) {
            Get.toNamed(notification.actionRoute!);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead ? Theme.of(context).cardColor : Theme.of(context).cardColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: notification.isRead 
                ? Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2))
                : Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unread indicator dot
              if (!notification.isRead) ...[
                Container(
                  margin: const EdgeInsets.only(top: 18, right: 12),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(notification.priority),
                    shape: BoxShape.circle,
                  ),
                ),
              ] else ...[
                const SizedBox(width: 20), // Spacing placeholder if read
              ],
              
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getCategoryColor(notification.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(notification.category),
                  color: _getCategoryColor(notification.category),
                ),
              ),
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            _getCategoryName(notification.category),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getCategoryColor(notification.category),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            timeago.format(notification.createdAt, locale: 'id'),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(notification.priority).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getPriorityName(notification.priority),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getPriorityColor(notification.priority),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.aiCoach: return Colors.blue;
      case NotificationCategory.budgetAlert: return Colors.orange;
      case NotificationCategory.goalReminder: return Colors.green;
      case NotificationCategory.emergencyFund: return Colors.teal;
      case NotificationCategory.achievement: return Colors.purple;
      case NotificationCategory.monthlyReport: return Colors.blueGrey;
      case NotificationCategory.recurringTransaction: return Colors.deepOrange;
      case NotificationCategory.smartSpending: return Colors.indigo;
    }
  }

  IconData _getCategoryIcon(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.aiCoach: return Icons.smart_toy_rounded;
      case NotificationCategory.budgetAlert: return Icons.pie_chart_rounded;
      case NotificationCategory.goalReminder: return Icons.track_changes_rounded;
      case NotificationCategory.emergencyFund: return Icons.shield_rounded;
      case NotificationCategory.achievement: return Icons.emoji_events_rounded;
      case NotificationCategory.monthlyReport: return Icons.insert_chart_rounded;
      case NotificationCategory.recurringTransaction: return Icons.autorenew_rounded;
      case NotificationCategory.smartSpending: return Icons.insights_rounded;
    }
  }

  String _getCategoryName(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.aiCoach: return 'AI Coach';
      case NotificationCategory.budgetAlert: return 'Budget Alert';
      case NotificationCategory.goalReminder: return 'Goal Reminder';
      case NotificationCategory.emergencyFund: return 'Dana Darurat';
      case NotificationCategory.achievement: return 'Achievement';
      case NotificationCategory.monthlyReport: return 'Monthly Report';
      case NotificationCategory.recurringTransaction: return 'Recurring Transaction';
      case NotificationCategory.smartSpending: return 'Smart Spending';
    }
  }

  Color _getPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.critical: return Colors.red;
      case NotificationPriority.warning: return Colors.orange;
      case NotificationPriority.success: return Colors.green;
      case NotificationPriority.info: return Colors.blue;
    }
  }
  
  String _getPriorityName(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.critical: return 'Critical';
      case NotificationPriority.warning: return 'Warning';
      case NotificationPriority.success: return 'Success';
      case NotificationPriority.info: return 'Info';
    }
  }
}
