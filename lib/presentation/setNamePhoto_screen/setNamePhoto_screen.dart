import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/app_export.dart';
import 'package:http/http.dart' as http;
import '../../routes/api_connection.dart';
import '../../routes/user.dart'; // user model
import 'dart:convert'; // for jsonDecode
// 處理回應並存儲 user_id
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/app_bar/appbar_leading_image.dart'; // 自定義應用欄返回按鈕
class SetNamePhotoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SetNamePhoto(),
    );
  }
}

// 設置名稱和照片頁面的狀態管理
class SetNamePhoto extends StatefulWidget {
  @override
  _SetNamePhotoState createState() => _SetNamePhotoState();
}

// 設置名稱和照片頁面的狀態
class _SetNamePhotoState extends State<SetNamePhoto> {
  final TextEditingController _controller = TextEditingController(); // 控制輸入框
  File? _image; // 選擇的圖片文件
  String? firebaseId; // Firebase用戶ID
  String? sourcePage; // 紀錄導航來源頁面
  final picker = ImagePicker(); // 圖片選擇器實例
  String? selectedAvatarPath; // 選擇的預設頭像路徑


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 獲取 defaultAvatar 傳來的頭像資料
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is String) {
      selectedAvatarPath = arguments; // 獲取傳遞的圖片路徑
    }
    sourcePage = ModalRoute.of(context)?.settings.arguments as String?;
  }

  // 保存用戶ID到本地存儲
  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
    print("user_id: $userId");
  }

  // 從本地存儲獲取用戶ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  // 添加完成的處理函數
  void addComplete() async {
    // 獲取導航傳遞過來的Firebase UID
    firebaseId = ModalRoute.of(context)!.settings.arguments as String?;
    if (firebaseId == null) {
      print('Error: firebaseId is null');
      return;
    }

    // 設置請求的URI
    final uri = Uri.parse(API.user); // user.php
    print('Sending request to: $uri');
    var request = http.MultipartRequest('POST', uri); // 創建POST請求

    // 創建用戶對象
    User user = User(
      0,
      firebaseId!,
      _controller.text.trim(),
      _image != null ? _image!.path.split('/').last : selectedAvatarPath!.split('/').last,
    );

    // 添加文本字段到請求
    user.toJson().forEach((key, value) {
      request.fields[key] = value;
    });
    print('Request fields: ${request.fields}');

    // 如果有選擇圖片，添加圖片到請求
    if (_image != null) {
      var pic = await http.MultipartFile.fromPath("photo", _image!.path);
      request.files.add(pic);
      print('Image Path: ${_image!.path}');
    } else {
      // 使用默認圖片
      request.fields['default_photo'] = 'true';
      print('Using default image: default_avatar.png');
    }

    // 發送請求並處理回應
    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await http.Response.fromStream(response);
      var result = jsonDecode(responseData.body);

      if (result['success'] == true) {
        String userId = result['user_id'].toString();
        await saveUserId(userId);
        print("Congratulations, you are SignUp Successfully.");
      } else {
        print("Error Occurred: ${result['message']}");
      }
    } else {
      print('Failed to upload image, status code: ${response.statusCode}');
    }
  }

  // 選擇圖片的函數
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
      // 應用程式的頂部應用欄
      appBar: AppBar(
        elevation: 0, // 設置應用欄的陰影為0
        backgroundColor: Colors.transparent, // 設置背景透明
        // 根據來源頁面決定是否顯示返回按鈕
        leading: sourcePage == 'setting'
            ? AppbarLeadingImage(
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
              )
            : AppbarLeadingImage(
                imagePath: 'assets/images/null.png', // 返回圖標圖片
                ),
        // 正中間顯示圖片
        title: Image.asset(
          'assets/images/edit.png',
          height: 30, // 您可以根據需要調整圖片的高度
        ),
        centerTitle: true, // 將圖片設置為居中
      ),
      // 應用的主要內容
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 180.0),
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.defaultAvatar); 
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFFF4F4E6), // 設置圓形頭像背景顏色
                      backgroundImage: _image != null
                          ? FileImage(_image!) // 顯示選擇的圖片
                          : AssetImage('assets/images/default_avatar_9.png')
                              as ImageProvider, // 顯示默認頭像
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage, // 點擊選擇圖片
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.white, // 圓形背景顏色
                        child: Icon(
                          Icons.camera_alt,
                          color: Color(0xFFA7BA89), // 圖標顏色
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40), // 增加垂直間距
            Container(
              width: 254,
              height: 44,
              child: TextField(
                controller: _controller, // 設置控制器
                textAlignVertical: TextAlignVertical.center, // 文本垂直居中
                decoration: InputDecoration(
                  prefixIcon:
                      Icon(Icons.person, color: Color(0xFFA7BA89)), // 左側圖標
                  hintText: 'me', // 提示文字
                  filled: true,
                  fillColor: Colors.white, // 填充顏色
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20), // 圓角邊框
                    borderSide: BorderSide.none, // 無邊框線
                  ),
                ),
              ),
            ),
            SizedBox(height: 40), // 增加垂直間距
            Container(
              width: 114,
              height: 40,
              child: ElevatedButton(
                onPressed: () async {
                  if (sourcePage == 'setting') {
                    FocusScope.of(context).requestFocus(FocusNode());
                    await Future.delayed(Duration(milliseconds: 500));
                    addComplete();
                    print("用戶名: ${_controller.text}");
                    Navigator.pop(context); // 返回上一頁
                  } else {
                    FocusScope.of(context).requestFocus(FocusNode());
                    await Future.delayed(Duration(milliseconds: 500));
                    addComplete();
                    print("用戶名: ${_controller.text}");
                    Navigator.pushNamed(context, AppRoutes.diaryMainScreen); // 導航到日記主頁
                  }
                },
                child: Text(
                  '確認更改',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFA7BA89), // 按鈕背景顏色
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // 圓角形狀
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
給後端的備註
把註冊後設定頭貼與設定頁連接到同一頁
需再確認是否與後端連接好 */