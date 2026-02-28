import 'package:get/get.dart';

import '../../../../presentation/user/controllers/user.controller.dart';

class UserControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserController>(
      () => UserController(),
    );
  }
}
