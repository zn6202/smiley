import 'package:flutter/material.dart';
import '../../../core/app_export.dart';
import '../models/k2_model.dart';

/// A provider class for the K2Screen.
///
/// This provider manages the state of the K2Screen, including the
/// current k2ModelObj
// ignore_for_file: must_be_immutable

// ignore_for_file: must_be_immutable
class K2Provider extends ChangeNotifier {
  TextEditingController emailaddressController = TextEditingController();

  K2Model k2ModelObj = K2Model();

  @override
  void dispose() {
    super.dispose();
    emailaddressController.dispose();
  }
}
