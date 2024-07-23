import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/bottom_navigation.dart';

class MyPost extends StatefulWidget {
  @override
  _MyPostState createState() => _MyPostState();
}

class _MyPostState extends State<MyPost> {
  late Future<Post> _futurePost;
  int _currentIndex = 3;

  @override
  void initState() {
    super.initState();
    _futurePost = fetchMyPost();
  }

  Future<Post> fetchMyPost() async {
    // 模擬從網絡獲取數據的延遲
    await Future.delayed(Duration(seconds: 1));
    return Post(
      colorId: Color(0xFFF4F4E6),
      monsterId: 1,
      angelId: null,
      title: "測試標題",
      date: DateFormat('yyyy.MM.dd').format(DateTime.now()),
      content: "這是測試的貼文內容。",
      emotionImage: "img_emotion.png",
    );
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
      body: FutureBuilder<Post>(
        future: _futurePost,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return Center(child: Text("No data"));
          }

          final post = snapshot.data!;
          final textColor = getTextColor(post.colorId);

          return Scaffold(
            backgroundColor: post.colorId,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, left: 16.0, right: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        post.date,
                        style: TextStyle(
                          fontSize: 25.0,
                          height: 1.2,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, left: 16.0, right: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        post.title,
                        style: TextStyle(
                          fontSize: 50.0,
                          height: 1.2,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 120.0),
                  Image.asset(
                    'assets/images/${post.emotionImage}',
                    height: 200,
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 30.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      post.content,
                      style: TextStyle(
                        fontSize: 18.0,
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
        },
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
