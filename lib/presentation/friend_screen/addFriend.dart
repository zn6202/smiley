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
  List<Map<String, String>> friends = [];
  List<Map<String, String>> filteredFriends = [];
  List invitedListMember = [];
  List sentFriendRequests = []; // 我發出的好友請求
  List receivedFriendRequests = [];
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
    fetchFriends();

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

  Future<String?> getUserId() async {
    // 使用者的 id
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<void> fetchFriends() async {
    final String? userId = await getUserId();
    // print("進入呈現好友列表函式 $userId");

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
          for (var item in result['users']) {
            // 確保 item 是 Map<String, dynamic>
            if (item is Map<String, dynamic>) {
              tempFriendRequests.add({
                'id': item['id'].toString(),
                'name': item['name'] as String,
                'photo': item['photo'] as String,
              });
            }
          }

          setState(() {
            friends = tempFriendRequests;
          });
          print("好友列表: $friends");
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

  Future<void> fetchFriendRequests() async {
    final String? userId = await getUserId();
    print("進入加好友的邀請好友列表函式 $userId");

    final response = await http.post(
      Uri.parse(API.invitedList),
      body: {
        'friend_id': userId,
      },
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      print('result是: $result');

      // 確保 `result` 是 Map 類型，並檢查 `success` 是否為 true
      if (result['success']) {
        List<Map<String, String>> tempSentRequests = [];
        List<Map<String, String>> tempReceivedRequests = [];
        List<String> tempInvitedListMember = [];
        List<Map<String, String>> tempFriendRequests = [];
        //         List<String> tempInvitedListMember = [];

        //         for (var item in result['users']) {
        //           // 確保 item 是 Map<String, dynamic>
        //           if (item is Map<String, dynamic>) {
        //             tempFriendRequests.add({
        // 處理發出的好友請求
        if (result['sent_by_me'] is List) {
          for (var item in result['sent_by_me']) {
            if (item is Map<String, dynamic>) {
              tempSentRequests.add({
                'id': item['id'].toString(),
                'name': item['name'] as String,
                'photo': item['photo'] as String,
              });
            }
          }
        }

        // 處理收到的好友請求
        if (result['sent_by_other'] is List) {
          for (var item in result['sent_by_other']) {
            if (item is Map<String, dynamic>) {
              tempReceivedRequests.add({
                'id': item['id'].toString(),
                'name': item['name'] as String,
                'photo': item['photo'] as String,
              });
              tempFriendRequests.add({
                'id': item['id'].toString(),
                'name': item['name'] as String,
                'photo': item['photo'] as String,
              });
              // 將 user_id 添加到 invitedListMember 中
              tempInvitedListMember.add(item['id'].toString()); // 假設 'id' 是回傳的值
            }
          }
        }

        setState(() {
          sentFriendRequests = tempSentRequests; // 我發出的好友請求
          friendRequests = tempFriendRequests; // 對我發邀請
          receivedFriendRequests = tempReceivedRequests; // 我收到的好友請求
          invitedListMember = tempInvitedListMember; // 想加我的好友的 id
        });

        print("我發出的好友邀請列表 有: $sentFriendRequests");
        print("想加我的好友列表 有: $friendRequests");
        print("想加我的好友列表 有: $receivedFriendRequests");
        print("想加我好友的 id 有: $invitedListMember");
      } else {
        print('User not found or invalid success flag');
        setState(() {
          sentFriendRequests = [];
          receivedFriendRequests = [];
        });
      }
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<void> searchUsers(String query) async {
    //搜尋用戶後端資料
    final String? userId = await getUserId();
    print("進入搜尋好友函式");
    // 以 aaa 為例:
    // 想加 aaa 好友的 id 有: [39, 23]，如果 aaa 在加好友搜尋 39 或 23，右邊顯示的 icon 要換
    // invitedListMember = [39, 23]
    if (invitedListMember.contains(query.toString())) {
      setState(() {
        // 顯示的人
      });
    } else if (userId != query) {
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
          print('存入的搜尋結果: $searchResults');
          print('搜尋的 query: $query');

        } else {
          setState(() {
            searchResults = [];
          });
          print('找不到該用戶.');
          print('搜尋的 query: $query');
          print('invitedListMember: $invitedListMember');
        }
      } else {
        throw Exception('Failed to load user');
      }
    }
  }

  void acceptFriend(int userInvite, int index) async {
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

  void rejectFriend(int userInvite, int index) async {
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

  void sendFriendRequest(int index) async {
    final String? userId = await getUserId();
    final friendId = searchResults[index]['id'];
    print("進入搜尋好友函式 userId: $userId , friendId: $friendId");

    if (searchResults[index]['hasRequested'] == 'false') {
      // 發送好友請求，並匯進資料庫
      final response = await http.post(
        Uri.parse(API.inviteFriend), // 解析字串變成 URI 對象
        body: {
          'user_id': userId,
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
    } else {
      // 撤銷好友邀請，從資料庫移除
      final response = await http.post(
        Uri.parse(API.cancelInviteFriend), // 解析字串變成 URI 對象
        body: {
          'user_id': userId,
          'friend_id': friendId,
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success']) {
          setState(() {
            searchResults[index]['hasRequested'] =
                'false'; //false 為還不是好友(撤銷邀請，對方拒絕)
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
            Navigator.pop(context); // pop 回上一頁的時候，ui 的 icon 數字要變
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
                // 成功接受邀請提示窗
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
                            backgroundImage: AssetImage(acceptedFriend![
                                'photo']!), //我不確定這樣寫能不能顯示接受者的頭像 需確認
                            radius: 30,
                          ),
                          SizedBox(width: 10.h),
                          Image.asset('assets/images/Lightning.png',
                              height: 30),
                          SizedBox(width: 10.h),
                          CircleAvatar(
                            backgroundColor: Color(0xFFF4F4E6), // 設置背景顏色
                            backgroundImage: AssetImage(
                                'assets/images/default_avatar_9.png'), //顯示自己的頭像
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
                // 搜尋好友的各種情形對應的UI
                key: ValueKey<bool>(showSuccessMessage),
                padding: EdgeInsets.all(16.adaptSize),
                child: Column(
                  children: [
                    Container(
                      // 搜尋框
                      width: 376.h,
                      height: 44.v,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.h, vertical: 10.v),
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
                                          itemBuilder: (context, index) {String searchedUserId = searchResults[index]['id']!;

                                            // 判斷關係
                                            bool isFriend = friends.any((friend) => friend['id'].toString() == searchResults[index]['id'].toString());
                                            bool isSentByMe = sentFriendRequests.any((request) => request['id'] == searchedUserId);
                                            bool isReceivedByMe = friendRequests.any((request) => request['id'] == searchedUserId);

                                            // 檢查
                                            print('目前的好友列表: $friends');
                                            print('目前收到的好友邀請: $receivedFriendRequests'); //friendRequests
                                            print('搜尋到的用戶ID: $searchedUserId');
                                            print('isFriend: $isFriend, isSentByMe: $isSentByMe, isReceivedByMe: $isReceivedByMe');

                                            return Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10.v),
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
                                                        width: 250.h,
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
                                                              margin: EdgeInsets.only(left:10.h),
                                                              decoration: BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                image:DecorationImage(
                                                                  image: NetworkImage(searchResults[index]['photo']!),
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Center(
                                                                child: Text(
                                                                  searchResults[index]['name']!,
                                                                  style:TextStyle(
                                                                    fontSize: 20.fSize,
                                                                    fontWeight:FontWeight.w700,
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

                                                  // 顯示對應的圖標或按鈕
                                                  isFriend
                                                      ? IconButton(
                                                          icon: Image.asset('assets/images/delFriend.png'),
                                                          iconSize:30.adaptSize,
                                                          onPressed: () {
                                                            // showDelConfirmationDialog(
                                                            //     context, int.parse(searchResults[index]['id']!), index);
                                                          },
                                                        )
                                                      : isReceivedByMe
                                                          ? Row(
                                                              children: [
                                                                IconButton(
                                                                  padding: EdgeInsets.only(left: 12.h),
                                                                  icon: Image.asset('assets/images/acceptFriend.png'),
                                                                  onPressed:() {
                                                                    int whoInviteMe = int.parse(friendRequests.firstWhere((request) => request['id'] == searchedUserId)['id']!);
                                                                    acceptFriend(whoInviteMe, index);
                                                                  },
                                                                ),
                                                                SizedBox(width: 5.h),
                                                                IconButton(
                                                                  padding: EdgeInsets.only(left:12.h),
                                                                  icon: Image.asset('assets/images/delFriend.png'),
                                                                  onPressed:() {
                                                                    int whoInviteMe = int.parse(friendRequests.firstWhere((request) =>
                                                                        request['id'] ==searchedUserId)['id']!);
                                                                    rejectFriend(whoInviteMe,index);
                                                                  },
                                                                ),
                                                              ],
                                                            )
                                                          : isSentByMe
                                                              ? Text(
                                                                  '已送出',
                                                                  style: TextStyle(
                                                                    color: Colors.grey,
                                                                    fontSize:16,
                                                                    fontWeight:FontWeight.bold,
                                                                  ),
                                                                )
                                                              : IconButton(
                                                                  icon: Icon(Icons.person_add_alt,color: Color(0xFFA7BA89)),
                                                                  iconSize: 30.adaptSize,
                                                                  onPressed:() {
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
                                                    icon: Image.asset('assets/images/acceptFriend.png'),
                                                    onPressed: () {
                                                      int whoInviteMe = int.parse(friendRequests[index]['id']!);
                                                      print('whoInviteMe: $whoInviteMe');
                                                      acceptFriend(whoInviteMe, index);
                                                    },
                                                  ),
                                                  SizedBox(width: 5.h),
                                                  IconButton(
                                                    padding: EdgeInsets.only(left: 12.h),
                                                    icon: Image.asset('assets/images/delFriend.png'),
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
- 送出交友邀請後要變成已送出
- 接收別人的好友邀請後要重新進入friendPage才會刷新好友名單
- 搜尋不到寄邀請給我的用戶

後端:
- icon數字抓錯 現在抓成已處理的(status = 1)
*/
