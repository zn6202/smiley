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

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<String?> getUserId() async { // 使用者的 id
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<void> fetchData() async {
    final String? userId = await getUserId();
    print("進入呈現好友列表函式 $userId");

    final response = await http.post(
      Uri.parse(API.getFriends),
      body: {
        'user_id':userId,
      },
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      final exp=result['users'];
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
              tempInvitedListMember.add(item['id'] as String); // assuming 'id' is returned
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

  void delFriend(int friendId ,int index) async{ 
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
          IconButton(
            icon: Image.asset(
              'assets/images/addFriend.png', // addFriend圖標圖片
              height: 30.v, // 您可以根據需要調整圖片的高度
            ),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.addFriend);
            },
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
                                icon: Image.asset(
                                    'assets/images/delFriend.png'),
                                onPressed: () {
                                  setState(() {
                                    filterFriends(searchText);
                                    int whoInviteMe = int.parse(friends[index]['id']!);
                                    print('whoInviteMe: $whoInviteMe');
                                    delFriend(whoInviteMe, index);
                                    // 現在的刪除只是頁面上的 要再加上後端的刪除
                                  });
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
}