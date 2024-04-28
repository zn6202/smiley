import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../core/utils/validation_functions.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/custom_text_form_field.dart';
import 'models/k1_model.dart';
import 'provider/k1_provider.dart';

class K1Screen extends StatefulWidget {
  const K1Screen({Key? key})
      : super(
          key: key,
        );

  @override
  K1ScreenState createState() => K1ScreenState();
  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => K1Provider(),
      child: K1Screen(),
    );
  }
}
// ignore_for_file: must_be_immutable

// ignore_for_file: must_be_immutable
class K1ScreenState extends State<K1Screen> {
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
                horizontal: 29.h,
                vertical: 46.v,
              ),
              child: Column(
                children: [
                  SizedBox(height: 57.v),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 35.h),
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
                  SizedBox(height: 57.v),
                  Selector<K1Provider, TextEditingController?>(
                    selector: (context, provider) => provider.emailController,
                    builder: (context, emailController, child) {
                      return CustomTextFormField(
                        controller: emailController,
                        hintText: "lbl_email".tr,
                        textInputType: TextInputType.emailAddress,
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
                        validator: (value) {
                          if (value == null ||
                              (!isValidEmail(value, isRequired: true))) {
                            return "err_msg_please_enter_valid_email".tr;
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  SizedBox(height: 26.v),
                  Consumer<K1Provider>(
                    builder: (context, provider, child) {
                      return CustomTextFormField(
                        controller: provider.passwordController,
                        hintText: "lbl_password".tr,
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
                            provider.changePasswordVisibility();
                          },
                          child: Container(
                            margin: EdgeInsets.fromLTRB(30.h, 7.v, 19.h, 7.v),
                            child: CustomImageView(
                              imagePath: ImageConstant
                                  .imgEyecancelledfilledsvgrepocom1,
                              height: 30.adaptSize,
                              width: 30.adaptSize,
                            ),
                          ),
                        ),
                        suffixConstraints: BoxConstraints(
                          maxHeight: 44.v,
                        ),
                        validator: (value) {
                          if (value == null ||
                              (!isValidPassword(value, isRequired: true))) {
                            return "err_msg_please_enter_valid_password".tr;
                          }
                          return null;
                        },
                        obscureText: provider.isShowPassword,
                        contentPadding: EdgeInsets.symmetric(vertical: 11.v),
                      );
                    },
                  ),
                  SizedBox(height: 7.v),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        onTapTxttf(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 3.h),
                        child: Text(
                          "lbl".tr,
                          style: CustomTextStyles.titleMediumLightgreen300,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 26.v),
                  CustomElevatedButton(
                    width: 114.h,
                    text: "lbl2".tr,
                  ),
                  SizedBox(height: 34.v),
                  _buildRowLineSixteen(context),
                  SizedBox(height: 35.v),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 58.h),
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
                  SizedBox(height: 86.v),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "lbl3".tr,
                        style: CustomTextStyles.titleMediumGray700,
                      ),
                      GestureDetector(
                        onTap: () {
                          onTapTxttf1(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(left: 6.h),
                          child: Text(
                            "lbl4".tr,
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

  /// Navigates to the k2Screen when the action is triggered.
  onTapTxttf(BuildContext context) {
    NavigatorService.pushNamed(
      AppRoutes.k2Screen,
    );
  }

  /// Navigates to the k3Screen when the action is triggered.
  onTapTxttf1(BuildContext context) {
    NavigatorService.pushNamed(
      AppRoutes.k3Screen,
    );
  }
}
