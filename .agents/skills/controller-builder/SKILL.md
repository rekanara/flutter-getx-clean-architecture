---
name: Controller Builder
description: Alternative pattern using plain state and manual update() with GetBuilder
---
# Skill: Controller Builder (BaseBuilderController + GetBuilder)

Alternative pattern that uses plain state (not `.obs`) and manual `update()` to trigger targeted widget rebuilds.

---

## When to Use

Use `BaseBuilderController` when:
- Granular control is needed: update only a specific widget (by ID)
- State is plain Dart (`bool`, `String`, `List`) — no need for `.obs`
- Real example: filter/search list that only updates the list part, not the entire screen
- More efficient for cases where updates only happen in a specific widget

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
    Object? id,  // if provided, only widgets with this ID will rebuild
  });
}
```

---

## Controller Template

```dart
// lib/presentation/user/controllers/user.controller.dart
import 'package:get/get.dart';
import '../../core/base_builder_controller.dart';

class UserController extends BaseBuilderController {
  // Plain Dart (not .obs)
  List<Map<String, String>> users = [];
  int selectedIndex = -1;

  // ID for targeted updates (optional but recommended)
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
    update([listId]); // update only the list widget
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

## Real Example in Codebase

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

## In UI: GetBuilder

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
            onChanged: controller.onSearch, // updates via update()
          ),
        ),
      ),
      body: GetBuilder<UserController>(
        id: UserController.listId,  // only rebuilds when listId is updated
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

## GetBuilder without ID (rebuilds all)

```dart
GetBuilder<UserController>(
  builder: (c) {
    // Rebuilds when update() is called without an ID
    return Text(c.isLoading ? 'Loading...' : 'Done');
  },
)
```

## GetBuilder with ID

```dart
GetBuilder<UserController>(
  id: 'my_widget_id',  // only rebuilds when update(['my_widget_id']) is called
  builder: (c) => ...,
)
```

---

## Comparison with BaseController

| | BaseController + Obx | BaseBuilderController + GetBuilder |
|---|---|---|
| State | `.obs` (Rx types) | Plain Dart (bool, List, etc.) |
| Update | Automatic | Manual `update([ids])` |
| Granularity | Per observable | Per widget ID |
| Complexity | Simpler | More control |
| Use when | Default, state changes frequently | Filter/search, targeted updates |

---

## Checklist

```
[ ] Class extends BaseBuilderController
[ ] State is plain Dart (NOT .obs)
[ ] Every state change calls update() or update([ids])
[ ] Use static const for widget IDs
[ ] In UI: GetBuilder<T>(id: T.listId, builder: ...)
[ ] onInit() calls super.onInit()
```
