import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/forget_controller.dart';

class ForgetView extends GetView<ForgetController> {
  const ForgetView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ForgetView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ForgetView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
