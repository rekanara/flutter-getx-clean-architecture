import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../presentation/core/base_pagination_controller.dart';

/// Reusable widget to display a paginated list with infinite scroll.
///
/// Automatically connects to [BasePaginationController] and provides:
/// - Pull to refresh
/// - Loading state (initial)
/// - Empty state
/// - Bottom loading indicator (load more)
/// - Error state
///
/// **Usage:**
/// ```dart
/// PaginationListView<BannerModel>(
///   controller: controller, // extends BasePaginationController<BannerModel>
///   itemBuilder: (context, item, index) => BannerCard(banner: item),
///   emptyMessage: 'No banners yet',
/// )
/// ```
class PaginationListView<T> extends StatelessWidget {
  /// Controller that extends [BasePaginationController]
  final BasePaginationController<T> controller;

  /// Builder for each item in the list
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Builder for separator between items (optional)
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  /// Message displayed when list is empty
  final String emptyMessage;

  /// Icon displayed when list is empty
  final IconData emptyIcon;

  /// Custom widget for initial loading state
  final Widget? loadingWidget;

  /// Custom widget for empty state
  final Widget? emptyWidget;

  /// Padding around the list
  final EdgeInsets padding;

  /// Scroll physics
  final ScrollPhysics? physics;

  /// Whether the list can be pulled to refresh
  final bool enableRefresh;

  const PaginationListView({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.separatorBuilder,
    this.emptyMessage = 'Data not found',
    this.emptyIcon = Icons.inbox_outlined,
    this.loadingWidget,
    this.emptyWidget,
    this.padding = const EdgeInsets.all(16),
    this.physics,
    this.enableRefresh = true,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ── Loading State (initial) ──
      if (controller.isLoading.value && controller.items.isEmpty) {
        return loadingWidget ??
            const Center(child: CircularProgressIndicator());
      }

      // ── Error State ──
      if (controller.errorMessage.value.isNotEmpty &&
          controller.items.isEmpty) {
        return _ErrorView(
          message: controller.errorMessage.value,
          onRetry: controller.refreshData,
        );
      }

      // ── Empty State ──
      if (controller.isEmpty) {
        return emptyWidget ??
            _EmptyView(message: emptyMessage, icon: emptyIcon);
      }

      // ── List with infinite scroll ──
      final listView = ListView.separated(
        controller: controller.scrollController,
        physics: physics ?? const AlwaysScrollableScrollPhysics(),
        padding: padding,
        itemCount:
            controller.items.length + (controller.isLoadMore.value ? 1 : 0),
        separatorBuilder:
            separatorBuilder ?? (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          // ── Bottom Loading Indicator ──
          if (index == controller.items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          return itemBuilder(context, controller.items[index], index);
        },
      );

      // ── Pull to Refresh wrapper ──
      if (enableRefresh) {
        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: listView,
        );
      }

      return listView;
    });
  }
}

// ─── Empty State ──────────────────────────────────

class _EmptyView extends StatelessWidget {
  final String message;
  final IconData icon;

  const _EmptyView({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

// ─── Error State ──────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
