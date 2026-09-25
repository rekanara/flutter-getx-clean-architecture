import '../../../../domain/contacts/entities/contact_entity.dart';

/// Model contoh yang meng-adapt shape response API eksternal
/// (`firstName`/`lastName`/`image`) ke bentuk domain (`fullName`/`avatarUrl`).
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
