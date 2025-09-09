import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../login/views/login_view.dart';

class ProfileController extends GetxController {
  final count = 0.obs;
  final userName = 'Kaleab Fekadu'.obs;
  final userEmail = 'callmecaleab@gmail.com'.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;

  // Logout method to clear tokens and user data
  Future<void> logout() async {
    try {
      // Clear tokens and user data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('remember_me');

      // Reset user data in controller
      userName.value = '';
      userEmail.value = '';

      // Show logout confirmation snackbar
      Get.closeAllSnackbars();
      Get.snackbar(
        'Success',
        'Logged out successfully!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        isDismissible: true,
        animationDuration: const Duration(milliseconds: 300),
        overlayBlur: 0.5,
        overlayColor: Colors.black.withOpacity(0.2),
      );

      // Delay navigation to ensure snackbar is visible
      await Future.delayed(const Duration(seconds: 2));

      // Navigate to LoginView and clear navigation stack
      Get.offAll(() => const LoginView());
    } catch (e) {
      // Handle any errors during logout
      Get.snackbar(
        'Error',
        'Failed to log out: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        isDismissible: true,
        animationDuration: const Duration(milliseconds: 300),
        overlayBlur: 0.5,
        overlayColor: Colors.black.withOpacity(0.2),
      );
    }
  }
}