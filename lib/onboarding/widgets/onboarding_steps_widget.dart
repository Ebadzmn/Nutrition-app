import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../controller/onboarding_controller.dart';
import 'onboarding_components.dart';

class StepPhotoWidget extends StatelessWidget {
  final OnboardingController controller = Get.find<OnboardingController>();
  StepPhotoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 30),
        OnboardingComponents.buildEyebrow('WELCOME'),
        const SizedBox(height: 12),
        OnboardingComponents.buildTitle(
          'Add a\n',
          accent: 'profile photo',
          align: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'Put a face to your profile — you can always\nchange this later in settings.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Color(0xFF3A2E28), height: 1.5),
        ),
        const SizedBox(height: 60),
        Obx(
          () => GestureDetector(
            onTap: () async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                source: ImageSource.gallery,
              );
              if (image != null) controller.profilePicture.value = image.path;
            },
            child: CustomPaint(
              painter: DashedCirclePainter(color: const Color(0xFFD4C5B9)),
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE6DD).withOpacity(0.3),
                  shape: BoxShape.circle,
                  image: controller.profilePicture.value != null
                      ? DecorationImage(
                          image: FileImage(
                            File(controller.profilePicture.value!),
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: controller.profilePicture.value == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 36,
                            color: Color(0xFF3A2E28),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap to add',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8B7355),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 100),
        OnboardingComponents.buildPrimaryButton(
          text: 'Continue',
          onPressed: controller.nextStep,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: controller.nextStep,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Skip for now',
            style: TextStyle(
              color: Color(0xFF8B7355),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class StepWelcomeWidget extends StatelessWidget {
  final OnboardingController controller = Get.find<OnboardingController>();
  StepWelcomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingComponents.buildEyebrow('YOUR CYCLE PROFILE'),
        const SizedBox(height: 12),
        OnboardingComponents.buildTitle(
          'Let\'s build your\n',
          accent: 'personal blueprint',
        ),
        const SizedBox(height: 16),
        const Text(
          'To give you accurate, personalised training and nutrition guidance, we need to understand your hormonal landscape. This takes about 3 minutes.',
          style: TextStyle(fontSize: 15, color: Color(0xFF3A2E28), height: 1.5),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE6DD).withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD4C5B9), width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OnboardingComponents.buildEyebrow('WHAT YOU\'LL GET'),
              const SizedBox(height: 20),
              OnboardingComponents.buildBulletPoint(
                const Color(0xFFE8927C),
                'Training recommendations matched to your exact hormonal profile',
              ),
              const SizedBox(height: 16),
              OnboardingComponents.buildBulletPoint(
                const Color(0xFFA78BCA),
                'Nutrition guidance that adapts to where you are in your cycle',
              ),
              const SizedBox(height: 16),
              OnboardingComponents.buildBulletPoint(
                const Color(0xFF8BCAA7),
                'Accurate phase predictions — or subjective-led tracking if needed',
              ),
              const SizedBox(height: 16),
              OnboardingComponents.buildBulletPoint(
                const Color(0xFF8BA7CA),
                'Symptom patterns that help you understand your body over time',
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'HerWellness is for informational purposes only and is not a substitute for professional medical advice, diagnosis, or treatment. Always consult your healthcare provider with any health questions.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Color(0xFF8B7355), height: 1.5),
        ),
        const SizedBox(height: 32),
        OnboardingComponents.buildPrimaryButton(
          text: 'Get started',
          onPressed: controller.nextStep,
        ),
      ],
    );
  }
}

