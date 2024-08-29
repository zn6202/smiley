import 'package:flutter/material.dart';
import '../../core/app_export.dart'; 
import '../../widgets/app_bar/appbar_leading_image.dart'; 
import 'package:flutter_svg/flutter_svg.dart';
// http
import 'package:http/http.dart' as http;
import '../../routes/api_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Postrecord extends StatefulWidget {
  @override
  _PostrecordState createState() => _PostrecordState();
}

class _PostrecordState extends State<Postrecord> {
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }
  
  Future<void> _fetchUserData() async {
    final String? userId = await getUserId();

    print("進入貼文紀錄函式");
    print('user_id: $userId');

    final response = await http.post(
      Uri.parse(API.getPostRecord),
      body: {
        'user_id': userId!,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      if (data['success'] == true) {
        List<dynamic> postsJson = data['posts'];
        print("data['posts'] 是 : ${postsJson.toString()}");
        setState(() {
          posts = postsJson.map((json) => Post.fromJson(json)).toList();
        });
      } else {
        print('貼文瀏覽失敗... ${data['message']}');
      }
    } else {
      print('貼文瀏覽失敗...');
    }
  }

  // Future<void> _fetchUserData() async {
  //   setState(() {
  //     posts = [
  //       Post(
  //           date: '2024.04.14',
  //           title: '酸酸檸檬',
  //           emotionImage: 'monster_4.png',
  //           colorId: Color(0xFFFFFF4E),
  //           content: '哼 沒關係ㄚ 我就是愛吃醋 怎麼樣~'),
  //       Post(
  //           date: '2024.04.15',
  //           title: '椒躁龐克',
  //           emotionImage: 'monster_3.png',
  //           colorId: Color(0xFFAF333A),
  //           content: '宿舍洗衣機真的超破，怎麼有辦法把衣服越洗越髒啦 是在哭ㄛ'),
  //       Post(
  //           date: '2024.04.16',
  //           title: '酸酸檸檬',
  //           emotionImage: 'monster_4.png',
  //           colorId: Color(0xFFCD95BC),
  //           content:
  //               '嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨'),
  //     ];
  //   });
  // }

  void _navigateToPostDetail(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(post: post),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F4E6), 
      appBar: AppBar(
        elevation: 0, 
        backgroundColor: Colors.transparent,
        leading: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: SvgPicture.asset(
              'assets/images/img_arrow_left.svg',
              color: Color(0xFFA7BA89),
            ),
            onPressed: () async {
              Navigator.pop(context);
            },
          ),
        ),
        title: Image.asset(
          'assets/images/Record.png',
          height: 30.v, 
        ),
        centerTitle: true, 
      ),
      body: posts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.h),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20.h,
                  mainAxisSpacing: 20.v,
                ),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return GestureDetector(
                    onTap: () => _navigateToPostDetail(post),
                    child: Padding(
                      padding: EdgeInsets.only(top: 10.v),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 6.v),
                            child: Text(
                              post.date,
                              style: TextStyle(
                                fontSize: 18.fSize,
                                height: 1.v,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF545453),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 14.v),
                            child: Text(
                              post.title,
                              style: TextStyle(
                                fontSize: 18.fSize,
                                height: 1.v,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF545453),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Image.network(
                              post.monster != null && post.monster!.isNotEmpty
                              ? 'http://163.22.32.24/smiley_backend/img/monster/${post.monster!}'
                              : 'http://163.22.32.24/smiley_backend/img/angel/${post.angel!}',
                              fit: BoxFit.contain,
                            ),
                            // child: Image.network(
                            //   post.monster != null && post.monster!.isNotEmpty
                            //   ? 'http://192.168.56.1/smiley_backend/img/angel_monster/${post.monster!}'
                            //   : 'http://192.168.56.1/smiley_backend/img/angel_monster/${post.angel!}',
                            //   fit: BoxFit.contain,
                            // ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
class Post {
  final Color textColor;
  final Color backgroundColor;
  final String? monster;
  final String? angel;
  final String title;
  final String date;
  final String content;

  Post({
    required this.textColor,
    required this.backgroundColor,
    this.monster,
    this.angel,
    required this.title,
    required this.date,
    required this.content,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      textColor: Color(int.parse(json['text_color'])),
      backgroundColor: Color(int.parse(json['background_color'])),
      monster: json['monster'] ?? '', // 可以是 null
      angel: json['angel'] ?? '', // 可以是 null
      title: json['title'],
      date: json['date'],
      content: json['content'],
    );
  }
}

// class Post {
//   final String date;
//   final String title;
//   final String emotionImage;
//   final Color colorId;
//   final String content;

//   Post({
//     required this.date,
//     required this.title,
//     required this.emotionImage,
//     required this.colorId,
//     required this.content,
//   });
// }

class PostDetailScreen extends StatelessWidget {
  final Post post;

  PostDetailScreen({required this.post});

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
  final textColor = getTextColor(post.backgroundColor);

  return Scaffold(
    backgroundColor: post.backgroundColor,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: SvgPicture.asset(
          'assets/images/img_arrow_left.svg',
          color: textColor,
        ),
        onPressed: () async {
          Navigator.pop(context);
        },
      ),
    ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding:
                  EdgeInsets.only(top: 10.v, left: 16.h, right: 16.v),
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
              padding:
                  EdgeInsets.only(top: 10.v, left: 16.h, right: 16.h),
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
            Image.network(
              post.monster != null && post.monster!.isNotEmpty
              ? 'http://163.22.32.24/smiley_backend/img/monster/${post.monster!}'
              : 'http://163.22.32.24/smiley_backend/img/angel/${post.angel!}',
              height: 200.v,
              width: 200.h,
              fit: BoxFit.contain,
            ),
            // Image.network(
            //   post.monster != null && post.monster!.isNotEmpty
            //   ? 'http://192.168.56.1/smiley_backend/img/angel_monster/${post.monster!}'
            //   : 'http://192.168.56.1/smiley_backend/img/angel_monster/${post.angel!}',
            //   height: 200.v,
            //   width: 200.h,
            //   fit: BoxFit.contain,
            // ),
            SizedBox(height: 30.h),
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

/*
前端
- 也要接留言
- 祝祝畫的新的圖，大小要調整
 */