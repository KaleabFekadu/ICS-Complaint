import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_pages.dart';
import '../../signup/views/signup_view.dart';

class LoginController extends GetxController {
  var phoneError = ''.obs;
  final phoneController = TextEditingController();
  var passwordError = ''.obs;
  final passwordController = TextEditingController();
  var isPasswordHidden = true.obs;
  var isLoginLoading = false.obs;
  var isSignupLoading = false.obs;
  var rememberMe = false.obs;
  var isPhoneValid = true.obs;
  var isPhoneEmpty = false.obs;

  // Dio instance
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.86.2.212:4400', // Verify this matches your backend
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  @override
  void onInit() {
    super.onInit();
    // Initialize controllers without clearing to avoid disposal issues
    checkLoginStatus();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void validatePhoneNumber() {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      isPhoneEmpty.value = true;
      isPhoneValid.value = false;
      phoneError.value = 'Phone number is required'.tr;
    } else {
      final phoneRegex = RegExp(r'^(?:\+251|0)?9\d{8}$');
      isPhoneValid.value = phoneRegex.hasMatch(phone);
      isPhoneEmpty.value = false;
      phoneError.value = isPhoneValid.value ? '' : 'Please enter a valid phone number'.tr;
    }
  }

  Future<void> login() async {
    validatePhoneNumber();
    if (!isPhoneValid.value || phoneController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      _showSnackBar(
        'Error'.tr,
        'Please fix the form errors before submitting.'.tr,
        Colors.red,
      );
      return;
    }

    String phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    // Normalize phone number formats to try
    List<String> phoneFormats = [];
    if (phone.startsWith('+2519')) {
      phoneFormats.add(phone); // Original format
      phoneFormats.add('0${phone.substring(5)}'); // Convert +2519 to 09
    } else if (phone.startsWith('09')) {
      phoneFormats.add(phone); // Original format
      phoneFormats.add('+251${phone.substring(1)}'); // Convert 09 to +2519
    } else {
      phoneFormats.add(phone); // Use as is
    }

    String? errorMessage;
    bool loginSuccess = false;

    try {
      isLoginLoading.value = true;

      // Try each phone format
      for (String phoneFormat in phoneFormats) {
        try {
          final response = await _dio.post(
            '/graphql',
            data: {
              'query': '''
              mutation MyMutation(\$input: LoginInput!) {
                login(input: \$input) {
                  token
                  refresh_token
                  user {
                    name
                    last_seen
                    is_active
                    username
                    id
                  }
                }
              }
            ''',
              'variables': {
                'input': {
                  'username': phoneFormat,
                  'password': password,
                },
              },
            },
            options: Options(
              headers: {'Content-Type': 'application/json'},
            ),
          );

          // Check response structure
          if (response.data is! Map || !response.data.containsKey('data')) {
            throw Exception('Invalid response structure: "data" key not found');
          }

          if (response.data['data'] is! Map || !response.data['data'].containsKey('login')) {
            throw Exception('Invalid response structure: "login" key not found');
          }

          final data = response.data['data']['login'];

          // Check for token and user data
          if (data is! Map || data['token'] == null || data['user'] == null) {
            throw Exception('Invalid response: token or user data missing');
          }

          final token = data['token'];
          final user = data['user'];

          // Validate user fields
          if (user is! Map || user['id'] == null || user['name'] == null || user['username'] == null) {
            throw Exception('Invalid user data: required fields missing');
          }

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', token);
          await prefs.setString('refresh_token', data['refresh_token'] ?? '');
          await prefs.setString('customer_id', user['id'].toString());
          await prefs.setString('full_name', user['name']);
          await prefs.setString('phone_number', user['username']);
          if (rememberMe.value) {
            await prefs.setBool('remember_me', true);
          }

          _showSnackBar(
            'Success'.tr,
            'Login successful!'.tr,
            Colors.green,
          );

          await Future.delayed(const Duration(seconds: 1));
          Get.offAllNamed(Routes.BOTTOM_NAV_HOME);
          loginSuccess = true;
          break; // Exit loop on successful login
        } catch (e) {
          errorMessage = e.toString();
          print('Attempt with $phoneFormat failed: $e');
        }
      }

      // If login failed after trying all formats
      if (!loginSuccess) {
        String suggestionKey = 'Incorrect phone number or password.';
        _showSnackBar(
          'Error'.tr,
          suggestionKey.tr,
          Colors.red,
        );
      }
    } on DioException catch (e) {
      print('DioException: ${e.response?.data}');
      String errorKey = 'Login failed. Please try again.';
      if (e.response?.data != null) {
        if (e.response!.data is String && e.response!.data.contains('MethodNotAllowedHttpException')) {
          errorKey = 'Server error: POST method not supported at this endpoint. Please check the API URL.';
        } else if (e.response!.data is Map) {
          final errors = e.response!.data['errors'];
          if (errors is List && errors.isNotEmpty && errors[0] is Map && errors[0].containsKey('message')) {
            errorMessage = errors[0]['message'];
          } else if (e.response!.data.containsKey('message')) {
            errorMessage = e.response!.data['message'];
          }
        }
      }
      String suggestionKey = 'Incorrect phone number or password.';
      _showSnackBar(
        'Error'.tr,
        errorMessage != null ? 'Unexpected error: $errorMessage $suggestionKey'.tr : errorKey.tr,
        Colors.red,
      );
    } catch (e) {
      print('Unexpected error: $e');
      String suggestionKey = 'Incorrect phone number or password.';
      _showSnackBar(
        'Error'.tr,
        'Unexpected error: $e $suggestionKey'.tr,
        Colors.red,
      );
    } finally {
      isLoginLoading.value = false;
    }
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null) {
      Get.offAllNamed(Routes.BOTTOM_NAV_HOME);
    }
  }

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
    Get.closeAllSnackbars();
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
      overlayBlur: 0.5,
      overlayColor: Colors.black.withOpacity(0.2),
    );
  }

  void showHelpToast() {
    Get.closeAllSnackbars();
    Get.snackbar(
      'Login Help'.tr,
      'To log in, enter your phone number and password. If you forgot your password, use the "Forgot Password" option.'.tr,
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
    // Avoid clearing controllers here to prevent disposal issues
    super.onClose();
  }
}