import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import './symptom_logger_widget.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';
import '../../core/network/api_client.dart';
import '../controller/home_controller.dart';

class DailyLoggerWidget extends StatefulWidget {
  const DailyLoggerWidget({super.key});

  @override
  State<DailyLoggerWidget> createState() => _DailyLoggerWidgetState();
}

class _DailyLoggerWidgetState extends State<DailyLoggerWidget> {
  String? _selectedMood;
  final Set<String> _selectedCheckins = {};
  bool _isSaving = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _loadTodayLog();

    // Listen to date changes
    final homeController = Get.find<HomeController>();
    ever(homeController.selectedDate, (_) {
      _loadTodayLog();
    });
  }

  void _loadTodayLog() async {
    try {
      final homeController = Get.find<HomeController>();
      final formattedDate = DateFormat(
        'yyyy-MM-dd',
      ).format(homeController.selectedDate.value);
      final ApiClient apiClient = Get.find<ApiClient>();

      final response = await apiClient.get(
        '/cycle/daily-logs',
        queryParameters: {"date": formattedDate},
      );

      if (response.isSuccess &&
          response.data != null &&
          response.data is List &&
          (response.data as List).isNotEmpty) {
        final log = response.data[0];
        if (mounted) {
          setState(() {
            _selectedMood = log['mood'];
            _selectedCheckins.clear();
            if (log['checkins'] != null) {
              _selectedCheckins.addAll(List<String>.from(log['checkins']));
            }
            _isSaved = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _selectedMood = null;
            _selectedCheckins.clear();
            _isSaved = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Failed to load today's daily log: $e");
    }
  }

  final List<Map<String, dynamic>> _moods = [
    {'value': 'Tired', 'icon': Icons.battery_alert_rounded, 'label': 'Tired'},
    {'value': 'low', 'icon': Icons.cloud_rounded, 'label': 'Low'},
    {'value': 'okay', 'icon': Icons.remove_rounded, 'label': 'Okay'},
    {
      'value': 'good',
      'icon': Icons.sentiment_satisfied_alt_rounded,
      'label': 'Good',
    },
    {'value': 'amazing', 'icon': Icons.bolt_rounded, 'label': 'Amazing'},
  ];

  final List<Map<String, dynamic>> _checkins = [
    {
      'value': 'workout',
      'icon': Icons.fitness_center_rounded,
      'label': 'Workout',
    },
    {'value': 'walk', 'icon': Icons.directions_walk_rounded, 'label': 'Walk'},
    {
      'value': 'self_care',
      'icon': Icons.favorite_rounded,
      'label': 'Self Care',
    },
    {
      'value': 'drank_water',
      'icon': Icons.water_drop_rounded,
      'label': 'Water',
    },
    {'value': 'ate_well', 'icon': Icons.apple_rounded, 'label': 'Ate Well'},
    {'value': 'rest', 'icon': Icons.nightlight_rounded, 'label': 'Rest'},
  ];

  void _handleSave() async {
    setState(() => _isSaving = true);
    try {
      final homeController = Get.find<HomeController>();
      final formattedDate = DateFormat(
        'yyyy-MM-dd',
      ).format(homeController.selectedDate.value);

      final phaseNum = homeController.getPhaseNumber();
      const phaseMap = {
        1: 'menstrual',
        2: 'follicular',
        3: 'ovulatory',
        4: 'luteal',
      };
      final phase = phaseMap[phaseNum] ?? 'follicular';

      final cycleDay = homeController.cycleDay.value;

      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.post(
        '/cycle/daily-logs',
        data: {
          "date": formattedDate,
          "phase": phase,
          "cycle_day": cycleDay,
          "mood": _selectedMood,
          "checkins": _selectedCheckins.toList(),
          "notes": "",
        },
      );

      if (response.isSuccess) {
        // Refresh home controller logs
        homeController.fetchRecentLogs();

        if (mounted) {
          setState(() {
            _isSaving = false;
            _isSaved = true;
          });
          Get.snackbar(
            'Success',
            'Today\'s check-in has been updated',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green[800],
          );
        }
      } else {
        if (mounted) {
          setState(() => _isSaving = false);
        }
        Get.snackbar(
          'Error',
          response.message.isNotEmpty
              ? response.message
              : 'Failed to update check-in',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
      }
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3EFEA);
    final titleColor = isDark ? Colors.white : const Color(0xFF3A2E28);
    final itemBgColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final itemBorderColor = isDark
        ? const Color(0xFF3A3A3A)
        : const Color(0xFFE2D6C8);
    final unselectedIconColor = isDark
        ? Colors.grey[400]
        : const Color(0xFF5A4D42);
    final selectedColor = const Color(0xFFE8927C);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Check-in",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 16),

          // Mood Section
          _buildSectionLabel("HOW ARE YOU FEELING?", isDark),
          const SizedBox(height: 12),
          Row(
            children: _moods.map((mood) {
              final isSelected = _selectedMood == mood['value'];
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () => setState(
                      () => _selectedMood = isSelected ? null : mood['value'],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 65,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? selectedColor.withOpacity(0.1)
                            : itemBgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? selectedColor : itemBorderColor,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            mood['icon'],
                            color: isSelected
                                ? selectedColor
                                : unselectedIconColor,
                            size: 20,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            mood['label'],
                            style: TextStyle(
                              fontSize: 9,
                              color: isSelected
                                  ? selectedColor
                                  : unselectedIconColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Check-ins Section
          _buildSectionLabel("WHAT DID YOU DO TODAY?", isDark),
          const SizedBox(height: 12),
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _checkins.length,
            itemBuilder: (context, index) {
              final checkin = _checkins[index];
              final isSelected = _selectedCheckins.contains(checkin['value']);
              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedCheckins.remove(checkin['value']);
                    } else {
                      _selectedCheckins.add(checkin['value']);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? selectedColor.withOpacity(0.1)
                        : itemBgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? selectedColor : itemBorderColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        checkin['icon'],
                        size: 14,
                        color: isSelected ? selectedColor : unselectedIconColor,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          checkin['label'],
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected
                                ? selectedColor
                                : unselectedIconColor,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: _isSaved
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.2)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          color: Colors.green,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Update saved',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ElevatedButton(
                    onPressed:
                        (_selectedMood == null && _selectedCheckins.isEmpty) ||
                            _isSaving
                        ? null
                        : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFFB5ADA4,
                      ), // Soft taupe button color
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: const Color(
                        0xFFB5ADA4,
                      ).withOpacity(0.5),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Update Check-in',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, bool isDark) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: isDark
            ? Colors.grey[400]
            : const Color(0xFF7A6856), // Dark brownish grey
        letterSpacing: 0.5,
      ),
    );
  }
}
