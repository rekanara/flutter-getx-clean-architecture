import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../network/environments.dart';
import '../../presentation/screens.dart';
import 'bindings/controllers/controllers_bindings.dart';
import 'routes.dart';

class EnvironmentsBadge extends StatelessWidget {
  final Widget child;
  const EnvironmentsBadge({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    DomainController domainController = Get.put(DomainController());
    return domainController.env.value != Environments.PRODUCTION
        ? Banner(
            location: BannerLocation.topStart,
            message: domainController.env.value,
            color: domainController.env.value == Environments.DEV
                ? Colors.purple
                : Colors.orange,
            child: child,
          )
        : SizedBox(child: child);
  }
}

class Nav {
  static List<GetPage> routes = [
    GetPage(
      name: Routes.HOME,
      page: () => const HomeScreen(),
      binding: HomeControllerBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginScreen(),
      binding: LoginControllerBinding(),
    ),
  ];
}
