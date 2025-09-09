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
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/logos/mainBackground.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Container(
          //   color: TColors.primary.withOpacity(0.45),
          // ),

          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 260, bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logos/ccilogomain.png',
                    width:390,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 20),
                  // Text(
                  //   'Biiroo Abbaa Alangaa W.O.',
                  //   style: TextStyle(
                  //     fontSize: 24,
                  //     fontWeight: FontWeight.bold,
                  //     color: TColors.white,
                  //   ),
                  // ),
                  // Text(
                  //   'የኦሮሚያ ጠቅላይ ዐቃቤ ሕግ ቢሮ',
                  //   style: TextStyle(
                  //     fontFamily: 'NokiaPureheadline',
                  //     fontSize: 28,
                  //     fontWeight: FontWeight.w600,
                  //     color: TColors.white,
                  //   ),
                  // ),
                  Spacer(),
                  Lottie.asset(
                    'assets/Searching.json', // your Lottie JSON file
                    height: 90,
                    width: 90,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'CRRSA የሲቪል ምዝገባ እና የነዋሪነት አገልግሎት ኤጀንሲ',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Developed by Ethiopian Artificial Intelligence Institute',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '© ${DateTime.now().year} CRRSA የሲቪል ምዝገባ እና የነዋሪነት አገልግሎት ኤጀንሲ. All rights reserved.',
                        style: TextStyle(
                          fontSize: 8,
                          color: TColors.secondary,
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
