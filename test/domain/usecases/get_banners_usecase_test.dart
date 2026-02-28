import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:zidanfath_codebase/domain/core/errors/failures.dart';
import 'package:zidanfath_codebase/domain/core/usecases/usecase.dart';
import 'package:zidanfath_codebase/domain/home/entities/banner_entity.dart';
import 'package:zidanfath_codebase/domain/home/repositories/home_repository.dart';
import 'package:zidanfath_codebase/domain/home/usecases/get_banners_usecase.dart';

import 'get_banners_usecase_test.mocks.dart';

@GenerateMocks([HomeRepository])
void main() {
  late GetBannersUseCase useCase;
  late MockHomeRepository mockRepository;

  setUp(() {
    mockRepository = MockHomeRepository();
    useCase = GetBannersUseCase(mockRepository);
  });

  group('GetBannersUseCase', () {
    final tBanners = [
      BannerEntity(
        id: '1',
        bannerUrl: 'https://img.com/1.jpg',
        title: 'Banner 1',
      ),
      BannerEntity(
        id: '2',
        bannerUrl: 'https://img.com/2.jpg',
        title: 'Banner 2',
      ),
    ];

    test(
      'should return list of banners when repository call is successful',
      () async {
        // Arrange
        when(
          mockRepository.getBanners(),
        ).thenAnswer((_) async => Right(tBanners));

        // Act
        final result = await useCase.execute(NoParams());

        // Assert
        expect(result, Right(tBanners));
        verify(mockRepository.getBanners()).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should return ServerFailure when repository call fails', () async {
      // Arrange
      final failure = ServerFailure('Network Error');
      when(mockRepository.getBanners()).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.execute(NoParams());

      // Assert
      expect(result, Left(failure));
      verify(mockRepository.getBanners()).called(1);
    });

    test('should return empty list when repository returns empty', () async {
      // Arrange
      when(
        mockRepository.getBanners(),
      ).thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase.execute(NoParams());

      // Assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (banners) => expect(banners, isEmpty),
      );
    });
  });
}
