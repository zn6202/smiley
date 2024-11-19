import 'dart:convert'; // jsonDecode
import 'package:flutter/material.dart';
// import 'package:smiley/core/network/flutter/packages/flutter/test/rendering/table_test.dart';
import 'dart:math';
import '../../core/app_export.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../core/app_export.dart';
import 'package:http/http.dart' as http;
import '../../../routes/api_connection.dart';

class ShomeScreen extends StatefulWidget {
  ShomeScreen({Key? key}) : super(key: key);

  @override
  _ShomeScreenState createState() => _ShomeScreenState();
}

class _ShomeScreenState extends State<ShomeScreen> {
  // List<int> randomNumbers = [];
  int dataCount = 0; // 資料數量，初始化為 0
  List<Map<String, dynamic>> messageList = [];

  @override
  void initState() {
    print('進入商家首頁');
    super.initState();
    getMessageSumFromDatabase();
    // fetchDataAndGenerateRandomNumbers();
  }

  // 幾個用戶要顯示就抓幾個隨機數選頭貼
  // void fetchDataAndGenerateRandomNumbers() async {
  //   randomNumbers =
  //       List.generate(dataCount, (index) => Random().nextInt(9) + 1);
  //   setState(() {});
  // }

  // 從資料庫讀有訊息來往紀錄的用戶數量
  Future<void> getMessageSumFromDatabase() async {
    print("進入賣家主頁，抓取訊息欄");

    final response = await http.post(Uri.parse(API.getShomeMessageSum));

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      print("發送訊息者, 未讀數 = ${responseData["data"]}");

      if (responseData['success'] == true) {
        List<dynamic> messages = responseData['data']; // 取出 "data" 陣列
        // {
        //   "success": true,
        //   "data": [
        //     {"sender_id": "23", "unread_count": "4"},
        //     {"sender_id": "24", "unread_count": "1"}
        //   ]
        // }
        setState(() {
          dataCount = messages.length; // 更新未讀訊息的用戶數量
          messageList = messages
              .map((item) => {
                    "random_numbers":
                        'assets/images/default_avatar_${item['random_numbers']}.png',
                    "sender_id": item['sender_id'],
                    "unread_count": item['unread_count']
                  })
              .toList();
        });
        // fetchDataAndGenerateRandomNumbers();
        print('發送訊息者有幾位 = $dataCount, 清單 =  $messageList');
      } else {
        print('瀏覽失敗... ${responseData['message']}');
      }
    } else {
      print('瀏覽失敗...');
    }
    await Future.delayed(Duration(seconds: 1));
    // return 5;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F4E6), // 背景顏色
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Image.asset('assets/store/home.png',
            color: Color.fromARGB(225, 167, 186, 137),
            height: 30.v,
            width: 30.v),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.v),
        child: messageList.isEmpty
            ? Center(
                child: Text(
                  "今日沒有訊息",
                  style: TextStyle(
                    fontSize: 18.0.v,
                    fontWeight: FontWeight.bold, // 設置粗體
                    color: Colors.grey,
                  ),
                ),
              )
            : GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 18.0.v,
                mainAxisSpacing: 18.0.v,
                childAspectRatio: 2,
                children: messageList.map((message) {
                  return buildGridItem(
                    message['random_numbers'], // 使用從訊息清單中取得的頭貼
                    message['sender_id'], // 使用發送者的 ID
                    message['unread_count'].toString(), // 顯示未讀數量
                  );
                }).toList(),
              ),
      ),

      // body: Padding(
      //   padding: EdgeInsets.all(16.0.v),
      //   child: GridView.count(
      //     crossAxisCount: 2,
      //     crossAxisSpacing: 18.0.v,
      //     mainAxisSpacing: 18.0.v,
      //     childAspectRatio: 2,
      //     children: messageList.map((message) {
      //       return buildGridItem(
      //           message['random_numbers'], // 使用從訊息清單中取得的頭貼
      //           message['sender_id'], // 使用發送者的 ID
      //           message['unread_count'].toString() // 顯示未讀數量
      //           );
      //     }).toList(),
      //   ),
      // ),
    );
  }

  // Future<String?> getUserId() async {
  //   // 使用者的 id
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString('user_id');
  // }

  Future<void> saveClientID(String clientId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('receiver_id', clientId);
    print('Saved receiver_id: $clientId');
  }

  // 儲存選到第幾個預設頭貼
  Future<void> saveClientImage(String path) async {
    String? clientImage = path.toString();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('client_image', clientImage);
  }

  // 用戶選項方塊
  Widget buildGridItem(String imagePath, String ClientID, String number) {
    // return buildGridItem(
    //       message['random_numbers'], // 使用從訊息清單中取得的頭貼
    //       message['sender_id'], // 使用發送者的 ID
    //       message['unread_count'].toString() // 顯示未讀數量
    //     );
    return GestureDetector(
      onTap: () {
        saveClientImage(imagePath); // 儲存客戶 ID
        saveClientID(ClientID); // 儲存客戶 ID
        // saveNum(number); // 儲存未讀訊息數
        Navigator.pushNamed(context, AppRoutes.dataScreen);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0.v),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                height: 55.v,
                width: 55.v,
              ),
              SizedBox(width: 18.v),
              Container(
                width: 28.v,
                height: 24.v,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(167, 186, 137, 0.8),
                  borderRadius: BorderRadius.circular(10.v),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.v,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// 改成未讀訊息的數量 68
// 要紀錄不同的客戶ID傳到下個頁面 81
// 30 幾個用戶要顯示就抓幾個隨機數選頭貼
// 37 從資料庫讀有訊息來往紀錄的用戶數量
