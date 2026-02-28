import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/atoms/custom_text.dart';
import '../../components/molecules/custom_cached_image.dart';
import '../../utils/config.dart';
import 'controllers/user.controller.dart';

/// Contoh screen menggunakan [GetBuilder] (manual update pattern).
///
/// Bandingkan dengan HomeScreen yang menggunakan [Obx] (reactive pattern).
class UserScreen extends GetView<UserController> {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users (GetBuilder)'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshData,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search Bar ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari user...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: controller.onSearch,
            ),
          ),

          // ── User List (GetBuilder — hanya rebuild bagian ini) ──
          Expanded(
            child: GetBuilder<UserController>(
              builder: (c) {
                // Loading state
                if (c.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Empty state
                if (c.filteredUsers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 8),
                        CustomText(
                          text: 'User tidak ditemukan',
                          fontType: FontType.bodyMedium,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  );
                }

                // User List
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: c.filteredUsers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final user = c.filteredUsers[index];
                    final isSelected = c.selectedIndex == index;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        leading: CustomCachedImage(
                          imageUrl: user['avatar']!,
                          width: 48,
                          height: 48,
                          borderRadius: 24,
                        ),
                        title: CustomText(
                          text: user['name']!,
                          fontType: FontType.titleMedium,
                        ),
                        subtitle: CustomText(
                          text: user['role']!,
                          fontType: FontType.bodySmall,
                          color: Colors.grey,
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : Icon(
                                Icons.circle_outlined,
                                color: Colors.grey.shade300,
                              ),
                        onTap: () => c.selectUser(index),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
