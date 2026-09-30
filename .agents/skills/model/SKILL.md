# Skill: Model (Infrastructure Layer)

Model adalah implementasi Entity yang menambahkan kemampuan JSON serialization. Berada di Infrastructure layer.

---

## Aturan Model

1. Selalu `extends` Entity dari Domain layer (bukan implements)
2. Tambahkan `factory fromJson(Map<String, dynamic> json)`
3. Tambahkan `Map<String, dynamic> toJson()` jika perlu kirim data ke server
4. Gunakan `super.fieldName` di constructor
5. Lokasi: `lib/infrastructure/dal/{feature}/models/{feature}_model.dart`

---

## Template Dasar

```dart
// lib/infrastructure/dal/product/models/product_model.dart
import '../../../../domain/product/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.price,
    required super.description,
    required super.imageUrl,
    required super.isActive,
    super.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'image_url': imageUrl,
      'is_active': isActive,
    };
  }
}
```

---

## Contoh Nyata di Codebase

```dart
// lib/infrastructure/dal/auth/models/user_model.dart
class UserModel extends UserEntity {
  UserModel({
    required super.roleId,
    required super.roleName,
    required super.appsId,
    required super.permissionToken,
    required super.accessToken,
    required super.refreshToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      roleId: json['role']?['id']?.toString() ?? '',   // nested object
      roleName: json['role']?['name'] ?? '',            // nested object
      appsId: json['apps_id']?.toString() ?? '',
      permissionToken: json['permission_token'] ?? '',
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
    );
  }
}

// lib/infrastructure/dal/home/models/banner_model.dart
class BannerModel extends BannerEntity {
  BannerModel({
    required super.id,
    required super.bannerUrl,
    required super.title,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id']?.toString() ?? '',
      bannerUrl: json['banner_url'] ?? '',
      title: json['title'] ?? '',
    );
  }
}
```

---

## Pattern Parsing Umum

```dart
// String
name: json['name'] as String? ?? '',

// Int
count: json['count'] as int? ?? 0,

// Double (num dapat menjadi int atau double dari JSON)
price: (json['price'] as num?)?.toDouble() ?? 0.0,

// Bool
isActive: json['is_active'] as bool? ?? false,

// Nullable DateTime dari ISO string
createdAt: json['created_at'] != null
    ? DateTime.tryParse(json['created_at'])
    : null,

// Nested object
roleId: json['role']?['id']?.toString() ?? '',

// List of nested objects
items: (json['items'] as List?)
    ?.map((e) => OrderItemModel.fromJson(e))
    .toList() ?? [],

// Enum from string
status: OrderStatus.values.firstWhere(
  (e) => e.name == json['status'],
  orElse: () => OrderStatus.pending,
),

// id yang bisa int atau string dari server
id: json['id']?.toString() ?? '',
```

---

## Model dengan List Nested

```dart
class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.items,
    required super.total,
    required super.status,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      items: (json['items'] as List?)
          ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((e) => (e as OrderItemModel).toJson()).toList(),
      'total': total,
      'status': status,
    };
  }
}
```

---

## Checklist

```
[ ] File di lib/infrastructure/dal/{feature}/models/{feature}_model.dart
[ ] Class menggunakan `extends` (bukan implements)
[ ] Constructor menggunakan `super.field` untuk field entity
[ ] factory fromJson() ada
[ ] Semua field nullable diberi default value (bukan null) jika field required di entity
[ ] id selalu di-toString() karena server bisa kirim int atau string
[ ] toJson() ada jika ada operasi POST/PUT
```
