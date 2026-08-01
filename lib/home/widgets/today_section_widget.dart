import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import '../controller/home_controller.dart';

import '../../core/app_route.dart';
import '../../nav_bar/navbar_controller.dart';

class TodaySectionWidget extends StatelessWidget {
  const TodaySectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final navBox = Get.find<NavbarController>();
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final phase = _getPhaseNumber(controller.cycleDay.value);
            final workout = _workoutByPhase[phase]!;
            final nutrition = _nutritionByPhase[phase]!;
            
            return Column(
              children: [
                _buildLandscapeCard(
                  icon: Icons.fitness_center_rounded,
                  iconColor: isDark ? const Color(0xFFE8D5C4) : const Color(0xFF6B5D4F),
                  accentColor: isDark ? const Color(0xFFE8D5C4) : const Color(0xFF6B5D4F),
                  cardBg: isDark ? const Color(0xFF4A3B2F) : const Color(0xFFE8D5C4),
                  title: workout['title']!,
                  desc: workout['desc']!,
                  onTap: () => navBox.changePage(1), // Switch to Workouts tab
                ),
                const SizedBox(height: 12),
                _buildLandscapeCard(
                  icon: Icons.apple_rounded,
                  iconColor: isDark ? const Color(0xFFC8DCC8) : const Color(0xFF4A7A5A),
                  accentColor: isDark ? const Color(0xFFC8DCC8) : const Color(0xFF4A7A5A),
                  cardBg: isDark ? const Color(0xFF2E3E34) : const Color(0xFFC8DCC8),
                  title: nutrition['title']!,
                  desc: nutrition['desc']!,
                  onTap: () => navBox.changePage(2), // Switch to Nutrition tab
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  int _getPhaseNumber(int cycleDay) {
    if (cycleDay <= 5) return 1;
    if (cycleDay <= 13) return 2;
    if (cycleDay <= 16) return 3;
    return 4;
  }

  static const Map<int, Map<String, String>> _workoutByPhase = {
    1: {"title": "Rest & Recover", "desc": "Low-intensity to support your body during menstruation"},
    2: {"title": "Building Energy", "desc": "Gradually increase intensity as energy rises"},
    3: {"title": "Peak Performance", "desc": "Your body is primed for high-intensity training"},
    4: {"title": "Wind Down", "desc": "Moderate intensity as you prepare for your next cycle"},
  };

  static const Map<int, Map<String, String>> _nutritionByPhase = {
    1: {"title": "Nourishing Foods", "desc": "Focus on iron-rich foods and anti-inflammatory ingredients"},
    2: {"title": "Energy Boosting", "desc": "Light, fresh foods to support rising energy levels"},
    3: {"title": "Peak Nutrition", "desc": "Fuel your body during your most energetic phase"},
    4: {"title": "Comfort Foods", "desc": "Complex carbs and mood-boosting nutrients"},
  };

  Widget _buildLandscapeCard({
    required IconData icon,
    required Color iconColor,
    required Color accentColor,
    required Color cardBg,
    required String title,
    required String desc,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.55),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 12,
                      color: accentColor.withOpacity(0.7),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: accentColor.withOpacity(0.5), size: 20),
          ],
        ),
      ),
    );
  }
}
