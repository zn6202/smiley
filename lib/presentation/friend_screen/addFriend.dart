import 'package:flutter/material.dart';
import '../../core/app_export.dart'; // 應用程式導出模組
import '../../widgets/app_bar/appbar_leading_image.dart'; // 自定義應用欄返回按鈕
import 'dart:async'; // 計時器插件
import 'package:http/http.dart' as http;
import '../../routes/api_connection.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddFriend extends StatefulWidget {
  @override
  _AddFriendState createState() => _AddFriendState();
}

class _AddFriendState extends State<AddFriend> {
  List<Map<String, String>> friendRequests = [];
  List<Map<String, String>> searchResults = [];
  List invitedListMember = [];
  String searchText = '';
  bool showSuccessMessage = false;
  Map<String, String>? acceptedFriend;
  bool isSearching = false;
  bool showCancelButton = false;
  FocusNode searchFocusNode = FocusNode();
  TextEditingController searchController = TextEditingController(); // 新增這行

  @override
  void initState() {
    super.initState();
    fetchFriendRequests();

    // 監聽焦點變化
    searchFocusNode.addListener(() {
      if (searchFocusNode.hasFocus) {
        setState(() {
          isSearching = true;
        });
      } else if (searchText.isEmpty) {
        setState(() {
          isSearching = false;
        });
      }
    });
  }

  Future<String?> getUserId() async { // 使用者的 id
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<void> fetchFriendRequests() async {
    final String? userId = await getUserId();
    print("進入被邀請好友列表函式 $userId");

    final response = await http.post(
      Uri.parse(API.invitedList),
      body: {
        'friend_id': userId,
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
            friendRequests = tempFriendRequests;
            invitedListMember = tempInvitedListMember;
          });
          print("想加的好友列表 有: $friendRequests");
          print("想加我好友的 id 有: $invitedListMember");
        } else {
          print('Invalid format for users');
          setState(() {
            friendRequests = [];
          });
        }
      } else {
        print('User not found or invalid success flag');
        setState(() {
          friendRequests = [];
        });
      }
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<void> searchUsers(String query) async { //搜尋用戶後端資料
    final String? userId = await getUserId();
    print("進入搜尋好友函式");
    // 以 aaa 為例: 
    // 想加 aaa 好友的 id 有: [39, 23]，如果 aaa 在加好友搜尋 39 或 23，右邊顯示的 icon 要換
    // invitedListMember = [39, 23]
    if (invitedListMember.contains(query)){
      setState(() {
        // 顯示的人
      });
    }else if (userId != query){
      final response = await http.post(
        Uri.parse(API.searchUser), // 解析字串變成 URI 對象
        body: {
          'friend_id': query,
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success']) {
          setState(() {
            searchResults = [
              {
                'id': query, // 好友 ID
                'name': result['name'],
                'photo': result['photo'],
                'hasRequested': result['status'],
              }
            ];
          });
        } else {
          setState(() {
            searchResults = [];
          });
          print('User not found.');
        }
      } else {
        throw Exception('Failed to load user');
      }
    }
  }

