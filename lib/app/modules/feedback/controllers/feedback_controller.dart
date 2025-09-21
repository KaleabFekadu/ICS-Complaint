import 'package:get/get.dart';

class FeedbackController extends GetxController {
  var selectedBranch = ''.obs;
  var selectedService = ''.obs;
  var rating = 0.obs;
  var description = ''.obs;

  final branches = ['Branch A', 'Branch B', 'Branch C'].obs;

  final servicesByBranch = {
    'Branch A': ['Service A1', 'Service A2', 'Service A3'],
    'Branch B': ['Service B1', 'Service B2'],
    'Branch C': ['Service C1', 'Service C2', 'Service C3', 'Service C4'],
  }.obs;

  List<String> getServicesForBranch(String branch) {
    return servicesByBranch[branch] ?? [];
  }

  void submitFeedback() {
    if (selectedBranch.value.isEmpty ||
        selectedService.value.isEmpty ||
        rating.value == 0 ||
        description.value.isEmpty) {
      Get.snackbar("Error", "Please fill all fields before submitting.");
      return;
    }

    // For now just show a snackbar (you can later integrate API call here)
    Get.snackbar(
      "Feedback Submitted",
      "Branch: ${selectedBranch.value}\nService: ${selectedService.value}\nRating: ${rating.value}\nDescription: ${description.value}",
    );

    // Reset fields
    selectedBranch.value = '';
    selectedService.value = '';
    rating.value = 0;
    description.value = '';
  }
}
