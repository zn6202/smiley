import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import 'controller/k0_controller.dart'; // ignore_for_file: must_be_immutable

class K0Screen extends GetWidget<K0Controller> {
  const K0Screen({Key? key})
      : super(
          key: key,
        );

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
                  onTapTxtSmiley();
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
  onTapTxtSmiley() {
    Get.toNamed(
      AppRoutes.k1Screen,
    );
  }
}
