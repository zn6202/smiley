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
  Map<String, dynamic> testData = {}; // 日
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
    // 計算上個月有幾天
    int daysDifference = lastDayOfLastMonth.difference(firstDayOfLastMonth).inDays;
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

      // 週、月分析
      for (int i = 0; i <= days; i++) {
        DateTime currentDate = startDate.add(Duration(days: i));
        dailyData = await analysisResult(currentDate); // 去後端拿資料
        if(dailyData['happiness']!='null'){
          positiveSum = (dailyData['happiness']?.toDouble() ?? 0.0) +
              (dailyData['like']?.toDouble() ?? 0.0);
          negativeSum = (dailyData['sadness']?.toDouble() ?? 0.0) +
              (dailyData['disgust']?.toDouble() ?? 0.0) +
              (dailyData['anger']?.toDouble() ?? 0.0);
          mul = 100.0/(positiveSum + negativeSum);

          positiveResult = positiveSum * mul;
          negativeResult = negativeSum * mul;

          // 取到小數點後一位
          positiveResult = double.parse(positiveResult.toStringAsFixed(1));
          negativeResult = double.parse(negativeResult.toStringAsFixed(1));
        }else{ // 如果那一天無分析結果的話，正負值為?
          positiveResult = 50;
          negativeResult = 50;
        }
        positiveSums.add(positiveResult);
        negativeSums.add(negativeResult);
      }

      setState(() {
        positiveEmotionData = [
          for (int i = 0; i <= days; i++) FlSpot(i.toDouble(), positiveSums[i])
        ];
        negativeEmotionData = [
          for (int i = 0; i <= days; i++) FlSpot(i.toDouble(), negativeSums[i])
        ];
        haveDiary = true;
      });
    } else if (isSelected[1]){ // 不是星期一，顯示舊的上週的折線圖
      print("不是星期一，顯示舊的上週的折線圖");
      print('上一週的星期一: $lastMonday');
      print('上一週的星期天: $lastSunday');

      //週分析
      for (int i = 0; i < 7; i++) {
        DateTime currentDate = lastMonday.add(Duration(days: i));
        dailyData = await analysisResult(currentDate); // 去後端拿資料

        if (dailyData['happiness']!=null){
          positiveSum = (dailyData['happiness']?.toDouble() ?? 0.0) +
              (dailyData['like']?.toDouble() ?? 0.0);
          negativeSum = (dailyData['sadness']?.toDouble() ?? 0.0) +
              (dailyData['disgust']?.toDouble() ?? 0.0) +
              (dailyData['anger']?.toDouble() ?? 0.0);
          mul = 100.0/(positiveSum + negativeSum);

          positiveResult = positiveSum * mul;
          negativeResult = negativeSum * mul;

          // 取到小數點後一位
          positiveResult = double.parse(positiveResult.toStringAsFixed(1));
          negativeResult = double.parse(negativeResult.toStringAsFixed(1));
        }else{ // 如果那一天無分析結果的話，正負值為?
          positiveResult = 50.0;
          negativeResult = 50.0;
        }
        positiveSums.add(positiveResult);
        negativeSums.add(negativeResult);
      }
      print(positiveSums);
      print(negativeSums);

      setState(() {
        positiveEmotionData = [
          for (int i = 0; i < 7; i++) FlSpot(i.toDouble(), positiveSums[i])
        ];
        negativeEmotionData = [
          for (int i = 0; i < 7; i++) FlSpot(i.toDouble(), negativeSums[i])
        ];
        haveDiary = true;
      });
    } else if (isSelected[2]){ // 不是月初，顯示舊的上個月的折線圖
      print("不是月底，顯示上個月的折線圖");
      print('上個月的第一天: $firstDayOfLastMonth');
      print('上個月的最後一天: $lastDayOfLastMonth');
      print('上個月的天數: $daysDifference');

      //月分析
      for (int i = 0; i <= daysDifference; i++) {
        DateTime currentDate = firstDayOfLastMonth.add(Duration(days: i));
        dailyData = await analysisResult(currentDate); // 去後端拿資料

        if (dailyData['happiness']!= null){
          positiveSum = (dailyData['happiness']?.toDouble() ?? 0.0) +
              (dailyData['like']?.toDouble() ?? 0.0);
          negativeSum = (dailyData['sadness']?.toDouble() ?? 0.0) +
              (dailyData['disgust']?.toDouble() ?? 0.0) +
              (dailyData['anger']?.toDouble() ?? 0.0);
          mul = 100.0/(positiveSum + negativeSum);

          positiveResult = positiveSum * mul;
          negativeResult = negativeSum * mul;

          // 取到小數點後一位
          positiveResult = double.parse(positiveResult.toStringAsFixed(1));
          negativeResult = double.parse(negativeResult.toStringAsFixed(1));
        }else{ // 如果那一天無分析結果的話，正負值為?
          positiveResult = 50.0;
          negativeResult = 50.0;
        }
        positiveSums.add(positiveResult);
        negativeSums.add(negativeResult);
      }

      setState(() {
        positiveEmotionData = [
          for (int i = 0; i <= daysDifference; i++) FlSpot(i.toDouble(), positiveSums[i])
        ];
        negativeEmotionData = [
          for (int i = 0; i <= daysDifference; i++) FlSpot(i.toDouble(), negativeSums[i])
        ];
        haveDiary = true;
      });
    }else { // 今日
      DateTime currentDate = DateTime.now();
      testData = await analysisResult(currentDate); // 去後端拿資料

      if (testData['happiness']!=null){
        setState(() {
          pieChartSections = [
            PieChartSectionData(
              color: Color(0xFFA7BA89),
              value: testData['happiness']?.toDouble() ?? 0.0,
              title: '${testData['happiness']}%',
              radius: 50,
              titleStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF72805C),
              ),
            ),
            PieChartSectionData(
              color: Color(0xFFDCDE76),
              value: testData['like']?.toDouble() ?? 0.0,
              title: '${testData['like']}%',
              radius: 50,
              titleStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF949551),
              ),
            ),
            PieChartSectionData(
              color: Color(0xFFD1BA7E),
              value: testData['sadness']?.toDouble() ?? 0.0,
              title: '${testData['sadness']}%',
              radius: 50,
              titleStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8F8059),
              ),
            ),
            PieChartSectionData(
              color: Color(0xFF7FA99B),
              value: testData['disgust']?.toDouble() ?? 0.0,
              title: '${testData['disgust']}%',
              radius: 50,
              titleStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF546F66),
              ),
            ),
            PieChartSectionData(
              color: Color(0xFF394A51),
              value: testData['anger']?.toDouble() ?? 0.0,
              title: '${testData['anger']}%',
              radius: 50,
              titleStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6D8E9B),
              ),
            ),
          ];
          double positiveSum = (testData['happiness']?.toDouble() ?? 0.0) +
              (testData['like']?.toDouble() ?? 0.0);
          double negativeSum = (testData['sadness']?.toDouble() ?? 0.0) +
              (testData['disgust']?.toDouble() ?? 0.0) +
              (testData['anger']?.toDouble() ?? 0.0);

          positiveEmotionData = [FlSpot(0, positiveSum)];
          negativeEmotionData = [FlSpot(0, negativeSum)];

          haveDiary = true;
        });
      }else{
        setState(() {
          haveDiary = false;
        });
      }
    }
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
      backgroundColor: backgroundColor,
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
                  width: 322.h,
                  height: 600.v,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: EdgeInsets.all(40.adaptSize),
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
                              ? Column(
                                  children: [
                                    Container(
                                      height: 200.v,
                                      child: LineChart(LineChartData(
                                        minY: 0,
                                        maxY: 100,
                                        gridData: FlGridData(
                                          show: true,
                                          getDrawingHorizontalLine: (value) {
                                            return FlLine(
                                              color: Color(0xFFD3D3D3),
                                              strokeWidth: 1,
                                            );
                                          },
                                          drawVerticalLine: false,
                                          horizontalInterval: 10,
                                        ),
                                        titlesData: FlTitlesData(
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 40,
                                              getTitlesWidget: (value, meta) {
                                                switch (value.toInt()) {
                                                  case 0:
                                                    return Text(
                                                      '0%',
                                                      style: TextStyle(
                                                        fontSize: 15.fSize,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xFF545453),
                                                      ),
                                                      textAlign:
                                                          TextAlign.right,
                                                    );
                                                  case 20:
                                                    return Text(
                                                      '20%',
                                                      style: TextStyle(
                                                        fontSize: 15.fSize,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xFF545453),
                                                      ),
                                                      textAlign:
                                                          TextAlign.right,
                                                    );
                                                  case 40:
                                                    return Text(
                                                      '40%',
                                                      style: TextStyle(
                                                        fontSize: 15.fSize,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xFF545453),
                                                      ),
                                                      textAlign:
                                                          TextAlign.right,
                                                    );
                                                  case 60:
                                                    return Text(
                                                      '60%',
                                                      style: TextStyle(
                                                        fontSize: 15.fSize,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xFF545453),
                                                      ),
                                                      textAlign:
                                                          TextAlign.right,
                                                    );
                                                  case 80:
                                                    return Text(
                                                      '80%',
                                                      style: TextStyle(
                                                        fontSize: 15.fSize,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xFF545453),
                                                      ),
                                                      textAlign:
                                                          TextAlign.right,
                                                    );
                                                  case 100:
                                                    return Text(
                                                      '100%',
                                                      style: TextStyle(
                                                        fontSize: 15.fSize,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xFF545453),
                                                      ),
                                                      textAlign:
                                                          TextAlign.right,
                                                    );
                                                  default:
                                                    return Text('');
                                                }
                                              },
                                              interval: 20,
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
                                              showTitles: false, //橫軸標籤未改好 先關閉
                                              getTitlesWidget: (value, meta) {
                                                switch (value.toInt()) {
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
                                                  default:
                                                    return Text('');
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        borderData: FlBorderData(show: false),
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: positiveEmotionData,
                                            isCurved: true,
                                            color: Color(0xFF7DA8E8),
                                            barWidth: 4,
                                            belowBarData:
                                                BarAreaData(show: false),
                                            dotData: FlDotData(show: false),
                                          ),
                                          LineChartBarData(
                                            spots: negativeEmotionData,
                                            isCurved: true,
                                            color: Color(0xFFA7BA89),
                                            barWidth: 4,
                                            belowBarData:
                                                BarAreaData(show: false),
                                            dotData: FlDotData(show: false),
                                          ),
                                        ],
                                      )),
                                    ),
                                    SizedBox(height: 60.v),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Container(
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
                                    Center(
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
  * 沒有0/100的灰線
  * 縱軸距離圖表太近
  * 橫軸標籤未改好 -> new! 要不要變成圖的畫面可以左右滑動(x 軸寫 1~當月最後一天)
  * 以月 橫軸顯示區間 資料標籤標日期
  * new! 數值是對的，但線的位置怪怪的
  * new! 月跟週的 title 日期範圍怪怪的，剛好變數有用到，就順便改好了~ 麻煩確認一下ㄌ
- 無資料時要顯示對應文字

疑問
1. other 要顯示在今日分析圓餅圖嗎？ (目前是除了 other 以外的情緒，乘上 100，再除以 other )
  ex:
    happiness = 5, like = 0            >>> 正面總數: 5
    sad = 20, disgust = 0, angry = 15  >>> 正面總數: 35
    other = 60                         >>> 中立總數: 60

    happiness like sad disgust angry 分別乘以 100/(5+35) 後，

    happiness = 12.5, like = 0, sad = 50.0, disgust = 0, angry = 37.5 >>> 總和 100
    other(不顯示在今日圖表)

2. 當那一天沒有寫日記，正負情緒數值為 ?? (162 203 247 行，先暫時寫各 50.0)
3. 月分析跑比較久，有沒有需要"等待畫面"?
*/