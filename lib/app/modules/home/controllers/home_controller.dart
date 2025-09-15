import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../views/home_view.dart';
import 'package:intl/intl.dart'; // For date formatting

class HomeController extends GetxController {
  var reports = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var hasToken = true.obs; // Assume logged in for demo
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
    loadDummyReports();
    startAutoScroll();
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


  void loadDummyReports() {
    // Dummy data mimicking the exact structure of the backend response
    reports.assignAll([
      {
        'id': '1',
        'description': 'Issue with service quality at the main branch.',
        'institution_name': 'City Hospital',
        'responsible_person': 'Dr. John Smith',
        'responsible_person_address': '123 Main St, City',
        'is_complaint': true,
        'first_name': 'Abebe',
        'father_name': 'Kebede',
        'grand_father_name': 'Tadesse',
        'report_place': 'Main Branch, Addis Ababa',
        'incident_time': '2025-08-20T10:00:00Z',
        'share_contact': true,
        'status': 'PENDING',
        'closed': false,
        'created_at': '2025-08-20T10:00:00Z',
        'ticket_number': 'TCK-001',
        'company_name': 'City Hospital Ltd.',
        'room_name': 'Room 101',
        'staff_name': 'Dr. John Smith',
        'attachments': [],
        'findings': 'Initial review in progress.',
        'ticket_created_at': '2025-08-20T10:00:00Z',
        'called_at': '2025-08-20T12:00:00Z',
        'served_date': null,
        'served': false,
        'closing_remark': null,
        'verification_remark': null,
        'fake_reason': null,
        'acceptance_remark': 'Awaiting verification.',
        'reportCategory': {
          'id': 'cat1',
          'name': 'Service Complaint',
        },
        'requests': [
          {
            'id': 'req1',
            'complaint_report_id': '1',
            'requested_by_id': 'admin1',
            'requested_at': '2025-08-21T09:00:00Z',
            'message': 'Please provide additional details about the incident.',
            'status': 'PENDING',
            'responded_by_id': null,
            'responded_at': null,
            'response_message': null,
            'response_attachment': null,
            'attachment': null,
            'requestedBy': {'id': 'admin1', 'name': 'Admin User'},
            'respondedBy': null,
          },
        ],
        'complaintReportEscalations': [],
      },
      {
        'id': '2',
        'description': 'Billing discrepancy reported.',
        'institution_name': 'City Bank',
        'responsible_person': 'Jane Doe',
        'responsible_person_address': '456 Bank St, City',
        'is_complaint': true,
        'first_name': 'Mulu',
        'father_name': 'Tesfaye',
        'grand_father_name': 'Girma',
        'report_place': 'Downtown Branch, Addis Ababa',
        'incident_time': '2025-08-15T14:30:00Z',
        'share_contact': false,
        'status': 'ACCEPTED',
        'closed': false,
        'created_at': '2025-08-15T14:30:00Z',
        'ticket_number': 'TCK-002',
        'company_name': 'City Bank Plc.',
        'room_name': 'Teller 5',
        'staff_name': 'Jane Doe',
        'attachments': [],
        'findings': 'Investigation ongoing.',
        'ticket_created_at': '2025-08-15T14:30:00Z',
        'called_at': '2025-08-16T10:00:00Z',
        'served_date': null,
        'served': false,
        'closing_remark': null,
        'verification_remark': 'Verified by manager.',
        'fake_reason': null,
        'acceptance_remark': 'Accepted for review.',
        'reportCategory': {
          'id': 'cat2',
          'name': 'Billing Issue',
        },
        'requests': [],
        'complaintReportEscalations': [
          {
            'id': 'esc1',
            'message': 'Requesting further investigation into billing issue.',
            'file': null,
            'response_message': 'Under review by senior management.',
            'responded_by_id': 'admin2',
            'created_at': '2025-08-16T11:00:00Z',
            'updated_at': '2025-08-17T09:00:00Z',
            'user': {'id': 'user1', 'name': 'Mulu Tesfaye'},
            'responder': {'id': 'admin2', 'name': 'Senior Admin'},
          },
        ],
      },
      {
        'id': '3',
        'description': 'Unresolved complaint about staff behavior.',
        'institution_name': 'Public Office',
        'responsible_person': 'Mr. Alemu',
        'responsible_person_address': '789 Gov St, City',
        'is_complaint': true,
        'first_name': 'Selam',
        'father_name': 'Hailu',
        'grand_father_name': 'Bekele',
        'report_place': 'Office 3, Addis Ababa',
        'incident_time': '2025-08-10T08:00:00Z',
        'share_contact': true,
        'status': 'CLOSED',
        'closed': true,
        'created_at': '2025-08-10T08:00:00Z',
        'ticket_number': 'TCK-003',
        'company_name': 'Public Office Ltd.',
        'room_name': 'Office 3',
        'staff_name': 'Mr. Alemu',
        'attachments': [],
        'findings': 'Issue resolved.',
        'ticket_created_at': '2025-08-10T08:00:00Z',
        'called_at': '2025-08-10T10:00:00Z',
        'served_date': '2025-08-12T15:00:00Z',
        'served': true,
        'closing_remark': 'Resolved after discussion.',
        'verification_remark': 'Verified by supervisor.',
        'fake_reason': null,
        'acceptance_remark': null,
        'reportCategory': {
          'id': 'cat3',
          'name': 'Staff Behavior',
        },
        'requests': [],
        'complaintReportEscalations': [],
      },
      {
        'id': '4',
        'description': 'Complaint marked invalid due to insufficient evidence.',
        'institution_name': 'Local Store',
        'responsible_person': 'Mrs. Genet',
        'responsible_person_address': '101 Market St, City',
        'is_complaint': true,
        'first_name': 'Tigist',
        'father_name': 'Mekonnen',
        'grand_father_name': 'Asrat',
        'report_place': 'Storefront, Addis Ababa',
        'incident_time': '2025-08-05T13:00:00Z',
        'share_contact': false,
        'status': 'INVALID_COMPLAINT',
        'closed': true,
        'created_at': '2025-08-05T13:00:00Z',
        'ticket_number': 'TCK-004',
        'company_name': 'Local Store Inc.',
        'room_name': 'Cashier 2',
        'staff_name': 'Mrs. Genet',
        'attachments': [],
        'findings': 'Insufficient evidence provided.',
        'ticket_created_at': '2025-08-05T13:00:00Z',
        'called_at': '2025-08-06T09:00:00Z',
        'served_date': null,
        'served': false,
        'closing_remark': 'Invalid due to lack of documentation.',
        'verification_remark': null,
        'fake_reason': 'Insufficient evidence.',
        'acceptance_remark': null,
        'reportCategory': {
          'id': 'cat4',
          'name': 'Customer Service',
        },
        'requests': [],
        'complaintReportEscalations': [],
      },
      {
        'id': '5',
        'description': 'Escalated due to unresolved issues.',
        'institution_name': 'Utility Company',
        'responsible_person': 'Mr. Yonas',
        'responsible_person_address': '321 Utility Rd, City',
        'is_complaint': true,
        'first_name': 'Bethel',
        'father_name': 'Solomon',
        'grand_father_name': 'Tsegaye',
        'report_place': 'Service Center, Addis Ababa',
        'incident_time': '2025-08-01T11:00:00Z',
        'share_contact': true,
        'status': 'ESCALATED',
        'closed': false,
        'created_at': '2025-08-01T11:00:00Z',
        'ticket_number': 'TCK-005',
        'company_name': 'Utility Company Ltd.',
        'room_name': 'Service Desk',
        'staff_name': 'Mr. Yonas',
        'attachments': [],
        'findings': 'Awaiting escalation review.',
        'ticket_created_at': '2025-08-01T11:00:00Z',
        'called_at': '2025-08-02T10:00:00Z',
        'served_date': null,
        'served': false,
        'closing_remark': null,
        'verification_remark': null,
        'fake_reason': null,
        'acceptance_remark': 'Escalated to senior management.',
        'reportCategory': {
          'id': 'cat5',
          'name': 'Utility Issue',
        },
        'requests': [],
        'complaintReportEscalations': [
          {
            'id': 'esc2',
            'message': 'Urgent escalation needed for unresolved issue.',
            'file': null,
            'response_message': null,
            'responded_by_id': null,
            'created_at': '2025-08-02T12:00:00Z',
            'updated_at': '2025-08-02T12:00:00Z',
            'user': {'id': 'user2', 'name': 'Bethel Solomon'},
            'responder': null,
          },
        ],
      },
    ]);
  }

