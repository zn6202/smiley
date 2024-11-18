import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smiley/presentation/seller_screen/schat_screen.dart';
import 'package:smiley/presentation/home_screen/home_screen.dart'; // 確認這個路徑正確
import '../../core/app_export.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../widgets/bottom_navigation.dart';
import 'package:http/http.dart' as http;
import '../../routes/api_connection.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class DataScreen extends StatefulWidget {
  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  bool isVisible = false;
  bool isLoading = true;
  String? number;
  String? clientId; //客戶id
  String highestEmotionName = '';
  double highestEmotionValue = 0.0;
  // String? clientId ;
  Map<String, dynamic>? weeklyData;
  Map<String, dynamic>? dailyData;
  var highestEmotion;
  Map<String, String> emotionTranslations = {
    "anger": "憤怒",
    "disgust": "噁心",
    "happiness": "開心",
    "like": "喜歡",
    "other": "心無波瀾",
    "sadness": "悲傷"
  };

  // 回饋文
  Map<String, String> feedbackTexts = {
    "開心":
        "今天適合你的精油是「橙花」。橙花帶來幸福與歡樂的感覺，幫助你保持心情愉悅555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555。",
    "喜歡": "今天適合你的精油是「檸檬草」。檸檬草可以提神醒腦，增強你對事物的熱情。",
    "悲傷":
        "今天適合你的精油是「薰衣草」。薰衣草有助於舒緩悲傷情緒，帶來寧靜與安定感555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555。",
    "噁心": "今天適合你的精油是「生薑」。生薑有助於舒緩胃部不適，並減輕噁心感。",
    "憤怒": "今天適合你的精油是「薄荷」。薄荷能夠幫助你冷靜下來，釋放憤怒情緒。",
    "心無波瀾": "心無波瀾",
  };

  @override
  void initState() {
    super.initState();
    getNumber();
    fetchClientData();
    print('進入客戶資料頁面');
  }

  Future<String?> getClientID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('receiver_id');
  }

  Future<void> fetchClientData() async {
    clientId = await getClientID(); //換成從上一個頁面傳過來的客戶id
    print("用戶id 為：$clientId");
    const apiUrl = "http://163.22.32.24/clientData";
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"uid": clientId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          weeklyData = data["weeklyData"]; // 週情緒百分比
          dailyData = data["dailyData"]; // 日情緒百分比
          highestEmotion = data["highestEmotion"]; // 最高情緒

          convertWeeklyDataToFlSpot();
          convertDailyDataToEmotions();
          if (highestEmotion != null && highestEmotion!.length == 2) {
            highestEmotionName =
                emotionTranslations[highestEmotion![0].toString()] ?? "未知情緒";
            highestEmotionValue =
                double.tryParse(highestEmotion![1].toString()) ?? 0.0;
          }
          isLoading = false;
        });
        print("情緒百分比取得成功：$data");
      } else {
        print("錯誤：${response.statusCode}");
        isLoading = false;
      }
    } catch (e) {
      print('取得資料失敗');
      print("發生錯誤：$e");
      isLoading = false;
    }
  }

  Map<String, int> emotions = {};
  void convertDailyDataToEmotions() {
    if (dailyData != null) {
      emotions = {
        "開心": (dailyData!["happiness"] as num)
            .toDouble()
            .round(), // 使用 `num` 類型，然後轉換為 `double`
        "喜歡": (dailyData!["like"] as num).toDouble().round(),
        "悲傷": (dailyData!["sadness"] as num).toDouble().round(),
        "噁心": (dailyData!["disgust"] as num).toDouble().round(),
        "憤怒": (dailyData!["anger"] as num).toDouble().round(),
      };
      print("Converted Emotions: $emotions");
    }
  }

  List<FlSpot> positiveEmotionData = [];
  List<FlSpot> negativeEmotionData = [];

  void convertWeeklyDataToFlSpot() {
    if (weeklyData != null) {
      // Extract positive and negative sums
      List<dynamic> positiveSums = weeklyData!["positive_sums"] ?? [];
      List<dynamic> negativeSums = weeklyData!["negative_sums"] ?? [];

      // Convert positive sums to FlSpot, ensuring values are doubles
      positiveEmotionData = [];
      for (int index = 0; index < positiveSums.length; index++) {
        double value = (positiveSums[index] as num)
            .toDouble(); // 使用 `num` 類型，然後轉換為 `double`
        if (value != 1000.0) {
          positiveEmotionData.add(FlSpot(index.toDouble(), value));
        }
      }

      // Convert negative sums to FlSpot, ensuring values are doubles
      negativeEmotionData = [];
      for (int index = 0; index < negativeSums.length; index++) {
        double value = (negativeSums[index] as num)
            .toDouble(); // 使用 `num` 類型，然後轉換為 `double`
        if (value != 1000.0) {
          negativeEmotionData.add(FlSpot(index.toDouble(), value));
        }
      }

      print("Positive Emotion Data: $positiveEmotionData");
      print("Negative Emotion Data: $negativeEmotionData");
    }
  }

  Future<void> getNumber() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      number = prefs.getString('number');
    });
    print('客戶頭貼為 $number ');
  }

  Widget AppBarImage() {
    if (number == null) {
      return CircularProgressIndicator(); // 載入中的指示器
    } else if (number!.isEmpty) {
      return Text("無法加載圖片");
    } else {
      return Image.asset(
        'assets/images/default_avatar_$number.png',
        height: 55.0.v, // 根據需要調整高度
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F4E6),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65.0.v),
        child: AppBar(
          elevation: 0, // 移除陰影
          backgroundColor: Color(0xFFF4F4E6),
          leading: IconButton(
            icon: Image.asset('assets/images/arrow-left-g.png',
                color: Color.fromARGB(225, 167, 186, 137)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: AppBarImage(),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: Color(0xFFF4F4E6),
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: AnimatedTextKit(
                animatedTexts: [
                  WavyAnimatedText(
                    "資料處理中",
                    textStyle: TextStyle(
                      fontSize: 20.0.v,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(225, 167, 186, 137),
                    ),
                  ),
                ],
                repeatForever: true, // Makes the animation repeat
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.v),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 上半部
                    Container(
                      width: 344.v,
                      height: 429.v,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.v),
                      ),
                      padding: EdgeInsets.all(16.v),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$highestEmotionName",
                            style: TextStyle(
                              fontSize: 30.v,
                              fontWeight: FontWeight.w700,
                              color: Color.fromARGB(255, 137, 138, 141),
                            ),
                          ),
                          SizedBox(height: 10.v),
                          Text(
                            "本日情緒占比：",
                            style: TextStyle(
                              fontSize: 20.v,
                              fontWeight: FontWeight.w700,
                              color: Color.fromARGB(255, 84, 84, 83),
                            ),
                          ),
                          SizedBox(height: 15.v),
                          // Horizontal Bar Chart
                          Row(
                            children: List.generate(10, (index) {
                              // int totalPercentage = emotions.values.reduce((a, b) => a + b);
                              double accumulatedPercentage = 0;
                              Color barColor = Colors.grey;

                              for (var entry in emotions.entries) {
                                accumulatedPercentage += entry.value;
                                if (index * 10 < accumulatedPercentage) {
                                  barColor = _getEmotionColor(entry.key);
                                  break;
                                }
                              }
                              return Container(
                                width: 24.0.v,
                                height: 24.0.v,
                                margin: EdgeInsets.only(right: 4.0.v),
                                decoration: BoxDecoration(
                                  color: barColor,
                                  borderRadius: BorderRadius.circular(4.0.v),
                                ),
                              );
                            }),
                          ),
                          SizedBox(height: 20.0.v),
                          Text(
                            "上週情緒趨勢：",
                            style: TextStyle(
                              fontSize: 20.v,
                              fontWeight: FontWeight.w700,
                              color: Color.fromARGB(255, 84, 84, 83),
                            ),
                          ),
                          SizedBox(height: 50.0.v),
                          // 週分析圖表
                          Container(
                            height: 160.0.v,
                            child: weeklyChart(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.0.v),
                    // 回饋文
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0.v),
                      ),
                      padding: EdgeInsets.all(16.0.v),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                child: Text(
                                  '回饋文',
                                  style: TextStyle(
                                    fontSize: 25.v,
                                    fontWeight: FontWeight.w700,
                                    color: Color.fromARGB(255, 84, 84, 83),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.v),
                              // 分割線
                              Container(
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 1.h,
                                      color: Color(0xFFDADADA),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.0.v),
                              Text(
                                feedbackTexts[highestEmotionName] ?? "無對應的回饋文",
                                style: TextStyle(
                                  fontSize: 14.0.v,
                                  color: Color(0xFF4A4A4A),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      // 懸浮按鈕
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 80.0.v,
            right: 10.0.v,
            child: FloatingActionButton(
              heroTag: 'fab1',
              onPressed: () async {
                // Save client_id as receiver_id
                clientId = await getClientID();
                await saveClientID(clientId!);

                // Navigate to SchatScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SchatScreen(),
                  ),
                );
              },
              backgroundColor: Color.fromRGBO(167, 186, 137, 0.8),
              child: Image.asset('assets/store/chat.png', height: 24.v),
            ),
          ),
          Positioned(
            bottom: 16.0.v,
            right: 10.0.v,
            child: FloatingActionButton(
              heroTag: 'fab2',
              onPressed: () => setState(() => isVisible = !isVisible),
              child: Image.asset('assets/store/functionList.png', height: 24.v),
              backgroundColor: Color.fromRGBO(167, 186, 137, 0.8),
            ),
          ),
          if (isVisible)
            Positioned(
              bottom: 80.0.v,
              right: 60.0.v,
              child: Container(
                height: 225.0.v,
                width: 106.0.v,
                padding: EdgeInsets.all(10.0.v),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0.v),
                  border: Border.all(color: Color(0xFFA7BA89), width: 3.0.v),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6.v,
                        offset: Offset(0.v, 3.v)),
                  ],
                ),
                child: Column(
                  children: [
                    colorList(Color(0xFFA7BA89), '開心'),
                    colorList(Color(0xFFDCDE76), '喜歡'),
                    colorList(Color(0xFFD1BA7E), '悲傷'),
                    colorList(Color(0xFF7FA99B), '噁心'),
                    colorList(Color(0xFF394A51), '憤怒'),
                    colorList(Color(0xFFA7BA89), '正面'),
                    colorList(Color(0xFF7DA8E8), '負面'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

//情緒顏色
  Color _getEmotionColor(String emotion) {
    switch (emotion) {
      case "開心":
        return Color(0xFFA7BA89);
      case "喜歡":
        return Color(0xFFDCDE76);
      case "悲傷":
        return Color(0xFFD1BA7E);
      case "噁心":
        return Color(0xFF7FA99B);
      case "憤怒":
        return Color(0xFF394A51);
      default:
        return Colors.grey;
    }
  }

// 懸浮按鈕圖示
  Widget colorList(Color color, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.v),
      child: Row(
        children: [
          SizedBox(width: 5.v),
          Container(
            width: 30.v,
            height: (text == '正面' || text == '負面') ? 5.v : 18.v,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.v),
              color: color,
            ),
          ),
          SizedBox(width: 12.v),
          Text(
            text,
            style: TextStyle(
                fontSize: 14.2.v, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

// 週分析折線圖
  Widget weeklyChart() {
    return Container(
      height: 200.v,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 100,
          gridData: FlGridData(
            show: true,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Color(0xFFD3D3D3),
                strokeWidth: 1.0.v,
              );
            },
            drawVerticalLine: false,
            horizontalInterval: 10,
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40.v,
                interval: 20,
                getTitlesWidget: (value, meta) {
                  final TextStyle labelTextStyle = TextStyle(
                    fontSize: 13.5.v,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF545453),
                  );

                  switch (value.toInt()) {
                    case 0:
                      return Text('0%',
                          style: labelTextStyle, textAlign: TextAlign.right);
                    case 20:
                      return Text('20%',
                          style: labelTextStyle, textAlign: TextAlign.right);
                    case 40:
                      return Text('40%',
                          style: labelTextStyle, textAlign: TextAlign.right);
                    case 60:
                      return Text('60%',
                          style: labelTextStyle, textAlign: TextAlign.right);
                    case 80:
                      return Text('80%',
                          style: labelTextStyle, textAlign: TextAlign.right);
                    case 100:
                      return Text('100%',
                          style: labelTextStyle, textAlign: TextAlign.right);
                    default:
                      return Text('');
                  }
                },
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
                showTitles: false,
                reservedSize: 22,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  // Customize horizontal labels
                  final labels = ['一', '二', '三', '四', '五', '六', '日'];
                  if (value.toInt() >= 0 && value.toInt() < labels.length) {
                    return Text(
                      labels[value.toInt()],
                      style: TextStyle(
                        fontSize: 12.v,
                        color: Color(0xFF545453),
                      ),
                    );
                  }
                  return Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: positiveEmotionData,
              isCurved: false,
              color: Color(0xFF7DA8E8),
              barWidth: 4,
              belowBarData: BarAreaData(show: false),
              dotData: FlDotData(show: false),
            ),
            LineChartBarData(
              spots: negativeEmotionData,
              isCurved: false,
              color: Color(0xFFA7BA89),
              barWidth: 4,
              belowBarData: BarAreaData(show: false),
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> saveClientID(String clientId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
      'receiver_id', clientId); // Save client_id as receiver_id
  print('Saved receiver_id: $clientId');
}

// 要記得先去用戶帳號寫日記 目前沒有處理沒日記的話日分析的顯示
// 24 60要改用讀取的
// 經由的文字也要改41
