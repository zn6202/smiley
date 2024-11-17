import 'dart:ffi';
import 'package:intl/intl.dart';
import '../../core/app_export.dart';
import 'package:url_launcher/url_launcher.dart';
// http
import 'package:http/http.dart' as http;
import '../../routes/api_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
// import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async'; // for TimeoutException
import 'dart:io'; // for SocketExecption

bool _isInitialized = false;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
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
  bool? isPlaying; //false
  AudioPlayer? player; // 保留音樂播放器實例
  String? musicButton = 'music.png'; // 保留音樂播放器實例
  String musicTalk = ' \\ 點我去聽音樂 ! /';
  String musicDialog =
      "音樂能療癒心靈，因為它能釋放情感、放鬆身心、帶來快樂化學物質、\n喚起美好記憶並增強人際聯繫。\n撥放音樂為你的房間增添一點點的溫馨和愉悅吧。";

  @override
  void initState() {
    super.initState();
    checkDiary();
    saveMusicStatus(false);
    saveMusicTalk(' \\ 點我去聽音樂 ! /');
    saveMusicDialog(
        "音樂能療癒心靈，因為它能釋放情感、放鬆身心、帶來快樂化學物質、\n喚起美好記憶並增強人際聯繫。\n撥放音樂為你的房間增添一點點的溫馨和愉悅吧。");
    _initializeMusicStatus();
    if (_isInitialized == false) {
      final messageProvider =
          Provider.of<MessageProvider>(context, listen: false);
      messageProvider.fetchWelcomeMessage();
      _isInitialized = true;
    }

    // _setupPlayerListeners(); // 設置播放器監聽器
  }

  @override
  void dispose() {
    print('音樂暫停且資源釋放中 isPlaying: $isPlaying'); // 拉到左右返回見的時候會跑到這裡
    WidgetsBinding.instance.removeObserver(this);
    if (isPlaying == true) {
      player?.pause(); //音樂暫停
      saveMusicStatus(false);
      saveMusicTalk(' \\ 點我去聽音樂 ! /');
      saveMusicDialog(
          "音樂能療癒心靈，因為它能釋放情感、放鬆身心、帶來快樂化學物質、\n喚起美好記憶並增強人際聯繫。\n撥放音樂為你的房間增添一點點的溫馨和愉悅吧。");
    }
    player?.dispose(); // 釋放音樂資源
    super.dispose();
  }

  // Future<void> disposeMusic() async {
  //   print('音樂暫停且資源釋放中 isPlaying: $isPlaying');
  //   WidgetsBinding.instance.removeObserver(this);
  //   if (isPlaying == true) {
  //     await player?.pause(); // 確保音樂暫停完成
  //     saveMusicStatus(false);
  //     saveMusicTalk(' \\ 點我去聽音樂 ! /');
  //     saveMusicDialog(
  //         "音樂能療癒心靈，因為它能釋放情感、放鬆身心、帶來快樂化學物質、\n喚起美好記憶並增強人際聯繫。\n撥放音樂為你的房間增添一點點的溫馨和愉悅吧。");
  //   }
  //   player?.dispose(); // 釋放資源
  // }

