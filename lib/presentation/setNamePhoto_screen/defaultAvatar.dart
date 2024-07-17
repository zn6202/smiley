import 'dart:io'; // Import the 'dart:io' package for the 'File' class
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_export.dart'; // 應用程式導出模組
import '../../widgets/app_bar/appbar_leading_image.dart'; // 自定義應用欄返回按鈕
import 'package:http/http.dart' as http; // HTTP請求插件
import '../setNamePhoto_screen/setNamePhoto_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 引入 SharedPreferences
import 'package:image_picker/image_picker.dart';

const TextStyle dialogTitleStyle = TextStyle(
    color: Color(0xFF545453),
    fontSize: 25,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w100,
    letterSpacing: -0.32);

const TextStyle dialogContentStyle = TextStyle(
    color: Color(0xFF545453),
    fontSize: 16,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w100,
    letterSpacing: -0.32);


class Defaultavatar extends StatefulWidget {
  final String? sourcePage;

  Defaultavatar({this.sourcePage});

  @override
  _DefaultavatarState createState() => _DefaultavatarState();
}

class _DefaultavatarState extends State<Defaultavatar> {
  File? _image; // 選擇的相簿的照片檔
  final picker = ImagePicker(); // 圖片選擇器實例
  final List<String> avatarImages = [
    'assets/images/default_avatar_1.png',
    'assets/images/default_avatar_2.png',
    'assets/images/default_avatar_3.png',
    'assets/images/default_avatar_4.png',
    'assets/images/default_avatar_5.png',
    'assets/images/default_avatar_6.png',
    'assets/images/default_avatar_7.png',
    'assets/images/default_avatar_8.png',
    'assets/images/default_avatar_9.png',
  ];

  // 將選擇的頭像路徑發送到 setNamePhoto
  Future<void> sendAvatarPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    String avatarName = path.split('/').last;
    await prefs.setString('selected_avatar_path', avatarName);
  
    Navigator.pop(context, avatarName);
  }


  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // 更新狀態以顯示選擇的圖片
      });
    }
  }

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
          'assets/images/default_avatar_icon.png',
          height: 30, // 您可以根據需要調整圖片的高度
        ),
        centerTitle: true, // 將圖片設置為居中
      ),
      body: Center(
        child: GridView.builder(
          padding: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 每行顯示三個圓形圖像
            crossAxisSpacing: 20.0, // 圖像之間的水平間距
            mainAxisSpacing: 20.0, // 圖像之間的垂直間距
          ),
          itemCount: avatarImages.length + 1, // 加一個顯示相機圖標的白底圓形圖
          itemBuilder: (context, index) {
            if (index == avatarImages.length) {
              // 顯示相機圖標的白底圓形圖
              return GestureDetector(
                onTap: _pickImage, // 點擊選擇圖片
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7), // 底色#FFFFFF 透明度70%
                    shape: BoxShape.circle, // 圓形背景
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10.0), // 圓形容器內的間距
                    child: Icon(
                      Icons.camera_alt,
                      color: Color(0xFFA7BA89), // 圖標顏色 // 設置相機圖標顏色
                      size: 40, // 設置相機圖標大小
                    ),
                  ),
                ),
              );
            } else {
              return GestureDetector(
                onTap: () {
                  sendAvatarPath(avatarImages[index]);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7), // 底色#FFFFFF 透明度70%
                    shape: BoxShape.circle, // 圓形背景
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10.0), // 圓形容器內的間距
                    child: Image.asset(
                      avatarImages[index],
                      fit: BoxFit.contain, // 圖片的適應方式
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

/*
後端：
- 本機照片的處理
- 在這頁選好後 不要直接傳到資料庫更改 等到回saveNamePhoto時 使用者按確定更改再改

*/