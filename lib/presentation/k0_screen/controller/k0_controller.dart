import '../../../core/app_export.dart';
import '../models/k0_model.dart';

/// A controller class for the K0Screen.
///
/// This class manages the state of the K0Screen, including the
/// current k0ModelObj
class K0Controller extends GetxController {
  Rx<K0Model> k0ModelObj = K0Model().obs;

  @override
  void onReady() {
    Future.delayed(const Duration(milliseconds: 3000), () {
      Get.offNamed(
        AppRoutes.k1Screen,
      );
    });
  }
}