// 設置播放器監聽器
  // void _setupPlayerListeners() {
  //   player?.playerStateStream.listen((playerState) {
  //     if (playerState.playing) {
  //       setState(() {
  //         isPlaying = true;
  //         musicButton = 'musicPause.png';
  //       });
  //     } else {
  //       setState(() {
  //         isPlaying = false;
  //         musicButton = 'music.png';
  //       });
  //     }
  //   });
  // }

  // 初始化音樂狀態
  Future<void> _initializeMusicStatus() async {
    isPlaying = await getMusicStatus();
    musicTalk = await getMusicTalk();
    musicDialog = await getMusicDialog();
    print('初始化的 isPlaying 為: $isPlaying');
    // 根據音樂狀態設置初始值
    // setState(() {
    //   musicButton = isPlaying == true ? musicEmoAngMon : 'music.png';
    // });
  }

  //  抓取當前 user_id
  Future<bool?> getMusicStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('musicStatus') ?? false;
  }

  Future<void> saveMusicStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('musicStatus', status);
  }

  Future<String> getMusicTalk() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('musicTalk') ?? ' \\ 點我去聽音樂 ! /';
  }

  Future<void> saveMusicTalk(String talk) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('musicTalk', talk);
  }

  Future<String> getMusicDialog() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('musicDialog') ??
        '音樂能療癒心靈，因為它能釋放情感、放鬆身心、帶來快樂化學物質、\n喚起美好記憶並增強人際聯繫。\n撥放音樂為你的房間增添一點點的溫馨和愉悅吧。';
  }

  Future<void> saveMusicDialog(String dialog) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('musicDialog', dialog);
  }

  Future<void> toggleMusic() async {
    print('musicButton 是 : $musicButton');
    try {
      if (isPlaying == null || isPlaying == true) {
        //
        // 如果音樂正在播放，則暫停音樂
        print('音樂正在播放 $isPlaying ');
        await player?.pause();
        setState(() {
          isPlaying = false;
          musicButton = 'music.png';
          musicTalk = ' \\ 點我去聽音樂 ! /';
          musicDialog =
              "音樂能療癒心靈，因為它能釋放情感、放鬆身心、帶來快樂化學物質、\n喚起美好記憶並增強人際聯繫。\n撥放音樂為你的房間增添一點點的溫馨和愉悅吧。";
        });
        await saveMusicStatus(isPlaying ?? false);
        print(' isPlaying 是 : $isPlaying');
      } else {
        // 如果音樂未播放，則開始播放
        final String? userId = await getUserId();
        if (userId == null) {
          print("無法獲取 userId");
          return;
        }

        print("進入撥音樂函式 userid: $userId");

        final response = await http.post(
          Uri.parse(API.getMusic),
          body: {
            'user_id': userId,
          },
        ).timeout(Duration(seconds: 60)); // 設置超時

        if (response.statusCode == 200) {
          final result = json.decode(response.body);
          if (result['success']) {
            String musicPath = result['music_path'];
            String musicEmoDialog = result['music_dialog'];
            String musicEmoAngMon = result['music_photo'];

            print(
                "音樂撥放成功 musicPath: $musicPath musicEmoDialog: $musicEmoDialog musicEmoAngMon: $musicEmoAngMon");

            player ??= AudioPlayer();
            await player?.setUrl(musicPath);
            player?.play();

            setState(() {
              isPlaying = true;
              musicButton = musicEmoAngMon;
              musicTalk = ' \\ 點我暫停音樂 ! /';
              musicDialog = musicEmoDialog;
            });
            await saveMusicStatus(isPlaying ?? false);
            await saveMusicTalk(musicTalk);
            await saveMusicDialog(musicDialog);
            print(' isPlaying 是 : $isPlaying');
          } else {
            print('音樂文件未找到。');
          }
        } else {
          print('獲取音樂失敗，狀態碼: ${response.statusCode}');
          throw Exception('Failed to load music');
        }
      }
    } on TimeoutException catch (e) {
      print("請求超時: $e");
    } on SocketException catch (e) {
      print("網絡連接錯誤: $e");
    } catch (e) {
      print("未知錯誤: $e");
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
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: 780.h,
              height: screenHeight,
              child: Stack(
                children: [
                  // 背景圖片 1 (60% 高度)
                  Positioned(
                    left: 0.h,
                    top: 0.v,
                    child: Image.asset(
                      'assets/images/home/background_1.jpg',
                      width: 780.h,
                      height: screenHeight * 0.6,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // 背景圖片 2 (5% 高度)
                  Positioned(
                    left: 0.h,
                    top: screenHeight * 0.6,
                    child: Image.asset(
                      'assets/images/home/background_2.png',
                      width: 780.h,
                      height: screenHeight * 0.05,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // 背景圖片 3 (35% 高度)
                  Positioned(
                    left: 0.h,
                    top: screenHeight * 0.65,
                    child: Image.asset(
                      'assets/images/home/background_3.jpg',
                      width: 780.h,
                      height: screenHeight * 0.35,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // 左側頁面內容 (390x844)
                  Positioned(
                    left: 0.h,
                    top: 0.v,
                    child: Container(
                      width: 390.h,
                      height: 844.v,
                      child: _buildLeftPage(),
                    ),
                  ),
                  // 右側頁面內容 (390x844)
                  Positioned(
                    left: 390.h,
                    top: 0.v,
                    child: Container(
                      width: 390.h,
                      height: 844.v,
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
        // 這裡是下方功能鍵嗎?
        currentIndex: _currentIndex,

        onTap: (index) async {
          // await disposeMusic(); // 等待 disposeMusic 完成
          setState(() {
            _currentIndex = index;
          });
        },
        isTransparent: true,
        isHomeScreen: true,
        audioPlayer: player,
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
              print('音樂暫停且資源釋放中 isPlaying: $isPlaying'); // 拉到左右返回見的時候會跑到這裡
              WidgetsBinding.instance.removeObserver(this);
              if (isPlaying == true) {
                player?.pause(); //音樂暫停
                saveMusicStatus(false);
                saveMusicTalk(' \\ 點我去聽音樂 ! /');
                saveMusicDialog(
                    "音樂能療癒心靈，因為它能釋放情感、放鬆身心、帶來快樂化學物質、\n喚起美好記憶並增強人際聯繫。\n撥放音樂為你的房間增添一點點的溫馨和愉悅吧。");
              }
              player?.dispose(); // 釋放音樂資源
              Navigator.pushNamed(context, AppRoutes.diaryMainScreen);
            },
            child: Transform.rotate(
              angle: -5 * 3.1415927 / 180,
              child: Image.asset(
                'assets/images/home/calendar.png',
                width: 188.h,
                height: 211.v,
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
                print('音樂暫停且資源釋放中 isPlaying: $isPlaying'); // 拉到左右返回見的時候會跑到這裡
                WidgetsBinding.instance.removeObserver(this);
                if (isPlaying == true) {
                  player?.pause(); //音樂暫停
                  saveMusicStatus(false);
                  saveMusicTalk(' \\ 點我去聽音樂 ! /');
                  saveMusicDialog(
                      "音樂能療癒心靈，因為它能釋放情感、放鬆身心、帶來快樂化學物質、\n喚起美好記憶並增強人際聯繫。\n撥放音樂為你的房間增添一點點的溫馨和愉悅吧。");
                }
                player?.dispose(); // 釋放音樂資源
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
                    margin: EdgeInsets.all(10.h),
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
        //畫
        Positioned(
          right: 33.h,
          top: 170.v,
          child: GestureDetector(
            onTap: () {
              showPerfumeDialog(context); // 修改
            },
            child: Image.asset(
              'assets/images/home/paint.png',
              width: 223.h,
              height: 252.v,
              fit: BoxFit.contain,
            ),
          ),
        ),
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

  void showPerfumeDialog(BuildContext context) async {
    // 先從本地存儲中獲取今天的花名和花語
    final prefs = await SharedPreferences.getInstance();
    final String? perfumeName = prefs.getString('perfumeName');
    final String? perfume = prefs.getString('perfume');
    final String? perfumeImage = prefs.getString('perfumeImage');
    final String? lastFetchPerfumeDate =
        prefs.getString('lastFetchPerfumeDate');
    print('進入每日香氛函式');
    print('花名:$perfumeName 香氛味道:$perfume 圖像:$perfumeImage');

    // 如果今天還沒寫日記，顯示先寫日記
    if (!hasDiaryToday) {
      print('先寫日記');
      _showNotPerfumeDialog(context);
    } // 今天已寫日記，今天非第一次點擊
    else if (perfumeName != null &&
        perfume != null &&
        perfumeImage != null &&
        lastFetchPerfumeDate ==
            DateTime.now().toIso8601String().substring(0, 10)) {
      print('取得舊的香氛');
      _showPerfumeDialog(context, perfumeName, perfume, perfumeImage);
    } // 今天已寫日記，今天第一次點擊
    else {
      print('取得新的香氛');
      final String? userId = await getUserId();
      // 否則從後端請求新的花名和花語
      final response = await http.post(
        Uri.parse(API.getPerfume),
        body: {
          'user_id': userId,
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final name = data['name'];
        final meaning = data['meaning'];
        final perfume = data['perfume'];
        final image = data['image'];

        // 更新本地存儲
        await prefs.setString('perfumeName', name);
        await prefs.setString('perfume', perfume);
        await prefs.setString('perfumeMeaning', meaning);
        await prefs.setString('perfumeImage', image);
        await prefs.setString('lastFetchPerfumeDate',
            DateTime.now().toIso8601String().substring(0, 10));

        // 顯示對話框
        _showPerfumeDialog(context, name, perfume, image);
      } else {
        // 處理錯誤
        print('Failed to load flower data');
      }
    }
  }

void _showPerfumeDialog(
  BuildContext context, String name, String perfume, String image) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.v),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(26.0.v),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Fixed Title
                Text(
                  '精油',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                // 分割線
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
                SizedBox(height: 8.v),
                // Subtitle
                Text(
                  '今天適合你的精油是 「$name」',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                // Image
                Image.network(
                  'http://163.22.32.24/smiley_backend/img/angel/$image',
                  height: 100.0.v,
                  width: 100.0.v,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 20.v),
                // Description
                Text(
                  perfume,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black87,
                    height: 1.5.v, // Line spacing
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.v),
                // 芳療師聊天室
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.chatScreen,
                      arguments: {
                        'imageUrl': 'http://163.22.32.24/smiley_backend/img/angel/$image',
                      },
                    );
                  },
                  child: styledContainer("與芳療師聊聊"),
                ),
                SizedBox(height: 10.v),
                //香氛商場
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.shopScreen);
                  },
                  child: styledContainer('去植芳園商場逛逛'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}


  void _showNotPerfumeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 16.v),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 標題文本
                Text(
                  '精油', // 固定標題
                  textAlign: TextAlign.center,
                  style: dialogTitleStyle,
                ),
                SizedBox(height: 10.v),
                // 中間分割線
                Container(
                  width: 244.5.h,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1.h,
                        color: Color(0xFFDADADA), // 灰色邊框
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.v),

                // 說明文本 (天竺葵)
                Text(
                  '寫日記得知最佳精油',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.fSize, // 調整字體大小
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10.v),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget styledContainer(String text) { //花語的按鈕樣式
    return Container(
      width: 253.0.v,
      padding: EdgeInsets.all(10.0.v), 
      decoration: BoxDecoration(
        color: Color(0xFFA7BA89), 
        borderRadius: BorderRadius.circular(20.0.v), 
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            offset: Offset(0.v, 4.v), 
            blurRadius: 4.0.v, 
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // 設置主軸對齊方式
        crossAxisAlignment: CrossAxisAlignment.center, // 設置交叉軸對齊方式
        children: [
          Text(
            text, // 使用傳入的文字內容
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void showFlowerDialog(BuildContext context) async {
    // 先從本地存儲中獲取今天的花名和花語
    final prefs = await SharedPreferences.getInstance();
    final String? flowerName = prefs.getString('flowerName');
    final String? flowerMeaning = prefs.getString('flowerMeaning');
    final String? flowerPerfume = prefs.getString('flowerPerfume');
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
        final perfume = data['perfume'];
        final image = data['image'];

        // 更新本地存儲
        await prefs.setString('flowerName', name);
        await prefs.setString('flowerMeaning', meaning);
        await prefs.setString('flowerPerfume', perfume);
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
  
  void _showDialog(BuildContext context, String name, String meaning, String image) {
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
                    '今日隨機花語',
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
                    '「$name」',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.fSize, // 調整字體大小
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
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

  Future<void> showMusicDialog(BuildContext context) async {
    return showDialog(
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
                    musicDialog, // "音樂能療癒心靈，因為它能釋放情感、放鬆身心、帶來快樂化學物質、\n喚起美好記憶並增強人際聯繫。\n撥放音樂為你的房間增添一點點的溫馨和愉悅吧。",
                    textAlign: TextAlign.center,
                    style: dialogContentStyle,
                  ),
                ),
                SizedBox(height: 7.v),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      musicTalk, //" \\ 點我去聽音樂 ! /", // '\'使用兩個反斜杠來顯示一個反斜杠
                      style: TextStyle(
                        fontSize: 12.fSize,
                        height: 1.75.v,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF9C9C94),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(width: 10.h),
                    GestureDetector(
                      onTap: () async {
                        // 執行 toggleMusic 並獲取音樂檔案名稱
                        await toggleMusic();
                        // 關閉當前對話框
                        Navigator.pop(context);
                        // 顯示新的對話框
                        await showMusicDialog(context);
                      },
                      child: Image.network(
                        "http://163.22.32.24/smiley_backend/img/music/${musicButton}",
                        width: 122.h,
                        height: 88.v,
                        fit: BoxFit.contain,
                        key: UniqueKey(), // 使用 UniqueKey 強制重新加載圖片
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

// 703可以改文字 兩段和在一起 後端處理可以分開接後再前端猴變新增一個變數儲存顯示 真的要切就複製702-710就好