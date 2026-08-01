import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/onboarding_controller.dart';

class OnboardingProgressHeader extends StatelessWidget {
  const OnboardingProgressHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = Get.find<OnboardingController>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => Container(
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFFD4C5B9).withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: controller.currentStep.value / controller.totalSteps,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFA78BCA), Color(0xFFE8927C)],
                    ),
                  ),
                ),
              ),
            )),
          ),
          const SizedBox(width: 16),
          Obx(() => Text(
            '${controller.currentStep.value} of ${controller.totalSteps}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8B7355),
              letterSpacing: 1.0,
            ),
          )),
        ],
      ),
    );
  }
}

class OnboardingBackButton extends StatelessWidget {
  const OnboardingBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = Get.find<OnboardingController>();

    return Obx(() {
      if (controller.currentStep.value > 1) {
        return Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
          child: TextButton.icon(
            onPressed: controller.prevStep,
            icon: const Icon(Icons.arrow_back, color: Color(0xFF8B7355), size: 18),
            label: const Text('Back', style: TextStyle(color: Color(0xFF8B7355), fontSize: 15, fontWeight: FontWeight.w500)),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        );
      }
      return const SizedBox(height: 12);
    });
  }
}
