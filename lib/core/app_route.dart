import 'package:get/get.dart';
import '../splashscreen/presentation/splash_screen.dart';
import '../onboarding/presentation/onboarding_screen.dart';
import '../nav_bar/navbar_ui.dart';
import '../home/presentation/home_screen.dart';
import '../home/presentation/notification_screen.dart';
import '../workouts/presentation/workouts_screen.dart';
import '../workout_library/presentation/workout_library_screen.dart';
import '../workout_session/presentation/workout_session_screen.dart';
import '../nutrition/presentation/nutrition_screen.dart';
import '../community/presentation/community_screen.dart';
import '../community/presentation/post_detail_screen.dart';
import '../settings/presentation/settings_screen.dart';
import '../settings/presentation/privacy_policy_screen.dart';
import '../settings/presentation/delete_account_screen.dart';
import '../premium/presentation/premium_screen.dart';
import '../auth/presentation/login_screen.dart';
import '../auth/presentation/signup_screen.dart';
import '../auth/presentation/forgot_password_screen.dart';
import '../auth/presentation/signup_otp_screen.dart';
import '../auth/presentation/forgot_password_otp_screen.dart';
import '../auth/presentation/reset_password_screen.dart';
import '../strava/presentation/strava_callback_screen.dart';
import '../onboarding/presentation/onboarding_screen.dart';
import '../workouts/presentation/ai_coach_chat_screen.dart';
import 'guards/premium_guard.dart';

class AppRoute {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String signupOtp = '/signup-otp';
  static const String forgotPasswordOtp = '/forgot-password-otp';
  static const String resetPassword = '/reset-password';
  static const String onboarding = '/onboarding';
  static const String navbar = '/navbar';
  static const String home = '/home';
  static const String notification = '/notification';
  static const String workouts = '/workouts';
  static const String aiCoachChat = '/ai-coach-chat';
  static const String workoutLibrary = '/workoutLibrary';
  static const String workoutSession = '/workoutSession';
  static const String nutrition = '/nutrition';
  static const String community = '/community';
  static const String postDetail = '/postDetail';
  static const String settings = '/settings';
  static const String privacyPolicy = '/privacyPolicy';
  static const String deleteAccount = '/deleteAccount';
  static const String premium = '/premium';
  static const String stravaCallback = '/stravaCallback';

  static List<GetPage> routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: signup, page: () => SignupScreen()),
    GetPage(name: forgotPassword, page: () => const ForgotPasswordScreen()),
    GetPage(name: signupOtp, page: () => const SignupOTPScreen()),
    GetPage(name: forgotPasswordOtp, page: () => const ForgotPasswordOTPScreen()),
    GetPage(name: resetPassword, page: () => const ResetPasswordScreen()),
    GetPage(name: onboarding, page: () => OnboardingScreen()),
    GetPage(name: navbar, page: () => const NavbarUi()),
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: notification, page: () => const NotificationScreen()),
    GetPage(name: workouts, page: () => const WorkoutsScreen(), middlewares: [PremiumGuard()]),
    GetPage(name: aiCoachChat, page: () => const AICoachChatScreen(), middlewares: [PremiumGuard()]),
    GetPage(name: workoutLibrary, page: () => const WorkoutLibraryScreen(), middlewares: [PremiumGuard()]),
    GetPage(name: workoutSession, page: () => const WorkoutSessionScreen(), middlewares: [PremiumGuard()]),
    GetPage(name: nutrition, page: () => const NutritionScreen(), middlewares: [PremiumGuard()]),
    GetPage(name: community, page: () => const CommunityScreen(), middlewares: [PremiumGuard()]),
    GetPage(name: postDetail, page: () => const PostDetailScreen(), middlewares: [PremiumGuard()]),
    GetPage(name: settings, page: () => SettingsScreen()),
    GetPage(name: privacyPolicy, page: () => const PrivacyPolicyScreen()),
    GetPage(name: deleteAccount, page: () => const DeleteAccountScreen()),
    GetPage(name: premium, page: () => const PremiumScreen()),
    GetPage(name: stravaCallback, page: () => const StravaCallbackScreen()),
  ];
}