class StepContraceptionWidget extends StatelessWidget {
  final OnboardingController controller = Get.find<OnboardingController>();
  StepContraceptionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final options = controller.dbContraceptions.isNotEmpty
          ? controller.dbContraceptions
              .map((c) => {'id': c['key'], 'title': c['title']})
              .toList()
          : [
              {'id': 'pill', 'title': 'Combined Pill'},
              {'id': 'mirena', 'title': 'Hormonal IUD'},
              {'id': 'implant', 'title': 'Implant'},
              {'id': 'injection', 'title': 'Injection'},
              {'id': 'mini', 'title': 'Mini Pill'},
              {'id': 'none', 'title': 'No hormonal contraception'},
            ];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingComponents.buildEyebrow('STEP 1 OF 6'),
          const SizedBox(height: 12),
          OnboardingComponents.buildTitle('What\'s your\ncurrent situation?'),
          OnboardingComponents.buildSub(
            'This shapes everything — your hormonal environment, how we predict your phases, and what guidance makes sense for you.',
          ),
          ...options.map(
            (opt) => OnboardingComponents.buildToggleOption(
              label: opt['title']!,
              selected: controller.contraception.value == opt['id'],
              onSelect: () => controller.contraception.value = opt['id']!,
            ),
          ),
          const SizedBox(height: 32),
          OnboardingComponents.buildPrimaryButton(
            text: 'Continue',
            onPressed: (controller.contraception.value?.isEmpty ?? true)
                ? null
                : controller.nextStep,
          ),
        ],
      );
    });
  }
}

class StepContraceptionDetailsWidget extends StatelessWidget {
  final OnboardingController controller = Get.find<OnboardingController>();
  StepContraceptionDetailsWidget({super.key});

