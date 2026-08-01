import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app_route.dart';
import '../../auth/controller/auth_controller.dart';

class PremiumGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    if (!authController.hasPremiumAccess) {
      return const RouteSettings(name: AppRoute.premium);
    }
    return null;
  }
}
