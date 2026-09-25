import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:zidanfath_codebase/domain/auth/repositories/auth_repository.dart';
import 'package:zidanfath_codebase/domain/auth/usecases/login_usecase.dart';
import 'package:zidanfath_codebase/presentation/login/controllers/login.controller.dart';

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
        // Tanpa widget test, formKey tidak pernah ter-attach ke Form widget
        // manapun sehingga currentState null dan validate() memicu null-check
        // error sebelum use case sempat dipanggil.
        await expectLater(controller.doLogin(), throwsA(isA<TypeError>()));

        verifyZeroInteractions(mockAuthRepository);
      },
    );
  });
}
