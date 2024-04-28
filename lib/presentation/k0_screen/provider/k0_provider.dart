import 'package:flutter/material.dart';
import '../../../core/app_export.dart';
import '../models/k0_model.dart';

/// A provider class for the K0Screen.
///
/// This provider manages the state of the K0Screen, including the
/// current k0ModelObj
// ignore_for_file: must_be_immutable

// ignore_for_file: must_be_immutable
class K0Provider extends ChangeNotifier {
  K0Model k0ModelObj = K0Model();

  @override
  void dispose() {
    super.dispose();
  }
}
