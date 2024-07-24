import 'package:flutter/material.dart';
import '../../core/app_export.dart'; // 應用程式導出模組
import '../../widgets/app_bar/appbar_leading_image.dart'; // 自定義應用欄返回按鈕
import 'dart:async'; // 計時器插件
import 'package:http/http.dart' as http;
import '../../routes/api_connection.dart';
import 'dart:convert';

class AddFriend extends StatefulWidget {
  @override
  _AddFriendState createState() => _AddFriendState();
}

class _AddFriendState extends State<AddFriend> {
  List<Map<String, String>> friendRequests = [];
  List<Map<String, String>> searchResults = [];
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

  Future<void> fetchFriendRequests() async { //好友邀請後端資料
    // 模擬後端資料
    setState(() {
      friendRequests = [
        {'name': 'mimi', 'photo': 'assets/images/default_avatar_1.png'},
        {'name': 'ohoh', 'photo': 'assets/images/default_avatar_2.png'},
        {'name': 'bbb', 'photo': 'assets/images/default_avatar_3.png'},
      ];
    });
  }

  Future<void> searchUsers(String query) async { //搜尋用戶後端資料
    // 模擬後端資料
    print("進入搜尋好友函式");
    final response = await http.post(
      Uri.parse(API.searchUser), // 解析字串變成 URI 對象
      body: {
        'id': query,
      },
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['success']) {
        setState(() {
          searchResults = [
            {
              'name': result['name'],
              'photo': result['photo'],
              'hasRequested': 'false'
            }
          ];
        });
      } else {
        print('User not found.');
      }
    } else {
      throw Exception('Failed to load user');
    }
  }


  void acceptFriend(int index) {
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
  }

  void sendFriendRequest(int index) { 
    // 這部分需特別注意!!!! 
    setState(() {
      if (searchResults[index]['hasRequested'] == 'true') {
        // 這裡會撤回好友邀請
        searchResults[index]['hasRequested'] = 'false';
      } else {
        // 這裡是送出好友邀請
        searchResults[index]['hasRequested'] = 'true';
      }
    });
    // 這裡可以添加發送或撤回好友請求的後端調用代碼
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F4E6), // 設置背景顏色
      appBar: AppBar(
        elevation: 0, // 設置應用欄的陰影為0
        backgroundColor: Colors.transparent, // 設置背景透明
        leading: AppbarLeadingImage(
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
        ),
        title: Image.asset(
          'assets/images/addFriend_y.png',
          height: 30, // 您可以根據需要調整圖片的高度
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
                  width: 304,
                  height: 202,
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
                          SizedBox(width: 10),
                          Image.asset('assets/images/Lightning.png', height: 30),
                          SizedBox(width: 10),
                          CircleAvatar(
                            backgroundColor: Color(0xFFF4F4E6), // 設置背景顏色
                            backgroundImage: AssetImage('assets/images/default_avatar_9.png'), //顯示自己的頭像
                            radius: 30,
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      width: 330,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/search.png',
                            height: 20,
                          ),
                          SizedBox(width: 10),
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
                                  fontSize: 20,
                                  height: 1.2,
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
                                  fontSize: 16,
                                  color: Color(0xFF545453),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    isSearching
                        ? Expanded(
                            child: Column(
                              children: [
                                Text(
                                  '搜尋用戶',
                                  style: TextStyle(
                                    fontSize: 20,
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
                                              fontSize: 25,
                                              height: 1.2,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFA7BA89),
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                        padding: EdgeInsets.symmetric(horizontal: 20),
                                        itemCount: searchResults.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            child: Row(
                                              children: [
                                                Stack(
                                                  alignment: Alignment.centerLeft,
                                                  children: [
                                                    Container(
                                                      width: 67,
                                                      height: 67,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 285,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(25),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: 45,
                                                            height: 45,
                                                            margin: EdgeInsets.only(left: 10),
                                                            decoration: BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              image: DecorationImage(
                                                                image: AssetImage(searchResults[index]['photo']!),
                                                                fit: BoxFit.cover,
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Center(
                                                              child: Text(
                                                                searchResults[index]['name']!,
                                                                style: TextStyle(
                                                                  fontSize: 20,
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
                                                SizedBox(width: 5),
                                                IconButton(
                                                  icon: searchResults[index]['hasRequested'] == 'true'
                                                      ? Image.asset('assets/images/delFriend.png')
                                                      : Icon(Icons.person_add, color: Color(0xFFA7BA89)),
                                                  iconSize: 30,
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
                                    fontSize: 20,
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
                                              fontSize: 25,
                                              height: 1.2,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFA7BA89),
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          padding: EdgeInsets.symmetric(horizontal: 20),
                                          itemCount: friendRequests.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              child: Row(
                                                children: [
                                                  Stack(
                                                    alignment: Alignment.centerLeft,
                                                    children: [
                                                      Container(
                                                        width: 67,
                                                        height: 67,
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          shape: BoxShape.circle,
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 230,
                                                        height: 50,
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius.circular(25),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              width: 45,
                                                              height: 45,
                                                              margin: EdgeInsets.only(left: 10),
                                                              decoration: BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                image: DecorationImage(
                                                                  image: AssetImage(
                                                                      friendRequests[index]['photo']!),
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Center(
                                                                child: Text(
                                                                  friendRequests[index]['name']!,
                                                                  style: TextStyle(
                                                                    fontSize: 20,
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
                                                  SizedBox(width: 5),
                                                  IconButton(
                                                    padding: EdgeInsets.only(left: 12),
                                                    icon: Image.asset(
                                                        'assets/images/acceptFriend.png'),
                                                    onPressed: () {
                                                      acceptFriend(index);
                                                    },
                                                  ),
                                                  SizedBox(width: 5),
                                                  IconButton(
                                                    padding: EdgeInsets.only(left: 12),
                                                    icon: Image.asset(
                                                        'assets/images/delFriend.png'),
                                                    onPressed: () {
                                                      setState(() {
                                                        // 模擬刪除好友請求的行為
                                                        friendRequests.removeAt(index);
                                                        // 現在的刪除只是頁面上的行為，後端需做相應的處理
                                                      });
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
後端修改:
- fetchFriendRequests 44行 抓好友邀請資料
- searchUsers 52行 搜尋用戶資料
- acceptFriend 74行 需傳到後端資料庫 同意好友
- sendFriendRequest 86行 需傳到後端資料庫 發送好友請求
- 140 305 407行都分別要顯示後端傳來的用戶頭貼 不確定這樣的格式是否可以 需確認
- 148需顯示自己的頭貼
*/