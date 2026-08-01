import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/app_colors.dart';
import '../core/app_route.dart';
import '../home/presentation/home_screen.dart';
import '../workouts/presentation/workouts_screen.dart';
import '../nutrition/presentation/nutrition_screen.dart';
import '../community/presentation/community_screen.dart';
import '../settings/presentation/settings_screen.dart';
import '../auth/controller/auth_controller.dart';
import 'navbar_controller.dart';

class NavbarUi extends StatelessWidget {
  const NavbarUi({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavbarController());

    final List<Widget> pages = [
      const HomeScreen(),
      const WorkoutsScreen(),
      const NutritionScreen(),
      const CommunityScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: pages,
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final authController = Get.find<AuthController>();
          if (!authController.hasPremiumAccess) {
            Get.toNamed(AppRoute.premium);
          } else {
            Get.toNamed(AppRoute.aiCoachChat);
          }
        },
        backgroundColor: const Color(0xFF7DD3C0),
        elevation: 4,
        child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, 'Home', 'https://qtrypzzcjebvfcihiynt.supabase.co/storage/v1/object/public/base44-prod/public/69934eac0b26e505ebf4ef11/2e1c8f2bd_TransparentLogo.png', controller),
                    _buildNavItem(1, 'Workouts', Icons.fitness_center_rounded, controller),
                    _buildNavItem(2, 'Nutrition', Icons.apple_rounded, controller),
                    _buildNavItem(3, 'Community', Icons.people_rounded, controller),
                    _buildNavItem(4, 'Settings', Icons.settings_rounded, controller),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, dynamic icon, NavbarController controller) {
    return Obx(() {
      final isActive = controller.currentIndex.value == index;
      const activeColor = Color(0xFF6B5D4F);
      final inactiveColor = Colors.grey.withOpacity(0.6);

      return GestureDetector(
        onTap: () {
          if (index == 1 || index == 2 || index == 3) {
            final authController = Get.find<AuthController>();
            if (!authController.hasPremiumAccess) {
              Get.toNamed(AppRoute.premium);
              return;
            }
          }
          controller.changePage(index);
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon is String)
              Image.network(
                icon,
                width: 24,
                height: 24,
                color: isActive ? null : Colors.grey.withOpacity(0.6),
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.home_rounded,
                    size: 24,
                    color: isActive ? const Color(0xFF6B5D4F) : Colors.grey.withOpacity(0.6),
                  );
                },
              )
            else
              Icon(
                icon as IconData,
                size: 24,
                color: isActive ? activeColor : inactiveColor,
              ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      );
    });
  }
}
