import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/app_route.dart';
import 'core/app_colors.dart';
import 'splashscreen/presentation/splash_screen.dart';
import 'core/bindings/initial_binding.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'HerWellness',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              surface: AppColors.background,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: AppColors.background,
            textTheme: GoogleFonts.nunitoTextTheme(
              ThemeData.light().textTheme,
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.dark,
              surface: AppColors.darkBackground,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: AppColors.darkBackground,
            textTheme: GoogleFonts.nunitoTextTheme(
              ThemeData.dark().textTheme,
            ),
          ),
          themeMode: ThemeMode.system,
          initialRoute: AppRoute.splash,
          initialBinding: InitialBinding(),
          getPages: AppRoute.routes,
        );
      },
      child: const SplashScreen(),
    );
  }
}
