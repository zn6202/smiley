// 匯入 Flutter 材料設計套件。
import 'package:flutter/material.dart';
// 匯入應用程式核心文件，用於應用程式的整體配置和設定。
import '../../core/app_export.dart';
// 匯入國際化工具套件，用於日期格式化。
import 'package:intl/intl.dart';
import '../../widgets/app_bar/appbar_leading_image.dart';
// http
import 'package:http/http.dart' as http;
import '../../routes/api_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';

// 主題色彩常數，用於應用程式中的主色調。
const Color primaryColor = Color(0xFFA7BA89);

// 日期文字的樣式常數，用於選定日期的顯示。
TextStyle selectedDateStyle = TextStyle(
    fontSize: 24.0.fSize, color: Color(0xFF545453), fontWeight: FontWeight.bold);

// 標題文字樣式常數
TextStyle dialogTitleStyle = TextStyle(
    color: Color(0xFF545453),
    fontSize: 25.fSize,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w100,
    letterSpacing: -0.32);

// 提示文字樣式常數
TextStyle dialogContentStyle = TextStyle(
    color: Color(0xFF545453),
    fontSize: 16.fSize,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w100,
    letterSpacing: -0.32);

// 按鈕文字樣式常數
TextStyle buttonTextStyleWhite = TextStyle(
    color: Colors.white,
    fontSize: 18.fSize,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
    height: 1.0);

TextStyle buttonTextStylePrimary = TextStyle(
    color: Color(0xFFA7BA89),
    fontSize: 18.fSize,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
    height: 1.0);

// 定義一個新的 StatefulWidget 用於新增日記。
class AddDiaryScreen extends StatefulWidget {
  @override
  _AddDiaryScreenState createState() => _AddDiaryScreenState();
}

// AddDiaryScreen 的狀態類，管理 AddDiaryScreen 的狀態。
class _AddDiaryScreenState extends State<AddDiaryScreen> {
  // 文本控制器，用於控制 TextField 的輸入。
  final TextEditingController _textController = TextEditingController();
  // 用於保存選定的日期，初始為當前日期。
  DateTime? selectedDate = DateTime.now();
  bool isSubmitted = false; // 表示日記是否已提交
  String submittedContent = ""; // 保存提交的日記內容
  // 抓取當前 user_id
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  // 替換日記內容中的換行符為空格
  String _formatContent(String content) {
    return content.replaceAll('\n', ' ');
  }

