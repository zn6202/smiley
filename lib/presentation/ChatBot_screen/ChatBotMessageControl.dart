import '../../core/app_export.dart';
import 'package:http/http.dart' as http;
import '../../routes/api_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 管理聊天機器人

// 負責載入和存取對話紀錄
// 之後會改成從後端取得對話紀錄
class MessageProvider with ChangeNotifier {
  List<Map<String, String>> _messages = []; // 和機器人的聊天紀錄
  int _newMessages = 0;                     // 新訊息數量
  List<Map<String, String>> get messages => this._messages;
  int get newMessages => this._newMessages;
  bool isSending = true;

  // 使用者資料
  String userID = "";
  String userName = 'User';

  set newMessages(int newMessages){
    this._newMessages = newMessages;
  }

  void clearUnread() {
    _newMessages = 0;
    notifyListeners();
  }
  void updateUnreadMsg(int value) {
    _newMessages = value;
    notifyListeners();
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  // 取得userName、接收歡迎訊息
  Future<void> fetchUserData() async {
    // 模擬從資料庫獲取數據
    final String? id = await getUserId();
    if (id == null) {
      // 處理 user_id 為空的情況
      print('Error: user_id is null');
      return;
    }
    final response = await http.post(
      Uri.parse(API.getProfile), // 解析字串變成 URI 對象
      body: {
        'id': id,
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success']) {
          userID = id;
          userName = responseData['name'];
          return;
      } else {
        print('使用者名稱取得失敗: ${responseData['message']}');
        return;
      }
    } else {
      print('使用者名稱取得失敗...');
      return;
    }
  }

  // 助手機器人歡迎訊息$
  Future<Map<String, String>> fetchWelcomeMessage() async {
    await fetchUserData(); // 取得使用者名稱
    print("userName:$userName");
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5001/welcome'),
      headers: <String, String>{'Content-Type': 'application/json; charset=utf-8',},
      body: jsonEncode({'user_id': userID, 'user_name': userName})
      );
    if (response.statusCode == 200) {
      // response.body = "response": "\u6211\u6703\u4e00\u76f4\u966a\u4f34\u5728\u4f60\u8eab\u908a\uff0c\u7121\u8ad6\u4f60\u9047\u5230\u4ec0\u9ebc\u56f0\u96e3\u6216\u7169\u60f1\u3002"
      final jsonresponseDecoded = jsonDecode(response.body);                        // jsonResponse = {response: 我會一直陪伴在你身邊，無論你遇到什麼困難或煩惱。}
      final jsonresponseContent = jsonresponseDecoded["response"] as String;        // 我會一直陪伴在你身邊，無論你遇到什麼困難或煩惱。
      final responseMessage = {'role': 'assistant', 'content': jsonresponseContent};
      _messages.add(responseMessage);
      _newMessages++;
      isSending = false;
      notifyListeners();
      return responseMessage;
    }
    else {
      final responseMessage = {'role': 'sys','content': '取得訊息失敗'};
      _newMessages++;
      isSending = false;
      notifyListeners();
      return responseMessage;
    }
  }
  
