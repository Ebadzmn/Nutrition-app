import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:herwellness_flutter/onboarding/widgets/onboarding_header_widget.dart';
import 'package:herwellness_flutter/onboarding/widgets/onboarding_steps_widget.dart';
import '../../core/app_colors.dart';
import '../controller/onboarding_controller.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late OnboardingController controller;

  @override
  void initState() {
    super.initState();
    // Initialize the controller properly
    if (Get.isRegistered<OnboardingController>()) {
      Get.delete<OnboardingController>();
    }
    controller = Get.put(OnboardingController());
    debugPrint('✅ OnboardingController initialized');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          _buildBackgroundTexture(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const OnboardingProgressHeader(),
                const OnboardingBackButton(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    child: Obx(() => _getStepWidget()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getStepWidget() {
    switch (controller.currentStep.value) {
      case 1:
        return StepPhotoWidget();
      case 2:
        return StepWelcomeWidget();
      case 3:
        return StepContraceptionWidget();
      case 4:
        return StepContraceptionDetailsWidget();
      case 5:
        return StepCycleDatesWidget();
      case 6:
        return StepDailyCheckinsWidget();
      case 7:
        return StepSymptomsGoalsWidget();
      case 8:
        return StepSummaryWidget();
      default:
        debugPrint('❌ Unknown step: ${controller.currentStep.value}');
        return const SizedBox();
    }
  }

  Widget _buildBackgroundTexture() {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.6, -0.6),
                radius: 1.2,
                colors: [
                  const Color(0xFFE8927C).withOpacity(0.08),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.8, 0.8),
                radius: 1.2,
                colors: [
                  const Color(0xFFA78BCA).withOpacity(0.06),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
