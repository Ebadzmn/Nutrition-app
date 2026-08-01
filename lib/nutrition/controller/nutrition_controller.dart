import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';

class NutritionController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  var isLoading = false.obs;
  var isSaving = false.obs;

  var foods = <dynamic>[].obs;
  var recipes = <dynamic>[].obs;

  // Profile properties
  var profileId = ''.obs;
  var weight = 70.0.obs;
  var height = 165.0.obs;
  var age = 25.obs;
  var activityLevel = 'moderately_active'.obs;
  var dietaryPreferences = 'none'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNutritionData();
  }

  Future<void> fetchNutritionData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        _fetchFoods(),
        _fetchRecipes(),
        _fetchProfile(),
      ]);
    } catch (e) {
      debugPrint("Error fetching nutrition data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchFoods() async {
    try {
      final response = await _apiClient.get('/nutrition/foods');
      if (response.isSuccess && response.data != null && response.data is List) {
        foods.assignAll(response.data);
      }
    } catch (e) {
      debugPrint("Error fetching foods: $e");
    }
  }

  Future<void> _fetchRecipes() async {
    try {
      final response = await _apiClient.get('/nutrition/recipes');
      if (response.isSuccess && response.data != null && response.data is List) {
        recipes.assignAll(response.data);
      }
    } catch (e) {
      debugPrint("Error fetching recipes: $e");
    }
  }

  Future<void> _fetchProfile() async {
    try {
      final response = await _apiClient.get('/profile');
      if (response.isSuccess && response.data != null) {
        final data = response.data;
        profileId.value = data['id']?.toString() ?? '';
        weight.value = (data['weight_kg'] as num?)?.toDouble() ?? 70.0;
        height.value = (data['height_cm'] as num?)?.toDouble() ?? 165.0;
        age.value = (data['age'] as num?)?.toInt() ?? 25;
        activityLevel.value = data['activity_level']?.toString() ?? 'moderately_active';
        dietaryPreferences.value = data['dietary_preferences']?.toString() ?? 'none';
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    }
  }

  Future<bool> saveUserProfile() async {
    try {
      isSaving.value = true;
      final payload = {
        'weight_kg': weight.value,
        'height_cm': height.value,
        'age': age.value,
        'activity_level': activityLevel.value,
        'dietary_preferences': dietaryPreferences.value,
      };

      final endpoint = profileId.value.isNotEmpty ? '/profile/${profileId.value}' : '/profile';
      final response = await _apiClient.put(endpoint, data: payload);

      if (response.isSuccess) {
        if (response.data != null && response.data['id'] != null) {
          profileId.value = response.data['id'].toString();
        }
        Get.snackbar(
          'Success',
          'Macros updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF8B7355),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.message ?? 'Failed to update macros',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[800],
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      debugPrint("Error saving profile: $e");
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[800],
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isSaving.value = false;
    }
    return false;
  }
}
