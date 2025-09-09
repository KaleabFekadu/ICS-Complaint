import 'package:connectivity_plus/connectivity_plus.dart'; // Import the package
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/loader/loaders.dart';

class SplashController extends GetxController {
  final GetStorage storage = GetStorage();
  RxBool isDarkMode = false.obs;

  bool get isDarkModeValue => isDarkMode.value; // Centralized getter

  @override
  void onInit() {
    super.onInit();
    print("SplashController is ready");
    _checkConnectivity(); // Check for internet connectivity
  }

  @override
  void onReady() {
    super.onReady();
  }



  // Method to check internet connectivity
  Future<void> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection
      TLoaders.errorSnackBar(title: 'No Internet Connection', message: 'Please check your internet connection');

      // Re-check connectivity after some time
      Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
        if (result != ConnectivityResult.none) {
          // Internet is now available, navigate to the next screen
          _checkNavigation();
        }
      });
    } else {
      // If there's internet connection, proceed to navigation
      _checkNavigation();
    }
  }

  Future<void> _checkNavigation() async {

    // Check for token first
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    bool hasCompletedOnboarding = storage.read('onboarding_completed') ?? false;
    //bool hasCompletedLanguageSelection = storage.read('language_first_completed') ?? false;
    bool hasCompletedRealLanguageSelection = storage.read('language_selection_completed') ?? false;


    Future.delayed(const Duration(seconds: 1), () {
      if (token != null && token.isNotEmpty) {
        print("Token found, navigating to Home");
        Get.offAllNamed(Routes.BOTTOM_NAV_HOME);
      } else if (!hasCompletedOnboarding) {
        print("Navigating to Onboarding");
        Get.offAllNamed(Routes.ONBOARDING);
      }
      // else if (!hasCompletedLanguageSelection) {
      //   print("Navigating to Permissions");
      //   Get.offAllNamed(Routes.LANGUAGE_FIRST);
      // }
      else if (!hasCompletedRealLanguageSelection) {
        print("Navigating to Language");
        Get.offAllNamed(Routes.LANGUAGE);
      } else {
        print("Navigating to Login");
        Get.offAllNamed(Routes.LOGIN);
      }
    });
  }
}