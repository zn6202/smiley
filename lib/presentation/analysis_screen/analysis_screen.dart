import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:smiley/core/app_export.dart';
import '../../widgets/bottom_navigation.dart';
import 'package:http/http.dart' as http;
import '../../routes/api_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

const Color backgroundColor = Color(0xFFF4F4E6);

class AnalysisScreen extends StatefulWidget {
  @override
  _AnalysisScreenState createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  int _currentIndex = 1;
  List<bool> isSelected = [true, false, false];
  DateTime? selectedDate = DateTime.now();
  bool haveDiary = false;
  List<PieChartSectionData> pieChartSections = [];
  String dateRangeText = '';
  String titleText = '今日日記的情緒佔比';
  List<FlSpot> positiveEmotionData = [];
  List<FlSpot> negativeEmotionData = [];
  Map<String, dynamic> todayData = {}; // 日
  Map<String, dynamic> dailyData = {}; // 週月
  List<double> positiveSums = [];
  List<double> negativeSums = [];


  @override
  void initState() {
    super.initState();
    fetchData();
    updateDateRangeAndTitle();
  }

  Future<String?> getUserId() async { // 使用者的 id
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<Map<String, dynamic>> analysisResult(DateTime date) async{ 
    final String? userId = await getUserId();
    // 只取日期部分，格式化為 YYYY-MM-DD
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    print("進入顯示分析圖表函式 userId: $userId, formattedDate: $formattedDate");

    final response = await http.post(
      Uri.parse(API.getAnalysis), // 解析字串變成 URI 對象
      body: {
        'user_id':userId,
        'date': formattedDate, // 將日期轉成ISO 8601
      },
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['success']) {
        print('分析圖表成功! 結果為 $result');
        return {
          'happiness': result['happiness'],
          'like': result['like'],
          'sadness': result['sadness'],
          'disgust': result['disgust'],
          'anger': result['anger'],
        };
      } else {
        print('分析圖表失敗...');
        return {};
      }
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<void> fetchData() async {
    // 今日日期
    DateTime endDate = DateTime.now();
    // 判斷是否月初
    bool isStartOfMonth = endDate.day == 1;
    // 當月第一天
    DateTime firstDayOfThisMonth = DateTime(endDate.year, endDate.month, 1);
    // 上個月的第一天
    DateTime firstDayOfLastMonth = DateTime(firstDayOfThisMonth.year, firstDayOfThisMonth.month - 1, 1);
    // 上個月的最後一天
    DateTime lastDayOfLastMonth = DateTime(firstDayOfLastMonth.year, firstDayOfLastMonth.month + 1, 0);
    // 計算上個月有幾天(會少一天因為是計算間隔)
    int daysDifference = lastDayOfLastMonth.difference(firstDayOfLastMonth).inDays ;
    // 今日星期幾
    int weekDay = endDate.weekday;
    String weekDayName;
    switch (weekDay) {
      case DateTime.monday:
        weekDayName = '星期一';
        break;
      case DateTime.tuesday:
        weekDayName = '星期二';
        break;
      case DateTime.wednesday:
        weekDayName = '星期三';
        break;
      case DateTime.thursday:
        weekDayName = '星期四';
        break;
      case DateTime.friday:
        weekDayName = '星期五';
        break;
      case DateTime.saturday:
        weekDayName = '星期六';
        break;
      case DateTime.sunday:
        weekDayName = '星期日';
        break;
      default:
        weekDayName = '未知';
        break;
    }
    print('今天是: $weekDayName');
    print('是否為月初: $isStartOfMonth');
    // 上週的星期一
    DateTime lastMonday = endDate.subtract(Duration(days: weekDay + 6));
    // 上週的星期天
    DateTime lastSunday = lastMonday.add(Duration(days: 6));

    positiveSums = []; // 正面情緒數值陣列
    negativeSums = []; // 負面情緒數值陣列
    double positiveSum = 0;
    double negativeSum = 0;
    double mul = 0;
    double positiveResult = 0;
    double negativeResult = 0;

    // 為星期一，顯示新的上週折線圖；為月初，顯示新的上個月折線圖
    if ((isSelected[1] && weekDayName=="星期一") || (isSelected[2] && isStartOfMonth)) {
      int days = isSelected[1] ? 6 : 28;
      DateTime startDate = endDate.subtract(Duration(days: days));
      int time = 0;

      // 週、月分析
      for (int i = 0; i <= days; i++) {
        DateTime currentDate = startDate.add(Duration(days: i));
        dailyData = await analysisResult(currentDate); // 去後端拿資料
        time = addEmotionResults(dailyData, time);
      }
      print(positiveResult);
      print(negativeResult);
      print('有寫日記的天數0: $time positiveSums: $positiveSums negativeSums: $negativeSums');
      if (time == 0 ){
        setState(() {
          haveDiary = false;
        });
      }else{
        setState(() {
          positiveEmotionData = [
            for (int i = 0; i < time; i++) FlSpot(i.toDouble(), positiveSums[i])
          ];
          negativeEmotionData = [
            for (int i = 0; i < time; i++) FlSpot(i.toDouble(), negativeSums[i])
          ];
          haveDiary = true;
        });
      }
    } else if (isSelected[1]){ // 不是星期一，顯示舊的上週的折線圖
      print("不是星期一，顯示舊的上週的折線圖");
      print('上一週的星期一: $lastMonday');
      print('上一週的星期天: $lastSunday');
      int time = 0;
      //週分析
      for (int i = 0; i < 7; i++) {
        DateTime currentDate = lastMonday.add(Duration(days: i));
        dailyData = await analysisResult(currentDate); // 去後端拿資料
        time = addEmotionResults(dailyData, time);
      }
      print('有寫日記的天數(週): $time positiveSums: $positiveSums negativeSums: $negativeSums');
      if (time == 0 ){
        setState(() {
          haveDiary = false;
        });
      }else{
        setState(() {
          positiveEmotionData = [
            for (int i = 0; i <= 6; i++) FlSpot(i.toDouble(), positiveSums[i])
          ];
          negativeEmotionData = [
            for (int i = 0; i <= 6; i++) FlSpot(i.toDouble(), negativeSums[i])
          ];
          haveDiary = true;
          print('週分析正面： $positiveEmotionData');
          print('週分析負面： $negativeEmotionData');
        });
      }
    } else if (isSelected[2]){ // 不是月初，顯示舊的上個月的折線圖
      print("不是月底，顯示上個月的折線圖");
      print('上個月的第一天: $firstDayOfLastMonth');
      print('上個月的最後一天: $lastDayOfLastMonth');
      print('上個月的天數: $daysDifference');
      int time = 0;

      //月分析
      for (int i = 0; i <= daysDifference; i++) {
        DateTime currentDate = firstDayOfLastMonth.add(Duration(days: i));
        dailyData = await analysisResult(currentDate); // 去後端拿資料
        time = addEmotionResults(dailyData, time);
      }
      print('有寫日記的天數(月): $time positiveSums: $positiveSums negativeSums: $negativeSums');
      if (time == 0 ){
        setState(() {
          haveDiary = false;
        });
      }else{
        setState(() {
          positiveEmotionData = [
            for (int i = 0; i <= daysDifference; i++) FlSpot(i.toDouble(), positiveSums[i])
          ];
          negativeEmotionData = [
            for (int i = 0; i <= daysDifference; i++) FlSpot(i.toDouble(), negativeSums[i])
          ];
          haveDiary = true;
          print('月分析正面： $positiveEmotionData');
          print('月分析負面： $negativeEmotionData');
        });
      }
    }else { // 今日
    // 計算方式
      // ex:
      //   happiness = 5, like = 0            >>> 正面總數: 5
      //   sad = 20, disgust = 0, angry = 15  >>> 正面總數: 35
      //   other = 60                         >>> 中立總數: 60

      //   happiness like sad disgust angry 分別乘以 100/(5+35) 後，

      //   happiness = 12.5, like = 0, sad = 50.0, disgust = 0, angry = 37.5 >>> 總和 100
      //   other(不顯示在今日圖表)
      // 計算情緒數值
      DateTime currentDate = DateTime.now();
      todayData = await analysisResult(currentDate); // 去後端拿資料
      createDailyAnalysis(todayData);
      print('今日分析圖表完今日分析圖表完成！');
    }
  }

  // 產生日分析圓餅圖資料
  void createDailyAnalysis(Map<String, dynamic>todayData){
    List<Color> colors = [ //圖
      Color(0xFFA7BA89), Color(0xFFDCDE76), Color(0xFFD1BA7E),
      Color(0xFF7FA99B), Color(0xFF394A51),
    ];
    List<Color> textColors = [ // 數字
      Color(0xFF72805C), Color(0xFF949551), Color(0xFF8F8059),
      Color(0xFF546F66), Color(0xFF6D8E9B),
    ];
    List<String> emoType = ['happiness', 'like', 'sadness', 'disgust', 'anger'];
    int emoSum = todayData.values.take(5).fold(0, (sum, value) => sum + value as int);
    
    for (String key in emoType) {
      todayData[key] = double.parse((todayData[key] * 100 / emoSum).toStringAsFixed(1));
    }
    if (todayData['happiness']!=null){ // 如果今天有日記
      setState(() {
        pieChartSections = [];
        double positiveSum = 0.0;
        double negativeSum = 0.0;

        for (int i = 0; i < emoType.length; i++) {
          String key = emoType[i];
          double percentage = todayData[key] ?? 0.0;
          
          pieChartSections.add(PieChartSectionData(
            color: colors[i],
            value: percentage,
            title: '${percentage}%',
            radius: 50,
            titleStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColors[i],
            ),
          ));

          if (i < 2) { // positive emotions
            positiveSum += percentage;
          } else { // negative emotions
            negativeSum += percentage;
          }
        }
        // positiveEmotionData = [FlSpot(0, positiveSum)];
        // negativeEmotionData = [FlSpot(0, negativeSum)];
        haveDiary = true;
        // print('DailyPositiveEmotionData：$positiveEmotionData');
        // print('DailyNegativeEmotionData：$negativeEmotionData');
      });
    }else{
      setState(() {
        haveDiary = false;
      });
    }
  }

  // 計算並加入正面、負面情緒結果的函數
  int addEmotionResults(Map<String, dynamic> dailyData, int time) {
    double positiveSum = 0;
    double negativeSum = 0;
    double mul = 0;
    double positiveResult = 0;
    double negativeResult = 0;

    if (dailyData['happiness'] != null) {
      time++; // 增加 time 的值，表示有日記數據
      positiveSum = (dailyData['happiness']?.toDouble() ?? 0.0) +
          (dailyData['like']?.toDouble() ?? 0.0);
      negativeSum = (dailyData['sadness']?.toDouble() ?? 0.0) +
          (dailyData['disgust']?.toDouble() ?? 0.0) +
          (dailyData['anger']?.toDouble() ?? 0.0);
      mul = 100.0 / (positiveSum + negativeSum);

      positiveResult = positiveSum * mul;
      negativeResult = negativeSum * mul;

      // 取到小數點後一位
      positiveResult = double.parse(positiveResult.toStringAsFixed(1));
      negativeResult = double.parse(negativeResult.toStringAsFixed(1));
    } else {
      // 如果沒有日記數據，正負值為 0
      positiveResult = 0;
      negativeResult = 0;
    }
    // 將結果添加到數據陣列中
    positiveSums.add(positiveResult);
    negativeSums.add(negativeResult);
    return time;
  }

  void updateDateRangeAndTitle() {
    DateTime endDate = DateTime.now();
    // 當月第一天
    DateTime firstDayOfThisMonth = DateTime(endDate.year, endDate.month, 1);
    // 上個月的第一天
    DateTime firstDayOfLastMonth = DateTime(firstDayOfThisMonth.year, firstDayOfThisMonth.month - 1, 1);
    // 上個月的最後一天
    DateTime lastDayOfLastMonth = DateTime(firstDayOfLastMonth.year, firstDayOfLastMonth.month + 1, 0);
    // 獲取星期幾
    int weekDay = endDate.weekday;
    // 上週的星期一
    DateTime lastMonday = endDate.subtract(Duration(days: weekDay + 6));
    // 上週的星期天
    DateTime lastSunday = lastMonday.add(Duration(days: 6));

    if (isSelected[1]) {
      dateRangeText =
          '${DateFormat('yyyy.MM.dd').format(lastMonday)} - ${DateFormat('yyyy.MM.dd').format(lastSunday)}';
      titleText = '上一週的正負情緒趨勢';
    } else if (isSelected[2]) {
      dateRangeText =
          '${DateFormat('yyyy.MM.dd').format(firstDayOfLastMonth)} - ${DateFormat('yyyy.MM.dd').format(lastDayOfLastMonth)}';
      titleText = '上個月的正負情緒趨勢';
    } else {
      dateRangeText =
          '${DateFormat('yyyy.MM.dd').format(selectedDate ?? DateTime.now())}';
      titleText = '今日日記的情緒佔比';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F4E6),
      body: Padding(
        padding: EdgeInsets.all(16.adaptSize),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 50.v),
              Center(
                child: Container(
                  width: 318.h,
                  height: 40.v,
                  decoration: BoxDecoration(
                    color: Color(0xFFEAEAEA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(4.adaptSize),
                  child: ToggleButtons(
                    isSelected: isSelected,
                    borderRadius: BorderRadius.circular(20),
                    renderBorder: false,
                    fillColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    selectedColor: Colors.black,
                    children: [
                      Container(
                        width: 103.h,
                        height: 32.v,
                        decoration: BoxDecoration(
                          color:
                              isSelected[0] ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "今日",
                          style: TextStyle(
                            fontSize: 18.fSize,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF545453),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        width: 103.h,
                        height: 32.v,
                        decoration: BoxDecoration(
                          color:
                              isSelected[1] ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "上週",
                          style: TextStyle(
                            fontSize: 18.fSize,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF545453),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        width: 103.h,
                        height: 32.v,
                        decoration: BoxDecoration(
                          color:
                              isSelected[2] ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "上月",
                          style: TextStyle(
                            fontSize: 18.fSize,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF545453),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    onPressed: (int index) {
                      setState(() {
                        for (int i = 0; i < isSelected.length; i++) {
                          isSelected[i] = i == index;
                        }
                        updateDateRangeAndTitle();
                        fetchData();
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 30.v),
              Center(
                child: Container(
                  width: 340.h,
                  height: 600.v,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: EdgeInsets.all(30.adaptSize),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        dateRangeText,
                        style: TextStyle(
                          fontSize: 20.fSize,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF545453),
                        ),
                      ),
                      SizedBox(height: 16.v),
                      Text(
                        titleText,
                        style: TextStyle(
                          fontSize: 20.fSize,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFC5C5C5),
                        ),
                      ),
                      SizedBox(height: 40.v),
                      haveDiary
                          ? isSelected[1] || isSelected[2]
                              ? isSelected[1]
                                ?buildWeeklyAnalysis(negativeEmotionData, positiveEmotionData) // 週分析 
                                :buildMonthlyAnalysis(negativeEmotionData, positiveEmotionData) // 月分析 
                              : Column(//日分析
                                  children: [
                                    Container(//圓餅圖
                                      height: 200.v,
                                      child: PieChart(
                                        PieChartData(
                                          sections: pieChartSections,
                                          centerSpaceRadius: 40.adaptSize,
                                          sectionsSpace: 0.adaptSize,
                                          borderData: FlBorderData(show: false),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 30.v),
                                    Center(// 底下文字
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Indicator(
                                              color: Color(0xFFA7BA89),
                                              text: '開心'),
                                          SizedBox(height: 8.v),
                                          Indicator(
                                              color: Color(0xFFDCDE76),
                                              text: '喜歡'),
                                          SizedBox(height: 8.v),
                                          Indicator(
                                              color: Color(0xFFD1BA7E),
                                              text: '悲傷'),
                                          SizedBox(height: 8.v),
                                          Indicator(
                                              color: Color(0xFF7FA99B),
                                              text: '噁心'),
                                          SizedBox(height: 8.v),
                                          Indicator(
                                              color: Color(0xFF394A51),
                                              text: '憤怒'),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                          : Column(
                              children: [
                                Image.asset(
                                  'assets/images/questionMark.jpg',
                                  width: 238.h,
                                  height: 238.v,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(height: 16.v),
                                Text(
                                  "今日日記尚未完成",
                                  style: TextStyle(
                                    fontSize: 20.fSize,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFC5C5C5),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
}

// 定義顏色指示器的 Widget
class Indicator extends StatelessWidget {
  final Color color; // 指示器的顏色
  final String text; // 指示器的文字

  Indicator({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // 使指示器在行內水平居中排列
      children: [
        Container(
          width: 30.h, // 設置指示器顏色方塊的寬度
          height: 18.v, // 設置指示器顏色方塊的高度
          decoration: BoxDecoration(
            color: color, // 指示器顏色方塊的顏色
            borderRadius: BorderRadius.circular(20), // 圓角形狀
          ),
        ),
        SizedBox(width: 10.h), // 添加水平間距
        Text(
          text, // 顯示指示器的文字
          style: TextStyle(
            fontSize: 20.fSize,
            fontWeight: FontWeight.bold,
            color: color, // 將文字顏色設置為與指示器顏色塊一致
          ),
        ),
      ],
    );
  }
}

// 週分析
Widget buildWeeklyAnalysis(  List<FlSpot> negativeEmotionData,   List<FlSpot> positiveEmotionData) {
  return Column(
    children: [
      Container(
        height: 180.v,
        width: 300,
        child: LineChart(LineChartData(
          minX: -1, 
          maxX: 7, 
          minY: 0,
          maxY: 100,
          gridData: FlGridData(
            show: true,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Color(0xFF545453),
                strokeWidth: 0.5,
              );
            },
            drawVerticalLine: false,
            horizontalInterval: 10,
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: 0, 
                color: Color(0xFF545453),
                strokeWidth: 0.5,
              ),
              HorizontalLine(
                y: 100, 
                color: Color(0xFF545453),
                strokeWidth: 0.5,
              ),
            ],
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value % 20 == 0) {
                    return Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Text(
                        '${value.toInt()}%',
                        style: TextStyle(
                          fontSize: 13.fSize,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF545453),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    );
                  }
                  return Text('');
                },
                interval: 10,
              ),
            ),
            topTitles: AxisTitles(
              sideTitles:
                  SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles:
                  SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case -1:
                      return Text(''); // 左側空白
                    case 0:
                      return Text('一');
                    case 1:
                      return Text('二');
                    case 2:
                      return Text('三');
                    case 3:
                      return Text('四');
                    case 4:
                      return Text('五');
                    case 5:
                      return Text('六');
                    case 6:
                      return Text('日');
                    case 7:
                      return Text(''); // 右側空白
                    default:
                      return Text('');
                  }
                }
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: negativeEmotionData
                  .where((data) => data.y != 0.0)
                  .map((data) => FlSpot(data.x, data.y))
                  .toList(),
              isCurved: true,
              color: Color(0xFF7DA8E8),
              barWidth: 3,
              belowBarData: BarAreaData(show: false),
              dotData: FlDotData(show: false),
            ),
            LineChartBarData(
              spots: positiveEmotionData
                  .where((data) => data.y != 0.0)
                  .map((data) => FlSpot(data.x, data.y))
                  .toList(),
              isCurved: true,
              color: Color(0xFFA7BA89),
              barWidth: 3,
              belowBarData: BarAreaData(show: false),
              dotData: FlDotData(show: false),
            ),
          ],
        )),
      ),
      SizedBox(height: 45.v),
      buildEmotionLegend(),
    ],
  );
}

// 月分析
Widget buildMonthlyAnalysis(List<FlSpot> negativeEmotionData, List<FlSpot> positiveEmotionData) {
  // 獲取當前月份的每週一日期
  DateTime now = DateTime.now();
  // 當月第一天
  DateTime firstDayOfLastMonth = DateTime(now.year, now.month-1, 1);
  // 當月最後一天
  DateTime lastDayOfLastMonth = DateTime(now.year, now.month , 0);
  // 上個月有幾天(計算結果會少一天)
  int daysInLastMonth = lastDayOfLastMonth.day;
  // 找到第一個禮拜一
  DateTime firstMonday = firstDayOfLastMonth;
  while (firstMonday.weekday != DateTime.monday) {
    firstMonday = firstMonday.add(Duration(days: 1));
  }
  // 生成每週一的日期列表
  List<DateTime> mondays = [];
  for (DateTime date = firstMonday; date.isBefore(lastDayOfLastMonth.add(Duration(days: 1))); date = date.add(Duration(days: 7))) {
    mondays.add(date);
  }
  print('上個月第一個週一為s： $firstMonday');
  print('上個月的每週一為s：$mondays');
  return Column(
    children: [
      Container(
        height: 180.v,
        width: 300,
        child: LineChart(LineChartData(
          minX: 1, // 範圍開始於 0
          maxX: daysInLastMonth.toDouble() , // 範圍結束於 29
          minY: 0,
          maxY: 100,
          gridData: FlGridData(
            show: true,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Color(0xFF545453),
                strokeWidth: 0.5,
              );
            },
            drawVerticalLine: false,
            horizontalInterval: 10,
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: 0, 
                color: Color(0xFF545453),
                strokeWidth: 0.5,
              ),
              HorizontalLine(
                y: 100, 
                color: Color(0xFF545453),
                strokeWidth: 0.5,
              ),
            ],
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value % 20 == 0) {
                    return Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Text(
                        '${value.toInt()}%',
                        style: TextStyle(
                          fontSize: 13.fSize,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF545453),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    );
                  }
                  return Text('');
                },
                interval: 10,
              ),
            ),
            topTitles: AxisTitles(
              sideTitles:
                  SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles:
                  SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles( 
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  // value 是 X 軸的數值，代表某天
                  int dayOfMonth = value.toInt(); 
                  for (DateTime monday in mondays) {
                    int mondayDayOfMonth = monday.day; // 每週一的日子
                    if (dayOfMonth == mondayDayOfMonth) {
                      // 如果 X 軸的天數與某週一的日子相同，顯示日期
                      DateFormat dateFormat = DateFormat('M/d'); 
                      return Text(
                        dateFormat.format(monday), // 顯示每週一的日期
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }
                  }
                  // 如果不是每週一，不顯示任何東西
                  return Text('');
                },
                interval: 1, 
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: negativeEmotionData
                  .where((data) => data.y != 0.0)
                  .map((data) => FlSpot(data.x, data.y))
                  .toList(),
              isCurved: true,
              color: Color(0xFF7DA8E8),
              barWidth: 3,
              belowBarData: BarAreaData(show: false),
              dotData: FlDotData(show: false),
            ),
            LineChartBarData(
              spots: positiveEmotionData
                  .where((data) => data.y != 0.0)
                  .map((data) => FlSpot(data.x, data.y))
                  .toList(),
              isCurved: true,
              color: Color(0xFFA7BA89),
              barWidth: 3,
              belowBarData: BarAreaData(show: false),
              dotData: FlDotData(show: false),
            ),
          ],
        )),
      ),
      SizedBox(height: 45.v),
      buildEmotionLegend(),
    ],
  );
}

Widget buildEmotionLegend() {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Column(
        children: [
          Container(
            width: 60.h,
            height: 32.v,
            decoration: BoxDecoration(
              color: Color(0xFFA7BA89),
              borderRadius:
              BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              "正面",
              style: TextStyle(
                fontSize: 20.fSize,
                fontWeight: FontWeight.w700,
                color: Color(0xFFFFFFFF),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 8.v),
          Text(
            "開心\n喜歡",
            style: TextStyle(
              fontSize: 20.fSize,
              fontWeight: FontWeight.w700,
              color: Color(0xFFA7BA89),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      SizedBox(width: 20.h),
      Column(
        children: [
          Container(
            width: 60.h,
            height: 32.v,
            decoration: BoxDecoration(
              color: Color(0xFF7DA8E8),
              borderRadius:
              BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              "負面",
              style: TextStyle(
                fontSize: 20.fSize,
                fontWeight: FontWeight.w700,
                color: Color(0xFFFFFFFF),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 8.v),
          Text(
            "悲傷\n噁心\n憤怒",
            style: TextStyle(
              fontSize: 20.fSize,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7DA8E8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ],
  );
}

// 自定義標籤 Widget
class CustomLabel extends StatelessWidget {
  final String text;

  CustomLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92.6.h,
      height: 37.04.v,
      decoration: BoxDecoration(
        color: Color(0x99F3F3F3),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.symmetric(horizontal: 15.h, vertical: 15.v),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.fSize,
            fontWeight: FontWeight.bold,
            color: Color(0xFF545453),
          ),
        ),
      ),
    );
  }
}


/*
前端
- 折線圖
  * new! 數值是對的，但線的位置怪怪的 
  * new! 當上週或上月只有寫過一篇日記，要標示出點點。
- 無資料時要顯示對應文字
  * new! 當上週或上月都沒寫日記的話，問號下面的文字看要不要改成 "上一週無日記記錄" / "上個月無日記記錄"~

疑問：
跑月分析需要一點點時間，看有沒有需要先跑等待畫面~
*/