  void submitDiary(BuildContext context) async {
    showWaitingDialog(context);
    final String content = _formatContent(_textController.text);
    final String date =
        DateFormat('yyyy-MM-dd').format(selectedDate ?? DateTime.now());
    final String? userId = await getUserId();

    print("進入提交日記函式 content: $content date:$date userId:$userId");

    Navigator.of(context).pop(); // 在這裡 pop context

    // 使用 Future.delayed 給 context 充分的時間處理 pop 事件
    await Future.delayed(Duration(milliseconds: 100));

    final response = await http.post(
      Uri.parse(API.diary), // 解析字串變成 URI 對象
      body: {
        'user_id': userId,
        'content': content,
        'date': date,
      },
    );
    
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      print("result = $result");

      // 此處重新獲得新的 context 來顯示 dialog
      if (context.mounted) {
        completeDialog(context);
      }
      
      setState(() {
        isSubmitted = true;
        submittedContent = content;
      });
      print('日記提交成功!');
    } else {
      // 此處重新獲得新的 context 來顯示 dialog
      if (context.mounted) {
        failDialog(context);
      }
      print('日記提交失敗...');
    }
  } 



  Widget build(BuildContext context) {
    return Scaffold(
      // 設置主體背景顏色為白色。
      backgroundColor: Colors.white,
      // 應用程式的頂部應用欄。
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: SvgPicture.asset(
                'assets/images/img_arrow_left.svg',
              ),
              onPressed: () async {
                if (isSubmitted) {
                  Navigator.of(context).pop();
                } else {
                  if (_textController.text.trim().isEmpty) {
                    Navigator.of(context).pop();
                  } else {
                    showExitConfirmationDialog(context);
                  }
                }
              },
            ),
          ),
      // 主體內容，添加內邊距。
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 內容左對齊排列。
          children: [
            // 顯示選定的日期，使用日期格式化工具格式化日期。
            Text(
              "${DateFormat('yyyy.MM.dd').format(selectedDate ?? DateTime.now())}",
              style: selectedDateStyle, // 日期文字的樣式。
            ),
            SizedBox(height: 16.v), // 添加垂直間距。
            // 展開多行文本輸入框，以覆蓋整個頁面
            Expanded(
              child: Container(
                alignment: Alignment.topLeft,
                child: isSubmitted
                    ? SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              submittedContent, // 顯示已提交的日記內容
                              style: TextStyle(fontSize: 16.fSize),
                            ),
                            SizedBox(height: 20.v), // 添加間距
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                buildEmotionBlock(
                                    'assets/images/monster_1.png'), //這裡到時候要改成小怪獸演算法函式
                                buildEmotionBlock(
                                    'assets/images/monster_2.png'),
                              ],
                            ),
                          ],
                        ),
                      )
                    : TextField(
                        maxLines: null, // 設置輸入框可以多行輸入。
                        controller: _textController, // 綁定文本控制器。
                        keyboardType: TextInputType.multiline, // 設置輸入類型為多行文本。
                        decoration: InputDecoration(
                          border: InputBorder.none, // 無邊框樣式。
                          hintText: '說說你的心情吧...', // 提示文字。
                        ),
                        style: TextStyle(fontSize: 16.fSize), // 文本樣式。
                      ),
              ),
            ),
            // 完成按鈕
            if (!isSubmitted)
              Center(
                child: Container(
                  height: 40.v,
                  width: 114.h,
                  decoration: ShapeDecoration(
                    color: Color(0xFFA7BA89),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        showSaveConfirmationDialog(
                            context); // 完成"日記"、"分析"、"小天使小怪獸" 的後端
                      },
                      child: Text(
                        '完成', // 按鈕上的文字。
                        textAlign: TextAlign.center,
                        style: buttonTextStyleWhite,
                      ),
                    ),
                  ),
                ),
              ),
            SizedBox(height: 16.v), // 確保按鈕下方有足夠間距。
          ],
        ),
      ),
    );
  }

