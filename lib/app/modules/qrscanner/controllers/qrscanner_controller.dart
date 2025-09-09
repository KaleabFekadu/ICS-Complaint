import 'package:get/get.dart';

class QrscannerController extends GetxController {
  var scannedCode = ''.obs;

  void setScannedCode(String code) {
    scannedCode.value = code;
  }

  void clearScannedCode() {
    scannedCode.value = '';
  }
}