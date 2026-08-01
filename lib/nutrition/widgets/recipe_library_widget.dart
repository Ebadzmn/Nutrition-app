import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/nutrition_controller.dart';
import '../../core/app_colors.dart';

class RecipeLibraryWidget extends StatelessWidget {
  const RecipeLibraryWidget({super.key});

  static const Map<String, String> _recipeReferences = {
    'Red Lentil Iron Soup': 'https://www.healthline.com/nutrition/lentils',
    'Ginger Anti-Cramp Porridge': 'https://www.healthline.com/nutrition/11-proven-benefits-of-ginger',
    'Omega-3 Salmon Bowl': 'https://www.healthline.com/nutrition/salmon-nutrition-and-health-benefits',
    'Magnesium Bliss Balls': 'https://www.healthline.com/nutrition/10-foods-high-in-magnesium',
    'Golden Milk Latte': 'https://www.healthline.com/nutrition/top-10-evidence-based-health-benefits-of-turmeric',
    'Follicular Power Bowl': 'https://www.healthline.com/nutrition/cruciferous-vegetables',
    'High-Protein Frittata': 'https://www.healthline.com/nutrition/proven-health-benefits-of-eggs',
    'Lemon Herb Chicken & Rice': 'https://www.healthline.com/nutrition/calories-in-chicken',
    'Cruciferous Oestrogen Salad': 'https://www.healthline.com/nutrition/cruciferous-vegetables',
    'Serotonin Pasta': 'https://www.healthline.com/nutrition/tryptophan',
    'Luteal Chocolate Mousse': 'https://www.healthline.com/nutrition/7-health-benefits-dark-chocolate',
    'Slow Cooker Chicken & Sweet Potato': 'https://www.healthline.com/nutrition/sweet-potato-benefits',
    'Hormone-Balancing Seed Pudding': 'https://www.healthline.com/nutrition/seed-cycling',
  };

