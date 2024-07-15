import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_export.dart'; // 應用程式導出模組
import '../../widgets/app_bar/appbar_leading_image.dart'; // 自定義應用欄返回按鈕
import 'package:http/http.dart' as http; // HTTP請求插件
import '../setNamePhoto_screen/setNamePhoto_screen.dart';

const TextStyle dialogTitleStyle = TextStyle(
    color: Color(0xFF545453),
    fontSize: 25,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w100,
    letterSpacing: -0.32);

const TextStyle dialogContentStyle = TextStyle(
    color: Color(0xFF545453),
    fontSize: 16,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w100,
    letterSpacing: -0.32);


class Defaultavatar extends StatefulWidget {
  @override
  _DefaultavatarState createState() => _DefaultavatarState();
}

class _DefaultavatarState extends State<Defaultavatar> {
  final List<String> avatarImages = [
    'assets/images/default_avatar_1.png',
    'assets/images/default_avatar_2.png',
    'assets/images/default_avatar_3.png',
    'assets/images/default_avatar_4.png',
    'assets/images/default_avatar_5.png',
    'assets/images/default_avatar_6.png',
    'assets/images/default_avatar_7.png',
    'assets/images/default_avatar_8.png',
    'assets/images/default_avatar_9.png',
  ];

  // 將選擇的頭像路徑發送到 setNamePhoto
  Future<void> sendAvatarPath(String path) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SetNamePhoto(),
        settings: RouteSettings(arguments: path), // 傳遞選擇的圖片路徑
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F4E6), // 設置背景顏色
      appBar: AppBar(
        elevation: 0, // 設置應用欄的陰影為0
        backgroundColor: Colors.transparent, // 設置背景透明
        leading: AppbarLeadingImage(
          imagePath: 'assets/images/arrow-left-g.png', // 返回圖標圖片
          margin: EdgeInsets.only(
            top: 19.0,
            bottom: 19.0,
          ),
          onTap: () async {
            FocusScope.of(context).requestFocus(FocusNode());
            await Future.delayed(Duration(milliseconds: 500));
            Navigator.pop(context); // 點擊返回按鈕返回上一頁
          },
        ),
        title: Image.asset(
          'assets/images/default_avatar_icon.png',
          height: 30, // 您可以根據需要調整圖片的高度
        ),
        centerTitle: true, // 將圖片設置為居中
      ),
      body: Center(
        child: GridView.builder(
          padding: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 每行顯示三個圓形圖像
            crossAxisSpacing: 20.0, // 圖像之間的水平間距
            mainAxisSpacing: 20.0, // 圖像之間的垂直間距
          ),
          itemCount: avatarImages.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                sendAvatarPath(avatarImages[index]);
                completeDialog(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7), // 底色#FFFFFF 透明度70%
                  shape: BoxShape.circle, // 圓形背景
                ),
                child: Padding(
                  padding: EdgeInsets.all(10.0), // 圓形容器內的間距
                  child: Image.asset(
                    avatarImages[index],
                    fit: BoxFit.contain, // 圖片的適應方式
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

   completeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // 返回一個自定義的 Dialog 小部件
        return Dialog(
            // 設置對話框的形狀和圓角
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0), // 設置圓角大小
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Container(
                width: 304.0, // 設置對話框的寬度
                height: 121.4, // 設置對話框的高度
                padding:
                    const EdgeInsets.symmetric(horizontal: 23), // 設置對話框的內邊距
                clipBehavior: Clip.antiAlias, // 防止對話框內容超出邊界
                decoration: ShapeDecoration(
                  color: Colors.white, // 設置對話框的背景顏色
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0), // 設置圓角大小
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // 垂直方向上居中對齊
                  crossAxisAlignment: CrossAxisAlignment.center, // 水平方向上居中對齊
                  children: [
                    const SizedBox(height: 10), // 添加垂直間距
                    // 設置標題文本
                    SizedBox(
                      width: double.infinity, // 寬度設置為充滿父容器
                      child: Text(
                        '完成', // 標題文本
                        textAlign: TextAlign.center, // 文本居中對齊
                        style: dialogTitleStyle,
                      ),
                    ),
                    const SizedBox(height: 10), // 添加垂直間距
                    // 添加橫線
                    Container(
                      width: 244.50,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            strokeAlign: BorderSide.strokeAlignCenter,
                            color: Color(0xFFDADADA),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10), // 添加垂直間距
                    // 設置提示文本
                    SizedBox(
                      width: double.infinity, // 寬度設置為充滿父容器
                      child: Text(
                        '頭貼更變完成！', // 提示文本
                        textAlign: TextAlign.center, // 文本居中對齊
                        style: dialogContentStyle,
                      ),
                    ),
                    const SizedBox(height: 20), // 添加垂直間距
                  ],
                ),
              ),
            ));
      },
    );
  }
}

/*
選好頭像後 要回傳路徑給後端 
修改sendAvatarPath
*/