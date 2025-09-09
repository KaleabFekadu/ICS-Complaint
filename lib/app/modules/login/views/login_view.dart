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
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    LoginController controller = Get.put(LoginController());
    // 🟦 Set status bar to blue with white icons
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
              // 🔷 Header with background image, gradient overlay, and logo
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 280,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: const AssetImage('assets/logos/Head.png'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.red.withOpacity(0.3), // Apply red tint to the image
                          BlendMode.multiply, // Blend mode to enhance red vibe
                        ),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.red.withOpacity(0.9), // Subtle red at the top
                          Colors.redAccent.withOpacity(0.5), // Vibrant red at the bottom
                        ],
                      ),
                    ),
                  ),
                  // Removed the second Container with color overlay to avoid masking the gradient
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
                              'assets/logos/ccilogomain.png',
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
                    // Title with animation
                    AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 600),
                      child: const Text(
                        'Sign in to your\nAccount',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 📧 Email Field
                    // 📧 Email Field
                    AnimatedSlide(
                      offset: const Offset(0, 0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                      child: Obx(() => TextField(
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          prefixIcon: Icon(
                            Iconsax.sms,
                            color: Colors.grey.shade600,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
                          errorText: controller.emailError.value.isNotEmpty
                              ? controller.emailError.value
                              : null,
                        ),
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
                          hintText: 'Password',
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
                          errorText: controller.passwordError.value.isNotEmpty
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
                        const Text(
                          'Remember me',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Get.to(ForgetView());
                          },
                          child: Text(
                            'Forgot Password?',
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
                    // 🔵 Log In Button
                    AnimatedScale(
                      scale: 1.0,
                      duration: const Duration(milliseconds: 600),
                      child: SizedBox(
                        width: double.infinity,
                        child: Obx(() => ElevatedButton(
                          onPressed: controller.isLoginLoading.value ? null : controller.login, // Use isLoginLoading
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            shadowColor: TColors.primary.withOpacity(0.4),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: controller.isLoginLoading.value // Use isLoginLoading
                              ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                              : const Text(
                            'Log In',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        )),
                      ),
                    ),
                    const SizedBox(height: 10),

                    AnimatedScale(
                      scale: 1.0,
                      duration: const Duration(milliseconds: 600),
                      child: SizedBox(
                        width: double.infinity,
                        child: Obx(() => OutlinedButton(
                          onPressed: controller.isSignupLoading.value ? null : controller.signup, // Use isSignupLoading
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: TColors.primary,
                            side: BorderSide(color: TColors.primary, width: 1.8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: controller.isSignupLoading.value // Use isSignupLoading
                              ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: TColors.primary,
                            ),
                          )
                              : const Text(
                            'Sign Up',
                            style: TextStyle(
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
                          text: 'By signing up, you agree to the ',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                            height: 1.3,
                          ),
                          children: [
                            TextSpan(
                              text: 'Terms of Service',
                              style: const TextStyle(
                                color: TColors.primary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  showCustomDialog(
                                    context,
                                    'Terms of Service',
                                    _termsOfServiceText,
                                  );
                                },
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Data Processing Agreement',
                              style: const TextStyle(
                                color: TColors.primary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  showCustomDialog(
                                    context,
                                    'Data Processing Agreement',
                                    _dataProcessingText,
                                  );
                                },
                            ),
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
              // Title with close button
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
              // Scrollable content
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
              // Action buttons
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
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: TColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: TColors.primary,
                        ),
                      ),
                      onPressed: () {
                        // Add secondary action here
                      },
                      child: const Text(
                        'Learn More',
                        style: TextStyle(color: TColors.primary),
                      ),
                    ),
                  ),
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
  **CRRSA የሲቪል ምዝገባ እና የነዋሪነት አገልግሎት ኤጀንሲ | Civil Registration and Residency Service Agency**

  **የአገልግሎት ውል**

  ይህ የአገልግሎት ውል የCRRSA የሲቪል ምዝገባ እና የነዋሪነት አገልግሎት ኤጀንሲ መተግበሪያን ሲጠቀሙ የሚከተሉትን ህጎችና መመሪያዎች እንዲከተሉ ያሳስባል። በመተግበሪያው መጠቀም ላይ በመቀመጥዎ ይህንን ውል በሙሉ ተቀብላችሁ መኖሩን ይረዳል።

  1. **የመጠቀሚያ ፈቃድ**
  መተግበሪያውን ለህጋዊና አገልግሎት ዓላማ ብቻ መጠቀም የተፈቀደልዎ ነው። ይህ ፈቃድ የተወሰነ፣ ያልተለዋዋጭ፣ የማይዋረድ እና የማይተላለፍ ነው።

  2. **የተጠቃሚ ኃላፊነቶች**
  • መተግበሪያውን ለህጋዊና አንደበት ያለው አግባብ ብቻ መጠቀም እንዳለቦት ይስማማሉ።  
  • የመግቢያ መለያዎን በመጠበቅ ላይ ኃላፊነት አለብዎት።  
  • መተግበሪያውን ያልተፈቀደ መግባት፣ መቀየር ወይም መጥፋት ከሕጋዊ እርምጃ ጋር ሊያጋጥም ይችላል።

  3. **የውሂብ ትክክለኛነት**
  በመተግበሪያው ውስጥ የሚሰጡ መረጃዎች ትክክለኛነትና ቅርብነት እንዲኖራቸው መንገድ ማድረግ የተጠቃሚው ኃላፊነት ነው።

  4. **የንብረት መብት**
  በመተግበሪያው የተጠቀመ የንብረት መብት ሁሉ የCRRSA ናቸው። ያልተፈቀደ መተግበርና ቅዳሜ እንደ ተከለከለ እንዲቆጠር ይሆናል።

  5. **የደህንነት መንገዶች**
  ሲስተሙ በከፍተኛ የደህንነት መንገዶች ተጠባባቂ ነው። የሲስተሙን ደህንነት ማፍረስ፣ መዝለል ወይም መንቀል በአንደኛው ጊዜ እንዲቋረጥና የምርመራ ሂደት እንዲጀምር ይደርሳል።

  6. **ለውጦችና ማቋረጥ**
  CRRSA መተግበሪያውን በማሻሻል፣ በማቋረጥ ወይም በማዘጋጀት የተወሰነ መብት አለው።

  7. **የሕግ መመሪያ**
  ይህ ውል በኢትዮጵያ ፌዴራል ዲሞክራሲያዊ ሪፐብሊክ የተወሰነውን ሕግ እና መመሪያዎች መሠረት ተመስርቷል።

  ከዚህ ውሉ ጋር የማተኮራችሁ ካልተስማሙ፣ መተግበሪያውን እባክዎ አትጠቀሙ።
  ''';

  static const String _dataProcessingText = '''
  **CRRSA የሲቪል ምዝገባ እና የነዋሪነት አገልግሎት ኤጀንሲ | Civil Registration and Residency Service Agency**

  **የውሂብ ማቀናበሪያ ስምምነት**

  ይህ ስምምነት CRRSA በመተግበሪያው ውስጥ የሚሰበሰቡና የሚቀመጡ የግልና የድርጅት መረጃዎች እንዴት እንደሚተካከሉ እና እንዴት እንደሚጠበቁ ይገልጻል።

  1. **የሚሰበሰቡ ውሂብ**
  • የተጠቃሚ መረጃ (ሙሉ ስም፣ የስራ ሁኔታ፣ የክፍል መለያ)  
  • የመግቢያ መለያና አዲት መመዝገቢያዎች  
  • የመዝገብ መረጃዎች እና ቅሬታ መረጃዎች  
  • የመተግበሪያ መዳረሻ መረጃ (IP, ሰአት)

  2. **የውሂብ ማቀናበሪያ ዓላማ**
  • ተጠቃሚዎችን ለማረጋገጥ  
  • የመዝገብ እና የሲቪል ምዝገባ ሂደቶችን ለማቀናበር  
  • የውሂብ አጠቃቀምን ለትርፍና ደህንነት ለማረጋገጥ  
  • ውሂብን በውስጣዊ አሰራር ለማስተዳደር

  3. **ውሂብ ማጋራት**
  መረጃዎች በመንግስት ውስጥ በተፈቀደ ክፍሎች ብቻ ይጋራሉ። ለሶስተኛ ወገን ያልተፈቀደ መላክ አይፈቀድም።

  4. **የውሂብ መቆያ**
  ውሂብ እንደ አገሪቱ የማስታወሻና መዝገብ ፖሊሲዎች ይቆያል። የተለያዩ መረጃዎች በአስተዳደር ደንቦች መሠረት ይጠበቃሉ።

  5. **የእርስዎ መብቶች**
  • የግል መረጃዎትን ማየትና ትክክለኛነቱን ማረጋገጥ ይችላሉ።  
  • በስሌት የተመዘገበ መረጃ ማስተካከያ ማመንጨት ይችላሉ።  
  • የመረጃ ተግባራትን ወይም ግንኙነትን ማሳወቅ ይችላሉ።

  6. **የደህንነት መንገዶች**
  መረጃዎች በኢንክሪፕሽን መንገዶችና በበለፀገ መከላከያ ሲሰበሰቡ እንደሚጠበቁ ነው።

  ይህን መተግበሪያ በመጠቀምዎ የCRRSA የውሂብ ማቀናበሪያ መመሪያዎችን እንዳረጋገጡ ይቆጠራል።
  ''';
}