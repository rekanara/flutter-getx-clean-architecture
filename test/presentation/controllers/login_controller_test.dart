import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:rekanara_getx/domain/auth/repositories/auth_repository.dart';
import 'package:rekanara_getx/domain/auth/usecases/login_usecase.dart';
import 'package:rekanara_getx/presentation/login/controllers/login.controller.dart';

import 'login_controller_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LoginController controller;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    Get.testMode = true;
    mockAuthRepository = MockAuthRepository();
    controller = LoginController(
      loginUseCase: LoginUseCase(mockAuthRepository),
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('LoginController', () {
    test('isObscure should default to true', () {
      expect(controller.isObscure.value, isTrue);
    });

    test('toggleObscure should flip isObscure', () {
      controller.toggleObscure();
      expect(controller.isObscure.value, isFalse);

      controller.toggleObscure();
      expect(controller.isObscure.value, isTrue);
    });

    test(
      'doLogin should never call the use case when formKey is unattached',
      () async {
        // Without widget test, formKey is never attached to any Form widget
        // so currentState is null and validate() triggers a null-check
        // error before the use case can be called.
        await expectLater(controller.doLogin(), throwsA(isA<TypeError>()));

        verifyZeroInteractions(mockAuthRepository);
      },
    );
  });
}
