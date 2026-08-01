import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';

import '../controller/notification_controller.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2D2420), size: 20),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF2D2420),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Georgia',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => controller.markAllAsRead(),
            child: const Text(
              'Mark all as read',
              style: TextStyle(color: Color(0xFFE8927C), fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF8B7355)),
          );
        }

        if (controller.notifications.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final item = controller.notifications[index];
            return _buildNotificationCard(item, controller);
          },
        );
      }),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item, NotificationController controller) {
    final isRead = item['read'] == true;
    final id = item['id'].toString();
    final type = item['type']?.toString() ?? 'general';

    return GestureDetector(
      onTap: () {
        if (!isRead) {
          controller.markAsRead(id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? Colors.white.withOpacity(0.6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: !isRead
              ? Border.all(color: const Color(0xFFE8927C).withOpacity(0.3), width: 1)
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getColor(type),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_getIcon(type), color: const Color(0xFF2D2420).withOpacity(0.7), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item['title'] ?? '',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D2420).withOpacity(isRead ? 0.6 : 1.0),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(item['createdAt']),
                        style: TextStyle(
                          fontSize: 11,
                          color: const Color(0xFF8B7355).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['message'] ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF5C4A3A).withOpacity(isRead ? 0.6 : 0.9),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (!isRead)
              Container(
                margin: const EdgeInsets.only(left: 8, top: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8927C),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? createdAtStr) {
    if (createdAtStr == null) return '';
    try {
      final dateTime = DateTime.parse(createdAtStr);
      final difference = DateTime.now().difference(dateTime);
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (_) {
      return '';
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'personal_record':
        return Icons.auto_awesome;
      case 'workout_milestone':
        return Icons.fitness_center_rounded;
      case 'streak':
        return Icons.wb_sunny_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'personal_record':
        return const Color(0xFFA78BCA).withOpacity(0.2);
      case 'workout_milestone':
        return const Color(0xFFE8D5C4);
      case 'streak':
        return const Color(0xFFF5D6C6);
      default:
        return const Color(0xFFC8DCC8);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFEDE6DD),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_off_outlined, size: 40, color: Color(0xFFD4C5B9)),
          ),
          const SizedBox(height: 24),
          const Text(
            'All caught up!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2420),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No new notifications at the moment.',
            style: TextStyle(color: Color(0xFF8B7355)),
          ),
        ],
      ),
    );
  }
}
