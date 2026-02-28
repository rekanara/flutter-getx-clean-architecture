import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/atoms/custom_text.dart';
import '../../components/molecules/custom_cached_image.dart';
import '../../utils/config.dart';
import '../../utils/responsive.dart';
import 'controllers/user.controller.dart';

class UserScreen extends GetView<UserController> {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(
            context.responsive(mobile: 16, tablet: 24, desktop: 32),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ── Header ──
              CustomText(
                text: 'Responsive Demo',
                fontType: FontType.headlineSmall,
              ),
              const SizedBox(height: 4),
              CustomText(
                text: 'Resize window untuk melihat perubahan layout.',
                fontType: FontType.bodyMedium,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),

              /// ── Responsive Grid ──
              Expanded(
                child: Responsive(
                  // ── Mobile: List vertikal ──
                  mobile: _buildList(context),

                  // ── Tablet: Grid 2 kolom ──
                  tablet: _buildGrid(context, crossAxisCount: 2),

                  // ── Desktop: Grid 3 kolom ──
                  desktop: _buildGrid(context, crossAxisCount: 3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Layout Mobile — tampilan list satu kolom
  Widget _buildList(BuildContext context) {
    return ListView.separated(
      itemCount: _dummyUsers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = _dummyUsers[index];
        return _UserCard(user: user, isCompact: true);
      },
    );
  }

  /// Layout Tablet/Desktop — tampilan grid multi-kolom
  Widget _buildGrid(BuildContext context, {required int crossAxisCount}) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: context.responsive(
          mobile: 1,
          tablet: 0.85,
          desktop: 0.9,
        ),
      ),
      itemCount: _dummyUsers.length,
      itemBuilder: (context, index) {
        final user = _dummyUsers[index];
        return _UserCard(user: user, isCompact: false);
      },
    );
  }
}

// ─── User Card ────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  final _DummyUser user;
  final bool isCompact;

  const _UserCard({required this.user, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      // ── Compact (Mobile) — horizontal card ──
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CustomCachedImage(
                imageUrl: user.avatarUrl,
                width: 56,
                height: 56,
                borderRadius: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(text: user.name, fontType: FontType.titleMedium),
                    const SizedBox(height: 2),
                    CustomText(
                      text: user.role,
                      fontType: FontType.bodySmall,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      );
    }

    // ── Expanded (Tablet/Desktop) — vertical card ──
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomCachedImage(
              imageUrl: user.avatarUrl,
              width: 80,
              height: 80,
              borderRadius: 40,
            ),
            const SizedBox(height: 12),
            CustomText(text: user.name, fontType: FontType.titleMedium),
            const SizedBox(height: 4),
            CustomText(
              text: user.role,
              fontType: FontType.bodySmall,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            CustomText(
              text: user.email,
              fontType: FontType.bodySmall,
              color: Colors.blueGrey,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dummy Data ───────────────────────────────────────────────

class _DummyUser {
  final String name;
  final String role;
  final String email;
  final String avatarUrl;

  const _DummyUser({
    required this.name,
    required this.role,
    required this.email,
    required this.avatarUrl,
  });
}

final List<_DummyUser> _dummyUsers = [
  _DummyUser(
    name: 'Ahmad Zidan',
    role: 'Mobile Developer',
    email: 'zidan@example.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=1',
  ),
  _DummyUser(
    name: 'Siti Rahma',
    role: 'UI/UX Designer',
    email: 'siti@example.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=5',
  ),
  _DummyUser(
    name: 'Budi Santoso',
    role: 'Backend Engineer',
    email: 'budi@example.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=3',
  ),
  _DummyUser(
    name: 'Dewi Lestari',
    role: 'Product Manager',
    email: 'dewi@example.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=9',
  ),
  _DummyUser(
    name: 'Raka Pratama',
    role: 'DevOps Engineer',
    email: 'raka@example.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=7',
  ),
  _DummyUser(
    name: 'Maya Putri',
    role: 'QA Engineer',
    email: 'maya@example.com',
    avatarUrl: 'https://i.pravatar.cc/150?img=10',
  ),
];
