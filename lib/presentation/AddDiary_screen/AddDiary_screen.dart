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

// 主題色彩常數，用於應用程式中的主色調。
const Color primaryColor = Color(0xFFA7BA89);

// 日期文字的樣式常數，用於選定日期的顯示。
const TextStyle selectedDateStyle = TextStyle(
    fontSize: 24.0, color: Color(0xFF545453), fontWeight: FontWeight.bold);

// 標題文字樣式常數
const TextStyle dialogTitleStyle = TextStyle(
    color: Color(0xFF545453),
    fontSize: 25,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w100,
    letterSpacing: -0.32);

// 提示文字樣式常數
const TextStyle dialogContentStyle = TextStyle(
    color: Color(0xFF545453),
    fontSize: 16,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w100,
    letterSpacing: -0.32);

// 按鈕文字樣式常數
const TextStyle buttonTextStyleWhite = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
    height: 1.0);

const TextStyle buttonTextStylePrimary = TextStyle(
    color: Color(0xFFA7BA89),
    fontSize: 18,
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
    waitDialog(context);
    final String content = _formatContent(_textController.text);
    final String date =
        DateFormat('yyyy-MM-dd').format(selectedDate ?? DateTime.now());

    // 獲取 user_id
    final String? userId = await getUserId();

    if (userId == null) {
      // 處理 user_id 為空的情況
      print('Error: user_id is null');
      return;
    }

    print("進入提交日記函式");
    final response = await http.post(
      Uri.parse(API.diary), // 解析字串變成 URI 對象
      body: {
        'user_id': userId,
        'content': content,
        'date': date,
      },
    );
    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      completeDialog(context);
      print('日記提交成功!');
    } else {
      Navigator.of(context).pop();
      failDialog(context);
      print('日記提交失敗...');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 設置主體背景顏色為白色。
      backgroundColor: Colors.white,
      // 應用程式的頂部應用欄。
      appBar: AppBar(
        // 設置應用欄的陰影為 0。
        elevation: 0,
        backgroundColor: Colors.transparent,
        // 應用欄的返回按鈕。
        leading: AppbarLeadingImage(
          imagePath: ImageConstant.imgArrowLeft, // 返回圖標圖片
          margin: EdgeInsets.only(
            // 設定內邊距
            top: 19.v,
            bottom: 19.v,
          ),
          // 點擊返回按鈕時，呼叫 `showExitConfirmationDialog` 函數顯示對話框。
          onTap: () {
            showExitConfirmationDialog(context);
          },
        ),
      ),
      // 主體內容，添加內邊距。
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 內容左對齊排列。
          children: [
            // 顯示選定的日期，使用日期格式化工具格式化日期。
            Text(
              "${DateFormat('yyyy.MM.dd').format(selectedDate ?? DateTime.now())}",
              style: selectedDateStyle, // 日期文字的樣式。
            ),
            SizedBox(height: 16), // 添加垂直間距。
            // 展開多行文本輸入框，以覆蓋整個頁面
            Expanded(
              child: TextField(
                maxLines: null, // 設置輸入框可以多行輸入。
                controller: _textController, // 綁定文本控制器。
                keyboardType: TextInputType.multiline, // 設置輸入類型為多行文本。
                decoration: InputDecoration(
                  border: InputBorder.none, // 無邊框樣式。
                  hintText: '說說你的心情吧...', // 提示文字。
                ),
                style: TextStyle(fontSize: 16), // 文本樣式。
              ),
            ),
            // 完成按鈕
            Center(
              child: Container(
                height: 40,
                width: 114,
                decoration: ShapeDecoration(
                  color: Color(0xFFA7BA89),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      showSaveConfirmationDialog(context); // 完成"日記"、"分析"、"小天使小怪獸" 的後端
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
            SizedBox(height: 16), // 確保按鈕下方有足夠間距。
          ],
        ),
      ),
    );
  }

  void showExitConfirmationDialog(BuildContext context) {
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
            width: 304.0, // 設置對話框的寬度
            height: 222.4, // 設置對話框的高度
            padding: const EdgeInsets.symmetric(horizontal: 23), // 設置對話框的內邊距
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
                    '按下返回鍵後，無法儲存日記內容。您確認您要返回嗎？', // 提示文本
                    textAlign: TextAlign.center, // 文本居中對齊
                    style: dialogContentStyle,
                  ),
                ),
                const SizedBox(height: 20), // 添加垂直間距
                // 添加水平排列的按鈕
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 按鈕之間均勻分布
                  children: [
                    // 返回按鈕
                    Container(
                      height: 40, // 按鈕容器高度
                      width: 114, // 設置按鈕寬度
                      decoration: ShapeDecoration(
                        color: Colors.white, // 按鈕背景顏色
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              width: 1, color: Color(0xFFA7BA89)), // 設置邊框顏色和寬度
                          borderRadius: BorderRadius.circular(20), // 設置圓角大小
                        ),
                      ),
                      child: Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop(); //回到主頁
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
                      height: 40, // 按鈕容器高度
                      width: 114, // 設置按鈕寬度
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

  void showSaveConfirmationDialog(BuildContext context) {
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
            width: 304.0, // 設置對話框的寬度
            height: 222.4, // 設置對話框的高度
            padding: const EdgeInsets.symmetric(horizontal: 23), // 設置對話框的內邊距
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
                    '按下確認鍵後，後續內容將無法再作修改。您確認您已經完成了嗎？', // 提示文本
                    textAlign: TextAlign.center, // 文本居中對齊
                    style: dialogContentStyle,
                  ),
                ),
                const SizedBox(height: 20), // 添加垂直間距
                // 添加水平排列的按鈕
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 按鈕之間均勻分布
                  children: [
                    // 返回按鈕
                    Container(
                      height: 40, // 按鈕容器高度
                      width: 114, // 設置按鈕寬度
                      decoration: ShapeDecoration(
                        color: Colors.white, // 按鈕背景顏色
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              width: 1, color: Color(0xFFA7BA89)), // 設置邊框顏色和寬度
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
                      height: 40, // 按鈕容器高度
                      width: 114, // 設置按鈕寬度
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

  waitDialog(BuildContext context) {
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
            width: 304.0, // 設置對話框的寬度
            height: 142.4, // 設置對話框的高度
            padding: const EdgeInsets.symmetric(horizontal: 23), // 設置對話框的內邊距
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
                    '分析情緒中', // 標題文本
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
                    '聽說多微笑會變漂亮耶~\n要不要笑一個ㄚ', // 提示文本
                    textAlign: TextAlign.center, // 文本居中對齊
                    style: dialogContentStyle,
                  ),
                ),
                const SizedBox(height: 20), // 添加垂直間距
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
              Navigator.pushNamed(context, AppRoutes.diaryMainScreen); //要再改成analyzeDiaryScreen
            
            },
            child: Container(
              width: 304.0, // 設置對話框的寬度
              height: 121.4, // 設置對話框的高度
              padding: const EdgeInsets.symmetric(horizontal: 23), // 設置對話框的內邊距
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
                      '分析結果出爐了~ 快去看看吧！', // 提示文本
                      textAlign: TextAlign.center, // 文本居中對齊
                      style: dialogContentStyle,
                    ),
                  ),
                  const SizedBox(height: 20), // 添加垂直間距
                ],
              ),
            ),
          )
        );
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
              width: 304.0, // 設置對話框的寬度
              height: 121.4, // 設置對話框的高度
              padding: const EdgeInsets.symmetric(horizontal: 23), // 設置對話框的內邊距
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
                      '分析失敗', // 標題文本
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
                      '點我再試一次!', // 提示文本
                      textAlign: TextAlign.center, // 文本居中對齊
                      style: dialogContentStyle,
                    ),
                  ),
                  const SizedBox(height: 20), // 添加垂直間距
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
/*
1. 捲動畫面最上方會有紫色陰影
2. 用Navigator.of(context).pop();來關閉前一個dialog時 會回到輸入日記 會彈出鍵盤 看如何修改
*/