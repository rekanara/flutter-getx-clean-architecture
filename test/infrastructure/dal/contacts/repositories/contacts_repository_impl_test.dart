import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:zidanfath_codebase/domain/core/errors/failures.dart';
import 'package:zidanfath_codebase/infrastructure/dal/contacts/repositories/contacts_repository_impl.dart';
import 'package:zidanfath_codebase/infrastructure/dal/services/contacts_api_service.dart';

import 'contacts_repository_impl_test.mocks.dart';

@GenerateMocks([ContactsApiService])
void main() {
  late MockContactsApiService mockApiService;
  late ContactsRepositoryImpl repository;

  final usersJson = [
    {
      'id': 1,
      'firstName': 'Ayu',
      'lastName': 'Putri',
      'email': 'ayu@mail.com',
      'image': 'https://img.test/ayu.png',
    },
    {
      'id': 2,
      'firstName': 'Budi',
      'lastName': 'Santoso',
      'email': 'budi@mail.com',
      'image': 'https://img.test/budi.png',
    },
  ];

  Response successResponse(Map<String, dynamic> data) => Response(
    requestOptions: RequestOptions(path: '/users'),
    statusCode: 200,
    data: data,
  );

  setUp(() {
    mockApiService = MockContactsApiService();
    repository = ContactsRepositoryImpl(apiService: mockApiService);
  });

  group('ContactsRepositoryImpl.getContacts', () {
    test(
      'returns Right with mapped contacts and computed pagination meta',
      () async {
        when(mockApiService.getContacts(any)).thenAnswer(
          (_) async => successResponse({'users': usersJson, 'total': 30}),
        );

        final result = await repository.getContacts(page: 1, limit: 15);

        result.fold((failure) => fail('Expected Right, got Left: $failure'), (
          result,
        ) {
          expect(result.items.length, 2);
          expect(result.items.first.fullName, 'Ayu Putri');
          expect(result.items.first.email, 'ayu@mail.com');
          expect(result.total, 30);
          expect(result.currentPage, 1);
          // (30 / 15).ceil() == 2
          expect(result.lastPage, 2);
        });
      },
    );

    test('returns Right with empty items when API returns no users', () async {
      when(mockApiService.getContacts(any)).thenAnswer(
        (_) async => successResponse({'users': <dynamic>[], 'total': 0}),
      );

      final result = await repository.getContacts(page: 1, limit: 15);

      result.fold((failure) => fail('Expected Right, got Left: $failure'), (
        result,
      ) {
        expect(result.items, isEmpty);
        // (0 / 15).ceil() == 0 → clamp(1, 999999) == 1
        expect(result.lastPage, 1);
        expect(result.total, 0);
      });
    });

    test('returns Left(ServerFailure) when status code is not 200', () async {
      when(mockApiService.getContacts(any)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/users'),
          statusCode: 500,
          statusMessage: 'Internal Server Error',
        ),
      );

      final result = await repository.getContacts(page: 1, limit: 15);

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Internal Server Error');
      }, (_) => fail('Expected Left, got Right'));
    });

    test('returns Left(ServerFailure) when DioException is thrown', () async {
      when(mockApiService.getContacts(any)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/users'),
          message: 'Connection timeout',
        ),
      );

      final result = await repository.getContacts(page: 1, limit: 15);

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Connection timeout');
      }, (_) => fail('Expected Left, got Right'));
    });

    test('returns Left(ServerFailure) on unexpected parse error', () async {
      when(mockApiService.getContacts(any)).thenAnswer(
        // `users` bukan List → cast melempar di catch-all.
        (_) async => successResponse({'users': 'not-a-list', 'total': 0}),
      );

      final result = await repository.getContacts(page: 1, limit: 15);

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Unexpected Error Occurred');
      }, (_) => fail('Expected Left, got Right'));
    });
  });
}
