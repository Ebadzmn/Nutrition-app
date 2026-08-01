import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:herwellness_flutter/home/controller/home_controller.dart';
import '../../core/app_colors.dart';
import '../../core/network/api_client.dart';

class PhaseExplorerWidget extends StatefulWidget {
  const PhaseExplorerWidget({super.key});

  @override
  State<PhaseExplorerWidget> createState() => _PhaseExplorerWidgetState();
}

class _PhaseExplorerWidgetState extends State<PhaseExplorerWidget> {
  String _activePhase = 'follicular';
  String _activeTab = 'hormones';

  Map<String, dynamic> _phasesFromApi = {};
  bool _isLoadingGuides = false;

  final HomeController _homeController = Get.find<HomeController>();

  final Map<String, dynamic> _phases = {
    'menstrual': {
      'id': 'menstrual',
      'label': 'Menstrual',
      'emoji': '🩸',
      'days': 'Days 1–5',
      'color': const Color(0xFFC0392B),
      'softBg': const Color(0xFFFADBD8),
      'tagline':
          'Rest, restore, and look inward — your body is doing its deepest work.',
      'hormones': [
        {
          'name': 'Oestrogen',
          'level': 1,
          'desc':
              'At its lowest. Drop triggers lining to shed. Reduces serotonin and dopamine → fatigue and low mood.',
        },
        {
          'name': 'Progesterone',
          'level': 1,
          'desc':
              'Also very low. Its fall from luteal triggers menstruation. Less calming GABA activity.',
        },
        {
          'name': 'Prostaglandins',
          'level': 4,
          'desc':
              'Elevated. Inflammatory compounds cause uterine contractions, cramping, and gut motility issues.',
        },
        {
          'name': 'FSH & LH',
          'level': 2,
          'desc':
              'FSH begins to rise slightly, stimulating follicle recruitment for the next cycle.',
        },
      ],
      'physical': [
        'Core temperature at its lowest — cardiovascular performance marginally better but you feel worst',
        'Blood loss reduces iron → impairs oxygen transport, contributing to fatigue',
        'Prostaglandins cause systemic inflammation — joints ache, muscles feel heavy',
        'GI motility increases — bloating, cramping, nausea common',
      ],
      'training': [
        'Low-intensity movement: walking, yoga, gentle stretching, swimming',
        'Yin yoga and restorative practices — parasympathetic activation aids recovery',
        'Light resistance at RPE 5–6 can help with cramps via endorphin release',
      ],
      'nutrition': [
        'Iron-rich foods to replenish losses: red meat, lentils, spinach, pumpkin seeds',
        'Anti-inflammatory foods: omega-3s, turmeric, ginger, dark leafy greens',
        'Magnesium (dark chocolate, nuts, seeds) — reduces cramping and improves mood',
      ],
      'avoid': [
        'Alcohol — worsens inflammation',
        'Excess caffeine — can worsen cramping',
        'Refined sugar — spikes inflammation',
        'Salty processed foods — worsen bloating',
      ],
    },
    'follicular': {
      'id': 'follicular',
      'label': 'Follicular',
      'emoji': '🌱',
      'days': 'Days 6–13',
      'color': const Color(0xFFE67E22),
      'softBg': const Color(0xFFFDEBD0),
      'tagline':
          'Rising energy, rising ambition — this is your season of emergence.',
      'hormones': [
        {
          'name': 'Oestrogen',
          'level': 3,
          'desc':
              'Steadily rising as dominant follicle grows. Boosts serotonin, dopamine, acetylcholine, and BDNF.',
        },
        {
          'name': 'FSH',
          'level': 3,
          'desc':
              'Drives follicle maturation. Eventually suppressed by oestrogen.',
        },
        {
          'name': 'Testosterone',
          'level': 2,
          'desc':
              'Gradual rise — supports libido, motivation, and anabolic drive.',
        },
      ],
      'physical': [
        'Core temperature low — cardiovascular efficiency at its best; VO2 max performance superior',
        'Oestrogen promotes glycogen storage — body preferentially burns carbs',
        'Anabolic signalling improves — oestrogen supports muscle protein synthesis',
      ],
      'training': [
        'Introduce progressive overload — increase weights, intensity, or volume',
        'Strength training, HIIT, and high-intensity cardio — body handles it well',
        'Try new skills or movement patterns — neuroplasticity is higher',
      ],
      'nutrition': [
        'Carbohydrate-forward fuelling — insulin sensitivity is high',
        'Adequate protein (1.6–2.2g/kg) to support training',
        'Fermented foods (kefir, kimchi) support gut microbiome',
      ],
      'avoid': [
        'Appetite often lower — listen to hunger signals',
        'Best phase for dietary flexibility',
      ],
    },
    'ovulatory': {
      'id': 'ovulatory',
      'label': 'Ovulatory',
      'emoji': '✨',
      'days': 'Days 14–17',
      'color': const Color(0xFF27AE60),
      'softBg': const Color(0xFFD5F5E3),
      'tagline':
          'Peak power, peak presence — you are at your most magnetic and capable.',
      'hormones': [
        {
          'name': 'Oestrogen',
          'level': 5,
          'desc':
              'Peaks sharply — triggers LH surge. Oestradiol at highest point.',
        },
        {
          'name': 'LH',
          'level': 5,
          'desc': 'LH surge triggers ovulation — mature follicle ruptures.',
        },
        {
          'name': 'Testosterone',
          'level': 3,
          'desc': 'Peaks around ovulation — drives libido and assertiveness.',
        },
      ],
      'physical': [
        'Absolute peak physical capacity — strength, power, and anaerobic threshold are highest',
        'Core temperature remains low — optimal for endurance performance',
        'Increased joint laxity at peak due to oestrogen spike',
      ],
      'training': [
        'Maximum intensity efforts — test PRs in strength, power, or speed',
        'Competition days, events, and races — time them here',
        'HIIT, sprint work, and explosive power training',
      ],
      'nutrition': [
        'Support high output with adequate carbohydrate around training',
        'Cruciferous vegetables (broccoli) support oestrogen metabolism',
        'Antioxidants (berries, leafy greens) to manage oxidative stress',
      ],
      'avoid': [
        'Peak ligament laxity: always warm up thoroughly',
        'Activate glutes/hamstrings before lower body',
        'Avoid cutting movements when fatigued',
      ],
    },
    'luteal': {
      'id': 'luteal',
      'label': 'Luteal',
      'emoji': '🌕',
      'days': 'Days 18–28',
      'color': const Color(0xFF8E44AD),
      'softBg': const Color(0xFFE8DAEF),
      'tagline': 'Your body turns inward — honour it.',
      'hormones': [
        {
          'name': 'Progesterone',
          'level': 4,
          'desc':
              'Dominant hormone. Raises core temp, increases metabolic rate.',
        },
        {
          'name': 'Oestrogen',
          'level': 3,
          'desc': 'Secondary mid-luteal peak then falls.',
        },
        {
          'name': 'Serotonin',
          'level': 2,
          'desc': 'Falls as oestrogen drops → carbohydrate cravings, low mood.',
        },
      ],
      'physical': [
        'Core temperature rises 0.3–0.5°C — reduces cardiovascular efficiency',
        'Metabolic rate increases — genuine calorie needs rise ~100–300 kcal/day',
        'Fluid retention increases — bloating, breast tenderness common',
      ],
      'training': [
        'Early luteal: moderate training, strength work still productive',
        'Late luteal: shift lower — brisk walks, Pilates, moderate yoga',
        'Steady-state cardio at moderate intensity',
      ],
      'nutrition': [
        'Increase calories modestly (+100–300 kcal)',
        'Complex carbohydrates (sweet potato, oats) raise serotonin',
        'Magnesium (300–400mg) reduces PMS symptoms',
      ],
      'avoid': [
        'Refined sugar — worsens mood swings',
        'Alcohol — severely worsens PMS mood',
        'Excessive caffeine — worsens anxiety and sleep',
        'High sodium — amplifies bloating',
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    _setActivePhaseFromHomeController();
    _loadPhaseGuidesFromApi();
  }

  void _setActivePhaseFromHomeController() {
    final homePhase = _homeController.currentPhase.value;
    String phaseId;
    switch (homePhase) {
      case 'Menstruation':
        phaseId = 'menstrual';
        break;
      case 'Follicular':
        phaseId = 'follicular';
        break;
      case 'Ovulation':
        phaseId = 'ovulatory';
        break;
      case 'Luteal':
        phaseId = 'luteal';
        break;
      default:
        phaseId = 'follicular';
    }
    if (mounted) {
      setState(() {
        _activePhase = phaseId;
      });
    }
  }

  void _loadPhaseGuidesFromApi() async {
    try {
      if (mounted) setState(() => _isLoadingGuides = true);
      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.get('/cycle/phase-guide');
      if (response.isSuccess &&
          response.data != null &&
          response.data is List) {
        final List<dynamic> list = response.data;
        final Map<String, dynamic> mapped = {};
        for (var item in list) {
          final id = item['id'] as String;
          final colorStr = item['color'] as String;
          final softBgStr = item['softBg'] as String;

          mapped[id] = {
            'id': id,
            'label': item['label'],
            'emoji': item['emoji'],
            'days': item['days'],
            'color': _parseHexColor(colorStr, const Color(0xFFC0392B)),
            'softBg': _parseHexColor(softBgStr, const Color(0xFFFADBD8)),
            'tagline': item['tagline'],
            'hormones': List<Map<String, dynamic>>.from(item['hormones'] ?? []),
            'physical': List<String>.from(item['physical'] ?? []),
            'training': List<String>.from(item['training'] ?? []),
            'nutrition': List<String>.from(item['nutrition'] ?? []),
            'avoid': List<String>.from(item['avoid'] ?? []),
          };
        }
        if (mounted) {
          setState(() {
            _phasesFromApi = mapped;
          });
        }
      }
    } catch (e) {
      debugPrint("Failed to load phase guides from API: $e");
    } finally {
      if (mounted) setState(() => _isLoadingGuides = false);
    }
  }

  Color _parseHexColor(String hexStr, Color fallback) {
    try {
      final cleanHex = hexStr.replaceAll('#', '');
      if (cleanHex.length == 6) {
        return Color(int.parse('FF$cleanHex', radix: 16));
      } else if (cleanHex.length == 8) {
        return Color(int.parse(cleanHex, radix: 16));
      }
    } catch (_) {}
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final phases = _phasesFromApi.isNotEmpty ? _phasesFromApi : _phases;
    final phase = phases[_activePhase];
    final color = phase['color'] as Color;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cycle Phase Guide',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Text(
                  'Evidence-based training & nutrition',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: phases.values.map((p) {
                      final isActive = _activePhase == p['id'];
                      return GestureDetector(
                        onTap: () => setState(() => _activePhase = p['id']),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 85,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isActive ? p['color'] : Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isActive
                                  ? Colors.transparent
                                  : Colors.grey[200]!,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                p['emoji'],
                                style: const TextStyle(fontSize: 22),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                p['label'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isActive
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                p['days'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isActive
                                      ? Colors.white.withOpacity(0.8)
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: phase['softBg'],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(phase['emoji'], style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      '${phase['label']} Phase — ${phase['days']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '"${phase['tagline']}"',
                  style: const TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildTabButton('hormones', '🧬', 'Hormones'),
                  _buildTabButton('physical', '🫀', 'Body'),
                  _buildTabButton('training', '🏋️', 'Training'),
                  _buildTabButton('nutrition', '🍽️', 'Nutrition'),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildTabContent(phase, color),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String id, String emoji, String label) {
    final isActive = _activeTab == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? Colors.grey[300]! : Colors.transparent,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? AppColors.textPrimary
                      : AppColors.textSecondary.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(Map<String, dynamic> phase, Color color) {
    if (_activeTab == 'hormones') {
      final hormones = phase['hormones'] as List;
      return Column(
        children: hormones.map((h) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  h['name'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(5, (index) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: index < h['level'] ? color : Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                Text(
                  h['desc'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    final items = phase[_activeTab] as List;
    final avoidItems = phase['avoid'] as List?;
    final isNutrition = _activeTab == 'nutrition';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        if (isNutrition && avoidItems != null && avoidItems.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LIMIT / AVOID',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[500],
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                ...avoidItems.map((avoidItem) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '✕',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            avoidItem,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
