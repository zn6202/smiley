import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/custom_text_form_field.dart'; // 忽略文件: 必須是可變的

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../diarymain_screen/diarymain_screen.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 電子郵件文字控制器
  TextEditingController emailController = TextEditingController();
  // 密碼文字控制器
  TextEditingController passwordController = TextEditingController();
  // 表單的全域鍵
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // 密碼可見性狀態
  bool _isPasswordVisible = false;

  // 錯誤訊息
  String? errorMessage;

  void signInWithEmailAndPassword() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      print('登入成功! 使用者的ID: ${credential.user?.uid}');
      Navigator.pushNamed(context, AppRoutes.diaryMainScreen);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = '帳號密碼輸入錯誤';
      });
    }
  }

  // google 註冊(如果已經註冊過就會直接登入)
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      // 登入成功後導航到下一個畫面，這裡假設登入成功後要跳轉到首頁
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DiaryMainScreen()),
      );
    } catch (e) {
      print('Google sign in error: $e');
      // 處理登入錯誤
      // 可以顯示錯誤訊息給用戶或者執行其他處理邏輯
    }
  }

  // 定義切換密碼可見性的方法
  void togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false, // 防止鍵盤彈出時界面過度縮小
        body: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // 根據鍵盤視窗自動填充底部間距
          ),
          child: Form(
            key: _formKey,
            child: Container(
              width: double.maxFinite, // 使用可用的最大寬度
              padding: EdgeInsets.symmetric(
                horizontal: 30.h,
                vertical: 46.v,
              ),
              child: Column(
                children: [
                  SizedBox(height: 57.v), // 上方間距
                  // Logo 排版區域
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 34.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // 水平置中
                      children: [
                        // 第一個 Logo 圖像
                        CustomImageView(
                          imagePath: ImageConstant.imgExport1,
                          height: 71.v,
                          width: 73.h,
                          margin: EdgeInsets.only(
                            top: 10.v,
                            bottom: 11.v,
                          ),
                        ),
                        // 第二個 Logo 圖像
                        CustomImageView(
                          imagePath: ImageConstant.imgExport3,
                          height: 92.v,
                          width: 101.h,
                          margin: EdgeInsets.only(left: 4.h),
                        ),
                        // 第三個 Logo 圖像
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
                  SizedBox(height: 57.v), // 上方間距
                  // 歡迎標題
                  Text(
                    "Welcome to SMILEY",
                    style: theme.textTheme.headlineLarge,
                  ),
                  SizedBox(
                    height: 57.v,
                    child: Center(
                      child: errorMessage != null
                          ? Text(
                              errorMessage!,
                              style: TextStyle(color: Colors.red),
                            )
                          : null,
                    ),
                  ),
                  // 電子郵件輸入框
                  CustomTextFormField(
                    controller: emailController,
                    hintText: "email...",
                    textInputType: TextInputType.emailAddress, // 指定輸入類型
                    textStyle: TextStyle(color: Colors.black), // 設定文本顏色為黑色
                    prefix: Container(
                      margin: EdgeInsets.fromLTRB(
                          20.h, 11.v, 10.h, 11.v), // 左、上、右、下間距
                      child: CustomImageView(
                        imagePath: ImageConstant.imgLock,
                        height: 20.v,
                        width: 26.h,
                      ),
                    ),
                    prefixConstraints: BoxConstraints(
                      maxHeight: 44.v, // 輸入框最大高度
                    ),
                  ),
                  SizedBox(height: 26.v), // 上方間距
                  // 密碼輸入框
                  CustomTextFormField(
                    controller: passwordController,
                    hintText: "password...",
                    textInputAction: TextInputAction.done, // 完成輸入操作
                    textInputType: TextInputType.visiblePassword,
                    textStyle: TextStyle(color: Colors.black), // 設定文本顏色為黑色
                    prefix: Container(
                      margin: EdgeInsets.fromLTRB(
                          20.h, 8.v, 10.h, 8.v), // 左、上、右、下間距
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
                        togglePasswordVisibility(); // 切換密碼可視/不可視狀態
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(
                            30.h, 7.v, 19.h, 7.v), // 左、上、右、下間距
                        child: CustomImageView(
                          imagePath: _isPasswordVisible
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
                    obscureText: !_isPasswordVisible, // 根據狀態切換密碼可視/不可視
                    contentPadding: EdgeInsets.symmetric(vertical: 11.v),
                  ),
                  SizedBox(height: 7.v), // 上方間距
                  // 忘記密碼連結
                  Align(
                    alignment: Alignment.centerRight, // 置於右側
                    child: GestureDetector(
                      onTap: () {
                        onTapforgetPWD(context); // 點擊跳轉至忘記密碼頁面
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 2.h),
                        child: Text(
                          "忘記密碼？",
                          style: CustomTextStyles.titleMediumLightgreen300,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 26.v), // 上方間距
                  // 登入按鈕
                  CustomElevatedButton(
                    width: 114.h,
                    text: "登入",
                    onPressed: () {
                      signInWithEmailAndPassword();
                    },
                  ),
                  SizedBox(height: 34.v), // 上方間距
                  // 分隔線與 "OR"
                  _buildRowLineSixteen(context),
                  SizedBox(height: 44.v), // 上方間距
                  // Google 和 Facebook 按鈕
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // 置於中心
                    children: [
                      // Google 按鈕
                      CustomIconButton(
                        onTap: () {
                          signInWithGoogle();
                        },
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
                  SizedBox(height: 64.v), // 上方間距
                  // 快速註冊區域
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "沒有帳號嗎？  ",
                        style: CustomTextStyles.titleMediumGray700,
                      ),
                      GestureDetector(
                        onTap: () {
                          onTapsignup(context); // 點擊跳轉至快速註冊頁面
                        },
                        child: Padding(
                          padding: EdgeInsets.only(left: 6.h),
                          child: Text(
                            "快速註冊",
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

  /// 分隔線組件
  Widget _buildRowLineSixteen(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.v),
          child: SizedBox(
            width: 135.h,
            child: Divider(), // 左側分隔線
          ),
        ),
        Text(
          "OR",
          style: CustomTextStyles.titleMediumLightgreen300,
        ),
        Padding(
          padding: EdgeInsets.only(
            top: 10.v,
            bottom: 9.v,
          ),
          child: SizedBox(
            width: 135.h,
            child: Divider(), // 右側分隔線
          ),
        )
      ],
    );
  }

  /// 當觸發該操作時，導航至 forgetpwdScreen。
  onTapforgetPWD(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.forgetpwdScreen);
  }

  /// 當觸發該操作時，導航至 registerScreen。
  onTapsignup(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.registerScreen);
  }

  /// 預留的登入函數
  void login(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.diaryMainScreen);
  }
}

/*
1. 輸入文字改黑色
*/