  /// Build a question section from a list of options with the same questionKey.
  Widget _buildApiQuestionSection(
    String questionLabel,
    String questionKey,
    List<Map<String, dynamic>> opts,
  ) {
    final type = opts.isNotEmpty ? opts.first['type']?.toString() ?? 'toggle' : 'toggle';

    if (type == 'select') {
      // Use dropdown
      String? currentVal;
      if (questionKey == 'pillType') currentVal = controller.pillType.value;
      else if (questionKey == 'pillProgestogen') currentVal = controller.pillProgestogen.value;
      else if (questionKey == 'miniType') currentVal = controller.miniType.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingComponents.buildKeyValueDropdownSelection(
            label: questionLabel.toUpperCase(),
            hint: 'Select if known...',
            value: currentVal,
            options: opts.map((o) => {
              'value': o['value'].toString(),
              'label': o['label'].toString(),
            }).toList(),
            onChanged: (v) {
              if (questionKey == 'pillType') controller.pillType.value = v;
              else if (questionKey == 'pillProgestogen') controller.pillProgestogen.value = v;
              else if (questionKey == 'miniType') controller.miniType.value = v;
            },
          ),
          const SizedBox(height: 20),
        ],
      );
    } else {
      // Use radio/toggle options
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingComponents.buildLabel(questionLabel.toUpperCase()),
          ...opts.map((opt) {
            final val = opt['value']?.toString() ?? '';
            final label = opt['label']?.toString() ?? '';
            bool isSelected = false;
            VoidCallback onSelect = () {};

            if (questionKey == 'pillFreeWeek') {
              isSelected = controller.pillFreeWeek.value?.toString() == val;
              onSelect = () => controller.pillFreeWeek.value = val == 'true';
            } else if (questionKey == 'iudPeriod') {
              isSelected = controller.iudPeriod.value == val;
              onSelect = () => controller.iudPeriod.value = val;
            } else if (questionKey == 'iudOvulating') {
              isSelected = controller.iudOvulating.value?.toString() == val;
              onSelect = () => controller.iudOvulating.value = val;
            } else if (questionKey == 'implantBleed') {
              isSelected = controller.implantBleed.value == val;
              onSelect = () => controller.implantBleed.value = val;
            } else if (questionKey == 'implantPattern') {
              isSelected = controller.implantPattern.value?.toString() == val;
              onSelect = () => controller.implantPattern.value = val == 'true';
            } else if (questionKey == 'injectionBleed') {
              isSelected = controller.injectionBleed.value == val;
              onSelect = () => controller.injectionBleed.value = val;
            } else if (questionKey == 'miniOvulating') {
              isSelected = controller.miniOvulating.value?.toString() == val;
              onSelect = () => controller.miniOvulating.value = val == 'true';
            } else if (questionKey == 'cycleRegular') {
              isSelected = controller.cycleRegular.value.toString() == val;
              onSelect = () => controller.cycleRegular.value = val == 'true';
            } else if (questionKey == 'alreadyTracking') {
              isSelected = controller.alreadyTracking.value == val;
              onSelect = () => controller.alreadyTracking.value = val;
            }

            return OnboardingComponents.buildRadioOption(
              label: label,
              selected: isSelected,
              onSelect: onSelect,
            );
          }).toList(),
          const SizedBox(height: 24),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final c = controller.contraception.value ?? '';
      final grouped = controller.getDetailOptionsForCurrentContraception();

      // Title based on selected contraception label from API
      final contraceptionTitle = controller.dbContraceptions.isNotEmpty
          ? (controller.dbContraceptions
                .firstWhere((x) => x['key'] == c, orElse: () => {})['title']
                ?.toString() ?? c)
          : (c == 'none' ? 'Natural cycle' : 'About your contraception');

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingComponents.buildEyebrow('STEP 2 OF 6'),
          const SizedBox(height: 12),
          OnboardingComponents.buildTitle(contraceptionTitle),
          const SizedBox(height: 24),
          if (grouped.isNotEmpty) ...[
            // API-driven: render each question group
            ...grouped.entries.map((entry) {
              final qKey = entry.key;
              final opts = entry.value;
              final questionLabel = opts.isNotEmpty
                  ? opts.first['questionLabel']?.toString() ?? qKey
                  : qKey;
              return _buildApiQuestionSection(questionLabel, qKey, opts);
            }).toList(),
          ] else if (c == 'pill') ...[
            // Fallback hardcoded for pill
            OnboardingComponents.buildDropdownSelection(
              label: 'PILL FORMULATION TYPE',
              hint: 'Select if known...',
              value: controller.pillType.value,
              options: ['Monophasic (same dose every day)', 'Biphasic (2 different doses)', 'Triphasic (3 different doses)', 'I\'m not sure'],
              onChanged: (v) => controller.pillType.value = v,
            ),
            const SizedBox(height: 20),
            OnboardingComponents.buildDropdownSelection(
              label: 'PROGESTOGEN TYPE (CHECK YOUR LEAFLET)',
              hint: 'Select if known...',
              value: controller.pillProgestogen.value,
              options: ['Androgenic', 'Anti-androgenic', 'Neutral', 'Unknown / not sure'],
              onChanged: (v) => controller.pillProgestogen.value = v,
            ),
            const SizedBox(height: 24),
            OnboardingComponents.buildLabel('DO YOU TAKE A PILL-FREE / PLACEBO WEEK?'),
            OnboardingComponents.buildRadioOption(label: 'Yes — I have a withdrawal bleed', selected: controller.pillFreeWeek.value == true, onSelect: () => controller.pillFreeWeek.value = true),
            OnboardingComponents.buildRadioOption(label: 'No — I take it continuously', selected: controller.pillFreeWeek.value == false, onSelect: () => controller.pillFreeWeek.value = false),
          ] else if (c == 'none') ...[
            OnboardingComponents.buildLabel('ARE YOUR CYCLES GENERALLY REGULAR?'),
            OnboardingComponents.buildRadioOption(label: 'Yes — fairly predictable', selected: controller.cycleRegular.value == true, onSelect: () => controller.cycleRegular.value = true),
            OnboardingComponents.buildRadioOption(label: 'No — quite variable or irregular', selected: controller.cycleRegular.value == false, onSelect: () => controller.cycleRegular.value = false),
            const SizedBox(height: 24),
            OnboardingComponents.buildLabel('DO YOU TRACK YOUR CYCLE ALREADY?'),
            OnboardingComponents.buildRadioOption(label: 'Yes — using an app', selected: controller.alreadyTracking.value == 'app', onSelect: () => controller.alreadyTracking.value = 'app'),
            OnboardingComponents.buildRadioOption(label: 'Yes — basal body temperature', selected: controller.alreadyTracking.value == 'bbt', onSelect: () => controller.alreadyTracking.value = 'bbt'),
            OnboardingComponents.buildRadioOption(label: 'No — starting fresh', selected: controller.alreadyTracking.value == 'none', onSelect: () => controller.alreadyTracking.value = 'none'),
          ] else ...[
            const Center(child: Text('No further details needed for this selection.', style: TextStyle(color: Color(0xFF8B7355)))),
          ],
          const SizedBox(height: 100),
          OnboardingComponents.buildPrimaryButton(text: 'Continue', onPressed: controller.nextStep),
        ],
      );
    });
  }
}

