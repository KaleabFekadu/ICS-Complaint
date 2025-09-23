import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:ics_complaint/app/modules/bottom_nav_home/views/bottom_nav_home_view.dart';
import 'package:ics_complaint/app/modules/home/views/home_view.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/constants/config.dart';

class FeedbackController extends GetxController {
  var selectedBranchId = ''.obs;
  var selectedServiceId = ''.obs;
  var rating = 0.obs;
  var description = ''.obs;
  var isSubmitting = false.obs;
  var isLoadingBranches = false.obs;
  var isLoadingServices = false.obs;
  var errorMessage = ''.obs;
  late TextEditingController descriptionController;


  final branches = <Map<String, dynamic>>[].obs;
  final services = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBranches();
    descriptionController = TextEditingController();
    // keep them in sync
    descriptionController.addListener(() {
      description.value = descriptionController.text;
    });
  }

  @override
  void onClose() {
    descriptionController.dispose();
    super.onClose();
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
        services.assignAll((data['services'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .where((service) => !(service['draft'] ?? false))
            .toList());
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

      final client = GraphQLClient(
        link: HttpLink(
          '${Config.baseUrl}/graphql',
          defaultHeaders: {'Authorization': 'Bearer $token'},
        ),
        cache: GraphQLCache(),
      );

      const mutation = r'''
        mutation CreateCorruptionReport($input: CorruptionReportCreateInput!) {
          createCorruptionReport(input: $input) {
            id
            description
            category
            rating
            feedback_description
            service {
              id
              name
            }
            branch {
              id
              name
            }
            status
            created_at
          }
        }
      ''';

      // Get user details from SharedPreferences
      final firstName = prefs.getString('first_name') ?? 'Anonymous';
      final fatherName = prefs.getString('father_name') ?? '';
      final grandFatherName = prefs.getString('grand_father_name') ?? '';

      // Get branch and service names for better description
      final selectedBranch = branches.firstWhere(
            (branch) => branch['id'].toString() == selectedBranchId.value,
        orElse: () => {'name': 'Unknown Branch'},
      );
      final selectedService = services.firstWhere(
            (service) => service['id'].toString() == selectedServiceId.value,
        orElse: () => {'name': 'Unknown Service'},
      );
      final branchName = selectedBranch['name'];
      final serviceName = selectedService['name'];

      // Format service_date to date-only (YYYY-MM-DD)
      // Format service_date to match backend expectation: "YYYY-MM-DD HH:MM:SS"
      final now = DateTime.now().toUtc();
      final serviceDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

      final input = {
        'description': 'Feedback for $serviceName at $branchName',
        'category': 'feedback',
        'service_id': selectedServiceId.value,
        'branch_id': selectedBranchId.value,
        'rating': rating.value,
        'feedback_description': description.value.trim(),
        'institution_name': branchName,
        'report_place': serviceName,
        'service_date': serviceDate, // This will now be "2025-09-21 14:30:45"
        'share_contact': false,
        'is_complaint': false,
        'first_name': firstName.isNotEmpty ? firstName : 'Anonymous',
        'father_name': fatherName,
        'grand_father_name': grandFatherName,
        'attachments': [],
      };

      // Debug input
      print('Submitting feedback with input: $input');

      final result = await client.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {'input': input},
          fetchPolicy: FetchPolicy.networkOnly,
          errorPolicy: ErrorPolicy.all,
        ),
      );

      if (result.hasException) {
        String errorMsg = 'Failed to submit feedback: ${result.exception.toString()}'.tr;
        if (result.exception!.graphqlErrors.isNotEmpty) {
          errorMsg = result.exception!.graphqlErrors.first.message;
          if (errorMsg.toLowerCase().contains('unauthorized') ||
              errorMsg.toLowerCase().contains('token')) {
            await prefs.remove('access_token');
            Get.offAllNamed('/login');
            errorMsg = 'Session expired. Please log in again.'.tr;
          } else if (errorMsg.toLowerCase().contains('service_id') ||
              errorMsg.toLowerCase().contains('branch_id')) {
            errorMsg = 'Invalid branch or service selected. Please try again.'.tr;
          } else if (errorMsg.toLowerCase().contains('service_date')) {
            errorMsg = 'Invalid date format. Please try again.'.tr;
          }
        } else if (result.exception!.linkException != null) {
          errorMsg = 'Network error: Please check your internet connection.'.tr;
        }
        print('Submission error: $errorMsg');
        Get.snackbar(
          'Error'.tr,
          errorMsg,
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

      final data = result.data?['createCorruptionReport'] as Map<String, dynamic>?;
      if (data == null) {
        print('Submission error: No data returned from server');
        Get.snackbar(
          'Error'.tr,
          'No data returned from server.'.tr,
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

      print('Feedback submitted successfully: $data');
      Get.snackbar(
        'Success'.tr,
        'Feedback submitted successfully!'.tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 2),
        isDismissible: true,
      );

      // Reset fields
      selectedBranchId.value = '';
      selectedServiceId.value = '';
      rating.value = 0;
      description.value = '';

      // Navigate back to previous screen
      Get.to(BottomNavHomeView());
    } catch (e) {
      print('Unexpected error during submission: $e');
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