import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/auth_controller.dart';
import '../../core/app_route.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthController controller = Get.put(AuthController());
  bool _acceptedEula = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 200,
        leading: TextButton.icon(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6B7280), size: 20),
          label: const Text(
            'Back to sign in',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(left: 24),
            alignment: Alignment.centerLeft,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Create your account',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildLabel('Name'),
              _buildTextField(
                controller: _nameController,
                hint: 'Jane Doe',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              _buildLabel('Username'),
              _buildTextField(
                controller: _usernameController,
                hint: 'fitness_jane',
                prefixIcon: Icons.alternate_email,
              ),
              const SizedBox(height: 20),
              _buildLabel('Email'),
              _buildTextField(
                controller: _emailController,
                hint: 'you@example.com',
                prefixIcon: Icons.mail_outline,
              ),
              const SizedBox(height: 20),
              _buildLabel('Password'),
              _buildTextField(
                controller: _passwordController,
                hint: 'Min. 8 characters',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 20),
              _buildLabel('Confirm Password'),
              _buildTextField(
                controller: _confirmPasswordController,
                hint: 'Re-enter password',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 24),

              // Mandatory EULA / Terms acceptance checkbox for Apple Guideline 1.2
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _acceptedEula,
                    activeColor: const Color(0xFF111827),
                    onChanged: (val) {
                      setState(() {
                        _acceptedEula = val ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563), height: 1.4),
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms of Use (EULA)',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF111827), decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  final Uri url = Uri.parse('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/');
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                  }
                                },
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF111827), decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  final Uri url = Uri.parse('https://sites.google.com/view/herwallness/home');
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                  }
                                },
                            ),
                            const TextSpan(
                              text: '. Zero tolerance for objectionable content or abusive behavior. Violators will be banned.',
                              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Obx(() => _buildPrimaryButton(
                text: controller.isLoading.value ? 'Loading...' : 'Create account',
                onPressed: controller.isLoading.value ? () {} : () async {
                  if (!_acceptedEula) {
                    Get.snackbar(
                      'Terms Acceptance Required',
                      'You must accept the Terms of Use (EULA) and Privacy Policy before creating an account.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white,
                    );
                    return;
                  }
                  if (_nameController.text.isEmpty || 
                      _usernameController.text.isEmpty || 
                      _emailController.text.isEmpty || 
                      _passwordController.text.isEmpty || 
                      _confirmPasswordController.text.isEmpty) {
                    Get.snackbar('Error', 'Please fill in all fields',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white);
                    return;
                  }
                  if (_passwordController.text != _confirmPasswordController.text) {
                    Get.snackbar('Error', 'Passwords do not match',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white);
                    return;
                  }
                  await controller.registerUser(_nameController.text, _usernameController.text, _emailController.text, _passwordController.text, _confirmPasswordController.text);
                },
              )),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () async {
                      final Uri url = Uri.parse('https://sites.google.com/view/herwallness/home');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: const Text(
                      'Privacy Policy',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Text(' • ', style: TextStyle(color: Color(0xFF6B7280))),
                  TextButton(
                    onPressed: () async {
                      final Uri url = Uri.parse('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: const Text(
                      'Terms of Use (EULA)',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Color(0xFF111827)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF9CA3AF), size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF111827), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF111827),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