class StepCycleDatesWidget extends StatelessWidget {
  final OnboardingController controller = Get.find<OnboardingController>();
  StepCycleDatesWidget({super.key});

  Widget _buildDateBox(String hint, String value) {
    bool isHint = value == 'Day' || value == 'Month' || value == 'Year';
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: const Color(0xFF1B1920),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isHint ? hint : value,
        style: TextStyle(
          color: isHint ? const Color(0xFF8A8794) : Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildPhaseBar() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(flex: 5, child: Container(height: 6, decoration: BoxDecoration(color: const Color(0xFFC0473A), borderRadius: BorderRadius.circular(3)))),
            const SizedBox(width: 4),
            Expanded(flex: 9, child: Container(height: 6, decoration: BoxDecoration(color: const Color(0xFFE88A31), borderRadius: BorderRadius.circular(3)))),
            const SizedBox(width: 4),
            Expanded(flex: 4, child: Container(height: 6, decoration: BoxDecoration(color: const Color(0xFF28A745), borderRadius: BorderRadius.circular(3)))),
            const SizedBox(width: 4),
            Expanded(flex: 10, child: Container(height: 6, decoration: BoxDecoration(color: const Color(0xFF8956A9), borderRadius: BorderRadius.circular(3)))),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: const [
            Expanded(flex: 5, child: Text('Menstrual', style: TextStyle(fontSize: 10, color: Color(0xFF7A6856)))),
            Expanded(flex: 9, child: Text('Follicular', style: TextStyle(fontSize: 10, color: Color(0xFF7A6856)), textAlign: TextAlign.center)),
            Expanded(flex: 4, child: Text('Ovulatory', style: TextStyle(fontSize: 10, color: Color(0xFF7A6856)), textAlign: TextAlign.center)),
            Expanded(flex: 10, child: Text('Luteal', style: TextStyle(fontSize: 10, color: Color(0xFF7A6856)), textAlign: TextAlign.right)),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingComponents.buildEyebrow('Step 3 of 6'),
        OnboardingComponents.buildTitle(
          'When was your\n',
          accent: 'last period?',
        ),
        OnboardingComponents.buildSub(
          'This anchors our phase calculations for today — and predicts your next cycle.',
        ),
        OnboardingComponents.buildLabel('First day of your last period'),
        Obx(() {
          DateTime selectedDate = DateTime(
            controller.lastYear.value ?? DateTime.now().year,
            controller.lastMonth.value ?? DateTime.now().month,
            controller.lastDay.value ?? DateTime.now().day,
          );
          
          String dayStr = controller.lastDay.value?.toString().padLeft(2, '0') ?? 'Day';
          String monthStr = controller.lastMonth.value != null ? DateFormat('MMM').format(selectedDate) : 'Month';
          String yearStr = controller.lastYear.value?.toString() ?? 'Year';

          return InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: Get.context!,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                builder: (c, child) => Theme(
                  data: Theme.of(c).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFFE8927C),
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) {
                controller.lastDay.value = picked.day;
                controller.lastMonth.value = picked.month;
                controller.lastYear.value = picked.year;
              }
            },
            child: Row(
              children: [
                Expanded(child: _buildDateBox('Day', dayStr)),
                const SizedBox(width: 8),
                Expanded(child: _buildDateBox('Month', monthStr)),
                const SizedBox(width: 8),
                Expanded(child: _buildDateBox('Year', yearStr)),
              ],
            ),
          );
        }),
        const SizedBox(height: 32),
        OnboardingComponents.buildLabel('AVERAGE CYCLE LENGTH'),
        Obx(() {
          int cycleValue = controller.cycleLength.value;
          return Column(
            children: [
              Center(child: Text('$cycleValue days', style: const TextStyle(fontFamily: 'Georgia', fontSize: 28, color: Color(0xFFE8927C)))),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  activeTrackColor: const Color(0xFFD4C5B9),
                  inactiveTrackColor: const Color(0xFFD4C5B9),
                  thumbColor: const Color(0xFFF5F3F0),
                  overlayColor: const Color(0xFFE8927C).withOpacity(0.2),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, pressedElevation: 4),
                ),
                child: Slider(
                  value: cycleValue.toDouble(),
                  min: 21,
                  max: 40,
                  onChanged: (v) => controller.cycleLength.value = v.toInt(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('21', style: TextStyle(color: Color(0xFF7A6856), fontSize: 12)),
                    Text('31', style: TextStyle(color: Color(0xFF7A6856), fontSize: 12)),
                    Text('40', style: TextStyle(color: Color(0xFF7A6856), fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildPhaseBar(),
            ],
          );
        }),
        const SizedBox(height: 32),
        OnboardingComponents.buildLabel('PERIOD LENGTH (DAYS OF BLEEDING)'),
        Obx(() {
          int periodValue = controller.periodLength.value;
          return Column(
            children: [
              Center(child: Text('$periodValue days', style: const TextStyle(fontFamily: 'Georgia', fontSize: 28, color: Color(0xFFE8927C)))),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  activeTrackColor: const Color(0xFFD4C5B9),
                  inactiveTrackColor: const Color(0xFFD4C5B9),
                  thumbColor: const Color(0xFFF5F3F0),
                  overlayColor: const Color(0xFFE8927C).withOpacity(0.2),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, pressedElevation: 4),
                ),
                child: Slider(
                  value: periodValue.toDouble(),
                  min: 1,
                  max: 10,
                  onChanged: (v) => controller.periodLength.value = v.toInt(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('1', style: TextStyle(color: Color(0xFF7A6856), fontSize: 12)),
                    Text('6', style: TextStyle(color: Color(0xFF7A6856), fontSize: 12)),
                    Text('10', style: TextStyle(color: Color(0xFF7A6856), fontSize: 12)),
                  ],
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 40),
        OnboardingComponents.buildPrimaryButton(
          text: 'Continue',
          onPressed: controller.nextStep,
        ),
      ],
    );
  }
}

class StepTrackingWidget extends StatelessWidget {
  final OnboardingController controller = Get.find<OnboardingController>();
  StepTrackingWidget({super.key});

