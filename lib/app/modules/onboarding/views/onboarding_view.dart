import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/constants/colors.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// --- PageView with Parallax Background ---
          PageView.builder(
            controller: controller.pageController,
            onPageChanged: controller.onPageChanged,
            itemCount: controller.onboardingPages.length,
            itemBuilder: (context, index) {
              final page = controller.onboardingPages[index];
              return Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: Image.asset(
                      page.imageAsset,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  // Gradient overlay for better readability
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Text content
                  Positioned(
                    bottom: 120,
                    left: 24,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() {
                          final isActive = controller.currentPage.value == index;
                          return AnimatedOpacity(
                            opacity: isActive ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 500),
                            child: Text(
                              page.title,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: TColors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10,
                                    color: Colors.black.withOpacity(0.7),
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                        Obx(() {
                          final isActive = controller.currentPage.value == index;
                          return AnimatedOpacity(
                            opacity: isActive ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 700),
                            child: Text(
                              page.subtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.4,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          /// --- Skip Button ---
          Positioned(
            top: 60,
            right: 10,
            child: Obx(() => AnimatedOpacity(
              opacity: controller.currentPage.value <
                  controller.onboardingPages.length - 1
                  ? 1.0
                  : 0.0,
              duration: const Duration(milliseconds: 500),
              child: OutlinedButton(
                onPressed: controller.completeOnboarding,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.6)),
                  shape: StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                ),
                child: const Text(
                  "Skip",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )),
          ),

          /// --- Bottom Controls: Indicators + Next/Done ---
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Page Indicators
                Obx(() => Row(
                  children: List.generate(
                    controller.onboardingPages.length,
                        (dotIndex) {
                      final isActive =
                          controller.currentPage.value == dotIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        height: 6,
                        width: isActive ? 48 : 15,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isActive
                              ? TColors.secondary
                              : Colors.white.withOpacity(1),
                          boxShadow: isActive
                              ? [
                            BoxShadow(
                              color: TColors.primary.withOpacity(0.5),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            )
                          ]
                              : [],
                        ),
                      );
                    },
                  ),
                )),

                /// Next / Done Button
                Obx(() => FloatingActionButton(
                  onPressed: () {
                    if (controller.isLastPage.value) {
                      controller.completeOnboarding();
                    } else {
                      controller.pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  backgroundColor: TColors.primary,
                  child: Icon(
                    controller.isLastPage.value
                        ? Icons.check
                        : Icons.arrow_forward,
                    color: Colors.white,
                    size: 26,
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
