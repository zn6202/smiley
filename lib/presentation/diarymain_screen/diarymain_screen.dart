import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_export.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:intl/intl.dart';
import '../../widgets/bottom_navigation.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
// http
import 'package:http/http.dart' as http;
import '../../routes/api_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

const Color primaryColor = Color(0xFFA7BA89);
TextStyle selectedDateStyle = TextStyle(
    fontSize: 24.fSize, color: Color(0xFF4C543E), fontWeight: FontWeight.w600);

const Color calendarBackgroundColor = Color(0xFFF4F4E6);
const Color addDiaryBackgroundColor = Color(0xFFFFFFFF);

// 此route是否已初始化過一次
bool _hasInitialized = false; //

class DiaryMainScreen extends StatefulWidget {
  @override
  _DiaryMainScreenState createState() => _DiaryMainScreenState();
}

class _DiaryMainScreenState extends State<DiaryMainScreen> {
  DateTime? selectedDate = DateTime.now();
  int _currentIndex = 2;
  final PanelController _panelController = PanelController();
  List<String> emotionImages = [];
  bool showEmotionBlock = false;

  // 聊天機器人資料
  Map<String, String>? welcomeMessage; // 歡迎訊息
  // 初始化執行程序
  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    // 判斷是否初始化過一次了
    if (!_hasInitialized) {
      _hasInitialized = true;
      _fetchEmotionData();
      final messageProvider =
          Provider.of<MessageProvider>(context, listen: false);
        messageProvider.fetchWelcomeMessage(); // 取得助手機器人歡迎訊息
    }
  }
  void dispose() {
    super.dispose(); 
  } //

  @override
  void initState() {
    super.initState();
    _fetchEmotionData();
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: calendarBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              _buildCalendar(),
              Expanded(child: Container()), // 填充剩餘空間
            ],
          ),
          SlidingUpPanel(
            controller: _panelController,
            minHeight: MediaQuery.of(context).size.height * 0.5,
            maxHeight: MediaQuery.of(context).size.height,
            panel: _buildAddDiary(),
            body: Container(),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            onPanelSlide: (double pos) {
              if (_isToday(selectedDate)) {
                setState(() {
                  showEmotionBlock = true;
                });
              } else {
                setState(() {
                  showEmotionBlock = false;
                });
              }
            },
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
      ),
    );
  }

  Widget _buildCalendar() {
    final screenSize = MediaQuery.of(context).size;
    final calendarWidth = screenSize.width * 0.9;
    final calendarHeight = screenSize.height * 0.4;
    return Container(
      color: calendarBackgroundColor,
      height: calendarHeight,
      child: Padding(
        padding: EdgeInsets.only(top: 40.v), // 增加頂部填充以避免狀態欄遮擋
        child: Center(
          child: SizedBox(
            width: calendarWidth,
            child: CalendarDatePicker2(
              config: CalendarDatePicker2Config(
                selectedDayHighlightColor: primaryColor,
                selectedDayTextStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                weekdayLabelTextStyle: TextStyle(
                  color: Color(0xFF545453),
                  fontWeight: FontWeight.bold,
                ),
                dayTextStyle: TextStyle(
                  color: Color(0xFF545453),
                  fontWeight: FontWeight.bold,
                ),
                weekdayLabels: [
                  'Sun',
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat'
                ],
                // 你可能需要調整日期的文字大小以適應較小的日曆
                calendarType: CalendarDatePicker2Type.single,
              ),
              value: [selectedDate ?? DateTime.now()],
              onValueChanged: (value) {
                if (value.first != null) {
                  setState(() {
                    selectedDate = value.first;
                    if (_isToday(selectedDate)) {
                      _fetchEmotionData();
                    } else {
                      emotionImages = [];
                    }
                  });
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddDiary() {
    return Container(
      decoration: BoxDecoration(
        color: addDiaryBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.h, 24.v, 12.h, 16.v),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20.h, right: 20.h),
              child: Text(
                "${DateFormat('yyyy.MM.dd').format(selectedDate ?? DateTime.now())}",
                style: selectedDateStyle,
              ),
            ),
            SizedBox(height: 10.v),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _getTestDiaryData(selectedDate!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFA7BA89)),
                      ),
                    );
                  } else if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data!['diary'] != null) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left: 20.h, right: 20.h, bottom: 36.v),
                            child: Text(
                              snapshot.data!['diary']['content'],
                              style: TextStyle(
                                fontSize: 18.fSize,
                                height: 1.5 * 1.v,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w100,
                                color: Color(0xFF545453),
                              ),
                            ),
                          ),
                          if (showEmotionBlock && emotionImages.isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: emotionImages
                                  .map((image) => buildEmotionBlock(image))
                                  .toList(),
                            ),
                        ],
                      ),
                    );
                  } else {
                    bool isToday = _isToday(selectedDate);

                    if (isToday) {
                      return Stack(
                        children: [
                          Positioned(
                            top: 146.v,
                            left: 0.h,
                            right: 0.h,
                            child: GestureDetector(
                              onTap: () {
                                _showAddDiaryScreen(context);
                              },
                              child: Align(
                                alignment: Alignment.center,
                                child: Container(
                                  width: 60.h,
                                  height: 60.v,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image:
                                          AssetImage('assets/images/add.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Container(
                        padding: EdgeInsets.only(
                            left: 20.h, right: 20.h, bottom: 36.v),
                        child: Text(
                          '這一天沒有寫日記 ~',
                          style: TextStyle(
                            fontSize: 18.fSize,
                            color: Color(0xFF545453),
                            height: 1.5 * 1.v,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
            SizedBox(height: 35.v),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _getTestDiaryData(DateTime date) async {
    final String? userId = await getUserId();
    final dateString = DateFormat('yyyy-MM-dd').format(date);

    print("進入月曆日記函式");
    print('user_id: $userId');

    final response = await http.post(
      Uri.parse(API.getDiary),
      body: {
        'user_id': userId!,
      },
    );

    if (response.statusCode == 200) {
      // 解析返回的 JSON 數據
      Map<String, dynamic> data = jsonDecode(response.body);

      if (data['success'] == true) {
        // 確認 'diaries' 是否存在並且具有指定日期的日記
        if (data['diaries'] != null && data['diaries'][dateString] != null) {
          print(
              "在指定日期找到日記 date: $dateString diary: ${data['diaries'][dateString]['diary']['content']}");
          return {"diary": data['diaries'][dateString]['diary']}; // 返回指定日期的日記數據
        } else {
          print('在指定日期未找到日記');
          return {}; // 返回空的 Map
        }
      } else {
        print('取得日記內容失敗: ${data['message']}');
        return {};
      }
    } else {
      print('取得貼文內容失敗...');
      return {};
    }
  }

  Future<void> _fetchEmotionData() async {
    final String? userId = await getUserId();
    String todayDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
    print("進入抓取小天使小怪獸函式");
    print('user_id: $userId date: $todayDate');

    final response = await http.post(
      Uri.parse(API.getAngMon),
      body: {
        'user_id': userId,
        'date': todayDate,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      if (data['success'] == true) {
        setState(() {
          emotionImages = List<String>.from(data['emotionImages']);
        });
        print('emotionImages: ${data['emotionImages']}');
        // setState(() {
        //   emotionImages = [
        //     'http://163.22.32.24/smiley_backend/img/angel_monster/monster_1.png',
        //     'http://163.22.32.24/smiley_backend/img/angel_monster/monster_2.png',
        //   ];
        // });
      } else {
        print('貼文瀏覽失敗... ${data['message']}');
      }
    } else {
      print('貼文瀏覽失敗...');
    }
  }

  Widget buildEmotionBlock(String imageUrl) {
    return Container(
      width: 150.h,
      height: 246.v,
      padding: EdgeInsets.symmetric(horizontal: 18.h, vertical: 20.v),
      margin: EdgeInsets.symmetric(horizontal: 14.5.h),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Color(0xFFC4C4C4)),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          print("imageUrl 是: $imageUrl");
          Navigator.pushNamed(context, AppRoutes.postPage, arguments: imageUrl);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 106.h,
              height: 27.v,
              child: Text(
                '情緒小怪獸',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFC4C4C4),
                  fontSize: 16.fSize,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.32,
                ),
              ),
            ),
            Container(
              width: 126.h,
              height: 122.v,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            SizedBox(height: 30.v),
            Container(
              width: 114.h,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                '輕觸發文',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFCDCED0),
                  fontSize: 15.fSize,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  height: 1.5.v / 15.fSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDiaryScreen(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.addDiaryScreen);
  }

  bool _isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

/*
  // 從後端獲取日記數據的函數
  Future<Map<String, dynamic>> _fetchDiaryData(DateTime date) async {
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    final response = await http.get(Uri.parse('http://192.168.56.1/smiley_backend/diaries?date=$dateString'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['diary'] != null && data['diary']['content'] != null) {
        return data;
      } else {
        return {};
      }
    } else {
      throw Exception('Failed to load diary data');
    }
  }*/
}

/*
 1. 非當日之前的日記顯示畫面
    o 無日記 -> 直接反灰 無法點選
 */

/*
後端: -> 已解決
- 297 _fetchEmotionData 從資料庫抓取正確的小天使小怪獸 -> 163.22.32.24

*/

