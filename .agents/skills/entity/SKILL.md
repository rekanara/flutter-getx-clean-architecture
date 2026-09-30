# Skill: Entity (Domain Layer)

Entity adalah representasi objek bisnis murni tanpa dependency apapun. Berada di layer Domain.

---

## Aturan Entity

1. **TIDAK boleh** import package: Flutter, Dio, GetX, storage, json package, dll.
2. Hanya berisi field, constructor, dan method bisnis murni.
3. Selalu di `lib/domain/{feature}/entities/{feature}_entity.dart`
4. Nama class: `{Feature}Entity`

---

## Template Dasar

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

## Template dengan Method Bisnis

Entity boleh punya method jika logic bersifat murni (tidak perlu I/O):

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

  // Method bisnis murni — tidak perlu service/package
  double get subtotal => items.fold(0, (sum, item) => sum + item.total);
  double get total => subtotal - discount;
  bool get isPaid => status == 'paid';
  bool get isCancelable => status == 'pending';
}
```

---

## Template Entity List (Nested)

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

## Contoh Nyata di Codebase

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
[ ] File di lib/domain/{feature}/entities/{feature}_entity.dart
[ ] Class name: {Feature}Entity
[ ] Tidak ada import package eksternal
[ ] Semua field final
[ ] Constructor menggunakan named params + required
[ ] Nullable field menggunakan ? (hanya jika memang opsional dari API)
```
