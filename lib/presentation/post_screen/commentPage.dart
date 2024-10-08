// commentPage.dart
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smiley/core/app_export.dart';
import 'package:smiley/presentation/post_screen/browsePage.dart';
import '../../widgets/bottom_navigation.dart';
import 'FallingEmojiComment.dart';
// http
import 'package:http/http.dart' as http;
import '../../routes/api_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CommentPage extends StatefulWidget {
  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  Color backgroundColor = Color(0xFFF4F4E6);
  Color textColor = Color(0xFF4C543E);
  String? postImage = "";
  String? postContent = "";
  // final comments = "";
  // final replies = "";

  @override
  void initState() {
    super.initState();
    fetchPostImage();
    fetchComments();
    fetchReplies();
  }

  TextEditingController _replyController = TextEditingController();
  FocusNode _focusNode = FocusNode();

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<String?> getPostId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('postId');
  }

  void submitReply(int postId, String content, int pos) async {
    final String? userId = await getUserId();

    print("進入提交評論函式");
    print('user_id: $userId');
    print('post_id: $postId'); //
    print("提交回覆: $content");
    print("回覆的對象評論 id 為: $pos"); //

    final response = await http.post(
      Uri.parse(API.submitReply),
      body: {
        'user_id': userId.toString(),
        'post_id': postId.toString(),
        'content': content,
        'pos': pos.toString(),
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      if (data['success'] == true) {
        print("回覆提交已完成是 : ${data}");
      } else {
        print('回覆提交未完成... $data');
      }
    } else {
      print('提交評論失敗...');
    }
  }

  // 假設的函數用於從資料庫讀取貼文照片
  Future<String?> fetchPostImage() async {
    final String? postId = await getPostId();
    print("進入留言獲取天使怪獸函式");
    print('post_id: $postId');

    final response = await http.post(
      Uri.parse(API.getCommentAngMon),
      body: {
        'post_id': postId.toString(),
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      if (data['success'] == true) {
        print("天使怪獸是 : ${data['image']} 貼文內容是 : ${data['content']}");
        print(
            "文字顏色是 : ${data['text_color']} 貼文顏色是 : ${data['background_color']}");
        setState(() {
          postImage = data['image'];
          postContent = data['content'];
          textColor = Color(int.parse(data['text_color']));
          backgroundColor = Color(int.parse(data['background_color']));
        });
        return data['image'];
      } else {
        print('進入留言獲取天使怪獸失敗... ${data['message']}');
      }
    } else {
      print('進入留言獲取天使怪獸失敗...');
    }
    return null;
    // return "https://via.placeholder.com/152x138";
  }

  // 假設的函數用於從資料庫讀取留言數據
  Future<List<Comment>> fetchComments() async {
    final String? postId = await getPostId();
    final String? userId = await getUserId();
    print("進入看別人給我的留言函式");
    print('user_id: $userId post_id: $postId');

    final response = await http.post(
      Uri.parse(API.getComment),
      body: {
        'user_id': userId,
        'post_id': postId,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      if (data['success'] == true) {
        List<dynamic> commentsJson = data['comments'];
        print("data['comments'] 是 : ${commentsJson.toString()}");
        return commentsJson.map((json) => Comment.fromJson(json)).toList();
      } else if (data['success'] == false &&
          data['message'] == "No posts found for the given user and date.") {
        print('無留言... ${data['message']}');
        return [];
      } else {
        print('留言瀏覽失敗... ${data['message']}');
        return [];
      }
    } else {
      print('貼文瀏覽失敗...');
      return [];
    }
  }

  Future<List<Reply>> fetchReplies() async {
    final String? postId = await getPostId();
    final String? userId = await getUserId();
    print("進入回別人給我的留言函式");
    print('user_id: $userId post_id: $postId');

    final response = await http.post(
      Uri.parse(API.getReply),
      body: {
        'user_id': userId,
        'post_id': postId,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      if (data['success'] == true) {
        List<dynamic> repliesJson = data['comments'];
        print("data['replies'] 是 : ${repliesJson.toString()}");
        return repliesJson.map((json) => Reply.fromJson(json)).toList();
      } else if (data['success'] == false &&
          data['message'] == "No posts found for the given user and date.") {
        print('無回覆留言... ${data['message']}');
        return [];
      } else {
        print('回覆留言失敗... ${data['message']}');
        return [];
      }
    } else {
      print('回覆留言失敗...');
      return [];
    }
  }

// 留言發送成功提示
  void showSnackBar(String message) {
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Center(
        child: Container(
          width: 100,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            message,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              decoration: TextDecoration.none,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
    overlayState?.insert(overlayEntry);
    // 顯示時長
    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  void _showReplyDialog(String text, String Url, int postId, int pos) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // 确保底部弹窗背景是透明的
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets, // To handle the keyboard
          child: Container(
            color: Colors.transparent, // 确保背景是透明的
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: textColor,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Column(
                      children: [
                        Row(
                          // 回副的那則留言
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                  'http://163.22.32.24/smiley_backend/img/photo/${Url}'),
                              radius: 24.0,
                            ),
                            SizedBox(width: 10.0),
                            Text(
                              text,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.v), // 上方間距
                        Divider(
                          color: const Color.fromARGB(255, 0, 0, 0), // 線條顏色
                          thickness: 1, // 線條厚度
                        ),
                        SizedBox(height: 10.0),
                        TextField(
                          // 输入框
                          controller: _replyController,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            hintText: '輸入回覆',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.send),
                              onPressed: () {
                                String content = _replyController.text;
                                submitReply(postId, content, pos);
                                showSnackBar("留言已發送");
                                Navigator.pop(context);
                                //  fetchComments(_currentPostId);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      // 重置输入框内容
      _replyController.clear();
    });

    Future.delayed(Duration(milliseconds: 100), () {
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    // final int? postId = ModalRoute.of(context)?.settings.arguments as int?;

    return Scaffold(
      backgroundColor: backgroundColor, // 設置整體背景色
      body: Stack(
        children: [
          // 貼文照片
          Positioned(
            top: 55,
            left: (MediaQuery.of(context).size.width - 152) / 2,
            child: GestureDetector(
              onTap: () {
                // Navigator.pushNamed(context, AppRoutes.browsePage); // 原本的
                Navigator.pop(
                    context); // 點頭貼會跳錯貼文，所以改成這個試試看~ pop 回上一頁的時候，ui 的 icon 數字要變
              },
              child: Container(
                width: 152,
                height: 138,
                decoration: BoxDecoration(
                  image: postImage != null && postImage!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(postImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: postImage == null || postImage!.isEmpty
                      ? Colors.grey[300] // 顯示占位顏色
                      : null,
                ),
                child: postImage == null || postImage!.isEmpty
                    ? Icon(Icons.image, size: 50, color: Colors.grey)
                    : null,
              ),
            ),
          ),
          // 貼文內容
          Positioned(
            top: 213, // 55 + 138 + 20
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 300,
                child: Text(
                  postContent ?? '',
                  style: TextStyle(
                    color: textColor, //標題顏色
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 23 / 18,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          // 留言部分
          Positioned(
            top: 286,
            left: (MediaQuery.of(context).size.width - 350) / 2,
            right: (MediaQuery.of(context).size.width - 350) / 2,
            child: SizedBox(
              height: 500, // 設定固定的高度
              child: FutureBuilder<List<Comment>>(
                future: fetchComments(), // 等待 fetchComments() 的結果
                builder: (context, commentsSnapshot) {
                  if (commentsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator()); // 加載中
                  } else if (commentsSnapshot.hasError) {
                    return Center(
                        child:
                            Text('發生錯誤：${commentsSnapshot.error}')); // 顯示錯誤信息
                  } else if (!commentsSnapshot.hasData ||
                      commentsSnapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        '沒有留言',
                        style: TextStyle(color: textColor),
                      ), // 沒有評論和回覆，顯示「沒有留言」
                    );
                  }

                  final comments = commentsSnapshot.data!;

                  // 獲取回覆
                  return FutureBuilder<List<Reply>>(
                    future: fetchReplies(), // 等待 fetchReplies() 的結果
                    builder: (context, repliesSnapshot) {
                      if (repliesSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                            child: CircularProgressIndicator()); // 加載中
                      } else if (repliesSnapshot.hasError) {
                        return Center(
                            child: Text(
                                '發生錯誤：${repliesSnapshot.error}')); // 顯示錯誤信息
                      } else if (!repliesSnapshot.hasData ||
                          (repliesSnapshot.data!.isEmpty && comments.isEmpty)) {
                        return Center(
                          child: Text(
                            '沒有留言',
                            style: TextStyle(color: textColor),
                          ), // 沒有評論和回覆，顯示「沒有留言」
                        );
                      }

                      final replies = repliesSnapshot.data!;

                      // 確認回覆資料是否正確獲取
                      print('獲取到的回覆資料:');
                      for (var reply in replies) {
                        print('回覆: pos = ${reply.pos}, 內容 = ${reply.text}');
                      }

                      // 創建一個 Map，將評論 ID 與其對應的回覆列表關聯
                      Map<int, List<Reply>> repliesMap = {};
                      for (var reply in replies) {
                        if (repliesMap.containsKey(reply.pos)) {
                          repliesMap[reply.pos]!.add(reply);
                        } else {
                          repliesMap[reply.pos] = [reply];
                        }
                      }

                      // 印出回覆 map 的 key 值（即 pos），以確保 map 正確建立
                      print('建立的回覆 map keys (評論 pos): ${repliesMap.keys}');
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        itemCount: comments.length, // 只計算評論數量
                        itemBuilder: (context, index) {
                          final comment = comments[index];

                          // 印出每個評論的 pos
                          print(
                              '顯示評論: pos = ${comment.pos}, 內容 = ${comment.text}');
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 顯示評論
                                InkWell(
                                  onTap: () => _showReplyDialog(
                                      comment.text ?? '',
                                      comment.avatarUrl ?? '',
                                      comment.postId,
                                      comment.pos),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: 235, // 設置最大寬度為 235
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: textColor, // 評論框背景
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6.18),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 29,
                                                  height: 29,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                          'http://163.22.32.24/smiley_backend/img/photo/${comment.avatarUrl!}'),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Flexible(
                                                  child: Text(
                                                    comment.text ?? '',
                                                    style: TextStyle(
                                                      color:
                                                          backgroundColor, // 評論字
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                ),

                                // 顯示與此評論相關的回覆
                                if (repliesMap.containsKey(comment.pos)) ...[
                                  const SizedBox(height: 8), // 留些間距
                                  for (var reply in repliesMap[comment.pos]!)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 35),
                                      child: InkWell(
                                        onTap: () => _showReplyDialog(
                                            reply.text ?? '',
                                            reply.avatarUrl ?? '',
                                            reply.postId,
                                            reply.pos),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.reply,
                                                size: 36,
                                                color:
                                                    textColor.withOpacity(0.8)),
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: 235, // 設置最大寬度為 235
                                              ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: textColor, // 回復框背景
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6.18),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: 29,
                                                      height: 29,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        image: DecorationImage(
                                                          image: NetworkImage(
                                                              'http://163.22.32.24/smiley_backend/img/photo/${reply.avatarUrl!}'),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Flexible(
                                                      child: Text(
                                                        reply.text ?? '',
                                                        style: TextStyle(
                                                          color:
                                                              backgroundColor, // 回覆字顏色
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ]
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 我的回覆
class Reply {
  final int id;
  final int userId;
  final int postId;
  final int postUserId;
  final int? emojiId;
  final String? text;
  final int pos;
  final String? avatarUrl;

  Reply({
    required this.id,
    required this.userId,
    required this.postId,
    required this.postUserId,
    this.emojiId,
    this.text,
    required this.pos,
    this.avatarUrl,
  });
  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      id: json['id'] != null ? json['id'] as int : 0, // 默認值為 0
      userId: json['user_id'] != null ? json['user_id'] as int : 0, // 默認值為 0
      postId: json['post_id'] != null ? json['post_id'] as int : 0, // 默認值為 0
      postUserId: json['post_user_id'] != null
          ? json['post_user_id'] as int
          : 0, // 默認值為 0
      emojiId: json['emoji_id'] as int,
      text: json['content'] as String,
      pos: json['pos'] != null ? json['pos'] as int : 0, // 默認值為 0
      avatarUrl: json['avatar_url'] as String,
    );
  }
}

// 別人的留言
class Comment {
  final int id;
  final int userId;
  final int postId;
  final int postUserId;
  final int? emojiId;
  final String? text;
  final int pos;
  final String? avatarUrl;

  Comment({
    required this.id,
    required this.userId,
    required this.postId,
    required this.postUserId,
    this.emojiId,
    this.text,
    required this.pos,
    this.avatarUrl,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] != null ? json['id'] as int : 0, // 默認值為 0
      userId: json['user_id'] != null ? json['user_id'] as int : 0, // 默認值為 0
      postId: json['post_id'] != null ? json['post_id'] as int : 0, // 默認值為 0
      postUserId: json['post_user_id'] != null
          ? json['post_user_id'] as int
          : 0, // 默認值為 0
      emojiId: json['emoji_id'] as int,
      text: json['content'] as String,
      pos: json['pos'] != null ? json['pos'] as int : 0, // 默認值為 0
      avatarUrl: json['avatar_url'] as String,
    );
  }
}

