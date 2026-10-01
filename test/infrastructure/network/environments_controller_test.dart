import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:rekanara_getx/config/flavor/flavor_service.dart';
import 'package:rekanara_getx/infrastructure/network/environments.dart';
import 'package:rekanara_getx/infrastructure/platform/storage/get_storage_impl.dart';
import 'package:rekanara_getx/infrastructure/platform/storage/storage.dart';

import 'environments_controller_test.mocks.dart';

@GenerateMocks([Storage])
void main() {
  late MockStorage mockStorage;

  setUp(() {
    mockStorage = MockStorage();
  });

  EnvironmentController buildController() {
    final controller = EnvironmentController(storage: mockStorage);
    controller.onInit();
    return controller;
  }

  group('EnvironmentController', () {
    test('defaults to dev and persists the label when storage is empty', () {
      when(mockStorage.read<String>(StorageValue.env)).thenReturn(null);

      final controller = buildController();

      expect(controller.currentEnv.value, Environment.dev);
      verify(mockStorage.write(StorageValue.env, 'dev')).called(1);
    });

    test('restores staging from persisted label', () {
      when(mockStorage.read<String>(StorageValue.env)).thenReturn('staging');

      final controller = buildController();

      expect(controller.currentEnv.value, Environment.staging);
      verifyNever(mockStorage.write(any, any));
    });

    test('falls back to dev when persisted label is unknown', () {
      when(mockStorage.read<String>(StorageValue.env)).thenReturn('production');

      final controller = buildController();

      expect(controller.currentEnv.value, Environment.dev);
    });

    test('switchEnvironment switches to staging and persists the label', () {
      when(mockStorage.read<String>(StorageValue.env)).thenReturn(null);
      final controller = buildController();

      controller.switchEnvironment(Environment.staging);

      expect(controller.currentEnv.value, Environment.staging);
      verify(mockStorage.write(StorageValue.env, 'staging')).called(1);
    });

    test(
      'switchEnvironment to prod is ignored (dev flavor never reaches prod)',
      () {
        when(mockStorage.read<String>(StorageValue.env)).thenReturn(null);
        final controller = buildController();

        controller.switchEnvironment(Environment.prod);

        expect(controller.currentEnv.value, Environment.dev);
        expect(controller.currentEnv.value.isProduction, isFalse);
        verifyNever(mockStorage.write(StorageValue.env, 'prod'));
      },
    );
  });

  group('FlavorService', () {
    test('dev flavor allows switching between dev and staging only', () {
      final saved = FlavorService.flavor;
      FlavorService.testOverride(AppFlavor.dev);

      expect(FlavorService.canSwitchEnv, isTrue);
      expect(FlavorService.allowedEnvironments, [
        Environment.dev,
        Environment.staging,
      ]);
      expect(FlavorService.lockedEnvironment, isNull);

      FlavorService.testOverride(saved);
    });

    test('staging flavor is locked to staging', () {
      final saved = FlavorService.flavor;
      FlavorService.testOverride(AppFlavor.staging);

      expect(FlavorService.canSwitchEnv, isFalse);
      expect(FlavorService.allowedEnvironments, [Environment.staging]);
      expect(FlavorService.lockedEnvironment, Environment.staging);

      FlavorService.testOverride(saved);
    });

    test('prod flavor is locked to prod and hides switcher', () {
      final saved = FlavorService.flavor;
      FlavorService.testOverride(AppFlavor.prod);

      expect(FlavorService.canSwitchEnv, isFalse);
      expect(FlavorService.allowedEnvironments, [Environment.prod]);
      expect(FlavorService.lockedEnvironment, Environment.prod);
      expect(FlavorService.flavor.isProduction, isTrue);

      FlavorService.testOverride(saved);
    });
  });
}
