import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ics_complaint/app/utils/constants/config.dart';
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
    baseUrl: Config.baseUrl, // Verify this matches your backend
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
      phoneError.value =
          isPhoneValid.value ? '' : 'Please enter a valid phone number'.tr;
    }
  }

  Future<void> login() async {
    validatePhoneNumber();
    if (!isPhoneValid.value ||
        phoneController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
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
        // Reset errorMessage for this attempt
        errorMessage = null;

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

          // Check if response is a valid map
          if (response.data is! Map) {
            errorMessage = 'Invalid response: not a map';
            print('Attempt with $phoneFormat failed: $errorMessage');
            continue;
          }

          final responseMap = response.data as Map;

          // Handle GraphQL errors
          if (responseMap.containsKey('errors')) {
            final errors = responseMap['errors'];
            String? msg;
            if (errors is List && errors.isNotEmpty) {
              final firstError = errors[0];
              if (firstError is Map && firstError['message'] != null) {
                msg = firstError['message'].toString();
              }
            }
            errorMessage = msg ?? 'Login failed';
            print('Attempt with $phoneFormat failed: $errorMessage');
            continue;
          }

          // Check for data
          if (!responseMap.containsKey('data')) {
            errorMessage = 'Invalid response structure: "data" key not found';
            print('Attempt with $phoneFormat failed: $errorMessage');
            continue;
          }

          final data = responseMap['data'];
          if (data is! Map || !data.containsKey('login')) {
            errorMessage = 'Invalid response structure: "login" key not found';
            print('Attempt with $phoneFormat failed: $errorMessage');
            continue;
          }

          final loginData = data['login'];
          if (loginData is! Map || loginData['token'] == null || loginData['user'] == null) {
            errorMessage = 'Invalid response: token or user data missing';
            print('Attempt with $phoneFormat failed: $errorMessage');
            continue;
          }

          final token = loginData['token'];
          final user = loginData['user'];

          // Validate user fields
          if (user is! Map ||
              user['id'] == null ||
              user['name'] == null ||
              user['username'] == null) {
            errorMessage = 'Invalid user data: required fields missing';
            print('Attempt with $phoneFormat failed: $errorMessage');
            continue;
          }

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', token);
          await prefs.setString('refresh_token', loginData['refresh_token'] ?? '');
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
        } on DioException catch (dioError) {
          errorMessage = dioError.message ?? 'Network error occurred';
          print('DioException with $phoneFormat: ${dioError.response?.data}');
          print('Attempt with $phoneFormat failed: $errorMessage');
          // Continue to next format on Dio errors (e.g., network issues might be transient)
        } catch (e) {
          errorMessage = e.toString();
          print('Unexpected error with $phoneFormat: $e');
          print('Attempt with $phoneFormat failed: $errorMessage');
          // Continue to next format
        }
      }

      // If login failed after trying all formats
      if (!loginSuccess) {
        final displayMessage = errorMessage ?? 'Incorrect phone number or password.'.tr;
        _showSnackBar(
          'Error'.tr,
          displayMessage,
          Colors.red,
        );
      }
    } catch (e) {
      print('Unexpected error in login: $e');
      _showSnackBar(
        'Error'.tr,
        'Unexpected error: $e. Please try again.'.tr,
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
    // Use closeCurrentSnackbar instead of closeAllSnackbars to avoid LateInitializationError
    Get.closeCurrentSnackbar();
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
    // Use closeCurrentSnackbar here as well
    Get.closeCurrentSnackbar();
    Get.snackbar(
      'Login Help'.tr,
      'To log in, enter your phone number and password. If you forgot your password, use the "Forgot Password" option.'
          .tr,
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
    super.onClose();
  }
}