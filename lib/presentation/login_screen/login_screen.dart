import 'dart:convert'; //jsonDecode
import 'package:flutter/material.dart';
import 'package:smiley/presentation/seller_screen/shome_screen.dart';
import 'package:smiley/presentation/home_screen/home_screen.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_icon_button.dart';
import '../../widgets/custom_text_form_field.dart'; // 忽略文件: 必須是可變的

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../diarymain_screen/diarymain_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../routes/api_connection.dart';

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
  String? firebaseId;
  String? status;

  Future<void> saveStatus(String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('status', status);
  }

  Future<String?> getStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('status') ?? '';
  }

  void signInWithEmailAndPassword() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      print('登入成功! 使用者的ID: ${credential.user?.uid}');

      // 從伺服器獲取 user_id 並存儲到 SharedPreferences
      await _fetchAndSaveUserId(credential.user?.uid);

      status = 'member';
      await saveStatus(status!);
      if (credential.user?.uid == 'MCYFz55dsAgMwmyoH3fIcmkqMpb2'){
        print('我的身分是賣家');
        Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ShomeScreen()), // Friendscreen() 要修改成賣家頁面~
        );
      }else{
        Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => DiaryMainScreen()),
      // );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = '帳號密碼輸入錯誤';
      });
    }
  }

  /// Google 登入 (如果已經註冊過就會直接登入)
  Future<void> signInWithGoogle() async {
    try {
      // Google 登入並取得使用者資訊
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        print('Google 登入取消');
        return;
      }

      final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;

      // 使用獲取到的 Google 凭證登入 Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // 使用憑證登入 Firebase 並取得 UserCredential
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // 從 userCredential 中提取 Firebase UID
      final String firebaseUid = userCredential.user?.uid ?? '';
      if (firebaseUid.isEmpty) {
        print('獲取 Firebase UID 失敗');
        return;
      }

      print("登入成功! 使用者的 Firebase UID: $firebaseUid");

      // 從伺服器獲取 user_id 並存儲到 SharedPreferences
      await _fetchAndSaveUserId(firebaseUid);

      status = 'member';
      await saveStatus(status!);

      // 登入成功後導航到 DiaryMainScreen
      _navigateToHomeScreen();
    } catch (e) {
      print('Google sign in error: $e');
      // 處理登入錯誤，可以顯示錯誤訊息給用戶或者執行其他處理邏輯
    }
  }

  Future<void> _fetchAndSaveUserId(String? firebaseUid) async {
    try {
      final response = await http.post(
        Uri.parse(API.getUid), // 替換為你的 API 路徑
        body: {
          'firebase_user_id': firebaseUid,
        },
      );

      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          int userId = responseData['user_id'];

          // 存儲 user_id 到 SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_id', userId.toString());

          print('user_id 儲存成功: $userId');
        } else {
          print('伺服器返回錯誤: ${responseData['message']}');
        }
      } else {
        print('請求失敗，狀態碼: ${response.statusCode}');
      }
    } catch (e) {
      print('HTTP 請求或 JSON 解析錯誤: $e');
      // 顯示錯誤訊息給用戶或執行其他處理邏輯
    }
  }

  void _navigateToHomeScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
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
                  SizedBox(height: 20.v), // 上方間距
                  // Logo 排版區域
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 34.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // 水平置中
                      children: [
                        Image.asset(
                          'assets/images/login-logo.png',
                          width: 262.h,
                          height: 90.v,
                          fit: BoxFit.contain,
                        ),
                        // 第一個 Logo 圖像
                        // CustomImageView(
                        //   imagePath: ImageConstant.imgExport1,
                        //   height: 92.v,
                        //   width: 80.h,
                        // ),
                        // // 第二個 Logo 圖像
                        // CustomImageView(
                        //   imagePath: ImageConstant.imgExport3,
                        //   height: 92.v,
                        //   width: 101.h,
                        // ),
                        // // 第三個 Logo 圖像
                        // CustomImageView(
                        //   imagePath: ImageConstant.imgExport2,
                        //   height: 92.v,
                        //   width: 79.h,
                        // )
                      ],
                    ),
                  ),
                  SizedBox(height: 28.v), // 上方間距
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
                              ? ImageConstant
                                  .imgEyeopenfilledsvgrepocom // 可視狀態的圖示
                              : ImageConstant
                                  .imgEyecancelledfilledsvgrepocom1, // 不可視狀態的圖示
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
}

/*
1. logo被切 左右*/