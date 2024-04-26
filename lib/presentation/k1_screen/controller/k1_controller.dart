import 'package:flutter/material.dart';
import '../../../core/app_export.dart';
import '../models/k1_model.dart';

/// A controller class for the K1Screen.
///
/// This class manages the state of the K1Screen, including the
/// current k1ModelObj
class K1Controller extends GetxController {
  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  Rx<K1Model> k1ModelObj = K1Model().obs;

  Rx<bool> isShowPassword = true.obs;

  @override
  void onClose() {
    super.onClose();
    emailController.dispose();
    passwordController.dispose();
  }
}
