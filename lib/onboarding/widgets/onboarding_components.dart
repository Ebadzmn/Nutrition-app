import 'package:flutter/material.dart';

class OnboardingComponents {
  static Widget buildEyebrow(String text) => Text(text.toUpperCase(), style: const TextStyle(fontSize: 12, letterSpacing: 4, fontWeight: FontWeight.w600, color: Color(0xFF8B7355)));
  
  static Widget buildTitle(String text, {String? accent, TextAlign align = TextAlign.left}) => RichText(textAlign: align, text: TextSpan(text: text, style: const TextStyle(fontFamily: 'Georgia', fontSize: 36, color: Color(0xFF2D2420), height: 1.1), children: [if (accent != null) TextSpan(text: accent, style: const TextStyle(fontStyle: FontStyle.italic, color: Color(0xFFE8927C)))]));
  
  static Widget buildSub(String text) => Padding(padding: const EdgeInsets.only(top: 16, bottom: 32), child: Text(text, style: const TextStyle(fontSize: 15, color: Color(0xFF3A2E28), height: 1.5)));
  
  static Widget buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(text.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Color(0xFF8B7355))));

  static Widget buildPrimaryButton({required String text, VoidCallback? onPressed}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: onPressed == null ? null : const LinearGradient(colors: [Color(0xFFE8927C), Color(0xFFA78BCA)]), color: onPressed == null ? Colors.grey.withOpacity(0.3) : null),
      child: ElevatedButton(onPressed: onPressed, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
    );
  }

  static Widget buildBulletPoint(Color dotColor, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6.0, right: 12.0),
          child: Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
        ),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 15, color: Color(0xFF3A2E28), height: 1.4))),
      ],
    );
  }

  static Widget buildToggleOption({required String label, required bool selected, required VoidCallback onSelect}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(color: selected ? const Color(0xFFE8927C).withOpacity(0.08) : const Color(0xFFEDE6DD).withOpacity(0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: selected ? const Color(0xFFE8927C) : const Color(0xFFD4C5B9), width: 1.0)),
          child: Row(children: [Expanded(child: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: selected ? const Color(0xFF2D2420) : const Color(0xFF5C4A3A))))]),
        ),
      ),
    );
  }

  static Widget buildRadioOption({required String label, required bool selected, required VoidCallback onSelect}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF3E5E1) : const Color(0xFFEAE5DE), 
            borderRadius: BorderRadius.circular(12), 
            border: Border.all(color: selected ? const Color(0xFFE8927C) : const Color(0xFFD4C5B9), width: 1.0)
          ),
          child: Row(
            children: [
              Expanded(child: Text(label, style: TextStyle(fontSize: 15, fontWeight: selected ? FontWeight.w600 : FontWeight.w500, color: const Color(0xFF3A2E28)))),
              Container(
                width: 22, height: 22, 
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: selected ? const Color(0xFFE8927C) : const Color(0xFFD4C5B9), width: 1.0), color: selected ? const Color(0xFFE8927C) : Colors.transparent), 
                child: selected ? const Icon(Icons.check, size: 14, color: Colors.white) : null
              )
            ]
          ),
        ),
      ),
    );
  }

  static Widget buildDropdownSelection({required String label, required String hint, required String? value, required List<String> options, required Function(String?) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel(label),
        Container(
          width: double.infinity,
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1920),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value?.isEmpty ?? true ? null : value,
              hint: Text(hint, style: const TextStyle(color: Color(0xFF8A8794), fontSize: 15)),
              icon: const SizedBox.shrink(), // Hiding the dropdown arrow to match design exactly
              dropdownColor: const Color(0xFF1B1920),
              style: const TextStyle(fontSize: 15, color: Colors.white),
              items: options.map((String opt) => DropdownMenuItem<String>(value: opt, child: Text(opt, style: const TextStyle(color: Colors.white)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  static Widget buildKeyValueDropdownSelection({
    required String label,
    required String hint,
    required String? value,
    required List<Map<String, String>> options,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel(label),
        Container(
          width: double.infinity,
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1920),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value?.isEmpty ?? true ? null : value,
              hint: Text(hint, style: const TextStyle(color: const Color(0xFF8A8794), fontSize: 15)),
              icon: const SizedBox.shrink(),
              dropdownColor: const Color(0xFF1B1920),
              style: const TextStyle(fontSize: 15, color: Colors.white),
              items: options.map((opt) => DropdownMenuItem<String>(
                value: opt['value'],
                child: Text(opt['label'] ?? '', style: const TextStyle(color: Colors.white)),
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  static Widget buildSlider(String label, int value, double min, double max, Function(double) onChange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel(label),
        Center(child: Text('$value days', style: const TextStyle(fontFamily: 'Georgia', fontSize: 24, color: Color(0xFFE8927C)))),
        Slider(value: value.toDouble(), min: min, max: max, activeColor: const Color(0xFFE8927C), inactiveColor: const Color(0xFFD4C5B9), onChanged: onChange),
      ],
    );
  }

  static Widget buildSummaryRow(String k, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(k, style: const TextStyle(color: Color(0xFF8B7355))), Text(v, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D2420)))]));
}

class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedCirclePainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.dashWidth = 6.0,
    this.dashSpace = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = strokeWidth..style = PaintingStyle.stroke;
    final radius = size.width / 2;
    final circumference = 2 * 3.141592653589793 * radius;
    final dashCount = (circumference / (dashWidth + dashSpace)).floor();
    final actualDashSpace = (circumference - (dashCount * dashWidth)) / dashCount;
    final sweepAngle = (dashWidth / circumference) * 2 * 3.141592653589793;
    final spaceAngle = (actualDashSpace / circumference) * 2 * 3.141592653589793;
    
    double currentAngle = 0;
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(Rect.fromCircle(center: Offset(radius, radius), radius: radius), currentAngle, sweepAngle, false, paint);
      currentAngle += sweepAngle + spaceAngle;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
