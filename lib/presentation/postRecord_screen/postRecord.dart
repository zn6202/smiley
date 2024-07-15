import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_export.dart'; 
import '../../widgets/app_bar/appbar_leading_image.dart'; 

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

  Future<void> _fetchUserData() async {
    setState(() {
      posts = [
        Post(
            date: '2024.04.14',
            title: '酸酸檸檬',
            emotionImage: 'monster_4.png',
            colorId: Color(0xFFFFFF4E),
            content: '哼 沒關係ㄚ 我就是愛吃醋 怎麼樣~'),
        Post(
            date: '2024.04.15',
            title: '椒躁龐克',
            emotionImage: 'monster_3.png',
            colorId: Color(0xFFAF333A),
            content: '宿舍洗衣機真的超破，怎麼有辦法把衣服越洗越髒啦 是在哭ㄛ'),
        Post(
            date: '2024.04.16',
            title: '酸酸檸檬',
            emotionImage: 'monster_4.png',
            colorId: Color(0xFFCD95BC),
            content:
                '嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨嗨'),
      ];
    });
  }

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
        leading: AppbarLeadingImage(
          imagePath: 'assets/images/arrow-left-g.png', 
          margin: EdgeInsets.only(
            top: 19.0,
            bottom: 19.0,
          ),
          onTap: () async {
            Navigator.pop(context); 
          },
        ),
        title: Image.asset(
          'assets/images/Record.png',
          height: 30, 
        ),
        centerTitle: true, 
      ),
      body: posts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20.0,
                  mainAxisSpacing: 20.0,
                ),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return GestureDetector(
                    onTap: () => _navigateToPostDetail(post),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Text(
                              post.date,
                              style: TextStyle(
                                fontSize: 18.0,
                                height: 1.0,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF545453),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14.0),
                            child: Text(
                              post.title,
                              style: TextStyle(
                                fontSize: 18.0,
                                height: 1.0,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF545453),
                              ),
                            ),
                          ),
                          Image.asset(
                            'assets/images/${post.emotionImage}',
                            height: 100.0,
                            width: 100.0,
                            fit: BoxFit.contain,
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
  final String date;
  final String title;
  final String emotionImage;
  final Color colorId;
  final String content;

  Post({
    required this.date,
    required this.title,
    required this.emotionImage,
    required this.colorId,
    required this.content,
  });
}

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
        return Color(0xFFDCDE76);
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
    final textColor = getTextColor(post.colorId);

    return Scaffold(
      backgroundColor: post.colorId, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Align(
          child: AppbarLeadingImage(
            imagePath: 'assets/images/arrow-left-r.png',
            margin: EdgeInsets.only(
              top: 19.0,
              bottom: 19.0,
            ),
            onTap: () async {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(top: 10.0, left: 16.0, right: 16.0),
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
              padding:
                  const EdgeInsets.only(top: 10.0, left: 16.0, right: 16.0),
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
  }
}

/*
前端
- 改12種不同顏色的返回鍵
- 未處理留言

後端
- 改_fetchUserData 抓取後端資料
(看是否可以color直接存語法「Color(0xFFFFFF4E)」 這樣可以直接使用)
 */