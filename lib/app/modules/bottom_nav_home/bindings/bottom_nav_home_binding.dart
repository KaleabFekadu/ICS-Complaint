import 'package:get/get.dart';

import '../controllers/bottom_nav_home_controller.dart';

class BottomNavHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BottomNavHomeController>(
      () => BottomNavHomeController(),
    );
  }
}
