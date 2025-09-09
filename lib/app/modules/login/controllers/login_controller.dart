import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_pages.dart';
import '../../signup/views/signup_view.dart';

class LoginController extends GetxController {
  var emailError = ''.obs;
  TextEditingController emailController = TextEditingController();
  var passwordError = ''.obs;
  TextEditingController passwordController = TextEditingController();
  var isPasswordHidden = true.obs;
  var isLoginLoading = false.obs;
  var isSignupLoading = false.obs;
  var rememberMe = false.obs;

  // Dio instance
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://196.189.247.250:8600/api/',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  @override
  void onInit() {
    super.onInit();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // Validate form inputs
  bool _validateForm() {
    bool hasErrors = false;

    // Email Validation
    if (emailController.text.trim().isEmpty) {
      emailError.value = 'Email is required';
      hasErrors = true;
    } else if (!GetUtils.isEmail(emailController.text.trim())) {
      emailError.value = 'Please enter a valid email';
      hasErrors = true;
    } else {
      emailError.value = '';
    }

    // Password Validation
    if (passwordController.text.isEmpty) {
      passwordError.value = 'Password is required';
      hasErrors = true;
    } else if (passwordController.text.length < 8) {
      passwordError.value = 'Password must be at least 8 characters';
      hasErrors = true;
    } else {
      passwordError.value = '';
    }

    return !hasErrors;
  }

  // Login with API
  // Login with API
  Future<void> login() async {
    if (!_validateForm()) {
      _showSnackBar(
        'Error',
        'Please fix the form errors before submitting.',
        Colors.red,
      );
      return;
    }

    // ===== STATIC USER LOGIN CHECK =====
    const staticEmail = 'sola@aii.et';
    const staticPassword = 'sol@1234567';

    if (emailController.text.trim() == staticEmail &&
        passwordController.text.trim() == staticPassword) {
      // Save dummy tokens for static login
      await _saveTokens('static_access_token', 'static_refresh_token');

      _showSnackBar(
        'Success',
        'Static user login successful!',
        Colors.green,
      );

      await Future.delayed(const Duration(seconds: 1));
      Get.offAllNamed(Routes.BOTTOM_NAV_HOME);
      return; // Skip API login
    }
    // ==================================

    isLoginLoading.value = true;

    try {
      final response = await _dio.post(
        'account/auth/login/',
        data: {
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final accessToken = data['access'];
        final refreshToken = data['refresh'];

        // Save tokens to SharedPreferences
        await _saveTokens(accessToken, refreshToken);

        _showSnackBar(
          'Success',
          'Login successful!',
          Colors.green,
        );

        await Future.delayed(const Duration(seconds: 2));
        Get.offAllNamed(Routes.BOTTOM_NAV_HOME);
      } else {
        _showSnackBar(
          'Error',
          'Unexpected response from server. Please try again.',
          Colors.red,
        );
      }
    } on DioException catch (e) {
      // existing error handling...
      String errorMessage = 'An error occurred. Please try again.';
      if (e.response != null) {
        if (e.response!.statusCode == 400) {
          final responseData = e.response!.data;
          if (responseData is Map && responseData.containsKey('non_field_errors')) {
            if (responseData['non_field_errors'].contains('Invalid credentials')) {
              errorMessage = 'No such user. Please check your email or password.';
            } else {
              errorMessage = 'Invalid input. Please check your credentials.';
            }
          } else {
            errorMessage = 'Bad request. Please check your input.';
          }
        } else if (e.response!.statusCode == 401) {
          errorMessage = 'Unauthorized. Please check your credentials.';
        } else {
          errorMessage = 'Server error: ${e.response!.statusCode}';
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timed out. Please check your internet.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server took too long to respond.';
      }

      _showSnackBar(
        'Error',
        errorMessage,
        Colors.red,
      );
    } catch (e) {
      _showSnackBar(
        'Error',
        'Unexpected error: $e',
        Colors.red,
      );
    } finally {
      isLoginLoading.value = false;
    }
  }


  // Save tokens to SharedPreferences
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    if (rememberMe.value) {
      await prefs.setBool('remember_me', true);
    }
  }

  // Retrieve tokens (for later use in the app)
  Future<Map<String, String?>> getTokens() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'access_token': prefs.getString('access_token'),
      'refresh_token': prefs.getString('refresh_token'),
    };
  }

  void signup() {
    Get.to(const SignupView());
  }

  void _showSnackBar(String title, String message, Color backgroundColor) {
    // Ensure snackbar is shown even if another is already visible
    Get.closeAllSnackbars(); // Close any existing snackbars
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      isDismissible: true,
      animationDuration: const Duration(milliseconds: 300),
      // Add overlay to ensure visibility
      overlayBlur: 0.5,
      overlayColor: Colors.black.withOpacity(0.2),
    );
  }

  void showHelpToast() {
    Get.closeAllSnackbars();
    Get.snackbar(
      'Login Help',
      'Use a valid email and password to log in. If you forgot your password, use the "Forgot Password" option.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.grey[800],
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      isDismissible: true,
      animationDuration: const Duration(milliseconds: 300),
      overlayBlur: 0.5,
      overlayColor: Colors.black.withOpacity(0.2),
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose(); // Call super last
  }
}