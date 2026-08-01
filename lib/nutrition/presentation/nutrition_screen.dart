import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import '../widgets/macro_calculator_widget.dart';
import '../widgets/food_library_widget.dart';
import '../widgets/recipe_library_widget.dart';
import '../widgets/reference_list_widget.dart';
import '../../home/controller/home_controller.dart';
import '../controller/nutrition_controller.dart';
import '../../nav_bar/navbar_controller.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NutritionController());
    final homeController = Get.find<HomeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Column(
          children: [
            // Top Section with Gradient
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Get.find<NavbarController>().changePage(0),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : const Color(0xFF3A2E28), size: 20),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Nutrition',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF3A2E28),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Phase Info Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Obx(() => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Phase ${homeController.getPhaseNumber()}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white70 : const Color(0xFF3A2E28).withOpacity(0.6),
                                  ),
                                ),

                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              homeController.currentPhase.value,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF3A2E28),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getPhaseDescription(homeController.getPhaseNumber()),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white70 : const Color(0xFF3A2E28).withOpacity(0.7),
                              ),
                            ),
                          ],
                        )),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content Section
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBackground : AppColors.background,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    children: [
                      // Tabs
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? const Color(0xFF333333) : Colors.grey[200]!),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                          labelColor: isDark ? Colors.white : const Color(0xFF2D2420),
                          unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
                          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: isDark ? AppColors.darkSurfaceLight : Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          tabs: const [
                            Tab(text: '🥦 Foods'),
                            Tab(text: '🍽️ Recipes'),
                            Tab(text: '📊 Macros'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            const FoodLibraryWidget(),
                            const RecipeLibraryWidget(),
                            _buildCalculatorTab(context, homeController),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPhaseDescription(int phase) {
    switch (phase) {
      case 1: return "Focus on iron-rich foods and anti-inflammatory ingredients";
      case 2: return "Light, fresh foods to support rising energy levels";
      case 3: return "Fuel your body during your most energetic phase";
      case 4: return "Complex carbs and mood-boosting nutrients";
      default: return "";
    }
  }

  Widget _buildTab(String label) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildCalculatorTab(BuildContext context, HomeController homeController) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recommended Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C3E30) : const Color(0xFFC8DCC8),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Energy Boosting',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF8FD1A3) : const Color(0xFF4A7A5A),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showReferences(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF8FD1A3).withOpacity(0.2) : const Color(0xFF4A7A5A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? const Color(0xFF8FD1A3).withOpacity(0.5) : const Color(0xFF4A7A5A).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 14, color: isDark ? const Color(0xFF8FD1A3) : const Color(0xFF4A7A5A)),
                          const SizedBox(width: 4),
                          Text(
                            'Sources',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF8FD1A3) : const Color(0xFF4A7A5A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Light, fresh foods to support rising energy levels',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF8FD1A3).withOpacity(0.7) : const Color(0xB24A7A5A), // 0.7 opacity
                ),
              ),
              const SizedBox(height: 20),
              const MacroCalculatorWidget(),
            ],
          ),
        ),
        const SizedBox(height: 100),
      ],
    ),
  );
  }

  void _showReferences(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
  }
}
