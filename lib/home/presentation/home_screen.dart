import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import '../widgets/header_widget.dart';
import '../widgets/week_calendar_widget.dart';
import '../widgets/today_section_widget.dart';
import '../widgets/phase_indicator_widget.dart';
import '../widgets/daily_logger_widget.dart';
import '../widgets/tips_section_widget.dart';
import '../widgets/hormone_chart_widget.dart';
import '../widgets/symptom_logger_widget.dart';
import '../widgets/phase_explorer_widget.dart';
import '../widgets/cycle_pattern_insights_widget.dart';
import '../controller/home_controller.dart';
import '../../nutrition/widgets/reference_list_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : AppColors.background;
    
    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Top Section with Gradient and Curves
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark ? [
                        const Color(0xFF2C2C2C),
                        const Color(0xFF1E1E1E),
                        const Color(0xFF121212),
                      ] : [
                        AppColors.homeGradientStart,
                        AppColors.homeGradientMid,
                        AppColors.homeGradientEnd,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: const [
                        HeaderWidget(),
                        WeekCalendarWidget(),
                        PhaseIndicatorWidget(),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                // Decorative Curves
                Positioned.fill(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.2,
                      child: CustomPaint(
                        painter: CurvePainter(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Content Section
            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: _buildMedicalCitations(context, isDark),
                    ),
                    const TodaySectionWidget(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const DailyLoggerWidget(),
                          const SizedBox(height: 16),
                          const CyclePatternInsightsWidget(),
                          const SizedBox(height: 16),
                          const SymptomLoggerWidget(),
                          const SizedBox(height: 16),
                          const HormoneChartWidget(),
                          const SizedBox(height: 16),
                          const PhaseExplorerWidget(),
                        ],
                      ),
                    ),
                    const TipsSectionWidget(),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalCitations(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBackground : AppColors.background,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Scientific References',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF3A2E28),
                  ),
                ),
                const SizedBox(height: 16),
                const Expanded(
                  child: ReferenceListWidget(),
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.blue.withOpacity(0.1) : Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.blue.withOpacity(0.3) : Colors.blue.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.health_and_safety_rounded, color: isDark ? Colors.blue[300] : Colors.blue[700]),
            const SizedBox(width: 8),
            Text(
              'Medical Citations',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.blue[300] : Colors.blue[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.2);
    path1.quadraticBezierTo(size.width * 0.25, size.height * 0.25, size.width * 0.5, size.height * 0.2);
    path1.quadraticBezierTo(size.width * 0.75, size.height * 0.15, size.width, size.height * 0.2);
    canvas.drawPath(path1, paint);

    final path2 = Path();
    path2.moveTo(0, size.height * 0.4);
    path2.quadraticBezierTo(size.width * 0.375, size.height * 0.45, size.width * 0.75, size.height * 0.4);
    path2.quadraticBezierTo(size.width * 0.875, size.height * 0.375, size.width, size.height * 0.4);
    canvas.drawPath(path2, paint);

    final path3 = Path();
    path3.moveTo(0, size.height * 0.6);
    path3.quadraticBezierTo(size.width * 0.25, size.height * 0.65, size.width * 0.5, size.height * 0.6);
    path3.quadraticBezierTo(size.width * 0.75, size.height * 0.55, size.width, size.height * 0.6);
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