  Widget _buildTrackingOption({
    required String icon,
    required String title,
    required String subtitle,
    required String description,
    required bool selected,
    required VoidCallback onSelect,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF0EAF5) : const Color(0xFFEAE5DE),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? const Color(0xFFA78BCA)
                  : const Color(0xFFD4C5B9),
              width: 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDED5C9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(icon, style: const TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2420),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8B7355),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF3A2E28),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final canUseCal = controller.canUseCalendar;
      final canUseB = controller.canUseBBT;

      final subtitle = !canUseCal
          ? 'Since your contraception may suppress your natural cycle, we\'ll use your daily signals as the primary guide.'
          : 'Choose how we determine which phase you\'re in each day.';

      final selectedMethod = controller.trackingMethod.value ?? (canUseCal ? 'calendar' : 'subjective');

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingComponents.buildEyebrow('STEP 4 OF 7'),
          const SizedBox(height: 12),
          OnboardingComponents.buildTitle(
            'How will you\n',
            accent: 'track your cycle?',
          ),
          OnboardingComponents.buildSub(subtitle),
          if (canUseCal)
            _buildTrackingOption(
              icon: '📅',
              title: 'Calendar + cycle length',
              subtitle: 'Recommended starting point',
              description: 'Uses your last period date and average cycle length to predict which phase you\'re in. Accuracy improves as we learn your patterns.',
              selected: selectedMethod == 'calendar',
              onSelect: () => controller.trackingMethod.value = 'calendar',
            ),
          if (canUseB)
            _buildTrackingOption(
              icon: '🌡️',
              title: 'Basal Body Temperature',
              subtitle: 'Highest accuracy — confirms ovulation',
              description: 'Log your temperature every morning. BBT rises ~0.3–0.5°C after ovulation, confirming the start of the luteal phase.',
              selected: selectedMethod == 'bbt',
              onSelect: () => controller.trackingMethod.value = 'bbt',
            ),
          _buildTrackingOption(
            icon: '💬',
            title: 'Subjective daily signals',
            subtitle: !canUseCal ? 'Recommended for your situation' : 'Best combined with calendar',
            description: 'Log energy, mood, sleep, and training performance daily. Our algorithm learns your personal patterns and maps them to hormonal phases.',
            selected: selectedMethod == 'subjective',
            onSelect: () => controller.trackingMethod.value = 'subjective',
          ),
          _buildTrackingOption(
            icon: '🔬',
            title: 'Combined approach',
            subtitle: 'Most powerful over time',
            description: 'Use all available signals together — calendar, symptoms, temperature, and subjective data.',
            selected: selectedMethod == 'combined',
            onSelect: () => controller.trackingMethod.value = 'combined',
          ),
          const SizedBox(height: 60),
          OnboardingComponents.buildPrimaryButton(
            text: 'Continue',
            onPressed: () {
              if (controller.trackingMethod.value == null) {
                controller.trackingMethod.value = selectedMethod;
              }
              controller.nextStep();
            },
          ),
        ],
      );
    });
  }
}

