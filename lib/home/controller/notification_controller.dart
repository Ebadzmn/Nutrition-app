import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';

class NotificationController extends GetxController {
  var notifications = <dynamic>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.get('/notification');
      if (response.isSuccess && response.data != null && response.data is List) {
        notifications.assignAll(response.data);
      }
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    } finally {
      isLoading.value = false;
    }
  }

  int get unreadCount {
    return notifications.where((n) => n['read'] == false).length;
  }

  Future<void> markAsRead(String id) async {
    try {
      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.put('/notification/$id', data: {'read': true});
      if (response.isSuccess) {
        // Update local list
        final idx = notifications.indexWhere((n) => n['id'].toString() == id);
        if (idx != -1) {
          final updated = Map<String, dynamic>.from(notifications[idx]);
          updated['read'] = true;
          notifications[idx] = updated;
          notifications.refresh();
        }
      }
    } catch (e) {
      debugPrint("Error marking notification as read: $e");
    }
  }

  Future<void> markAllAsRead() async {
    final unreadList = notifications.where((n) => n['read'] == false).toList();
    if (unreadList.isEmpty) return;

    try {
      final ApiClient apiClient = Get.find<ApiClient>();
      for (var n in unreadList) {
        final id = n['id'].toString();
        await apiClient.put('/notification/$id', data: {'read': true});
        
        final idx = notifications.indexWhere((item) => item['id'].toString() == id);
        if (idx != -1) {
          final updated = Map<String, dynamic>.from(notifications[idx]);
          updated['read'] = true;
          notifications[idx] = updated;
        }
      }
      notifications.refresh();
      Get.snackbar(
        'Success',
        'All notifications marked as read',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF8B7355),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      debugPrint("Error marking all notifications as read: $e");
    }
  }
}
