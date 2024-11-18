import '../../core/app_export.dart';
const Color backgroundColor = Color(0xFFF4F4E6);

// 小助手聊天室視窗
class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({Key? key}) : super(key: key);
  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

// 設定小助手聊天室視窗
class _ChatBotScreenState extends State<ChatBotScreen> {
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController(); // 控制畫面滑動
  final TextEditingController _controller = TextEditingController(); // 文字輸入欄
  List<Map<String, String>> _messages = []; // 聊天紀錄

  // 初始化載入聊天室
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _scrollToBottom()); // 確保畫面構建完成後執行滾動
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // 使用者傳送訊息
  void _sendMessage(MessageProvider messageProvider) {
    if (_controller.text.isNotEmpty) {
      // 若輸入攔不為空白則傳送
      setState(() {
        _messages.add({
          'role': 'user', //   使用者名稱
          'content': _controller.text
        }); //   使用者的訊息
        messageProvider.sendDataToPython(_controller.text); //   將訊息傳送給Python機器人後端
        _controller.clear(); //   清空輸入攔
        messageProvider.isSending = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(messageProvider);
      });
    }
  }

  // 滑到聊天室最底層
  // 將 MessageProvider? messageProvider 放入方括號中，使其成為可選參數，這樣我們在需要 _scrollToBottom 但不打算使用 messageProvider 的地方，仍可以不傳入 messageProvider
  void _scrollToBottom([MessageProvider? messageProvider]) {
    // 檢查控制器是否可以滾動
    if (_scrollController.hasClients) {
      // 滑動動畫
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent, // 滑到最底
        duration: const Duration(milliseconds: 300), // 滑動時間
        curve: Curves.easeOut, // 淡出滑動
      ).then((_) {
        // 動畫完成後才將 messageProvider.newMessage 設為 false
        if (mounted && messageProvider != null) { // 確保 widget 還存在
          setState(() {
            messageProvider.newMessage = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: EdgeInsets.only(top: 69.v),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 標題框
            // SizedBox(height: 37.v),
            // // 暫時日記按鈕
            // Consumer<MessageProvider>(                                  // 當接收到機器人回覆時刷新介面，拉到最底部
            //   builder: (context, messageProvider, child) {
            //     return Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Container(
            //           width: 100,
            //           height: 40,
            //           decoration: BoxDecoration(
            //             color: Color.fromARGB(255, 255, 255, 255),
            //             borderRadius: BorderRadius.circular(20),
            //           ),
            //           alignment: Alignment.center,
            //           child: Text(
            //             "小助手",
            //             style: TextStyle(
            //               fontSize: 18,
            //               fontWeight: FontWeight.w700,
            //               color: Color(0xFF545453),
            //             ),
            //             textAlign: TextAlign.center,
            //           ),
            //         ),
            //         OutlinedButton(
            //           child: Text("取得日記"),
            //           onPressed: () {
            //             _sendDiary(messageProvider);
            //           },
            //         ),
            //       ],
            //     );
            //   },
            // ),
            // Center(
            //   child: Container(
            //     width: 100,
            //     height: 40,
            //     decoration: BoxDecoration(
            //       color: Color.fromARGB(255, 255, 255, 255),
            //       borderRadius: BorderRadius.circular(20),
            //     ),
            //     alignment: Alignment.center,
            //     child: Text(
            //       "小助手",
            //       style: TextStyle(
            //         fontSize: 18,
            //         fontWeight: FontWeight.w700,
            //         color: Color(0xFF545453),
            //       ),
            //       textAlign: TextAlign.center,
            //     ),
            //   ),
            // ),
            // 聊天欄
            // SizedBox(height: 32.v),
            Center(
              // 聊天室框
              child: Container(
                width: 330.h,
                height: 641.v,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                // 對話
                child: Container(
                  child: Consumer<MessageProvider>(
                    // 當接收到機器人回覆時刷新介面，拉到最底部
                    builder: (context, messageProvider, child) {
                      Future.microtask(() => messageProvider.clearUnread()); // Clear unread messages
                      // 當 messageProvider 變化時，更新 _messages 並刷新 UI
                      // if (_messages != messageProvider.messages) {
                      _messages = messageProvider.messages;
                      if (_scrollController.hasClients && messageProvider.newMessage == true){
                        if (_scrollController.offset < _scrollController.position.maxScrollExtent-5){
                          _scrollToBottom(messageProvider);
                        }
                      }
                      // print("_scrollController.offset=${_scrollController.offset}");
                      // print("_scrollController.position.maxScrollExtent=${_scrollController.position.maxScrollExtent}");
                      // print("messageP=${messageProvider.newMessage}");
                      return Column(
                        children: [
                          Expanded(
                            // 每當傳送或收到訊息時，將對話新增在聊天室
                            child: ListView.builder(
                              // 新建一個ListView
                              controller: _scrollController,   //     滑動控制器
                              itemCount:_messages.length,      //     訊息總數（ListView長度）
                              itemBuilder: (context, index) {
                                // 設定ListView內容物
                                final sender =_messages[index]['role']!;      //    訊息的傳送者
                                final message = _messages[index]['content']!; //    傳送者的訊息
                                String senderName = "";
                                Widget? chosenIcon;                                 // 判斷訊息的傳送者為誰
                                switch (sender) {
                                  //     根據不同傳送者為(使用者, 小助手, 系統訊息)，設定訊息頭像
                                  case 'assistant':
                                    chosenIcon = Image.asset(
                                      'assets/images/chatBot.png',
                                    );
                                    senderName = "小蜜";
                                    break;
                                  case 'sys':
                                    chosenIcon = const Icon(Icons.error);
                                    senderName = "系統訊息";
                                    break;
                                  default:
                                    chosenIcon = null;
                                    break;
                                }
                                return ListTile(
                                  // 用ListTile來編輯ListView
                                  leading: CircleAvatar(
                                    //    傳送者頭像
                                    backgroundColor:
                                      Color.fromARGB(255, 255, 255, 255),
                                    child: chosenIcon,
                                  ),
                                  // title: Text(senderName,
                                  //   style: const TextStyle(
                                  //     fontSize: 16,
                                  //     fontWeight: FontWeight.normal)),    //      傳送者名稱
                                  // 傳送者訊息框
                                  subtitle: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // 主軸排列方式：兩端對齊
                                    children: [
                                      sender == "user"
                                          ? Expanded(
                                              child: Container(
                                              alignment: Alignment.centerRight,
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                    top: 10.v,
                                                    bottom: 10.v,
                                                    left: 15.h,
                                                    right: 15.h),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: const Color(
                                                          0xFFA7BA89)),
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  color:
                                                      const Color(0xFFFFFFFF),
                                                ),
                                                child: Text(message,
                                                  style: const TextStyle(
                                                    color:
                                                        Color(0xFFA7BA89),
                                                    fontSize: 18,
                                                    fontWeight:FontWeight.normal)),
                                              ),
                                            ))
                                          : Container(
                                            constraints:
                                              BoxConstraints(maxWidth: 205),
                                            padding: EdgeInsets.only(
                                                top: 10.0,
                                                bottom: 10.0,
                                                left: 15.0,
                                                right: 15.0),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFA7BA89),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: Text(message,
                                              style: const TextStyle(
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                                fontSize: 18,
                                                fontWeight:FontWeight.normal)),
                                            ),
                                    ], // Children
                                  ),
                                );
                              },
                            ),
                          ),
                          // SizedBox(height: 15),
                          // 輸入回覆列
                          Padding(
                            padding: EdgeInsets.all(30.0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color.fromARGB(
                                    255, 164, 164, 164)),
                                borderRadius: BorderRadius.circular(30),
                                color: messageProvider.isSending == true
                                  ? Color.fromARGB(255, 255, 213, 0)
                                  : const Color(0xFFFFFFFF),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: messageProvider.isSending == true
                                      ? TextField(
                                        // 建立文字輸入框
                                        enabled: false,
                                        textAlign: TextAlign.center,
                                        controller:_controller, //     文字輸入內容
                                        decoration: const InputDecoration(
                                          //     輸入框裝飾模樣
                                          border: InputBorder.none,
                                          hintText:
                                              '等待回覆...', //       提示訊息
                                          hintStyle: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 164, 164, 164),
                                              fontSize: 18,
                                              fontWeight:
                                                  FontWeight.normal)),
                                          )
                                        : TextField(
                                          // 建立文字輸入框
                                          enabled: true,
                                          textAlign: TextAlign.center,
                                          controller:
                                              _controller, //     文字輸入內容
                                          decoration: const InputDecoration(
                                            //     輸入框裝飾模樣
                                            border: InputBorder.none,
                                            hintText: '輸入訊息', //       提示訊息
                                            hintStyle: TextStyle(
                                              color: Color.fromARGB(255, 164, 164, 164),
                                              fontSize: 18,
                                              fontWeight: FontWeight.normal)),
                                          ),
                                  ),
                                  messageProvider.isSending == true
                                    ? Container()
                                    : IconButton(
                                      // 傳送訊息按鈕(Icon)
                                      icon: Image.asset('assets/images/img_send.png'), //     按鈕圖案
                                      onPressed: () {
                                        _sendMessage( messageProvider); //       顯示使用者訊息在聊天室
                                      }),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
