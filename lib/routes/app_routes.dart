import 'package:flutter/material.dart';
// 自訂的核心應用程式功能和庫的引入
import '../presentation/forgetpwd_screen/forgetpwd_screen.dart'; // 引入忘記密碼頁面組件
import '../presentation/login_screen/login_screen.dart'; // 引入登入頁面組件
import '../presentation/register_screen/register_screen.dart'; // 引入註冊頁面組件
import '../presentation/welcome_screen/welcome_screen.dart'; // 引入歡迎頁面組件
import '../presentation/diarymain_screen/diarymain_screen.dart'; // 引入日記頁面組件
import '../presentation/AddDiary_screen/AddDiary_screen.dart'; // 引入寫日記頁面組件
import '../presentation/setNamePhoto_screen/setNamePhoto_screen.dart'; //引入設定姓名照片頁面組件
import '../presentation/setting_screen/setting_screen.dart'; //引入設定頁面組件
import '../presentation/analysis_screen/analysis_screen.dart';
import '../presentation/setNamePhoto_screen/defaultAvatar.dart';
// import '../presentation/setNamePhoto_screen/edit.dart';
import '../presentation/friend_screen/friendScreen.dart';
import '../presentation/postRecord_screen/postRecord.dart';
import '../presentation/notification_screen/notification.dart';
import '../presentation/friend_screen/addFriend.dart';

class AppRoutes {
  static const String welcomeScreen = '/welcome_screen';
  static const String loginScreen = '/login_screen';
  static const String forgetpwdScreen = '/forgetpwd_screen';
  static const String registerScreen = '/register_screen';
  static const String diaryMainScreen = '/diary_main_screen';
  static const String addDiaryScreen = '/AddDiary_screen';
  static const String setNamePhoto = '/setNamePhoto_screen';
  static const String setting = '/setting_screen';
  static const String analysis = '/analysis_screen';
  static const String defaultAvatar = '/default_avatar';
  static const String friendScreen = '/friend_screen';
  static const String postRecord = '/post_record';
  static const String notificationScreen = '/notification_screen';
  static const String addFriend = '/add_friend';
  // static const String edit = '/edit';

  static Map<String, WidgetBuilder> routes = {
    welcomeScreen: (context) => WelcomeScreen(),
    loginScreen: (context) => LoginScreen(),
    forgetpwdScreen: (context) => ForgetpwdScreen(),
    registerScreen: (context) => RegisterScreen(),
    diaryMainScreen: (context) => DiaryMainScreen(),
    addDiaryScreen: (context) => AddDiaryScreen(),
    setNamePhoto: (context) => SetNamePhoto(),
    setting: (context) => settingScreen(),
    analysis: (context) => AnalysisScreen(),
    defaultAvatar: (context) => Defaultavatar(),
    friendScreen: (context) => Friendscreen(), 
    postRecord: (context) => Postrecord(),
    notificationScreen: (context) => Notificationscreen(),
    addFriend: (context) => AddFriend(),
    // edit: (context) => EditScreen(),
  };
}


