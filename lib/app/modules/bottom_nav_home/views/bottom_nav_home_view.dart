import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/bottom_nav_home_controller.dart';

class BottomNavHomeView extends GetView<BottomNavHomeController> {
  const BottomNavHomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BottomNavHomeView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'BottomNavHomeView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
