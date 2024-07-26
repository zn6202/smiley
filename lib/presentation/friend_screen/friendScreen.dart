import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/app_export.dart'; // 應用程式導出模組
import '../../widgets/app_bar/appbar_leading_image.dart'; // 自定義應用欄返回按鈕
class Friendscreen extends StatefulWidget {
  @override
  _FriendscreenState createState() => _FriendscreenState();
}

class _FriendscreenState extends State<Friendscreen> {
  List<Map<String, String>> friends = [];
  List<Map<String, String>> filteredFriends = [];
  String searchText = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    // 模擬後端資料
    setState(() {
      friends = [
        {'name': 'mimi', 'photo': 'assets/images/default_avatar_1.png'},
        {'name': 'ohoh', 'photo': 'assets/images/default_avatar_2.png'},
        {'name': 'bbb', 'photo': 'assets/images/default_avatar_3.png'},
      ];
      filteredFriends = friends;
    });
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
                                              image: AssetImage(
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
                                    friends.removeAt(index);
                                    filterFriends(searchText);
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