class StepDailyCheckinsWidget extends StatelessWidget {
  final OnboardingController controller = Get.find<OnboardingController>();
  StepDailyCheckinsWidget({super.key});

  Widget _buildCheckinOption(
    BuildContext context,
    Map<String, String> opt,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        if (isSelected) {
          controller.dailyCheckins.remove(opt['id']);
        } else {
          controller.dailyCheckins.add(opt['id']!);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEBF1EC) : const Color(0xFFEAE5DE),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF8DC0A1)
                : const Color(0xFFD4C5B9),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Text(opt['icon']!, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                opt['title']!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3A2E28),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Use full label as ID so it matches what the backend stores in daily_checkins
      final options = controller.dbDailyCheckins.isNotEmpty
          ? controller.dbDailyCheckins
              .map<Map<String, String>>((c) => {
                    'id': c['label'].toString(), // full label = ID sent to API
                    'icon': c['icon'].toString(),
                    'title': c['label'].toString(),
                  })
              .toList()
          : [
              {'id': 'Sleep quality', 'icon': '😴', 'title': 'Sleep quality'},
              {'id': 'Energy level', 'icon': '⚡', 'title': 'Energy level'},
              {'id': 'Training performance', 'icon': '🏋️', 'title': 'Training performance'},
              {'id': 'Mood & motivation', 'icon': '😤', 'title': 'Mood & motivation'},
              {'id': 'Bloating / GI', 'icon': '🤢', 'title': 'Bloating / GI'},
              {'id': 'Cravings', 'icon': '🍫', 'title': 'Cravings'},
              {'id': 'Hydration', 'icon': '💧', 'title': 'Hydration'},
              {'id': 'Resting HR / HRV', 'icon': '❤️', 'title': 'Resting HR / HRV'},
              {'id': 'Basal body temp', 'icon': '🌡️', 'title': 'Basal body temp'},
              {'id': 'Flow / bleeding', 'icon': '🩸', 'title': 'Flow / bleeding'},
            ];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingComponents.buildEyebrow('STEP 4 OF 6'),
          const SizedBox(height: 12),
          OnboardingComponents.buildTitle('Daily check-ins'),
          OnboardingComponents.buildSub(
            'Which signals do you want to log each day? These help us spot your patterns over time.',
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 56,
            ),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final opt = options[index];
              return Obx(() {
                // id is the full label — matches dailyCheckins list
                final isSelected = controller.dailyCheckins.contains(opt['id']);
                return _buildCheckinOption(context, opt, isSelected);
              });
            },
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFFEAE5DE),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD4C5B9), width: 1),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: Color(0xFFE8927C), width: 4),
                ),
              ),
              child: const Text(
                'Logging sleep, energy, and training performance gives us the most accurate picture of where you are hormonally.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF3A2E28),
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          OnboardingComponents.buildPrimaryButton(
            text: 'Continue',
            onPressed: controller.nextStep,
          ),
        ],
      );
    });
  }
}

