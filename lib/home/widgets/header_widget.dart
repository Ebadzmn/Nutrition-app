import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:herwellness_flutter/core/network/api_client.dart';
import '../../core/app_colors.dart';
import '../../core/app_route.dart';
import '../controller/home_controller.dart';

import '../../settings/controller/settings_controller.dart';
import '../controller/notification_controller.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController =
        Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>()
        : Get.put(SettingsController());

    final NotificationController notificationController =
        Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left: Avatar
          Align(
            alignment: Alignment.centerLeft,
            child: Obx(() {
              final hasAvatar = settingsController.avatarUrl.value.isNotEmpty;
              return Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  shape: BoxShape.circle,
                ),
                child: hasAvatar
                    ? ClipOval(
                        child: Image.network(
                          settingsController.avatarUrl.value,
                          headers: {
                            if (Get.isRegistered<ApiClient>() &&
                                Get.find<ApiClient>().authToken != null)
                              'Authorization':
                                  'Bearer ${Get.find<ApiClient>().authToken}',
                          },
                          fit: BoxFit.cover,
                          width: 40,
                          height: 40,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                settingsController.username.value.isNotEmpty
                                    ? settingsController.username.value
                                          .substring(0, 1)
                                          .toLowerCase()
                                    : (settingsController.name.value.isNotEmpty
                                          ? settingsController.name.value
                                                .substring(0, 1)
                                                .toLowerCase()
                                          : 'h'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Georgia',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Text(
                          settingsController.username.value.isNotEmpty
                              ? settingsController.username.value
                                    .substring(0, 1)
                                    .toLowerCase()
                              : (settingsController.name.value.isNotEmpty
                                    ? settingsController.name.value
                                          .substring(0, 1)
                                          .toLowerCase()
                                    : 'h'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Georgia',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              );
            }),
          ),

          // Center: Logo
          Image.network(
            'https://qtrypzzcjebvfcihiynt.supabase.co/storage/v1/object/public/base44-prod/public/69934eac0b26e505ebf4ef11/6dd51d48c_TransparentLogo.png',
            height: 40,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.spa_rounded, color: AppColors.primary, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'HerWellness',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              );
            },
          ),

          // Right: Bell with Badge
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => Get.toNamed(AppRoute.notification),
              borderRadius: BorderRadius.circular(20),
              child: Obx(() {
                final count = notificationController.unreadCount;
                return Stack(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    if (count > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
