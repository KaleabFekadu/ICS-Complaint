import 'package:get/get.dart';

import '../controllers/create_complaint_controller.dart';

class CreateComplaintBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateComplaintController>(
      () => CreateComplaintController(),
    );
  }
}
