import 'dart:async';

import '../../../domain/contacts/entities/contact_entity.dart';
import '../../../domain/contacts/usecases/get_contacts_usecase.dart';
import '../../core/base_pagination_controller.dart';

/// Contoh controller pagination nyata — lihat juga
/// `.agents/skills/controller-pagination/SKILL.md`.
class ContactsController extends BasePaginationController<ContactEntity> {
  final GetContactsUseCase getContactsUseCase;

  ContactsController({required this.getContactsUseCase});

  String _search = '';
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    fetchPage(1);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  @override
  Future<void> fetchPage(int page) async {
    await callUseCase(
      getContactsUseCase.execute(
        GetContactsParams(
          page: page,
          limit: limit,
          search: _search.isEmpty ? null : _search,
        ),
      ),
      onSuccess: (result) {
        appendData(newItems: result.items, lastPage: result.lastPage);
      },
    );
  }

  /// Dipanggil dari search field — di-debounce supaya tidak fetch tiap ketikan.
  void onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _search = query;
      refreshData();
    });
  }
}
