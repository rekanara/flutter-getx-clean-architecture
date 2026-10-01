import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/atoms/custom_text.dart';
import '../../utils/config.dart';
import 'controllers/{{feature_name}}.controller.dart';

class {{feature_name.pascalCase()}}Screen extends GetView<{{feature_name.pascalCase()}}Controller> {
  const {{feature_name.pascalCase()}}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          text: '{{feature_name.pascalCase()}}',
          fontType: FontType.titleMedium,
          color: Colors.white,
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final item = controller.data.value;
        if (item == null) {
          return const Center(child: Text('No data found'));
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(
                text: 'ID: ${item.id}',
                fontType: FontType.bodyLarge,
              ),
              const SizedBox(height: 16),
              CustomText(
                text: 'Name: ${item.name}',
                fontType: FontType.titleLarge,
                weight: FontWeight.bold,
              ),
            ],
          ),
        );
      }),
    );
  }
}
