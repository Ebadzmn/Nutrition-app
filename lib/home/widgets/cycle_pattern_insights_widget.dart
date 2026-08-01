import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import '../controller/home_controller.dart';
import 'package:intl/intl.dart';
import '../../auth/controller/auth_controller.dart';
import '../../core/app_route.dart';

class CyclePatternInsightsWidget extends StatelessWidget {
  const CyclePatternInsightsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final authController = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final hasPremium = authController.hasPremiumAccess;
      final logsCount = controller.recentLogs.length;
      final canGenerate = logsCount >= 5;
      final insights = controller.aiInsights.value;
      final isExpanded = controller.isInsightsExpanded.value;
      final isLoading = controller.isLoadingInsights.value;
      final lastGenerated = controller.lastInsightsGenerated.value;

      String subtitle = '';
      if (!hasPremium) {
        subtitle = "Upgrade to Premium to unlock AI analysis";
      } else if (!canGenerate) {
        final remaining = 5 - logsCount;
        subtitle = "Log $remaining more day${remaining != 1 ? 's' : ''} to unlock AI analysis";
      } else if (lastGenerated != null) {
        subtitle = "Updated ${DateFormat('MMM d, h:mm a').format(lastGenerated)}";
      } else {
        subtitle = "Tap to analyse your patterns";
      }

      return Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3EFEA),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header button
            InkWell(
              onTap: () {
                if (!hasPremium) {
                  Get.toNamed(AppRoute.premium);
                  return;
                }
                if (isLoading) return;
                if (insights != null) {
                  controller.isInsightsExpanded.value = !controller.isInsightsExpanded.value;
                } else if (canGenerate) {
                  controller.generateInsights();
                } else {
                  final remaining = 5 - logsCount;
                  Get.snackbar(
                    'AI Insights',
                    'Log $remaining more day${remaining != 1 ? 's' : ''} to unlock personalized AI cycle analysis!',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF9B63F8).withOpacity(0.1),
                    colorText: isDark ? Colors.white : Colors.black,
                  );
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9B63F8),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cycle Pattern Insights',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF3A2E28),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : const Color(0xFF7A6856),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!hasPremium)
                      const Icon(
                        Icons.lock_outline_rounded,
                        color: Color(0xFFE8927C),
                        size: 20,
                      )
                    else if (isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9B63F8)),
                        ),
                      )
                    else if (insights != null)
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: isDark ? Colors.grey[400] : const Color(0xFF7A6856),
                      )
                    else if (canGenerate)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9B63F8).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Analyse',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF9B63F8),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Expanded body
            if (isExpanded && insights != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 1, thickness: 1, color: Color(0x1F7A6856)),
                    const SizedBox(height: 16),
                    if (insights['error'] == true)
                      const Center(
                        child: Text(
                          "Couldn't generate insights. Try again later.",
                          style: TextStyle(fontSize: 12, color: Colors.redAccent),
                        ),
                      )
                    else ...[
                      if (insights['summary'] != null) ...[
                        Container(
                          padding: const EdgeInsets.only(left: 12),
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(color: Color(0xFFD3C2FF), width: 3),
                            ),
                          ),
                          child: Text(
                            insights['summary'],
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: isDark ? Colors.grey[400] : const Color(0xFF7A6856),
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (insights['insights'] != null && insights['insights'] is List)
                        ...List.generate((insights['insights'] as List).length, (idx) {
                          final item = insights['insights'][idx];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.star, color: Color(0xFF9B63F8), size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'] ?? '',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : const Color(0xFF3A2E28),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['body'] ?? '',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? Colors.grey[300] : const Color(0xFF5A4D42),
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton(
                          onPressed: isLoading ? null : () => controller.generateInsights(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: const Color(0xFF9B63F8).withOpacity(0.5)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Refresh analysis',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9B63F8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}