/*
!!!!小怪獸演算法區域!!!!
目前先顯示figma上的圖片，之後演算法建立好後 只要呼叫這個 並附上圖片網址即可
 */
  Widget buildEmotionBlock(String imageUrl) {
    return Container(
      width: 140.h,
      height: 246.v,
      padding: EdgeInsets.symmetric(horizontal: 18.h, vertical: 20.v),
      margin: EdgeInsets.symmetric(horizontal: 14.5.h),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Color(0xFFC4C4C4)),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.postPage, arguments: imageUrl);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 106.h,
              height: 27.v,
              child: Text(
                '情緒小怪獸',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFC4C4C4),
                  fontSize: 16.fSize,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.32,
                ),
              ),
            ),
            Container(
              width: 126.h,
              height: 122.v,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imageUrl),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            SizedBox(height: 30.v),
            Container(
              width: 114.h,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                '輕觸發文',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFCDCED0),
                  fontSize: 15.fSize,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  height: 1.5.v / 15.fSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  showExitConfirmationDialog(BuildContext context) {
    // 顯示對話框
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // 返回一個自定義的 Dialog 小部件
        return Dialog(
          // 設置對話框的形狀和圓角
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0), // 設置圓角大小
          ),
          child: Container(
            width: 304.h, // 設置對話框的寬度
            height: 222.4.v, // 設置對話框的高度
            padding: EdgeInsets.symmetric(horizontal: 23.h), // 設置對話框的內邊距
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
                // 設置標題文本
                SizedBox(
                  width: double.infinity, // 寬度設置為充滿父容器
                  child: Text(
                    '返回首頁確認', // 標題文本
                    textAlign: TextAlign.center, // 文本居中對齊
                    style: dialogTitleStyle,
                  ),
                ),
                SizedBox(height: 10.v), // 添加垂直間距
                // 添加橫線
                Container(
                  width: 244.5.h,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1.h,
                        strokeAlign: BorderSide.strokeAlignCenter,
                        color: Color(0xFFDADADA),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.v), // 添加垂直間距
                // 設置提示文本
                SizedBox(
                  width: double.infinity, // 寬度設置為充滿父容器
                  child: Text(
                    '按下返回鍵後，無法儲存日記內容。您確認您要返回嗎？', // 提示文本
                    textAlign: TextAlign.center, // 文本居中對齊
                    style: dialogContentStyle,
                  ),
                ),
                SizedBox(height: 20.v), // 添加垂直間距
                // 添加水平排列的按鈕
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 按鈕之間均勻分布
                  children: [
                    // 返回按鈕
                    Container(
                      height: 42.v, // 按鈕容器高度
                      width: 114.h, // 設置按鈕寬度
                      decoration: ShapeDecoration(
                        color: Colors.white, // 按鈕背景顏色
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              width: 1.h, color: Color(0xFFA7BA89)), // 設置邊框顏色和寬度
                          borderRadius: BorderRadius.circular(20), // 設置圓角大小
                        ),
                      ),
                      child: Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, AppRoutes.diaryMainScreen);
                          },
                          child: Text(
                            '返回', // 按鈕文本
                            textAlign: TextAlign.center, // 文本居中對齊
                            style: buttonTextStylePrimary,
                          ),
                        ),
                      ),
                    ),
                    // 繼續編輯按鈕
                    Container(
                      height: 42.v, // 按鈕容器高度
                      width: 114.h, // 設置按鈕寬度
                      decoration: ShapeDecoration(
                        color: Color(0xFFA7BA89), // 按鈕背景顏色
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // 設置圓角大小
                        ),
                      ),
                      child: Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // 點擊按鈕時關閉對話框
                          },
                          child: Text(
                            '繼續編輯', // 按鈕文本
                            textAlign: TextAlign.center, // 文本居中對齊
                            style: buttonTextStyleWhite,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  showSaveConfirmationDialog(BuildContext context) {
    // 顯示對話框
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // 返回一個自定義的 Dialog 小部件
        return Dialog(
          // 設置對話框的形狀和圓角
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0), // 設置圓角大小
          ),
          child: Container(
            width: 304.0.h, // 設置對話框的寬度
            height: 222.4.v, // 設置對話框的高度
            padding: EdgeInsets.symmetric(horizontal: 23.h), // 設置對話框的內邊距
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
                // 設置標題文本
                SizedBox(
                  width: double.infinity, // 寬度設置為充滿父容器
                  child: Text(
                    '日記繳交確認', // 標題文本
                    textAlign: TextAlign.center, // 文本居中對齊
                    style: dialogTitleStyle,
                  ),
                ),
                SizedBox(height: 10.v), // 添加垂直間距
                // 添加橫線
                Container(
                  width: 244.5.h,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1.v,
                        strokeAlign: BorderSide.strokeAlignCenter,
                        color: Color(0xFFDADADA),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.v), // 添加垂直間距
                // 設置提示文本
                SizedBox(
                  width: double.infinity, // 寬度設置為充滿父容器
                  child: Text(
                    '按下確認鍵後，後續內容將無法再作修改。您確認您已經完成了嗎？', // 提示文本
                    textAlign: TextAlign.center, // 文本居中對齊
                    style: dialogContentStyle,
                  ),
                ),
                SizedBox(height: 20.v), // 添加垂直間距
                // 添加水平排列的按鈕
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 按鈕之間均勻分布
                  children: [
                    // 返回按鈕
                    Container(
                      height: 42.v, // 按鈕容器高度
                      width: 114.h, // 設置按鈕寬度
                      decoration: ShapeDecoration(
                        color: Colors.white, // 按鈕背景顏色
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              width: 1.h, color: Color(0xFFA7BA89)), // 設置邊框顏色和寬度
                          borderRadius: BorderRadius.circular(20), // 設置圓角大小
                        ),
                      ),
                      child: Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // 點擊按鈕時關閉對話框
                          },
                          child: Text(
                            '未完成', // 按鈕文本
                            textAlign: TextAlign.center, // 文本居中對齊
                            style: buttonTextStylePrimary,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 42.v, // 按鈕容器高度
                      width: 114.h, // 設置按鈕寬度
                      decoration: ShapeDecoration(
                        color: Color(0xFFA7BA89), // 按鈕背景顏色
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // 設置圓角大小
                        ),
                      ),
                      child: Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            submitDiary(context); // 提交日記
                          },
                          child: Text(
                            '完成', // 按鈕文本
                            textAlign: TextAlign.center, // 文本居中對齊
                            style: buttonTextStyleWhite,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
                setState(() {
                  isSubmitted = true;
                  submittedContent = _textController.text; // 保存提交的日记内容
                });
              },
              child: Container(
                width: 304.h, // 設置對話框的寬度
                height: 131.4.v, // 設置對話框的高度
                padding:
                    EdgeInsets.symmetric(horizontal: 23.h), // 設置對話框的內邊距
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
                    SizedBox(height: 20.v), // 添加垂直間距
                    // 設置標題文本
                    SizedBox(
                      width: double.infinity, // 寬度設置為充滿父容器
                      child: Text(
                        '完成', // 標題文本
                        textAlign: TextAlign.center, // 文本居中對齊
                        style: dialogTitleStyle,
                      ),
                    ),
                    SizedBox(height: 10.v), // 添加垂直間距
                    // 添加橫線
                    Container(
                      width: 244.5.h,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1.h,
                            strokeAlign: BorderSide.strokeAlignCenter,
                            color: Color(0xFFDADADA),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.v), // 添加垂直間距
                    // 設置提示文本
                    SizedBox(
                      width: double.infinity, // 寬度設置為充滿父容器
                      child: Text(
                        '分析結果出爐了~ 快去看看吧！', // 提示文本
                        textAlign: TextAlign.center, // 文本居中對齊
                        style: dialogContentStyle,
                      ),
                    ),
                    SizedBox(height: 20.v), // 添加垂直間距
                  ],
                ),
              ),
            ));
      },
    );
  }

  failDialog(BuildContext context) {
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
              submitDiary(context); // 呼叫提交日記方法
            },
            child: Container(
              width: 304.h, // 設置對話框的寬度
              height: 121.4.v, // 設置對話框的高度
              padding: EdgeInsets.symmetric(horizontal: 23.h), // 設置對話框的內邊距
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
                  SizedBox(height: 10.v), // 添加垂直間距
                  // 設置標題文本
                  SizedBox(
                    width: double.infinity, // 寬度設置為充滿父容器
                    child: Text(
                      '分析失敗', // 標題文本
                      textAlign: TextAlign.center, // 文本居中對齊
                      style: dialogTitleStyle,
                    ),
                  ),
                  SizedBox(height: 10.v), // 添加垂直間距
                  // 添加橫線
                  Container(
                    width: 244.5.h,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1.h,
                          strokeAlign: BorderSide.strokeAlignCenter,
                          color: Color(0xFFDADADA),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.v), // 添加垂直間距
                  // 設置提示文本
                  SizedBox(
                    width: double.infinity, // 寬度設置為充滿父容器
                    child: Text(
                      '點我再試一次!', // 提示文本
                      textAlign: TextAlign.center, // 文本居中對齊
                      style: dialogContentStyle,
                    ),
                  ),
                  SizedBox(height: 20.v), // 添加垂直間距
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showWaitingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Container(
            width: 304.h,
            height: 160.0.v,
            padding: EdgeInsets.symmetric(horizontal: 23.h,vertical: 23.v),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    '分析情緒中',
                    textAlign: TextAlign.center,
                    style: dialogTitleStyle,
                  ),
                ),
                SizedBox(height: 10.v),
                Container(
                  width: 244.5.h,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1.h,
                        color: Color(0xFFDADADA),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.v),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    '聽說多微笑會變漂亮耶~\n要不要笑一個ㄚ',
                    textAlign: TextAlign.center,
                    style: dialogContentStyle,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/*
前端修正:
- 捲動畫面最上方會有紫色陰影
- 輸入框與提交後日記顯示的起始點有些微不同

- new! 左邊標題是情緒小天使
*/

/*
後端需再處理的事項：
1.連接情緒辨識模型
2.連接情緒小怪獸結果 
資料格式都先用圖片網址:'assets/images/monster_1.png' 按下後會把路徑給postPage去顯示 所以如果這裡改了資料格式 記得修改那部分
*/