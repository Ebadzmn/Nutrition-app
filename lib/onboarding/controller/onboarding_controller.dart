import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_route.dart';
import '../../core/network/api_client.dart';
import 'dart:io';
import 'package:dio/dio.dart' as dio;

class OnboardingController extends GetxController {
  var currentStep = 1.obs;
  final int totalSteps = 8;

  // UI State
  final isLoading = RxBool(false);
  final isOptionsLoading = RxBool(true);

  // Auth Data (Local UI only)
  final email = RxString('');
  final password = RxString('');

  // Form Data
  final profilePicture = RxnString();
  final contraception = RxnString();
  final pillType = RxnString();
  final pillProgestogen = RxnString();
  final pillFreeWeek = RxnBool(true);
  final iudPeriod = RxnString();
  final iudOvulating = Rxn<dynamic>();
  final implantBleed = RxnString();
  final implantPattern = RxnBool();
  final injectionBleed = RxnString();
  final miniType = RxnString();
  final miniOvulating = RxnBool();

  final cycleRegular = RxBool(true);
  final alreadyTracking = RxnString();
  final cycleLength = RxInt(28);
  final periodLength = RxInt(5);
  final lastDay = RxnInt();
  final lastMonth = RxnInt();
  final lastYear = RxnInt(DateTime.now().year);

  final trackingMethod = RxnString();
  // dailyCheckins stores the full label strings (which match what the backend expects)
  final dailyCheckins = <String>[].obs;
  final selectedSymptoms = <String>[].obs;
  final fitnessGoal = RxString('');

  // Dynamic backend-seeded options
  final dbContraceptions = <Map<String, dynamic>>[].obs;
  // contraception detail options keyed by contraceptionKey
  final dbDetails = <Map<String, dynamic>>[].obs;
  final dbGoals = <Map<String, dynamic>>[].obs;
  final dbSymptoms = <String>[].obs;
  final dbDailyCheckins = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadOnboardingOptions();
  }

  Future<void> loadOnboardingOptions() async {
    try {
      isOptionsLoading.value = true;
      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.get('/onboarding/options');
      if (response.isSuccess && response.data != null) {
        final rawResponse = response.data;
        final data = rawResponse['data'];
        if (data != null) {
          if (data['contraceptions'] != null) {
            dbContraceptions.value =
                List<Map<String, dynamic>>.from(data['contraceptions']);
          }

          // Store contraception detail options
          if (data['details'] != null) {
            dbDetails.value =
                List<Map<String, dynamic>>.from(data['details']);
          }

          if (data['goals'] != null) {
            dbGoals.value =
                List<Map<String, dynamic>>.from(data['goals']);
            // Pre-select the first goal if none is set yet
            if (fitnessGoal.value.isEmpty && dbGoals.isNotEmpty) {
              fitnessGoal.value = dbGoals.first['value']?.toString() ?? 'build_muscle';
            }
          }

          if (data['symptoms'] != null) {
            dbSymptoms.value = List<String>.from(
                (data['symptoms'] as List).map((s) => s['name'] as String));
          }

          if (data['checkins'] != null) {
            dbDailyCheckins.value =
                List<Map<String, dynamic>>.from(data['checkins']);
            // Pre-select check-ins that are marked as default in the API
            if (dailyCheckins.isEmpty) {
              dailyCheckins.value = dbDailyCheckins
                  .where((c) => c['isDefault'] == true)
                  .map((c) => c['label'].toString())
                  .toList();
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Failed to load onboarding options: $e");
    } finally {
      isOptionsLoading.value = false;
    }
  }

  /// Returns detail options for the currently selected contraception key,
  /// grouped by questionKey.
  Map<String, List<Map<String, dynamic>>> getDetailOptionsForCurrentContraception() {
    final key = contraception.value;
    if (key == null || dbDetails.isEmpty) return {};

    final filtered = dbDetails.where((d) => d['contraceptionKey'] == key).toList();
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final d in filtered) {
      final qKey = d['questionKey'].toString();
      grouped.putIfAbsent(qKey, () => []).add(d);
    }
    return grouped;
  }

  void nextStep() {
    if (currentStep.value < totalSteps) {
      currentStep.value++;
    } else {
      completeOnboarding();
    }
  }

  void prevStep() {
    if (currentStep.value > 1) {
      currentStep.value--;
    }
  }

  Future<void> completeOnboarding() async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;

      final ApiClient apiClient = Get.find<ApiClient>();

      // 1. Upload profile photo if chosen
      String? avatarUrl;
      if (profilePicture.value != null && profilePicture.value!.isNotEmpty) {
        try {
          final file = File(profilePicture.value!);
          if (await file.exists()) {
            final fileName = file.path.split('/').last;
            final formData = dio.FormData.fromMap({
              'file': await dio.MultipartFile.fromFile(file.path,
                  filename: fileName),
            });
            final uploadResponse = await apiClient.post(
              '/integration/files/upload',
              data: formData,
            );
            if (uploadResponse.isSuccess && uploadResponse.data != null) {
              avatarUrl = uploadResponse.data['file_url'];
            }
          }
        } catch (e) {
          debugPrint("Failed to upload profile picture: $e");
        }
      }

      // 2. Update user profile with avatar URL if uploaded
      if (avatarUrl != null) {
        try {
          await apiClient.put('/auth/me', data: {"avatarUrl": avatarUrl});
        } catch (e) {
          debugPrint("Failed to update avatarUrl on user: $e");
        }
      }

      final now = DateTime.now();
      final year = lastYear.value ?? now.year;
      final month = lastMonth.value ?? now.month;
      final day = lastDay.value ?? now.day;
      final startDateStr =
          "${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";

      final response = await apiClient.post(
        '/cycle/cycle-data',
        data: {
          "cycle_start_date": startDateStr,
          "cycle_length": cycleLength.value,
          "period_length": periodLength.value,
          "fitness_goal": fitnessGoal.value.isNotEmpty ? fitnessGoal.value : 'build_muscle',
          "contraception_type": contraception.value ?? "none",
          "tracking_method": trackingMethod.value ?? (canUseCalendar ? "calendar" : "subjective"),
          "pill_progestogen": pillProgestogen.value,
          "cycle_regular": cycleRegular.value,
          "symptoms": selectedSymptoms.toList(),
          // Send full label strings — these match what the backend stores
          "daily_checkins": dailyCheckins.toList(),
          "preferred_workout_types": [],
          "available_equipment": [],
        },
      );

      if (response.isSuccess) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('hasCompletedOnboarding', true);
        Get.offAllNamed(AppRoute.navbar);
      } else {
        Get.snackbar(
          'Error',
          response.message.isNotEmpty
              ? response.message
              : 'Failed to save onboarding data',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred during onboarding completion',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void toggleSymptom(String symptom) {
    if (selectedSymptoms.contains(symptom)) {
      selectedSymptoms.remove(symptom);
    } else {
      selectedSymptoms.add(symptom);
    }
  }

  int getPhaseNumber() {
    return 1;
  }

  bool get canUseCalendar {
    final c = contraception.value;
    if (c == 'none') return true;
    if (c == 'mirena' && iudOvulating.value != false && iudOvulating.value != 'false') return true;
    if (c == 'mini' && miniOvulating.value == true) return true;
    return false;
  }

  bool get canUseBBT {
    final c = contraception.value;
    return c == 'none' || c == 'mirena';
  }
}
