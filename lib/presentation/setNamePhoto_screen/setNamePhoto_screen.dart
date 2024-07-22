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
import 'defaultAvatar.dart';

class SetNamePhoto extends StatefulWidget {
  final String? sourcePage;

  SetNamePhoto({this.sourcePage});

  @override
  _SetNamePhotoState createState() => _SetNamePhotoState();
}

// 設置名稱和照片頁面的狀態
class _SetNamePhotoState extends State<SetNamePhoto> {
  final TextEditingController _controller = TextEditingController(); // 控制輸入框
  File? _image; // 選擇的相簿的照片檔
  String? firebaseId; // Firebase用戶ID
  String? sourcePage; // 紀錄導航來源頁面
  final picker = ImagePicker(); // 圖片選擇器實例
  String?
      selectedAvatarPath; // 選擇的預設頭像路徑(從 defaultAvatar.dart 傳來的預設圖片路徑，沒選擇的話就是 dafault_avatar_9 )
  String? defaultUserName;

  @override
  void initState() {
    super.initState();
    sourcePage = widget.sourcePage;
    loadAvatarPath();
    loadUserName();
  }

  Future<void> loadAvatarPath() async {
    selectedAvatarPath = await getSavedAvatarPath();
    print("頭貼為: $selectedAvatarPath");
    if (mounted) {
      setState(() {});
    }
  }

  Future<String?> getSavedAvatarPath() async {
    final Avatar = await SharedPreferences.getInstance();
    return Avatar.getString('selected_avatar_path');
  }

  Future<void> saveUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', userName);
    print("user_name 放入 share_preference: $userName");
  }

  Future<void> loadUserName() async {
    defaultUserName = await getDefaultUserName();
    print('預設姓名為: $defaultUserName');
    _controller.text = defaultUserName ?? '';
    if (mounted) {
      setState(() {});
    }
  }

  Future<String?> getDefaultUserName() async {
    final Name = await SharedPreferences.getInstance();
    return Name.getString('user_name');
  }

  // 保存用戶ID到本地存儲
  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
    print("user_id: $userId");
  }

  // 從本地存儲獲取用戶ID
  Future<String?> getUserId() async {
    final userId = await SharedPreferences.getInstance();
    return userId.getString('user_id');
  }

  Future<String?> getFirebaseId() async {
    final Avatar = await SharedPreferences.getInstance();
    return Avatar.getString('firebaseId');
  }

  // 添加完成的處理函數
  void addComplete() async {
    // 獲取導航傳遞過來的Firebase UID
    firebaseId = await getFirebaseId();
    print('firebaseId = $firebaseId');
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
      _image != null ? _image!.path.split('/').last : selectedAvatarPath!,
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
      print('Using default image: ${selectedAvatarPath}');
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
  // 從設定進到 編輯
  void editProfile() async {
    final String? id = await getUserId();
    if (id == null) {
      // 處理 user_id 為空的情況
      print('Error: user_id is null');
      return;
    }

    print("進入修改個資函式 id:$id; name:$_controller.text; photo:$selectedAvatarPath");
    final response = await http.post(
      Uri.parse(API.editProfile), // 解析字串變成 URI 對象
      body: {
        'id': id,
        'name': _controller.text,
        'photo':selectedAvatarPath ?? '',
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success']) {
        setState(() {
          defaultUserName = responseData['name'];
          selectedAvatarPath = responseData['photo'];
        });
        await saveUserName(responseData['name']);
        print('User name: ${responseData['name']}');
        print('User photo path: ${responseData['photo']}');
        // 在這裡處理獲取到的用戶名稱和照片資訊
      } else {
        print('更新個資取得失敗: ${responseData['message']}');
      }
    } else {
      print('更新個資失敗...');
    }
  }
/*
  // 選擇圖片的函數
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // 更新狀態以顯示選擇的圖片
      });
    }
  }
*/
  Future<void> navigateToDefaultAvatar() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => Defaultavatar(sourcePage: sourcePage),
      ),
    );
    if (result != null) {
      setState(() {
        selectedAvatarPath = result;
        _image = null; // 清除之前選擇的相冊圖片
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
                    onTap: navigateToDefaultAvatar,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFFF4F4E6),
                      backgroundImage: _image != null
                        ? FileImage(_image!)
                        : selectedAvatarPath != null
                          ? AssetImage('assets/images/$selectedAvatarPath') as ImageProvider<Object>
                          : AssetImage('assets/images/default_avatar_9.png') as ImageProvider<Object>,
                    ),  
                  ),
                  /* 
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
                  ), */
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
                  hintText:'me', // 提示文字
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
                  // 設定 ->
                  if (sourcePage == 'setting') {
                    FocusScope.of(context).requestFocus(FocusNode());
                    await Future.delayed(Duration(milliseconds: 500));
                    editProfile();
                    print("用戶名: ${_controller.text}");
                    // Navigator.pop(context); // 返回上一頁
                    Navigator.pushNamed(
                        context, AppRoutes.setting);
                  // 註冊 ->
                  } else {
                    FocusScope.of(context).requestFocus(FocusNode());
                    await Future.delayed(Duration(milliseconds: 500));
                    addComplete();
                    print("用戶名: ${_controller.text}");
                    Navigator.pushNamed(
                        context, AppRoutes.diaryMainScreen); // 導航到日記主頁
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
