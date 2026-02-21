import '../../../../domain/home/entities/banner_entity.dart';

class BannerModel extends BannerEntity {
  BannerModel({
    required super.id,
    required super.imageUrl,
    required super.title,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id']?.toString() ?? '',
      imageUrl: json['image_url'] ?? '',
      title: json['title'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'image_url': imageUrl, 'title': title};
  }
}
