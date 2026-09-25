import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:zidanfath_codebase/infrastructure/network/environments.dart';
import 'package:zidanfath_codebase/infrastructure/platform/storage/get_storage_impl.dart';
import 'package:zidanfath_codebase/infrastructure/platform/storage/storage.dart';

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

    test('switchEnvironment updates state and persists the new label', () {
      when(mockStorage.read<String>(StorageValue.env)).thenReturn(null);
      final controller = buildController();

      controller.switchEnvironment(Environment.prod);

      expect(controller.currentEnv.value, Environment.prod);
      expect(controller.currentEnv.value.isProduction, isTrue);
      verify(mockStorage.write(StorageValue.env, 'prod')).called(1);
    });
  });
}
