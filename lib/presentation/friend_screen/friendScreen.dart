import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/app_export.dart'; // 應用程式導出模組
import '../../widgets/app_bar/appbar_leading_image.dart'; // 自定義應用欄返回按鈕

import 'package:http/http.dart' as http;
import '../../routes/api_connection.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Friendscreen extends StatefulWidget {
  @override
  _FriendscreenState createState() => _FriendscreenState();
}

class _FriendscreenState extends State<Friendscreen> {
  List<Map<String, String>> friends = [];
  List<Map<String, String>> filteredFriends = [];
  List invitedListMember = [];
  String searchText = '';
  int invitedSum = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchInvitedSum();
  }

  Future<String?> getUserId() async {
    // 使用者的 id
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<void> fetchData() async {
    final String? userId = await getUserId();
    print("進入呈現好友列表函式 $userId");

    final response = await http.post(
      Uri.parse(API.getFriends),
      body: {
        'user_id': userId,
      },
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      final exp = result['users'];
      print('result是: $exp');

      // 確保 `result` 是 Map 類型，並檢查 `success` 是否為 true
      if (result['success']) {
        // 檢查 `users` 是否存在且是 List 類型
        if (result['users'] is List) {
          List<Map<String, String>> tempFriendRequests = [];
          List<String> tempInvitedListMember = [];

          for (var item in result['users']) {
            // 確保 item 是 Map<String, dynamic>
            if (item is Map<String, dynamic>) {
              tempFriendRequests.add({
                'id': item['id'].toString(),
                'name': item['name'] as String,
                'photo': item['photo'] as String,
              });

              // 将 user_id 添加到 invitedListMember 中
              tempInvitedListMember
                  .add(item['id'] as String); // assuming 'id' is returned
            }
          }

          setState(() {
            friends = tempFriendRequests;
            invitedListMember = tempInvitedListMember;
          });
          filteredFriends = friends;
          print("想加的好友列表 有: $friends");
          print("想加我好友的 id 有: $invitedListMember");
        } else {
          print('Invalid format for users');
          setState(() {
            friends = [];
          });
        }
      } else {
        print('User not found or invalid success flag');
        setState(() {
          friends = [];
        });
      }
    } else {
      throw Exception('Failed to load user');
    }
  }

  void fetchInvitedSum() async {
    final String? userId = await getUserId();
    print("進入好友邀請數量函式: $userId");

    final response = await http.post(
      Uri.parse(API.getInvitedSum), // 解析字串變成 URI 對象
      body: {
        'user_id': userId!,
      },
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['success']) {
        setState(() {
          invitedSum = result['count'];
        });
        print("計算成功 $invitedSum");
      } else {
        setState(() {
          invitedSum = 0;
        });
        print('User not found.');
      }
    } else {
      throw Exception('Failed to load user');
    }
  }

  void delFriend(int friendId, int index) async {
    final String? userId = await getUserId();
    print("進入刪除好友函式: $userId 要刪除 $friendId");

    final response = await http.post(
      Uri.parse(API.delFriend), // 解析字串變成 URI 對象
      body: {
        'user_id': userId!,
        'friend_id': friendId.toString(),
      },
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['success']) {
        setState(() {
          friends.removeAt(index);
        });
        print("拒絕邀請成功");
      } else {
        print('User not found.');
      }
    } else {
      throw Exception('Failed to load user');
    }
  }

  void filterFriends(String query) {
    List<Map<String, String>> tempFriends = [];
    if (query.isNotEmpty) {
      tempFriends = friends
          .where((friend) =>
              friend['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } else {
      tempFriends = friends;
    }
    setState(() {
      filteredFriends = tempFriends;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F4E6), // 設置背景顏色
      appBar: AppBar(
        elevation: 0, // 設置應用欄的陰影為0
        backgroundColor: Colors.transparent, // 設置背景透明
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/images/img_arrow_left.svg',
            color: Color(0xFFA7BA89),
          ),
          onPressed: () async {
            FocusScope.of(context).requestFocus(FocusNode());
            await Future.delayed(Duration(milliseconds: 300));
            Navigator.pop(context); // 點擊返回按鈕返回上一頁
          },
        ),
        title: Image.asset(
          'assets/images/friend_y.png',
          height: 30.v, // 您可以根據需要調整圖片的高度
        ),
        centerTitle: true, // 將圖片設置為居中
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0), // 向左移動
            child: Stack(
              children: [
                IconButton(
                  icon: Image.asset(
                    'assets/images/addFriend.png', // addFriend圖標圖片
                    height: 30.v,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.addFriend).then((_) {
                      fetchInvitedSum();
                    });
                    ;
                  },
                ),
                if (invitedSum != 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Color(0xFFA7BA89),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${invitedSum}', //代處理好友邀請數量
                          style: TextStyle(
                            color: Color(0xFFF4F4E6),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.adaptSize),
        child: Column(
          children: [
            Container(
              width: 376.h,
              height: 44.v,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 10.v),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/search.png',
                    height: 20.v,
                  ),
                  SizedBox(width: 10.h),
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchText = value;
                          filterFriends(searchText);
                        });
                      },
                      decoration: InputDecoration(
                        hintText: '輸入好友名稱',
                        hintStyle: TextStyle(
                          fontSize: 20.fSize,
                          height: 1.2.v,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w100,
                          color: Color(0xFFC5C5C5),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.v),
            Expanded(
              child: filteredFriends.isEmpty
                  ? Center(
                      child: Text(
                        '查無用戶',
                        style: TextStyle(
                          fontSize: 25.fSize,
                          height: 1.2.v,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFA7BA89),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 10.h),
                      itemCount: filteredFriends.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.v),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  Container(
                                    width: 67.h,
                                    height: 67.v,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Container(
                                    width: 280.h,
                                    height: 50.v,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 45.h,
                                          height: 45.v,
                                          margin: EdgeInsets.only(left: 10.h),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  filteredFriends[index]
                                                      ['photo']!),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              filteredFriends[index]['name']!,
                                              style: TextStyle(
                                                fontSize: 20.fSize,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF545453),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 5.h),
                              IconButton(
                                padding: EdgeInsets.only(left: 12.h),
                                icon:
                                    Image.asset('assets/images/delFriend.png'),
                                onPressed: () {
                                  // 弹出确认对话框
                                  showDelConfirmationDialog(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }

  showDelConfirmationDialog(BuildContext context) {
    // 顯示對話框
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // 返回一個自定義的 Dialog 小部件
        return Dialog(
          // 設置對話框的形狀和圓角
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0), // 設置圓角大小
          ),
          child: Container(
            width: 304.h, // 設置對話框的寬度
            height: 222.4.v, // 設置對話框的高度
            padding: EdgeInsets.symmetric(horizontal: 23.h), // 設置對話框的內邊距
            clipBehavior: Clip.antiAlias, // 防止對話框內容超出邊界
            decoration: ShapeDecoration(
              color: Colors.white, // 設置對話框的背景顏色
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0), // 設置圓角大小
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // 垂直方向上居中對齊
              crossAxisAlignment: CrossAxisAlignment.center, // 水平方向上居中對齊
              children: [
                // 設置標題文本
                SizedBox(
                  width: double.infinity, // 寬度設置為充滿父容器
                  child: Text(
                    '刪除好友確認', // 標題文本
                    textAlign: TextAlign.center, // 文本居中對齊
                    style: dialogTitleStyle,
                  ),
                ),
                SizedBox(height: 10.v), // 添加垂直間距
                // 添加橫線
                Container(
                  width: 244.5.h,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1.h,
                        strokeAlign: BorderSide.strokeAlignCenter,
                        color: Color(0xFFDADADA),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.v), // 添加垂直間距
                // 設置提示文本
                SizedBox(
                  width: double.infinity, // 寬度設置為充滿父容器
                  child: Text(
                    '按下確認鍵後，立即刪除好友。您確認要刪除嗎？', // 提示文本
                    textAlign: TextAlign.center, // 文本居中對齊
                    style: dialogContentStyle,
                  ),
                ),
                SizedBox(height: 20.v), // 添加垂直間距
                // 添加水平排列的按鈕
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 按鈕之間均勻分布
                  children: [
                    // 返回按鈕
                    Container(
                      height: 42.v, // 按鈕容器高度
                      width: 114.h, // 設置按鈕寬度
                      decoration: ShapeDecoration(
                        color: Colors.white, // 按鈕背景顏色
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              width: 1.h,
                              color: Color(0xFFA7BA89)), // 設置邊框顏色和寬度
                          borderRadius: BorderRadius.circular(20), // 設置圓角大小
                        ),
                      ),
                      child: Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            '取消', // 按鈕文本
                            textAlign: TextAlign.center, // 文本居中對齊
                            style: buttonTextStylePrimary,
                          ),
                        ),
                      ),
                    ),
                    // 確認按鈕
                    Container(
                      height: 42.v, // 按鈕容器高度
                      width: 114.h, // 設置按鈕寬度
                      decoration: ShapeDecoration(
                        color: Color(0xFFA7BA89), // 按鈕背景顏色
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // 設置圓角大小
                        ),
                      ),
                      child: Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // 點擊按鈕時關閉對話框
                          },
                          child: Text(
                            '確認', // 按鈕文本
                            textAlign: TextAlign.center, // 文本居中對齊
                            style: buttonTextStyleWhite,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 標題文字樣式常數
TextStyle dialogTitleStyle = TextStyle(
    color: Color(0xFF545453),
    fontSize: 25.fSize,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w100,
    letterSpacing: -0.32);

// 提示文字樣式常數
TextStyle dialogContentStyle = TextStyle(
    color: Color(0xFF545453),
    fontSize: 16.fSize,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w100,
    letterSpacing: -0.32);

TextStyle buttonTextStyleWhite = TextStyle(
    color: Colors.white,
    fontSize: 18.fSize,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
    height: 1.0);

TextStyle buttonTextStylePrimary = TextStyle(
    color: Color(0xFFA7BA89),
    fontSize: 18.fSize,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
    height: 1.0);
/*
前端:
- 當我從 addFriend.dart 同意好友然後按返回鍵回到 friendScreen.dart，icon 數字沒有及時修改
 */