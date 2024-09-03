import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/app_export.dart';
import '../../widgets/bottom_navigation.dart';
import '../../main.dart';
// 後端需要的套件
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../routes/api_connection.dart';
import 'dart:convert';
//  
import '../setNamePhoto_screen/setNamePhoto_screen.dart';

const Color primaryColor = Color(0xFFA7BA89);
const Color backgroundColor = Color(0xFFF4F4E6);

class settingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<settingScreen> {
  int _currentIndex = 4;
  String userName = '';
  String userProfilePic = '';
  String userId = '';
  String albumPhoto = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    loadUserName();
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<void> loadUserName() async {
    userName = await getUserName() ?? '';
    print('預設姓名為: $userName');
    if (mounted) {
      setState(() {});
    }
  }

  Future<String?> getUserName() async {
    final Name = await SharedPreferences.getInstance();
    return Name.getString('user_name');
  }

  Future<void> _fetchUserData() async {
    final String? id = await getUserId();
    if (id == null) {
      print('Error: user_id is null');
      return;
    }

    print("進入設定出現個資函式");
    final response = await http.post(
      Uri.parse(API.getProfile),
      body: {
        'id': id,
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success']) {
        setState(() {
          userName = responseData['name'];
          userProfilePic = responseData['photo'];
          userId = id;
        });
        print('用戶id: $userId 用戶名稱: $userName, 用戶照片路徑: $userProfilePic');
        sendAvatarPath();
        sendName();
      } else {
        print('設定功能的個資取得失敗: ${responseData['message']}');
      }
    } else {
      print('設定功能的個資取得失敗...');
    }
  }

  Future<void> sendAvatarPath() async {
    final prefs = await SharedPreferences.getInstance();
    String avatarName = userProfilePic.split('/').last;
    await prefs.setString('selected_avatar_path', avatarName);
  }

  Future<void> sendName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', userName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: backgroundColor,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildProfileSection(),
              Expanded(
                child: _buildOptionsGrid(),
              ),
              CustomBottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      color: backgroundColor,
      padding: EdgeInsets.only(
        top: 132.v,
        bottom: 40.v,
      ),
      child: Column(
        children: [
          Container(
            width: 80.h,
            height: 80.v,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: Color(0xFFF4F4E6),
              backgroundImage: userProfilePic.isNotEmpty
                  ? NetworkImage(userProfilePic)
                  : AssetImage('assets/images/default_avatar.png')
                      as ImageProvider<Object>?,
            ),
          ),
          SizedBox(height: 16.v),
          Container(
            width: 104.h,
            height: 28.v,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: Color(0xFFFFFFFF), width: 1.h),
            ),
            padding: EdgeInsets.all(2.adaptSize),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Center(
                child: Text(
                  'name',
                  style: TextStyle(
                    fontSize: 14.fSize,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 8.v),
          Text(
            userName,
            style: TextStyle(
              fontSize: 18.fSize,
              fontWeight: FontWeight.w700,
              color: Color(0xFF545453),
            ),
          ),
          SizedBox(height: 16.v),
          Container(
            width: 104.h,
            height: 28.v,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: Color(0xFFFFFFFF), width: 1.h),
            ),
            padding: EdgeInsets.all(2.adaptSize),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Center(
                child: Text(
                  'id',
                  style: TextStyle(
                    fontSize: 14.fSize,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 8.v),
          Text(
            userId,
            style: TextStyle(
              fontSize: 18.fSize,
              fontWeight: FontWeight.w700,
              color: Color(0xFF545453),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsGrid() {
    return Padding(
      padding: EdgeInsets.only(
        left: 60.v,
        right: 60.v,
      ),
      child: GridView.builder(
        itemCount: 3, // 修改為3個網格項目
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20.h,
          mainAxisSpacing: 20.v,
          childAspectRatio: 117 / 92,
        ),
        itemBuilder: (context, index) {
          List<String> images = [
            'assets/images/Record.png',
            'assets/images/friend.png',
            'assets/images/edit.png',
          ];
          List<String> labels = ['貼文記錄', '好友', '編輯'];
          return _buildGridOption(images[index], labels[index], () {
            _handleGridOptionTap(index);
          });
        },
      ),
    );
  }

  Widget _buildGridOption(String imagePath, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 117.h,
        height: 92.v,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 40.h,
              height: 40.v,
            ),
            SizedBox(height: 8.v),
            Text(
              label,
              style: TextStyle(
                fontSize: 16.fSize,
                color: Color(0xFFA7BA89),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleGridOptionTap(int index) async {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, AppRoutes.postRecord);
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.friendScreen);
        break;
      case 2:
        await sendAvatarPath();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SetNamePhoto(sourcePage: 'setting'),
          ),
        );
        break;
    }
  }
}
