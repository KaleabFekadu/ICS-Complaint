import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/constants/config.dart';
import '../../login/views/login_view.dart';

class SignupController extends GetxController {
  var phoneError = ''.obs;
  TextEditingController phoneController = TextEditingController();
  final fullNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  var firstNameError = ''.obs;
  var lastNameError = ''.obs;
  var passwordError = ''.obs;
  var confirmPasswordError = ''.obs;
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;
  var isLoading = false.obs;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: Config.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
    // Add this to handle 404 responses more gracefully
    validateStatus: (status) => status! < 500,
  ))
    ..interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  Future<void> signUp() async {
    print('🔵 Signup initiated');

    // Add validation before proceeding
    if (fullNameController.text.trim().isEmpty) {
      showCustomSnackBar(
        title: 'Error',
        message: 'Please enter your full name',
        type: 'failure',
      );
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      showCustomSnackBar(
        title: 'Error',
        message: 'Please enter your phone number',
        type: 'failure',
      );
      return;
    }

    if (passwordController.text.trim().isEmpty) {
      showCustomSnackBar(
        title: 'Error',
        message: 'Please enter a password',
        type: 'failure',
      );
      return;
    }

    if (confirmPasswordController.text.trim().isEmpty) {
      showCustomSnackBar(
        title: 'Error',
        message: 'Please confirm your password',
        type: 'failure',
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      showCustomSnackBar(
        title: 'Error',
        message: 'Passwords do not match',
        type: 'failure',
      );
      return;
    }

    isLoading.value = true;
    print('🔄 Loading started');

    // Format phone number
    String phone = phoneController.text.trim();
    print('📱 Original phone: $phone');

    if (phone.startsWith('0')) {
      phone = '+251${phone.substring(1)}';
    } else if (!phone.startsWith('+251') && phone.startsWith('9')) {
      phone = '+251$phone';
    }
    print('📱 Formatted phone: $phone');

    try {
      final Map<String, dynamic> requestData = {
        'query': '''
    mutation register(\$input: RegisterInput!) {
      register(input: \$input) {
        status
        token
      }
    }
  ''',
        'variables': {
          'input': {
            'name':
                '${fullNameController.text.trim()} ${lastNameController.text.trim()}',
            'username': phone,
            'password': passwordController.text.trim(),
            'password_confirmation': confirmPasswordController.text.trim(),
          },
        },
      };

      print('📤 Sending request with data: ${jsonEncode(requestData)}');

      final response = await _dio
          .post(
        '/graphql',
        data: requestData,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      )
          .timeout(const Duration(seconds: 15), onTimeout: () {
        throw DioException(
          requestOptions: RequestOptions(path: '/graphql'),
          error: 'Request timed out',
        );
      });

      print('📥 Received response: ${response.data}');

      if (response.data == null) {
        print('🔴 Null response received');
        throw Exception('No response received from server');
      }

      // Handle GraphQL errors
      if (response.data.containsKey('errors')) {
        final errors = response.data['errors'];
        String errorMessage = 'Signup failed. Please try again.';
        if (errors is List && errors.isNotEmpty) {
          errorMessage = errors[0]['message'] ?? errorMessage;
          print('🔴 GraphQL Error: $errorMessage');

          // Check if it's a duplicate phone number error
          if (errorMessage.toLowerCase().contains('phone') ||
              errorMessage.toLowerCase().contains('username') ||
              errorMessage.toLowerCase().contains('exist') ||
              errorMessage.toLowerCase().contains('already')) {
            errorMessage =
                'This phone number is already registered. Please log in or reset your password.';
          }
        }
        throw Exception(errorMessage);
      }

      if (!response.data.containsKey('data')) {
        print('🔴 Missing data field in response');
        throw Exception('Invalid response format: missing data field');
      }

      final registerData = response.data['data']['register'];
      if (registerData == null) {
        print('🔴 No register data in response');
        throw Exception('Registration failed: no data returned');
      }

      print('🟢 Register data: $registerData');

      // Check status
      if (registerData['status']?.toString().toLowerCase() != 'success') {
        final message = registerData['message'] ?? 'Registration failed';
        print('🔴 Registration failed: $message');

        // Check if it's a duplicate phone number error
        String errorMessage = message;
        if (message.toLowerCase().contains('phone') ||
            message.toLowerCase().contains('username') ||
            message.toLowerCase().contains('exist') ||
            message.toLowerCase().contains('already')) {
          errorMessage =
              'This phone number is already registered. Please log in or reset your password.';
        }
        throw Exception(errorMessage);
      }

      // Store user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', registerData['token'] ?? '');
      await prefs.setString('phone_number', phone);
      print('🔐 Stored token and phone number');

      showCustomSnackBar(
        title: 'Success',
        message: 'Account created successfully',
        type: 'success',
      );
      print('🟢 Signup successful');

      // Redirect to login with phone number
      Get.off(() =>  LoginView(), arguments: {"phone_number": phone});
      print('🔄 Redirecting to login');
    } on DioException catch (e) {
      print('🔴 Dio Error: ${e.toString()}');
      print('🔴 Error Type: ${e.type}');
      print('🔴 Error Message: ${e.message}');
      print('🔴 Response: ${e.response?.data}');
      print('🔴 Status Code: ${e.response?.statusCode}');

      String errorMessage = 'Signup failed. Please try again.';

      if (e.response?.data != null) {
        if (e.response!.data is Map && e.response!.data.containsKey('errors')) {
          final errors = e.response!.data['errors'];
          if (errors is List && errors.isNotEmpty) {
            errorMessage = errors[0]['message'] ?? errorMessage;

            // Check if it's a duplicate phone number error
            if (errorMessage.toLowerCase().contains('phone') ||
                errorMessage.toLowerCase().contains('username') ||
                errorMessage.toLowerCase().contains('exist') ||
                errorMessage.toLowerCase().contains('already')) {
              errorMessage =
                  'This phone number is already registered. Please log in or reset your password.';
            }
          }
        } else if (e.response!.data is Map &&
            e.response!.data.containsKey('message')) {
          errorMessage = e.response!.data['message'];

          // Check if it's a duplicate phone number error
          if (errorMessage.toLowerCase().contains('phone') ||
              errorMessage.toLowerCase().contains('username') ||
              errorMessage.toLowerCase().contains('exist') ||
              errorMessage.toLowerCase().contains('already')) {
            errorMessage =
                'This phone number is already registered. Please log in or reset your password.';
          }
        } else if (e.response!.data is String) {
          errorMessage = e.response!.data;

          // Check if it's a duplicate phone number error
          if (errorMessage.toLowerCase().contains('phone') ||
              errorMessage.toLowerCase().contains('username') ||
              errorMessage.toLowerCase().contains('exist') ||
              errorMessage.toLowerCase().contains('already')) {
            errorMessage =
                'This phone number is already registered. Please log in or reset your password.';
          }
        }
      }

      print('🔴 Final Error Message: $errorMessage');
      showCustomSnackBar(
        title: 'Error',
        message: errorMessage,
        type: 'failure',
      );
    } catch (e, stackTrace) {
      print('🔴 Unexpected Error: $e');
      print('🔴 Stack Trace: $stackTrace');

      // Only show the phone number message for specific errors
      String errorMessage = e.toString();
      if (errorMessage.toLowerCase().contains('phone') ||
          errorMessage.toLowerCase().contains('username') ||
          errorMessage.toLowerCase().contains('exist') ||
          errorMessage.toLowerCase().contains('already')) {
        errorMessage =
            'This phone number is already registered. Please log in or reset your password.';
      } else {
        errorMessage = 'Signup failed. Please try again.';
      }

      showCustomSnackBar(
        title: 'Error',
        message: errorMessage,
        type: 'failure',
      );
    } finally {
      isLoading.value = false;
      print('🔄 Loading completed');
    }
  }

  void showCustomSnackBar({
    required String title,
    required String message,
    required String type,
    Duration duration = const Duration(seconds: 3),
  }) {
    Color backgroundColor;
    IconData icon;
    Color iconBackgroundColor;

    switch (type.toLowerCase()) {
      case 'success':
        backgroundColor = Colors.green.shade800;
        icon = Icons.check_circle;
        iconBackgroundColor = Colors.green.shade600;
        break;
      case 'failure':
        backgroundColor = Colors.red.shade800;
        icon = Icons.error;
        iconBackgroundColor = Colors.red.shade600;
        break;
      case 'warning':
        backgroundColor = Colors.orange.shade800;
        icon = Icons.warning;
        iconBackgroundColor = Colors.orange.shade600;
        break;
      case 'info':
      default:
        backgroundColor = Colors.blue.shade800;
        icon = Icons.info;
        iconBackgroundColor = Colors.blue.shade600;
    }

    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      duration: duration,
      dismissDirection: DismissDirection.up,
      content: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
              spreadRadius: 1,
            ),
          ],
          gradient: LinearGradient(
            colors: [
              backgroundColor,
              backgroundColor.withOpacity(0.9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () =>
                  ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar(),
              child: Icon(
                Icons.close,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );

    ScaffoldMessenger.of(Get.context!)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  // bool _validateForm() {
  //   bool hasErrors = false;
  //
  //   if (fullNameController.text.trim().isEmpty) {
  //     firstNameError.value = 'First Name is required';
  //     hasErrors = true;
  //   } else {
  //     firstNameError.value = '';
  //   }
  //
  //   if (lastNameController.text.trim().isEmpty) {
  //     lastNameError.value = 'Last Name is required';
  //     hasErrors = true;
  //   } else {
  //     lastNameError.value = '';
  //   }
  //
  //   final phoneRegex = RegExp(r'^(?:\+251|251|0)?9\d{8}$');
  //   if (phoneController.text.isEmpty || !phoneRegex.hasMatch(phoneController.text)) {
  //     phoneError.value = 'Invalid phone number';
  //     hasErrors = true;
  //   } else {
  //     phoneError.value = '';
  //   }
  //
  //   final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$%^&*\(\)_+\-=\[\]{};:\",<>\.\?/`~|]).{8,}$');
  //   if (passwordController.text.isEmpty || !passwordRegex.hasMatch(passwordController.text)) {
  //     passwordError.value = 'Password must contain at least 8 characters, one uppercase letter, one number, and one special character';
  //     hasErrors = true;
  //   } else {
  //     passwordError.value = '';
  //   }
  //
  //   if (confirmPasswordController.text != passwordController.text) {
  //     confirmPasswordError.value = 'Passwords do not match';
  //     hasErrors = true;
  //   } else {
  //     confirmPasswordError.value = '';
  //   }
  //
  //   return !hasErrors;
  // }

  void _showSnackBar(String title, String message, Color backgroundColor) {
    print('Showing snackbar: $title - $message');
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  void onClose() {
    fullNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
