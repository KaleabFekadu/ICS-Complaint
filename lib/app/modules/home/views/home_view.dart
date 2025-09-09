import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../utils/constants/colors.dart';
import '../controllers/home_controller.dart';

class TColorss {
  static const Color primary = Color(0xFF04235b);
  static const Color accent = Color(0xFFFF6B6B);
  static const Color background = Color(0xFFF5F7FA);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color error = Color(0xFFF05252);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF1F5F9);
}

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: FadeInDown(
          duration: const Duration(milliseconds: 400),
          child: Text(
            'My Reports'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: TColorss.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: TColorss.background,
        elevation: 0,
        toolbarHeight: 60,
        titleSpacing: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Spin(
              duration: const Duration(milliseconds: 1000),
              child: CircularProgressIndicator(
                color: TColorss.primary,
                strokeWidth: 4,
                backgroundColor: TColorss.primary.withOpacity(0.2),
              ),
            ),
          );
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: FadeInUp(
              duration: const Duration(milliseconds: 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.warning_2,
                    size: 64,
                    color: TColorss.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: TColorss.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ZoomIn(
                    duration: const Duration(milliseconds: 400),
                    child: ElevatedButton(
                      onPressed: controller.refreshReports,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColorss.primary,
                        foregroundColor: TColorss.surface,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            _buildTabBar(context),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshReports,
                color: TColorss.primary,
                child: controller.reports.isEmpty
                    ? Center(
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.stickynote,
                          size: 64,
                          color: TColorss.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Reports Available',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: TColorss.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
                    : _buildReportList(context),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final tabs = [
      {
        'label': 'Pending'.tr,
        'value': 'pending',
        'icon': Iconsax.timer,
        'color': TColorss.primary,
      },
      {
        'label': 'Accepted'.tr,
        'value': 'accepted',
        'icon': Iconsax.activity,
        'color': Colors.blue,
      },
      {
        'label': 'Closed'.tr,
        'value': 'closed',
        'icon': Iconsax.tick_circle,
        'color': Colors.green,
      },
      {
        'label': 'Invalid'.tr,
        'value': 'invalid',
        'icon': Iconsax.close_circle,
        'color': TColorss.error,
      },
      {
        'label': 'Escalated'.tr,
        'value': 'escalated',
        'icon': Iconsax.arrow_up_3,
        'color': Colors.orange,
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: TColorss.surface,
        boxShadow: [
          BoxShadow(
            color: TColorss.textPrimary.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          return Expanded(
            child: Obx(
                  () => GestureDetector(
                onTap: () => controller.changeTab(tab['value'] as String),
                child: FadeIn(
                  duration: const Duration(milliseconds: 400),
                  delay: Duration(milliseconds: 100 * index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: controller.currentTab.value == tab['value']
                          ? (tab['color'] as Color).withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          tab['icon'] as IconData,
                          size: 24,
                          color: controller.currentTab.value == tab['value']
                              ? tab['color'] as Color
                              : TColorss.textSecondary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tab['label'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: controller.currentTab.value == tab['value']
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: controller.currentTab.value == tab['value']
                                ? tab['color'] as Color
                                : TColorss.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReportList(BuildContext context) {
    final filteredReports = controller.getFilteredReports();
    if (filteredReports.isEmpty) {
      return Center(
        child: FadeInUp(
          duration: const Duration(milliseconds: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.stickynote,
                size: 64,
                color: TColorss.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                controller.currentTab.value == 'pending'
                    ? 'No Pending Reports Available'
                    : 'No ${controller.currentTab.value.capitalizeFirst} Reports Available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: TColorss.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredReports.length,
      itemBuilder: (context, index) {
        final report = filteredReports[index];
        return FadeInUp(
          duration: Duration(milliseconds: 400 + index * 100),
          child: _buildReportCard(context, report),
        );
      },
    );
  }

  Widget _buildReportCard(BuildContext context, Map<String, dynamic> report) {
    final status = (report['status'] ?? 'UNKNOWN').toString().toUpperCase();
    final requests = (report['requests'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final hasPendingRequests = requests.any((req) => req['status'] == 'PENDING');

    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'PENDING':
        statusColor = TColorss.primary;
        statusIcon = Iconsax.timer;
        break;
      case 'ACCEPTED':
        statusColor = Colors.blue;
        statusIcon = Iconsax.activity;
        break;
      case 'CLOSED':
        statusColor = Colors.green;
        statusIcon = Iconsax.tick_circle;
        break;
      case 'INVALID_COMPLAINT':
        statusColor = TColorss.error;
        statusIcon = Iconsax.close_circle;
        break;
      case 'ESCALATED':
        statusColor = Colors.orange;
        statusIcon = Iconsax.arrow_up_3;
        break;
      default:
        statusColor = TColorss.textSecondary;
        statusIcon = Iconsax.stickynote;
    }

    return GestureDetector(
      onTap: () => _showReportModal(context, report),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            color: TColorss.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: TColorss.textPrimary.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: TColorss.surfaceSecondary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: TColorss.textPrimary.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/img/logos/mesob.png',
                            width: 40,
                            height: 40,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Iconsax.stickynote,
                              size: 40,
                              color: TColorss.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                report['staff_name'] ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: TColorss.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ticket: ${report['ticket_number'] ?? 'N/A'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: TColorss.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Track No: ${report['id'] ?? 'N/A'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: TColorss.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                statusIcon,
                                size: 16,
                                color: statusColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                status,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatDateTime(report['created_at']),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: TColorss.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (hasPendingRequests)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      requests.where((req) => req['status'] == 'PENDING').length.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportModal(BuildContext context, Map<String, dynamic> report) {
    final status = (report['status'] ?? 'UNKNOWN').toString().toUpperCase();
    final requests = (report['requests'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final escalations = (report['complaintReportEscalations'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final hasPendingRequests = requests.any((req) => req['status'] == 'PENDING');
    final reportCategory = report['reportCategory'] as Map<String, dynamic>?;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: TColorss.surface,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Report Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: TColorss.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Iconsax.close_circle, color: TColorss.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (reportCategory != null)
                        _buildDetailRow('Category', reportCategory['name'] ?? 'N/A'),
                      _buildDetailRow('Ticket Number', report['ticket_number'] ?? 'N/A'),
                      _buildDetailRow('Track Number', report['id'] ?? 'N/A'),
                      _buildDetailRow('Staff Name', report['staff_name'] ?? 'N/A'),
                      _buildDetailRow('Room Name', report['room_name'] ?? 'N/A'),
                      _buildDetailRow('Ticket Created At', _formatDateTime(report['ticket_created_at'])),
                      _buildDetailRow('Called At', _formatDateTime(report['called_at'])),
                      _buildDetailRow('Served Date', _formatDateTime(report['served_date'])),
                      _buildDetailRow('Served', report['served'] == true ? 'Yes' : 'No'),
                      _buildDetailRow('First Name', report['first_name'] ?? 'N/A'),
                      _buildDetailRow('Father\'s Name', report['father_name'] ?? 'N/A'),
                      _buildDetailRow('Grandfather\'s Name', report['grand_father_name'] ?? 'N/A'),
                      _buildDetailRow('Institution Name', report['institution_name'] ?? 'N/A'),
                      _buildDetailRow('Institution Address', report['report_place'] ?? 'N/A'),
                      const Divider(color: TColorss.textSecondary),
                      _buildDetailRow('Description', report['description'] ?? 'N/A'),
                      _buildDetailRow(
                        'Status',
                        report['status'] ?? 'N/A',
                        color: _getStatusColor(report['status']),
                      ),
                      _buildDetailRow('Acceptance Remark', report['acceptance_remark'] ?? 'N/A'),
                      if (status == 'CLOSED' && report['closing_remark'] != null)
                        _buildDetailRow('Closing Remarks', report['closing_remark']),
                      if (status == 'INVALID_COMPLAINT' && report['closing_remark'] != null)
                        _buildDetailRow('Invalid Reason', report['closing_remark']),
                      if (report['verification_remark'] != null)
                        _buildDetailRow('Verification Remarks', report['verification_remark']),
                      if (requests.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Requests for Additional Info',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: TColorss.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...requests.map((request) => _buildRequestCard(context, request)).toList(),
                      ],
                      if (escalations.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Escalations & Messages',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: TColorss.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...escalations.map((escalation) => _buildEscalationCard(context, escalation)).toList(),
                      ],
                      const SizedBox(height: 16),
                      if (status == 'INVALID_COMPLAINT' || status == 'CLOSED') ...[
                        const SizedBox(height: 8),
                        Text(
                          status == 'INVALID_COMPLAINT'
                              ? 'This report was marked invalid. You can appeal to request a review.'
                              : 'This report was closed. You can appeal if you need further assistance.',
                          style: TextStyle(
                            fontSize: 14,
                            color: TColorss.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ZoomIn(
                          duration: const Duration(milliseconds: 400),
                          child: ElevatedButton.icon(
                            onPressed: () => _showAppealDialog(context, report['id'].toString()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TColorss.accent,
                              foregroundColor: TColorss.surface,
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 2,
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            icon: const Icon(Iconsax.message_question, size: 20),
                            label: const Text('Escalate Report'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEscalationCard(BuildContext context, Map<String, dynamic> escalation) {
    final user = escalation['user'] as Map<String, dynamic>? ?? {};
    final responder = escalation['responder'] as Map<String, dynamic>? ?? {};
    final hasResponse = escalation['response_message'] != null && (escalation['response_message'] as String).isNotEmpty;
    final hasFile = escalation['file'] != null && (escalation['file'] as String).isNotEmpty;

    return SlideInUp(
      duration: const Duration(milliseconds: 400),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        elevation: 6,
        shadowColor: TColorss.textPrimary.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                TColorss.surface,
                TColorss.surfaceSecondary.withOpacity(0.9),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['name'] ?? 'You',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: TColorss.textPrimary,
                            ),
                          ),
                          Text(
                            _formatDateTime(escalation['created_at']),
                            style: TextStyle(
                              fontSize: 12,
                              color: TColorss.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                const SizedBox(height: 16),
                if (escalation['message'] != null && (escalation['message'] as String).isNotEmpty) ...[
                  Text(
                    'Message:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: TColorss.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    escalation['message'],
                    style: TextStyle(
                      fontSize: 14,
                      color: TColorss.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (hasResponse) ...[
                  Divider(
                    color: TColorss.textSecondary.withOpacity(0.3),
                    thickness: 1,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Iconsax.message_tick,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Admin Response • ${_formatDateTime(escalation['updated_at'] ?? escalation['created_at'])}',
                          style: TextStyle(
                            fontSize: 12,
                            color: TColorss.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (responder['name'] != null)
                    Text(
                      'By: ${responder['name']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: TColorss.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      escalation['response_message'],
                      style: TextStyle(
                        fontSize: 14,
                        color: TColorss.textPrimary,
                      ),
                    ),
                  ),
                ] else if (escalation['responded_by_id'] != null) ...[
                  Divider(
                    color: TColorss.textSecondary.withOpacity(0.3),
                    thickness: 1,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Iconsax.clock,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Response in progress...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, Map<String, dynamic> request) {
    final isPending = request['status'] == 'PENDING';
    final TextEditingController messageController = TextEditingController();
    final RxString selectedFileName = ''.obs;
    final Rx<PlatformFile?> selectedFile = Rx<PlatformFile?>(null);

    return SlideInUp(
      duration: const Duration(milliseconds: 400),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        elevation: 6,
        shadowColor: TColorss.textPrimary.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                TColorss.surface,
                TColorss.surfaceSecondary.withOpacity(0.9),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElasticIn(
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        'Request #${request['id']}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isPending ? TColorss.primary : TColorss.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    ZoomIn(
                      duration: const Duration(milliseconds: 400),
                      child: Chip(
                        label: Text(
                          request['status'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isPending ? TColorss.surface : Colors.white,
                          ),
                        ),
                        backgroundColor: isPending ? TColorss.primary : Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isPending ? TColorss.primary.withOpacity(0.4) : Colors.green.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        elevation: 2,
                        shadowColor: TColorss.textPrimary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FadeIn(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    request['message'] ?? 'No message',
                    style: const TextStyle(
                      fontSize: 15,
                      color: TColorss.textPrimary,
                      height: 1.6,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                if (!isPending && request['response_message'] != null) ...[
                  const SizedBox(height: 20),
                  Divider(
                    color: TColorss.textSecondary.withOpacity(0.3),
                    thickness: 1,
                    indent: 10,
                    endIndent: 10,
                  ),
                  const SizedBox(height: 16),
                  FadeIn(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      'Your Response:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: TColorss.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    request['response_message'],
                    style: const TextStyle(
                      fontSize: 15,
                      color: TColorss.textPrimary,
                      height: 1.6,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
                if (isPending) ...[
                  const SizedBox(height: 20),
                  Divider(
                    color: TColorss.textSecondary.withOpacity(0.3),
                    thickness: 1,
                    indent: 10,
                    endIndent: 10,
                  ),
                  const SizedBox(height: 16),
                  FadeIn(
                    duration: const Duration(milliseconds: 400),
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        labelText: 'Response Message',
                        hintText: 'Type your response here...',
                        hintStyle: TextStyle(
                          color: TColorss.textSecondary.withOpacity(0.5),
                          fontStyle: FontStyle.italic,
                        ),
                        filled: true,
                        fillColor: TColorss.surfaceSecondary.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: TColorss.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        prefixIcon: Icon(
                          Iconsax.message,
                          color: TColorss.textSecondary.withOpacity(0.6),
                          size: 20,
                        ),
                      ),
                      maxLines: 4,
                      style: const TextStyle(
                        fontSize: 15,
                        color: TColorss.textPrimary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ZoomIn(
                        duration: const Duration(milliseconds: 400),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles();
                            if (result != null) {
                              selectedFile.value = result.files.first;
                              selectedFileName.value = result.files.first.name;
                            }
                          },
                          icon: const Icon(Iconsax.document_upload, size: 22),
                          label: const Text('Attach File'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColorss.primary,
                            foregroundColor: TColorss.surface,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 3,
                            shadowColor: TColorss.textPrimary.withOpacity(0.2),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                      if (selectedFileName.value.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: ZoomIn(
                            duration: const Duration(milliseconds: 400),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: TColorss.surfaceSecondary.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: TColorss.textPrimary.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Iconsax.document,
                                    size: 20,
                                    color: TColorss.textPrimary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Selected: ${selectedFileName.value}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: TColorss.textPrimary,
                                        letterSpacing: 0.2,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Iconsax.trash,
                                      size: 20,
                                      color: TColorss.error,
                                    ),
                                    onPressed: () {
                                      selectedFile.value = null;
                                      selectedFileName.value = '';
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  )),
                  const SizedBox(height: 16),
                  ZoomIn(
                    duration: const Duration(milliseconds: 400),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (messageController.text.isEmpty) {
                            Get.snackbar(
                              'Error',
                              'Please enter a response message',
                              backgroundColor: TColorss.error,
                              colorText: TColorss.surface,
                              snackPosition: SnackPosition.BOTTOM,
                              borderRadius: 12,
                              margin: const EdgeInsets.all(16),
                              duration: const Duration(seconds: 4),
                              icon: const Icon(
                                Iconsax.warning_2,
                                color: TColorss.surface,
                              ),
                            );
                            return;
                          }
                          Get.find<HomeController>().replyToRequest(
                            request['id'].toString(),
                            messageController.text,
                            selectedFile.value,
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColorss.accent,
                          foregroundColor: TColorss.surface,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                          shadowColor: TColorss.textPrimary.withOpacity(0.2),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Iconsax.send_1, size: 20),
                            SizedBox(width: 8),
                            Text('Submit Response'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openAttachment(String url) {
    Get.snackbar('Info', 'Opening attachment: $url');
  }

  void _showAppealDialog(BuildContext context, String reportId) {
    final TextEditingController appealController = TextEditingController();
    final RxString selectedFileName = ''.obs;
    final Rx<PlatformFile?> selectedFile = Rx<PlatformFile?>(null);
    final RxInt charCount = 0.obs;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: TColorss.surface,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Appeal Report',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TColorss.textPrimary,
              ),
            ),
            IconButton(
              icon: Icon(Iconsax.close_circle, color: TColorss.textSecondary),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Explain why you believe this report should be reviewed (max 500 characters).',
                style: TextStyle(
                  fontSize: 14,
                  color: TColorss.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => TextField(
                controller: appealController,
                maxLines: 4,
                maxLength: 500,
                onChanged: (value) => charCount.value = value.length,
                decoration: InputDecoration(
                  hintText: 'Enter your appeal message',
                  hintStyle: TextStyle(color: TColorss.textSecondary),
                  filled: true,
                  fillColor: TColorss.surfaceSecondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: TColorss.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  counterText: '${charCount.value}/500',
                  counterStyle: TextStyle(
                    color: charCount.value > 500 ? TColorss.error : TColorss.textSecondary,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: TColorss.textPrimary,
                ),
                textInputAction: TextInputAction.done,
              )),
              const SizedBox(height: 16),
              ZoomIn(
                duration: const Duration(milliseconds: 400),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                        withData: true,
                      );
                      if (result != null && result.files.isNotEmpty) {
                        final file = result.files.first;
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
                          return;
                        }
                        final extension = file.name.split('.').last.toLowerCase();
                        if (!['pdf', 'jpg', 'jpeg', 'png'].contains(extension)) {
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
                          return;
                        }
                        selectedFile.value = file;
                        selectedFileName.value = file.name;
                      }
                    } catch (e) {
                      Get.snackbar(
                        'Error',
                        'Failed to select file: $e',
                        backgroundColor: TColorss.error,
                        colorText: TColorss.surface,
                        snackPosition: SnackPosition.BOTTOM,
                        borderRadius: 12,
                        margin: const EdgeInsets.all(16),
                        duration: const Duration(seconds: 4),
                        icon: const Icon(Iconsax.warning_2, color: TColorss.surface),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColorss.primary,
                    foregroundColor: TColorss.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 2,
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  icon: const Icon(Iconsax.document_upload, size: 20),
                  label: const Text('Select File'),
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedFileName.value.isEmpty
                          ? 'No file selected (optional)'
                          : 'Selected: ${selectedFileName.value}',
                      style: TextStyle(
                        fontSize: 14,
                        color: selectedFileName.value.isEmpty
                            ? TColorss.textSecondary
                            : TColorss.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (selectedFileName.value.isNotEmpty)
                    IconButton(
                      icon: Icon(Iconsax.trash, color: TColorss.error, size: 20),
                      onPressed: () {
                        selectedFile.value = null;
                        selectedFileName.value = '';
                      },
                    ),
                ],
              )),
            ],
          ),
        ),
        actions: [
          ZoomIn(
            duration: const Duration(milliseconds: 400),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14,
                  color: TColorss.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          ZoomIn(
            duration: const Duration(milliseconds: 400),
            child: Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () {
                if (appealController.text.trim().isEmpty) {
                  Get.snackbar(
                    'Error',
                    'Please enter an appeal message.',
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
                controller.appealReport(
                  reportId,
                  appealController.text.trim(),
                  selectedFile.value,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColorss.accent,
                foregroundColor: TColorss.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 2,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: controller.isLoading.value
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: TColorss.surface,
                  strokeWidth: 2,
                ),
              )
                  : const Text('Submit Appeal'),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: TColorss.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: color ?? TColorss.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return TColorss.textSecondary;

    final statusStr = status.toString().toUpperCase();
    switch (statusStr) {
      case 'PENDING':
        return TColorss.primary;
      case 'ACCEPTED':
        return Colors.blue;
      case 'CLOSED':
        return Colors.green;
      case 'INVALID_COMPLAINT':
        return TColorss.error;
      case 'ESCALATED':
        return Colors.orange;
      default:
        return TColorss.textSecondary;
    }
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      final date = DateTime.parse(dateTime);
      final now = DateTime.now();
      final difference = now.difference(date);
      if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      }
      return DateFormat('MMM d, yyyy • HH:mm').format(date);
    } catch (e) {
      return 'N/A';
    }
  }
}