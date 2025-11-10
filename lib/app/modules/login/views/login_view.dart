import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../utils/constants/colors.dart';
import '../../forget/views/forget_view.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  final LoginController controller = Get.put(LoginController());
  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // Move Get.put to a higher scope or ensure it's only called once
    // If using GetView, the controller is already managed by Get
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
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 280,
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
                              height: 280,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // ⚪ Form container with subtle shadow and rounded top
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                    AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 600),
                      child: Text(
                        'Sign in to your\nAccount'.tr,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 📱 Phone Number Field
                    AnimatedSlide(
                      offset: const Offset(0, 0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                      child: Obx(() => TextField(
                            controller: controller.phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: 'Phone Number'.tr,
                              prefixIcon: Icon(
                                Iconsax.call,
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
                              errorText: controller.phoneError.value.isNotEmpty
                                  ? controller.phoneError.value
                                  : null,
                            ),
                            onChanged: (value) =>
                                controller.validatePhoneNumber(),
                          )),
                    ),
                    const SizedBox(height: 16),

                    // 🔒 Password Field
                    AnimatedSlide(
                      offset: const Offset(0, 0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                      child: Obx(() => TextField(
                            controller: controller.passwordController,
                            obscureText: controller.isPasswordHidden.value,
                            decoration: InputDecoration(
                              hintText: 'Password'.tr,
                              prefixIcon: Icon(
                                Iconsax.lock,
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
                              errorText:
                                  controller.passwordError.value.isNotEmpty
                                      ? controller.passwordError.value
                                      : null,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.isPasswordHidden.value
                                      ? Iconsax.eye_slash
                                      : Iconsax.eye,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: controller.togglePasswordVisibility,
                              ),
                            ),
                          )),
                    ),
                    const SizedBox(height: 20),

                    // 🔘 Remember me & Forgot Password
                    Row(
                      children: [
                        Obx(() => Checkbox(
                              value: controller.rememberMe.value,
                              onChanged: (value) =>
                                  controller.rememberMe.value = value ?? false,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              activeColor: TColors.primary,
                            )),
                        Text(
                          'Remember me'.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Get.to(const ForgetView());
                          },
                          child: Text(
                            'Forgot Password?'.tr,
                            style: TextStyle(
                              color: TColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // 🔵 Log In Button
                    AnimatedScale(
                      scale: 1.0,
                      duration: const Duration(milliseconds: 600),
                      child: SizedBox(
                        width: double.infinity,
                        child: Obx(() => ElevatedButton(
                              onPressed: controller.isLoginLoading.value
                                  ? null
                                  : controller.login,
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
                              child: controller.isLoginLoading.value
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      'Log In'.tr,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                            )),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 🔵 Sign Up Button
                    AnimatedScale(
                      scale: 1.0,
                      duration: const Duration(milliseconds: 600),
                      child: SizedBox(
                        width: double.infinity,
                        child: Obx(() => OutlinedButton(
                              onPressed: controller.isSignupLoading.value
                                  ? null
                                  : controller.signup,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: TColors.primary,
                                side: BorderSide(
                                    color: TColors.primary, width: 1.8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: controller.isSignupLoading.value
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: TColors.primary,
                                      ),
                                    )
                                  : Text(
                                      'Sign Up'.tr,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                            )),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 📄 Terms
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'By signing up, you agree to the '.tr,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                            height: 1.3,
                          ),
                          children: [
                            TextSpan(
                              text: 'Terms of Service'.tr,
                              style: const TextStyle(
                                color: TColors.primary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  showCustomDialog(
                                    context,
                                    'Terms of Service'.tr,
                                    _termsOfServiceText,
                                  );
                                },
                            ),
                            // TextSpan(text: ' and '.tr),
                            // TextSpan(
                            //   text: 'Data Processing Agreement'.tr,
                            //   style: const TextStyle(
                            //     color: TColors.primary,
                            //     fontWeight: FontWeight.w600,
                            //     decoration: TextDecoration.underline,
                            //   ),
                            //   recognizer: TapGestureRecognizer()
                            //     ..onTap = () {
                            //       showCustomDialog(
                            //         context,
                            //         'Data Processing Agreement'.tr,
                            //         _dataProcessingText,
                            //       );
                            //     },
                            // ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDialog(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: 400,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: TColors.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: MarkdownBody(
                      data: content,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                        h1: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TColors.primary,
                        ),
                        h2: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        listBullet: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        code: const TextStyle(
                          fontFamily: 'Courier',
                          backgroundColor: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Close'.tr),
                    ),
                  ),
                  // const SizedBox(width: 12),
                  // Expanded(
                  //   child: OutlinedButton(
                  //     style: OutlinedButton.styleFrom(
                  //       side: const BorderSide(color: TColors.primary),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(10),
                  //       ),
                  //       padding: const EdgeInsets.symmetric(vertical: 14),
                  //       textStyle: const TextStyle(
                  //         fontSize: 16,
                  //         fontWeight: FontWeight.w600,
                  //         color: TColors.primary,
                  //       ),
                  //     ),
                  //     onPressed: () {
                  //       // Add secondary action here
                  //     },
                  //     child: Text(
                  //       'Learn More'.tr,
                  //       style: const TextStyle(color: TColors.primary),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showCustomDialog(BuildContext context, String title, String content) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return _buildCustomDialog(context, title: title, content: content);
      },
    );
  }

  static const String _termsOfServiceText = '''
  1. **Introduction**
  These Terms & Conditions (“Terms”) govern your use of the Complaints Mobile 
  Application (“ICSResolve”), provided by Immigration and Citizenship Service. By 
  downloading, accessing, or using this App, you agree to be bound by these 
  Terms. If you disagree, do not use the App.
  2. **Purpose of the App**
  The App allows users to submit complaints, track status, and communicate with 
  customer service. The App may not be used for illegal, abusive, or fraudulent 
  activities.
  3. **User Eligibility**
  You must be at least 18 years old, provide accurate information, and be the 
  rightful owner of the device. False or fraudulent reporting is prohibited.
  4. **Account Registration**
  You may be required to register an account and verify identification. You are 
  responsible for the confidentiality of your credentials.
  5. **Submission of Complaints**
  You agree to provide truthful information and avoid abusive, defamatory, or 
  illegal content. We may reject or investigate complaints and, if necessary, forward 
  them to the authorities.
  6. **Data Collection & Privacy**
  We may collect personal details, including ID, contact information, and uploaded 
  documents. Data handling follows Data Protection Laws and our Privacy Policy.
  7. **Confidentiality of Complaints**
  We maintain confidentiality but may share information with relevant government 
  departments or law enforcement if required.
  8. **Misuse of the App**
  You are prohibited from submitting fake or malicious complaints, hacking, 
  uploading harmful files, or using the platform for unauthorized purposes.
  9. **App Availability**
  We strive for continuous service, but do not guarantee uninterrupted access. We 
  are not responsible for outages or technical issues.
  10. **Intellectual Property**
  All content and software are the property of the immigration and Citizenship 
  Service and protected by law.
  11. **Limitation of Liability**
  We are not liable for user errors, device malfunctions, or false information 
  submitted by users.
  12. **Termination**
  We may suspend or terminate access in cases of misuse or security compromise. 
  Users may delete the app to discontinue use.
  13. **Changes to Terms**
  We may update Terms at any time, and continued use constitutes acceptance.
  14. **Governing Law**
  These Terms are governed by the laws of Ethiopia. Disputes follow national legal 
  procedures.
  15. **Contact Information**
  Email: support@compliant.digitalics.gov.et
  Hotline:8133
  Website:-www.ics.gov.et 
  ''';

  static const String _dataProcessingText = '''
  ** Terms & Conditions – ICS Resolve Mobile App for Immigration and Citizenship Service **
  1. **Introduction**
  These Terms & Conditions (“Terms”) govern your use of the Complaints Mobile 
  Application (“ICSResolve”), provided by Immigration and Citizenship Service. By 
  downloading, accessing, or using this App, you agree to be bound by these 
  Terms. If you disagree, do not use the App.
  2. **Purpose of the App**
  The App allows users to submit complaints, track status, and communicate with 
  customer service. The App may not be used for illegal, abusive, or fraudulent 
  activities.
  3. **User Eligibility**
  You must be at least 18 years old, provide accurate information, and be the 
  rightful owner of the device. False or fraudulent reporting is prohibited.
  4. **Account Registration**
  You may be required to register an account and verify identification. You are 
  responsible for the confidentiality of your credentials.
  5. **Submission of Complaints**
  You agree to provide truthful information and avoid abusive, defamatory, or 
  illegal content. We may reject or investigate complaints and, if necessary, forward 
  them to the authorities.
  6. **Data Collection & Privacy**
  We may collect personal details, including ID, contact information, and uploaded 
  documents. Data handling follows Data Protection Laws and our Privacy Policy.
  7. **Confidentiality of Complaints**
  We maintain confidentiality but may share information with relevant government 
  departments or law enforcement if required.
  8. **Misuse of the App**
  You are prohibited from submitting fake or malicious complaints, hacking, 
  uploading harmful files, or using the platform for unauthorized purposes.
  9. **App Availability**
  We strive for continuous service, but do not guarantee uninterrupted access. We 
  are not responsible for outages or technical issues.
  10. **Intellectual Property**
  All content and software are the property of the immigration and Citizenship 
  Service and protected by law.
  11. **Limitation of Liability**
  We are not liable for user errors, device malfunctions, or false information 
  submitted by users.
  12. **Termination**
  We may suspend or terminate access in cases of misuse or security compromise. 
  Users may delete the app to discontinue use.
  13. **Changes to Terms**
  We may update Terms at any time, and continued use constitutes acceptance.
  14. **Governing Law**
  These Terms are governed by the laws of Ethiopia. Disputes follow national legal 
  procedures.
  15. **Contact Information**
  Email: support@compliant.digitalics.gov.et
  Hotline:8133
  Website:-www.ics.gov.et 
  ''';
}
