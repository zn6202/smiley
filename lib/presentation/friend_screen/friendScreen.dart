import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_export.dart'; // 應用程式導出模組
import '../../widgets/app_bar/appbar_leading_image.dart'; // 自定義應用欄返回按鈕
import 'package:http/http.dart' as http; // HTTP請求插件

class Friendscreen extends StatefulWidget {
  @override
  _friendscreenState createState() => _friendscreenState();
}

class _friendscreenState extends State<Friendscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFF4F4E6), // 設置背景顏色
        appBar: AppBar(
          elevation: 0, // 設置應用欄的陰影為0
          backgroundColor: Colors.transparent, // 設置背景透明
          leading: AppbarLeadingImage(
            imagePath: 'assets/images/arrow-left-g.png', // 返回圖標圖片
            margin: EdgeInsets.only(
              top: 19.0,
              bottom: 19.0,
            ),
            onTap: () async {
              FocusScope.of(context).requestFocus(FocusNode());
              await Future.delayed(Duration(milliseconds: 500));
              Navigator.pop(context); // 點擊返回按鈕返回上一頁
            },
          ),
          title: Image.asset(
            'assets/images/friend.png',
            height: 30, // 您可以根據需要調整圖片的高度
          ),
          centerTitle: true, // 將圖片設置為居中
        ));
  }
}