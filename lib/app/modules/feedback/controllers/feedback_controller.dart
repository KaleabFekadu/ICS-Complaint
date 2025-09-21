import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/constants/config.dart';

class FeedbackController extends GetxController {
  var selectedBranchId = ''.obs; // Changed to store branch ID
  var selectedServiceId = ''.obs; // Changed to store service ID
  var rating = 0.obs;
  var description = ''.obs;
  var isSubmitting = false.obs;
  var isLoadingBranches = false.obs;
  var isLoadingServices = false.obs;
  var errorMessage = ''.obs;

  final branches = <Map<String, dynamic>>[].obs; // Store branch data (id, name)
  final services = <Map<String, dynamic>>[].obs; // Store service data (id, name)

  @override
  void onInit() {
    super.onInit();
    fetchBranches();
  }

  Future<void> fetchBranches() async {
    isLoadingBranches.value = true;
    errorMessage.value = '';
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null || token.isEmpty) {
        errorMessage.value = 'Please log in to fetch branches.'.tr;
        Get.offAllNamed('/login');
        return;
      }

      final client = GraphQLClient(
        link: HttpLink(
          '${Config.baseUrl}/graphql',
          defaultHeaders: {'Authorization': 'Bearer $token'},
        ),
        cache: GraphQLCache(),
      );

      const query = r'''
        query GetAllBranchesWithServices {
          all_branches {
            id
            name
            code
            description
            icon
            
          }
        }
      ''';

      final result = await client.query(
        QueryOptions(
          document: gql(query),
          fetchPolicy: FetchPolicy.networkOnly,
          errorPolicy: ErrorPolicy.all,
        ),
      );

      if (result.hasException) {
        errorMessage.value = 'Failed to load branches: ${result.exception.toString()}'.tr;
        return;
      }

      final data = result.data?['all_branches'] as List<dynamic>?;
      if (data != null) {
        branches.assignAll(data.cast<Map<String, dynamic>>());
        // Cache services for each branch
        services.clear();
        selectedBranchId.value = '';
        selectedServiceId.value = '';
      } else {
        errorMessage.value = 'No branches found.'.tr;
      }
    } catch (e) {
      errorMessage.value = 'Error fetching branches: $e'.tr;
    } finally {
      isLoadingBranches.value = false;
    }
  }

  Future<void> fetchServicesForBranch(String branchId) async {
    if (branchId.isEmpty) {
      services.clear();
      selectedServiceId.value = '';
      return;
    }

    isLoadingServices.value = true;
    errorMessage.value = '';
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null || token.isEmpty) {
        errorMessage.value = 'Please log in to fetch services.'.tr;
        Get.offAllNamed('/login');
        return;
      }

      final client = GraphQLClient(
        link: HttpLink(
          '${Config.baseUrl}/graphql',
          defaultHeaders: {'Authorization': 'Bearer $token'},
        ),
        cache: GraphQLCache(),
      );

      const query = r'''
        query GetBranchWithServices($branchId: ID!) {
          branch(id: $branchId) {
            id
            name
            services {
              id
              name
              description
              draft
            }
          }
        }
      ''';

      final result = await client.query(
        QueryOptions(
          document: gql(query),
          variables: {'branchId': branchId},
          fetchPolicy: FetchPolicy.networkOnly,
          errorPolicy: ErrorPolicy.all,
        ),
      );

      if (result.hasException) {
        errorMessage.value = 'Failed to load services: ${result.exception.toString()}'.tr;
        return;
      }

      final data = result.data?['branch'] as Map<String, dynamic>?;
      if (data != null && data['services'] != null) {
        services.assignAll((data['services'] as List<dynamic>).cast<Map<String, dynamic>>().where((service) => !(service['draft'] ?? false)).toList());
        selectedServiceId.value = '';
      } else {
        errorMessage.value = 'No services found for this branch.'.tr;
        services.clear();
      }
    } catch (e) {
      errorMessage.value = 'Error fetching services: $e'.tr;
    } finally {
      isLoadingServices.value = false;
    }
  }

  Future<void> submitFeedback() async {
    if (selectedBranchId.value.isEmpty) {
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
    if (selectedServiceId.value.isEmpty) {
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

      // TODO: Integrate API call for submitting feedback
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
      selectedBranchId.value = '';
      selectedServiceId.value = '';
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