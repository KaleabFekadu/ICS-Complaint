import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/create_complaint_controller.dart';

class CreateComplaintView extends GetView<CreateComplaintController> {
  const CreateComplaintView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CreateComplaintView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'CreateComplaintView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
