import 'package:flutter/material.dart';
import '../../../core/app_export.dart';
import '../models/k3_model.dart';

/// A controller class for the K3Screen.
///
/// This class manages the state of the K3Screen, including the
/// current k3ModelObj
class K3Controller extends GetxController {
  TextEditingController emailAddressController = TextEditingController();

  TextEditingController passwordOneController = TextEditingController();

  TextEditingController confirmPasswordController = TextEditingController();

  Rx<K3Model> k3ModelObj = K3Model().obs;

  Rx<bool> isShowPassword = true.obs;

  Rx<bool> isShowPassword1 = true.obs;

  @override
  void onClose() {
    super.onClose();
    emailAddressController.dispose();
    passwordOneController.dispose();
    confirmPasswordController.dispose();
  }
}
