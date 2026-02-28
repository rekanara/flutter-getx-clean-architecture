import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../presentation/screens.dart';
import '../network/environments.dart';
import 'bindings/controllers/controllers_bindings.dart';
import 'routes.dart';

class EnvironmentsBadge extends StatelessWidget {
  final Widget child;
  const EnvironmentsBadge({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    final env = ConfigEnvironments.current;

    if (env.isProduction) {
      return SizedBox(child: child);
    }

    return Banner(
      location: BannerLocation.topStart,
      message: env.label,
      color: env.badgeColor,
      child: child,
    );
  }
}

class Nav {
  static List<GetPage> routes = [
    GetPage(
      name: Routes.home,
      page: () => const HomeScreen(),
      binding: HomeControllerBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginScreen(),
      binding: LoginControllerBinding(),
    ),
    GetPage(
      name: Routes.user,
      page: () => const UserScreen(),
      binding: UserControllerBinding(),
    ),
  ];
}
