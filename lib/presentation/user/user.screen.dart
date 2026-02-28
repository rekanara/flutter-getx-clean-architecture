import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/user.controller.dart';

class UserScreen extends GetView<UserController> {
  const UserScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UserScreen'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'UserScreen is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
