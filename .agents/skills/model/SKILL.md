---
name: Model (Infrastructure)
description: Creating models extending Entities for JSON serialization
---
# Skill: Model (Infrastructure Layer)

A Model is an implementation of an Entity that adds JSON serialization capabilities. Located in the Infrastructure layer.

---

## Model Rules

1. Always `extends` the Entity from the Domain layer (not implements).
2. Add `factory fromJson(Map<String, dynamic> json)`.
3. Add `Map<String, dynamic> toJson()` if you need to send data to the server.
4. Use `super.fieldName` in the constructor.
5. Location: `lib/infrastructure/dal/{feature}/models/{feature}_model.dart`

---

## Basic Template

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

## Real Example in Codebase

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

## Common Parsing Patterns

```dart
// String
name: json['name'] as String? ?? '',

// Int
count: json['count'] as int? ?? 0,

// Double (num can be int or double from JSON)
price: (json['price'] as num?)?.toDouble() ?? 0.0,

// Bool
isActive: json['is_active'] as bool? ?? false,

// Nullable DateTime from ISO string
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

// id which can be int or string from the server
id: json['id']?.toString() ?? '',
```

---

## Model with Nested List

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
[ ] File in lib/infrastructure/dal/{feature}/models/{feature}_model.dart
[ ] Class uses `extends` (not implements)
[ ] Constructor uses `super.field` for entity fields
[ ] factory fromJson() exists
[ ] All nullable fields are given a default value (not null) if the field is required in the entity
[ ] id is always cast with toString() because the server might send int or string
[ ] toJson() exists if there is a POST/PUT operation
```
