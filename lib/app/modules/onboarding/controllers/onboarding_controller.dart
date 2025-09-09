import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';

import '../../../utils/constants/colors.dart';

/// Onboarding Controller
class OnboardingController extends GetxController {
  var pageController = PageController();
  var currentPage = 0.obs;
  var isLastPage = false.obs;

  final GetStorage storage = GetStorage();

  List<OnboardingModel> onboardingPages = [
    OnboardingModel(
      'assets/logos/2346699_315780-P8VAIG-9.jpg',
      'Welcome to ICS',
      'Access trusted Immigration and Citizenship services anytime, anywhere.',
    ),
    OnboardingModel(
      'assets/logos/Screenshot 2025-09-04 at 11.18.19 in the morning.jpg',
      'Verify Your Identity',
      'Easily authenticate your Ethiopian ID to securely access government services.',
    ),
    OnboardingModel(
      'assets/logos/10221134.jpg',
      'Track Your Applications',
      'Stay updated on the progress of your visa, residency, and citizenship requests in real-time.',
    ),
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
    isLastPage.value = index == onboardingPages.length - 1;
  }

  void completeOnboarding() {
    storage.write('onboarding_completed', true);
    Get.offNamed('/language'); // Navigate to next screen
  }
}

/// Onboarding Model
class OnboardingModel {
  final String imageAsset;
  final String title;
  final String subtitle;

  OnboardingModel(this.imageAsset, this.title, this.subtitle);
}