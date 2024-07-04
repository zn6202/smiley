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

class SetNamePhotoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SetNamePhoto(),
    );
  }
}

class SetNamePhoto extends StatefulWidget {
  @override
  _SetNamePhotoState createState() => _SetNamePhotoState();
}

class _SetNamePhotoState extends State<SetNamePhoto> {
  final TextEditingController _controller = TextEditingController();
  File? _image;
  String? firebaseId;
  final picker = ImagePicker();

  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
    print("usesr_id: $userId");
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  void addComplete() async {
    firebaseId = ModalRoute.of(context)!.settings.arguments as String?;  // 獲取 Firebase UID
    if (firebaseId == null) {
      print('Error: firebaseId is null');
      return;
    }

    final uri = Uri.parse(API.user);  // user.php
    print('Sending request to: $uri');
    var request = http.MultipartRequest('POST', uri); // 對 user.php 發送 POST 請求

    // 創建 User 對象
    User user = User(
      0,
      firebaseId!,
      _controller.text.trim(),
      _image != null ? _image!.path.split('/').last : 'default_avatar.png',
    );

    // 添加文本字段到請求
    user.toJson().forEach((key, value) {
      request.fields[key] = value;
    });
    print('Request fields: ${request.fields}');

    if (_image != null) {
      var pic = await http.MultipartFile.fromPath("photo", _image!.path); // 選擇的圖片數據
      request.files.add(pic); // 加到 http 請求文件上
      print('Image Path: ${_image!.path}');
    } else {
      request.fields['default_photo'] = 'true'; // 標識使用默認圖片
      print('Using default image: default_avatar.png');
    }

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

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5DC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : AssetImage('assets/images/default_avatar.png')
                          as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.camera_alt,
                        color: Color(0xFFA7BA89),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              width: 254,
              height: 44,
              child: TextField(
                controller: _controller,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Color(0xFFA7BA89)),
                  hintText: 'me',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: 114,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  addComplete();
                  print("用戶名: ${_controller.text}");
                  Navigator.pushNamed(context, AppRoutes.diaryMainScreen);
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
                  backgroundColor: Color(0xFFA7BA89),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
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