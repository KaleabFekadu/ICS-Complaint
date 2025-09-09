import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../utils/constants/colors.dart';
import '../controllers/splash_controller.dart';

class SplashView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final SplashController controller = Get.put(SplashController());
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background image
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 260, bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logos/logo_2.png',
                    width:390,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 20),
                  Spacer(),
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 2),
                      Text(
                        'Developed by Ethiopian Artificial Intelligence Institute',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '© ${DateTime.now().year} Immigration and Citizenship Service - ETHIOPIA. All rights reserved.',
                        style: TextStyle(
                          fontSize: 8,
                          color: TColors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
