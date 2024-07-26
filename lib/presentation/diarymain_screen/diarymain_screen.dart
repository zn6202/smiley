import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_export.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:intl/intl.dart';
import '../../widgets/bottom_navigation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sliding_up_panel/sliding_up_panel.dart';

const Color primaryColor = Color(0xFFA7BA89);
TextStyle selectedDateStyle = TextStyle(
    fontSize: 24.fSize, color: Color(0xFF4C543E), fontWeight: FontWeight.w600);

const Color calendarBackgroundColor = Color(0xFFF4F4E6);
const Color addDiaryBackgroundColor = Color(0xFFFFFFFF);

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

  @override
  void initState() {
    super.initState();
    _fetchEmotionData();
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
            body: Container(), // 這裡可以是空的，因為我們已經在 Stack 中添加了日曆
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            onPanelSlide: (double pos) {
              if (pos > 0.9 && _isToday(selectedDate)) {
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
                  'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
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
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA7BA89)),
                      ),
                    );
                  } else if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data!['diary'] != null) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 20.h, right: 20.h, bottom: 36.v),
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
                              children: emotionImages.map((image) => buildEmotionBlock(image)).toList(),
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
                                      image: AssetImage('assets/images/add.png'),
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
                      return Center(
                        child: Text(
                          '',
                          style: TextStyle(
                            fontSize: 18.fSize,
                            color: Color(0xFF545453),
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
    final testData = {
      '2024-07-20': {
        'diary': {
          'content': '昨天我在等買飲料的時候，看到一個阿婆載著大同電鍋準備騎車回家。但是小50的機車體積太小了，阿婆只能頂著電鍋慢慢催油門，甚至差點要跌倒了！我趕緊跳下車來扶阿婆一把，並建議她用走的把東西拿回家、再回來牽車。慢慢來。\r\n\n阿婆謝謝我幫她扶助機車，並且真的拎著電鍋走回去（她家大概只有3分鐘路程）。這是一件小事情，但是收到感謝的那一刻，我的心真的很快樂。'
        }
      },
      '2024-07-21': {
        'diary': {
          'content': '我的前任 離開我 選擇了一個家境好的名校女孩  我的朋友勸過我放下他  但其實他背叛我的時候 我就頭也不回的離開了  我想我真正的難過還是跟原生家庭有關  -  我算是可以唸書的小孩， 不是頂聰明， 但成績也不差， 大約到國中還能校排前20。  但我家一直有兩個問題： 就是窮，還有言語及肢體暴力  窮，所以除了學校以外，我沒有其他資源，這沒關係。  但我吃飯是要看父母臉色的， 以民國98-104年的物價來說， 我整個中學時期每月有5000生活費， 含所有吃喝穿用。  偶爾父親沒工作會拿不到這5000  這是我需要腆著臉找媽媽蹭飯， 她有時給，有時不給，飯桌上也需要接受她的歇斯底里。  經常在他們的腳步聲接近時，我就開始戒備，害怕挨打。至於原因，有時候是因為排水孔有頭髮。  -  後來我填了縣裡的第二志願，因為離家比較近。但還是足足有10公里遠。  為了省車費，高中時期我每天騎20公里單車通勤，腳踏車常掉鏈，我也常遲到，累積不少警告，別問哪家品質那麼差，那是我在二手店用1000塊買的。  因此，我需要更多食物，與睡眠，但家裡時常有紛爭，比方突然關燈嚇人，砸東西，莫名的爭吵與尖叫，所以我經常睡不飽，上課也經常不自覺睡著。  順帶一提，瞌睡及遲到問題讓班導很抓狂，她一直很疑惑我為什麼不買新腳踏車，拿這個當遲到藉口，我也不願意多解釋。  就這麼到高三，高三的時候，我想，要麼死，要嘛搬走，我在學校附近租了5000的套房想拼拼學測，但為了房租，我開始打工。  那時我的時薪是120。  就在我以為一切要稍微正常的時候， 我爸因為長期工作傷害，病倒了。  住到學校附近的醫院，我需要給他送飯，雖然是用他的錢買，但是是我的時間。  再後來，我爸給的5000生活費徹底斷了。因為他動完手術幾乎就算殘廢了，那是我學測前一個月。  -  我因為分數不高，填到外縣市的私校，因為親戚在那，他們表示願意爾偶幫我，但也只是偶爾蹭飯。  我還記得大學面試之前，我為了報名費，交通費，服裝費，省吃儉用了很久。  私校學費不便宜，我只能學貸，要辦貸款的時候，我爸媽卻因為感情不好，不願意共同出面當保證人，最後是我用求的，用印鑑證明的方式才過。  到了大學，我的腦袋沒一刻不在為錢而焦慮，所以我開始打工，又為了打工買了一台二手機車。  大概一年半後，我就休學了。 大學沒畢業這件事，也成為我揮之不去的心魔。  接觸社會後我碰過飲料店、銷售、業務、甚至還有，兩個禮拜的酒店小姐。  我開始了正常的人生。  我以為這樣我就都忘了，都過去了！  但在我的前任離開我，轉投另一個女孩身邊的時候，  我發現，我什麼都記得，只是太痛苦，所以被我塵封了。  2024/06/13 03:10 願我以後能過得更好更幸福，即便很困難。'
        }
      },
      '2024-07-24': {
        'diary': {'content': '今天過得好開心~久違的跟朋友出去玩。'}
      },
      // 可以根據需要添加更多測試數據
    };

    final dateString = DateFormat('yyyy-MM-dd').format(date);
    if (testData.containsKey(dateString)) {
      return testData[dateString]!;
    } else {
      return {};
    }
  }

  Future<void> _fetchEmotionData() async {
    if (_isToday(selectedDate)) {
      setState(() {
        emotionImages = [
          'assets/images/monster_1.png',
          'assets/images/monster_2.png',
        ];
      });
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
                  image: AssetImage(imageUrl),
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
    return date.year == now.year && date.month == now.month && date.day == now.day;
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
後端未連接資料
我先加入測試資料 到時候後端弄好_getTestDiaryData可以刪除
現在程式邏輯是日期是今日去_fetchEmotionData(只有當日才會出現小怪獸能發文)
資料格式都先用圖片網址:'assets/images/monster_1.png' 按下後會把路徑給postPage去顯示 所以如果這裡改了資料格式 記得修改那部分
*/

