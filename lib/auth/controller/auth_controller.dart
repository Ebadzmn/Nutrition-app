import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_route.dart';
import '../../core/network/api_client.dart';
import '../../core/services/notification_service.dart';
import '../models/login_response_model.dart';
import '../models/user_model.dart';
import 'dart:convert';

class AuthController extends GetxController {
  final isLoading = false.obs;
  final email = ''.obs;
  final password = ''.obs;
  final otp = ''.obs;

  final resetToken = ''.obs;
  final currentUser = Rxn<UserModel>();

  bool get hasPremiumAccess => currentUser.value?.hasPremiumAccess ?? false;

  @override
  void onInit() {
    super.onInit();
    _loadUserFromPrefs();
  }

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      try {
        currentUser.value = UserModel.fromJson(jsonDecode(userData));
      } catch (e) {
        debugPrint('Error decoding user_data from prefs: $e');
      }
    }
    final token = prefs.getString('access_token');
    if (token != null && token.isNotEmpty) {
      Get.find<ApiClient>().setToken(token);
    }
  }

  Future<void> refreshCurrentUser() async {
    try {
      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.get('/auth/me');
      if (response.isSuccess && response.data != null) {
        final user = UserModel.fromJson(response.data);
        currentUser.value = user;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(user.toJson()));
      }
    } catch (e) {
      debugPrint('Error refreshing current user: $e');
    }
  }

  Future<void> loginUser(String email, String password) async {
    if (isLoading.value) return; // Prevent multiple requests
    try {
      isLoading.value = true;
      
      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.post(
        '/auth/login',
        data: {
          "email": email.trim(),
          "password": password,
        },
      );

      if (response.isSuccess && response.data != null) {
        final loginData = LoginResponseModel.fromJson(response.data);
        
        final prefs = await SharedPreferences.getInstance();
        if (loginData.accessToken != null) {
          await prefs.setString('access_token', loginData.accessToken!);
          apiClient.setToken(loginData.accessToken!);
        }
        if (loginData.refreshToken != null) {
          await prefs.setString('refresh_token', loginData.refreshToken!);
        }
        if (loginData.user != null) {
          currentUser.value = loginData.user;
          await prefs.setString('user_data', jsonEncode(loginData.user!.toJson()));
        }

        // Sync Firebase Cloud Messaging token with the backend
        if (Get.isRegistered<NotificationService>()) {
          Get.find<NotificationService>().syncFcmToken();
        }

        Get.snackbar('Success', response.message.isNotEmpty ? response.message : 'Login Successful',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.1));
            
        bool userHasCycleData = false;
        try {
          final cycleResponse = await apiClient.get('/cycle/cycle-data');
          if (cycleResponse.isSuccess && cycleResponse.data is List && (cycleResponse.data as List).isNotEmpty) {
            userHasCycleData = true;
            await prefs.setBool('hasCompletedOnboarding', true);
          }
        } catch (e) {
          debugPrint('Error checking cycle data during login: $e');
        }

        final hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding') ?? userHasCycleData;
        debugPrint('✅ Login successful. hasCompletedOnboarding: $hasCompletedOnboarding');
        
        if (hasCompletedOnboarding) {
          debugPrint('🏠 Navigating to navbar');
          Get.offAllNamed(AppRoute.navbar);
        } else {
          debugPrint('📋 Navigating to onboarding');
          Get.offAllNamed(AppRoute.onboarding);
        }
      } else {
        Get.snackbar('Error', response.message.isNotEmpty ? response.message : 'Login failed',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerUser(String name, String username, String email, String password, String confirmPassword) async {
    if (isLoading.value) return; // Disable multiple submissions
    try {
      isLoading.value = true;
      this.email.value = email;
      
      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.post(
        '/auth/register',
        data: {
          "name": name.trim(),
          "username": username.trim(),
          "email": email.trim(),
          "password": password,
          "confirm_password": confirmPassword,
        },
      );

      if (response.isSuccess && response.data != null) {
        // Backend returns tokens immediately on registration — save them now
        final prefs = await SharedPreferences.getInstance();
        final accessToken = response.data['access_token']?.toString();
        final refreshToken = response.data['refresh_token']?.toString();

        if (accessToken != null && accessToken.isNotEmpty) {
          await prefs.setString('access_token', accessToken);
          apiClient.setToken(accessToken);
        }
        if (refreshToken != null && refreshToken.isNotEmpty) {
          await prefs.setString('refresh_token', refreshToken);
        }
        if (response.data['user'] != null) {
          final userObj = UserModel.fromJson(response.data['user']);
          currentUser.value = userObj;
          await prefs.setString('user_data', jsonEncode(userObj.toJson()));
        }

        // Clear stale onboarding flag so first-time user always sees onboarding
        await prefs.remove('hasCompletedOnboarding');

        // Sync FCM token if notification service is registered
        if (Get.isRegistered<NotificationService>()) {
          Get.find<NotificationService>().syncFcmToken();
        }

        Get.snackbar('Welcome!', 'Check your email for a verification code.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.1));

        // Server sends OTP for email verification — navigate to OTP screen
        Get.toNamed(AppRoute.signupOtp);
      } else {
        Get.snackbar('Error', response.message.isNotEmpty ? response.message : 'Registration failed',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword(String email) async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      this.email.value = email.trim();
      
      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.post(
        '/auth/forgot-password',
        data: {"email": email.trim()},
      );

      if (response.isSuccess) {
        Get.snackbar('Success', response.message.isNotEmpty ? response.message : 'OTP sent successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.1));
        Get.toNamed(AppRoute.forgotPasswordOtp);
      } else {
        Get.snackbar('Error', response.message.isNotEmpty ? response.message : 'Failed to request password reset',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifySignupOTP(String otp) async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;

      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.post(
        '/auth/verify-signup-otp',
        data: {
          "email": email.value,
          "otp": otp.trim(),
        },
      );

      if (response.isSuccess && response.data != null) {
        // Save tokens exactly as we do during login
        final prefs = await SharedPreferences.getInstance();
        final accessToken = response.data['access_token']?.toString();
        final refreshToken = response.data['refresh_token']?.toString();

        if (accessToken != null && accessToken.isNotEmpty) {
          await prefs.setString('access_token', accessToken);
          apiClient.setToken(accessToken);
        }
        if (refreshToken != null && refreshToken.isNotEmpty) {
          await prefs.setString('refresh_token', refreshToken);
        }
        if (response.data['user'] != null) {
          final userObj = UserModel.fromJson(response.data['user']);
          currentUser.value = userObj;
          await prefs.setString('user_data', jsonEncode(userObj.toJson()));
        }

        // Clear any stale onboarding flag so the new user sees onboarding
        await prefs.remove('hasCompletedOnboarding');

        Get.snackbar(
          'Email verified!',
          'Let\'s set up your profile.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
        );
        Get.offAllNamed(AppRoute.onboarding);
      } else {
        // Fallback: some backends return 200 with no token on OTP verify,
        // requiring a separate login. In that case send user to login.
        final msg = response.message.isNotEmpty ? response.message : 'Verification failed';
        // If the message hints success (e.g. "OTP verified") treat it as success
        final isSuccess = msg.toLowerCase().contains('verif') && !msg.toLowerCase().contains('fail') && !msg.toLowerCase().contains('invalid');
        if (isSuccess) {
          Get.snackbar('Verified!', 'Please log in to continue.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green.withOpacity(0.1));
          Get.offAllNamed(AppRoute.login);
        } else {
          Get.snackbar('Error', msg,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent,
              colorText: Colors.white);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred during verification',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyForgotPasswordOTP(String otp) async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      
      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.post(
        '/auth/verify-otp',
        data: {
          "email": email.value,
          "otp": otp.trim(),
        },
      );

      if (response.isSuccess && response.data != null && response.data['resetToken'] != null) {
        resetToken.value = response.data['resetToken'];
        Get.snackbar('Success', 'OTP verified successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.1));
        Get.toNamed(AppRoute.resetPassword);
      } else {
        Get.snackbar('Error', response.message.isNotEmpty ? response.message : 'Verification failed',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(String newPassword) async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      
      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.post(
        '/auth/reset-password',
        data: {
          "resetToken": resetToken.value,
          "newPassword": newPassword,
        },
      );

      if (response.isSuccess) {
        Get.snackbar('Success', 'Password reset successfully', 
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFE8927C).withOpacity(0.1));
        Get.offAllNamed(AppRoute.login);
      } else {
        Get.snackbar('Error', response.message.isNotEmpty ? response.message : 'Password reset failed',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> socialLogin(String provider) async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1)); // Mock delay
      
      final prefs = await SharedPreferences.getInstance();
      final hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding') ?? false;
      
      if (hasCompletedOnboarding) {
        Get.offAllNamed(AppRoute.navbar);
      } else {
        Get.offAllNamed(AppRoute.onboarding);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_data');
      currentUser.value = null;
      // Clear onboarding flag so a different user on the same device goes through onboarding
      await prefs.remove('hasCompletedOnboarding');

      final ApiClient apiClient = Get.find<ApiClient>();
      apiClient.clearToken();

      Get.offAllNamed(AppRoute.login);
    } catch (e) {
      Get.snackbar('Error', 'Logout failed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAccount() async {
    try {
      isLoading.value = true;
      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.delete('/auth/me');

      if (response.isSuccess) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        await prefs.remove('user_data');
        apiClient.clearToken();

        Get.snackbar(
          'Success',
          'Account deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green[800],
        );
        Get.offAllNamed(AppRoute.login);
      } else {
        Get.snackbar(
          'Error',
          response.message.isNotEmpty ? response.message : 'Failed to delete account',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
