import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class CycleReferencesWidget extends StatefulWidget {
  const CycleReferencesWidget({super.key});

  @override
  State<CycleReferencesWidget> createState() => _CycleReferencesWidgetState();
}

class _CycleReferencesWidgetState extends State<CycleReferencesWidget> {
  bool _isOpen = false;

  final List<Map<String, dynamic>> _references = [
    {'num': 1, 'text': 'Sarwar R, et al. (1996). Changes in muscle strength, relaxation rate, and fatigability during the human menstrual cycle. J Physiol.'},
    {'num': 2, 'text': 'Hampson E. (1990). Estrogen-related variations in human spatial and articulatory motor skills. Psychoneuroendocrinology.'},
    {'num': 3, 'text': 'Facchinetti F, et al. (1991). Oral magnesium successfully relieves premenstrual mood changes. Obstet Gynecol.'},
    {'num': 4, 'text': 'Janse de Jonge XAK. (2003). Effects of the menstrual cycle on exercise performance. Sports Med.'},
    {'num': 5, 'text': 'Enns DL & Tiidus PM. (2010). The influence of estrogen on skeletal muscle. Sports Med.'},
    {'num': 6, 'text': 'Hewett TE, et al. (2007). Anterior cruciate ligament injuries in female athletes. Am J Sports Med.'},
    {'num': 7, 'text': 'Sohrabji F & Lewis DK. (2006). Estrogen–BDNF interactions. Front Neuroendocrinol.'},
    {'num': 8, 'text': 'Stokes T, et al. (2018). Role of dietary protein for muscle hypertrophy. Nutrients.'},
  ];

  @override
  Widget build(BuildContext context) {
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
        children: [
          ListTile(
            onTap: () => setState(() => _isOpen = !_isOpen),
            title: const Text(
              'Key References',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            trailing: Icon(
              _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 20,
              color: AppColors.textTertiary,
            ),
          ),
          if (_isOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  ..._references.map((ref) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '[${ref['num']}]',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              ref['text'],
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: const Border(
                        left: BorderSide(color: Colors.grey, width: 2),
                      ),
                    ),
                    child: const Text(
                      'Note: Cycle length and symptom experience vary between individuals. This reflects average 28-day patterns. Consult a healthcare provider for personalised guidance.',
                      style: TextStyle(
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textTertiary,
                        height: 1.4,
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
}
