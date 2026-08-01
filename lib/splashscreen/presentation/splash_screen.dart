import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import '../../core/app_route.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';
import '../../core/services/notification_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    await Future.delayed(const Duration(seconds: 3));
    
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding') ?? false;
    final accessToken = prefs.getString('access_token');
    
    if (accessToken == null || accessToken.isEmpty) {
      Get.offAllNamed(AppRoute.login);
    } else {
      // Set token and verify it via /auth/me
      final apiClient = Get.find<ApiClient>();
      apiClient.setToken(accessToken);
      
      final response = await apiClient.get('/auth/me');
      if (response.isSuccess) {
        // Sync Firebase Cloud Messaging token with the backend
        if (Get.isRegistered<NotificationService>()) {
          Get.find<NotificationService>().syncFcmToken();
        }

        bool userHasCycleData = false;
        if (!hasCompletedOnboarding) {
          try {
            final cycleResponse = await apiClient.get('/cycle/cycle-data');
            if (cycleResponse.isSuccess && cycleResponse.data is List && (cycleResponse.data as List).isNotEmpty) {
              userHasCycleData = true;
              await prefs.setBool('hasCompletedOnboarding', true);
            }
          } catch (e) {
            debugPrint('Error checking cycle data in splash: $e');
          }
        }

        if (hasCompletedOnboarding || userHasCycleData) {
          Get.offAllNamed(AppRoute.navbar);
        } else {
          Get.offAllNamed(AppRoute.onboarding);
        }
      } else {
        // Token is invalid/expired
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        await prefs.remove('user_data');
        apiClient.clearToken();
        Get.offAllNamed(AppRoute.login);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://qtrypzzcjebvfcihiynt.supabase.co/storage/v1/object/public/base44-prod/public/69934eac0b26e505ebf4ef11/6dd51d48c_TransparentLogo.png',
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.spa_rounded,
                      size: 80,
                      color: AppColors.primary,
                    );
                  },
                ),
                const SizedBox(height: 32),
                const Text(
                  'HerWellness',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your wellness companion',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