class StepSymptomsGoalsWidget extends StatelessWidget {
  final OnboardingController controller = Get.find<OnboardingController>();
  StepSymptomsGoalsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final symptoms = controller.dbSymptoms.isNotEmpty
          ? controller.dbSymptoms
          : [
              'PMS mood changes',
              'Cramping',
              'Fatigue',
              'Bloating',
              'Cravings',
              'Headaches',
              'Breast tenderness',
              'Anxiety / low mood',
              'Sleep disruption',
              'Brain fog',
              'Skin breakouts',
              'None / minimal',
            ];

      final goals = controller.dbGoals.isNotEmpty
          ? controller.dbGoals
              .map((g) => {'id': g['value'], 'label': g['label']})
              .toList()
          : [
              {'id': 'build_muscle', 'label': 'Build strength & muscle'},
              {
                'id': 'improve_endurance',
                'label': 'Improve endurance / cardio fitness',
              },
              {'id': 'weight_loss', 'label': 'Lose body fat'},
              {'id': 'general_fitness', 'label': 'General health & wellbeing'},
              {
                'id': 'athletic_performance',
                'label': 'Athletic performance / competition',
              },
            ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingComponents.buildEyebrow('STEP 5 OF 6'),
          const SizedBox(height: 12),
          OnboardingComponents.buildTitle('Your experience\n', accent: '& goals'),
          OnboardingComponents.buildSub(
            'This helps us tailor guidance to what actually affects you, not just the average.',
          ),

          OnboardingComponents.buildLabel('SYMPTOMS YOU REGULARLY EXPERIENCE'),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: symptoms
                .map(
                  (sym) {
                    final isSelected = controller.selectedSymptoms.contains(sym);
                    return InkWell(
                      onTap: () {
                        if (isSelected) {
                          controller.selectedSymptoms.remove(sym);
                        } else {
                          controller.selectedSymptoms.add(sym);
                        }
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFF3E5E1)
                              : const Color(0xFFEAE5DE),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFE8927C)
                                : const Color(0xFFD4C5B9),
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          sym,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: const Color(0xFF3A2E28),
                          ),
                        ),
                      ),
                    );
                  },
                )
                .toList(),
          ),

          const SizedBox(height: 32),
          OnboardingComponents.buildLabel('PRIMARY TRAINING GOAL'),
          ...goals.map(
            (g) => OnboardingComponents.buildRadioOption(
              label: g['label']!,
              selected: controller.fitnessGoal.value == g['id'],
              onSelect: () => controller.fitnessGoal.value = g['id']!,
            ),
          ),
          const SizedBox(height: 40),
          OnboardingComponents.buildPrimaryButton(
            text: 'Continue',
            onPressed: controller.nextStep,
          ),
        ],
      );
    });
  }
}

