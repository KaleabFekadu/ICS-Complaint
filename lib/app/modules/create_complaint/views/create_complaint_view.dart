import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/create_complaint_controller.dart';
import 'package:intl/intl.dart';
import 'dart:io';

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

class CreateComplaintView extends GetView<CreateComplaintController> {
  const CreateComplaintView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CreateComplaintController());
    return Scaffold(
      backgroundColor: TColorss.background,
      appBar: AppBar(
        title: Obx(
              () => FadeInDown(
            duration: const Duration(milliseconds: 400),
            child: Text(
              'Create Complaint - ${controller.categoryName.value.isEmpty ? 'Category'.tr : controller.categoryName.value}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: TColorss.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: TColorss.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: TColorss.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Obx(
                () => controller.errorMessage.isNotEmpty
                ? FadeIn(
              duration: const Duration(milliseconds: 600),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: controller.errorMessage.value.contains('patience')
                        ? TColorss.accent.withOpacity(0.1)
                        : TColorss.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        controller.errorMessage.value.contains('patience')
                            ? Iconsax.warning_2
                            : Iconsax.close_circle,
                        color: controller.errorMessage.value.contains('patience')
                            ? TColorss.primary
                            : TColorss.error,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          controller.errorMessage.value,
                          style: TextStyle(
                            color: controller.errorMessage.value.contains('patience')
                                ? TColorss.primary
                                : TColorss.error,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
                : const SizedBox.shrink(),
          ),
          Obx(() => _buildWizardHeader(context)),
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Obx(() => FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      child: _buildForm(context),
                    )),
                    Obx(
                          () => controller.isTicketVerified.value
                          ? FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        child: _buildTicketInfoCard(),
                      )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWizardHeader(BuildContext context) {
    final stepTitles = ['Branch'.tr, 'Personal Info'.tr, 'Report Details'.tr, 'Attachment'.tr];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(4, (index) {
          return Expanded(
            child: FadeIn(
              duration: const Duration(milliseconds: 500),
              delay: Duration(milliseconds: 100 * index),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: controller.currentStep.value >= index
                                ? [TColorss.primary, TColorss.primary.withOpacity(0.8)]
                                : [TColorss.textSecondary.withOpacity(0.2), TColorss.textSecondary.withOpacity(0.2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: controller.currentStep.value >= index
                                  ? TColorss.surface
                                  : TColorss.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      if (index < 3)
                        Expanded(
                          child: Container(
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: controller.currentStep.value > index
                                  ? TColorss.primary
                                  : TColorss.textSecondary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stepTitles[index],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: controller.currentStep.value >= index
                          ? TColorss.textPrimary
                          : TColorss.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return [
      _buildStep1(),
      _buildStep2(),
      _buildStep3(),
      _buildStep4(context),
    ][controller.currentStep.value];
  }

  // In create_complaint_view.dart, replace _buildStep1() with this:

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Branch Information'.tr,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: TColorss.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select Branch'.tr,
          style: TextStyle(
            fontSize: 14,
            color: TColorss.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => DropdownButtonFormField<String>(
          value: controller.selectedBranch.value.isEmpty ? null : controller.selectedBranch.value,
          hint: Text(
            'Select a branch'.tr,
            style: TextStyle(color: TColorss.textSecondary),
          ),
          isExpanded: true,
          items: controller.branches.map((branch) {
            return DropdownMenuItem<String>(
              value: branch,
              child: Text(branch),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              controller.selectedBranch.value = value;
              controller.selectedService.value = ''; // Reset service when branch changes
            }
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: TColorss.surfaceSecondary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: TColorss.primary, width: 1.5),
            ),
            prefixIcon: Icon(
              Iconsax.location,
              color: TColorss.textSecondary,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a branch'.tr;
            }
            return null;
          },
        )),
        const SizedBox(height: 16),
        Text(
          'Select Service'.tr,
          style: TextStyle(
            fontSize: 14,
            color: TColorss.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => DropdownButtonFormField<String>(
          value: controller.selectedService.value.isEmpty ? null : controller.selectedService.value,
          hint: Text(
            'Select a service'.tr,
            style: TextStyle(color: TColorss.textSecondary),
          ),
          isExpanded: true,
          items: controller.getServicesForBranch(controller.selectedBranch.value).map((service) {
            return DropdownMenuItem<String>(
              value: service,
              child: Text(service),
            );
          }).toList(),
          onChanged: controller.selectedBranch.value.isEmpty
              ? null
              : (value) {
            if (value != null) {
              controller.selectedService.value = value;
            }
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: TColorss.surfaceSecondary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: TColorss.primary, width: 1.5),
            ),
            prefixIcon: Icon(
              Iconsax.task,
              color: TColorss.textSecondary,
            ),
            enabled: controller.selectedBranch.value.isNotEmpty,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a service'.tr;
            }
            return null;
          },
        )),
        const SizedBox(height: 24),
        Obx(
              () => controller.isLoading.value
              ? Center(
            child: CircularProgressIndicator(
              color: TColorss.primary,
              strokeWidth: 4,
              backgroundColor: TColorss.primary.withOpacity(0.2),
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ZoomIn(
                duration: const Duration(milliseconds: 400),
                child: ElevatedButton(
                  onPressed: controller.isTicketVerified.value ? controller.retryTicket : controller.verifyTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColorss.accent,
                    foregroundColor: TColorss.surface,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  child: Text(
                    controller.isTicketVerified.value ? 'Retry Selection'.tr : 'Fetch Branch Info'.tr,
                  ),
                ),
              ),
              if (controller.isTicketVerified.value)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ZoomIn(
                    duration: const Duration(milliseconds: 400),
                    child: ElevatedButton(
                      onPressed: controller.nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColorss.primary,
                        foregroundColor: TColorss.surface,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      child: Text('Next'.tr),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information'.tr,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: TColorss.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: controller.firstNameController,
          label: 'First Name'.tr,
          maxLength: 30,
          onChanged: (value) => controller.firstName.value = value,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: controller.lastNameController,
          label: 'Last Name'.tr,
          maxLength: 30,
          onChanged: (value) => controller.lastName.value = value,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: controller.surnameController,
          label: 'Surname'.tr,
          maxLength: 30,
          onChanged: (value) => controller.surname.value = value,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ZoomIn(
              duration: const Duration(milliseconds: 400),
              child: ElevatedButton(
                onPressed: controller.previousStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColorss.textSecondary,
                  foregroundColor: TColorss.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 2,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text('Previous'.tr),
              ),
            ),
            ZoomIn(
              duration: const Duration(milliseconds: 400),
              child: ElevatedButton(
                onPressed: controller.nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColorss.primary,
                  foregroundColor: TColorss.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 2,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text('Next'.tr),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3() {
    final _formKey = GlobalKey<FormState>();
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report Details'.tr,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: TColorss.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: controller.descriptionController,
            label: 'Details *'.tr,
            maxLength: 500,
            maxLines: 5,
            onChanged: (value) => controller.detail.value = value,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ZoomIn(
                duration: const Duration(milliseconds: 400),
                child: ElevatedButton(
                  onPressed: controller.previousStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColorss.textSecondary,
                    foregroundColor: TColorss.surface,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 2,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text('Previous'.tr),
                ),
              ),
              ZoomIn(
                duration: const Duration(milliseconds: 400),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      controller.nextStep();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColorss.primary,
                    foregroundColor: TColorss.surface,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 2,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text('Next'.tr),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep4(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   'Attachements'.tr,
        //   style: TextStyle(
        //     fontSize: 20,
        //     fontWeight: FontWeight.bold,
        //     color: TColorss.textPrimary,
        //   ),
        // ),
        // const SizedBox(height: 16),
        Text(
          'Do you want to upload attachments?'.tr,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: TColorss.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
              () => Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: controller.hasDocument.value,
                onChanged: (value) => controller.hasDocument.value = value!,
                activeColor: TColorss.primary,
              ),
              Text(
                'Yes'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: TColorss.textPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Radio<bool>(
                value: false,
                groupValue: controller.hasDocument.value,
                onChanged: (value) => controller.hasDocument.value = value!,
                activeColor: TColorss.primary,
              ),
              Text(
                'No'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: TColorss.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Obx(
              () => Visibility(
            visible: controller.hasDocument.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Obx(() {
                  final tabIndex = controller.selectedTab.value;
                  final tabContent = controller.tabs[tabIndex];
                  return Column(
                    children: [
                      _buildTabBar(controller),
                      const SizedBox(height: 20),
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        child: _buildUploadContainer(tabContent),
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                }),
                if (controller.files.isNotEmpty || controller.links.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _buildMediaCard(),
                  ),
                const SizedBox(height: 16),
                Text(
                  '• Maximum 5 files\n• Accepted formats: jpeg, png, mp4, mp3, wav, pdf, doc, docx\n• Maximum size: 500MB'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    color: TColorss.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Obx(
              () => controller.isLoading.value
              ? Center(
            child: CircularProgressIndicator(
              color: TColorss.primary,
              strokeWidth: 4,
              backgroundColor: TColorss.primary.withOpacity(0.2),
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ZoomIn(
                duration: const Duration(milliseconds: 400),
                child: ElevatedButton(
                  onPressed: controller.previousStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColorss.textSecondary,
                    foregroundColor: TColorss.surface,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 2,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text('Previous'.tr),
                ),
              ),
              ZoomIn(
                duration: const Duration(milliseconds: 400),
                child: ElevatedButton(
                  onPressed: controller.submitComplaint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColorss.primary,
                    foregroundColor: TColorss.surface,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 2,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text('Submit'.tr),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(CreateComplaintController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: TColorss.surfaceSecondary,
      child: Row(
        children: List.generate(controller.tabs.length, (index) {
          final tab = controller.tabs[index];
          final isSelected = controller.selectedTab.value == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.selectedTab.value = index,
              child: Container(
                // Remove SlideInDown widget or ensure it's not causing key conflicts
                key: ValueKey('tab_$index'), // Add unique key for each tab
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? TColorss.primary : TColorss.surface,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: TColorss.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tab.icon,
                      color: isSelected ? TColorss.surface : TColorss.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tab.uploadTitle.split(' ')[0],
                      style: TextStyle(
                        color: isSelected ? TColorss.surface : TColorss.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildUploadContainer(UploadTab tabContent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColorss.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: TColorss.textPrimary.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            tabContent.uploadTitle,
            style: TextStyle(
              color: TColorss.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Replace the existing Row widget with this conditional widget
          if (tabContent.uploadTitle == 'Audio Upload')
            Obx(() {
              if (controller.isRecording.value) {
                return Column(
                  children: [
                    Text(
                      'Recording: ${controller.formatDuration(controller.recordingDuration.value)}',
                      style: TextStyle(
                        color: TColorss.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: controller.stopRecording,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColorss.error,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Stop Recording'.tr),
                    ),
                  ],
                );
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: List.generate(tabContent.actions.length, (actionIndex) {
                    final action = tabContent.actions[actionIndex];
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: OutlinedButton.icon(
                          onPressed: () {
                            if (action.label == 'Start Recording'.tr) {
                              controller.startRecording();
                            } else {
                              controller.pickFiles(controller.selectedTab.value);
                            }
                          },
                          icon: Icon(
                            action.icon,
                            color: TColorss.primary,
                            size: 20,
                          ),
                          label: Text(
                            action.label,
                            style: TextStyle(
                              color: TColorss.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            side: BorderSide(color: TColorss.primary.withOpacity(0.5)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              }
            })
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: List.generate(tabContent.actions.length, (actionIndex) {
                final action = tabContent.actions[actionIndex];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        if (action.label == 'Take Photo' || action.label == 'Take Video') {
                          controller.captureMedia(action.label);
                        } else {
                          controller.pickFiles(controller.selectedTab.value);
                        }
                      },
                      icon: Icon(
                        action.icon,
                        color: TColorss.primary,
                        size: 20,
                      ),
                      label: Text(
                        action.label,
                        style: TextStyle(
                          color: TColorss.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        side: BorderSide(color: TColorss.primary.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: TColorss.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uploaded Media & Links'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: TColorss.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => Column(
              children: [
                ...controller.files.map((file) {
                  final isImage = ['jpg', 'jpeg', 'png'].contains(file.extension?.toLowerCase());
                  final isVideo = ['mp4', 'mov', 'avi'].contains(file.extension?.toLowerCase());
                  final isAudio = ['mp3', 'wav', 'm4a', 'aac'].contains(file.extension?.toLowerCase());
                  final isDocument = ['pdf', 'doc', 'docx', 'txt'].contains(file.extension?.toLowerCase());

                  if (isAudio) {
                    return ListTile(
                      leading: Icon(
                        Iconsax.sound,
                        color: TColorss.textSecondary,
                      ),
                      title: Text(
                        file.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: TColorss.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // IconButton(
                          //   icon: Icon(
                          //     Icons.play_arrow,
                          //     color: TColorss.primary,
                          //   ),
                          //   onPressed: () => controller.playRecording(file.path!),
                          // ),
                          // IconButton(
                          //   icon: Icon(
                          //     Icons.stop,
                          //     color: TColorss.textSecondary,
                          //   ),
                          //   onPressed: controller.stopPlayback,
                          // ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: TColorss.error,
                            ),
                            onPressed: () {
                              controller.files.remove(file);
                              controller.files.refresh();
                            },
                          ),
                        ],
                      ),
                    );
                  }

                  return ListTile(
                    leading: isImage
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(file.path!),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    )
                        : Icon(
                      isVideo ? Iconsax.video :
                      isDocument ? Iconsax.document : Iconsax.note,
                      color: TColorss.textSecondary,
                    ),
                    title: Text(
                      file.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: TColorss.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: TColorss.error),
                      onPressed: () {
                        controller.files.remove(file);
                        controller.files.refresh();
                      },
                    ),
                  );
                }).toList(),
                if (controller.files.isEmpty && controller.links.isEmpty)
                  Text(
                    'No files or links added yet'.tr,
                    style: TextStyle(
                      color: TColorss.textSecondary,
                      fontSize: 14,
                    ),
                  ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'monospace',
                color: Colors.blue[800],
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required int maxLength,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintStyle: TextStyle(color: TColorss.textSecondary.withOpacity(0.7)),
        labelStyle: TextStyle(color: TColorss.textSecondary),
        floatingLabelStyle: TextStyle(color: TColorss.primary),
        filled: true,
        fillColor: TColorss.surfaceSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: TColorss.primary, width: 1.5),
        ),
        counterStyle: TextStyle(color: TColorss.textSecondary),
        counterText: '${controller.text.length}/$maxLength',
        prefixIcon: Icon(
          label.contains('Ticket') ? Iconsax.ticket : Iconsax.note,
          color: TColorss.textSecondary,
        ),
      ),
      style: TextStyle(color: TColorss.textPrimary),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }


  Widget _buildTicketInfoCard() {
    return Card(
      margin: const EdgeInsets.only(top: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: TColorss.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Branch Information'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: TColorss.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildTicketInfoRow('Ticket Number'.tr, controller.ticketInfo['ticketNumber'] ?? ''),
              _buildTicketInfoRow('Company Name'.tr, controller.ticketInfo['companyName'] ?? ''),
              _buildTicketInfoRow('Room Name'.tr, controller.ticketInfo['roomName'] ?? ''),
              _buildTicketInfoRow('Staff Name'.tr, controller.ticketInfo['staffName'] ?? ''),
              //_buildTicketInfoRow('Ticket Created At'.tr, controller.ticketInfo['ticketCreatedAt'] ?? ''),
              //_buildTicketInfoRow('Called At'.tr, controller.ticketInfo['calledAt'] ?? ''),
              //_buildTicketInfoRow('Served Date'.tr, controller.ticketInfo['servedDate'] ?? 'Not Served'),
              //_buildTicketInfoRow('Served'.tr, controller.ticketInfo['served']?.toString() ?? 'Not Served'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: TColorss.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: TColorss.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}