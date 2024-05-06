import 'package:flutter/material.dart';
import '../../core/app_export.dart'; // 應用程式導出模組
import '../../widgets/custom_elevated_button.dart'; // 自訂的高架按鈕元件
import '../../widgets/custom_icon_button.dart'; // 自訂的圖示按鈕元件
import '../../widgets/custom_text_form_field.dart'; // 自訂的文字輸入欄位元件

// 忽略檔案錯誤: 必須是不可變的
// ignore_for_file: must_be_immutable
class RegisterScreen extends StatefulWidget {
  RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 輸入控制器
  TextEditingController emailAddressController =
      TextEditingController(); // 電子郵件地址輸入控制器
  TextEditingController passwordOneController =
      TextEditingController(); // 密碼輸入控制器
  TextEditingController confirmPasswordController =
      TextEditingController(); // 確認密碼輸入控制器

  // 全局表單鍵
  GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // 表單鍵全局鍵
  bool isPasswordVisible = false;

  // 定義切換密碼可見性的方法
  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
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
                  // 應用程式 Logo
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
                  // 歡迎訊息
                  Text(
                    "Welcome to SMILEY",
                    style: theme.textTheme.headlineLarge,
                  ),
                  SizedBox(height: 48.v),
                  // 電子郵件輸入區塊
                  _buildEmailAddress(context),
                  SizedBox(height: 26.v),
                  // 密碼輸入區塊
                  _buildPasswordOne(context),
                  SizedBox(height: 26.v),
                  // 確認密碼輸入區塊
                  _buildConfirmPassword(context),
                  SizedBox(height: 26.v),
                  // 註冊按鈕
                  _buildRegisterButton(context),
                  SizedBox(height: 36.v),
                  // 分隔線
                  _buildRowLineSixteen(context),
                  SizedBox(height: 35.v),
                  // 社交媒體圖示按鈕
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconButton(
                        height: 52.v,
                        width: 55.h,
                        padding: EdgeInsets.all(11.h),
                        child: CustomImageView(
                          imagePath: ImageConstant.imgGoogle,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 57.h),
                        child: CustomIconButton(
                          height: 50.v,
                          width: 53.h,
                          padding: EdgeInsets.all(10.h),
                          decoration: IconButtonStyleHelper.fillBlueA,
                          child: CustomImageView(
                            imagePath: ImageConstant.imgFacebook,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 40.v),
                  // 登錄連結
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "已經有帳號嗎？  ",
                        style: CustomTextStyles.titleMediumGray700,
                      ),
                      GestureDetector(
                        onTap: () {
                          onTaplogin(context); // 呼叫登錄方法
                        },
                        child: Padding(
                          padding: EdgeInsets.only(left: 8.h),
                          child: Text(
                            "快速登入",
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

  /// 電子郵件輸入欄位
  Widget _buildEmailAddress(BuildContext context) {
    return CustomTextFormField(
      controller: emailAddressController,
      hintText: "email...",
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
  }

  /// 密碼輸入欄位
  Widget _buildPasswordOne(BuildContext context) {
    return CustomTextFormField(
      controller: passwordOneController,
      hintText: "password...",
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
      suffix: GestureDetector(
        onTap: () {
          togglePasswordVisibility(); // 切換密碼可見性
        },
        child: Container(
          margin: EdgeInsets.fromLTRB(30.h, 7.v, 19.h, 7.v),
          child: CustomImageView(
            imagePath: isPasswordVisible
                ? ImageConstant.imgEyeopenfilledsvgrepocom // 可視狀態的圖示
                : ImageConstant.imgEyecancelledfilledsvgrepocom1, // 不可視狀態的圖示
            height: 30.adaptSize,
            width: 30.adaptSize,
          ),
        ),
      ),
      suffixConstraints: BoxConstraints(
        maxHeight: 44.v,
      ),
      obscureText: !isPasswordVisible, // 切換密碼的可視/不可視狀態
      contentPadding: EdgeInsets.symmetric(vertical: 11.v),
    );
  }

  /// 確認密碼輸入欄位
  Widget _buildConfirmPassword(BuildContext context) {
    return CustomTextFormField(
      controller: confirmPasswordController,
      hintText: "confirm password...",
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
      suffix: Container(
        margin: EdgeInsets.fromLTRB(30.h, 7.v, 19.h, 7.v),
        child: CustomImageView(
          imagePath: ImageConstant.imgEyecancelledfilledsvgrepocom1,
          height: 30.adaptSize,
          width: 30.adaptSize,
        ),
      ),
      suffixConstraints: BoxConstraints(
        maxHeight: 44.v,
      ),
      obscureText: true,
      contentPadding: EdgeInsets.symmetric(vertical: 11.v),
    );
  }

  /// 註冊按鈕
  Widget _buildRegisterButton(BuildContext context) {
    return CustomElevatedButton(
      width: 114.h,
      text: "註冊",
      onTap: () {
        Register(context);
      },
    );
  }

  /// 分隔線
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
          "OR",
          style: CustomTextStyles.titleMediumGray700,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.v),
          child: SizedBox(
            width: 135.h,
            child: Divider(),
          ),
        ),
      ],
    );
  }

  void onTaplogin(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.loginScreen); // 跳轉至登錄頁面
  }

  /// 預留的註冊函數
  void Register(BuildContext context) {}
}
