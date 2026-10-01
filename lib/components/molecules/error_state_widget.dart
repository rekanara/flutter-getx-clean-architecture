import 'package:flutter/material.dart';
import '../atoms/custom_text.dart';
import '../atoms/custom_button.dart';
import '../../utils/config.dart';

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorStateWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.redAccent),
            const SizedBox(height: 16),
            const CustomText(
              text: 'Oops, something went wrong!',
              fontType: FontType.titleMedium,
              weight: FontWeight.bold,
            ),
            const SizedBox(height: 8),
            CustomText(
              text: message,
              fontType: FontType.bodyMedium,
              color: Colors.grey,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(title: 'Retry', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
