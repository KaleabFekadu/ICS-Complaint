import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../controllers/language_controller.dart';
import 'package:iconsax/iconsax.dart';

class LanguageView extends GetView<LanguageController> {
  const LanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedLanguage = controller.selectedLanguage.value;

      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header Section
                    Column(
                      children: [
                        // Circular image with a modern border
                        Container(
                            child: Image.asset(
                              'assets/logos/logo_2.png',
                              height: 160,
                              width: 160,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(height: 26),
                        Text(
                          'Choose Your Language',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            letterSpacing: 0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 0),
                        Text(
                          'Select a language spoken in Ethiopia',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Language List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.languages.length,
                      itemBuilder: (context, index) {
                        final language = controller.languages[index];
                        final isSelected = selectedLanguage == language;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GestureDetector(
                            onTap: () => controller.setLanguage(language),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              transform: Matrix4.identity()
                                ..scale(isSelected ? 1.02 : 1.0), // Subtle scale effect
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(isSelected ? 0.05 : 0.1),
                                    blurRadius: isSelected ? 16 : 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: isSelected ? TColors.primary : Colors.grey[100]!,
                                  width: isSelected ? 1 : 0.1,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Icon(
                                    Iconsax.global,
                                    color: isSelected ? TColors.primary : Colors.grey,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      language,
                                      style: TextStyle(
                                        fontSize: isSelected ? 16 : 15,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                        color: isSelected ? TColors.primary : Colors.grey,
                                      ),
                                    ),
                                  ),
                                  AnimatedOpacity(
                                    opacity: isSelected ? 1.0 : 0.0,
                                    duration: Duration(milliseconds: 200),
                                    child: Icon(
                                      Icons.check_circle,
                                      color: isSelected ? TColors.primary : Colors.grey,
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // Continue Button
                    GestureDetector(
                      onTap: () {
                        controller.completeLanguageSelection();
                        Get.offNamed('/login');
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              TColors.primary,
                              TColors.primary.withOpacity(0.85),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: TColors.primary.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              controller.completeLanguageSelection();
                              Get.offNamed('/login');
                            },
                            splashColor: Colors.white.withOpacity(0.3),
                            highlightColor: Colors.transparent,
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Continue',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 28),
                                  const Icon(
                                    Iconsax.arrow_right_3,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}