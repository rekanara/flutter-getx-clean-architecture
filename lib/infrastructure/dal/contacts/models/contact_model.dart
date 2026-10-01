import '../../../../domain/contacts/entities/contact_entity.dart';

/// Example model that adapts external API response shape
/// (`firstName`/`lastName`/`image`) to domain shape (`fullName`/`avatarUrl`).
class ContactModel extends ContactEntity {
  ContactModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.avatarUrl,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    final firstName = json['firstName'] ?? '';
    final lastName = json['lastName'] ?? '';

    return ContactModel(
      id: json['id']?.toString() ?? '',
      fullName: '$firstName $lastName'.trim(),
      email: json['email'] ?? '',
      avatarUrl: json['image'] ?? '',
    );
  }
}