  // 接受一個字串參數messageContent，用於傳送訊息到Python伺服器並等待回應
  Future<Map<String, String>> sendDataToPython(String messageContent) async {           // 傳送訊息至Python，等待接收回覆
    await fetchUserData(); // 取得使用者名稱
    final message = messageContent;                                                     //     欲傳送之訊息：{'role': 'user', 'content': 使用者輸入之訊息}
    final response = await http.post(                                                   //     發送HTTP POST請求至後端並等待回應，傳送訊息，並等待回覆
      Uri.parse('http://10.0.2.2:5001/send_message_to_python'),                         //       設定請求的URL，指向本地開發環境的Python伺服器
      headers: <String, String>{'Content-Type': 'application/json; charset=utf-8',},    //        設定HTTP請求的標頭，指定內容類型為JSON，編碼為UTF-8
      body: jsonEncode({'user_id': userID,'user_name': userName,'messages': message})   //        傳送之訊息（將訊息內容包裝為JSON格式並作為請求的body）
    );
    if (response.statusCode == 200) {                                                   //     成功收到回覆（如果HTTP回應狀態碼為200，表示請求成功）
      final jsonresponseDecoded = jsonDecode(response.body);                            //     將回應的body從JSON格式解碼為Dart物件
      final jsonresponseContent = jsonresponseDecoded["response"] as String;            //     從解碼後的JSON物件中提取回應內容，這裡假設回應的JSON物件中有一個鍵為"response"
      final responseMessage = {'role': 'assistant', 'content': jsonresponseContent};
      _messages.add(responseMessage);
      _newMessages++;
      isSending = false;
      notifyListeners();
      return responseMessage;
    }
    else {
      final responseMessage = {'role': 'sys','content': '取得訊息失敗'};
      _newMessages++;
      isSending = false;
      notifyListeners();
      return responseMessage;
    }
  }
  String getUserDiary(String diaryMessage){
    // 取得並回傳User寫的日記並
    // String newDiary = "「紀錄時間：『2024年9月11日，星期三。』。日記內容：『今天是個特別讓人心動的日子！早上在咖啡店排隊時，偶然間與一個陌生人聊了起來。他對咖啡的熱情和深厚的知識讓我感到非常有趣，並且他那種真誠的微笑讓人很難不喜歡上他。中午時，我居然又在公園裡碰到了他！但這次我們坐下來聊了很久，話題從咖啡延展到音樂、旅行和書籍。我們發現彼此有很多共同的愛好，這種感覺實在太美好了～下午我回到家後，整個人都充滿了愉快的情緒。每當想起我們的對話，我都忍不住微笑。那種心動的感覺真是讓人難以忘懷。今天的每一刻都讓我感到無比愉快，心裡充滿了對未來的期待和喜歡的感覺。』」";
    // String newDiary = "紀錄時間：『2024年9月11日，星期三。』。日記內容：『早上收到消息，一個很親近的朋友突然決定搬到其他城市去工作。這個消息對我來說非常震驚和難過，因為我們一起度過了很多快樂的時光，現在突然要分開，心裡感到無比的失落。工作中也沒有什麼好消息，幾個重要的項目進展不順利，讓我感到壓力山大。同事們似乎也很忙碌，沒有時間互相支持和幫助，這讓我感到更加孤單和無助。午餐時，本來想給自己買點喜歡的食物來振作一下心情，結果卻發現自己最愛的那家餐廳今天關門了。這小小的打擊讓我更覺得整個世界都在與我作對。下午試著集中精神工作，但心情一直無法平靜下來，總是想起朋友離開的事。晚上回到家，感覺整個人都被悲傷和孤獨包圍，只能靜靜地躺在床上，默默流淚。』";
    // String newDiary = "「紀錄時間：『2024年9月11日，星期三。』。日記內容：『今天真是讓人惱火的一天！！！！早上在公司，老闆無緣無故對我發火，責怪我沒有完成一個根本不屬於我的任務。我試圖解釋，但他根本不聽，甚至威脅要扣我的薪水。這讓我感到極度不公平和憤怒午餐時，本來打算和同事們一起放鬆一下，但餐廳服務態度極差，餐點還上錯了兩次。這一系列的小事累積下來，讓我心裡的怒火越來越旺。下午回到辦公室，又收到客戶的無理要求和抱怨，這些明顯是他們自己的問題，卻都推到我頭上。我感到非常無力和憤怒，但只能強忍著，因為知道即使表達出來也無濟於事。回家路上還遇到塞車，其他車輛的惡劣行為與三寶技術讓我心情更加煩躁。回到家後，本來期待能放鬆一下，才發現忘記停水公告，澡都無法洗了…』」";
    // String newDiary = "「紀錄時間：『2024年9月11日，星期三。』。日記內容：『今天有夠糟糕。早上剛起床，我就感覺到肚子一陣翻騰，像是吃壞了什麼東西。強忍著不適去上班，結果途中還遇到堵車，車裡悶熱的空氣讓我感到更加噁心⋯到了公司後，狀況並沒有好轉⋯同事帶來的早餐味道讓我更加難受。忍著不適處理工作，但無法集中精神，感覺頭昏眼花。午飯時間，同事們邀我去餐廳吃飯，我只能勉強陪同，但一進餐廳，濃烈的食物氣味讓我幾乎要吐出來。下午請了病假回家，一路上感覺像在走鋼絲，深怕自己會在大街上吐出來。回到家裡，只能躺在床上休息，但那股噁心的感覺始終揮之不去，整個人疲憊不堪。噩夢般的一天能快點結束。』」";
    //String newDiary = "「紀錄時間：『2024年9月11日，星期三。』。日記內容：『今天是一個美好的日子！一大早醒來，陽光透過窗戶灑進房間，感覺整個人都被幸福包圍了。早餐時，我和家人一起享用了豐盛的早點，大家談笑風生，氣氛非常愉快～～下午我獨自去公園散步，微風輕拂，花草的香氣讓人心曠神怡。晚上，我邀請朋友來家裡，一起做了一頓美味的晚餐，點上蠟燭、放著柔和的音樂，一切都顯得那麼愉悅和溫馨！看著大家的笑容，我也感受到滿滿的幸福。在這樣的一天結束時，我真心感激生命中的每一個美好時刻，感覺自己的心裡充滿了愛和感恩。』」";
    String userDiary = "我寫了一篇日記：${diaryMessage}";
    return userDiary;
  }
  // 將User寫的日記，並傳給助手，等待回覆
  Future<Map<String, String>> sendUserDiaryToAssistant(String diaryContent) async {
    isSending = true;
    await fetchUserData();
    print("傳送日記給小助手...：$diaryContent");
    final response = await http.post(                                                        //     發送HTTP POST請求至後端並等待回應，傳送訊息，並等待回覆
      Uri.parse('http://10.0.2.2:5001/send_message_to_python'),                              //       設定請求的URL，指向本地開發環境的Python伺服器
      headers: <String, String>{'Content-Type': 'application/json; charset=utf-8',},         //        設定HTTP請求的標頭，指定內容類型為JSON，編碼為UTF-8
      body: jsonEncode({'user_id': userID,'user_name': userName,'messages': diaryContent})   //       傳送之訊息（將訊息內容包裝為JSON格式並作為請求的body）
    );
    if (response.statusCode == 200) {                                                        //     成功收到回覆（如果HTTP回應狀態碼為200，表示請求成功）
      final jsonresponseDecoded = jsonDecode(response.body);                                 //     將回應的body從JSON格式解碼為Dart物件
      final jsonresponseContent = jsonresponseDecoded["response"] as String;                 //     從解碼後的JSON物件中提取回應內容，這裡假設回應的JSON物件中有一個鍵為"response"
      final responseMessage = {'role': 'assistant', 'content': jsonresponseContent};
      _messages.add({'role': 'user', 'content': "新的日記！"});
      _messages.add(responseMessage);
      print("_message2:$_messages");
      _newMessages++;
      isSending = false;
      notifyListeners();
      return responseMessage;
    }
    else {
      final responseMessage = {'role': 'sys','content': '取得訊息失敗'};
      _newMessages++;
      isSending = false;
      notifyListeners();
      return responseMessage;
    }
  }
}
