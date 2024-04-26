import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../widgets/app_bar/appbar_leading_image.dart';
import '../../widgets/app_bar/appbar_title.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_text_form_field.dart';
import 'controller/k2_controller.dart'; // ignore_for_file: must_be_immutable

class K2Screen extends GetWidget<K2Controller> {
  const K2Screen({Key? key})
      : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: _buildAppBar(),
        body: Container(
          width: double.maxFinite,
          padding: EdgeInsets.only(
            left: 30.h,
            top: 95.v,
            right: 30.h,
          ),
          child: Column(
            children: [
              CustomTextFormField(
                controller: controller.emailaddressController,
                hintText: "lbl6".tr,
                textInputAction: TextInputAction.done,
                prefix: Container(
                  margin: EdgeInsets.fromLTRB(20.h, 11.v, 10.h, 11.v),
                  child: CustomImageView(
                    imagePath: ImageConstant.imgLock,
                    height: 20.v,
                    width: 26.h,
                  ),
                ),
                prefixConstraints: BoxConstraints(
                  maxHeight: 44.v,
                ),
              ),
              SizedBox(height: 34.v),
              CustomElevatedButton(
                width: 114.h,
                text: "lbl7".tr,
              ),
              SizedBox(height: 5.v)
            ],
          ),
        ),
      ),
    );
  }

  /// Section Widget
  PreferredSizeWidget _buildAppBar() {
    return CustomAppBar(
      leadingWidth: 50.h,
      leading: AppbarLeadingImage(
        imagePath: ImageConstant.imgArrowLeft,
        margin: EdgeInsets.only(
          left: 41.h,
          top: 19.v,
          bottom: 19.v,
        ),
        onTap: () {
          onTapArrowleftone();
        },
      ),
      centerTitle: true,
      title: AppbarTitle(
        text: "lbl5".tr,
      ),
    );
  }

  /// Navigates to the previous screen.
  onTapArrowleftone() {
    Get.back();
  }
}