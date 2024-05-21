// bottom_navigation.dart

import 'package:flutter/material.dart'; // 導入 Flutter 的 Material 包
import '../../core/app_export.dart'; // 導入自定義的應用程式導出包

class CustomBottomNavigationBar extends StatefulWidget { // 自定義底部導航欄的 StatefulWidget
  final int currentIndex; // 當前選中的索引
  final ValueChanged<int> onTap; // 當導航欄被點擊時的回調函數

  CustomBottomNavigationBar({required this.currentIndex, required this.onTap}); // 構造函數，接收當前索引和點擊回調

  @override
  _CustomBottomNavigationBarState createState() => _CustomBottomNavigationBarState(); // 創建狀態
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> { // 自定義底部導航欄的狀態
  late int _currentIndex = widget.currentIndex; // 初始化當前索引

  void _handleLogout() { // 處理登出的函數
    Navigator.pushNamed(context, AppRoutes.loginScreen); // 導航到登錄畫面
  }

  void _onTap(int index) { // 當導航欄項目被點擊時的處理函數
    if (index == 4) { // 如果點擊的是最後一個項目（設置）
      _handleLogout(); // 執行登出操作
    } else if (index == 2) { // 如果點擊的是第三個項目（日記）
      Navigator.pushNamed(context, AppRoutes.diaryMainScreen); // 導航到日記主頁面
    } else {
      widget.onTap(index); // 否則執行傳入的回調函數
    }
    setState(() {
      _currentIndex = index; // 更新當前選中的索引
    });
  }

  @override
  Widget build(BuildContext context) { // 構建部件
    return BottomNavigationBar( // 返回一個底部導航欄
      currentIndex: _currentIndex, // 設置當前選中的索引
      onTap: _onTap, // 設置點擊回調函數
      items: [ // 設置導航欄的項目
        BottomNavigationBarItem( // 第一個導航欄項目
          icon: Column( // 使用 Column 將圖標垂直居中
            mainAxisAlignment: MainAxisAlignment.center, // 垂直居中對齊
            children: [
              Image.asset(_currentIndex == 0 ? 'assets/images/chatRobot_on.png' : 'assets/images/chatRobot_off.png'), // 根據當前索引選擇對應的圖標
            ],
          ),
          label: '', // 移除文字標籤
        ),
        BottomNavigationBarItem( // 第二個導航欄項目
          icon: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(_currentIndex == 1 ? 'assets/images/analyze_on.png' : 'assets/images/analyze_off.png'), // 根據當前索引選擇對應的圖標
            ],
          ),
          label: '', // 移除文字標籤
        ),
        BottomNavigationBarItem( // 第三個導航欄項目
          icon: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(_currentIndex == 2 ? 'assets/images/diary_on.png' : 'assets/images/diary_off.png'), // 根據當前索引選擇對應的圖標
            ],
          ),
          label: '', // 移除文字標籤
        ),
        BottomNavigationBarItem( // 第四個導航欄項目
          icon: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(_currentIndex == 3 ? 'assets/images/social_on.png' : 'assets/images/social_off.png'), // 根據當前索引選擇對應的圖標
            ],
          ),
          label: '', // 移除文字標籤
        ),
        BottomNavigationBarItem( // 第五個導航欄項目
          icon: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(_currentIndex == 4 ? 'assets/images/setting_on.png' : 'assets/images/setting_off.png'), // 根據當前索引選擇對應的圖標
            ],
          ),
          label: '', // 移除文字標籤
        ),
      ],
      type: BottomNavigationBarType.fixed, // 設置導航欄類型為固定
    );
  }
}

/*
1. icon有點偏上
2. 大小不一 */