---
name: Entity (Domain)
description: Rules and templates for creating pure domain Entities
---
# Skill: Entity (Domain Layer)

An Entity is a pure business object representation without any dependencies. Located in the Domain layer.

---

## Entity Rules

1. **MUST NOT** import any packages: Flutter, Dio, GetX, storage, json packages, etc.
2. Only contains fields, constructors, and pure business methods.
3. Always located in `lib/domain/{feature}/entities/{feature}_entity.dart`
4. Class name: `{Feature}Entity`

---

## Basic Template

```dart
// lib/domain/product/entities/product_entity.dart

class ProductEntity {
  final String id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final bool isActive;
  final DateTime? createdAt;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.isActive,
    this.createdAt,
  });
}
```

---

## Template with Business Methods

Entities can have methods if the logic is pure (no I/O needed):

```dart
class OrderEntity {
  final String id;
  final List<OrderItemEntity> items;
  final double discount;
  final String status;

  const OrderEntity({
    required this.id,
    required this.items,
    required this.discount,
    required this.status,
  });

  // Pure business methods — no services/packages needed
  double get subtotal => items.fold(0, (sum, item) => sum + item.total);
  double get total => subtotal - discount;
  bool get isPaid => status == 'paid';
  bool get isCancelable => status == 'pending';
}
```

---

## Entity List Template (Nested)

```dart
class OrderItemEntity {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  const OrderItemEntity({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  double get total => quantity * price;
}
```

---

## Real Example in Codebase

```dart
// lib/domain/auth/entities/user_entity.dart
class UserEntity {
  final String roleId;
  final String roleName;
  final String appsId;
  final String permissionToken;
  final String accessToken;
  final String refreshToken;

  UserEntity({
    required this.roleId,
    required this.roleName,
    required this.appsId,
    required this.permissionToken,
    required this.accessToken,
    required this.refreshToken,
  });
}

// lib/domain/home/entities/banner_entity.dart
class BannerEntity {
  final String id;
  final String bannerUrl;
  final String title;

  BannerEntity({
    required this.id,
    required this.bannerUrl,
    required this.title,
  });
}
```

---

## Checklist

```
[ ] File in lib/domain/{feature}/entities/{feature}_entity.dart
[ ] Class name: {Feature}Entity
[ ] No external package imports
[ ] All fields are final
[ ] Constructor uses named params + required
[ ] Nullable fields use ? (only if genuinely optional from the API)
```
