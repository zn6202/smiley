import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MessageProvider with ChangeNotifier {
  List<Map<String, dynamic>> _messages = [];
  int currentUserId = 1; // 模擬當前使用者 ID
  int receiverId = 2; // 模擬接收者 ID

  List<Map<String, dynamic>> get messages => _messages;

  // 從後端抓取最近 30 筆聊天紀錄
  Future<void> fetchChatHistory() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/get_messages?sender_id=1&receiver_id=2'));
      if (response.statusCode == 200) {
        _messages = List<Map<String, dynamic>>.from(json.decode(response.body));
        notifyListeners();
      } else {
        print('Failed to load chat history');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // 發送訊息到後端
  Future<void> sendMessage(String messageContent) async {
    final newMessage = {
      'sender_id': currentUserId,
      'receiver_id': receiverId,
      'message': messageContent,
      'timestamp': DateTime.now().toIso8601String(),
      'is_read': false,
    };

    _messages.add(newMessage);
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/send-message'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newMessage),
      );

      if (response.statusCode != 200) {
        print('Failed to send message');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
