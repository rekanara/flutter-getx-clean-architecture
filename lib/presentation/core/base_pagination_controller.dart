import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'base_controller.dart';

/// Base Controller specifically for handling Pagination and Infinite Scroll.
///
/// Usage:
/// 1. `class MyController extends BasePaginationController<MyModel>`
/// 2. Override `fetchPage(int page)` method
/// 3. Call `appendData(newItems: data, lastPage: meta.lastPage)` on success.
/// 4. Connect `scrollController` to `ListView` or `GridView`.
abstract class BasePaginationController<T> extends BaseController {
  /// List of item data displayed in UI
  final RxList<T> items = <T>[].obs;

  /// Data limit per page (default 15)
  int limit = 15;

  int _currentPage = 1;
  int _lastPage = 1;

  /// Special state for loading the next page (bottom loading indicator)
  final RxBool isLoadMore = false.obs;

  /// Check if it has reached the last page
  bool get hasReachedMax => _currentPage >= _lastPage;

  /// Current active page getter
  int get currentPage => _currentPage;

  /// ScrollController automatically bound to listen to scrolling down
  final ScrollController scrollController = ScrollController();

  /// Default threshold distance in pixels from bottom before triggering fetch next page
  final double scrollThreshold = 200.0;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;

    if (maxScroll - currentScroll <= scrollThreshold) {
      loadNextPage();
    }
  }

  /// Main function that must be overridden in subclass.
  /// Perform API / UseCase calls inside this function.
  ///
  /// Use the built-in `callUseCase` from [BaseController], and if successful,
  /// call `appendData(newItems, lastPage)`.
  Future<void> fetchPage(int page);

  /// Call this function to reset data and fetch page 1 again.
  /// Suitable to be called from [RefreshIndicator].
  Future<void> refreshData() async {
    _currentPage = 1;
    _lastPage = 1;
    errorMessage.value = '';
    items.clear();
    // callUseCase inside fetchPage already handles isLoading automatically
    await fetchPage(1);
  }

  /// Load the next page. Automatically called when scrolling down.
  Future<void> loadNextPage() async {
    if (isLoadMore.value || hasReachedMax || isLoading.value) return;

    isLoadMore.value = true;
    _currentPage++;

    await fetchPage(_currentPage);

    isLoadMore.value = false;
  }

  /// Insert new data from API response into the list.
  /// [newItems] is the list of data models received.
  /// [lastPage] is the total pages from backend pagination meta.
  void appendData({required List<T> newItems, required int lastPage}) {
    _lastPage = lastPage;

    if (_currentPage == 1) {
      items.assignAll(newItems);
    } else {
      items.addAll(newItems);
    }
  }

  /// Check for empty list status (useful for displaying UI empty state)
  bool get isEmpty => !isLoading.value && items.isEmpty;
}
