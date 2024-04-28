import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import 'models/k0_model.dart';
import 'provider/k0_provider.dart';

class K0Screen extends StatefulWidget {
  const K0Screen({Key? key})
      : super(
          key: key,
        );

  @override
  K0ScreenState createState() => K0ScreenState();
  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => K0Provider(),
      child: K0Screen(),
    );
  }
}

class K0ScreenState extends State<K0Screen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3000), () {
      NavigatorService.popAndPushNamed(
        AppRoutes.k1Screen,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomImageView(
                    imagePath: ImageConstant.imgExport1,
                    height: 71.v,
                    width: 73.h,
                    margin: EdgeInsets.only(
                      top: 10.v,
                      bottom: 11.v,
                    ),
                  ),
                  CustomImageView(
                    imagePath: ImageConstant.imgExport3,
                    height: 92.v,
                    width: 101.h,
                    margin: EdgeInsets.only(left: 4.h),
                  ),
                  CustomImageView(
                    imagePath: ImageConstant.imgExport2,
                    height: 70.v,
                    width: 79.h,
                    margin: EdgeInsets.only(
                      left: 4.h,
                      top: 10.v,
                      bottom: 11.v,
                    ),
                  )
                ],
              ),
              SizedBox(height: 2.v),
              GestureDetector(
                onTap: () {
                  onTapTxtSmiley(context);
                },
                child: Text(
                  "lbl_smiley".tr,
                  style: theme.textTheme.displayMedium,
                ),
              ),
              SizedBox(height: 5.v)
            ],
          ),
        ),
      ),
    );
  }

  /// Navigates to the k1Screen when the action is triggered.
  onTapTxtSmiley(BuildContext context) {
    NavigatorService.pushNamed(
      AppRoutes.k1Screen,
    );
  }
}
