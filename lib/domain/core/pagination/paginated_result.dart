/// Domain-safe wrapper untuk hasil paginated dari repository.
///
/// Beda dengan `ApiResponse`/`PaginationMeta` (infrastructure/dal/models) —
/// class ini pure Dart tanpa dependency apapun, jadi aman dipakai lintas
/// domain contract (`{feature}_repository.dart`, `{action}_{feature}_usecase.dart`).
class PaginatedResult<T> {
  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int total;

  const PaginatedResult({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  bool get hasReachedMax => currentPage >= lastPage;
}
