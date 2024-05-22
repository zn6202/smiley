import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../widgets/app_bar/appbar_leading_image.dart';
import '../../widgets/app_bar/appbar_title.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_text_form_field.dart';


import 'package:firebase_auth/firebase_auth.dart';
import '../login_screen/login_screen.dart';


// 忽略「不可變」的警告
// ignore_for_file: must_be_immutable

/// 忘記密碼畫面，採用無狀態（Stateless）的小部件
class ForgetpwdScreen extends StatelessWidget {
  ForgetpwdScreen({Key? key}) : super(key: key);

  // 建立電子郵件地址的文字編輯控制器
  TextEditingController emailaddressController = TextEditingController();

  // 發送驗證信至該 email
  Future<void> sendPasswordResetLink(context) async{
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailaddressController.text.trim()
      );
    } catch (e) {
      print(e.toString);
    }
  }
  /// 構建畫面
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false, // 當鍵盤出現時保持佈局
        appBar: _buildAppBar(context), // 建立自訂 App Bar
        body: Container(
          width: double.maxFinite, // 設定寬度為可使用的最大寬度
          padding: EdgeInsets.only(
            // 設定內邊距
            left: 30.h,
            top: 95.v,
            right: 30.h,
          ),
          // 使用 Column 來排列元件
          child: Column(
            children: [
              // 電子郵件輸入欄位
              CustomTextFormField(
                controller: emailaddressController, // 關聯控制器
                hintText: "電子郵件地址...", // 提示文字
                textStyle: TextStyle(color: Colors.black), // 設定文本顏色為黑色ㄇ
                textInputAction: TextInputAction.done, // 輸入完成後的操作
                // 設定前綴圖標
                prefix: Container(
                  margin: EdgeInsets.fromLTRB(20.h, 11.v, 10.h, 11.v), // 設定內邊距
                  child: CustomImageView(
                    imagePath: ImageConstant.imgLock, // 圖標圖片
                    height: 20.v, // 高度
                    width: 26.h, // 寬度
                  ),
                ),
                prefixConstraints: BoxConstraints(
                  // 設定最大高度
                  maxHeight: 44.v,
                ),
              ),
              // 設定垂直間距
              SizedBox(height: 34.v),
              // 發送驗證碼按鈕
              CustomElevatedButton(
                width: 114.h, // 設定按鈕寬度
                text: "發送驗證信", // 按鈕文字
                onPressed: () {
                  sendPasswordResetLink(context); //發送驗證信
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("驗證信已發送至該電子信箱")));
                  Navigator.pop(context,MaterialPageRoute(builder: (context) => LoginScreen()),); // 跳回 loginScreen
                },
              ),
              // 設定垂直間距
              SizedBox(height: 5.v),
            ],
          ),
        ),
      ),
    );
  }

  /// 建立自訂的 App Bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return CustomAppBar(
      leadingWidth: 50.h, // 設定返回圖標的寬度
      leading: AppbarLeadingImage(
        imagePath: ImageConstant.imgArrowLeft, // 返回圖標圖片
        margin: EdgeInsets.only(
          // 設定內邊距
          left: 41.h,
          top: 19.v,
          bottom: 19.v,
        ),
        // 點擊返回按鈕時，呼叫 `onTapArrowleftone` 函數返回上一頁
        onTap: () {
          onTapArrowleftone(context);
        },
      ),
      centerTitle: true, // 標題居中
      // 設定 App Bar 標題
      title: AppbarTitle(
        text: "密碼找回",
      ),
    );
  }

  // 返回到上一個畫面
  void onTapArrowleftone(BuildContext context) {
    Navigator.pop(context); // 使用 Navigator 導航返回
  }
}


/*
1. 發送驗證碼後端未處理
 */