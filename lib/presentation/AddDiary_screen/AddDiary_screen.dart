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
    final String content = _formatContent(_textController.text);
    final String date = DateFormat('yyyy-MM-dd').format(selectedDate ?? DateTime.now());

    // 獲取 user_id
    final String? userId = await getUserId();

    if (userId == null) {
      // 處理 user_id 為空的情況
      print('Error: user_id is null');
      return;
    }

    print("進入提交日記函式");
    final response = await http.post( // await 等待完成。 ex:等 post 完成再開始執行 69 行
      Uri.parse(API.diary), // 解析字串變成 URI 對象
      body: {
        'user_id': userId,
        'content': content,
        'date': date,
      },
    );

    // print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      // 修改 73 -> 顯示完成分析對話框
      Navigator.pushNamed(context, AppRoutes.diaryMainScreen);
      print('日記提交成功!');
    } else {
      // 修改 77 -> ???
      Navigator.pushNamed(context, AppRoutes.diaryMainScreen);
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
        // 設置應用欄的背景色為透明。
        backgroundColor: Colors.transparent,
        // 應用欄的返回按鈕。
        leading: AppbarLeadingImage(
          imagePath: ImageConstant.imgArrowLeft, // 返回圖標圖片
          margin: EdgeInsets.only(
            // 設定內邊距
            left: 41.h,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顯示選定的日期，使用日期格式化工具格式化日期。
            Text(
              "${DateFormat('yyyy.MM.dd').format(selectedDate ?? DateTime.now())}",
              style: selectedDateStyle, // 日期文字的樣式。
            ),
            SizedBox(height: 16), // 添加垂直間距。
            Expanded(
              child: SingleChildScrollView(
                // 多行文本輸入框。
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
            ),
            SizedBox(height: 16), // 添加垂直間距。
            // 使用 Spacer 元件將按鈕向上推。
            Spacer(flex: 1),
            // 中間對齊的完成按鈕。
            Center(
              child: ElevatedButton(
                // 按鈕的點擊事件，目前未設置具體功能。
                onPressed: () {
                  // 顯示等待分析對話框
                  submitDiary(context); // 完成"日記"、"分析"、"小天使小怪獸" 的後端
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor, // 設置按鈕的背景色。
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // 設置按鈕圓角。
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: 32, vertical: 20), // 設置按鈕內邊距。
                ),
                child: Text(
                  '完成', // 按鈕上的文字。
                  style: TextStyle(fontSize: 18, color: Colors.white), // 按鈕文字樣式。
                ),
              ),
            ),
            SizedBox(height: 16), // 確保按鈕下方有足夠間距。
          ],
        ),
      ),
    );
  }

  // 顯示返回確認對話框。
  void showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('返回首頁確認'),
          content: Text('按下返回鍵後，無法儲存日記內容。您確認您要返回嗎？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 關閉對話框，繼續編輯。
              },
              child: Text('繼續編輯'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 關閉對話框。
                Navigator.of(context).pop(); // 返回上一頁。
              },
              child: Text('返回'),
            ),
          ],
        );
      },
    );
  }
}


/*
1. 未將返回dialog改成設計樣式
2. 未加入繳交dialog
3. 提示文字(說說你的心情吧)，改成用灰色
 */

/*
1. 日記打很長的時候，發現能瀏覽的範圍很小。(區塊設定有誤)
2. 按"完成"後，出現等待畫面 (143 修改) -> 進入後端 -> 提交跟分析完成後，出現分析完成畫面 (73 77 修改)
3. 等待結束後，要能顯示日記跟小天使小怪獸。
*/