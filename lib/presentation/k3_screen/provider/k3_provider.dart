import 'package:flutter/material.dart';
import '../../../core/app_export.dart';
import '../models/k3_model.dart';

/// A provider class for the K3Screen.
///
/// This provider manages the state of the K3Screen, including the
/// current k3ModelObj
// ignore_for_file: must_be_immutable

// ignore_for_file: must_be_immutable
class K3Provider extends ChangeNotifier {
  TextEditingController emailAddressController = TextEditingController();

  TextEditingController passwordOneController = TextEditingController();

  TextEditingController confirmPasswordController = TextEditingController();

  K3Model k3ModelObj = K3Model();

  bool isShowPassword = true;

  bool isShowPassword1 = true;

  @override
  void dispose() {
    super.dispose();
    emailAddressController.dispose();
    passwordOneController.dispose();
    confirmPasswordController.dispose();
  }

  void changePasswordVisibility() {
    isShowPassword = !isShowPassword;
    notifyListeners();
  }

  void changePasswordVisibility1() {
    isShowPassword1 = !isShowPassword1;
    notifyListeners();
  }
}
