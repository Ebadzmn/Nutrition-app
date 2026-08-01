import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/network/api_client.dart';

class ExerciseSetModel {
  RxDouble weight;
  RxInt reps;
  ExerciseSetModel({required double weight, required int reps})
      : weight = weight.obs,
        reps = reps.obs;
}

class ExerciseModel {
  String name;
  RxList<ExerciseSetModel> sets;
  ExerciseModel({required this.name, required List<ExerciseSetModel> sets})
      : sets = sets.obs;
}

class WorkoutSessionController extends GetxController {
  final exercises = <ExerciseModel>[
    ExerciseModel(
      name: 'Walk',
      sets: [ExerciseSetModel(weight: 0.0, reps: 0)],
    ),
    ExerciseModel(
      name: 'Light Jog',
      sets: [ExerciseSetModel(weight: 0.0, reps: 0)],
    ),
  ].obs;

  final totalVolume = '0 kg'.obs;
  final vsLastTime = '0%'.obs;
  final isLoading = false.obs;
  final isCompleted = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map) {
      final workout = Get.arguments as Map;
      if (workout['exercises'] != null && workout['exercises'] is List) {
        exercises.clear();
        for (var ex in workout['exercises']) {
          final String name = ex['name'] ?? '';
          final List setsList = ex['sets'] ?? [];
          final setModels = <ExerciseSetModel>[];
          if (setsList.isEmpty) {
            setModels.add(ExerciseSetModel(weight: 0.0, reps: 0));
          } else {
            for (var set in setsList) {
              int repsVal = 0;
              final repsObj = set['reps'];
              if (repsObj != null) {
                if (repsObj is num) {
                  repsVal = repsObj.toInt();
                } else {
                  final match = RegExp(r'\d+').firstMatch(repsObj.toString());
                  if (match != null) {
                    repsVal = int.tryParse(match.group(0)!) ?? 0;
                  }
                }
              }
              setModels.add(ExerciseSetModel(weight: 0.0, reps: repsVal));
            }
          }
          exercises.add(ExerciseModel(name: name, sets: setModels));
        }
      }
    }
  }

  void addSet(int exerciseIndex) {
    final sets = exercises[exerciseIndex].sets;
    final lastSet = sets.isNotEmpty 
        ? sets.last 
        : ExerciseSetModel(weight: 0.0, reps: 0);
    sets.add(ExerciseSetModel(
      weight: lastSet.weight.value, 
      reps: lastSet.reps.value
    ));
  }

  Future<String?> saveWorkoutSession({
    required String workoutName,
    required double durationMinutes,
    required String notes,
  }) async {
    if (isLoading.value) return 'Loading';
    try {
      isLoading.value = true;
      final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Calculate total volume
      double volume = 0.0;
      for (var ex in exercises) {
        for (var set in ex.sets) {
          volume += set.weight.value * set.reps.value;
        }
      }
      totalVolume.value = '${volume.toStringAsFixed(1)} kg';

      // Map exercises list to JSON array
      final exercisesJson = exercises.map((ex) => {
        "name": ex.name,
        "sets": ex.sets.map((set) => {
          "weight": set.weight.value,
          "reps": set.reps.value,
        }).toList(),
      }).toList();

      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.post(
        '/workout/workout-sessions',
        data: {
          "workout_name": workoutName,
          "date": formattedDate,
          "duration_minutes": durationMinutes,
          "exercises": exercisesJson,
          "total_volume": volume,
          "notes": notes,
          "completed": true,
        },
      );

      if (response.isSuccess) {
        isCompleted.value = true;
        return null;
      } else {
        return response.message.isNotEmpty ? response.message : 'Failed to save workout';
      }
    } catch (e) {
      return 'An unexpected error occurred';
    } finally {
      isLoading.value = false;
    }
  }
}
