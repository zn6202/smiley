import '../../core/app_export.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService(); 
  List<Map<String, String>> messages = [];
  String? imageUrl;
  String? userId; 
  String receiverId = '76'; //seller
  String? perfumeImage;

  @override
  void initState() {
    super.initState();
    initializeData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> initializeData() async {
    await loadSharedPreferencesData();
    if (userId != null ) {
      List<Map<String, dynamic>> fetchedMessages = await _chatService.fetchMessages(userId!, receiverId!);
      setState(() {
        messages = fetchedMessages.map((msg) => {
              'senderId': msg['sender_id'].toString(),
              'message': msg['message']?.toString() ?? '',
              'timestamp': msg['timestamp']?.toString() ?? '',
            }).toList();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  Future<void> loadSharedPreferencesData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id');
      perfumeImage = prefs.getString('perfumeImage');

    });
    print('聊天對象為 $receiverId');
    print('User ID: $userId');
    print('商家頭貼為：$perfumeImage');
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty && userId != null && receiverId != null) {
      setState(() {
        messages.add({'senderId': userId!, 'message': _controller.text});
      });
      _chatService.sendMessage(userId!, receiverId!, _controller.text);
      print('輸入內容: ${_controller.text}');
      _controller.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F4E6),
      body: Stack(
        children: [
          // 背景圖片
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/chatBack.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 左上返回按鈕
          Positioned(
            top: 40.0.v,
            left: 16.0.v,
            child: IconButton(
              icon: Image.asset('assets/images/arrow-left-g.png', color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.homeScreen);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.v),
            child: Align(
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.v),
                ),
                width: 344.v,
                height: MediaQuery.of(context).size.height * 0.65.v,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final sender = messages[index]['senderId'].toString();
                          final message = messages[index]['message'] ?? '';
                          final isCurrentUser = sender == userId;
                          return ListTile(
                            leading: isCurrentUser
                                ? null
                                : CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: _buildChosenIcon(sender),
                                  ),
                            subtitle: Row(
                              mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                              children: [
                                Container(
                                  constraints: BoxConstraints(maxWidth: 205.v),
                                  padding: EdgeInsets.symmetric(vertical: 10.v, horizontal: 15.v),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFA7BA89)),
                                    borderRadius: BorderRadius.circular(30.v),
                                    color: isCurrentUser ? Colors.white : const Color(0xFFA7BA89),
                                  ),
                                  child: Text(
                                    message,
                                    style: TextStyle(
                                      color: isCurrentUser ? Color(0xFFA7BA89) : Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0.v),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Color.fromARGB(255, 218, 218, 218), width: 2.v),
                          borderRadius: BorderRadius.circular(20.v),
                          color: Colors.white.withOpacity(0.8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(left: 20.0.v),
                                  border: InputBorder.none,
                                  hintText: '輸入回覆',
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 164, 164, 164),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Image.asset('assets/images/img_send.png'),
                              onPressed: _sendMessage,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 選頭貼
  Widget _buildChosenIcon(String sender) {
    switch (sender) {
      case '76': // 商家
        if (perfumeImage != null && perfumeImage!.isNotEmpty) {
          // 使用網絡圖片
          return Image.network(
            'http://163.22.32.24/smiley_backend/img/angel/$perfumeImage',
            errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return CircularProgressIndicator();
            },
          );
        } else {
          // 使用占位符
          return Image.asset('assets/images/placeholder.png');
        }
      case 'sys':
        return const Icon(Icons.error);
      default: // 用戶
        return imageUrl != null
            ? Image.network(imageUrl!)
            : Image.asset('assets/images/Lightning.png');
    }
  }
}

class ChatService {
  // 把訊息紀錄到資料庫
  Future<void> sendMessage(String senderId, String receiverId, String message) async {
    try {
      final response = await http.post(
        Uri.parse('http://163.22.32.24/send_message'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "sender_id": senderId,
          "receiver_id": receiverId,
          "message": message,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("訊息發送成功，發送者：${senderId}，接收者：${receiverId}，內容：${message}");
      } else {
        print('Failed to send message. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }
  //取得聊天紀錄
  Future<List<Map<String, dynamic>>> fetchMessages(String senderId, String receiverId) async {
    print('聊天紀錄載入中...');
    List<Map<String, dynamic>> messages = [];

    try {
      final response = await http.post(
        Uri.parse('http://163.22.32.24/get_messages'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "sender_id": senderId,
          "receiver_id": receiverId,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        messages = List<Map<String, dynamic>>.from(responseData['data']);
        print('Fetched Messages: $messages');
      } else {
        print('Failed to load messages. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching messages: $e');
    }

    return messages;
  }
}
