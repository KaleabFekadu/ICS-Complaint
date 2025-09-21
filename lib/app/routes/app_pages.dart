import 'package:get/get.dart';

import '../modules/bottom_nav_home/bindings/bottom_nav_home_binding.dart';
import '../modules/bottom_nav_home/views/bottom_nav_home_view.dart';
import '../modules/create_complaint/bindings/create_complaint_binding.dart';
import '../modules/create_complaint/views/create_complaint_view.dart';
import '../modules/feedback/bindings/feedback_binding.dart';
import '../modules/feedback/views/feedback_view.dart';
import '../modules/forget/bindings/forget_binding.dart';
import '../modules/forget/views/forget_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/language/bindings/language_binding.dart';
import '../modules/language/views/language_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/qrscanner/bindings/qrscanner_binding.dart';
import '../modules/qrscanner/views/qrscanner_view.dart';
import '../modules/signup/bindings/signup_binding.dart';
import '../modules/signup/views/signup_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.LANGUAGE,
      page: () => const LanguageView(),
      binding: LanguageBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.BOTTOM_NAV_HOME,
      page: () => const BottomNavHomeView(),
      binding: BottomNavHomeBinding(),
    ),
    GetPage(
      name: _Paths.SIGNUP,
      page: () => const SignupView(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: _Paths.FORGET,
      page: () => const ForgetView(),
      binding: ForgetBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.QRSCANNER,
      page: () => const QrscannerView(),
      binding: QrscannerBinding(),
    ),
    GetPage(
      name: _Paths.CREATE_COMPLAINT,
      page: () => const CreateComplaintView(),
      binding: CreateComplaintBinding(),
    ),
    GetPage(
      name: _Paths.FEEDBACK,
      page: () => const FeedbackView(),
      binding: FeedbackBinding(),
    ),
  ];
}
