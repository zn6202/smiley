import '../core/app_export.dart';
import '../presentation/app_navigation_screen/app_navigation_screen.dart';
import '../presentation/app_navigation_screen/binding/app_navigation_binding.dart';
import '../presentation/k0_screen/binding/k0_binding.dart';
import '../presentation/k0_screen/k0_screen.dart';
import '../presentation/k1_screen/binding/k1_binding.dart';
import '../presentation/k1_screen/k1_screen.dart';
import '../presentation/k2_screen/binding/k2_binding.dart';
import '../presentation/k2_screen/k2_screen.dart';
import '../presentation/k3_screen/binding/k3_binding.dart';
import '../presentation/k3_screen/k3_screen.dart'; // ignore_for_file: must_be_immutable

// ignore_for_file: must_be_immutable
class AppRoutes {
  static const String k0Screen = '/k0_screen';

  static const String k1Screen = '/k1_screen';

  static const String k2Screen = '/k2_screen';

  static const String k3Screen = '/k3_screen';

  static const String appNavigationScreen = '/app_navigation_screen';

  static const String initialRoute = '/initialRoute';

  static List<GetPage> pages = [
    GetPage(
      name: k0Screen,
      page: () => K0Screen(),
      bindings: [K0Binding()],
    ),
    GetPage(
      name: k1Screen,
      page: () => K1Screen(),
      bindings: [K1Binding()],
    ),
    GetPage(
      name: k2Screen,
      page: () => K2Screen(),
      bindings: [K2Binding()],
    ),
    GetPage(
      name: k3Screen,
      page: () => K3Screen(),
      bindings: [K3Binding()],
    ),
    GetPage(
      name: appNavigationScreen,
      page: () => AppNavigationScreen(),
      bindings: [AppNavigationBinding()],
    ),
    GetPage(
      name: initialRoute,
      page: () => K0Screen(),
      bindings: [K0Binding()],
    )
  ];
}
