import 'package:flutter/material.dart';
import '../atoms/custom_text.dart';
import '../../utils/config.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    this.title = 'No Data Available',
    this.subtitle = 'There is nothing to show here at the moment.',
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            CustomText(
              text: title,
              fontType: FontType.titleMedium,
              weight: FontWeight.bold,
            ),
            const SizedBox(height: 8),
            CustomText(
              text: subtitle,
              fontType: FontType.bodyMedium,
              color: Colors.grey,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
