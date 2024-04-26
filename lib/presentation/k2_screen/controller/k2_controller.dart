import 'package:flutter/material.dart';
import '../../../core/app_export.dart';
import '../models/k2_model.dart';

/// A controller class for the K2Screen.
///
/// This class manages the state of the K2Screen, including the
/// current k2ModelObj
class K2Controller extends GetxController {
  TextEditingController emailaddressController = TextEditingController();

  Rx<K2Model> k2ModelObj = K2Model().obs;

  @override
  void onClose() {
    super.onClose();
    emailaddressController.dispose();
  }
}