  void _showRecipeDetail(BuildContext context, Map<String, dynamic> recipe) {
    final prepTime = recipe['prepTime'] ?? recipe['time'] ?? '15 min';
    final caloriesText = '${recipe['cals'] ?? recipe['calories'] ?? 300} kcal';
    final firstPhase = List<dynamic>.from(recipe['phases'] ?? []).isNotEmpty
        ? List<dynamic>.from(recipe['phases'])[0].toString()
        : (recipe['phase']?.toString() ?? '');
    final phaseText = firstPhase.isNotEmpty
        ? firstPhase[0].toUpperCase() + firstPhase.substring(1)
        : 'All';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(recipe['emoji'] ?? '🍽️', style: const TextStyle(fontSize: 48)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(recipe['name'] ?? '', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                        Text(recipe['tagline'] ?? '', style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: isDark ? Colors.white70 : AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDetailTag(Icons.timer_outlined, prepTime, context),
                  _buildDetailTag(Icons.local_fire_department_rounded, caloriesText, context),
                  _buildDetailTag(Icons.spa_rounded, phaseText, context),
                ],
              ),
              const SizedBox(height: 32),
              Text('Ingredients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
              const SizedBox(height: 12),
              if (recipe['ingredients'] != null && recipe['ingredients'] is List)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (recipe['ingredients'] as List<dynamic>).map((ing) {
                    final name = ing['n'] ?? ing['name'] ?? '';
                    final amount = ing['a'] ?? ing['amount'] ?? '';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Text(
                        '• $amount $name',
                        style: TextStyle(fontSize: 14, height: 1.6, color: isDark ? Colors.white : AppColors.textPrimary),
                      ),
                    );
                  }).toList(),
                )
              else
                Text('• Standard ingredients', style: TextStyle(fontSize: 14, height: 1.6, color: isDark ? Colors.white : AppColors.textPrimary)),
              const SizedBox(height: 32),
              if (recipe['why'] != null) ...[
                Text('Why it\'s good for you', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                const SizedBox(height: 12),
                Text(recipe['why'], style: TextStyle(fontSize: 14, height: 1.6, color: isDark ? Colors.white70 : AppColors.textPrimary)),
                if (_recipeReferences.containsKey(recipe['name']) || recipe['referenceLink'] != null) ...[
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final urlString = recipe['referenceLink'] ?? _recipeReferences[recipe['name']];
                      if (urlString != null) {
                        final url = Uri.parse(urlString);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(isDark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withOpacity(isDark ? 0.5 : 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.menu_book_rounded, size: 14, color: isDark ? const Color(0xFFFFB38E) : AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            'Read Reference Article',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFFFFB38E) : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
              ],
              Text('Instructions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
              const SizedBox(height: 12),
              if (recipe['steps'] != null && recipe['steps'] is List)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (recipe['steps'] as List<dynamic>).asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final step = entry.value.toString();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        '$idx. $step',
                        style: TextStyle(fontSize: 14, height: 1.6, color: isDark ? Colors.white : AppColors.textPrimary),
                      ),
                    );
                  }).toList(),
                )
              else
                Text('1. Prepare and enjoy.', style: TextStyle(fontSize: 14, height: 1.6, color: isDark ? Colors.white : AppColors.textPrimary)),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.accent : AppColors.textPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Add to Log'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
          ),
        );
      },
    );
  }

  Widget _buildDetailTag(IconData icon, String label, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Icon(icon, color: AppColors.textMuted, size: 24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NutritionController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: CircularProgressIndicator(color: Color(0xFF8B7355)),
          ),
        );
      }

      if (controller.recipes.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'No recipes found.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        );
      }

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            'Quick Recipes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.recipes.length,
            itemBuilder: (context, index) {
              final recipe = controller.recipes[index];
              final prepTime = recipe['prepTime'] ?? recipe['time'] ?? '15 min';
              final caloriesText = '${recipe['cals'] ?? recipe['calories'] ?? 300} kcal';
              final firstPhase = List<dynamic>.from(recipe['phases'] ?? []).isNotEmpty
                  ? List<dynamic>.from(recipe['phases'])[0].toString()
                  : (recipe['phase']?.toString() ?? '');

              return GestureDetector(
                onTap: () => _showRecipeDetail(context, recipe),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 4,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _getPhaseColor(firstPhase),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Text(recipe['emoji'] ?? '🍽️', style: const TextStyle(fontSize: 32)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recipe['name'] ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    recipe['tagline'] ?? '',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _buildInfo(Icons.timer_outlined, prepTime),
                                      const SizedBox(width: 12),
                                      _buildInfo(Icons.local_fire_department_rounded, caloriesText),
                                    ],
                                  ),
                                  if (_recipeReferences.containsKey(recipe['name']) || recipe['referenceLink'] != null) ...[
                                    const SizedBox(height: 10),
                                    InkWell(
                                      onTap: () async {
                                        final urlString = recipe['referenceLink'] ?? _recipeReferences[recipe['name']];
                                        if (urlString != null) {
                                          final url = Uri.parse(urlString);
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(url);
                                          }
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(isDark ? 0.2 : 0.1),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: AppColors.primary.withOpacity(isDark ? 0.5 : 0.3)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.menu_book_rounded, size: 14, color: isDark ? const Color(0xFFFFB38E) : AppColors.primary),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Reference Source',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? const Color(0xFFFFB38E) : AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ));
    });
  }

  Widget _buildInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Color _getPhaseColor(String phase) {
    switch (phase.toLowerCase()) {
      case 'menstrual':
        return const Color(0xFFC0392B);
      case 'follicular':
        return const Color(0xFFE67E22);
      case 'ovulatory':
        return const Color(0xFF27AE60);
      case 'luteal':
        return const Color(0xFF8E44AD);
      default:
        return AppColors.primary;
    }
  }
}
