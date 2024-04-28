import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../core/utils/validation_functions.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/custom_text_form_field.dart';
import 'models/k3_model.dart';
import 'provider/k3_provider.dart';

class K3Screen extends StatefulWidget {
  const K3Screen({Key? key})
      : super(
          key: key,
        );

  @override
  K3ScreenState createState() => K3ScreenState();
  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => K3Provider(),
      child: K3Screen(),
    );
  }
}
// ignore_for_file: must_be_immutable

// ignore_for_file: must_be_immutable
class K3ScreenState extends State<K3Screen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: _formKey,
            child: Container(
              width: double.maxFinite,
              padding: EdgeInsets.symmetric(
                horizontal: 30.h,
                vertical: 46.v,
              ),
              child: Column(
                children: [
                  SizedBox(height: 57.v),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 34.h),
                    child: Row(
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
                  ),
                  SizedBox(height: 57.v),
                  Text(
                    "msg_welcome_to_smiley".tr,
                    style: theme.textTheme.headlineLarge,
                  ),
                  SizedBox(height: 48.v),
                  _buildEmailAddress(context),
                  SizedBox(height: 26.v),
                  _buildPasswordOne(context),
                  SizedBox(height: 26.v),
                  _buildConfirmPassword(context),
                  SizedBox(height: 26.v),
                  _buildRegister(context),
                  SizedBox(height: 36.v),
                  _buildRowLineSixteen(context),
                  SizedBox(height: 35.v),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 57.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconButton(
                          height: 38.v,
                          width: 40.h,
                          child: CustomImageView(
                            imagePath: ImageConstant.imgWarning,
                          ),
                        ),
                        Spacer(
                          flex: 46,
                        ),
                        CustomImageView(
                          imagePath: ImageConstant.imgGoogleSvgrepoCom,
                          height: 23.adaptSize,
                          width: 23.adaptSize,
                          radius: BorderRadius.circular(
                            5.h,
                          ),
                          margin: EdgeInsets.symmetric(vertical: 7.v),
                        ),
                        Spacer(
                          flex: 53,
                        ),
                        Container(
                          height: 23.adaptSize,
                          width: 23.adaptSize,
                          padding: EdgeInsets.symmetric(horizontal: 5.h),
                          decoration: AppDecoration.outlineBlueA.copyWith(
                            borderRadius: BorderRadiusStyle.roundedBorder5,
                          ),
                          child: CustomImageView(
                            imagePath: ImageConstant.imgFacebook,
                            height: 22.v,
                            width: 11.h,
                            alignment: Alignment.center,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 53.v),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "lbl11".tr,
                        style: CustomTextStyles.titleMediumGray700,
                      ),
                      GestureDetector(
                        onTap: () {
                          onTapTxttf(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(left: 8.h),
                          child: Text(
                            "lbl12".tr,
                            style: CustomTextStyles.titleMediumLightgreen300,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildEmailAddress(BuildContext context) {
    return Selector<K3Provider, TextEditingController?>(
      selector: (context, provider) => provider.emailAddressController,
      builder: (context, emailAddressController, child) {
        return CustomTextFormField(
          controller: emailAddressController,
          hintText: "lbl6".tr,
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
        );
      },
    );
  }

  /// Section Widget
  Widget _buildPasswordOne(BuildContext context) {
    return Consumer<K3Provider>(
      builder: (context, provider, child) {
        return CustomTextFormField(
          controller: provider.passwordOneController,
          hintText: "lbl8".tr,
          textInputType: TextInputType.visiblePassword,
          prefix: Container(
            margin: EdgeInsets.fromLTRB(20.h, 8.v, 10.h, 8.v),
            child: CustomImageView(
              imagePath: ImageConstant.imgKeysvgrepocom1,
              height: 28.adaptSize,
              width: 28.adaptSize,
            ),
          ),
          prefixConstraints: BoxConstraints(
            maxHeight: 44.v,
          ),
          suffix: InkWell(
            onTap: () {
              provider.changePasswordVisibility();
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(30.h, 7.v, 19.h, 7.v),
              child: CustomImageView(
                imagePath: ImageConstant.imgEyecancelledfilledsvgrepocom1,
                height: 30.adaptSize,
                width: 30.adaptSize,
              ),
            ),
          ),
          suffixConstraints: BoxConstraints(
            maxHeight: 44.v,
          ),
          validator: (value) {
            if (value == null || (!isValidPassword(value, isRequired: true))) {
              return "err_msg_please_enter_valid_password".tr;
            }
            return null;
          },
          obscureText: provider.isShowPassword,
          contentPadding: EdgeInsets.symmetric(vertical: 11.v),
        );
      },
    );
  }

  /// Section Widget
  Widget _buildConfirmPassword(BuildContext context) {
    return Consumer<K3Provider>(
      builder: (context, provider, child) {
        return CustomTextFormField(
          controller: provider.confirmPasswordController,
          hintText: "lbl9".tr,
          textInputAction: TextInputAction.done,
          textInputType: TextInputType.visiblePassword,
          prefix: Container(
            margin: EdgeInsets.fromLTRB(20.h, 8.v, 10.h, 8.v),
            child: CustomImageView(
              imagePath: ImageConstant.imgKeysvgrepocom1,
              height: 28.adaptSize,
              width: 28.adaptSize,
            ),
          ),
          prefixConstraints: BoxConstraints(
            maxHeight: 44.v,
          ),
          suffix: InkWell(
            onTap: () {
              provider.changePasswordVisibility1();
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(30.h, 7.v, 19.h, 7.v),
              child: CustomImageView(
                imagePath: ImageConstant.imgEyecancelledfilledsvgrepocom1,
                height: 30.adaptSize,
                width: 30.adaptSize,
              ),
            ),
          ),
          suffixConstraints: BoxConstraints(
            maxHeight: 44.v,
          ),
          validator: (value) {
            if (value == null || (!isValidPassword(value, isRequired: true))) {
              return "err_msg_please_enter_valid_password".tr;
            }
            return null;
          },
          obscureText: provider.isShowPassword1,
          contentPadding: EdgeInsets.symmetric(vertical: 11.v),
        );
      },
    );
  }

  /// Section Widget
  Widget _buildRegister(BuildContext context) {
    return CustomElevatedButton(
      width: 114.h,
      text: "lbl10".tr,
    );
  }

  /// Section Widget
  Widget _buildRowLineSixteen(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.v),
          child: SizedBox(
            width: 135.h,
            child: Divider(),
          ),
        ),
        Text(
          "lbl_or".tr,
          style: CustomTextStyles.titleMediumLightgreen300,
        ),
        Padding(
          padding: EdgeInsets.only(
            top: 10.v,
            bottom: 9.v,
          ),
          child: SizedBox(
            width: 135.h,
            child: Divider(),
          ),
        )
      ],
    );
  }

  /// Navigates to the k1Screen when the action is triggered.
  onTapTxttf(BuildContext context) {
    NavigatorService.pushNamed(
      AppRoutes.k1Screen,
    );
  }
}
