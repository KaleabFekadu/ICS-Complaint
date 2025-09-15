import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../utils/constants/colors.dart';
import '../../home/views/home_view.dart';
import '../../profile/views/profile_view.dart';
import '../../qrscanner/views/qrscanner_view.dart';
import '../controllers/bottom_nav_home_controller.dart';

class BottomNavHomeView extends GetView<BottomNavHomeController> {
  const BottomNavHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    BottomNavHomeController controller = Get.put(BottomNavHomeController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        return IndexedStack(
          index: controller.selectedIndex.value,
          children: const [
            HomeView(),
            QrscannerView(), // QR Scanner Screen
            ProfileView(),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: TColors.primary,
        shape: const CircleBorder(),
        elevation: 6,
        onPressed: () => controller.changeTab(1),
        child: const Icon(
          Iconsax.scan_barcode,
          size: 30,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Obx(() {
        return BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          elevation: 8,
          color: TColors.primary.withOpacity(0.1), // White background for light mode
          child: SizedBox(
            height: 60, // Prevent overflow
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  controller: controller,
                  index: 0,
                  icon: Iconsax.home,
                  label: 'Home',
                  selectedColor: TColors.primary,
                  unselectedColor: Colors.grey,
                ),
                const SizedBox(width: 40), // Space for notch
                _buildNavItem(
                  controller: controller,
                  index: 2,
                  icon: Iconsax.profile_circle,
                  label: 'Profile',
                  selectedColor: TColors.primary,
                  unselectedColor: Colors.grey,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNavItem({
    required BottomNavHomeController controller,
    required int index,
    required IconData icon,
    required String label,
    required Color selectedColor,
    required Color unselectedColor,
  }) {
    bool isSelected = controller.selectedIndex.value == index;

    return InkWell(
      onTap: () => controller.changeTab(index),
      child: Container(
        height: 60,
        width: 140,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? selectedColor : Colors.transparent,
            width: 1, // Thin border width
          ),
          borderRadius: BorderRadius.circular(8), // Optional: rounded corners
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? selectedColor : unselectedColor,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                  color: isSelected ? selectedColor : unselectedColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