  void acceptFriend(int userInvite ,int index) async{
    final String? userId = await getUserId();
    print("進入接受好友函式: $userInvite 邀請 $userId");

    final response = await http.post(
      Uri.parse(API.acceptInvite), // 解析字串變成 URI 對象
      body: {
        'user_id': userInvite.toString(),
        'friend_id': userId!,
      },
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['success']) {
        setState(() {
          acceptedFriend = friendRequests[index];
          showSuccessMessage = true;
        });

        Timer(Duration(seconds: 2), () {
          setState(() {
            showSuccessMessage = false;
            friendRequests.removeAt(index);
          });
        });
        print("接受邀請成功");

      } else {
        setState(() {
          searchResults = [];
        });
        print('User not found.');
      }
    } else {
      throw Exception('Failed to load user');
    }
  }

  void rejectFriend(int userInvite ,int index) async{ 
    final String? userId = await getUserId();
    print("進入拒絕好友函式: $userId 要拒絕 $userInvite 的邀請");

    final response = await http.post(
      Uri.parse(API.rejectInvite), // 解析字串變成 URI 對象
      body: {
        'user_id': userInvite.toString(),
        'friend_id': userId!,
      },
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['success']) {
        setState(() {
          friendRequests.removeAt(index);
        });
        print("拒絕邀請成功");

      } else {
        setState(() {
          searchResults = [];
        });
        print('User not found.');
      }
    } else {
      throw Exception('Failed to load user');
    }
  }

  void sendFriendRequest(int index) async{ 
    final String? userId = await getUserId();
    final friendId = searchResults[index]['id'];
    print("進入搜尋好友函式 userId: $userId , friendId: $friendId");

    if (searchResults[index]['hasRequested'] == 'false'){  // 發送好友請求，並匯進資料庫
      final response = await http.post(
        Uri.parse(API.inviteFriend), // 解析字串變成 URI 對象
        body: {
          'user_id':userId,
          'friend_id': friendId,
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success']) {
          setState(() {
            searchResults[index]['hasRequested'] = 'true'; //已發送邀請
          });
          print('好友邀請發送成功!');
        } else {
          print('好友邀請發送失敗...');
        }
      } else {
        throw Exception('Failed to load user');
      }
    }else{ // 撤銷好友邀請，從資料庫移除
      final response = await http.post(
        Uri.parse(API.cancelInviteFriend), // 解析字串變成 URI 對象
        body: {
          'user_id':userId,
          'friend_id': friendId,
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success']) {
          setState(() {
            searchResults[index]['hasRequested'] = 'false'; //false 為還不是好友(撤銷邀請，對方拒絕)
          });
          print('撤銷好友邀請成功!');
        } else {
          print('撤銷好友邀請失敗...');
        }
      } else {
        throw Exception('Failed to load user');
      }
    }
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
          'assets/images/addFriend_y.png',
          height: 30.v, // 您可以根據需要調整圖片的高度
        ),
        centerTitle: true, // 將圖片設置為居中
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: showSuccessMessage
            ? Center(
                key: ValueKey<bool>(showSuccessMessage),
                child: Container(
                  width: 304.h,
                  height: 202.v,
                  decoration: BoxDecoration(
                    color: Color(0xFFFCFCFE),
                    borderRadius: BorderRadius.circular(49),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: Color(0xFFFFFFF), // 設置背景顏色
                            backgroundImage: AssetImage(acceptedFriend!['photo']!), //我不確定這樣寫能不能顯示接受者的頭像 需確認
                            radius: 30,
                          ),
                          SizedBox(width: 10.h),
                          Image.asset('assets/images/Lightning.png', height: 30),
                          SizedBox(width: 10.h),
                          CircleAvatar(
                            backgroundColor: Color(0xFFF4F4E6), // 設置背景顏色
                            backgroundImage: AssetImage('assets/images/default_avatar_9.png'), //顯示自己的頭像
                            radius: 30,
                          ),
                        ],
                      ),
                      SizedBox(height: 20.v),
                      Text(
                        '太棒了 ! 成功成為好友',
                        style: TextStyle(
                          fontSize: 20,
                          height: 1.2,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF545453),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Padding(
                key: ValueKey<bool>(showSuccessMessage),
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
                              controller: searchController, 
                              focusNode: searchFocusNode,
                              onChanged: (value) {
                                setState(() {
                                  searchText = value;
                                  if (searchText.isEmpty) {
                                    isSearching = false;
                                  } else {
                                    isSearching = true;
                                    searchUsers(searchText);
                                  }
                                });
                              },
                              onTap: () {
                                setState(() {
                                  showCancelButton = true;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: '輸入 ID',
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
                          if (showCancelButton)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  searchController.clear(); // 清除搜尋框的文字
                                  searchFocusNode.unfocus();
                                  isSearching = false;
                                  showCancelButton = false;
                                  searchText = '';
                                });
                              },
                              child: Text(
                                '取消',
                                style: TextStyle(
                                  fontSize: 16.fSize,
                                  color: Color(0xFF545453),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.v),
                    isSearching
                        ? Expanded(
                            child: Column(
                              children: [
                                Text(
                                  '搜尋用戶',
                                  style: TextStyle(
                                    fontSize: 20.fSize,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF545453),
                                  ),
                                ),
                                Expanded(
                                  child: searchResults.isEmpty
                                      ? Center(
                                          child: Text(
                                            '無搜尋結果',
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
                                        padding: EdgeInsets.symmetric(horizontal: 20.h),
                                        itemCount: searchResults.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: EdgeInsets.symmetric(vertical: 10.v),
                                            child: Row(
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
                                                      width: 285.h,
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
                                                                image: NetworkImage(searchResults[index]['photo']!),
                                                                // image: AssetImage(searchResults[index]['photo']!),
                                                                fit: BoxFit.cover,
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Center(
                                                              child: Text(
                                                                searchResults[index]['name']!,
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
                                                  icon: searchResults[index]['hasRequested'] == 'true'
                                                      ? Image.asset('assets/images/delFriend.png')
                                                      : Icon(Icons.person_add, color: Color(0xFFA7BA89)),
                                                  iconSize: 30.adaptSize,
                                                  onPressed: () {
                                                    sendFriendRequest(index);
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                ),
                              ],
                            ),
                          )
                        : Expanded(
                            child: Column(
                              children: [
                                Text(
                                  '好友邀請',
                                  style: TextStyle(
                                    fontSize: 20.fSize,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF545453),
                                  ),
                                ),
                                Expanded(
                                  child: friendRequests.isEmpty
                                      ? Center(
                                          child: Text(
                                            '無好友邀請',
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
                                          itemCount: friendRequests.length,
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
                                                        width: 210.h,
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
                                                                  image: NetworkImage(friendRequests[index]['photo']!),
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Center(
                                                                child: Text(
                                                                  friendRequests[index]['name']!,
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
                                                        'assets/images/acceptFriend.png'),
                                                    onPressed: () {
                                                      int whoInviteMe = int.parse(friendRequests[index]['id']!);
                                                      print('whoInviteMe: $whoInviteMe');
                                                      acceptFriend(whoInviteMe, index);
                                                    },
                                                  ),
                                                  SizedBox(width: 5.h),
                                                  IconButton(
                                                    padding: EdgeInsets.only(left: 12.h),
                                                    icon: Image.asset(
                                                        'assets/images/delFriend.png'),
                                                    onPressed: () {
                                                      int whoInviteMe = int.parse(friendRequests[index]['id']!);
                                                      print('whoInviteMe: $whoInviteMe');
                                                      rejectFriend(whoInviteMe, index);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
      ),
    );
  }
}

/*
前端修改:
- 114，如果對方已加我好友，當我搜尋對方時，icon 要是 "勾勾" 或 "叉叉"
*/

/*
後端修改:
- acceptFriend 74行 需傳到後端資料庫 同意好友
- sendFriendRequest 86行 需傳到後端資料庫 發送好友請求
- 140 305 407行都分別要顯示後端傳來的用戶頭貼 不確定這樣的格式是否可以 需確認
- 148需顯示自己的頭貼
*/