class StepSummaryWidget extends StatelessWidget {
  final OnboardingController controller = Get.find<OnboardingController>();
  StepSummaryWidget({super.key});

  Widget _buildTableRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF8B7355),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D2420),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Look up the contraception title from API data
      final contraceptionKey = controller.contraception.value ?? '';
      final contraceptionData = controller.dbContraceptions.isNotEmpty
          ? controller.dbContraceptions.firstWhere(
              (x) => x['key'] == contraceptionKey,
              orElse: () => {},
            )
          : <String, dynamic>{};
      final contraceptionTitle = contraceptionData['title']?.toString() ??
          (contraceptionKey.isEmpty ? 'Not specified' : contraceptionKey);
      final contraceptionIcon = contraceptionData['icon']?.toString() ?? '🌸';

      // Look up the fitness goal label from API data
      final goalKey = controller.fitnessGoal.value;
      final goalData = controller.dbGoals.isNotEmpty
          ? controller.dbGoals.firstWhere(
              (g) => g['value'] == goalKey,
              orElse: () => {},
            )
          : <String, dynamic>{};
      final goalLabel = goalData['label']?.toString() ??
          (goalKey.isEmpty ? 'Not selected' : goalKey);


      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingComponents.buildEyebrow('STEP 6 OF 6'),
          const SizedBox(height: 12),
          OnboardingComponents.buildTitle('Your profile is\n', accent: 'ready'),
          OnboardingComponents.buildSub(
            'Here\'s a summary of what you\'ve told us — we\'ll use this to personalise everything.',
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEAE5DE),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4C5B9)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEEDFD9),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(contraceptionIcon, style: const TextStyle(fontSize: 24)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contraceptionTitle,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D2420),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Hormonal profile configured',
                              style: TextStyle(fontSize: 13, color: Color(0xFF8B7355)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: Color(0xFFD4C5B9)),
                _buildTableRow('Cycle length', '${controller.cycleLength.value} days'),
                const Divider(height: 1, thickness: 1, color: Color(0xFFD4C5B9)),
                _buildTableRow('Period length', '${controller.periodLength.value} days'),
                const Divider(height: 1, thickness: 1, color: Color(0xFFD4C5B9)),
                _buildTableRow('Training goal', goalLabel),
                if (controller.selectedSymptoms.isNotEmpty) ...[
                  const Divider(height: 1, thickness: 1, color: Color(0xFFD4C5B9)),
                  _buildTableRow('Symptoms tracked', '${controller.selectedSymptoms.length} selected'),
                ],
                if (controller.dailyCheckins.isNotEmpty) ...[
                  const Divider(height: 1, thickness: 1, color: Color(0xFFD4C5B9)),
                  _buildTableRow('Daily check-ins', '${controller.dailyCheckins.length} selected'),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFEAE5DE),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4C5B9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OnboardingComponents.buildLabel('HOW WE\'LL GUIDE YOU'),
                const SizedBox(height: 8),
                OnboardingComponents.buildBulletPoint(
                  const Color(0xFFE8927C),
                  'Personalised training based on your hormonal profile and chosen goal',
                ),
                const SizedBox(height: 16),
                OnboardingComponents.buildBulletPoint(
                  const Color(0xFFA78BCA),
                  'Daily check-in insights mapped to your cycle phase patterns',
                ),
                const SizedBox(height: 16),
                OnboardingComponents.buildBulletPoint(
                  const Color(0xFF8BCAA7),
                  'Symptom tracking to help you understand your body over time',
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          OnboardingComponents.buildPrimaryButton(
            text: controller.isLoading.value ? 'Finishing...' : 'Start my journey →',
            onPressed: controller.isLoading.value ? null : controller.completeOnboarding,
          ),
        ],
      );
    });
  }
}
