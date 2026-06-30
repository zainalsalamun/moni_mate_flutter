import 'package:get/get.dart';
import '../models/financial_notification_model.dart';
import '../services/financial_notification_service.dart';

class FinancialInboxController extends GetxController {
  final FinancialNotificationService _service = Get.find<FinancialNotificationService>();

  final notifications = <FinancialNotificationModel>[].obs;
  final selectedFilter = Rx<NotificationCategory?>(null);

  @override
  void onInit() {
    super.onInit();
    refreshNotifications();
  }

  void refreshNotifications() {
    var allNotifs = _service.notifications;
    
    if (selectedFilter.value != null) {
      allNotifs = allNotifs.where((n) => n.category == selectedFilter.value).toList();
    }
    
    notifications.assignAll(allNotifs);
  }

  void setFilter(NotificationCategory? category) {
    selectedFilter.value = category;
    refreshNotifications();
  }

  Future<void> markAsRead(String id) async {
    await _service.markAsRead(id);
    refreshNotifications();
  }

  Future<void> deleteNotification(String id) async {
    await _service.deleteNotification(id);
    refreshNotifications();
  }
}
