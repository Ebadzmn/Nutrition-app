import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/network/api_client.dart';
import '../../home/controller/home_controller.dart';

class SettingsController extends GetxController {
  final cycleLength = 28.obs;
  final periodDuration = 5.obs;

  final lastPeriodDay = 12.obs;
  final lastPeriodMonth = 'Jun'.obs;
  final lastPeriodYear = 2026.obs;

  final isDarkMode = false.obs;
  final notificationsEnabled = false.obs;
  final deviceToken = ''.obs;

  // Profile fields
  final username = ''.obs;
  final email = ''.obs;
  final name = ''.obs;
  final avatarUrl = ''.obs;
  final cycleDataId = ''.obs;
  final contraceptionType = 'none'.obs;
  final fitnessGoal = 'general_fitness'.obs;
  final isLoading = false.obs;

  // Dynamic onboarding options loaded from API
  final dbContraceptions = <Map<String, dynamic>>[].obs;
  final dbGoals = <Map<String, dynamic>>[].obs;

  // Subscription plan selection (used in settings subscription card)
  final selectedPlan = 'annual'.obs; // 'annual' | 'monthly'

  @override
  void onInit() {
    super.onInit();
    fetchProfileAndCycleData();
    fetchOnboardingOptions();
  }

  /// Loads contraception options and goal options from the backend.
  /// Uses the same /onboarding/options endpoint as the onboarding flow.
  Future<void> fetchOnboardingOptions() async {
    try {
      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.get('/onboarding/options');
      if (response.isSuccess && response.data != null) {
        final data = response.data['data'];
        if (data != null) {
          if (data['contraceptions'] != null) {
            dbContraceptions.value =
                List<Map<String, dynamic>>.from(data['contraceptions']);
          }
          if (data['goals'] != null) {
            dbGoals.value =
                List<Map<String, dynamic>>.from(data['goals']);
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to fetch onboarding options in settings: $e');
    }
  }

  Future<void> fetchProfileAndCycleData() async {
    try {
      isLoading.value = true;
      final ApiClient apiClient = Get.find<ApiClient>();

      // Fetch user profile info
      final userResponse = await apiClient.get('/auth/me');
      if (userResponse.isSuccess && userResponse.data != null) {
        username.value = userResponse.data['username'] ?? '';
        email.value = userResponse.data['email'] ?? '';
        name.value = userResponse.data['name'] ?? '';
        avatarUrl.value = userResponse.data['avatarUrl'] ?? '';
      }

      // Fetch cycle data
      final cycleResponse = await apiClient.get('/cycle/cycle-data');
      if (cycleResponse.isSuccess &&
          cycleResponse.data != null &&
          cycleResponse.data is List &&
          (cycleResponse.data as List).isNotEmpty) {
        final cycleData = cycleResponse.data[0];
        cycleDataId.value = cycleData['id'] ?? '';
        cycleLength.value = cycleData['cycle_length'] ?? 28;
        periodDuration.value = cycleData['period_length'] ?? 5;
        contraceptionType.value = cycleData['contraception_type'] ?? 'none';
        fitnessGoal.value = cycleData['fitness_goal'] ?? 'general_fitness';

        if (cycleData['cycle_start_date'] != null) {
          try {
            final parsedDate = DateTime.parse(cycleData['cycle_start_date']);
            lastPeriodDay.value = parsedDate.day;
            lastPeriodMonth.value = DateFormat('MMM').format(parsedDate);
            lastPeriodYear.value = parsedDate.year;
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint('Failed to fetch settings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCycleData() async {
    if (cycleDataId.value.isEmpty) return;
    try {
      final ApiClient apiClient = Get.find<ApiClient>();

      const monthMap = {
        'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
        'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
      };
      final monthNum = monthMap[lastPeriodMonth.value] ?? 1;
      final dateStr =
          '${lastPeriodYear.value}-${monthNum.toString().padLeft(2, '0')}-${lastPeriodDay.value.toString().padLeft(2, '0')}';

      final response = await apiClient.put(
        '/cycle/cycle-data/${cycleDataId.value}',
        data: {
          'cycle_length': cycleLength.value,
          'period_length': periodDuration.value,
          'cycle_start_date': dateStr,
        },
      );

      if (response.isSuccess) {
        Get.snackbar(
          'Success',
          'Cycle information updated successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
        );
        try {
          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().fetchCycleData();
          }
        } catch (_) {}
      } else {
        Get.snackbar(
          'Error',
          response.message.isNotEmpty
              ? response.message
              : 'Failed to update cycle data',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update cycle data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      debugPrint('Failed to update cycle data: $e');
    }
  }

  Future<void> updateFitnessGoal(String goalId) async {
    fitnessGoal.value = goalId;
    if (cycleDataId.value.isEmpty) return;
    try {
      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.put(
        '/cycle/cycle-data/${cycleDataId.value}',
        data: {'fitness_goal': goalId},
      );
      if (response.isSuccess) {
        Get.snackbar(
          'Success',
          'Fitness goal updated successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
        );
        try {
          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().fetchCycleData();
          }
        } catch (_) {}
      } else {
        Get.snackbar(
          'Error',
          response.message.isNotEmpty
              ? response.message
              : 'Failed to update fitness goal',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update fitness goal: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      debugPrint('Failed to update fitness goal: $e');
    }
  }

  Future<void> updateContraceptionType(String value) async {
    contraceptionType.value = value;
    if (cycleDataId.value.isEmpty) return;
    try {
      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.put(
        '/cycle/cycle-data/${cycleDataId.value}',
        data: {'contraception_type': value},
      );
      if (response.isSuccess) {
        try {
          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().fetchCycleData();
          }
        } catch (_) {}
      } else {
        Get.snackbar(
          'Error',
          response.message.isNotEmpty
              ? response.message
              : 'Failed to update contraception type',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Failed to update contraception type: $e');
    }
  }

  Future<void> toggleNotifications(bool value) async {
    notificationsEnabled.value = value;
    if (value) {
      // TODO: Implement Twinr push token fetch here
      // For now, just show a snackbar
      Get.snackbar(
        'Notifications',
        'Notifications enabled',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Notifications',
        'Notifications disabled',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey.withOpacity(0.9),
        colorText: Colors.white,
      );
    }
  }
}
