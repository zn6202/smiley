import 'package:flutter/material.dart';
import '../../../core/app_export.dart';
import '../models/k1_model.dart';

/// A provider class for the K1Screen.
///
/// This provider manages the state of the K1Screen, including the
/// current k1ModelObj
// ignore_for_file: must_be_immutable

// ignore_for_file: must_be_immutable
class K1Provider extends ChangeNotifier {
  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  K1Model k1ModelObj = K1Model();

  bool isShowPassword = true;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void changePasswordVisibility() {
    isShowPassword = !isShowPassword;
    notifyListeners();
  }
}
