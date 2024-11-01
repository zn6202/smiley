import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_export.dart';
import '../../routes/api_connection.dart';

class MessageProvider with ChangeNotifier {
  List<Map<String, String>> _messages = [];
  int _newMessages = 0;
  String userID = "";
  String userName = 'User';
  bool isSending = false;

  List<Map<String, String>> get messages => _messages;
  int get newMessages => _newMessages;

  void clearUnread() {
    _newMessages = 0;
    notifyListeners();
  }

  void updateUnreadMsg(int value) {
    _newMessages = value;
    notifyListeners();
  }

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<void> _fetchUserData() async {
    final String? id = await _getUserId();
    if (id == null) {
      print('Error: user_id is null');
      return;
    }
    try {
      final response = await http.post(
        Uri.parse(API.getProfile),
        body: {'id': id},
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success']) {
          userID = id;
          userName = responseData['name'];
        } else {
          print('使用者名稱取得失敗: ${responseData['message']}');
        }
      } else {
        print('使用者名稱取得失敗...');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> fetchWelcomeMessage() async {
    await _fetchUserData();
    try {
      final response = await http.post(
        Uri.parse('http://163.22.32.24/welcome'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({'user_id': userID, 'user_name': userName}),
      );
      if (response.statusCode == 200) {
        final jsonResponseDecoded = jsonDecode(response.body);
        final jsonResponseContent = jsonResponseDecoded["response"] as String;
        final responseMessage = {
          'role': 'assistant',
          'content': jsonResponseContent
        };
        _messages.add(responseMessage);
        _newMessages += 1;
        updateUnreadMsg(_newMessages);
      } else {
        _handleError();
      }
    } catch (e) {
      print('Error fetching welcome message: $e');
      _handleError();
    }
  }

  Future<Map<String, String>> sendDataToPython(String messageContent) async {
    await _fetchUserData();
    // _addMessage(responseMessage);
    try {
      final response = await http.post(
        Uri.parse('http://163.22.32.24/send_message_to_python'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          'user_id': userID,
          'user_name': userName,
          'messages': messageContent
        }),
      );
      if (response.statusCode == 200) {
        final jsonResponseDecoded = jsonDecode(response.body);
        final jsonResponseContent = jsonResponseDecoded["response"] as String;
        final assistantMessage = {
          'role': 'assistant',
          'content': jsonResponseContent
        };
        _messages.add(assistantMessage);
        _newMessages += 1;
        updateUnreadMsg(_newMessages);
        return assistantMessage;
      } else {
        _handleError();
      }
    } catch (e) {
      print('Error sending data to Python: $e');
      _handleError();
    }
    return {'role': 'sys', 'content': '取得訊息失敗'};
  }

  String getUserDiary(String diaryMessage) {
    return "我寫了一篇日記：${diaryMessage}";
  }

  Future<Map<String, String>> sendUserDiaryToAssistant(
      String diaryContent) async {
    isSending = true;
    await _fetchUserData();
    print("傳送日記給小助手...：$diaryContent");
    try {
      final response = await http.post(
        Uri.parse('http://163.22.32.24:5001/send_message_to_python'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          'user_id': userID,
          'user_name': userName,
          'messages': diaryContent
        }),
      );
      if (response.statusCode == 200) {
        final jsonResponseDecoded = jsonDecode(response.body);
        final jsonResponseContent = jsonResponseDecoded["response"] as String;
        final assistantMessage = {
          'role': 'assistant',
          'content': jsonResponseContent
        };
        _messages.add({'role': 'user', 'content': "新的日記！"});
        _newMessages += 1;
        updateUnreadMsg(_newMessages);
        // _addMessage(assistantMessage);
        return assistantMessage;
      } else {
        _handleError();
      }
    } catch (e) {
      print('Error sending user diary to assistant: $e');
      _handleError();
    }
    return {'role': 'sys', 'content': '取得訊息失敗'};
  }

  // void _addMessage(Map<String, String> message) {
  //   _messages.add(message);
  //   _newMessages++;
  //   isSending = false;
  //   notifyListeners();
  // }

  void _handleError() {
    final errorMessage = {'role': 'sys', 'content': '取得訊息失敗'};
    _messages.add(errorMessage);
    // _addMessage(errorMessage);
  }
}
