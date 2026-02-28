import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/auth/usecases/login_usecase.dart';
import '../../../infrastructure/navigation/routes.dart';
import '../../../presentation/core/base_controller.dart';
import '../../../utils/helper/snackbar.dart';

class LoginController extends BaseController {
  final LoginUseCase loginUseCase;

  LoginController({required this.loginUseCase});

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isObscure = true.obs;

  @override
  void onInit() {
    emailController.text = 'zidanfath.code@gmail.comm';
    passwordController.text = 'Masuk123';

    super.onInit();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void toggleObscure() => isObscure.toggle();

  Future<void> doLogin() async {
    if (!formKey.currentState!.validate()) return;

    final params = LoginParams(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    await callUseCase(
      loginUseCase.execute(params),
      onSuccess: (user) {
        SnackbarHelper.showSuccess('Welcome back, ${user.roleName}');
        Get.offAllNamed(Routes.home);
      },
    );
  }
}
