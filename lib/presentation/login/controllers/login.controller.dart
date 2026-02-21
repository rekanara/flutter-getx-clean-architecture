import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zidanfath_codebase/utils/helper/snackbar.dart';

import '../../../../domain/auth/usecases/login_usecase.dart';
import '../../../../infrastructure/navigation/routes.dart';

class LoginController extends GetxController {
  final LoginUseCase loginUseCase;

  LoginController({required this.loginUseCase});

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isObscure = true.obs;
  final isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void toggleObscure() => isObscure.toggle();

  Future<void> doLogin() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    final email = emailController.text.trim();
    final password = passwordController.text;

    final result = await loginUseCase.execute(email, password);

    result.fold(
      (failure) {
        isLoading.value = false;
        SnackbarHelper.showError(failure.message);
      },
      (user) {
        isLoading.value = false;
        SnackbarHelper.showSuccess('Welcome back, ${user.roleName}');
        Get.offAllNamed(Routes.HOME);
      },
    );
  }
}
