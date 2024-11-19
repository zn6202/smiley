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
  String? todayOil;
  String? clientImage; //客戶頭貼
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
  Map<String, String> generateFeedbackTexts() {
    getTodayOil();
    return {
      "開心":
          "\n今天適合你的精油是「$todayOil」\n\n< 緩解焦慮、舒緩壓力、恢復精力 >\n在壓力導致失眠的情況下，其強大的鎮靜效果著稱，且有助於平衡神經系統，可以幫助人們在壓力下放鬆心情，減少壓力感，使人在疲憊時感覺更有精神和舒適。\n\n< 推薦使用方式 - 擴香 >\n用途：放鬆身心、減壓、助眠\n方法：使用擴香器或加濕器，加入3-5滴精油到水中，讓精油的香氣隨著蒸汽散發到空氣中。",
      "喜歡":
          "\n今天適合你的精油是「$todayOil」\n\n<甜美、浪漫、幸福>\n具有極強的情感療癒效果，幫助增強愛與被愛的感覺。它的香氣能激發內心的甜美與浪漫，讓使用者感受到幸福與愛的美好，尤其適合在喜愛的情緒中使用。\n\n< 推薦使用方式 - 香氛噴霧 >\n用途：增強愛的情感、提升幸福感、營造浪漫氛圍\n方法：將3-5滴精油加入50ml蒸餾水，裝入噴霧瓶中，隨時噴灑於房間或衣物上，讓香氣隨著空氣蔓延，提升愉悅感。",
      "悲傷":
          "\n今天適合你的精油是「$todayOil」\n\n< 緩解悲傷、舒緩情緒 >\n其清新的木質香氣能幫助舒緩情緒，減輕內心的悲傷感。它具有強大的情緒調節作用，能為心靈提供安慰，讓使用者感覺更有力量來面對困難的情緒。\n\n< 推薦使用方式 - 香氛按摩 >\n用途：釋放悲傷、安撫心靈、增強內心力量\n方法：將2-3滴精油混合15ml基底油（如甜杏仁油），輕柔地按摩肩頸和手腕，讓香氣緩慢地散發，安撫緊繃的情緒，幫助釋放悲傷。",
      "噁心":
          "\n今天適合你的精油是「$todayOil」\n\n<淨化心靈、提振精神>\n其清新的氣息著稱，能有效驅散令人不愉快的感覺，讓人感到煥然一新。同時具有淨化心靈與空間的作用，幫助轉換負面情緒。\n\n<推薦使用方式 - 空氣淨化>\n用途：驅除負能量、提振心情、淨化空間\n方法：將3-5滴精油加入擴香器中，或滴在棉球上放置於房間四角，營造乾淨、清新的氛圍，驅走不愉快的感覺。",
      "憤怒":
          "\n今天適合你的精油是「$todayOil」\n\n<平復情緒波動、冷靜>\n辛香氣息具有強烈的放鬆效果，能有效減少情緒波動，平復因憤怒所帶來的心理壓力。它對於釋放情緒及促進冷靜與理智的回歸有顯著的效果。\n\n<推薦使用方式 - 熱敷>\n用途：平復怒氣、釋放壓力、促進情緒冷靜\n方法：將5滴精油滴入溫水中，浸濕毛巾後輕擰乾，敷在額頭或脖後，靜靜地深呼吸，幫助冷靜情緒並釋放怒氣。",
      "心無波瀾":
          "\n今天適合你的精油是「$todayOil」\n\n<放鬆、身心平衡>\n其以平衡與穩定的特性著稱，適合用於日常放鬆或不明確的情緒狀態，幫助人們重拾心靈的平靜與專注。\n\n< 推薦使用方式 - 擴香 >\n用途：放鬆身心、減壓、助眠\n方法：使用擴香器或加濕器，加入3-5滴精油到水中，讓精油的香氣隨著蒸汽散發到空氣中。",
    };
  }

  @override
  void initState() {
    super.initState();
    getClientImage();
    fetchClientData();
    print('進入客戶資料頁面');
  }

  Future<void> getTodayOil() async {
    String? userId = await getClientID(); //換成從上一個頁面傳過來的客戶id

    print("抓取今日精油 user_id = $userId");

    final response =
        await http.post(Uri.parse(API.getTodayOil), body: {'user_id': userId});

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      print("今日推薦精油 = ${responseData["data"]}");

      if (responseData['success'] == true) {
        setState(() {
          todayOil = responseData['oil_name'];
        });
        // fetchDataAndGenerateRandomNumbers();
      } else {
        print('瀏覽失敗... ${responseData['message']}');
      }
    } else {
      print('瀏覽失敗...');
    }
    await Future.delayed(Duration(seconds: 1));
    // return 5;
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

  Future<void> getClientImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      clientImage = prefs.getString('client_image');
    });
    print('客戶頭貼為 $clientImage ');
  }

  Future<void> cleanMessageSum(String? clientID) async {
    print("進入聊天室，更新訊息未讀數量, clientID = $clientID");

    final response = await http.post(
      Uri.parse(
        API.cleanMessageSum), 
        body: {
          'user_id': clientID,
        }
      );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      print("更新訊息未讀數量成功 = ${responseData["data"]}");
      // if (responseData['success'] == true) {
      //   setState(() {

      //   });
      // } else {
      //   print('瀏覽失敗... ${responseData['message']}');
      // }
    } else {
      print('瀏覽失敗...');
    }
    await Future.delayed(Duration(seconds: 1));
  }

  Widget AppBarImage() {
    if (clientImage == null) {
      return CircularProgressIndicator(); // 載入中的指示器
    } else if (clientImage!.isEmpty) {
      return Text("無法加載圖片");
    } else {
      return Image.asset(
        clientImage!,
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
                              Center(
                                child: Text(
                                  generateFeedbackTexts()[highestEmotionName] ??
                                      "無對應的回饋文",
                                  textAlign: TextAlign.center, // 多行文字也會置中對齊
                                  style: TextStyle(
                                    fontSize: 14.0.v,
                                    color: Color(0xFF4A4A4A),
                                  ),
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
                // await saveClientID(clientId!);
                cleanMessageSum(clientId);

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

// Future<void> saveClientID(String clientId) async {
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.setString(
//       'receiver_id', clientId); // Save client_id as receiver_id
//   print('Saved receiver_id: $clientId');
// }

// 要記得先去用戶帳號寫日記 目前沒有處理沒日記的話日分析的顯示
// 24 60要改用讀取的
// 經由的文字也要改41
