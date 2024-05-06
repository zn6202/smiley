// 引入 Flutter 相關的庫，提供 Material Design 的組件和功能
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 自訂的應用程式組件匯入
import 'core/app_export.dart';

// 建立一個全域的 ScaffoldMessengerState 鍵，以用於顯示通知訊息
var globalMessengerKey = GlobalKey<ScaffoldMessengerState>();

// 程式入口，定義 main 函數
void main() {
  // 確保在執行框架相關的任何操作之前 Flutter 綁定已經初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 鎖定應用程式方向為豎屏（portrait）
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // 呼叫自訂的主題助手，切換到 "primary" 主題
  ThemeHelper().changeTheme('primary');

  // 啟動 Flutter 應用程式
  runApp(MyApp());
}

// 自訂應用程式的主組件 MyApp
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 使用 Sizer 組件處理應用的尺寸和設備類型，讓應用程式適應不同的設備
    return Sizer(
      builder: (context, orientation, deviceType) {
        // 回傳 MaterialApp 組件作為應用程式的根組件
        return MaterialApp(
          // 設定應用的主題
          theme: theme,

          // 設定應用程式的標題
          title: 'smiley',

          // 隱藏除錯模式的標籤
          debugShowCheckedModeBanner: false,

          // 設定應用的初始路徑
          initialRoute: AppRoutes.loginScreen,

          // 設定應用程式的路由
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
