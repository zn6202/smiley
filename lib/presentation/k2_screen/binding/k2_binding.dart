import '../../../core/app_export.dart';
import '../controller/k2_controller.dart';

/// A binding class for the K2Screen.
///
/// This class ensures that the K2Controller is created when the
/// K2Screen is first loaded.
class K2Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => K2Controller());
  }
}
