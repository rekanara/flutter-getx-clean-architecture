# Skill: Controller Builder (BaseBuilderController + GetBuilder)

Pattern alternatif yang menggunakan state biasa (bukan .obs) dan manual `update()` untuk trigger rebuild widget tertentu.

---

## Kapan Digunakan

Gunakan `BaseBuilderController` ketika:
- Perlu kontrol granular: update hanya sebagian widget (by ID)
- State adalah plain Dart (`bool`, `String`, `List`) — tidak perlu `.obs`
- Contoh nyata: filter/search list yang hanya update bagian list, bukan keseluruhan screen
- Lebih efisien untuk kasus di mana update hanya terjadi di satu widget tertentu

---

## BaseBuilderController API

```dart
// lib/presentation/core/base_builder_controller.dart
abstract class BaseBuilderController extends GetxController {
  bool isLoading = false;
  String errorMessage = '';

  Future<void> callUseCase<T>(
    Future<Either<Failure, T>> call, {
    required Function(T) onSuccess,
    Function(Failure)? onFailure,
    bool showLoading = true,
    Object? id,  // jika diisi, hanya widget dengan ID ini yang rebuild
  });
}
```

---

## Template Controller

```dart
// lib/presentation/user/controllers/user.controller.dart
import 'package:get/get.dart';
import '../../core/base_builder_controller.dart';

class UserController extends BaseBuilderController {
  // Plain Dart (tidak .obs)
  List<Map<String, String>> users = [];
  int selectedIndex = -1;

  // ID untuk update target (optional tapi recommended)
  static const listId = 'user_list';
  static const detailId = 'user_detail';

  @override
  void onInit() {
    super.onInit();
    _loadUsers();
  }

  void _loadUsers() {
    users = [
      {'name': 'Alice', 'role': 'Admin'},
      {'name': 'Bob', 'role': 'User'},
    ];
    update([listId]); // update hanya widget list
  }

  void onSearch(String query) {
    if (query.isEmpty) {
      _loadUsers();
    } else {
      users = users.where((u) => u['name']!.contains(query)).toList();
      update([listId]);
    }
  }

  void selectUser(int index) {
    selectedIndex = index;
    update([listId, detailId]); // update list + detail
  }
}
```

---

## Contoh Nyata di Codebase

```dart
// lib/presentation/user/controllers/user.controller.dart (actual)
class UserController extends BaseBuilderController {
  List<Map<String, String>> users = [
    {'name': 'Alice Johnson', 'role': 'Admin', 'email': 'alice@example.com'},
    {'name': 'Bob Smith', 'role': 'Developer', 'email': 'bob@example.com'},
    // ...
  ];

  List<Map<String, String>> filteredUsers = [];
  int selectedUserIndex = -1;
  static const listId = 'user_list';

  @override
  void onInit() {
    super.onInit();
    filteredUsers = List.from(users);
  }

  void onSearch(String query) {
    filteredUsers = query.isEmpty
        ? List.from(users)
        : users.where((u) => u['name']!.toLowerCase().contains(query.toLowerCase())).toList();
    update([listId]);
  }

  void selectUser(int index) {
    selectedUserIndex = index;
    update([listId]);
  }
}
```

---

## Di UI: GetBuilder

```dart
// lib/presentation/user/user.screen.dart
class UserScreen extends GetView<UserController> {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: TextField(
            onChanged: controller.onSearch, // update via update()
          ),
        ),
      ),
      body: GetBuilder<UserController>(
        id: UserController.listId,  // hanya rebuild saat listId di-update
        builder: (c) {
          if (c.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (c.filteredUsers.isEmpty) {
            return const Center(child: Text('No users'));
          }
          return ListView.builder(
            itemCount: c.filteredUsers.length,
            itemBuilder: (context, index) {
              final user = c.filteredUsers[index];
              return ListTile(
                title: Text(user['name']!),
                subtitle: Text(user['role']!),
                selected: c.selectedUserIndex == index,
                onTap: () => c.selectUser(index),
              );
            },
          );
        },
      ),
    );
  }
}
```

---

## GetBuilder tanpa ID (rebuild semua)

```dart
GetBuilder<UserController>(
  builder: (c) {
    // Rebuild saat update() dipanggil tanpa ID
    return Text(c.isLoading ? 'Loading...' : 'Done');
  },
)
```

## GetBuilder dengan ID

```dart
GetBuilder<UserController>(
  id: 'my_widget_id',  // hanya rebuild saat update(['my_widget_id']) dipanggil
  builder: (c) => ...,
)
```

---

## Perbandingan dengan BaseController

| | BaseController + Obx | BaseBuilderController + GetBuilder |
|---|---|---|
| State | `.obs` (Rx types) | Plain Dart (bool, List, dll) |
| Update | Otomatis | Manual `update([ids])` |
| Granularity | Per observable | Per widget ID |
| Kompleksitas | Lebih simpel | Lebih kontrol |
| Gunakan saat | Default, state sering berubah | Filter/search, update targeted |

---

## Checklist

```
[ ] Class extends BaseBuilderController
[ ] State adalah plain Dart (TIDAK .obs)
[ ] Setiap perubahan state panggil update() atau update([ids])
[ ] Gunakan static const untuk widget IDs
[ ] Di UI: GetBuilder<T>(id: T.listId, builder: ...)
[ ] onInit() panggil super.onInit()
```
