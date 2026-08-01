import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../core/app_colors.dart';
import 'package:get/get.dart';
import '../../auth/controller/auth_controller.dart';
import '../../core/app_route.dart';

class HormoneChartWidget extends StatelessWidget {
  const HormoneChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final hasPremium = authController.hasPremiumAccess;

      final content = Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hormone Levels',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF3A2E28),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Full 28-day cycle view. Tap hormones to toggle. Your current day is highlighted.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : const Color(0xFF7A6856),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            // Legends
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildLegend('Oestrogen', const Color(0xFFC87930)),
                _buildLegend('Progesterone', const Color(0xFF168F7F)),
                _buildLegend('LH', const Color(0xFFCA3E32)),
                _buildLegend('FSH', const Color(0xFF7A41AA)),
              ],
            ),
            const SizedBox(height: 20),
            // Phase Indicator Bar
            Row(
              children: [
                _buildPhaseBar(
                  context: context,
                  flex: 5, 
                  color: const Color(0xFFE8A09A), 
                  label: '1-5',
                  phaseName: 'Menstruation',
                  phaseNum: 1,
                ),
                const SizedBox(width: 4),
                _buildPhaseBar(
                  context: context,
                  flex: 8, 
                  color: const Color(0xFFE8D0A5), 
                  label: '6-13',
                  phaseName: 'Follicular',
                  phaseNum: 2,
                ),
                const SizedBox(width: 4),
                _buildPhaseBar(
                  context: context,
                  flex: 4, 
                  color: const Color(0xFFA5D4B5), 
                  label: '14-17',
                  phaseName: 'Ovulation',
                  phaseNum: 3,
                ),
                const SizedBox(width: 4),
                _buildPhaseBar(
                  context: context,
                  flex: 11, 
                  color: const Color(0xFFC8B8E0), 
                  label: '18-28',
                  phaseName: 'Luteal',
                  phaseNum: 4,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 7,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const Text('');
                          return Text(
                            'Day ${value.toInt()}',
                            style: TextStyle(
                              color: isDark ? Colors.grey[500] : AppColors.textSecondary.withOpacity(0.5),
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 1,
                  maxX: 28,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    _generateLineData(
                      color: const Color(0xFFC87930),
                      type: 'oestrogen',
                    ),
                    _generateLineData(
                      color: const Color(0xFF168F7F),
                      type: 'progesterone',
                    ),
                    _generateLineData(
                      color: const Color(0xFFCA3E32),
                      type: 'lh',
                    ),
                    _generateLineData(
                      color: const Color(0xFF7A41AA),
                      type: 'fsh',
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => AppColors.primaryDark.withOpacity(0.8),
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final flSpot = barSpot;
                          return LineTooltipItem(
                            '${flSpot.y.toInt()}',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildPhaseLabelLegend(),
          ],
        ),
      );

      if (hasPremium) {
        return content;
      }

      return Stack(
        children: [
          Opacity(
            opacity: 0.15,
            child: AbsorbPointer(
              child: content,
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C).withOpacity(0.9) : Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8927C).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        color: Color(0xFFE8927C),
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Unlock Hormone Trends',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF3A2E28),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Track how your oestrogen, progesterone, LH, and FSH fluctuate throughout your cycle.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : const Color(0xFF8B7355),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Get.toNamed(AppRoute.premium),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8927C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Upgrade to Premium',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPhaseBar({
    required BuildContext context,
    required int flex,
    required Color color,
    required String label,
    required String phaseName,
    required int phaseNum,
  }) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () => _showPhaseInfo(context, phaseName, phaseNum, color),
        child: Container(
          height: 6,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  void _showPhaseInfo(BuildContext context, String name, int num, Color color) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Phase $num: $name',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _getPhaseDescription(num),
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color.withOpacity(0.8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPhaseDescription(int num) {
    switch (num) {
      case 1: return 'Your hormones are at their lowest. Focus on rest and recovery.';
      case 2: return 'Oestrogen begins to rise, boosting your energy and mood.';
      case 3: return 'Peak oestrogen and testosterone. You are at your most capable.';
      case 4: return 'Progesterone becomes dominant. Body temperature rises.';
      default: return '';
    }
  }

  Widget _buildLegend(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseLabelLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSmallLabel('1–5', const Color(0xFFD86B62)),
          _buildSmallLabel('6–13', const Color(0xFFDDA15E)),
          _buildSmallLabel('14–17', const Color(0xFF63A77C)),
          _buildSmallLabel('18–28', const Color(0xFF9B70C4)),
        ],
      ),
    );
  }

  Widget _buildSmallLabel(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  LineChartBarData _generateLineData({required Color color, required String type}) {
    List<FlSpot> spots = [];
    for (int day = 1; day <= 28; day++) {
      double value = 0;
      if (type == 'oestrogen') {
        if (day <= 5) value = 20.0 + day * 2;
        else if (day <= 13) value = 30.0 + (day - 5) * 9;
        else if (day == 14) value = 100;
        else if (day <= 17) value = 100.0 - (day - 14) * 18;
        else if (day <= 22) value = 46.0 + (day - 17) * 5;
        else value = 71.0 - (day - 22) * 6;
      } else if (type == 'progesterone') {
        if (day <= 14) value = 5.0 + day * 0.3;
        else if (day <= 22) value = 9.0 + (day - 14) * 8;
        else if (day <= 26) value = 73.0 - (day - 22) * 10;
        else value = 33.0 - (day - 26) * 8;
      } else if (type == 'lh') {
        if (day >= 12 && day <= 15) {
          value = 15.0 + math.max(0, 75.0 - math.pow((day - 13.5).abs(), 2) * 18);
        } else {
          value = 12.0 + (day <= 5 ? day * 0.5 : 0);
        }
      } else if (type == 'fsh') {
        if (day <= 3) value = 10.0 + day * 3;
        else if (day <= 8) value = 16.0 - (day - 3) * 1.5;
        else if (day <= 13) value = 9.0 + (day - 8) * 5;
        else if (day == 14) value = 38;
        else if (day <= 17) value = 38.0 - (day - 14) * 10;
        else value = 8;
      }
      spots.add(FlSpot(day.toDouble(), value));
    }

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.05),
      ),
    );
  }
}
