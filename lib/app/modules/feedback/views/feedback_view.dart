import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/feedback_controller.dart';

class FeedbackView extends GetView<FeedbackController> {
  const FeedbackView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FeedbackController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedback"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Branch Dropdown
              const Text(
                "Select Branch",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedBranch.value.isEmpty
                    ? null
                    : controller.selectedBranch.value,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                hint: const Text("Choose branch"),
                items: controller.branches.map((branch) {
                  return DropdownMenuItem<String>(
                    value: branch,
                    child: Text(branch),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedBranch.value = value;
                    controller.selectedService.value = '';
                  }
                },
              )),
              const SizedBox(height: 20),

              // Service Dropdown
              const Text(
                "Select Service",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedService.value.isEmpty
                    ? null
                    : controller.selectedService.value,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                hint: const Text("Choose service"),
                items: controller
                    .getServicesForBranch(controller.selectedBranch.value)
                    .map((service) {
                  return DropdownMenuItem<String>(
                    value: service,
                    child: Text(service),
                  );
                }).toList(),
                onChanged: controller.selectedBranch.value.isEmpty
                    ? null
                    : (value) {
                  if (value != null) {
                    controller.selectedService.value = value;
                  }
                },
              )),
              const SizedBox(height: 20),

              // Rating
              const Text(
                "Rate Service",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Obx(() => Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < controller.rating.value
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () {
                      controller.rating.value = index + 1;
                    },
                  );
                }),
              )),
              const SizedBox(height: 20),

              // Description
              const Text(
                "Description",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Obx(() => TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Write your feedback...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) => controller.description.value = value,
                controller: TextEditingController(
                  text: controller.description.value,
                ),
              )),
              const SizedBox(height: 30),

              // Submit button
              Center(
                child: ElevatedButton(
                  onPressed: controller.submitFeedback,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Submit Feedback"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
