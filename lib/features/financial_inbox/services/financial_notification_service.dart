import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../data/services/hive_service.dart';
import '../models/financial_notification_model.dart';
import '../controllers/financial_inbox_controller.dart';

class FinancialNotificationService extends GetxService {
  final _uuid = const Uuid();

  List<FinancialNotificationModel> get notifications {
    return HiveService.financialInboxBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _updateUnreadCount();
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  Future<void> sendNotification({
    required String title,
    required String message,
    required NotificationCategory category,
    required NotificationPriority priority,
    String? actionRoute,
    String? actionPayload,
  }) async {
    final notification = FinancialNotificationModel(
      id: _uuid.v4(),
      title: title,
      message: message,
      category: category,
      priority: priority,
      actionRoute: actionRoute,
      actionPayload: actionPayload,
      createdAt: DateTime.now(),
      isRead: false,
      isDismissed: false,
    );

    await HiveService.financialInboxBox.put(notification.id, notification);
    _updateUnreadCount();
    
    // Optionally trigger an event or refresh controller
    if (Get.isRegistered<FinancialInboxController>()) {
      Get.find<FinancialInboxController>().refreshNotifications();
    }
  }

  Future<void> markAsRead(String id) async {
    final notif = HiveService.financialInboxBox.get(id);
    if (notif != null && !notif.isRead) {
      notif.isRead = true;
      await HiveService.financialInboxBox.put(id, notif);
      _updateUnreadCount();
    }
  }

  Future<void> deleteNotification(String id) async {
    await HiveService.financialInboxBox.delete(id);
    _updateUnreadCount();
  }

  Future<void> syncOldNotifications() async {
    final now = DateTime.now();
    final allNotifs = HiveService.financialInboxBox.values.toList();
    
    for (var notif in allNotifs) {
      // Retain last 90 days, delete older than 90 days
      if (now.difference(notif.createdAt).inDays > 90) {
        await notif.delete();
      } 
      // Delete dismissed older than 30 days
      else if (notif.isDismissed && now.difference(notif.createdAt).inDays > 30) {
        await notif.delete();
      }
    }
  }

  // --- Convenience Methods for Generators ---

  Future<void> sendAiInsight(String message) async {
    await sendNotification(
      title: 'AI Coach',
      message: message,
      category: NotificationCategory.aiCoach,
      priority: NotificationPriority.info,
    );
  }

  Future<void> sendBudgetAlert(String budgetName, double percentage, {double? remaining}) async {
    final isCritical = percentage >= 100;
    final message = isCritical 
        ? "Budget $budgetName telah habis."
        : "Budget $budgetName telah mencapai ${percentage.toInt()}%.";
    
    await sendNotification(
      title: 'Budget Alert',
      message: message,
      category: NotificationCategory.budgetAlert,
      priority: isCritical ? NotificationPriority.critical : NotificationPriority.warning,
    );
  }

  Future<void> sendGoalReminder(String goalName, String message) async {
    await sendNotification(
      title: 'Goal Reminder',
      message: message,
      category: NotificationCategory.goalReminder,
      priority: NotificationPriority.warning,
    );
  }

  Future<void> sendAchievement(String title, String message) async {
    await sendNotification(
      title: title,
      message: message,
      category: NotificationCategory.achievement,
      priority: NotificationPriority.success,
    );
  }

  Future<void> sendEmergencyFundUpdate(String message) async {
    await sendNotification(
      title: 'Dana Darurat',
      message: message,
      category: NotificationCategory.emergencyFund,
      priority: NotificationPriority.success,
    );
  }
}
