import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../utils/constants/colors.dart';
import '../controllers/feedback_controller.dart';

class FeedbackView extends GetView<FeedbackController> {
  const FeedbackView({super.key});

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style to match LoginView
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: TColors.primary,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with gradient and logo
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.grey.withOpacity(0.9),
                          Colors.grey.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedScale(
                            scale: 1.0,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                            child: Image.asset(
                              'assets/logos/logo_2.png',
                              height: 160,
                              fit: BoxFit.contain,
                            ),
                          ),
                          AnimatedOpacity(
                            opacity: 1.0,
                            duration: const Duration(milliseconds: 600),
                            child: Text(
                              'Provide Your Feedback'.tr,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Form container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Branch Dropdown
                    AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 600),
                      child: Text(
                        'Select Branch'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => AnimatedSlide(
                      offset: const Offset(0, 0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                      child: DropdownButtonFormField<String>(
                        value: controller.selectedBranch.value.isEmpty
                            ? null
                            : controller.selectedBranch.value,
                        decoration: InputDecoration(
                          hintText: 'Choose branch'.tr,
                          prefixIcon: Icon(
                            Iconsax.location,
                            color: Colors.grey.shade600,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: TColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        items: controller.branches.map((branch) {
                          return DropdownMenuItem<String>(
                            value: branch,
                            child: Text(branch),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedBranch.value = value;
                            controller.selectedService.value = '';
                          }
                        },
                      ),
                    )),
                    const SizedBox(height: 20),

                    // Service Dropdown
                    AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 600),
                      child: Text(
                        'Select Service'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => AnimatedSlide(
                      offset: const Offset(0, 0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                      child: DropdownButtonFormField<String>(
                        value: controller.selectedService.value.isEmpty
                            ? null
                            : controller.selectedService.value,
                        decoration: InputDecoration(
                          hintText: 'Choose service'.tr,
                          prefixIcon: Icon(
                            Iconsax.task,
                            color: Colors.grey.shade600,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: TColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        items: controller
                            .getServicesForBranch(
                            controller.selectedBranch.value)
                            .map((service) {
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
                      ),
                    )),
                    const SizedBox(height: 20),

                    // Rating
                    // Rating
                    AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 600),
                      child: Text(
                        'Rate Service'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(() => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final isSelected = index < controller.rating.value;
                          return GestureDetector(
                            onTap: () {
                              controller.rating.value = index + 1;
                            },
                            child: AnimatedScale(
                              scale: isSelected ? 1.2 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(
                                  isSelected ? Icons.star : Icons.star_border,
                                  color: isSelected ? Colors.amber.shade700 : Colors.grey.shade400,
                                  size: 40,
                                  shadows: isSelected
                                      ? [
                                    BoxShadow(
                                      color: Colors.amber.withOpacity(0.4),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                      : null,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    )),
                    const SizedBox(height: 20),
                    // Description
                    AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 600),
                      child: Text(
                        'Description'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => AnimatedSlide(
                      offset: const Offset(0, 0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                      child: TextField(
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Write your feedback...'.tr,
                          prefixIcon: Icon(
                            Iconsax.message,
                            color: Colors.grey.shade600,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: TColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onChanged: (value) => controller.description.value = value,
                        controller: TextEditingController(
                          text: controller.description.value,
                        ),
                      ),
                    )),
                    const SizedBox(height: 30),

                    // Submit Button
                    AnimatedScale(
                      scale: 1.0,
                      duration: const Duration(milliseconds: 600),
                      child: SizedBox(
                        width: double.infinity,
                        child: Obx(() => ElevatedButton(
                          onPressed: controller.isSubmitting.value
                              ? null
                              : controller.submitFeedback,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            shadowColor: TColors.primary.withOpacity(0.4),
                            padding:
                            const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: controller.isSubmitting.value
                              ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                              : Text(
                            'Submit Feedback'.tr,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}