import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:zidanfath_codebase/domain/core/errors/failures.dart';
import 'package:zidanfath_codebase/domain/home/entities/banner_entity.dart';
import 'package:zidanfath_codebase/domain/home/usecases/get_banners_usecase.dart';
import 'package:zidanfath_codebase/presentation/home/controllers/home.controller.dart';

import 'home_controller_test.mocks.dart';

@GenerateMocks([GetBannersUseCase])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late HomeController controller;
  late MockGetBannersUseCase mockUseCase;

  setUp(() {
    Get.testMode = true;
    mockUseCase = MockGetBannersUseCase();
    controller = HomeController(getBannersUseCase: mockUseCase);
  });

  tearDown(() {
    Get.reset();
  });

  group('HomeController', () {
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

    test('should have empty banners initially', () {
      // Setup: stub usecase karena onInit akan memanggil fetchBanners
      when(mockUseCase.execute(any)).thenAnswer((_) async => const Right([]));

      expect(controller.banners, isEmpty);
    });

    test('fetchBanners should populate banners on success', () async {
      // Arrange
      when(mockUseCase.execute(any)).thenAnswer((_) async => Right(tBanners));

      // Act
      await controller.fetchBanners();

      // Assert
      expect(controller.banners.length, 2);
      expect(controller.banners.first.title, 'Banner 1');
      verify(mockUseCase.execute(any)).called(1);
    });

    test('fetchBanners should set errorMessage on failure', () async {
      // Arrange
      when(
        mockUseCase.execute(any),
      ).thenAnswer((_) async => Left(ServerFailure('Server Error')));

      // Act
      await controller.fetchBanners();

      // Assert
      expect(controller.errorMessage.value, 'Server Error');
      expect(controller.banners, isEmpty);
    });

    test('fetchBanners should handle empty response', () async {
      // Arrange
      when(mockUseCase.execute(any)).thenAnswer((_) async => const Right([]));

      // Act
      await controller.fetchBanners();

      // Assert
      expect(controller.banners, isEmpty);
      expect(controller.errorMessage.value, isEmpty);
    });
  });
}
