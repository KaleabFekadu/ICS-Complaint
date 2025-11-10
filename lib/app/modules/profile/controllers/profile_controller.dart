import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ics_complaint/app/modules/login/controllers/login_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../login/views/login_view.dart';

class ProfileController extends GetxController {
  final count = 0.obs;
  final userName = ''.obs;
  final userPhone = ''.obs; // Changed from userEmail to userPhone
  final userId = ''.obs; // Added to store customer_id

  @override
  void onInit() {
    super.onInit();
    loadUserData(); // Load user data when controller initializes
  }

  Future<void> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userName.value = prefs.getString('full_name') ?? 'Unknown User';
      userPhone.value = prefs.getString('phone_number') ?? 'No Phone';
      userId.value = prefs.getString('customer_id') ?? 'No ID';
    } catch (e) {
      Get.snackbar(
        'Error'.tr,
        'Failed to load user data: $e'.tr,
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

  Future<void> logout() async {
    try {
      // Clear tokens and user data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('customer_id');
      await prefs.remove('full_name');
      await prefs.remove('phone_number');
      await prefs.remove('remember_me');

      // Reset user data in controller
      userName.value = '';
      userPhone.value = '';
      userId.value = '';

      // Show logout confirmation snackbar
      Get.closeAllSnackbars();
      Get.snackbar(
        'Success'.tr,
        'Logged out successfully!'.tr,
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
      await Future.delayed(const Duration(seconds: 1));

      // Navigate to LoginView and clear navigation stack
  
      Get.offAll(() =>  LoginView());
    } catch (e) {
      // Handle any errors during logout
      Get.snackbar(
        'Error'.tr,
        'Failed to log out: $e'.tr,
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

  void increment() => count.value++;
}