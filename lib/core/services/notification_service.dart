import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import 'package:flutter/material.dart';

class NotificationService extends GetxService {
  FirebaseMessaging? _fcm;
  bool _initialized = false;

  Future<NotificationService> init() async {
    try {
      log('[FCM] Initializing Firebase App...');
      await Firebase.initializeApp();
      _fcm = FirebaseMessaging.instance;
      _initialized = true;
      log('[FCM] Firebase App initialized successfully.');

      // Request permissions
      NotificationSettings settings = await _fcm!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      log('[FCM] User granted permission status: ${settings.authorizationStatus}');

      // Configure foreground and background message handlers
      _setupFcmListeners();

      // Attempt to sync FCM token
      await syncFcmToken();
    } catch (e) {
      log('[FCM] Warning: Failed to initialize Firebase Messaging: $e. (Make sure google-services.json/GoogleService-Info.plist are configured natively)');
    }
    return this;
  }

  void _setupFcmListeners() {
    if (!_initialized || _fcm == null) return;

    // Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('[FCM] Foreground message received: ${message.notification?.title}');
      if (message.notification != null) {
        Get.snackbar(
          message.notification!.title ?? 'Notification',
          message.notification!.body ?? '',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white.withOpacity(0.9),
          colorText: const Color(0xFF2D2420),
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(12),
          borderRadius: 16,
          boxShadows: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        );
      }
    });

    // Background/terminated notification tapped handler
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('[FCM] Background message opened: ${message.data}');
      // Handle navigation here if necessary (e.g. routing to Notifications)
      // Get.toNamed('/notification');
    });
  }

  Future<void> syncFcmToken() async {
    if (!_initialized || _fcm == null) {
      log('[FCM] Cannot sync token: Firebase not initialized.');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      if (accessToken == null || accessToken.isEmpty) {
        log('[FCM] User is not logged in. Skipping FCM token sync.');
        return;
      }

      log('[FCM] Fetching FCM token...');
      String? token = await _fcm!.getToken();
      if (token == null) {
        log('[FCM] Failed to retrieve FCM token.');
        return;
      }
      log('[FCM] Token retrieved successfully: $token');

      // Cache token locally
      await prefs.setString('fcm_token', token);

      // Send token to backend via ApiClient
      final ApiClient apiClient = Get.find<ApiClient>();
      apiClient.setToken(accessToken);

      final response = await apiClient.put(
        '/auth/me',
        data: {
          'fcmToken': token,
          'platform': GetPlatform.isAndroid ? 'android' : (GetPlatform.isIOS ? 'ios' : 'web'),
        },
      );

      if (response.isSuccess) {
        log('[FCM] Successfully updated FCM token on the backend.');
      } else {
        log('[FCM] Failed to register FCM token: ${response.message}');
      }
    } catch (e) {
      log('[FCM] Error updating token on server: $e');
    }
  }
}
