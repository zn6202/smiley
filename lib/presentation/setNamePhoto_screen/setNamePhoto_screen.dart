import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smiley/presentation/Setting_screen/setting_screen.dart';
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
  final File? image;

  SetNamePhoto({this.sourcePage, this.image});

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
  String? status;

  @override
  void initState() {
    super.initState();
    _image = widget.image; // 初始化 _image 為傳入的 image
    print("_image是:$_image");
    sourcePage = widget.sourcePage;
    loadAvatarPath();
    loadUserName();
    loadStatus();
  }

  Future<void> loadStatus() async {
    status = await getStatus();
    print("status 是: $status");
    if (mounted) {
      setState(() {});
    }
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

  Future<void> saveStatus(String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('status', status);
  }

  Future<String?> getStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('status') ?? '';
  }

  // Future<void> saveAlbumPhoto() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   String example = _image!.path;
  //   await prefs.setString('user_album_photo', _image!.path);
  //   print("user_album_photo: $example");
  // }

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
        // await saveAlbumPhoto(_image!.path);
        status = 'member';
        await saveStatus(status!);
        print("Congratulations, you are SignUp Successfully.");
        //在此添加保存图片到本地存储的程式
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
        'photo': selectedAvatarPath ?? '',
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
      backgroundColor: Color(0xFFF4F4E6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: status == 'member'
            ? IconButton(
                icon: SvgPicture.asset(
                  'assets/images/img_arrow_left.svg',
                  color: Color(0xFFA7BA89),
                ),
                onPressed: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  await Future.delayed(Duration(milliseconds: 500));
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => settingScreen(),
                    ),
                  );
                },
              )
            : AppbarLeadingImage(
                imagePath: 'assets/images/null.png',
              ),
        title: Image.asset(
          'assets/images/edit.png',
          height: 30.v,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 103.v),
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
                                  ? selectedAvatarPath!
                                          .startsWith('default_avatar')
                                      ? AssetImage(
                                              'assets/images/$selectedAvatarPath')
                                          as ImageProvider<Object>
                                      : NetworkImage(
                                              'http://163.22.32.24/smiley_backend/img/photo/$selectedAvatarPath')
                                          as ImageProvider<Object>
                                      // : NetworkImage(
                                      //         'http://192.168.56.1/smiley_backend/img/photo/$selectedAvatarPath')
                                      //     as ImageProvider<Object>
                                  : AssetImage(
                                          'assets/images/default_avatar_9.png')
                                      as ImageProvider<Object>,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.v),
                Container(
                  width: 254.h,
                  height: 44.v,
                  child: TextField(
                    controller: _controller,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person, color: Color(0xFFA7BA89)),
                      hintText: 'me',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(vertical: 0.v),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40.v),
                Container(
                  width: 114.h,
                  height: 40.v,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (status == "member") {
                        FocusScope.of(context).requestFocus(FocusNode());
                        await Future.delayed(Duration(milliseconds: 500));
                        editProfile();
                        Navigator.pushNamed(context, AppRoutes.setting);
                      } else {
                        FocusScope.of(context).requestFocus(FocusNode());
                        await Future.delayed(Duration(milliseconds: 500));
                        addComplete();
                        Navigator.pushNamed(context, AppRoutes.diaryMainScreen);
                      }
                    },
                    child: Text(
                      '確認更改',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 18.fSize,
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
        ),
      ),
    );
  }
}
// 後端: 301 改 ip 位址 163.22.32.24