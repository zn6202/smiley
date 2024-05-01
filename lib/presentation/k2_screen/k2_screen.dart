import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../widgets/app_bar/appbar_leading_image.dart';
import '../../widgets/app_bar/appbar_title.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_text_form_field.dart'; // ignore_for_file: must_be_immutable

// ignore_for_file: must_be_immutable
class K2Screen extends StatelessWidget {
  K2Screen({Key? key})
      : super(
          key: key,
        );

  TextEditingController emailaddressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: _buildAppBar(context),
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
                controller: emailaddressController,
                hintText: "電子郵件地址...",
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
                text: "發送驗證碼",
              ),
              SizedBox(height: 5.v)
            ],
          ),
        ),
      ),
    );
  }

  /// Section Widget
  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
          onTapArrowleftone(context);
        },
      ),
      centerTitle: true,
      title: AppbarTitle(
        text: "密碼找回",
      ),
    );
  }

  /// Navigates back to the previous screen.
  onTapArrowleftone(BuildContext context) {
    Navigator.pop(context);
  }
}
