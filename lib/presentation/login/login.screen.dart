import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/atoms/custom_button.dart';
import '../../components/atoms/custom_text.dart';
import '../../components/atoms/custom_text_field.dart';
import '../../utils/config.dart';
import 'controllers/login.controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                Icon(
                  Icons.lock_person_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                CustomText(
                  text: 'Welcome Back!',
                  fontType: FontType.headlineMedium,
                  weight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                CustomText(
                  text: 'Sign in to your account',
                  fontType: FontType.bodyLarge,
                  textAlign: TextAlign.center,
                  opacity: 0.6,
                ),
                const SizedBox(height: 48),
                CustomTextField(
                  controller: controller.emailController,
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Obx(
                  () => CustomTextField(
                    controller: controller.passwordController,
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    obscureText: controller.isObscure.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isObscure.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: controller.toggleObscure,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 32),
                Obx(
                  () => CustomButton(
                    title: 'Sign In',
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.doLogin,
                    widget: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