  Future<void> replyToRequest(
      String requestId, String message, PlatformFile? file) async {
    isLoading(true);
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    try {
      // Find the report and request
      final report = reports.firstWhereOrNull(
              (r) => r['requests'].any((req) => req['id'] == requestId));
      if (report == null) {
        throw Exception('Request not found.');
      }

      final requestIndex = report['requests']
          .indexWhere((req) => req['id'] == requestId);
      if (requestIndex == -1) {
        throw Exception('Request not found.');
      }

      // Update the request with response
      report['requests'][requestIndex] = {
        ...report['requests'][requestIndex],
        'status': 'RESPONDED',
        'response_message': message,
        'response_attachment': file != null ? file.name : null,
        'responded_at': DateTime.now().toIso8601String(),
        'respondedBy': {'id': 'user1', 'name': 'Current User'},
      };

      // Update reports list
      reports.refresh();

      Get.snackbar(
        'Success',
        'Reply sent successfully!',
        backgroundColor: TColorss.primary,
        colorText: TColorss.surface,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send reply: $e',
        backgroundColor: TColorss.error,
        colorText: TColorss.surface,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> refreshReports() async {
    isLoading(true);
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    loadDummyReports();
    isLoading(false);
  }

  void navigateToLogin() {
    Get.snackbar(
      'Info',
      'Login navigation disabled in demo mode.',
      backgroundColor: TColorss.primary,
      colorText: TColorss.surface,
    );
  }

  void changeTab(String tab) {
    currentTab.value = tab;
    print('Changed tab to: $tab');
  }

  Future<void> appealReport(
      String reportId, String message, PlatformFile? file) async {
    isLoading(true);
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    try {
      final report =
      reports.firstWhereOrNull((r) => r['id'].toString() == reportId);
      final status =
      report != null ? (report['status'] ?? '').toString().toUpperCase() : '';

      if (report == null ||
          (status != 'INVALID_COMPLAINT' && status != 'CLOSED')) {
        throw Exception(
            'Only reports marked as INVALID_COMPLAINT or CLOSED can be escalated.');
      }

      if (message.length > 500) {
        throw Exception('Appeal message cannot exceed 500 characters.');
      }

      if (file != null) {
        final allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png'];
        final extension = file.name.split('.').last.toLowerCase();
        if (!allowedExtensions.contains(extension)) {
          throw Exception(
              'Invalid file type. Only PDF, JPG, JPEG, or PNG files are allowed.');
        }
        if (file.size > 5 * 1024 * 1024) {
          throw Exception('File size exceeds 5MB limit.');
        }
      }

      // Add new escalation to the report
      final newEscalation = {
        'id': 'esc${reports.length + 1}',
        'message': message,
        'file': file != null ? file.name : null,
        'response_message': null,
        'responded_by_id': null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'user': {'id': 'user1', 'name': 'Current User'},
        'responder': null,
      };

      report['complaintReportEscalations'].add(newEscalation);
      report['status'] = 'ESCALATED';

      // Update reports list
      reports.refresh();

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
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while submitting appeal: $e',
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
          return status == 'PENDING' || hasPendingRequests;
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