import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackController extends GetxController {
  var selectedBranch = ''.obs;
  var selectedService = ''.obs;
  var rating = 0.obs;
  var description = ''.obs;
  var isSubmitting = false.obs;

  final branches = ['Branch A', 'Branch B', 'Branch C'].obs;
  final servicesByBranch = {
    'Branch A': ['Service A1', 'Service A2', 'Service A3'],
    'Branch B': ['Service B1', 'Service B2'],
    'Branch C': ['Service C1', 'Service C2', 'Service C3', 'Service C4'],
  }.obs;

  List<String> getServicesForBranch(String branch) {
    return servicesByBranch[branch] ?? [];
  }

  Future<void> submitFeedback() async {
    if (selectedBranch.value.isEmpty) {
      Get.snackbar(
        'Error'.tr,
        'Please select a branch.'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 4),
        isDismissible: true,
      );
      return;
    }
    if (selectedService.value.isEmpty) {
      Get.snackbar(
        'Error'.tr,
        'Please select a service.'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 4),
        isDismissible: true,
      );
      return;
    }
    if (rating.value == 0) {
      Get.snackbar(
        'Error'.tr,
        'Please provide a rating.'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 4),
        isDismissible: true,
      );
      return;
    }
    if (description.value.isEmpty) {
      Get.snackbar(
        'Error'.tr,
        'Please enter a description.'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 4),
        isDismissible: true,
      );
      return;
    }

    isSubmitting.value = true;
    try {
      // Check if user is logged in
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null || token.isEmpty) {
        Get.snackbar(
          'Error'.tr,
          'Please log in to submit feedback.'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 4),
          isDismissible: true,
        );
        Get.offAllNamed('/login');
        return;
      }

      // TODO: Integrate API call here for submitting feedback
      // For now, simulate success
      await Future.delayed(const Duration(seconds: 1)); // Simulate API delay

      Get.snackbar(
        'Success'.tr,
        'Feedback submitted successfully!'.tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 4),
        isDismissible: true,
      );

      // Reset fields
      selectedBranch.value = '';
      selectedService.value = '';
      rating.value = 0;
      description.value = '';
    } catch (e) {
      Get.snackbar(
        'Error'.tr,
        'Failed to submit feedback: $e'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 4),
        isDismissible: true,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}