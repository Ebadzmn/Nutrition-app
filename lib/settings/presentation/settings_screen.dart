import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:herwellness_flutter/core/app_colors.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../controller/settings_controller.dart';
import '../../core/network/api_client.dart';
import '../../core/app_route.dart';
import '../../auth/controller/auth_controller.dart';
import '../../home/widgets/cycle_references_widget.dart';
import '../../premium/controller/premium_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final SettingsController controller = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF3A2E28),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Manage your profile and preferences',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8B7355),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Profile Card
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Obx(
                          () => Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD49A9B),
                              shape: BoxShape.circle,
                            ),
                            child: controller.avatarUrl.value.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      controller.avatarUrl.value,
                                      headers: {
                                        if (Get.isRegistered<ApiClient>() &&
                                            Get.find<ApiClient>().authToken !=
                                                null)
                                          'Authorization':
                                              'Bearer ${Get.find<ApiClient>().authToken}',
                                      },
                                      fit: BoxFit.cover,
                                      width: 56,
                                      height: 56,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Center(
                                              child: Text(
                                                controller
                                                        .username
                                                        .value
                                                        .isNotEmpty
                                                    ? controller
                                                          .username
                                                          .value[0]
                                                          .toUpperCase()
                                                    : 'M',
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            );
                                          },
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      controller.username.value.isNotEmpty
                                          ? controller.username.value[0]
                                                .toUpperCase()
                                          : 'M',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8927C),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.settings,
                                size: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.username.value.isNotEmpty
                                  ? controller.username.value
                                  : 'mxguxnnfbzlenetvlf',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF3A2E28),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              controller.email.value.isNotEmpty
                                  ? controller.email.value
                                  : 'mxguxnnfbzlenetvlf@onidm.net',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF8B7355),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // CYCLE PROFILE
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'CYCLE PROFILE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF8B7355),
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              // Contraception Card
              GestureDetector(
                onTap: () => _showContraceptionPicker(context),
                child: Obx(() {
                  final type = controller.contraceptionType.value;
                  Map<String, dynamic>? selectedContraception;
                  for (var c in controller.dbContraceptions) {
                    if (c['key'] == type) {
                      selectedContraception = c;
                      break;
                    }
                  }
                  final icon = selectedContraception?['icon'] ?? '💊';
                  final title =
                      selectedContraception?['title'] ??
                      getContraceptionLabel(type);

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1B22),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(icon, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Contraception type',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFA09FA6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: const [
                            Text(
                              'EDIT',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFE8927C),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFFE8927C),
                              size: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),

              // Training Goal Card
              Obx(() {
                final List<Map<String, dynamic>> defaultGoals = [
                  {'value': 'build_muscle', 'label': 'Build strength & muscle'},
                  {
                    'value': 'improve_endurance',
                    'label': 'Improve endurance / cardio fitness',
                  },
                  {'value': 'weight_loss', 'label': 'Lose body fat'},
                  {
                    'value': 'general_fitness',
                    'label': 'General health & wellbeing',
                  },
                  {
                    'value': 'athletic_performance',
                    'label': 'Athletic performance / competition',
                  },
                ];
                final List<Map<String, dynamic>> goals =
                    controller.dbGoals.isNotEmpty
                    ? controller.dbGoals.toList()
                    : defaultGoals;

                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Training Goal',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF3A2E28),
                          ),
                        ),
                      ),
                      ...goals.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final opt = entry.value;
                        final value = opt['value'] ?? '';
                        final label = opt['label'] ?? '';
                        final isLast = idx == goals.length - 1;
                        return _buildTrainingGoalItem(
                          label,
                          isDark: isDark,
                          isSelected: controller.fitnessGoal.value == value,
                          onTap: () => controller.updateFitnessGoal(value),
                          isLast: isLast,
                        );
                      }),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Cycle Length Card
              Obx(
                () => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _buildExpandedCycleCard(context, isDark),
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'SUBSCRIPTION',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF8B7355),
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              _buildSubscriptionCard(isDark),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'REFERENCES',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF8B7355),
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const CycleReferencesWidget(),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'APP',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF8B7355),
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              _buildAppCard(isDark),
              const SizedBox(height: 24),
              _buildSignOutButton(isDark),
              const SizedBox(height: 16),
              _buildDeleteAccountButton(isDark),
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  'HerWellness · Version 1.0 · yasmin@herwellness.app',
                  style: TextStyle(fontSize: 11, color: Color(0xFF9E9287)),
                ),
              ),
              const SizedBox(height: 80), // Padding for Bottom Nav Bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrainingGoalItem(
    String title, {
    required bool isDark,
    bool isSelected = false,
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? const Color(0xFF333333) : const Color(0xFFF6F3F0),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? (isDark ? Colors.white : const Color(0xFF3A2E28))
                          : const Color(0xFF9E9287),
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check, size: 18, color: Color(0xFFE8927C)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedCycleCard(BuildContext context, bool isDark) {
    final titleColor = isDark ? Colors.white : const Color(0xFF3A2E28);
    final boxBgColor = isDark
        ? const Color(0xFF2C2C2C)
        : const Color(0xFFF3EFEA);
    final boxBorderColor = isDark
        ? const Color(0xFF3A3A3A)
        : const Color(0xFFE2D6C8);
    final boxTextColor = isDark ? Colors.white : const Color(0xFF2D2420);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cycle Length',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${controller.cycleLength.value} ',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE8927C),
                    fontFamily: 'Georgia',
                  ),
                ),
                const TextSpan(
                  text: 'days',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFE8927C),
                    fontFamily: 'Georgia',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildCustomSlider(
          value: controller.cycleLength.value.toDouble().clamp(21.0, 40.0),
          min: 21,
          max: 40,
          onChanged: (v) {
            controller.cycleLength.value = v.toInt();
          },
          onChangeEnd: (v) {
            controller.updateCycleData();
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '21',
                style: TextStyle(color: Color(0xFFAAA5A0), fontSize: 12),
              ),
              Text(
                '28',
                style: TextStyle(color: Color(0xFFAAA5A0), fontSize: 12),
              ),
              Text(
                '35',
                style: TextStyle(color: Color(0xFFAAA5A0), fontSize: 12),
              ),
              Text(
                '40+',
                style: TextStyle(color: Color(0xFFAAA5A0), fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        Text(
          'Period Duration',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${controller.periodDuration.value} ',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE8927C),
                    fontFamily: 'Georgia',
                  ),
                ),
                const TextSpan(
                  text: 'days',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFE8927C),
                    fontFamily: 'Georgia',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildCustomSlider(
          value: controller.periodDuration.value.toDouble().clamp(1.0, 10.0),
          min: 1,
          max: 10,
          onChanged: (v) {
            controller.periodDuration.value = v.toInt();
          },
          onChangeEnd: (v) {
            controller.updateCycleData();
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '1',
                style: TextStyle(color: Color(0xFFAAA5A0), fontSize: 12),
              ),
              Text(
                '3',
                style: TextStyle(color: Color(0xFFAAA5A0), fontSize: 12),
              ),
              Text(
                '5',
                style: TextStyle(color: Color(0xFFAAA5A0), fontSize: 12),
              ),
              Text(
                '7',
                style: TextStyle(color: Color(0xFFAAA5A0), fontSize: 12),
              ),
              Text(
                '10',
                style: TextStyle(color: Color(0xFFAAA5A0), fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        Text(
          'Last Period Start Date',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _selectStartDate(context),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: boxBgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: boxBorderColor, width: 1),
                  ),
                  child: Text(
                    '${controller.lastPeriodDay.value}',
                    style: TextStyle(fontSize: 16, color: boxTextColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: boxBgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: boxBorderColor, width: 1),
                  ),
                  child: Text(
                    controller.lastPeriodMonth.value,
                    style: TextStyle(fontSize: 16, color: boxTextColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: boxBgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: boxBorderColor, width: 1),
                  ),
                  child: Text(
                    '${controller.lastPeriodYear.value}',
                    style: TextStyle(fontSize: 16, color: boxTextColor),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCustomSlider({
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    ValueChanged<double>? onChangeEnd,
  }) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 6,
        activeTrackColor: const Color(0xFFE8927C),
        inactiveTrackColor: const Color(0xFFDCDCE2),
        thumbColor: const Color(0xFF7B8089),
        overlayColor: const Color(0xFFE8927C).withValues(alpha: 0.1),
        thumbShape: _CustomThumbShape(),
        trackShape: const RoundedRectSliderTrackShape(),
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        onChanged: onChanged,
        onChangeEnd: onChangeEnd,
      ),
    );
  }

  Widget _buildSubscriptionCard(bool isDark) {
    final authController = Get.find<AuthController>();
    return Obx(() {
      final user = authController.currentUser.value;

      final sub = user?.subscription;
      final bool hasPaidSubscription = user?.isPaidSubscriptionActive ?? false;
      final bool isTrial = user?.isTrialStrictlyActive ?? false;

      // Extract plan type/name (checking type, plan, productId)
      final type = sub?['type']?.toString().toLowerCase() ?? '';
      final plan = sub?['plan']?.toString().toLowerCase() ?? '';
      final productId = sub?['productId']?.toString().toLowerCase() ?? '';
      
      final planIdentifier = type.isNotEmpty ? type : (plan.isNotEmpty ? plan : productId);

      String activePlanName = 'Premium Subscription';
      String statusSubtitle = 'Status: Active · All Features Unlocked';
      String? durationText;
      String? expirationDateFormatted;

      // Extract expiration/renewal date (checking endDate, expiresAt, etc.)
      final rawExpiresAt =
          sub?['endDate'] ??
          sub?['expiresAt'] ??
          sub?['currentPeriodEnd'] ??
          sub?['expiryDate'] ??
          sub?['expirationDate'] ??
          user?.trialExpiresAt;

      if (rawExpiresAt != null && rawExpiresAt.toString().isNotEmpty) {
        try {
          final dt = DateTime.parse(rawExpiresAt.toString());
          expirationDateFormatted = DateFormat('dd MMM yyyy').format(dt);
        } catch (_) {}
      }

      if (hasPaidSubscription) {
        if (planIdentifier.contains('annual') || planIdentifier.contains('year')) {
          activePlanName = 'Annual Premium Plan';
          durationText = '1 Year Access (Auto-Renewing)';
        } else if (planIdentifier.contains('monthly') || planIdentifier.contains('month')) {
          activePlanName = 'Monthly Premium Plan';
          durationText = '1 Month Access (Auto-Renewing)';
        } else if (planIdentifier.isNotEmpty) {
          activePlanName = '${planIdentifier.capitalizeFirst} Plan';
          durationText = 'Premium Subscription';
        }

        if (expirationDateFormatted != null) {
          statusSubtitle = 'Renews on: $expirationDateFormatted';
        } else {
          statusSubtitle = 'Status: Active Subscription · Auto-Renewing';
        }
      } else if (isTrial) {
        activePlanName = '7-Day Free Trial';
        durationText = '7 Days Free Trial Access';
        if (user?.trialExpiresAt != null && user!.trialExpiresAt!.isNotEmpty) {
          try {
            final expires = DateTime.parse(user.trialExpiresAt!);
            final daysLeft = expires.difference(DateTime.now()).inDays;
            if (daysLeft > 0) {
              statusSubtitle =
                  'Trial Active · $daysLeft days remaining (Ends: $expirationDateFormatted)';
            } else {
              statusSubtitle = 'Trial Active · Ends today';
            }
          } catch (_) {
            statusSubtitle = 'Trial Active · Premium Unlocked';
          }
        } else {
          statusSubtitle = 'Trial Active · Premium Unlocked';
        }
      }

      return Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  colors: [Color(0xFFE8927C), Color(0xFFA687C6)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        hasPaidSubscription
                            ? 'Active Subscription'
                            : (isTrial
                                  ? 'Free Trial Active'
                                  : 'Premium Cycle Insights'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (hasPaidSubscription) ...[
              // Active paid subscription display (Purchased plan card)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2C2C2C)
                            : AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE8927C).withOpacity(0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFE8927C),
                                      Color(0xFFA687C6),
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activePlanName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    if (durationText != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        durationText,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFFE8927C),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black26 : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 14,
                                  color: isDark
                                      ? Colors.white70
                                      : AppColors.accentGreen,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    statusSubtitle,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white70
                                          : AppColors.accentGreen,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildPremiumFeature(
                      'Advanced hormone trend charts',
                      isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildPremiumFeature(
                      'Phase-optimised workout plans',
                      isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildPremiumFeature('AI nutrition guidance', isDark),
                    const SizedBox(height: 10),
                    _buildPremiumFeature('Symptom pattern insights', isDark),
                  ],
                ),
              ),
            ] else ...[
              // Free trial banner or standard features list
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (isTrial) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2C2C2C)
                              : const Color(0xFFFFF4E5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE8927C).withOpacity(0.6),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFE8927C),
                                    Color(0xFFA687C6),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.stars_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activePlanName,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    statusSubtitle,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.orangeAccent
                                          : const Color(0xFFD97706),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    _buildPremiumFeature(
                      'Advanced hormone trend charts 15',
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildPremiumFeature(
                      'Phase-optimised workout plans',
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildPremiumFeature('AI nutrition guidance', isDark),
                    const SizedBox(height: 12),
                    _buildPremiumFeature('Symptom pattern insights', isDark),
                  ],
                ),
              ),
              // Selectable Pricing Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: _buildPricingCard(
                          planKey: 'annual',
                          title: 'Annual',
                          price: '£115.99',
                          suffix: '/year',
                          subtitle: '≈ £9.67/month · Save 19%',
                          isBestValue: true,
                          isDark: isDark,
                          isSelected: controller.selectedPlan.value == 'annual',
                          onTap: () => controller.selectedPlan.value = 'annual',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPricingCard(
                          planKey: 'monthly',
                          title: 'Monthly',
                          price: '£11.99',
                          suffix: '/month',
                          subtitle: '',
                          isBestValue: false,
                          isDark: isDark,
                          isSelected:
                              controller.selectedPlan.value == 'monthly',
                          onTap: () =>
                              controller.selectedPlan.value = 'monthly',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // CTA Button — navigates to PremiumScreen with selected plan
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () {
                    final premiumController = Get.find<PremiumController>();
                    final productId = controller.selectedPlan.value == 'annual'
                        ? 'com.herwellnessapp.annual'
                        : 'com.herwellnessapp.monthly';
                    premiumController.buyProduct(productId);
                  },
                  child: Obx(() {
                    final premiumController = Get.find<PremiumController>();
                    final isPurchasing = premiumController.purchasing.value;
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE8927C), Color(0xFFA687C6)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: isPurchasing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Subscribe Now',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Payment will be charged to your Apple ID account at the confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. You can manage and cancel your subscriptions by going to your account settings on the App Store after purchase.',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white54 : const Color(0xFF8B7355),
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                final premiumController = Get.find<PremiumController>();
                premiumController.restorePurchases();
              },
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Restore Purchases',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : const Color(0xFF3A2E28),
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () async {
                    final url = Uri.parse(
                      'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
                    );
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Terms of Use',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white54 : const Color(0xFF8B7355),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Text(
                  ' | ',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white54 : const Color(0xFF8B7355),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final url = Uri.parse(
                      'https://sites.google.com/view/herwallness/home',
                    );
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white54 : const Color(0xFF8B7355),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    });
  }

  Widget _buildPremiumFeature(String text, bool isDark) {
    return Row(
      children: [
        const Icon(Icons.check, color: Color(0xFFE8927C), size: 16),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white : const Color(0xFF3A2E28),
          ),
        ),
      ],
    );
  }

  Widget _buildPricingCard({
    required String planKey,
    required String title,
    required String price,
    required String suffix,
    required String subtitle,
    required bool isBestValue,
    required bool isDark,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? const Color(0xFF3B2F2A) : const Color(0xFFFAF5F0))
                  : isBestValue
                  ? (isDark ? const Color(0xFF3B2F2A) : const Color(0xFFFAF5F0))
                  : (isDark ? AppColors.darkSurfaceLight : Colors.white),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFE8927C)
                    : isBestValue
                    ? const Color(0xFFE8927C)
                    : (isDark
                          ? const Color(0xFF333333)
                          : const Color(0xFFE2D6C8)),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF3A2E28),
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: price,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF3A2E28),
                        ),
                      ),
                      TextSpan(
                        text: suffix,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF8B7355),
                        ),
                      ),
                    ],
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF8B7355),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (isSelected) ...[
                  const SizedBox(height: 6),
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFFE8927C),
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
          if (isBestValue)
            Positioned(
              top: -8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA687C6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Best Value',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildAppSettingItem(
            icon: Icons.light_mode_outlined,
            iconBgColor: isDark
                ? const Color(0xFF333333)
                : const Color(0xFFF3EFEA),
            iconColor: isDark ? Colors.white : const Color(0xFF3A2E28),
            title: 'Appearance',
            isToggle: true,
            isDark: isDark,
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? const Color(0xFF333333) : const Color(0xFFF6F3F0),
          ),
          _buildAppSettingItem(
            icon: Icons.notifications_outlined,
            iconBgColor: isDark
                ? const Color(0xFF4A2B24)
                : const Color(0xFFFFF0EC),
            iconColor: const Color(0xFFE8927C),
            title: 'Notifications',
            isToggle: true,
            isNotificationToggle: true,
            isDark: isDark,
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? const Color(0xFF333333) : const Color(0xFFF6F3F0),
          ),
          _buildAppSettingItem(
            icon: Icons.health_and_safety_outlined,
            iconBgColor: isDark
                ? const Color(0xFF2E4032)
                : const Color(0xFFE8F5E9),
            iconColor: const Color(0xFF4CAF50),
            title: 'Medical Disclaimer',
            isDark: isDark,
            onTap: () {
              Get.defaultDialog(
                title: 'Medical Disclaimer',
                titleStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF3A2E28),
                ),
                content: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    'The HerWellness app provides fitness and nutrition information for educational purposes only.\n\nIt is not intended to be a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of your physician or other qualified health provider with any questions you may have regarding a medical condition.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: isDark
                          ? Colors.white70
                          : const Color(0xFF3A2E28).withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                confirm: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text(
                    'I Understand',
                    style: TextStyle(
                      color: Color(0xFFE8927C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? const Color(0xFF333333) : const Color(0xFFF6F3F0),
          ),
          _buildAppSettingItem(
            icon: Icons.privacy_tip_outlined,
            iconBgColor: isDark
                ? const Color(0xFF3A2D4A)
                : const Color(0xFFF4F0F9),
            iconColor: const Color(0xFFA687C6),
            title: 'Privacy Policy',
            isDark: isDark,
            onTap: () async {
              final Uri url = Uri.parse(
                'https://sites.google.com/view/herwallness/home',
              );
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? const Color(0xFF333333) : const Color(0xFFF6F3F0),
          ),
          _buildAppSettingItem(
            icon: Icons.description_outlined,
            iconBgColor: isDark
                ? const Color(0xFF2C3E50)
                : const Color(0xFFEBF5FB),
            iconColor: const Color(0xFF3498DB),
            title: 'Terms of Use (EULA)',
            isDark: isDark,
            onTap: () async {
              final Uri url = Uri.parse(
                'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
              );
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettingItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    bool isToggle = false,
    bool isNotificationToggle = false,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF3A2E28),
                ),
              ),
            ),
            if (isToggle)
              Obx(
                () => Switch(
                  value: isNotificationToggle
                      ? controller.notificationsEnabled.value
                      : controller.isDarkMode.value,
                  onChanged: (val) {
                    if (isNotificationToggle) {
                      controller.toggleNotifications(val);
                    } else {
                      controller.isDarkMode.value = val;
                      Get.changeThemeMode(
                        val ? ThemeMode.dark : ThemeMode.light,
                      );
                    }
                  },
                  activeThumbColor: const Color(0xFFE8927C),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: const Color(0xFFE2D6C8),
                ),
              )
            else
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFC4B8AD),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton(bool isDark) {
    return InkWell(
      onTap: () {
        Get.put(AuthController()).logout();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout, color: Color(0xFFC0473A), size: 18),
            SizedBox(width: 8),
            Text(
              'Sign out',
              style: TextStyle(
                color: Color(0xFFC0473A),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(bool isDark) {
    return InkWell(
      onTap: () {
        Get.toNamed(AppRoute.deleteAccount);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF333333) : const Color(0xFFCDBEAE),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.delete_outline, color: Color(0xFFC0473A), size: 18),
            SizedBox(width: 8),
            Text(
              'Delete account',
              style: TextStyle(
                color: Color(0xFFC0473A),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper integration functions
  String getContraceptionLabel(String type) {
    switch (type) {
      case 'pill':
        return 'Combined Pill';
      case 'mirena':
        return 'Hormonal IUD';
      case 'implant':
        return 'Implant';
      case 'injection':
        return 'Injection';
      case 'mini':
        return 'Mini Pill';
      case 'none':
      default:
        return 'No hormonal contraception';
    }
  }

  void _showContraceptionPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Obx(() {
          final List<Map<String, dynamic>> options =
              controller.dbContraceptions.isNotEmpty
              ? controller.dbContraceptions
              : [
                  {'key': 'pill', 'title': 'Combined Pill', 'icon': '💊'},
                  {'key': 'mirena', 'title': 'Hormonal IUD', 'icon': '🔩'},
                  {'key': 'implant', 'title': 'Implant', 'icon': '📌'},
                  {'key': 'injection', 'title': 'Injection', 'icon': '💉'},
                  {'key': 'mini', 'title': 'Mini Pill', 'icon': '🔵'},
                  {
                    'key': 'none',
                    'title': 'No hormonal contraception',
                    'icon': '🌙',
                  },
                ];

          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Select Contraception Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3A2E28),
                  ),
                ),
                const Divider(),
                ...options.map((opt) {
                  final key = opt['key'] ?? '';
                  final title = opt['title'] ?? '';
                  final icon = opt['icon'] ?? '';
                  return ListTile(
                    leading: icon.isNotEmpty
                        ? Text(icon, style: const TextStyle(fontSize: 20))
                        : null,
                    title: Text(
                      title,
                      style: const TextStyle(color: Color(0xFF3A2E28)),
                    ),
                    trailing: controller.contraceptionType.value == key
                        ? const Icon(Icons.check, color: Color(0xFFE8927C))
                        : null,
                    onTap: () {
                      controller.updateContraceptionType(key);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final monthMap = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };
    final monthNum = monthMap[controller.lastPeriodMonth.value] ?? 1;
    final currentDate = DateTime(
      controller.lastPeriodYear.value,
      monthNum,
      controller.lastPeriodDay.value,
    );

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE8927C),
              onPrimary: Colors.white,
              onSurface: Color(0xFF3A2E28),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE8927C),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.lastPeriodDay.value = picked.day;
      controller.lastPeriodMonth.value = DateFormat('MMM').format(picked);
      controller.lastPeriodYear.value = picked.year;
      controller.updateCycleData();
    }
  }
}

class _CustomThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(20, 20);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Outer white border
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Inner thumb color
    final Paint thumbPaint = Paint()
      ..color = sliderTheme.thumbColor ?? const Color(0xFF7B8089)
      ..style = PaintingStyle.fill;

    // Shadow
    canvas.drawShadow(
      Path()..addOval(Rect.fromCircle(center: center, radius: 10)),
      Colors.black,
      2.0,
      true,
    );

    // Draw border
    canvas.drawCircle(center, 10, borderPaint);
    // Draw inner
    canvas.drawCircle(center, 7.5, thumbPaint);
  }
}
