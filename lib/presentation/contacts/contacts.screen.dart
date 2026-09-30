import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/atoms/custom_text.dart';
import '../../components/atoms/custom_text_field.dart';
import '../../components/molecules/custom_cached_image.dart';
import '../../components/molecules/pagination_list_view.dart';
import '../../domain/contacts/entities/contact_entity.dart';
import '../../utils/config.dart';
import 'controllers/contacts.controller.dart';

/// Contoh nyata end-to-end: Entity -> Repository -> UseCase -> Model ->
/// ApiService -> RepositoryImpl -> Binding -> Controller (pagination) ->
/// Screen (PaginationListView). Lihat `.agents/skills/new-feature/SKILL.md`.
class ContactsScreen extends GetView<ContactsController> {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          text: 'Contacts (Pagination Demo)',
          fontType: FontType.titleLarge,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomTextField(
              hintText: 'Cari nama atau email...',
              prefixIcon: const Icon(Icons.search),
              onChanged: controller.onSearchChanged,
            ),
          ),
          Expanded(
            child: PaginationListView<ContactEntity>(
              controller: controller,
              emptyMessage: 'Contact tidak ditemukan',
              itemBuilder: (context, contact, index) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  leading: CustomCachedImage(
                    imageUrl: contact.avatarUrl,
                    width: 44,
                    height: 44,
                    borderRadius: 22,
                  ),
                  title: CustomText(
                    text: contact.fullName,
                    fontType: FontType.titleSmall,
                  ),
                  subtitle: CustomText(
                    text: contact.email,
                    fontType: FontType.bodySmall,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
