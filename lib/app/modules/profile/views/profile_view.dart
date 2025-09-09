import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../utils/constants/colors.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure ProfileController is initialized
    ValueNotifier<String> selectedLanguage = ValueNotifier('English');

    Get.put(ProfileController());
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text('Settings',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
        elevation: 0.4,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 24),
                _buildTile(Iconsax.profile_circle, 'Edit Profile', () {}),
                _buildTile(
                  Iconsax.lock,
                  'Change Password',
                      () => _showChangePasswordBottomSheet(context),
                ),
                const SizedBox(height: 24),
                const Text("Preferences",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey)),
                const SizedBox(height: 8),
                _buildTile(
                  Iconsax.language_square,
                  'Language',
                      () => _showLanguageBottomSheet(context, selectedLanguage),
                ),
                _buildTile(Iconsax.moon, 'Dark Mode', () {}),
                const SizedBox(height: 24),
                const Text("Support",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey)),
                const SizedBox(height: 8),
                _buildTile(
                  Iconsax.security_card,
                  'Privacy Policy',
                      () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors
                          .transparent, // make background transparent for rounded corners effect
                      builder: (context) => DraggableScrollableSheet(
                        expand: false,
                        initialChildSize: 0.75,
                        minChildSize: 0.4,
                        maxChildSize: 0.95,
                        builder: (context, scrollController) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(24)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            child: SingleChildScrollView(
                              controller: scrollController,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Drag handle
                                  Center(
                                    child: Container(
                                      width: 48,
                                      height: 6,
                                      margin: const EdgeInsets.only(bottom: 24),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "Privacy Policy",
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  _policySection(
                                    title:
                                    "Welcome to the CRRSA (Civil Registration and Residency Service Agency) application.",
                                    content:
                                    "We are committed to protecting your privacy and ensuring that your personal data is handled securely. By using this application, you agree to the collection and use of your information in accordance with this policy.",
                                  ),

                                  _policySection(
                                    title: "Information Collection",
                                    content:
                                    "We collect personal details such as your full name, date of birth, residency details, and identification information strictly for registration and residency services.",
                                  ),

                                  _policySection(
                                    title: "Information Use",
                                    content:
                                    "Your data will be used only for official CRRSA services and will not be shared with third parties without your consent, unless required by law.",
                                  ),

                                  _policySection(
                                    title: "Data Security",
                                    content:
                                    "We use advanced security measures to protect your information from unauthorized access.",
                                  ),

                                  _policySection(
                                    title: "User Rights",
                                    content:
                                    "You have the right to request corrections or deletion of your personal data in accordance with applicable regulations.",
                                  ),

                                  const SizedBox(height: 12),
                                  Center(
                                    child: Text(
                                      "Thank you for trusting CRRSA with your personal information.",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                        fontStyle: FontStyle.normal,
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                _buildTile(Iconsax.info_circle, 'About App', () {
                  //Get.to(() => const AboutView());
                }),
                const SizedBox(height: 24),
                const Divider(),
                _buildTile(
                  Iconsax.logout,
                  'Logout',
                      () {
                    controller.logout(); // Call logout from ProfileController
                  },
                  iconColor: Colors.red,
                  textColor: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _policySection({
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageBottomSheet(
      BuildContext context, ValueNotifier<String> selectedLanguage) {
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      builder: (context) {
        return ValueListenableBuilder<String>(
          valueListenable: selectedLanguage,
          builder: (context, value, child) {
            return Container(
              padding:
              const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[400]?.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Select Language',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: isDarkMode ? TColors.secondary : TColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLanguageTile(
                    context: context,
                    language: 'English',
                    selectedLanguage: selectedLanguage,
                    isSelected: value == 'English',
                    isDarkMode: isDarkMode,
                  ),
                  _buildLanguageTile(
                    context: context,
                    language: 'አማርኛ',
                    selectedLanguage: selectedLanguage,
                    isSelected: value == 'አማርኛ',
                    isDarkMode: isDarkMode,
                  ),
                  _buildLanguageTile(
                    context: context,
                    language: 'ትግርኛ',
                    selectedLanguage: selectedLanguage,
                    isSelected: value == 'ትግርኛ',
                    isDarkMode: isDarkMode,
                  ),
                  _buildLanguageTile(
                    context: context,
                    language: 'Afaan Oromoo',
                    selectedLanguage: selectedLanguage,
                    isSelected: value == 'Afaan Oromoo',
                    isDarkMode: isDarkMode,
                  ),
                  _buildLanguageTile(
                    context: context,
                    language: 'Soomaali',
                    selectedLanguage: selectedLanguage,
                    isSelected: value == 'Soomaali',
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showChangePasswordBottomSheet(BuildContext context) {
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    final ValueNotifier<bool> showCurrent = ValueNotifier(false);
    final ValueNotifier<bool> showNew = ValueNotifier(false);
    final ValueNotifier<bool> showConfirm = ValueNotifier(false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding:
            const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[400]?.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Title
                Center(
                  child: Text(
                    'Change Password',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: isDarkMode ? TColors.secondary : TColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Current Password
                ValueListenableBuilder<bool>(
                  valueListenable: showCurrent,
                  builder: (context, show, child) {
                    return _buildPasswordField(
                      label: "Current Password",
                      controller: currentPasswordController,
                      obscureText: !show,
                      isDarkMode: isDarkMode,
                      onToggle: () => showCurrent.value = !showCurrent.value,
                    );
                  },
                ),
                const SizedBox(height: 12),

                // New Password
                ValueListenableBuilder<bool>(
                  valueListenable: showNew,
                  builder: (context, show, child) {
                    return _buildPasswordField(
                      label: "New Password",
                      controller: newPasswordController,
                      obscureText: !show,
                      isDarkMode: isDarkMode,
                      onToggle: () => showNew.value = !showNew.value,
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Confirm Password
                ValueListenableBuilder<bool>(
                  valueListenable: showConfirm,
                  builder: (context, show, child) {
                    return _buildPasswordField(
                      label: "Confirm Password",
                      controller: confirmPasswordController,
                      obscureText: !show,
                      isDarkMode: isDarkMode,
                      onToggle: () => showConfirm.value = !showConfirm.value,
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // TODO: handle password change logic
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Save Password",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required bool isDarkMode,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDarkMode ? Colors.white70 : Colors.grey[700],
          fontSize: 14,
        ),
        filled: true,
        fillColor: isDarkMode
            ? Colors.grey[800]?.withOpacity(0.6)
            : Colors.grey[100]?.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: onToggle,
        ),
      ),
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black,
        fontSize: 14,
      ),
    );
  }

  Widget _buildLanguageTile({
    required BuildContext context,
    required String language,
    required ValueNotifier<String> selectedLanguage,
    required bool isSelected,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: GestureDetector(
        onTap: () {
          selectedLanguage.value = language;
          Navigator.pop(context);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.grey[800]?.withOpacity(0.6)
                : Colors.grey[100]?.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
              color: isDarkMode ? TColors.white : TColors.secondary,
              width: 0.5,
            )
                : null,
            boxShadow: [
              BoxShadow(
                color:
                isDarkMode ? Colors.black26 : Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDarkMode ? Colors.white : Colors.black,
                    width: 0.5,
                  ),
                ),
                child: isSelected
                    ? Center(
                  child: Icon(
                    Icons.check,
                    size: 16,
                    color: isDarkMode ? TColors.white : TColors.primary,
                  ),
                )
                    : null,
              ),
              const SizedBox(width: 16),
              Text(
                language,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Obx(() => Row(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color:
            TColors.primary.withOpacity(0.1), // light background circle
            shape: BoxShape.circle,
          ),
          child: Icon(
            Iconsax.profile_circle, // Iconsax profile icon
            size: 50,
            color: TColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.userName.value,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              controller.userEmail.value,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        const Spacer(),
      ],
    ));
  }

  Widget _buildTile(IconData icon, String title, VoidCallback onTap,
      {Color iconColor = Colors.black, Color textColor = Colors.black}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(title,
          style: TextStyle(
              color: textColor, fontSize: 16, fontWeight: FontWeight.w500)),
      trailing: const Icon(Iconsax.arrow_right_3, size: 18, color: Colors.grey),
      onTap: onTap,
    );
  }
}


class _IDInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDarkMode;
  final BuildContext context;

  const _IDInfoRow({
    required this.label,
    required this.value,
    required this.isDarkMode,
    required this.context,
  });

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white70 : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.copy,
              size: 20,
              color: isDarkMode ? Colors.white70 : Colors.grey[700],
            ),
            onPressed: _copyToClipboard,
            tooltip: 'Copy $label',
          ),
        ],
      ),
    );
  }
}

class _IDCardFlipper extends StatefulWidget {
  final bool isDarkMode;

  const _IDCardFlipper({required this.isDarkMode});

  @override
  _IDCardFlipperState createState() => _IDCardFlipperState();
}

class _IDCardFlipperState extends State<_IDCardFlipper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_controller.isAnimating) return;
    setState(() {
      _isFront = !_isFront;
    });
    if (_isFront) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final isFrontVisible = _animation.value <= 0.5;
          final angle = _animation.value * pi;
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Add perspective
              ..rotateY(angle),
            alignment: Alignment.center,
            child: Center(
              child: isFrontVisible
                  ? Image.asset(
                'assets/logos/IMG_2479 (1).JPG',
                key: const ValueKey(true),
                height: 220,
                fit: BoxFit.contain,
              )
                  : Transform(
                transform: Matrix4.identity()..rotateY(pi),
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/logos/IMG_2480 (1).JPG', // Fixed asset path
                  key: const ValueKey(false),
                  height: 220,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
