import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/constants/config.dart';
import 'package:dio/dio.dart' as dio;

import '../../create_complaint/views/create_complaint_view.dart';

class HomeController extends GetxController {
  var reports = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var hasToken = false.obs;
  var currentTab = 'pending'.obs;
  late Timer autoScrollTimer;
  var currentPagenews = 0.obs;
  final PageController announcementsPageController = PageController();
  var currentPage = 0.obs;
  final PageController newsPageController = PageController();
  var selectedIndex = 0.obs;




  List<String> announcements = [
    'Public Hearing Scheduled',
    'Citizen Feedback Initiative',
    'New Case Procedures',
    'Legal Training Session',
    'Case Updates',
  ];

  @override
  void onInit() {
    super.onInit();
    checkTokenAndFetchReports();
    startAutoScroll();
    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        // Network is restored, attempt to refresh reports
        refreshReports();
      }
    });
  }

  void startAutoScroll() {
    autoScrollTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (announcementsPageController.hasClients) {
        int nextPage = (currentPage.value + 1) % announcements.length;
        announcementsPageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        currentPage.value = nextPage;
      }

      if (newsPageController.hasClients) {
        int nextPage = (currentPagenews.value + 1) % 3;
        newsPageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
        currentPagenews.value = nextPage;
      }
    });
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token'); // Changed from 'token' to 'access_token'
    if (token == null || token.isEmpty) {
      errorMessage.value = 'Please log in to access reports.'.tr; // Added .tr for localization
      hasToken.value = false;
      Get.offAllNamed('/login'); // Navigate to login if no token
      return null;
    }
    hasToken.value = true;
    return token;
  }

  Future<void> checkTokenAndFetchReports() async {
    final token = await _getToken();
    if (token != null) {
      await fetchReports(token);
    } else {
      // Optional: Show a snackbar to inform the user
      Get.snackbar(
        'Error'.tr,
        'Please log in to access reports.'.tr,
        backgroundColor: TColorss.error,
        colorText: TColorss.surface,
        snackPosition: SnackPosition.TOP,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        icon: const Icon(Iconsax.warning_2, color: TColorss.surface),
      );
    }
  }

  Future<void> _cacheReports(List<Map<String, dynamic>> reports) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_reports', json.encode(reports));
  }

  Future<List<Map<String, dynamic>>> _getCachedReports() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cached_reports');
    if (cachedData != null) {
      try {
        final List<dynamic> decoded = json.decode(cachedData);
        return decoded.cast<Map<String, dynamic>>();
      } catch (e) {
        print('Error decoding cached reports: $e');
        return [];
      }
    }
    return [];
  }

  void _logError(dynamic error, StackTrace stackTrace,
      {String? status, String? context}) {
    print(
        'ERROR${status != null ? ' for status $status' : ''}${context != null ? ' in $context' : ''}: $error');
    print('STACK TRACE: $stackTrace');

    if (error is OperationException) {
      print('GRAPHQL ERROR DETAILS:');
      for (var err in error.graphqlErrors) {
        print('Message: ${err.message}');
        print('Path: ${err.path}');
        print('Locations: ${err.locations}');
        print('Extensions: ${err.extensions}');

        // Provide user-friendly error messages
        if (err.message.contains('unauthorized') ||
            err.message.contains('token')) {
          //errorMessage.value = 'Session expired. Please log in again.';
          hasToken.value = false;
        } else if (err.message.contains('permission')) {
          // errorMessage.value = 'You don\'t have permission to view these reports.';
        }
      }
    } else if (error is dio.DioException) {
      if (error.response?.statusCode == 401 ||
          error.response?.statusCode == 403) {
        //errorMessage.value = 'Session expired. Please log in again.';
        hasToken.value = false;
      } else if (error.type == dio.DioExceptionType.connectionTimeout ||
          error.type == dio.DioExceptionType.receiveTimeout) {
        //errorMessage.value = 'Connection timeout. Please check your internet connection.';
      } else {
        //errorMessage.value = 'Network error: ${error.message}';
      }
    }
  }

  Future<void> fetchReports(String token) async {
    isLoading(true);
    errorMessage('');

    // Load cached reports first
    final cachedReports = await _getCachedReports();
    if (cachedReports.isNotEmpty) {
      reports.assignAll(cachedReports);
    }

    // Check network connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      errorMessage.value = 'No internet connection.';
      isLoading(false);
      return;
    }

    try {
      final query = r'''
        query MyReportsByStatus($status: ReportStatusEnum) {
          my_reports(status: $status) {
            id
            description
            institution_name
            responsible_person
            responsible_person_phone
            responsible_person_address
            report_place
            associated_parties
            is_complaint
            first_name
            father_name
            grand_father_name
            service_date
            share_contact
            status
            service {
              id
              name
              description
            }
            branch {
              id
              name
              code
              description
            }
            attachments
            findings
            created_at
            complaintReportEscalations {
              id
              message
              file
              response_message
              created_at
              user {
                id
                name
              }
            }
            requests {
              id
              message
              status
              responded_at
              response_message
              respondedBy {
                id
                name
              }
            }
          }
        }
      ''';

      final client = GraphQLClient(
        link: HttpLink(
          '${Config.baseUrl}/graphql',
          defaultHeaders: {'Authorization': 'Bearer $token'},
        ),
        cache: GraphQLCache(),
      );

      final validStatuses = [
        'PENDING',
        'ACCEPTED',
        'CLOSED',
        'INVALID_COMPLAINT',
        'ESCALATED',
      ];

      final reportIds = <String>{};
      List<Map<String, dynamic>> allReports = [];
      List<String> failedStatuses = [];

      for (var status in validStatuses) {
        final result = await client.query(
          QueryOptions(
            document: gql(query),
            variables: {'status': status},
            fetchPolicy: FetchPolicy.networkOnly,
            errorPolicy: ErrorPolicy.all,
          ),
        );

        if (result.hasException) {
          _logError(result.exception, StackTrace.current,
              status: status, context: 'fetchReports');
          failedStatuses.add(status);
          continue;
        }

        final rawData = result.data?['my_reports'] as List<dynamic>?;
        print('Raw response for status $status: $rawData');
        if (rawData != null) {
          final filteredReports = rawData.map((report) {
            final reportMap = Map<String, dynamic>.from(report as Map<String, dynamic>);
            final reportId = reportMap['id'].toString();
            final reportStatus = (reportMap['status'] ?? '').toString().toUpperCase();

            if (reportIds.contains(reportId)) {
              print('Skipping duplicate report ID: $reportId for status $status');
              return null;
            }

            if (reportStatus != status) {
              print('Skipping report ID $reportId with mismatched status $reportStatus for queried status $status');
              return null;
            }

            if (reportStatus.isEmpty) {
              print('Warning: Skipping report ID $reportId with empty status');
              return null;
            }
            if (!validStatuses.contains(reportStatus)) {
              print('Warning: Skipping report ID $reportId with invalid status "$reportStatus"');
              return null;
            }

            reportIds.add(reportId);
            return reportMap;
          }).where((report) => report != null).toList();

          allReports.addAll(filteredReports.cast<Map<String, dynamic>>());
        }
      }

      if (allReports.isEmpty && failedStatuses.length == validStatuses.length) {
        print('No valid reports found. Attempting to fetch all reports without status filter...');
        final result = await client.query(
          QueryOptions(
            document: gql(query),
            variables: {},
            fetchPolicy: FetchPolicy.networkOnly,
            errorPolicy: ErrorPolicy.all,
          ),
        );

        if (result.hasException) {
          print('Fallback query failed: ${result.exception.toString()}');
          _logError(result.exception, StackTrace.current,
              status: 'ALL', context: 'fetchReports');
        } else {
          final rawData = result.data?['my_reports'] as List<dynamic>?;
          print('Fallback query raw response: $rawData');
          if (rawData != null) {
            final filteredReports = rawData.map((report) {
              final reportMap = Map<String, dynamic>.from(report as Map<String, dynamic>);
              final reportId = reportMap['id'].toString();
              final reportStatus = (reportMap['status'] ?? '').toString().toUpperCase();

              if (reportIds.contains(reportId)) {
                print('Skipping duplicate report ID: $reportId in fallback query');
                return null;
              }

              if (reportStatus.isEmpty) {
                print('Warning: Skipping report ID $reportId with empty status');
                return null;
              }
              if (!validStatuses.contains(reportStatus)) {
                print('Warning: Skipping report ID $reportId with invalid status "$reportStatus"');
                return null;
              }

              reportIds.add(reportId);
              return reportMap;
            }).where((report) => report != null).toList();

            print('Fetched ${filteredReports.length} valid reports from fallback query');
            allReports.addAll(filteredReports.cast<Map<String, dynamic>>());
          }
        }
      }

      print('Total unique reports fetched: ${allReports.length}');
      if (allReports.isEmpty && cachedReports.isEmpty) {
        errorMessage.value = 'No valid reports found. Please check your connection or try again.';
      } else if (failedStatuses.isNotEmpty) {
        errorMessage.value = 'Some reports could not be loaded for statuses: ${failedStatuses.join(', ')}.';
      }

      reports.assignAll(allReports);
      // Cache the fetched reports
      if (allReports.isNotEmpty) {
        await _cacheReports(allReports);
      }
    } catch (e) {
      errorMessage.value = 'Network error: ${e.toString()}';
      _logError(e, StackTrace.current, context: 'fetchReports');
      // Show cached reports if available
      if (cachedReports.isNotEmpty) {
        errorMessage.value = 'Network error. Showing cached reports.';
        reports.assignAll(cachedReports);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> replyToRequest(
      String requestId, String message, PlatformFile? file) async {
    final token = await _getToken();
    if (token == null) {
      Get.snackbar(
        'Error',
        'Please log in to submit a reply.',
        backgroundColor: TColorss.error,
        colorText: TColorss.surface,
      );
      return;
    }

    isLoading(true);
    try {
      final dioClient = dio.Dio();

      // Prepare the GraphQL operation
      final operations = {
        'query': '''
        mutation UpdateComplaintReportRequest(\$input: ComplaintReportRequestUpdateInput!) {
          updateComplaintReportRequest(input: \$input) {
            id
            status
            response_message
            response_attachment
            responded_at
          }
        }
      ''',
        'variables': {
          'input': {
            'id': requestId,
            'response_message': message,
            'response_attachment': null, // Will be mapped if file exists
          }
        }
      };

      // Create form data
      final formData = dio.FormData.fromMap({
        'operations': json.encode(operations),
        'map': json.encode({
          if (file != null && file.bytes != null)
            '0': ['variables.input.response_attachment']
        }),
      });

      // Add file if exists
      if (file != null && file.bytes != null) {
        formData.files.add(MapEntry(
          '0',
          await dio.MultipartFile.fromBytes(
            file.bytes!,
            filename: file.name,
          ),
        ));
      }

      final response = await dioClient.post(
        '${Config.baseUrl}/graphql',
        data: formData,
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        final result = response.data;
        if (result['errors'] != null) {
          throw Exception(result['errors'][0]['message']);
        }

        Get.snackbar(
          'Success',
          'Reply sent successfully!',
          backgroundColor: TColorss.primary,
          colorText: TColorss.surface,
        );
        await refreshReports();
      } else {
        throw Exception('Failed to send reply: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send reply: ${e.toString()}',
        backgroundColor: TColorss.error,
        colorText: TColorss.surface,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> refreshReports() async {
    final token = await _getToken();
    if (token != null) {
      // Clear any stale error messages
      errorMessage('');
      await fetchReports(token);
    }
  }


  void navigateToLogin() {
    Get.toNamed('/login');
  }

  void changeTab(String tab) {
    currentTab.value = tab;
    print('Changed tab to: $tab'); // Debug
  }

  Future<void> appealReport(
      String reportId, String message, PlatformFile? file) async {
    final token = await _getToken();
    if (token == null) {
      Get.snackbar(
        'Error',
        'Please log in to submit an appeal.',
        backgroundColor: TColorss.error,
        colorText: TColorss.surface,
        snackPosition: SnackPosition.BOTTOM,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        icon: const Icon(Iconsax.warning_2, color: TColorss.surface),
      );
      return;
    }

    // Validate report status - UPDATED to allow both INVALID_COMPLAINT and CLOSED
    final report =
    reports.firstWhereOrNull((r) => r['id'].toString() == reportId);
    final status =
    report != null ? (report['status'] ?? '').toString().toUpperCase() : '';

    if (report == null ||
        (status != 'INVALID_COMPLAINT' && status != 'CLOSED')) {
      Get.snackbar(
        'Error',
        'Only reports marked as INVALID_COMPLAINT or CLOSED can be escalated.',
        backgroundColor: TColorss.error,
        colorText: TColorss.surface,
        snackPosition: SnackPosition.BOTTOM,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        icon: const Icon(Iconsax.warning_2, color: TColorss.surface),
      );
      return;
    }

    if (message.length > 500) {
      Get.snackbar(
        'Error',
        'Appeal message cannot exceed 500 characters.',
        backgroundColor: TColorss.error,
        colorText: TColorss.surface,
        snackPosition: SnackPosition.BOTTOM,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        icon: const Icon(Iconsax.warning_2, color: TColorss.surface),
      );
      return;
    }

    isLoading(true);
    try {
      // Create Dio instance with proper headers
      final dioClient = dio.Dio();

      // Prepare the GraphQL operation
      final operations = {
        'query': '''
        mutation EscalateCorruptionReport(\$input: EscalateCorruptionReportInput!) {
          escalateCorruptionReport(input: \$input) {
            id
            complaint_report_id
            message
            file
            created_at
            updated_at
            user {
              id
              name
            }
          }
        }
      ''',
        'variables': {
          'input': {
            'id': reportId,
            'message': message,
          }
        }
      };

      // Create form data
      final formData = dio.FormData.fromMap({
        'operations': json.encode(operations),
        'map': json.encode({
          if (file != null && file.bytes != null) '0': ['variables.input.file']
        }),
      });

      // Validate and add file if exists
      if (file != null && file.bytes != null) {
        final allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png'];
        final extension = file.name.split('.').last.toLowerCase();

        if (!allowedExtensions.contains(extension)) {
          Get.snackbar(
            'Error',
            'Invalid file type. Only PDF, JPG, JPEG, or PNG files are allowed.',
            backgroundColor: TColorss.error,
            colorText: TColorss.surface,
            snackPosition: SnackPosition.BOTTOM,
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
            icon: const Icon(Iconsax.warning_2, color: TColorss.surface),
          );
          isLoading(false);
          return;
        }

        if (file.size > 5 * 1024 * 1024) {
          Get.snackbar(
            'Error',
            'File size exceeds 5MB limit.',
            backgroundColor: TColorss.error,
            colorText: TColorss.surface,
            snackPosition: SnackPosition.BOTTOM,
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
            icon: const Icon(Iconsax.warning_2, color: TColorss.surface),
          );
          isLoading(false);
          return;
        }

        // Add file to form data
        formData.files.add(MapEntry(
          '0',
          await dio.MultipartFile.fromBytes(
            file.bytes!,
            filename: file.name,
          ),
        ));
      }

      // Make the request with proper authorization
      final response = await dioClient.post(
        '${Config.baseUrl}/graphql',
        data: formData,
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
            'Accept': 'application/json',
          },
        ),
      );

      // Handle response
      if (response.statusCode == 200) {
        final result = response.data;
        if (result['errors'] != null) {
          throw Exception(result['errors'][0]['message']);
        }

        print('Escalation mutation response: $result');
        Get.snackbar(
          'Success',
          'Appeal submitted successfully for report ID: $reportId',
          backgroundColor: TColorss.primary,
          colorText: TColorss.surface,
          snackPosition: SnackPosition.BOTTOM,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
          icon: const Icon(Iconsax.tick_circle, color: TColorss.surface),
        );

        // Refresh reports to reflect status change
        await refreshReports();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Handle unauthorized/forbidden cases
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        hasToken.value = false;
        navigateToLogin();
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception('Failed to upload: ${response.statusCode}');
      }
    } catch (e) {
      print('Escalation error: $e');
      _logError(e, StackTrace.current, context: 'appealReport');

      String errorMessage = 'An error occurred while submitting appeal';
      if (e.toString().contains('unauthorized') ||
          e.toString().contains('expired')) {
        //errorMessage = 'Session expired or unauthorized. Please log in again.';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: TColorss.error,
        colorText: TColorss.surface,
        snackPosition: SnackPosition.BOTTOM,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        icon: const Icon(Iconsax.warning_2, color: TColorss.surface),
      );
    } finally {
      isLoading(false);
    }
  }

  List<Map<String, dynamic>> getFilteredReports() {
    final filtered = reports.where((report) {
      final status = (report['status'] ?? '').toString().toUpperCase();
      final requests = (report['requests'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>() ??
          [];
      final hasPendingRequests =
      requests.any((req) => req['status'] == 'PENDING');

      switch (currentTab.value) {
        case 'pending':
          return status == 'PENDING' && (hasPendingRequests || requests.isEmpty);
        case 'accepted':
          return status == 'ACCEPTED';
        case 'closed':
          return status == 'CLOSED';
        case 'invalid':
          return status == 'INVALID_COMPLAINT';
        case 'escalated':
          return status == 'ESCALATED';
        default:
          return false;
      }
    }).toList();
    print('Filtered ${filtered.length} reports for tab ${currentTab.value}');
    return filtered;
  }
}
