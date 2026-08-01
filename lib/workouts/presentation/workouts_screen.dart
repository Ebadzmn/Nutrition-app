import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../core/app_colors.dart';
import '../../core/app_route.dart';
import '../controller/workouts_controller.dart';
import '../../home/controller/home_controller.dart';

import '../../nav_bar/navbar_controller.dart';

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WorkoutsController());
    final homeController = Get.find<HomeController>();
    final navBox = Get.find<NavbarController>();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF5F3F0),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark ? [
                    const Color(0xFF2C2C2C),
                    const Color(0xFF1E1E1E),
                    const Color(0xFF121212),
                  ] : [
                    const Color(0xFFE5D9CF),
                    const Color(0xFFD4C5B9),
                    const Color(0xFFC4B5A9),
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => navBox.changePage(0),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_back_rounded,
                                color: isDark ? Colors.white : const Color(0xFF3A2E28),
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Workouts',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF3A2E28),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Phase Info Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Obx(() {
                          final phaseNum = homeController.getPhaseNumber();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Phase $phaseNum • Day ${homeController.cycleDay.value}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.white70 : const Color(
                                          0xFF3A2E28,
                                        ).withOpacity(0.6),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'GENERAL FITNESS',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : const Color(0xFF3A2E28),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getPhaseTitle(phaseNum),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF3A2E28),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _getPhaseDesc(phaseNum),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white70 : const Color(
                                    0xFF3A2E28,
                                  ).withOpacity(0.7),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                      const SizedBox(height: 16),

                      // Filters
                      Row(
                        children: [
                          Expanded(
                            child: _buildFilterTrigger(
                              'Intensity',
                              controller.selectedIntensity,
                              controller.intensities
                                  .map((i) => {'v': i, 'l': i.capitalizeFirst!})
                                  .toList(),
                              context,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildFilterTrigger(
                              'Duration',
                              controller.selectedDuration,
                              controller.durations
                                  .map(
                                    (d) => {'v': d['value'], 'l': d['label']},
                                  )
                                  .toList(),
                              context,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildFilterTrigger(
                              'Body part',
                              controller.selectedBodypart,
                              controller.bodyparts
                                  .map(
                                    (b) => {
                                      'v': b,
                                      'l': b == 'all'
                                          ? 'Body part'
                                          : b.capitalizeFirst!,
                                    },
                                  )
                                  .toList(),
                              context,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildTabButton(
                      0,
                      'Browse',
                      Icons.fitness_center_rounded,
                      controller,
                    ),
                    _buildTabButton(
                      1,
                      'AI Coach',
                      Icons.auto_awesome_rounded,
                      controller,
                    ),
                    _buildTabButton(
                      2,
                      'Saved',
                      Icons.bookmark_rounded,
                      controller,
                    ),
                  ],
                ),
              ),
            ),

            // Content Section
            Obx(() {
              if (controller.selectedTab.value == 0) {
                return _buildBrowseTab(controller, homeController);
              } else if (controller.selectedTab.value == 1) {
                return _buildAICoachTab();
              } else {
                return _buildSavedTab(controller);
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTrigger(
    String label,
    RxString value,
    List<Map<String, dynamic>> options,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _showFilterBottomSheet(label, value, options, context),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Obx(() {
                final match = options
                    .where((o) => o['v'] == value.value)
                    .toList();
                final selectedOption = match.isNotEmpty
                    ? match.first
                    : options.first;
                return Text(
                  selectedOption['l'],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF3A2E28),
                  ),
                  overflow: TextOverflow.ellipsis,
                );
              }),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isDark ? Colors.white : const Color(0xFF3A2E28),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(
    String label,
    RxString value,
    List<Map<String, dynamic>> options,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final opt = options[index];
                  return Obx(() {
                    final isSelected = value.value == opt['v'];
                    return ListTile(
                      onTap: () {
                        value.value = opt['v'];
                        Navigator.pop(context);
                      },
                      title: Text(
                        opt['l'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? AppColors.accent
                              : (isDark ? Colors.white : AppColors.textPrimary),
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              color: AppColors.accent,
                            )
                          : null,
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(
    int index,
    String label,
    IconData icon,
    WorkoutsController controller,
  ) {
    return Obx(() {
      final isSelected = controller.selectedTab.value == index;
      return Expanded(
        child: GestureDetector(
          onTap: () => controller.changeTab(index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF8B7355) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Get.isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? Colors.white : (Get.isDarkMode ? Colors.white70 : const Color(0xFF5C4A3A)),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : (Get.isDarkMode ? Colors.white70 : const Color(0xFF5C4A3A)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  String _getPhaseTitle(int phase) {
    switch (phase) {
      case 1:
        return "Rest & Recover";
      case 2:
        return "Building Energy";
      case 3:
        return "Peak Performance";
      case 4:
        return "Wind Down";
      default:
        return "";
    }
  }

  String _getPhaseDesc(int phase) {
    switch (phase) {
      case 1:
        return "Low-intensity to support your body during menstruation";
      case 2:
        return "Gradually increase intensity as energy rises";
      case 3:
        return "Your body is primed for high-intensity training";
      case 4:
        return "Moderate intensity as you prepare for your next cycle";
      default:
        return "";
    }
  }

  Widget _buildBrowseTab(
    WorkoutsController controller,
    HomeController homeController,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Workout count and reset
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Workouts for your phase',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => controller.fetchWorkouts(),
                    child: const Text(
                      'Refresh',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8B7355),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.selectedIntensity.value = 'all';
                      controller.selectedDuration.value = 'all';
                      controller.selectedBodypart.value = 'all';
                    },
                    child: const Text(
                      'Reset filters',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8B7355),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Workouts list
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(color: Color(0xFF8B7355)),
                ),
              );
            }
            final allWO = controller.allWorkouts;
            final list = controller.filteredWorkouts;
            
            if (allWO.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text(
                        'No workouts loaded.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => controller.fetchWorkouts(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B7355),
                        ),
                        child: const Text('Load Workouts', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            if (list.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'No workouts match your filters for this phase.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildWebStyleWorkoutCard(
                  context: context,
                  workout: list[index],
                  controller: controller,
                );
              },
            );
          }),

          const SizedBox(height: 22),

          // Library Link
          GestureDetector(
            onTap: () => Get.toNamed(AppRoute.workoutLibrary),
            child: _buildActionCard(
              'Explore all 100+ workouts',
              'Open Workout Library',
              AppRoute.workoutLibrary,
              isDashed: true,
              gradient: true,
            ),
          ),
          const SizedBox(height: 12),

          // Settings Link
          GestureDetector(
            onTap: () {
              final NavbarController navBox = Get.find<NavbarController>();
              navBox.changePage(4); // Navigate to Settings tab
            },
            child: _buildActionCard(
              'Want different workouts?',
              'Update your fitness goal',
              '/Settings',
              isDashed: true,
            ),
          ),

          // Strava Button
          const SizedBox(height: 24),
          _buildStravaSection(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _showWorkoutDetail(
    BuildContext context,
    Map<String, dynamic> workout,
  ) {
    final title = workout['name'] ?? '';
    final desc = workout['desc'] ?? '';
    final intensity = workout['intensity'] ?? 'low';
    final phaseNote = workout['phaseNote'] ?? 'A restorative sequence designed for your cycle.';
    final List exercisesList = workout['exercises'] ?? [];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFF1A1A1A), // Black theme
        child: Container(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PHASE NOTE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB8860B),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        phaseNote,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8B7355),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Exercises',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                if (exercisesList.isEmpty)
                  const Text('No exercises registered for this workout.', style: TextStyle(color: Colors.white70))
                else
                  ...exercisesList.map((ex) {
                    final exName = ex['name'] ?? '';
                    final setsList = List.from(ex['sets'] ?? []);
                    final setsDesc = setsList.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final setObj = entry.value;
                      return 'Set ${idx + 1}: ${setObj['reps']}';
                    }).join('\n');
                    return _buildExerciseItem(
                      exName,
                      '${setsList.length} sets',
                      setsDesc,
                    );
                  }).toList(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Get.toNamed(AppRoute.workoutSession, arguments: workout);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B7355),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Start Workout',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseItem(String name, String sets, String details) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2420),
                ),
              ),
              Text(
                sets,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            details,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebStyleWorkoutCard({
    required BuildContext context,
    required Map<String, dynamic> workout,
    required WorkoutsController controller,
  }) {
    final title = workout['name'] ?? '';
    final duration = workout['duration_mins']?.toString() ?? '0';
    final intensity = workout['intensity'] ?? 'low';
    final bodypart = workout['bodypart'] ?? 'full body';
    final equipment = workout['equipment'] ?? 'None';
    final desc = workout['desc'] ?? '';
    final workoutId = workout['id']?.toString() ?? '';

    Color intBg;
    Color intText;
    switch (intensity) {
      case 'low':
        intBg = const Color(0x263CB87A);
        intText = const Color(0xFF3CB87A);
        break;
      case 'moderate':
        intBg = const Color(0x26D4B84A);
        intText = const Color(0xFFD4B84A);
        break;
      case 'high':
        intBg = const Color(0x26E05C4B);
        intText = const Color(0xFFE05C4B);
        break;
      default:
        intBg = Colors.grey.withOpacity(0.15);
        intText = Colors.grey;
    }

    return GestureDetector(
      onTap: () => _showWorkoutDetail(
        context,
        workout,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Get.isDarkMode ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Get.isDarkMode ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFFC4B5A9),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Get.isDarkMode ? Colors.white : const Color(0xFF2D2420),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: intBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          intensity,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: intText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Get.isDarkMode ? Colors.white54 : Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _buildInfoItem(
                              Icons.access_time_rounded,
                              '$duration min',
                            ),
                            _buildInfoItem(Icons.track_changes_rounded, bodypart),
                            _buildInfoItem(Icons.inventory_2_outlined, equipment),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => controller.toggleSaveWorkout(workoutId),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Get.isDarkMode ? const Color(0xFF333333) : const Color(0xFFF5F3F0),
                                shape: BoxShape.circle,
                              ),
                              child: Obx(() => Icon(
                                controller.savedWorkoutIds.contains(workoutId)
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                size: 18,
                                color: Get.isDarkMode ? Colors.white : const Color(0xFF5C4A3A),
                              )),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildIconButton(
                            Icons.fitness_center_rounded,
                            isFilled: true,
                            onTap: () => _showWorkoutDetail(
                              context,
                              workout,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: Get.isDarkMode ? Colors.white70 : Colors.black),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(fontSize: 11, color: Get.isDarkMode ? Colors.white70 : Colors.black),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton(
    IconData icon, {
    bool isFilled = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Get.isDarkMode ? const Color(0xFF333333) : const Color(0xFFF5F3F0),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Get.isDarkMode ? Colors.white : const Color(0xFF5C4A3A)),
      ),
    );
  }

  Widget _buildActionCard(
    String text,
    String subtext,
    String route, {
    bool isDashed = false,
    bool gradient = false,
  }) {
    final bgColor = gradient ? (Get.isDarkMode ? AppColors.darkSurface : const Color(0xFFEFE8DE)) : (Get.isDarkMode ? AppColors.darkSurfaceLight : Colors.white);
    final borderColor = gradient
        ? (Get.isDarkMode ? AppColors.darkSurface : const Color(0xFFD4C5B9))
        : (Get.isDarkMode ? const Color(0xFF333333) : const Color(0xFFE2E8F0));

    Widget content = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(fontSize: 14, color: Get.isDarkMode ? Colors.white70 : const Color(0xFF4F5962)),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                subtext,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8A6B4E),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF8A6B4E),
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );

    if (isDashed) {
      return DottedBorder(
        options: RoundedRectDottedBorderOptions(
          radius: const Radius.circular(16),
          color: borderColor,
          strokeWidth: 1.5,
          dashPattern: const [6, 4],
          padding: EdgeInsets.zero,
        ),
        child: content,
      );
    }

    return content;
  }

  Widget _buildStravaSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Get.isDarkMode ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFC4C02),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'S',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Strava Activities',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2420),
                ),
              ),
            ],
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  Widget _buildAICoachTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7DD3C0), Color(0xFF5BA89D)],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 20),
                const Text(
                  'AI Fitness Coach',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Personalized training plans that adapt to your menstrual cycle and fitness goals.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Get.toNamed(AppRoute.aiCoachChat),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF5BA89D),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Start Conversation',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSavedTab(WorkoutsController controller) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Obx(() {
        final savedWorkouts = controller.allWorkouts
            .where((w) => controller.savedWorkoutIds.contains(w['id'].toString()))
            .toList();

        if (savedWorkouts.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Icon(
                Icons.bookmark_outline_rounded,
                size: 80,
                color: Colors.grey[200],
              ),
              const SizedBox(height: 24),
              const Text(
                'No Saved Workouts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Workouts you save will appear here for quick access.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey[400]),
              ),
            ],
          );
        }

        final listWidget = ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: savedWorkouts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildWebStyleWorkoutCard(
              context: context,
              workout: savedWorkouts[index],
              controller: controller,
            );
          },
        );
        
        return Column(
          children: [
            listWidget,
            const SizedBox(height: 100),
          ],
        );
      }),
    );
  }
}
