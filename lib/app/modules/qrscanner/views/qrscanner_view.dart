import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/qrscanner_controller.dart';

class QrscannerView extends GetView<QrscannerController> {
  const QrscannerView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QrscannerView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'QrscannerView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
