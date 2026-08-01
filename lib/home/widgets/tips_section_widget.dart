import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import '../controller/home_controller.dart';

class TipsSectionWidget extends StatelessWidget {
  const TipsSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    
    final tips = [
      {'icon': Icons.water_drop_outlined, 'title': 'Stay Hydrated', 'desc': 'Drink at least 8 glasses of water to help reduce bloating.'},
      {'icon': Icons.accessibility_new_rounded, 'title': 'Gentle Exercise', 'desc': 'Light yoga or walking can help ease cramps.'},
      {'icon': Icons.eco_outlined, 'title': 'Iron-Rich Foods', 'desc': 'Include spinach and legumes in your meals today.'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tips for today',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Get.snackbar(
                        'Tips Library',
                        'More wellness tips are coming soon!',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    child: Text(
                      'SEE ALL',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary.withOpacity(0.5),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Get.snackbar(
                        'Feature Coming Soon',
                        'You will soon be able to add your own tips.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.textPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: tips.length,
            itemBuilder: (context, index) {
              final tip = tips[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(tip['icon'] as IconData, color: AppColors.textPrimary.withOpacity(0.4), size: 24),
                    const SizedBox(height: 12),
                    Text(
                      tip['title'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tip['desc'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textPrimary.withOpacity(0.6),
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
