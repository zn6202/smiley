import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../widgets/bottom_navigation.dart';

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

  @override
  void initState() {
    super.initState();
    fetchData();
    updateDateRangeAndTitle();
  }
  
  Future<void> fetchData() async {
    if (isSelected[1] || isSelected[2]) {
      int days = isSelected[1] ? 6 : 27;
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(Duration(days: days));

      List<double> positiveSums = [];
      List<double> negativeSums = [];
      //周/月分析從這裡改! map要改成從資料庫取得的值
      for (int i = 0; i <= days; i++) {
        Map<String, dynamic> dailyData = { //這是我亂生的測試值 要刪
          'happiness': 40 - i * 5,
          'like': 25 + i * 2,
          'sadness': 15 + i * 3,
          'disgust': 10 - i,
          'anger': 10 + i * 1.5,
        };

        double positiveSum = (dailyData['happiness']?.toDouble() ?? 0.0) + (dailyData['like']?.toDouble() ?? 0.0);
        double negativeSum = (dailyData['sadness']?.toDouble() ?? 0.0) + (dailyData['disgust']?.toDouble() ?? 0.0) + (dailyData['anger']?.toDouble() ?? 0.0);

        positiveSums.add(positiveSum);
        negativeSums.add(negativeSum);
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
    } else {//本日分析從這裡改! map要改成從資料庫取得的值
      Map<String, dynamic> testData = {  //這是我亂生的測試值 要刪
        'happiness': 40,
        'like': 25,
        'sadness': 15,
        'disgust': 10,
        'anger': 10,
      };

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
              shadows: [
                Shadow(
                  offset: Offset(0.1, 0.1), // Figma中的X和Y偏移量
                  blurRadius: 2.0, // Figma中的模糊半徑
                  color: Color.fromRGBO(0, 0, 0, 0.5), // Figma中的顏色和透明度 (黑色，50%透明度)
                ),
              ],
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
              shadows: [
                Shadow(
                  offset: Offset(0.1, 0.1), // Figma中的X和Y偏移量
                  blurRadius: 2.0, // Figma中的模糊半徑
                  color: Color.fromRGBO(0, 0, 0, 0.5), // Figma中的顏色和透明度 (黑色，50%透明度)
                ),
              ],
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
              shadows: [
                Shadow(
                  offset: Offset(0.1, 0.1),
                  blurRadius: 2.0, 
                  color: Color.fromRGBO(0, 0, 0, 0.5), 
                ),
              ],
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
              shadows: [
                Shadow(
                  offset: Offset(0.1, 0.1), 
                  blurRadius: 2.0, 
                  color: Color.fromRGBO(0, 0, 0, 0.5), 
                ),
              ],
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
              shadows: [
                Shadow(
                  offset: Offset(0.1, 0.1), 
                  blurRadius: 2.0, 
                  color: Color.fromRGBO(0, 0, 0, 0.5), 
                ),
              ],
            ),
          ),
        ];
        double positiveSum = (testData['happiness']?.toDouble() ?? 0.0) + (testData['like']?.toDouble() ?? 0.0);
        double negativeSum = (testData['sadness']?.toDouble() ?? 0.0) + (testData['disgust']?.toDouble() ?? 0.0) + (testData['anger']?.toDouble() ?? 0.0);

        positiveEmotionData = [FlSpot(0, positiveSum)];
        negativeEmotionData = [FlSpot(0, negativeSum)];

        haveDiary = true;
      });
    }
  }

  void updateDateRangeAndTitle() {
    if (isSelected[1]) {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(Duration(days: 6));
      dateRangeText = '${DateFormat('yyyy.MM.dd').format(startDate)} - ${DateFormat('yyyy.MM.dd').format(endDate)}';
      titleText = '上一週的正負情緒趨勢';
    } else if (isSelected[2]) {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(Duration(days: 27));
      dateRangeText = '${DateFormat('yyyy.MM.dd').format(startDate)} - ${DateFormat('yyyy.MM.dd').format(endDate)}';
      titleText = '上個月的正負情緒趨勢';
    } else {
      dateRangeText = '${DateFormat('yyyy.MM.dd').format(selectedDate ?? DateTime.now())}';
      titleText = '今日日記的情緒佔比';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 32),
              Center(
                child: Container(
                  width: 324,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFFEAEAEA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(4),
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
                        width: 105,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected[0] ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "今日",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF545453),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        width: 105,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected[1] ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "上週",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF545453),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        width: 105,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected[2] ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "上月",
                          style: TextStyle(
                            fontSize: 18,
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
              SizedBox(height: 32),
              Center(
                child: Container(
                  width: 330,
                  height: 587,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        dateRangeText,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF545453),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        titleText,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFC5C5C5),
                        ),
                      ),
                      SizedBox(height: 32),
                      haveDiary 
                        ? isSelected[1] || isSelected[2]
                          ? Column(
                              children: [
                                Container(
                                  height: 200,
                                  child: LineChart(
                                    LineChartData(
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
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF545453),
                                                    ),
                                                    textAlign: TextAlign.right,
                                                  );
                                                case 20:
                                                  return Text(
                                                    '20%',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF545453),
                                                    ),
                                                    textAlign: TextAlign.right,
                                                  );
                                                case 40:
                                                  return Text(
                                                    '40%',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF545453),
                                                    ),
                                                    textAlign: TextAlign.right,
                                                  );
                                                case 60:
                                                  return Text(
                                                    '60%',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF545453),
                                                    ),
                                                    textAlign: TextAlign.right,
                                                  );
                                                case 80:
                                                  return Text(
                                                    '80%',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF545453),
                                                    ),
                                                    textAlign: TextAlign.right,
                                                  );
                                                case 100:
                                                  return Text(
                                                    '100%',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF545453),
                                                    ),
                                                    textAlign: TextAlign.right,
                                                  );
                                                default:
                                                  return Text('');
                                              }
                                            },
                                            interval: 20,
                                          ),
                                        ),
                                        topTitles: AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
                                        ),
                                        rightTitles: AxisTitles(
                                          sideTitles: SideTitles(showTitles: false),
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
                                          belowBarData: BarAreaData(show: false),
                                          dotData: FlDotData(show: false),
                                        ),
                                        LineChartBarData(
                                          spots: negativeEmotionData,
                                          isCurved: true,
                                          color: Color(0xFFA7BA89),
                                          barWidth: 4,
                                          belowBarData: BarAreaData(show: false),
                                          dotData: FlDotData(show: false),
                                        ),
                                      ],
                                    )
                                  ),
                                ),
                                SizedBox(height: 45),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: Color(0xFFA7BA89),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            "正面",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFFFFFFFF),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "開心\n喜歡",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFFA7BA89),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 16),
                                    Column(
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: Color(0xFF7DA8E8),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            "負面",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFFFFFFFF),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "悲傷\n噁心\n憤怒",
                                          style: TextStyle(
                                            fontSize: 20,
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
                                  height: 200,
                                  child: PieChart(
                                    PieChartData(
                                      sections: pieChartSections,
                                      centerSpaceRadius: 40,
                                      sectionsSpace: 0,
                                      borderData: FlBorderData(show: false),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Indicator(color: Color(0xFFA7BA89), text: '開心'),
                                      SizedBox(height: 8),
                                      Indicator(color: Color(0xFFDCDE76), text: '喜歡'),
                                      SizedBox(height: 8),
                                      Indicator(color: Color(0xFFD1BA7E), text: '悲傷'),
                                      SizedBox(height: 8),
                                      Indicator(color: Color(0xFF7FA99B), text: '噁心'),
                                      SizedBox(height: 8),
                                      Indicator(color: Color(0xFF394A51), text: '憤怒'),
                                    ],
                                  ),
                                ),
                              ],
                            )
                        : Column(
                            children: [
                              Image.asset(
                                'assets/images/questionMark.jpg',
                                width: 238,
                                height: 238,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(height: 16),
                              Text(
                                "今日日記尚未完成",
                                style: TextStyle(
                                  fontSize: 20,
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
          width: 30, // 設置指示器顏色方塊的寬度
          height: 18, // 設置指示器顏色方塊的高度
          decoration: BoxDecoration(
            color: color, // 指示器顏色方塊的顏色
            borderRadius: BorderRadius.circular(20), // 圓角形狀
          ),
        ),
        SizedBox(width: 8), // 添加水平間距
        Text(
          text, // 顯示指示器的文字
          style: TextStyle(
            fontSize: 16,
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
      width: 92.6,
      height: 37.04,
      decoration: BoxDecoration(
        color: Color(0x99F3F3F3),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
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
2. 折線圖
- 沒有0/100的灰線
- 縱軸距離圖表太近
- 橫軸標籤未改好 (問大家要28天還是30天)
- 
後端
1. 未連接資料庫
*/