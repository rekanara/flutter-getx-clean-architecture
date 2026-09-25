import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:zidanfath_codebase/domain/contacts/entities/contact_entity.dart';
import 'package:zidanfath_codebase/domain/contacts/repositories/contacts_repository.dart';
import 'package:zidanfath_codebase/domain/contacts/usecases/get_contacts_usecase.dart';
import 'package:zidanfath_codebase/domain/core/errors/failures.dart';
import 'package:zidanfath_codebase/domain/core/pagination/paginated_result.dart';
import 'package:zidanfath_codebase/presentation/contacts/controllers/contacts.controller.dart';

import 'contacts_controller_test.mocks.dart';

@GenerateMocks([ContactsRepository])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockContactsRepository mockRepository;
  late ContactsController controller;

  ContactEntity contact(String id) => ContactEntity(
    id: id,
    fullName: 'User $id',
    email: 'user$id@mail.com',
    avatarUrl: 'https://img.test/$id.png',
  );

  PaginatedResult<ContactEntity> pageResult(
    List<ContactEntity> items,
    int lastPage,
  ) => PaginatedResult(
    items: items,
    currentPage: 1,
    lastPage: lastPage,
    total: items.length,
  );

  setUp(() {
    Get.testMode = true;
    mockRepository = MockContactsRepository();
    controller = ContactsController(
      getContactsUseCase: GetContactsUseCase(mockRepository),
    );
  });

  tearDown(() {
    controller.onClose();
    Get.reset();
  });

  group('ContactsController (BasePaginationController)', () {
    test('initial fetch populates items and clears loading state', () async {
      when(
        mockRepository.getContacts(
          page: 1,
          limit: 15,
          search: anyNamed('search'),
        ),
      ).thenAnswer(
        (_) async => Right(pageResult([contact('1'), contact('2')], 3)),
      );

      controller.onInit();
      await pumpEventQueue();

      expect(controller.items.length, 2);
      expect(controller.isLoading.value, isFalse);
      expect(controller.errorMessage.value, isEmpty);
      expect(controller.hasReachedMax, isFalse);
      expect(controller.isEmpty, isFalse);
    });

    test('loadNextPage appends items and stops at last page', () async {
      when(
        mockRepository.getContacts(
          page: 1,
          limit: 15,
          search: anyNamed('search'),
        ),
      ).thenAnswer((_) async => Right(pageResult([contact('1')], 2)));
      when(
        mockRepository.getContacts(
          page: 2,
          limit: 15,
          search: anyNamed('search'),
        ),
      ).thenAnswer(
        (_) async => Right(pageResult([contact('2'), contact('3')], 2)),
      );

      controller.onInit();
      await pumpEventQueue();

      await controller.loadNextPage();

      expect(controller.items.length, 3);
      expect(controller.hasReachedMax, isTrue);
      expect(controller.isLoadMore.value, isFalse);

      // Guard: setelah last page, loadNextPage tidak boleh fetch lagi.
      await controller.loadNextPage();
      verifyNever(
        mockRepository.getContacts(
          page: 3,
          limit: 15,
          search: anyNamed('search'),
        ),
      );
    });

    test('failure sets errorMessage and leaves items empty', () async {
      when(
        mockRepository.getContacts(
          page: 1,
          limit: 15,
          search: anyNamed('search'),
        ),
      ).thenAnswer((_) async => Left(ServerFailure('Network down')));

      controller.onInit();
      await pumpEventQueue();

      expect(controller.errorMessage.value, 'Network down');
      expect(controller.items, isEmpty);
      expect(controller.isLoading.value, isFalse);
    });

    test('empty page 1 results in empty state', () async {
      when(
        mockRepository.getContacts(
          page: 1,
          limit: 15,
          search: anyNamed('search'),
        ),
      ).thenAnswer((_) async => Right(pageResult(<ContactEntity>[], 1)));

      controller.onInit();
      await pumpEventQueue();

      expect(controller.items, isEmpty);
      expect(controller.isEmpty, isTrue);
    });

    test('refreshData resets list and re-fetches page 1', () async {
      when(
        mockRepository.getContacts(
          page: 1,
          limit: 15,
          search: anyNamed('search'),
        ),
      ).thenAnswer((_) async => Right(pageResult([contact('1')], 1)));

      controller.onInit();
      await pumpEventQueue();

      await controller.refreshData();

      // assignAll (bukan addAll) — jumlah tetap, bukan duplikat.
      expect(controller.items.length, 1);
      verify(
        mockRepository.getContacts(
          page: 1,
          limit: 15,
          search: anyNamed('search'),
        ),
      ).called(2);
    });
  });
}
