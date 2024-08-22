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
  // Color textColor = Color(0xFF4C543E);
  Color backgroundColor = Color(0xFFF4F4E6);
  Color textColor = Color(0xFF4C543E);
  int selectedColor = 0xFFF4F4E6;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // 假設這些函數用於從資料庫中讀取數據
    final postImage = fetchPostImage(); // 讀取貼文照片
    // final postColor = fetchPostColor(); // 讀取貼文顏色
    final postContent = fetchPostContent(); // 讀取貼文內容
    final comments = fetchComments(); //從資料庫中讀取留言數據

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
            top: 55 + 138 + 20, // 貼文照片下方 + 間距
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 320,
                child: Text(
                  postContent,
                  style: TextStyle(
                    color: textColor, // 貼文內容顏色
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 23 / 18, // 調整行高
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          // 留言部分
          Positioned(
            top: 286, // 留言區域的起始位置
            left: 11,
            right: 235,
            bottom: 514,
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return Container(
                  width: 144,
                  height: 44,
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  margin: EdgeInsets.only(bottom: 10), // 留言方塊之間的間距
                  decoration: BoxDecoration(
                    color: Colors.white, // 背景顏色
                    borderRadius: BorderRadius.circular(20), // 圓角
                  ),
                  child: Row(
                    children: [
                      // 使用者頭貼
                      Container(
                        width: 29,
                        height: 29,
                        margin: EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300], // 頭貼背景顏色
                          image: DecorationImage(
                            image: NetworkImage(comment.avatarUrl), // 使用者頭貼 URL
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // 留言文字
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                            color: Color(0xFFFF53FF), // 留言文字框背景顏色
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            comment.text,
                            style: TextStyle(
                              color: Colors.black, // 文字顏色
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
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
        text: "這是第二則留言，可能會比較長一些。",
      ),
    ];
  }
}

// 定義一個類來存儲留言數據
class Comment {
  final String avatarUrl;
  final String text;

  Comment({
    required this.avatarUrl,
    required this.text,
  });
}

//       body: Stack(
//         children: [
//           // 顯示留言的部分
//           ListView.builder(
//             padding: EdgeInsets.only(top: 286, bottom: 514, left: 11, right: 235),
//             itemCount: comments.length,
//             itemBuilder: (context, index) {
//               final comment = comments[index];
//               return Container(
//                 width: 144,
//                 height: 44,
//                 padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
//                 margin: EdgeInsets.only(bottom: 10), // 留言方塊之間的間距
//                 decoration: BoxDecoration(
//                   color: Colors.white, // 背景顏色可根據需求修改
//                   borderRadius: BorderRadius.circular(20), // 圓角
//                 ),
//                 child: Row(
//                   children: [
//                     // 使用者頭貼
//                     Container(
//                       width: 29,
//                       height: 29,
//                       margin: EdgeInsets.only(right: 10),
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.grey[300], // 頭貼背景顏色
//                         image: DecorationImage(
//                           image: NetworkImage(comment.avatarUrl), // 使用者頭貼 URL
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                     // 留言文字
//                     Expanded(
//                       child: Container(
//                         padding: EdgeInsets.only(left: 10),
//                         decoration: BoxDecoration(
//                           color: Color(0xFFFF53FF), // 留言文字框背景顏色
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           comment.text,
//                           style: TextStyle(
//                             color: Colors.black, // 文字顏色
//                             fontSize: 14,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 1,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }


//   // 假設的函數用於從資料庫讀取數據
//   String fetchPostImage() {
//     // 從資料庫讀取貼文照片的 URL
//     return "https://via.placeholder.com/152x138";
//   }

//   int fetchPostColor() {
//     // 從資料庫讀取貼文顏色，這裡應該返回顏色的整數值
//     return 0xFF00FF00; // 例如綠色
//   }

//   String fetchPostContent() {
//     // 從資料庫讀取貼文內容
//     return "陽光特別明亮，讓人忍不住想要好好開始這一天。生活就是這樣吧，有起有落，有光明也有陰影。或許，接受這一切，才是面對生活的最好方式。";
//   }

//   // 假設的函數用於從資料庫讀取留言數據
//   List<Comment> fetchComments() {
//     // 返回一個包含留言數據的列表
//     return [
//       Comment(
//         avatarUrl: "https://via.placeholder.com/29",
//         text: "這是第一則留言",
//       ),
//       Comment(
//         avatarUrl: "https://via.placeholder.com/29",
//         text: "這是第二則留言，可能會比較長一些。",
//       ),
//       // 添加更多留言數據...
//     ];
//   }
// }

// // 定義一個類來存儲留言數據
// class Comment {
//   final String avatarUrl;
//   final String text;

//   Comment({
//     required this.avatarUrl,
//     required this.text,
//   });
// }