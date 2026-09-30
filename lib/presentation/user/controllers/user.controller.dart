import '../../core/base_builder_controller.dart';

/// Contoh controller menggunakan [BaseBuilderController] (GetBuilder pattern).
///
/// Berbeda dengan HomeController yang pakai BaseController + Obx (reactive),
/// controller ini menggunakan manual `update()` untuk trigger rebuild.
///
/// Di UI, wrap widget dengan `GetBuilder<UserController>(builder: ...)`.
class UserController extends BaseBuilderController {
  // ── State (plain variables, tanpa .obs) ──
  List<Map<String, String>> users = [];
  String searchQuery = '';
  int selectedIndex = -1;

  // ── Contoh ID untuk targeted update ──
  static const String listId = 'user_list';
  static const String searchId = 'user_search';

  @override
  void onInit() {
    super.onInit();
    _loadDummyUsers();
  }

  /// Simulate loading data
  Future<void> _loadDummyUsers() async {
    isLoading = true;
    update();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    users = [
      {
        'name': 'Ahmad Zidan',
        'role': 'Mobile Developer',
        'avatar': 'https://i.pravatar.cc/150?img=1',
      },
      {
        'name': 'Siti Rahma',
        'role': 'UI/UX Designer',
        'avatar': 'https://i.pravatar.cc/150?img=5',
      },
      {
        'name': 'Budi Santoso',
        'role': 'Backend Engineer',
        'avatar': 'https://i.pravatar.cc/150?img=3',
      },
      {
        'name': 'Dewi Lestari',
        'role': 'Product Manager',
        'avatar': 'https://i.pravatar.cc/150?img=9',
      },
      {
        'name': 'Raka Pratama',
        'role': 'DevOps Engineer',
        'avatar': 'https://i.pravatar.cc/150?img=7',
      },
      {
        'name': 'Maya Putri',
        'role': 'QA Engineer',
        'avatar': 'https://i.pravatar.cc/150?img=10',
      },
    ];
    isLoading = false;
    update();
  }

  /// Filter users berdasarkan search query — hanya rebuild list, bukan seluruh UI
  void onSearch(String query) {
    searchQuery = query;
    update([listId]); // Targeted update — hanya widget dengan id 'user_list'
  }

  /// Get filtered users
  List<Map<String, String>> get filteredUsers {
    if (searchQuery.isEmpty) return users;
    return users
        .where(
          (u) =>
              u['name']!.toLowerCase().contains(searchQuery.toLowerCase()) ||
              u['role']!.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
  }

  /// Select user — hanya rebuild list
  void selectUser(int index) {
    selectedIndex = index;
    update([listId]);
  }

  /// Refresh data
  void refreshData() {
    users.clear();
    searchQuery = '';
    selectedIndex = -1;
    _loadDummyUsers();
  }
}
