/// Domain-safe wrapper for paginated results from repository.
///
/// Unlike `ApiResponse`/`PaginationMeta` (infrastructure/dal/models) —
/// this class is pure Dart without any dependencies, making it safe to use across
/// domain contracts (`{feature}_repository.dart`, `{action}_{feature}_usecase.dart`).
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
