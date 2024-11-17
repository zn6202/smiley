import 'package:flutter/material.dart';
import '../../core/app_export.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false, // 防止鍵盤彈出時界面過度縮小
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/shop/shopBack.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              // 添加頂部間距
              SizedBox(height: 75.v),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0.v),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.homeScreen);
                      },
                      child: Image.asset(
                        'assets/shop/list.png',
                        width: 25,
                        height: 25,
                      ),
                    ),
                    Image.asset(
                      'assets/shop/cart.png',
                      color: Colors.white,
                      width: 25.v,
                      height: 25.v,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0.v),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40.v),
                    // Welcome Text
                    Text(
                      "welcome to",
                      style: TextStyle(
                        fontSize: 16.v,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 5.v),
                    Text(
                      "植芳園商場",
                      style: TextStyle(
                        fontSize: 40.v,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 38.v),
                    // 搜尋框
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.v, vertical: 10.v),
                      height: 50.v,
                      decoration: BoxDecoration(
                        color: Color(0xFFE9E8D7),
                        borderRadius: BorderRadius.circular(25.v),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.black54),
                          SizedBox(width: 10.v),
                          Text(
                            "Search",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 17.v,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 34.v),
                    // 分割線
                    Container(
                      width: double.infinity,
                      height: 3.v,
                      color: Colors.white,
                    ),
                    SizedBox(height: 50.v),
                    
                    // 水平滾動列表
                    SizedBox(
                      height: 310,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: essentialOils.length,
                        itemBuilder: (context, index) {
                          final oil = essentialOils[index];
                          return Padding(
                            padding: EdgeInsets.only(right: 16.0),
                            child: SizedBox(
                              width: 200,
                              child: Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  Positioned(
                                    bottom: 0,
                                    child: Container(
                                      width: 200,
                                      height: 260,
                                      decoration: BoxDecoration(
                                        color: Color.fromARGB(255, 244, 244, 230),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Column(
                                        children: [
                                          SizedBox(height: 160),
                                          Text(
                                            oil["name"]!,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: Color.fromARGB(255, 84, 84, 83),
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            "NT400",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color.fromARGB(255, 178, 186, 137),
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // 精油瓶圖片
                                  Positioned(
                                    top: 0.v,
                                    left: 30.v,
                                    child: Image.asset(
                                      'assets/shop/oil.png',
                                      height: 170.v, // 圖片高度
                                    ),
                                  ),
                                  // 精油貼圖
                                  Positioned(
                                    top: 80.v,
                                    left: 80.v,
                                    child: Image.network(
                                      'http://163.22.32.24/smiley_backend/img/angel/${oil["image"]}',
                                      height: 100,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
    // 精油名稱及圖片路徑列表
  final List<Map<String, String>> essentialOils = [
    {"name": "薰衣草精油", "image": "anger_2.png"},
    {"name": "玫瑰精油", "image": "anger_2.png"},
    {"name": "茶樹精油", "image": "anger_2.png"},
    {"name": "檸檬精油", "image": "anger_2.png"},
    {"name": "薄荷精油", "image": "anger_2.png"},
    {"name": "尤加利精油", "image": "anger_2.png"},
    {"name": "甜橙精油", "image": "anger_2.png"},
    {"name": "洋甘菊精油", "image": "anger_2.png"},
    {"name": "佛手柑精油", "image": "anger_2.png"},
    {"name": "檀香精油", "image": "anger_2.png"},
  ];
}
