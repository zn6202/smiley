import 'package:flutter/material.dart';
import '../../core/app_export.dart'; // 應用程式導出模組
import '../../widgets/custom_elevated_button.dart'; // 自訂的高架按鈕元件
import '../../widgets/custom_icon_button.dart'; // 自訂的圖示按鈕元件
import '../../widgets/custom_text_form_field.dart'; // 自訂的文字輸入欄位元件

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';


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

  // 錯誤訊息
  String? errorMessage;
  String? firebaseId;


  Future<void> createUserWithEmailAndPassword() async {
    try {
      if (passwordOneController.text.trim() != confirmPasswordController.text.trim()) {
        setState(() {
          errorMessage = '該密碼不一致';
        });
      }else{
      // 呼叫Firebase的createUserWithEmailAndPassword()方法
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailAddressController.text.trim(), // 取得使用者輸入的電子郵件
          password: passwordOneController.text.trim(), // 取得使用者輸入的密碼
        );
        // 如果成功建立新帳戶，credential 將包含用戶的驗證資訊
        // 這裡您可以添加任何註冊成功後的後續操作
        firebaseId = credential.user?.uid;
        print('註冊成功! 使用者的ID: ${firebaseId}');
        // 登入成功後導航到下一個畫面，這裡假設登入成功後要跳轉到首頁
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('firebaseId', firebaseId!);

        Navigator.pushNamed(context, AppRoutes.setNamePhoto);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') { // 至少6個字元
        setState(() {
          errorMessage = '提供的密碼太弱 (至少 6 碼)';
        });
      } else if (e.code == 'email-already-in-use') {
        setState(() {
          errorMessage = '該電子郵件地址已經被使用';
        });
      } else if (e.code == 'invalid-email') {
        setState(() {
          errorMessage = '該電子郵件格式不正確';
        });
      } else if (emailAddressController.text.isEmpty) {
        setState(() {
          errorMessage = '電子郵件尚未填寫';
        });
      } else if (passwordOneController.text.isEmpty) {
        setState(() {
          errorMessage = '密碼尚未填寫';
        });
      } else {
        setState(() {
          errorMessage = '發生了一些錯誤：$e';
        });
      }
    }
  }

  // google 註冊(如果已經註冊過就會直接登入)
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
      );
      
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      // 確認使用者 id
      firebaseId = credential.idToken;
      print("註冊成功! 使用者的ID: ${firebaseId}");

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('firebaseId', firebaseId!);

      if (isNewUser) {
        print("使用者是新註冊的");
        // 新註冊用戶，導航到 setNamePhoto
        Navigator.pushNamed(context, AppRoutes.setNamePhoto);
      } else {
        print("使用者已經註冊過");
        // 已註冊過的用戶，導航到 diaryMainScreen
        Navigator.pushNamed(context, AppRoutes.homeScreen);
      }
    } catch (e) {
      print('Google sign in error: $e');
      // 處理登入錯誤
      // 可以顯示錯誤訊息給用戶或者執行其他處理邏輯
    }
  }


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
                  SizedBox(height: 20.v),
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
                  SizedBox(height: 28.v),
                  Column(
                    children: [
                      // 歡迎訊息
                      Text(
                        "Welcome to SMILEY",
                        style: theme.textTheme.headlineLarge,
                      ),
                      SizedBox(
                        height: 48.v,
                        child: Center(
                          child: errorMessage != null
                              ? Text(
                                  errorMessage!,
                                  style: TextStyle(color: Colors.red),
                                )
                              : null,
                        ),
                      ),

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
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
      textStyle: TextStyle(color: Colors.black), // 設定文本顏色為黑色
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
      textStyle: TextStyle(color: Colors.black), // 設定文本顏色為黑色
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
      textStyle: TextStyle(color: Colors.black), // 設定文本顏色為黑色ㄇ
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

  /// 註冊按鈕
  Widget _buildRegisterButton(BuildContext context) {
    return CustomElevatedButton(
      width: 114.h,
      text: "註冊",
      onPressed: () {
        createUserWithEmailAndPassword();
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
          style: CustomTextStyles.titleMediumLightgreen300,
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


}

/* 
1. 可視不可視圖標大小有差
2. fb 註冊鈕刪掉
 */