import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import '../../core/app_route.dart';
import '../controller/auth_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final AuthController controller = Get.find<AuthController>();

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
                    'Forgot Password',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF2D2420),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Enter your email address and we will send you an OTP to reset your password.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF5C4A3A),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildLabel('Email Address'),
                  _buildTextField(
                    controller: _emailController,
                    hint: 'Enter your email',
                  ),
                  const SizedBox(height: 40),
                  Obx(() => _buildPrimaryButton(
                    text: controller.isLoading.value ? 'Sending...' : 'Send OTP',
                    onPressed: controller.isLoading.value ? () {} : () async {
                      if (_emailController.text.isEmpty) {
                        Get.snackbar('Error', 'Please enter your email',
                            snackPosition: SnackPosition.BOTTOM);
                        return;
                      }
                      await controller.forgotPassword(_emailController.text);
                    },
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundTexture() {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.6, -0.6),
                radius: 1.2,
                colors: [const Color(0xFFE8927C).withOpacity(0.08), Colors.transparent],
                stops: const [0.0, 0.7],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.8, 0.8),
                radius: 1.2,
                colors: [const Color(0xFFA78BCA).withOpacity(0.06), Colors.transparent],
                stops: const [0.0, 0.7],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
          color: Color(0xFF8B7355),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Color(0xFF2D2420)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF8B7355), fontSize: 15),
        filled: true,
        fillColor: const Color(0xFFEDE6DD),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD4C5B9), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD4C5B9), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE8927C), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({required String text, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFFE8927C), Color(0xFFA78BCA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
