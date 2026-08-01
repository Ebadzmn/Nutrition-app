import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../controller/home_controller.dart';

import 'dart:math' as math;

class PhaseIndicatorWidget extends StatefulWidget {
  const PhaseIndicatorWidget({super.key});

  @override
  State<PhaseIndicatorWidget> createState() => _PhaseIndicatorWidgetState();
}

class _PhaseIndicatorWidgetState extends State<PhaseIndicatorWidget> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _showCycleTracking(BuildContext context) {
    final controller = Get.find<HomeController>();
    DateTime viewDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 48), // Spacer for balance
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Cycle Tracker',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Alert Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEB),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.transparent,
                              ),
                              child: const Icon(Icons.water_drop_outlined, color: Color(0xFFC0392B), size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Next period in ${controller.cycleLength.value - controller.cycleDay.value} days',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D2420),
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Expected around ${DateFormat('MMMM d, yyyy').format(controller.periodStartDate.value.add(Duration(days: controller.cycleLength.value)))}',
                                    style: const TextStyle(
                                      color: Color(0xFF5C4A3A),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Month Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left_rounded),
                            onPressed: () {
                              setModalState(() {
                                viewDate = DateTime(viewDate.year, viewDate.month - 1);
                              });
                            },
                          ),
                          Text(
                            DateFormat('MMMM yyyy').format(viewDate),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right_rounded),
                            onPressed: () {
                              setModalState(() {
                                viewDate = DateTime(viewDate.year, viewDate.month + 1);
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Calendar Grid
                      _buildCalendarGrid(viewDate, controller),
                      const SizedBox(height: 24),

                      // Legend
                      _buildLegend(),
                      const SizedBox(height: 32),

                      // Predicted Periods Section
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Predicted Periods',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPredictedPeriodList(controller),
                      const SizedBox(height: 32),

                      // Action Buttons
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            controller.updateCycleDataOnBackend(startDate: DateTime.now());
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.water_drop_outlined, size: 20),
                          label: const Text('My period started today'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF14C4C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final duration = DateTime.now().difference(controller.periodStartDate.value).inDays + 1;
                            controller.updateCycleDataOnBackend(periodLengthValue: duration);
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.check_circle_outline, size: 20),
                          label: const Text('My period ended today'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(DateTime viewDate, HomeController controller) {
    final firstDayOfMonth = DateTime(viewDate.year, viewDate.month, 1);
    final lastDayOfMonth = DateTime(viewDate.year, viewDate.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday

    final weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekDays.map((day) => Text(
            day,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          )).toList(),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: daysInMonth + (firstWeekday - 1),
          itemBuilder: (context, index) {
            if (index < firstWeekday - 1) {
              return const SizedBox.shrink();
            }
            final day = index - (firstWeekday - 1) + 1;
            final date = DateTime(viewDate.year, viewDate.month, day);
            final phase = controller.getPhaseForDate(date);
            final color = controller.getPhaseColor(phase);
            
            final isToday = date.year == DateTime.now().year && 
                           date.month == DateTime.now().month && 
                           date.day == DateTime.now().day;

            return Center(
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isToday ? Border.all(color: Colors.black, width: 2) : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLegend() {
    final phases = [
      {'name': 'Period', 'color': const Color(0xFFFFD1D1)},
      {'name': 'Predicted period', 'color': const Color(0xFFFFEBEB)},
      {'name': 'Follicular', 'color': const Color(0xFFFFF4D1)},
      {'name': 'Ovulation', 'color': const Color(0xFFD1F9ED)},
      {'name': 'Luteal', 'color': const Color(0xFFE8D1FF)},
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: phases.map((phase) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: phase['color'] as Color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            phase['name'] as String,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      )).toList(),
    );
  }

  Widget _buildPredictedPeriodList(HomeController controller) {
    return Column(
      children: List.generate(3, (index) {
        final date = controller.periodStartDate.value.add(Duration(days: (index + 1) * controller.cycleLength.value));
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEB).withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.water_drop_outlined, color: Color(0xFFC0392B), size: 20),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, MMMM d').format(date),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Text(
                      '~2 days',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  void _showPhaseDetails(BuildContext context) {
    final controller = Get.find<HomeController>();
    final phaseNum = controller.getPhaseNumber();
    final phaseName = controller.currentPhase.value;
    
    final Map<int, Map<String, dynamic>> phaseData = {
      1: {
        'title': 'Menstruation',
        'emoji': '🩸',
        'desc': 'Focus on rest and recovery. Your hormones are at their lowest levels.',
        'tips': ['Gentle yoga', 'Iron-rich foods', 'Extra sleep'],
        'color': const Color(0xFFE8927C),
      },
      2: {
        'title': 'Follicular',
        'emoji': '🌱',
        'desc': 'Energy is rising. Great time for building new habits and increasing intensity.',
        'tips': ['Strength training', 'Complex carbs', 'High intensity'],
        'color': const Color(0xFFF5D6C6),
      },
      3: {
        'title': 'Ovulation',
        'emoji': '✨',
        'desc': 'Peak energy and strength. You are at your most capable.',
        'tips': ['PR attempts', 'Social events', 'Metabolism boost'],
        'color': const Color(0xFF7DD3C0),
      },
      4: {
        'title': 'Luteal',
        'emoji': '🌕',
        'desc': 'Body is preparing for next cycle. Energy may start to dip.',
        'tips': ['Moderate cardio', 'Magnesium', 'Self-care'],
        'color': const Color(0xFFA78BCA),
      },
    };

    final data = phaseData[phaseNum]!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  data['emoji'],
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Text(
                  'Phase $phaseNum: ${data['title']}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              data['desc'],
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Recommended for today:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            ...(data['tips'] as List<String>).map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: data['color'],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    tip,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            )),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: data['color'],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Got it'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    
    return Column(
      children: [
        const SizedBox(height: 10),
        Stack(
          alignment: Alignment.center,
          children: [
            // Glow effect
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7DD3C0).withOpacity(0.2),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),

            // Outer ring
            SizedBox(
              width: 190,
              height: 190,
              child: CustomPaint(
                painter: RingPainter(),
              ),
            ),

            // Center Button
            GestureDetector(
              onTap: () => _showCycleTracking(context),
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFA89585),
                      Color(0xFF8B7D6F),
                      Color(0xFF6B5D4F),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Top highlight
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Obx(() => Text(
                        '${controller.cycleDay.value}',
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                          shadows: [
                            Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                          ],
                        ),
                      )),
                    ),
                  ],
                ),
              ),
            ),

            // Rotating Dot
            RotationTransition(
              turns: _rotationController,
              child: SizedBox(
                width: 175,
                height: 175,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7DD3C0),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7DD3C0).withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => _showPhaseDetails(context),
          child: Obx(() => Text.rich(
            TextSpan(
              text: 'You are currently in ',
              style: const TextStyle(color: Colors.white, fontSize: 18),
              children: [
                TextSpan(
                  text: 'Phase ${controller.getPhaseNumber()}, ${controller.currentPhase.value}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          )),
        ),
        const SizedBox(height: 8),
        Obx(() => Text(
          '${controller.cycleLength.value - controller.cycleDay.value} days until your next period',
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
        )),
      ],
    );
  }
}

class RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF7DD3C0),
          Color(0xFFF5D6C6),
          Color(0xFF7DD3C0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
