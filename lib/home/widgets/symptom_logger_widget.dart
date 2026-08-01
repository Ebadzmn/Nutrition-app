import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';

import 'package:intl/intl.dart';
import '../../core/network/api_client.dart';
import '../controller/home_controller.dart';

class SymptomLoggerWidget extends StatefulWidget {
  final bool isModal;
  const SymptomLoggerWidget({super.key, this.isModal = false});

  @override
  State<SymptomLoggerWidget> createState() => _SymptomLoggerWidgetState();
}

class _SymptomLoggerWidgetState extends State<SymptomLoggerWidget> {
  bool _showLogger = true;
  final List<String> _selectedSymptoms = [];
  String _severity = 'mild';
  final TextEditingController _notesController = TextEditingController();

  List<String> _symptoms = [];
  bool _isLoadingSymptoms = false;

  @override
  void initState() {
    super.initState();
    _loadTodaySymptoms();
    _loadSymptomsFromApi();
    
    // Listen to date changes
    final homeController = Get.find<HomeController>();
    ever(homeController.selectedDate, (_) {
      _loadTodaySymptoms();
    });
  }

  void _loadSymptomsFromApi() async {
    try {
      if (mounted) setState(() => _isLoadingSymptoms = true);
      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.get('/onboarding/options');
      if (response.isSuccess && response.data != null) {
        final data = response.data['data'];
        if (data != null && data['symptoms'] != null) {
          final List<String> loadedSymptoms = List<String>.from(
              (data['symptoms'] as List)
                  .map((s) => s['name'] as String)
                  .where((name) => name != 'None / minimal'));
          if (mounted) {
            setState(() {
              _symptoms = loadedSymptoms;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Failed to load symptoms: $e");
    } finally {
      if (mounted) setState(() => _isLoadingSymptoms = false);
    }
  }

  void _loadTodaySymptoms() async {
    try {
      final homeController = Get.find<HomeController>();
      final formattedDate = DateFormat('yyyy-MM-dd').format(homeController.selectedDate.value);
      final ApiClient apiClient = Get.find<ApiClient>();

      final response = await apiClient.get(
        '/cycle/symptom-logs',
        queryParameters: {"date": formattedDate},
      );

      if (response.isSuccess && response.data != null && response.data is List && (response.data as List).isNotEmpty) {
        final log = response.data[0];
        if (mounted) {
          setState(() {
            _selectedSymptoms.clear();
            if (log['symptoms'] != null) {
              _selectedSymptoms.addAll(List<String>.from(log['symptoms']));
            }
            _severity = log['severity'] ?? 'mild';
            _notesController.text = log['notes'] ?? '';
            _showLogger = true;
          });
        }
      } else {
        if (mounted && !widget.isModal) {
          setState(() {
            _selectedSymptoms.clear();
            _severity = 'mild';
            _notesController.clear();
            _showLogger = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Failed to load today's symptoms: $e");
    }
  }

  final List<String> _commonSymptoms = [
    "PMS mood changes", "Cramping", "Fatigue", "Bloating", "Cravings", "Headaches",
    "Breast tenderness", "Anxiety / low mood", "Sleep disruption", "Brain fog", "Skin breakouts"
  ];

  void _toggleSymptom(String symptom) {
    setState(() {
      if (_selectedSymptoms.contains(symptom)) {
        _selectedSymptoms.remove(symptom);
      } else {
        _selectedSymptoms.add(symptom);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (!_showLogger && !widget.isModal) {
      return ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const SymptomLoggerWidget(isModal: true),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
            foregroundColor: isDark ? Colors.white : const Color(0xFF3A2E28),
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 20, color: Color(0xFF3A2E28)),
              SizedBox(width: 8),
              Text(
                'Log Today\'s Symptoms',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3A2E28),
                ),
              ),
            ],
          ),
      );
    }

    return Container(
      margin: widget.isModal ? EdgeInsets.zero : EdgeInsets.zero,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : AppColors.cardBackground,
        borderRadius: widget.isModal ? const BorderRadius.vertical(top: Radius.circular(32)) : BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling today?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (_symptoms.isNotEmpty ? _symptoms : _commonSymptoms).map((symptom) {
              final isSelected = _selectedSymptoms.contains(symptom);
              return GestureDetector(
                onTap: () => _toggleSymptom(symptom),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : (isDark ? const Color(0xFF2C2C2C) : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    symptom,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : AppColors.textPrimary),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text(
            'Severity',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: ['mild', 'moderate', 'severe'].map((level) {
              final isSelected = _severity == level;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _severity = level),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryLight : (isDark ? const Color(0xFF2C2C2C) : Colors.white),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : (isDark ? const Color(0xFF3A3A3A) : Colors.grey[300]!),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      level[0].toUpperCase() + level.substring(1),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Any other notes...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => setState(() => _showLogger = false),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_selectedSymptoms.isEmpty) {
                      Get.snackbar('Selection Required', 'Please select at least one symptom');
                      return;
                    }
                    try {
                      final homeController = Get.find<HomeController>();
                      final formattedDate = DateFormat('yyyy-MM-dd').format(homeController.selectedDate.value);

                      final ApiClient apiClient = Get.find<ApiClient>();
                      final response = await apiClient.post(
                        '/cycle/symptom-logs',
                        data: {
                          "date": formattedDate,
                          "symptoms": _selectedSymptoms.toList(),
                          "severity": _severity,
                          "notes": _notesController.text,
                        },
                      );

                      if (response.isSuccess) {
                        homeController.fetchRecentLogs();
                        Navigator.pop(context);
                        Get.snackbar(
                          'Success',
                          'Symptoms logged successfully',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green.withOpacity(0.1),
                          colorText: Colors.green[800],
                        );
                      } else {
                        Get.snackbar(
                          'Error',
                          response.message.isNotEmpty ? response.message : 'Failed to log symptoms',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                      }
                    } catch (e) {
                      Get.snackbar(
                        'Error',
                        'An unexpected error occurred',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Log'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
