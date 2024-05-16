import 'package:flutter/material.dart';
// 自訂的核心應用程式功能和庫的引入
import '../presentation/forgetpwd_screen/forgetpwd_screen.dart'; // 引入忘記密碼頁面組件
import '../presentation/login_screen/login_screen.dart'; // 引入登入頁面組件
import '../presentation/register_screen/register_screen.dart'; // 引入註冊頁面組件
import '../presentation/welcome_screen/welcome_screen.dart'; // 引入歡迎頁面組件
import '../presentation/diarymain_screen/diarymain_screen.dart'; // 引入日記頁面組件
import '../presentation/AddDiary_screen/AddDiary_screen.dart'; // 引入日記頁面組件

// ignore_for_file: must_be_immutable  // 忽略不可變性的警告，通常不建議在生產代碼中使用

// 定義應用中的路由
class AppRoutes {
  // 定義各個頁面的路由名稱常量
  static const String welcomeScreen = '/welcome_screen';
  static const String loginScreen = '/login_screen';
  static const String forgetpwdScreen = '/forgetpwd_screen';
  static const String registerScreen = '/register_screen';
  static const String diaryMainScreen = '/diary_main_screen';
  static const String addDiaryScreen = '/AddDiary_screen';
  
  // 路由表，將路由名稱映射到對應的頁面建造者
  static Map<String, WidgetBuilder> routes = {
    welcomeScreen: (context) => WelcomeScreen(), // 歡迎頁面
    loginScreen: (context) => LoginScreen(), // 登入頁面
    forgetpwdScreen: (context) => ForgetpwdScreen(), // 忘記密碼頁面
    registerScreen: (context) => RegisterScreen(), // 註冊頁面
    diaryMainScreen: (context) => DiaryMainScreen(), // 日記頁面
    addDiaryScreen: (context) => AddDiaryScreen(),
  };
}
