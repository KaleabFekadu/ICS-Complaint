import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../utils/constants/colors.dart';
import '../controllers/signup_controller.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    SignupController controller = Get.put(SignupController());
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        actions: [],
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      Image.asset(
                        'assets/logos/logo_2.png',
                        height: 280,
                        width: 280,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 15,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Obx(() => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: controller.fullNameController,
                                  decoration: InputDecoration(
                                    labelText: 'Full Name'.tr, // Localized
                                    filled: true,
                                    labelStyle: const TextStyle(fontSize: 12),
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade400,
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: TColors.secondary,
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 20),
                                    prefixIcon: const Icon(
                                      Iconsax.user,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (controller.firstNameError.isNotEmpty)
                                  Text(
                                    controller
                                        .firstNameError.value.tr, // Localized
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 12),
                                  ),
                                const SizedBox(height: 10),
                              ],
                            )),
                        Obx(() => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: controller.phoneController,
                                  keyboardType: TextInputType.phone,
                                  onChanged: (value) {
                                    final regex =
                                        RegExp(r'^(?:\+251|251|0)?9\d{8}$');
                                    if (!regex.hasMatch(value)) {
                                      controller.phoneError.value =
                                          'Invalid phone number';
                                    } else {
                                      controller.phoneError.value = '';
                                    }
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Phone Number'.tr, // Localized
                                    filled: true,
                                    labelStyle: const TextStyle(fontSize: 12),
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade400,
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: TColors.secondary,
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 20),
                                    prefixIcon: const Icon(
                                      Iconsax.call,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (controller.phoneError.isNotEmpty)
                                  Text(
                                    controller.phoneError.value.tr, // Localized
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 12),
                                  ),
                                const SizedBox(height: 10),
                              ],
                            )),
                        Obx(() => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: controller.passwordController,
                                  obscureText:
                                      controller.isPasswordHidden.value,
                                  onChanged: (value) {
                                    final passwordRegex = RegExp(
                                        r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$%^&*\(\)_+\-=\[\]{};:\",<>\.\?/`~|]).{8,}$');
                                    if (!passwordRegex.hasMatch(value)) {
                                      controller.passwordError.value =
                                          'Password must be at least 8 characters, contain one uppercase letter, one number, and one special character';
                                    } else {
                                      controller.passwordError.value = '';
                                    }
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Password'.tr, // Localized
                                    labelStyle: const TextStyle(fontSize: 12),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade400,
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: TColors.secondary,
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 20),
                                    prefixIcon: const Icon(
                                      Iconsax.lock,
                                      size: 20,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        controller.isPasswordHidden.value
                                            ? Iconsax.eye_slash
                                            : Iconsax.eye,
                                        size: 20,
                                      ),
                                      onPressed:
                                          controller.togglePasswordVisibility,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (controller.passwordError.isNotEmpty)
                                  Text(
                                    controller
                                        .passwordError.value.tr, // Localized
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 12),
                                  ),
                                const SizedBox(height: 10),
                              ],
                            )),
                        Obx(() => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller:
                                      controller.confirmPasswordController,
                                  obscureText:
                                      controller.isConfirmPasswordHidden.value,
                                  onChanged: (value) {
                                    if (value !=
                                        controller.passwordController.text) {
                                      controller.confirmPasswordError.value =
                                          'Passwords do not match';
                                    } else {
                                      controller.confirmPasswordError.value =
                                          '';
                                    }
                                  },
                                  decoration: InputDecoration(
                                    labelText:
                                        'Confirm Password'.tr, // Localized
                                    labelStyle: const TextStyle(fontSize: 12),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade400,
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: TColors.secondary,
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 20),
                                    prefixIcon: const Icon(
                                      Iconsax.lock,
                                      size: 20,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        controller.isConfirmPasswordHidden.value
                                            ? Iconsax.eye_slash
                                            : Iconsax.eye,
                                        size: 20,
                                      ),
                                      onPressed: controller
                                          .toggleConfirmPasswordVisibility,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (controller.confirmPasswordError.isNotEmpty)
                                  Text(
                                    controller.confirmPasswordError.value
                                        .tr, // Localized
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 12),
                                  ),
                                const SizedBox(height: 10),
                              ],
                            )),
                        const SizedBox(height: 20),
                        Obx(() => SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () {
                                        controller.signUp();
                                      },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.zero,
                                  elevation: 5,
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        TColors.primary,
                                        TColors.secondary
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: controller.isLoading.value
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            'Sign Up'.tr, // Localized
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            )),
                      ],
                    ),
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
