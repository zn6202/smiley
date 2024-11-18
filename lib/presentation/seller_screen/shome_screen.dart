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

class ShomeScreen extends StatefulWidget {
  ShomeScreen({Key? key}) : super(key: key);

  @override
  _ShomeScreenState createState() => _ShomeScreenState();
}

class _ShomeScreenState extends State<ShomeScreen> {
  List<int> randomNumbers = [];
  int dataCount = 0; // 資料數量，初始化為 0

  @override
  void initState() {
    print('進入商家首頁');
    super.initState();
    fetchDataAndGenerateRandomNumbers();
  }

  // 幾個用戶要顯示就抓幾個隨機數選頭貼
  void fetchDataAndGenerateRandomNumbers() async {
    dataCount = await getDataCountFromDatabase();
    randomNumbers = List.generate(dataCount, (index) => Random().nextInt(9) + 1);
    setState(() {});
  }

  // 從資料庫讀有訊息來往紀錄的用戶數量
  Future<int> getDataCountFromDatabase() async {
    await Future.delayed(Duration(seconds: 1)); 
    return 5; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F4E6), // 背景顏色
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Image.asset(
          'assets/store/home.png', 
          color: Color.fromARGB(225, 167, 186, 137), 
          height: 30.v,
          width: 30.v
          ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.v),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 18.0.v,
          mainAxisSpacing: 18.0.v,
          childAspectRatio: 2,
          children: randomNumbers.map((number) {
            return buildGridItem(
              'assets/images/default_avatar_$number.png', 
              '23',//客戶ID
              number.toString()// 每個用戶未讀訊息的數量
            );
          }).toList(),
        ),
      ),
    );
  }

  // 用戶選項方塊
  Widget buildGridItem(String imagePath, String ClientID, String number) {
    return GestureDetector(
      onTap: () {
        saveNum(number);
        // saveClientID(ClientID); // 儲存客戶 ID
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

  // 儲存選到第幾個預設頭貼
  Future<void> saveNum(String _currentNum) async {
    String? number = _currentNum.toString();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('number', number);
  }
}
// 改成未讀訊息的數量 68
// 要紀錄不同的客戶ID傳到下個頁面 81 
// 30 幾個用戶要顯示就抓幾個隨機數選頭貼
// 37 從資料庫讀有訊息來往紀錄的用戶數量
