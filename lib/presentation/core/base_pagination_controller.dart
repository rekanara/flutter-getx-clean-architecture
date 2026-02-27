import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'base_controller.dart';

/// Base Controller khusus untuk menangani Pagination dan Infinite Scroll.
///
/// Cara pakai:
/// 1. `class MyController extends BasePaginationController<MyModel>`
/// 2. Override method `fetchPage(int page)`
/// 3. Panggil `appendData(newItems: data, lastPage: meta.lastPage)` saat success.
/// 4. Hubungkan `scrollController` ke `ListView` atau `GridView`.
abstract class BasePaginationController<T> extends BaseController {
  /// List item data yang ditampilkan di UI
  final RxList<T> items = <T>[].obs;

  /// Limit data per halaman (default 15)
  int limit = 15;

  int _currentPage = 1;
  int _lastPage = 1;

  /// State khusus untuk loading halaman berikutnya (bottom loading indicator)
  final RxBool isLoadMore = false.obs;

  /// Cek apakah sudah mencapai halaman terakhir
  bool get hasReachedMax => _currentPage >= _lastPage;

  /// Current active page getter
  int get currentPage => _currentPage;

  /// ScrollController otomatis bind untuk mendengarkan scroll ke bawah
  final ScrollController scrollController = ScrollController();

  /// Default threshold jarak pixels dari bawah sebelum trigger fetch next page
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

  /// Fungsi utama yang harus di-override di subclass.
  /// Lakukan pemanggilan API / UseCase di dalam fungsi ini.
  ///
  /// Gunakan `callUseCase` bawaan [BaseController], dan jika success,
  /// panggil `appendData(newItems, lastPage)`.
  Future<void> fetchPage(int page);

  /// Panggil fungsi ini untuk me-reset data dan mengambil halaman 1 kembali.
  /// Cocok dipanggil dari [RefreshIndicator].
  Future<void> refreshData() async {
    _currentPage = 1;
    _lastPage = 1;

    // Set isLoading menjadi true untuk show skeleton/loading awal
    isLoading.value = true;
    errorMessage.value = '';

    await fetchPage(_currentPage);

    // BaseController callUseCase biasanya meng-handle isLoading,
    // tapi kita pastikan ulang di sini jika fetchPage tidak pakai callUseCase
    isLoading.value = false;
  }

  /// Memuat halaman berikutnya. Otomatis dipanggil saat di-scroll ke bawah.
  Future<void> loadNextPage() async {
    if (isLoadMore.value || hasReachedMax || isLoading.value) return;

    isLoadMore.value = true;
    _currentPage++;

    await fetchPage(_currentPage);

    isLoadMore.value = false;
  }

  /// Sisipkan data baru dari response API ke dalam list.
  /// [newItems] adalah list data model yang didapat.
  /// [lastPage] adalah total halaman dari meta pagination backend.
  void appendData({required List<T> newItems, required int lastPage}) {
    _lastPage = lastPage;

    if (_currentPage == 1) {
      items.assignAll(newItems);
    } else {
      items.addAll(newItems);
    }
  }

  /// Pengecekan status list kosong (berguna untuk menampilkan UI empty state)
  bool get isEmpty => !isLoading.value && items.isEmpty;
}
