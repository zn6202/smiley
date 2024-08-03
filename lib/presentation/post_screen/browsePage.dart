import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smiley/core/app_export.dart';
import '../../widgets/bottom_navigation.dart';

class BrowsePage extends StatefulWidget {
  @override
  _BrowsePageState createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  late Future<List<Post>> _futureMyPosts;
  late Future<List<Post>> _futureFriendsPosts;
  late PageController _mainPageController;
  late PageController _friendsPostsController;
  int _currentIndex = 3;
  bool _isViewingFriendsPosts = false;

  @override
  void initState() {
    super.initState();
    _futureMyPosts = fetchMyPosts();
    _futureFriendsPosts = fetchFriendsPosts();
    _mainPageController = PageController();
    _friendsPostsController = PageController();
  }

  @override
  void dispose() {
    _mainPageController.dispose();
    _friendsPostsController.dispose();
    super.dispose();
  }

  Future<List<Post>> fetchMyPosts() async {
    return [
      Post(
        colorId: Color(0xFFF4F4E6),
        monsterId: 1,
        angelId: null,
        title: "測試標題1",
        date: DateFormat('yyyy.MM.dd').format(DateTime.now().subtract(Duration(hours: 1))),
        content: "這是測試的貼文內容1。",
        emotionImage: "monster_1.png",
      ),
      Post(
        colorId: Color(0xFFDDCCC0),
        monsterId: 2,
        angelId: null,
        title: "測試標題2",
        date: DateFormat('yyyy.MM.dd').format(DateTime.now().subtract(Duration(hours: 3))),
        content: "這是測試的貼文內容2。",
        emotionImage: "monster_2.png",
      ),
      Post(
        colorId: Color(0xFFA7BA89),
        monsterId: 3,
        angelId: null,
        title: "測試標題3",
        date: DateFormat('yyyy.MM.dd').format(DateTime.now().subtract(Duration(hours: 5))),
        content: "這是測試的貼文內容3。",
        emotionImage: "monster_3.png",
      ),
    ];
  }

  Future<List<Post>> fetchFriendsPosts() async {
    return [
      Post(
        colorId: Color(0xFF6F5032),
        monsterId: 4,
        angelId: null,
        title: "好友貼文1",
        date: DateFormat('yyyy.MM.dd').format(DateTime.now().subtract(Duration(hours: 2))),
        content: "這是好友的貼文內容1。",
        emotionImage: "monster_4.png",
      ),
      Post(
        colorId: Color(0xFFFBBC05),
        monsterId: 1,
        angelId: null,
        title: "好友貼文2",
        date: DateFormat('yyyy.MM.dd').format(DateTime.now().subtract(Duration(hours: 4))),
        content: "這是好友的貼文內容2。",
        emotionImage: "monster_1.png",
      ),
      Post(
        colorId: Color(0xFF374295),
        monsterId: 2,
        angelId: null,
        title: "好友貼文3",
        date: DateFormat('yyyy.MM.dd').format(DateTime.now().subtract(Duration(hours: 6))),
        content: "這是好友的貼文內容3。",
        emotionImage: "monster_2.png",
      ),
    ];
  }

  Color getTextColor(Color colorId) {
    switch (colorId.value) {
      case 0xFF222222:
        return Color(0xFFFFFF53);
      case 0xFFAF333A:
        return Color(0xFFFFFF00);
      case 0xFF374295:
        return Color(0xFFECA8A4);
      case 0xFFA1E0E4:
        return Color(0xFF4285F4);
      case 0xFFCD95BC:
        return Color(0xFFFFFFFF);
      case 0xFFECA8A4:
        return Color(0xFF29979E);
      case 0xFFA7BA89:
        return Color(0xFF6B6C39);
      case 0xFFFBBC05:
        return Color(0xFF34A853);
      case 0xFFFFFF4E:
        return Color(0xFFEB4335);
      case 0xFFF4F4E6:
        return Color(0xFF545453);
      case 0xFFDDCCC0:
        return Color(0xFF545453);
      case 0xFF6F5032:
        return Color(0xFFD1BA7E);
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _mainPageController,
        onPageChanged: (index) {
          setState(() {
            _isViewingFriendsPosts = index == 1;
          });
        },
        children: [
          _buildMyPostsPage(),
          _buildFriendsPostsWrapper(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildMyPostsPage() {
    return FutureBuilder<List<Post>>(
      future: _futureMyPosts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No data"));
        }

        final posts = snapshot.data!;

        return PageView.builder(
          scrollDirection: Axis.vertical,
          reverse: true,
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return _buildPostItem(posts[index]);
          },
        );
      },
    );
  }

  Widget _buildFriendsPostsWrapper() {
    return FutureBuilder<List<Post>>(
      future: _futureFriendsPosts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No data"));
        }

        final posts = snapshot.data!;

        return PageView.builder(
          controller: _friendsPostsController,
          itemCount: posts.length,
          scrollDirection: Axis.horizontal,
          onPageChanged: (index) {
            if (index == 0 && !_isViewingFriendsPosts) {
              _mainPageController.jumpToPage(0);
            }
          },
          itemBuilder: (context, index) {
            return _buildPostItem(posts[index]);
          },
        );
      },
    );
  }

  Widget _buildPostItem(Post post) {
    final textColor = getTextColor(post.colorId);

    return Container(
      color: post.colorId,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 70.v, left: 16.h, right: 16.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  post.date,
                  style: TextStyle(
                    fontSize: 25.fSize,
                    height: 1.2.v,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.v, left: 16.h, right: 16.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  post.title,
                  style: TextStyle(
                    fontSize: 50.fSize,
                    height: 1.2.v,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
            ),
            SizedBox(height: 120.v),
            Image.asset(
              'assets/images/${post.emotionImage}',
              height: 200.v,
              width: 200.h,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 30.v),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.h),
              child: Text(
                post.content,
                style: TextStyle(
                  fontSize: 18.fSize,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Post {
  final Color colorId;
  final int? monsterId;
  final int? angelId;
  final String title;
  final String date;
  final String content;
  final String emotionImage;

  Post({
    required this.colorId,
    required this.monsterId,
    required this.angelId,
    required this.title,
    required this.date,
    required this.content,
    required this.emotionImage,
  });
}