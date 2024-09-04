import 'dart:ffi';
import 'package:intl/intl.dart';
import '../../core/app_export.dart';
import 'package:url_launcher/url_launcher.dart';
// http
import 'package:http/http.dart' as http;
import '../../routes/api_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextStyle dialogContentStyle = TextStyle(
    color: Color(0xFF545453),
    fontSize: 16.fSize,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,
  );
  TextStyle dialogTitleStyle = TextStyle(
    color: Color(0xFF545453),
    fontSize: 25.fSize,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w100,
  );
  int _currentIndex = 2;
  bool hasDiaryToday = false;

  @override
  void initState() {
    super.initState();
    checkDiary();
  }

  Future<void> getMusic() async {
    final String? userId = await getUserId();
    print("進入撥音樂函式 userid: $userId");

    final response = await http.post(
      Uri.parse(API.getMusic), // 解析字串變成 URI 對象
      body: {
        'user_id': userId!,
      },
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['success']) {
        String musicPath = result['music_path'];
        print("音樂撥放成功: $musicPath");
        AudioPlayer audioPlayer = AudioPlayer();
        await audioPlayer.play(UrlSource(musicPath));
      } else {
        print('User not found.');
      }
    } else {
      throw Exception('Failed to load user');
    }
  }

  //  抓取當前 user_id
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<void> checkDiary() async {
    final String? userId = await getUserId();
    String date = DateFormat('yyyy.MM.dd').format(DateTime.now());

    print("進入主頁日記是否寫了函式");
    print('user_id: $userId');
    print('date: $date');

    final response = await http.post(
      Uri.parse(API.getDiaryBool),
      body: {
        'user_id': userId ?? '',
        'date': date,
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      if (data['success'] == true) {
        print("今日日記已完成是 : ${data}");
        setState(() {
          hasDiaryToday = data['diary_bool'];
        });
      } else {
        print('今日日記未完成... $data');
        setState(() {
          hasDiaryToday = data['diary_bool'];
        });
      }
    } else {
      print('貼文瀏覽失敗...');
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: 780,
              height: 844,
              child: Stack(
                children: [
                  // 背景圖片 1 (60% 高度)
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Image.asset(
                      'assets/images/home/background_1.jpg',
                      width: 780,
                      height: 844 * 0.6,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // 背景圖片 2 (5% 高度)
                  Positioned(
                    left: 0,
                    top: 844 * 0.6,
                    child: Image.asset(
                      'assets/images/home/background_2.png',
                      width: 780,
                      height: 844 * 0.05,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // 背景圖片 3 (35% 高度)
                  Positioned(
                    left: 0,
                    top: 844 * 0.65,
                    child: Image.asset(
                      'assets/images/home/background_3.jpg',
                      width: 780,
                      height: 844 * 0.35,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // 左側頁面內容 (390x844)
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 390,
                      height: 844,
                      child: _buildLeftPage(),
                    ),
                  ),
                  // 右側頁面內容 (390x844)
                  Positioned(
                    left: 390,
                    top: 0,
                    child: Container(
                      width: 390,
                      height: 844,
                      child: _buildRightPage(),
                    ),
                  ),
                  //窗
                  Positioned(
                    left: 258.h,
                    top: 67.v,
                    child: Image.asset(
                      'assets/images/home/window.png',
                      width: 186.h,
                      height: 355.v,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        isTransparent: true,
        isHomeScreen: true,
      ),
    );
  }

  Widget _buildLeftPage() {
    return Stack(
      children: [
        // 輪盤
        Positioned(
          left: 102.h,
          top: 82.v,
          child: Image.asset(
            'assets/images/home/roulette.png',
            width: 85.h,
            height: 87.v,
            fit: BoxFit.contain,
          ),
        ),
        //日曆
        Positioned(
          left: 12.h,
          top: 182.v,
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.diaryMainScreen);
            },
            child: Transform.rotate(
              angle: -5 * 3.1415927 / 180,
              child: Image.asset(
                'assets/images/home/calendar.png',
                width: 188.0,
                height: 211.0,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        //椅子
        Positioned(
          left: 25.h,
          top: 456.v,
          child: Image.asset(
            'assets/images/home/chair.png',
            width: 143.h,
            height: 234.v,
            fit: BoxFit.contain,
          ),
        ),
        //人
        Positioned(
          left: 75.h,
          top: 354.v,
          child: Image.asset(
            'assets/images/home/people.png',
            width: 225.h,
            height: 378.v,
            fit: BoxFit.contain,
          ),
        ),
        //花
        Positioned(
          left: 215.h,
          top: 430.v,
          child: GestureDetector(
            onTap: () {
              showFlowerDialog(context);
            },
            child: Transform.rotate(
              angle: 5 * 3.1415927 / 180,
              child: Image.asset(
                'assets/images/home/flower.png',
                width: 94.h,
                height: 155.v,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        //桌
        Positioned(
          left: 224.h,
          top: 560.v,
          child: Image.asset(
            'assets/images/home/table.png',
            width: 147.h,
            height: 196.v,
            fit: BoxFit.contain,
          ),
        ),
        //日記
        Positioned(
          left: 230.h,
          top: 530.v,
          child: GestureDetector(
            onTap: () {
              if (!hasDiaryToday) {
                Navigator.pushNamed(context, AppRoutes.addDiaryScreen);
              } else {
                // 可以在這裡添加一些提示，比如顯示一個 SnackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '今天已經寫過日記了！',
                      style: dialogContentStyle,
                    ),
                    backgroundColor: Color(0xFFFFFFFF),
                    duration: Duration(seconds: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(10),
                  ),
                );
              }
            },
            child: Transform.rotate(
              angle: 15 * 3.1415927 / 180,
              child: Image.asset(
                'assets/images/home/diary.png',
                width: 135.h,
                height: 133.v,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRightPage() {
    return Stack(
      children: [
        //桌
        Positioned(
          right: 143.h,
          top: 422.v,
          child: Image.asset(
            'assets/images/home/table_2.png',
            width: 186.h,
            height: 192.v,
            fit: BoxFit.contain,
          ),
        ),
        //茶
        Positioned(
          right: 203.h,
          top: 403.v,
          child: Image.asset(
            'assets/images/home/tea.png',
            width: 57.h,
            height: 70.v,
            fit: BoxFit.contain,
          ),
        ),
        //音響
        Positioned(
          right: 18.h,
          top: 547.v,
          child: GestureDetector(
            onTap: () {
              showMusicDialog(context);
            },
            child: Image.asset(
              'assets/images/home/audio.png',
              width: 146.h,
              height: 203.v,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }

  void showFlowerDialog(BuildContext context) async {
    // 先從本地存儲中獲取今天的花名和花語
    final prefs = await SharedPreferences.getInstance();
    final String? flowerName = prefs.getString('flowerName');
    final String? flowerMeaning = prefs.getString('flowerMeaning');
    final String? flowerImage = prefs.getString('flowerImage');
    final String? lastFetchDate = prefs.getString('lastFetchDate');
    print('進入每日隨機花語函式');
    print('花名:$flowerName 花語:$flowerMeaning 圖像:$flowerImage');

    // 如果今天的花名和花語已經存在，直接使用
    if (flowerName != null &&
        flowerMeaning != null &&
        flowerImage != null &&
        lastFetchDate == DateTime.now().toIso8601String().substring(0, 10)) {
      _showDialog(context, flowerName, flowerMeaning, flowerImage);
    } else {
      // 否則從後端請求新的花名和花語
      final response = await http.post(
        Uri.parse(API.getFlower),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final name = data['name'];
        final meaning = data['meaning'];
        final image = data['image'];

        // 更新本地存儲
        await prefs.setString('flowerName', name);
        await prefs.setString('flowerMeaning', meaning);
        await prefs.setString('flowerImage', image);
        await prefs.setString(
            'lastFetchDate', DateTime.now().toIso8601String().substring(0, 10));

        // 顯示對話框
        _showDialog(context, name, meaning, image);
      } else {
        // 處理錯誤
        print('Failed to load flower data');
      }
    }
  }

  void _showDialog(
      BuildContext context, String name, String meaning, String image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Container(
            // width: 304.h,
            // height: 190.0.v,
            padding: EdgeInsets.symmetric(horizontal: 23.h, vertical: 16.v),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // 確保 Column 的大小僅根據其內容來確定
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    style: dialogTitleStyle,
                  ),
                ),
                SizedBox(height: 10.v),
                Container(
                  width: 244.5.h,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1.h,
                        color: Color(0xFFDADADA),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.v),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    meaning,
                    textAlign: TextAlign.center,
                    style: dialogContentStyle,
                  ),
                ),
                // SizedBox(height: 10.v),
                Image.network(
                  'http://163.22.32.24/smiley_backend/img/angel/$image',
                  height: 170.v, // 調整圖片高度
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  showMusicDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Container(
            // width: 304.h,
            // height: 265.0.v,
            padding: EdgeInsets.only(
                left: 23.h, right: 23.h, top: 23.v, bottom: 13.v),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, //容器的大小會隨著內部子元素的總大小而調整
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    '音樂',
                    textAlign: TextAlign.center,
                    style: dialogTitleStyle,
                  ),
                ),
                SizedBox(height: 10.v),
                Container(
                  width: 244.5.h,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1.h,
                        color: Color(0xFFDADADA),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.v),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    "音樂能療癒心靈，因為它能釋放情感、放鬆身心、帶來快樂化學物質、\n喚起美好記憶並增強人際聯繫。",
                    textAlign: TextAlign.center,
                    style: dialogContentStyle,
                  ),
                ),
                SizedBox(height: 7.v),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: getMusic,
                      // () {
                      //   _launchURL(
                      //       'https://youtu.be/Ntr0ZnRr7Qo?si=Es3Akat9qymQlvrs');
                      // },
                      child: Image.asset(
                        'assets/images/home/music.png',
                        width: 122.h,
                        height: 88.v,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(width: 10.h),
                    Text(
                      "(點我去聽音樂 ! )",
                      style: TextStyle(
                        fontSize: 12.fSize,
                        height: 1.75,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF9C9C94),
                      ),
                      textAlign: TextAlign.center,
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

/**
後端修改:
- 剛寫完案返回會無更新
 */