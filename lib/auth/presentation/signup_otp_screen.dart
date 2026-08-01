import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import '../../core/app_route.dart';
import '../controller/auth_controller.dart';

class SignupOTPScreen extends StatefulWidget {
  const SignupOTPScreen({super.key});

  @override
  State<SignupOTPScreen> createState() => _SignupOTPScreenState();
}

class _SignupOTPScreenState extends State<SignupOTPScreen> {
  final List<TextEditingController> _otpControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final AuthController controller = Get.find<AuthController>();

  @override
  void dispose() {
    for (var c in _otpControllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _otp => _otpControllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2D2420)),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          _buildBackgroundTexture(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Verify Signup',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF2D2420),
                    ),
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    text: TextSpan(
                      text: 'We\'ve sent a 4-digit signup code to ',
                      style: const TextStyle(fontSize: 15, color: Color(0xFF5C4A3A), height: 1.5),
                      children: [
                        TextSpan(
                          text: controller.email.value,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D2420)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(4, (index) => _buildOTPField(index)),
                  ),
                  const SizedBox(height: 40),
                  Obx(() => _buildPrimaryButton(
                    text: controller.isLoading.value ? 'Verifying...' : 'Verify & Continue',
                    onPressed: controller.isLoading.value ? () {} : () async {
                      if (_otp.length < 4) {
                        Get.snackbar('Error', 'Please enter the full 4-digit code', snackPosition: SnackPosition.BOTTOM);
                        return;
                      }
                      await controller.verifySignupOTP(_otp);
                    },
                  )),
                  const SizedBox(height: 32),
                  Center(
                    child: TextButton(
                      onPressed: () => Get.snackbar('Success', 'Signup OTP resent', snackPosition: SnackPosition.BOTTOM),
                      child: const Text('Resend Code', style: TextStyle(color: Color(0xFFE8927C), fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOTPField(int index) {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        color: const Color(0xFFEDE6DD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4C5B9), width: 1.5),
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D2420)),
        decoration: const InputDecoration(counterText: '', border: InputBorder.none),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) _focusNodes[index + 1].requestFocus();
          else if (value.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
        },
      ),
    );
  }

  Widget _buildBackgroundTexture() {
    return Stack(
      children: [
        Positioned.fill(child: Container(decoration: BoxDecoration(gradient: RadialGradient(center: const Alignment(-0.6, -0.6), radius: 1.2, colors: [const Color(0xFFE8927C).withOpacity(0.08), Colors.transparent], stops: const [0.0, 0.7])))),
        Positioned.fill(child: Container(decoration: BoxDecoration(gradient: RadialGradient(center: const Alignment(0.8, 0.8), radius: 1.2, colors: [const Color(0xFFA78BCA).withOpacity(0.06), Colors.transparent], stops: const [0.0, 0.7])))),
      ],
    );
  }

  Widget _buildPrimaryButton({required String text, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: const LinearGradient(colors: [Color(0xFFE8927C), Color(0xFFA78BCA)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: ElevatedButton(onPressed: onPressed, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.3))),
    );
  }
}
