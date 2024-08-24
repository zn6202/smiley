// commentPage.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smiley/core/app_export.dart';
import '../../widgets/bottom_navigation.dart';
import 'FallingEmojiComment.dart';
// http
import 'package:http/http.dart' as http;
import '../../routes/api_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


// class CommentPage extends StatefulWidget {
//   @override
//   _CommentPageState createState() => _CommentPageState();
// }

class CommentPage extends StatefulWidget {
  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {

  Color backgroundColor = Color(0xFFF4F4E6);
  Color textColor = Color(0xFF4C543E);

  @override
  Widget build(BuildContext context) {
    final postImage = fetchPostImage();
    final postContent = fetchPostContent();
    final comments = fetchComments();
    final replies = fetchReplies();

    return Scaffold(
      body: Stack(
        children: [
          // 貼文照片
          Positioned(
            top: 55,
            left: (MediaQuery.of(context).size.width - 152) / 2,
            child: Container(
              width: 152,
              height: 138,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(postImage),
                  fit: BoxFit.cover,
                ),
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
                  postContent,
                  style: TextStyle(
                    color: textColor,
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
            child: Container(
              width: 320,
              height: 500,
              child: ListView.builder(
                itemCount: comments.length + replies.length,
                itemBuilder: (context, index) {
                  if (index < comments.length) {
                    final comment = comments[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 别人的留言气泡（左侧）
                          Flexible(
                            child: Container(
                              width:237,
                              decoration: BoxDecoration(
                                color:textColor, // 气泡背景色
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6.18),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // 对方的头像
                                  Container(
                                    width: 29,
                                    height: 29,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: NetworkImage(comment.avatarUrl), // 头像的链接
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      comment.text,
                                      style: TextStyle(
                                        color: backgroundColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    final reply = replies[index - comments.length];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 你的回复气泡（右侧）
                          Flexible(
                            child: Container(
                              width: 237,
                              decoration: BoxDecoration(
                                color: textColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6.18), // 調整 padding
                              child: Row( // 使用 Row 來水平排列大頭貼和文字
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // 第一張大頭貼
                                  Container(
                                    width: 29, // 設置大頭貼的寬度
                                    height: 29,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: NetworkImage(reply.avatarUrl), // 第一張大頭貼的連結
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10), // 大頭貼之間的間隔
                                  // 第二張大頭貼
                                  Container(
                                    width: 29,
                                    height: 29,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: NetworkImage(reply.avatarUrl), // 第二張大頭貼的連結
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10), // 大頭貼和文字之間的間隔
                                  // 文字
                                  Flexible(
                                    child: Text(
                                      reply.text,
                                      style: TextStyle(
                                        color: backgroundColor,
                                        fontSize: 15, // 調整文字大小
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 假設的函數用於從資料庫讀取貼文照片
String fetchPostImage() {
  return "https://via.placeholder.com/152x138";
}

// 假設的函數用於從資料庫讀取貼文顏色
Color fetchTextColor() {
  return Color(0xFFFF53FF);
}

// 假設的函數用於從資料庫讀取貼文內容
String fetchPostContent() {
  return "陽光特別明亮，讓人忍不住想要好好開始這一天。可是，隨著時間的推移，內心卻慢慢被一些說不上來的不安和焦慮感包圍...";
}

// 假設的函數用於從資料庫讀取留言數據
List<Comment> fetchComments() {
  return [
    Comment(
      avatarUrl: "https://via.placeholder.com/29",
      text: "這是第一則留言",
    ),
    Comment(
      avatarUrl: "https://via.placeholder.com/29",
      text: "這是第二則留言，可能會比較長一些1111111111。",
    ),
    // 更多留言...
  ];
}

List<Reply> fetchReplies() {
  return [
    Reply(
      avatarUrl: "https://via.placeholder.com/40",
      text: "這是我的第一則回覆。",
    ),
    Reply(
      avatarUrl: "https://via.placeholder.com/40",
      text: "這是我的第二則回覆，可能會比較長一些。",
    ),
    Reply(
      avatarUrl: "https://via.placeholder.com/40",
      text: "這是我的第三則回覆，可能會比較長一些。",
    ),
    // 更多回覆...
  ];
}

// 我的回覆
class Reply {
  final String avatarUrl;
  final String text;

  Reply({
    required this.avatarUrl,
    required this.text,
  });
}

// 別人的留言
class Comment {
  final String avatarUrl;
  final String text;

  Comment({
    required this.avatarUrl,
    required this.text,
  });
}
