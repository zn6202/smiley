import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/app_export.dart';

// 定義一個無狀態小部件 SetNamePhotoApp
class SetNamePhotoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SetNamePhoto(), // 設定首頁為 SetNamePhoto
    );
  }
}

// 定義一個有狀態的小部件 SetNamePhoto
class SetNamePhoto extends StatefulWidget {
  @override
  _SetNamePhotoState createState() => _SetNamePhotoState();
}

// 定義一個方法，用於完成後跳轉到日記主頁
void addComplete(BuildContext context) {
  Navigator.pushNamed(context, AppRoutes.diaryMainScreen);
}

// 定義 SetNamePhoto 的狀態類
class _SetNamePhotoState extends State<SetNamePhoto> {
  final TextEditingController _controller = TextEditingController(); // 控制文本輸入的控制器
  File? _image; // 用於存儲選擇的圖片文件

  // 定義一個異步方法，用於從相冊中選擇圖片
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery); // 從相冊中選擇圖片

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // 如果選擇了圖片，更新狀態
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5DC), // 設定背景顏色
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 垂直方向居中
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50, // 設定圓形頭像的半徑
                  backgroundImage: _image != null
                      ? FileImage(_image!) // 如果有選擇圖片，顯示選擇的圖片
                      : AssetImage('assets/images/default_avatar.png')
                          as ImageProvider, // 否則顯示默認頭像
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage, // 點擊時調用 _pickImage 方法
                    child: CircleAvatar(
                      radius: 15, // 設定小圓形圖標的半徑
                      backgroundColor: Colors.white, // 背景顏色為白色
                      child: Icon(
                        Icons.camera_alt, // 相機圖標
                        color: Color(0xFFA7BA89), // 圖標顏色
                        size: 20, // 圖標大小
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // 增加垂直間距
            Container(
              width: 254,
              height: 44,
              child: TextField(
                controller: _controller, // 綁定文本輸入控制器
                textAlignVertical: TextAlignVertical.center, // 垂直方向居中
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Color(0xFFA7BA89)), // 前置圖標
                  hintText: 'me', // 提示文字
                  filled: true,
                  fillColor: Colors.white, // 背景顏色
                  contentPadding: EdgeInsets.symmetric(vertical: 0), // 調整內邊距以垂直居中
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20), // 圓角邊框
                    borderSide: BorderSide.none, // 無邊框線
                  ),
                ),
              ),
            ),
            SizedBox(height: 20), // 增加垂直間距
            Container(
              width: 114,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  addComplete(context); // 點擊按鈕時調用 addComplete 方法
                  print("用戶名: ${_controller.text}"); // 在控制台打印用戶名
                },
                child: Text(
                  '確認更改', // 按鈕文字
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600, // 半粗體
                    fontSize: 18,
                    color: Colors.white, // 文字顏色
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFA7BA89), // 按鈕背景顏色
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // 圓角按鈕
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
1. 三元件間的寬度與大小未調
2. 未連接資料庫
*/