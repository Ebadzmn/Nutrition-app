import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';
import '../../home/controller/home_controller.dart';

class WorkoutsController extends GetxController {
  var selectedTab = 0.obs;
  var selectedIntensity = 'all'.obs;
  var selectedDuration = 'all'.obs;
  var selectedBodypart = 'all'.obs;

  var allWorkouts = <dynamic>[].obs;
  var isLoading = false.obs;
  var savedWorkoutIds = <String>[].obs;

  final intensities = ['all', 'low', 'moderate', 'high'];
  final durations = [
    {'value': 'all', 'label': 'Any duration'},
    {'value': '15-30', 'label': '15–30 min'},
    {'value': '30-45', 'label': '30–45 min'},
    {'value': '45-60', 'label': '45–60 min'},
    {'value': '60+', 'label': '60+ min'},
  ];
  final bodyparts = ['all', 'full body', 'lower body', 'upper body', 'core', 'glutes', 'back', 'cardio', 'mobility'];

  @override
  void onInit() {
    super.onInit();
    _setDefaultsByPhase();
    fetchWorkouts();
    loadSavedWorkouts();
  }

  void _setDefaultsByPhase() {
    selectedIntensity.value = 'all';
  }

  Future<void> fetchWorkouts() async {
    try {
      isLoading.value = true;
      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.get('/workout/library');
      if (response.isSuccess && response.data != null && response.data is List) {
        debugPrint("✅ Fetched ${response.data.length} workouts");
        allWorkouts.assignAll(response.data);
      } else {
        debugPrint("❌ Fetch failed: no data or not a list");
      }
    } catch (e) {
      debugPrint("❌ Error fetching workouts: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSavedWorkouts() async {
    try {
      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.get('/workout/saved');
      if (response.isSuccess && response.data != null && response.data is List) {
        final List<dynamic> savedWorkouts = response.data;
        final ids = savedWorkouts.map((w) => w['id']?.toString() ?? '').where((id) => id.isNotEmpty).toList();
        savedWorkoutIds.assignAll(ids);
      }
    } catch (e) {
      debugPrint("Error loading saved workouts: $e");
    }
  }

  Future<void> toggleSaveWorkout(String workoutId) async {
    try {
      final ApiClient apiClient = Get.find<ApiClient>();
      if (savedWorkoutIds.contains(workoutId)) {
        final response = await apiClient.delete('/workout/saved/$workoutId');
        if (response.isSuccess) {
          savedWorkoutIds.remove(workoutId);
          Get.snackbar(
            'Success',
            'Workout removed from your collection!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF8B7355),
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
          );
        }
      } else {
        final response = await apiClient.post('/workout/saved', data: {'workoutId': workoutId});
        if (response.isSuccess) {
          savedWorkoutIds.add(workoutId);
          Get.snackbar(
            'Success',
            'Workout saved to your collection!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF8B7355),
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
          );
        }
      }
    } catch (e) {
      debugPrint("Error toggling saved workout: $e");
    }
  }

  String get currentPhaseKey {
    final homeController = Get.find<HomeController>();
    final phase = homeController.currentPhase.value.toLowerCase();
    if (phase.contains('menstruat')) return 'menstrual';
    if (phase.contains('follicular')) return 'follicular';
    if (phase.contains('ovulat')) return 'ovulatory';
    if (phase.contains('luteal')) return 'luteal';
    return 'all';
  }

  List<dynamic> get filteredWorkouts {
    final phaseKey = currentPhaseKey;
    debugPrint("🔍 Filtering: phase=$phaseKey, intensity=${selectedIntensity.value}, duration=${selectedDuration.value}, bodypart=${selectedBodypart.value}");
    debugPrint("📊 Total workouts: ${allWorkouts.length}");
    
    final filtered = allWorkouts.where((w) {
      // 1. Phase check
      final phases = List<String>.from(w['phase'] ?? []);
      if (!phases.contains(phaseKey) && !phases.contains('all')) {
        return false;
      }
      // 2. Intensity check
      if (selectedIntensity.value != 'all' && w['intensity'] != selectedIntensity.value) {
        return false;
      }
      // 3. Duration check
      if (selectedDuration.value != 'all' && w['duration'] != selectedDuration.value) {
        return false;
      }
      // 4. Bodypart check
      if (selectedBodypart.value != 'all' && w['bodypart'] != selectedBodypart.value) {
        return false;
      }
      return true;
    }).toList();
    
    debugPrint("✅ Filtered workouts: ${filtered.length}");
    return filtered;
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }
}
