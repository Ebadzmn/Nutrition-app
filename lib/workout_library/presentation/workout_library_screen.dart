import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import '../../core/app_route.dart';
import '../../core/network/api_client.dart';
import '../../workouts/controller/workouts_controller.dart';

class WorkoutLibraryScreen extends StatefulWidget {
  const WorkoutLibraryScreen({super.key});

  @override
  State<WorkoutLibraryScreen> createState() => _WorkoutLibraryScreenState();
}

class _WorkoutLibraryScreenState extends State<WorkoutLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedPhase = 'all';
  String _selectedIntensity = 'all';
  String _selectedDuration = 'all';
  String _selectedBodypart = 'all';
  String _selectedEquipment = 'all';

  List<dynamic> _allWorkouts = [];
  bool _isLoading = true;

  final Map<String, Color> _phaseColors = {
    'menstrual': const Color(0xFFe05c4b),
    'follicular': const Color(0xFFe8943a),
    'ovulatory': const Color(0xFF3cb87a),
    'luteal': const Color(0xFF9b6fd4),
    'all': const Color(0xFFa0a0b0),
  };

  final Map<String, Map<String, dynamic>> _intensityColors = {
    'low': {'bg': const Color(0x263CB87A), 'text': const Color(0xFF3CB87A)},
    'moderate': {
      'bg': const Color(0x26D4B84A),
      'text': const Color(0xFFD4B84A),
    },
    'high': {'bg': const Color(0x26E05C4B), 'text': const Color(0xFFE05C4B)},
  };

  late final WorkoutsController _workoutsController;

  @override
  void initState() {
    super.initState();
    _workoutsController = Get.put(WorkoutsController());
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    try {
      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.get('/workout/library');
      if (response.isSuccess && response.data != null && response.data is List) {
        setState(() {
          _allWorkouts = response.data;
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch workouts from server");
      }
    } catch (e) {
      debugPrint("Failed to load workouts from server: $e");
      setState(() {
        _allWorkouts = [];
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _filteredWorkouts {
    return _allWorkouts.where((w) {
      final name = w['name'].toString().toLowerCase();
      final desc = w['desc'].toString().toLowerCase();
      final search = _searchController.text.toLowerCase();

      if (search.isNotEmpty && !name.contains(search) && !desc.contains(search))
        return false;

      final phases = List<String>.from(w['phase']);
      if (_selectedPhase != 'all' &&
          !phases.contains(_selectedPhase) &&
          !phases.contains('all'))
        return false;

      if (_selectedIntensity != 'all' && w['intensity'] != _selectedIntensity)
        return false;
      if (_selectedDuration != 'all' && w['duration'] != _selectedDuration)
        return false;
      if (_selectedBodypart != 'all' && w['bodypart'] != _selectedBodypart)
        return false;
      if (_selectedEquipment != 'all' && w['equipment'] != _selectedEquipment)
        return false;

      return true;
    }).toList();
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _selectedPhase = 'all';
      _selectedIntensity = 'all';
      _selectedDuration = 'all';
      _selectedBodypart = 'all';
      _selectedEquipment = 'all';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      body: Column(
        children: [
          // Header
          _buildHeader(),

          // Sticky Filters
          _buildStickyFilters(),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF8B7355)),
                  )
                : _filteredWorkouts.isEmpty
                ? _buildEmptyState()
                : _buildWorkoutGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFC4956A), Color(0xFFB08968), Color(0xFF8B7355)],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Workout Library',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${_filteredWorkouts.length} workouts',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() {}),
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search workouts...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey, size: 18),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          // Phase Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip(
                  'All phases',
                  'all',
                  _selectedPhase,
                  (v) => setState(() => _selectedPhase = v),
                  isPhase: true,
                ),
                _buildFilterChip(
                  '🩸 Menstrual',
                  'menstrual',
                  _selectedPhase,
                  (v) => setState(() => _selectedPhase = v),
                  isPhase: true,
                ),
                _buildFilterChip(
                  '🌱 Follicular',
                  'follicular',
                  _selectedPhase,
                  (v) => setState(() => _selectedPhase = v),
                  isPhase: true,
                ),
                _buildFilterChip(
                  '✨ Ovulatory',
                  'ovulatory',
                  _selectedPhase,
                  (v) => setState(() => _selectedPhase = v),
                  isPhase: true,
                ),
                _buildFilterChip(
                  '🌕 Luteal',
                  'luteal',
                  _selectedPhase,
                  (v) => setState(() => _selectedPhase = v),
                  isPhase: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Intensity & Duration Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Intensity: ',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                _buildFilterChip(
                  'All',
                  'all',
                  _selectedIntensity,
                  (v) => setState(() => _selectedIntensity = v),
                ),
                _buildFilterChip(
                  'Low',
                  'low',
                  _selectedIntensity,
                  (v) => setState(() => _selectedIntensity = v),
                ),
                _buildFilterChip(
                  'Moderate',
                  'moderate',
                  _selectedIntensity,
                  (v) => setState(() => _selectedIntensity = v),
                ),
                _buildFilterChip(
                  'High',
                  'high',
                  _selectedIntensity,
                  (v) => setState(() => _selectedIntensity = v),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Duration: ',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                _buildFilterChip(
                  'All',
                  'all',
                  _selectedDuration,
                  (v) => setState(() => _selectedDuration = v),
                ),
                _buildFilterChip(
                  '15-30',
                  '15-30',
                  _selectedDuration,
                  (v) => setState(() => _selectedDuration = v),
                ),
                _buildFilterChip(
                  '30-45',
                  '30-45',
                  _selectedDuration,
                  (v) => setState(() => _selectedDuration = v),
                ),
                _buildFilterChip(
                  '45-60',
                  '45-60',
                  _selectedDuration,
                  (v) => setState(() => _selectedDuration = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Bodypart & Equipment & Clear
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Area: ',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                _buildFilterChip(
                  'All',
                  'all',
                  _selectedBodypart,
                  (v) => setState(() => _selectedBodypart = v),
                ),
                _buildFilterChip(
                  'Full Body',
                  'full body',
                  _selectedBodypart,
                  (v) => setState(() => _selectedBodypart = v),
                ),
                _buildFilterChip(
                  'Lower Body',
                  'lower body',
                  _selectedBodypart,
                  (v) => setState(() => _selectedBodypart = v),
                ),
                _buildFilterChip(
                  'Upper Body',
                  'upper body',
                  _selectedBodypart,
                  (v) => setState(() => _selectedBodypart = v),
                ),
                _buildFilterChip(
                  'Core',
                  'core',
                  _selectedBodypart,
                  (v) => setState(() => _selectedBodypart = v),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Equipment: ',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                _buildFilterChip(
                  'All',
                  'all',
                  _selectedEquipment,
                  (v) => setState(() => _selectedEquipment = v),
                ),
                _buildFilterChip(
                  'No Equipment',
                  'no equipment',
                  _selectedEquipment,
                  (v) => setState(() => _selectedEquipment = v),
                ),
                _buildFilterChip(
                  'Dumbbells',
                  'dumbbells',
                  _selectedEquipment,
                  (v) => setState(() => _selectedEquipment = v),
                ),
                _buildFilterChip(
                  'Barbell',
                  'barbell',
                  _selectedEquipment,
                  (v) => setState(() => _selectedEquipment = v),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _clearAllFilters,
                  child: const Text(
                    'Clear all',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    String selectedValue,
    Function(String) onSelect, {
    bool isPhase = false,
  }) {
    final isSelected = value == selectedValue;
    Color? activeColor;
    if (isPhase && isSelected && value != 'all') {
      activeColor = _phaseColors[value];
    }

    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        constraints: const BoxConstraints(minHeight: 32),
        decoration: BoxDecoration(
          color: isSelected
              ? (activeColor?.withOpacity(0.1) ??
                    const Color(0xFF6B5D4F).withOpacity(0.1))
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (activeColor ?? const Color(0xFF6B5D4F))
                : Colors.grey.withOpacity(0.2),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? (activeColor ?? const Color(0xFF3A2E28))
                : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutGrid() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredWorkouts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildWorkoutCard(_filteredWorkouts[index]);
      },
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutCard(Map<String, dynamic> workout) {
    final primaryPhase = List<String>.from(workout['phase'])[0];
    final phaseColor = _phaseColors[primaryPhase] ?? _phaseColors['all']!;
    final intensity = workout['intensity'].toString();
    final intColor =
        _intensityColors[intensity] ??
        {'bg': Colors.grey[100], 'text': Colors.grey};

    return GestureDetector(
      onTap: () => _showWorkoutDetail(workout, phaseColor),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 5,
              decoration: BoxDecoration(
                color: phaseColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
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
                          workout['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2420),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: intColor['bg'] as Color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          intensity.toLowerCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: intColor['text'] as Color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: phaseColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      primaryPhase.toLowerCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: phaseColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    workout['desc'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildIconText(
                        Icons.access_time_rounded,
                        '${workout['duration_mins']} min',
                      ),
                      const SizedBox(width: 16),
                      _buildIconText(
                        Icons.track_changes_rounded,
                        workout['bodypart'].toString(),
                      ),
                      const SizedBox(width: 16),
                      _buildIconText(
                        Icons.inventory_2_outlined,
                        workout['equipment']?.toString() ?? 'yoga mat',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Obx(() {
                        final workoutId = workout['id']?.toString() ?? '';
                        final isSaved = _workoutsController.savedWorkoutIds.contains(workoutId);
                        return GestureDetector(
                          onTap: () {
                            if (workoutId.isNotEmpty) {
                              _workoutsController.toggleSaveWorkout(workoutId);
                            }
                          },
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                              color: const Color(0xFF5C4A3A),
                              size: 20,
                            ),
                          ),
                        );
                      }),
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

  void _showWorkoutDetail(Map<String, dynamic> workout, Color phaseColor) {
    final intensity = workout['intensity'].toString();
    final intColor =
        _intensityColors[intensity] ??
        {'bg': Colors.grey[100], 'text': Colors.grey};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            Container(
              height: 6,
              width: 100,
              decoration: BoxDecoration(
                color: phaseColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout['name'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2420),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: intColor['bg'],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                intensity.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: intColor['text'],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '⏱ ${workout['duration_mins']} min',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout['desc'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9E7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFECB3)),
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
                          const SizedBox(height: 6),
                          Text(
                            workout['phaseNote'] ??
                                'A restorative sequence designed for your cycle.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF8B7355),
                              height: 1.4,
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
                        color: Color(0xFF2D2420),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.from(
                      workout['exercises'],
                    ).map((ex) => _buildExerciseDetailItem(ex)).toList(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        side: BorderSide(color: phaseColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: phaseColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Get.toNamed(AppRoute.workoutSession, arguments: workout);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: phaseColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Start Workout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseDetailItem(Map<String, dynamic> ex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ex['name'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2420),
                  ),
                ),
                Text(
                  '${List.from(ex['sets']).length} sets',
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          ...List.from(ex['sets']).asMap().entries.map((entry) {
            final idx = entry.key;
            final set = entry.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Text(
                    '${idx + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Text(
                    set['reps'].toString(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF2D2420),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 80,
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'kg / RPE',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text(
            'No workouts match your filters',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          TextButton(
            onPressed: _clearAllFilters,
            child: const Text(
              'Clear all filters',
              style: TextStyle(
                color: Color(0xFF8B7355),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
