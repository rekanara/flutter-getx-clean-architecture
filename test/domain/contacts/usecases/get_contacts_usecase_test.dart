import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:zidanfath_codebase/domain/contacts/entities/contact_entity.dart';
import 'package:zidanfath_codebase/domain/contacts/repositories/contacts_repository.dart';
import 'package:zidanfath_codebase/domain/contacts/usecases/get_contacts_usecase.dart';
import 'package:zidanfath_codebase/domain/core/errors/failures.dart';
import 'package:zidanfath_codebase/domain/core/pagination/paginated_result.dart';

import 'get_contacts_usecase_test.mocks.dart';

@GenerateMocks([ContactsRepository])
void main() {
  late GetContactsUseCase useCase;
  late MockContactsRepository mockRepository;

  setUp(() {
    mockRepository = MockContactsRepository();
    useCase = GetContactsUseCase(mockRepository);
  });

  final tContacts = [
    ContactEntity(
      id: '1',
      fullName: 'Jane Doe',
      email: 'jane@example.com',
      avatarUrl: 'https://img.com/jane.jpg',
    ),
  ];

  group('GetContactsUseCase', () {
    test(
      'should return PaginatedResult when repository call is successful',
      () async {
        // Arrange
        final tResult = PaginatedResult(
          items: tContacts,
          currentPage: 1,
          lastPage: 3,
          total: 30,
        );
        when(
          mockRepository.getContacts(page: 1, limit: 15, search: null),
        ).thenAnswer((_) async => Right(tResult));

        // Act
        final result = await useCase.execute(
          const GetContactsParams(page: 1, limit: 15),
        );

        // Assert
        expect(result, Right(tResult));
        verify(
          mockRepository.getContacts(page: 1, limit: 15, search: null),
        ).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should forward search param to repository', () async {
      // Arrange
      when(
        mockRepository.getContacts(page: 1, limit: 15, search: 'jane'),
      ).thenAnswer(
        (_) async => Right(
          PaginatedResult(
            items: tContacts,
            currentPage: 1,
            lastPage: 1,
            total: 1,
          ),
        ),
      );

      // Act
      await useCase.execute(
        const GetContactsParams(page: 1, limit: 15, search: 'jane'),
      );

      // Assert
      verify(
        mockRepository.getContacts(page: 1, limit: 15, search: 'jane'),
      ).called(1);
    });

    test('should return ServerFailure when repository call fails', () async {
      // Arrange
      final failure = ServerFailure('Network Error');
      when(
        mockRepository.getContacts(page: 1, limit: 15, search: null),
      ).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.execute(
        const GetContactsParams(page: 1, limit: 15),
      );

      // Assert
      expect(result, Left(failure));
    });
  });
}
