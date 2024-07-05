// 匯入 Flutter 材料設計套件。
import 'package:flutter/material.dart';
import '../../core/app_export.dart';
// 匯入日曆日期選擇器套件，以使用日曆小部件。
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
// 匯入國際化工具套件，用於日期格式化。
import 'package:intl/intl.dart';
import '../../widgets/bottom_navigation.dart'; // 引用自訂的 BottomNavigationBar
import 'dart:convert'; // 用於 JSON 處理
import 'package:http/http.dart' as http; // 用於 HTTP 請求

// 主題色彩常數，用於應用程式中的主色調。
const Color primaryColor = Color(0xFFA7BA89);
// 選定日期的文字樣式常數，包括字體大小、顏色和粗體設定。
const TextStyle selectedDateStyle = TextStyle(
    fontSize: 24.0, color: Color(0xFF545453), fontWeight: FontWeight.bold);

// 日曆視圖的背景顏色。
const Color calendarBackgroundColor = Color(0xFFF4F4E6);
// 新增日記條目區域的背景顏色。
const Color addDiaryBackgroundColor = Color(0xFFFFFFFF);

// 日記主畫面的 StatefulWidget。
class DiaryMainScreen extends StatefulWidget {
  @override
  _DiaryMainScreenState createState() => _DiaryMainScreenState();
}

// DiaryMainScreen 的狀態管理類別，管理小部件的狀態。
class _DiaryMainScreenState extends State<DiaryMainScreen> {
  // 儲存當前選定日期的變數，初始化為今天。
  DateTime? selectedDate = DateTime.now();
  int _currentIndex = 2;

  @override
  // 構建主要小部件結構。
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold 提供一個架構以布局主要組件。
      backgroundColor: calendarBackgroundColor, // 將背景顏色設置為日曆底色
      body: Container(
        color: calendarBackgroundColor, // 設定整個螢幕的背景顏色為日曆背景顏色。
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 在列中居中對齊內容。
          children: [
            // 每個子元件均分屏幕空間。
            Expanded(
              flex: 1,
              child: Center(
                child: _buildCalendar(), // 構建並顯示日曆的小部件，垂直居中。
              ),
            ),
            Expanded(
              flex: 1,
              child: _buildAddDiary(), // 構建並顯示日記條目介面的小部件。
            ),
          ],
        ),
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

  // 構建日曆小部件的函數。
  Widget _buildCalendar() {
    return Container(
      color: calendarBackgroundColor, // 設定日曆容器的背景顏色。
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0), // 日曆的水平填充。
        child: CalendarDatePicker2(
          config: CalendarDatePicker2Config(
            selectedDayHighlightColor: primaryColor, // 高亮顯示選定日的顏色。
            selectedDayTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold, // 選定日的文字樣式。
            ),
            weekdayLabelTextStyle: TextStyle(
              color: Color(0xFF545453),
              fontWeight: FontWeight.bold, // 星期標籤的文字樣式。
            ),
            dayTextStyle: TextStyle(
              color: Color(0xFF545453),
              fontWeight: FontWeight.bold, // 其他日期的文字樣式。
            ),
            weekdayLabels: [
              'Sun',
              'Mon',
              'Tue',
              'Wed',
              'Thu',
              'Fri',
              'Sat'
            ], // 自定義星期標籤
          ),
          value: [selectedDate ?? DateTime.now()], // 當前選定的日期，如果為 null 則為今天。
          onValueChanged: (value) {
            // 當日期被選擇時的回調函數。
            if (value.first != null) {
              setState(() {
                selectedDate = value.first; // 更新選定日期。
              });
            }
          },
        ),
      ),
    );
  }
// 構建新增日記小部件的函數。
Widget _buildAddDiary() {
  bool isToday = selectedDate != null &&
      selectedDate!.year == DateTime.now().year &&
      selectedDate!.month == DateTime.now().month &&
      selectedDate!.day == DateTime.now().day; // 判斷選定日期是否為今天。
  return Container(
    decoration: BoxDecoration(
      color: addDiaryBackgroundColor,
      borderRadius: BorderRadius.circular(20.0), // 容器的圓角設定。
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0), // 容器內部的填充。
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 將子元件對齊到列的起始位置。
        children: [
          Text(
            "${DateFormat('yyyy.MM.dd').format(selectedDate ?? DateTime.now())}",
            style: selectedDateStyle, // 日期文字的樣式。
          ),
          SizedBox(height: 27.0), // 與日期文字之間的距離。
          Expanded(
            child: Center(
              child: isToday
                  ? GestureDetector(
                      onTap: () {
                        _showAddDiaryScreen(context); // 按鈕動作觸發顯示底部彈窗。
                      },
                      child: Container(
                        width: 60, // 按鈕的寬度
                        height: 60, // 按鈕的高度
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, // 圓形形狀
                          image: DecorationImage(
                            image: AssetImage('assets/images/add.png'), // 替換為您的圖片路徑
                            fit: BoxFit.cover, // 確保圖片完全填滿容器
                          ),
                        ),
                      ),
                    )
                  : FutureBuilder<Map<String, dynamic>>(
                      future: _fetchDiaryData(selectedDate!), // 從後端獲取日記數據
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA7BA89)), // 設置加載圓圈的顏色
                          ); // 加載中顯示旋轉指示器
                        } else if (snapshot.hasData && snapshot.data != null) {
                          return Text(snapshot.data!['diary']['content']); // 顯示日記內容
                        } else {
                          return Text(''); // 無數據顯示提示
                        }
                      },
                    ),
            ),
          ),
          SizedBox(height: 36.0), // 與底部之間的距離
        ],
      ),
    ),
  );
}

  // 顯示新增日記頁面的函數。
  void _showAddDiaryScreen(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.addDiaryScreen);
  }

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
  }
}



/*
 1. 非當日之前的日記顯示畫面
    o 有日記 -> 日記內容 (等候端串接 再來修改內容顯示格式等)
    o 無日記 -> ??? (目前無顯示東西 等組內開會與大家討論)
 */