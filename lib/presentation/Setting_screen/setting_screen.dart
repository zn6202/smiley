import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../widgets/bottom_navigation.dart'; // 引用自訂的 BottomNavigationBar
import 'package:firebase_auth/firebase_auth.dart';
import '../../main.dart';

// 主題色彩常數，用於應用程式中的主色調。
const Color primaryColor = Color(0xFFA7BA89);
const Color backgroundColor = Color(0xFFF4F4E6);

// 日記主畫面的 StatefulWidget。
class settingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

// SettingScreen 的狀態管理類別，管理小部件的狀態。
class _SettingScreenState extends State<settingScreen> {
  int _currentIndex = 4; // 記錄当前選擇的頁面索引。

  /*
  Future<bool> _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      print("登出成功");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
        (route) => false,
      );
      return true;
    } catch (e) {
      print('signOut->$e');
      return false;
    }
  }
  */

  @override
  // 構建主要小部件結構。
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold 提供一個架構以布局主要組件。
      body: Container(
        color: backgroundColor, // 修改背景顏色。
        child: SafeArea(
          // SafeArea 確保內容顯示在顯示器安全區域邊界內。
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 在列中居中對齊內容。
            children: [
              _buildProfileSection(),
              Expanded(
                flex: 1,
                child: _buildOptionsGrid(), // 構建並顯示選項網格的小部件。
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  // 構建個人資料部分小部件。
  Widget _buildProfileSection() {
    return Container(
      color: backgroundColor, // 修改背景顏色。
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.yellow, // 你的圖像背景顏色
            child: Text(
              ':)', // 圖像內的文字
              style: TextStyle(fontSize: 40.0), // 文字樣式
            ),
          ),
          SizedBox(height: 8.0), // 增加一個固定高度的空間
          Container(
            width: 112, // 設置寬度為 112
            height: 22, // 設置高度為 22
            decoration: BoxDecoration(
              color: primaryColor, // 背景顏色
              borderRadius: BorderRadius.circular(20.0), // 圓角
            ),
            child: Center(
              child: Text(
                'name',
                style: TextStyle(
                  fontSize: 16.0, // 字體大小
                  color: Colors.white, // 字體顏色
                ),
              ),
            ),
          ),
          SizedBox(height: 8.0), // 增加一個固定高度的空間
          Text(
            'me', // 用戶名
            style: TextStyle(
              fontSize: 20.0, // 字體大小
              color: Colors.black, // 字體顏色
            ),
          ),
          Text(
            '320', // 用戶 ID
            style: TextStyle(
              fontSize: 16.0, // 字體大小
              color: Colors.grey, // 字體顏色
            ),
          ),
        ],
      ),
    );
  }

  // 構建選項網格小部件。
  Widget _buildOptionsGrid() {
    return GridView.count(
      crossAxisCount: 2, // 每行顯示兩個網格
      padding: EdgeInsets.all(60.0), // 外邊距
      crossAxisSpacing: 20.0, // 水平間距
      mainAxisSpacing: 20.0, // 垂直間距
      children: [
        _buildGridOption('assets/images/Record.png', '貼文記錄'), // 貼文記錄選項
        _buildGridOption('assets/images/friend.png', '好友'), // 好友選項
        _buildGridOption('assets/images/edit.png', '編輯'), // 編輯選項
        _buildGridOption('assets/images/notify.png', '通知中心'), // 通知中心選項
        // _buildGridOption('assets/images/logout.png', '登出', _handleLogout), // 登出選項，帶有登出處理
      ],
    );
  }

  // 構建網格選項小部件。
  Widget _buildGridOption(String imagePath, String label, [Function? onTap]) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap(context); // 如果有點擊事件，則調用它
        }
      },
      child: Container(
        width: 117, // 設置寬度為 117
        height: 92, // 設置高度為 92
        decoration: BoxDecoration(
          color: Colors.white, // 背景顏色
          borderRadius: BorderRadius.circular(15.0), // 圓角
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 內容垂直居中
          children: [
            Image.asset(
              imagePath, // 圖標圖片路徑
              width: 40.0, // 圖片寬度
              height: 40.0, // 圖片高度
            ),
            SizedBox(height: 8.0), // 增加一個固定高度的空間
            Text(
              label, // 標籤文字
              style: TextStyle(
                fontSize: 16.0, // 字體大小
                color: Color(0xFFA7BA89), // 字體顏色
              ),
            ),
          ],
        ),
      ),
    );
  }
}