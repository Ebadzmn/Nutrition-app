import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/workout_session_controller.dart';

class WorkoutSessionScreen extends StatefulWidget {
  const WorkoutSessionScreen({super.key});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  final TextEditingController notesController = TextEditingController();

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final WorkoutSessionController controller = Get.put(WorkoutSessionController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.grey : Colors.grey.shade600;

    final workout = Get.arguments as Map?;
    final workoutName = workout?['name'] ?? 'Endorphin Boost Walk/Jog';
    final workoutDurationStr = workout?['duration_mins']?.toString() ?? '30-45';

    return Scaffold(
      backgroundColor: const Color(0xFFF3EBE3), // Off-white warm background
      body: Obx(() {
        if (controller.isCompleted.value) {
          return _buildCompletionScreen(controller, workoutName, workoutDurationStr, isDark);
        } else {
          return _buildWorkoutScreen(controller, workoutName, workoutDurationStr, cardBgColor, textColor, hintColor, isDark);
        }
      }),
    );
  }

  Widget _buildWorkoutScreen(WorkoutSessionController controller, String workoutName, String workoutDurationStr, Color cardBgColor, Color textColor, Color hintColor, bool isDark) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 260,
          floating: false,
          pinned: true,
          backgroundColor: const Color(0xFFB58E6B), // Brownish header color
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                onPressed: () => Get.back(),
              ),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: const Color(0xFFB58E6B),
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workoutName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$workoutDurationStr min',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatsCard('Total Volume', '0 kg'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatsCard('vs Last Time', '0%'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Obx(
                  () => ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.exercises.length,
                    itemBuilder: (context, exIndex) {
                      final ex = controller.exercises[exIndex];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isDark ? [] : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  ex.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.play_circle_outline, color: Colors.redAccent, size: 20),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(flex: 1, child: Text('Set', style: TextStyle(color: hintColor, fontSize: 12))),
                                Expanded(flex: 3, child: Text('Weight (kg)', style: TextStyle(color: hintColor, fontSize: 12))),
                                Expanded(flex: 3, child: Text('Reps', style: TextStyle(color: hintColor, fontSize: 12))),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Obx(
                              () => Column(
                                children: List.generate(ex.sets.length, (setIndex) {
                                  final set = ex.sets[setIndex];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            '${setIndex + 1}',
                                            style: TextStyle(color: hintColor, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: _buildSessionInputField(
                                            set.weight.value.toString(),
                                            (val) {
                                              final parsed = double.tryParse(val) ?? 0.0;
                                              set.weight.value = parsed;
                                            },
                                            isDark,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          flex: 3,
                                          child: _buildSessionInputField(
                                            set.reps.value.toString(),
                                            (val) {
                                              final parsed = int.tryParse(val) ?? 0;
                                              set.reps.value = parsed;
                                            },
                                            isDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton.icon(
                                onPressed: () => controller.addSet(exIndex),
                                icon: Icon(Icons.add, size: 18, color: textColor),
                                label: Text(
                                  'Add Set',
                                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: isDark ? Colors.transparent : Colors.grey.withOpacity(0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.transparent),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                // Workout Notes Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isDark ? [] : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Workout Notes',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.transparent),
                        ),
                         child: TextField(
                          controller: notesController,
                          maxLines: 2,
                          style: TextStyle(color: textColor, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'How did this workout feel?',
                            hintStyle: TextStyle(color: hintColor, fontSize: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Complete Workout Button
                 SizedBox(
                  width: double.infinity,
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value ? () {} : () async {
                      final errorMessage = await controller.saveWorkoutSession(
                        workoutName: workoutName,
                        durationMinutes: double.tryParse(workoutDurationStr) ?? 35.0,
                        notes: notesController.text,
                      );
                      if (mounted) {
                        if (errorMessage != null && errorMessage != 'Loading') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8C735B), // Muted brown button
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      controller.isLoading.value ? 'Saving...' : 'Complete Workout',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  )),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionScreen(WorkoutSessionController controller, String workoutName, String workoutDurationStr, bool isDark) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Color(0xFFE8927C),
            ),
            const SizedBox(height: 24),
            Text(
              'Workout Complete!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF3A2E28),
              ),
            ),
            const SizedBox(height: 16),
            // Workout Summary Cards
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    workoutName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF3A2E28),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem('Duration', '$workoutDurationStr min', isDark),
                      _buildSummaryItem('Total Volume', controller.totalVolume.value, isDark),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Strava Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final url = Uri.parse('https://www.strava.com');
                  try {
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not open Strava'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error opening Strava: $e'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.link, color: Colors.white),
                label: const Text(
                  'Link Strava Activity',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFC5200), // Strava brand color
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Done Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: isDark ? Colors.white70 : const Color(0xFF8B7355)),
                ),
                child: Text(
                  'Done',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF3A2E28),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey : const Color(0xFF8B7355),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF3A2E28),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2), // Semi-transparent overlay on top of the brown header
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildSessionInputField(String initialValue, Function(String) onChanged, bool isDark) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.2) : Colors.transparent),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              controller: TextEditingController(text: initialValue == '0.0' || initialValue == '0' ? '' : initialValue),
              onChanged: onChanged,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.keyboard_arrow_up, color: isDark ? Colors.grey : Colors.grey.shade600, size: 14),
                Icon(Icons.keyboard_arrow_down, color: isDark ? Colors.grey : Colors.grey.shade600, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
