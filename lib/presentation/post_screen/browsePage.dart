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

class BrowsePage extends StatefulWidget {
  @override
  _BrowsePageState createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  late PageController _mainPageController;
  late Future<List<Post>> _futureMyPosts;
  late Future<List<Post>> _futureFriendsPosts;
  int _currentIndex = 3;
  bool _isViewingFriendsPosts = false;
  int? _selectedCommentIcon;
  String? _commentText = '';
  int _currentPostId = -1;
  int commentSum = 0;

  // FocusNode _commentFocusNode = FocusNode();
  TextEditingController commentsController = TextEditingController(); // 新增的

  final StreamController<List<Comment>> _commentsController =
      StreamController<List<Comment>>.broadcast();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _commentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _mainPageController = PageController();
    _futureMyPosts = fetchMyPosts();
    _futureFriendsPosts = fetchFriendsPosts();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _commentFocusNode.unfocus(); // 确保页面加载时输入框不会自动聚焦
    });

    _futureMyPosts.then((posts) {
      if (posts.isNotEmpty) {
        _currentPostId = posts.first.id;
        fetchComments(_currentPostId);
        fetchCommentSum(_currentPostId); //
      }
    });

    _commentFocusNode.addListener(() {
      if (_commentFocusNode.hasFocus) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void fetchCommentSum(int postId) async {
    print("進入評論數量函式 postId: $postId");

    final response = await http.post(
      Uri.parse(API.getCommentSum), // 解析字串變成 URI 對象
      body: {
        'post_id': postId.toString(),
      },
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['success']) {
        setState(() {
          commentSum = result['count'];
        });
        print("計算成功 $commentSum");
      } else {
        setState(() {
          commentSum = 0;
        });
        print('User not found.');
      }
    } else {
      throw Exception('Failed to load user');
    }
  }

  @override
  void dispose() {
    _mainPageController.dispose();
    _commentsController.close();
    _scrollController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _mainPageController,
        onPageChanged: (index) {
          setState(() {
            _isViewingFriendsPosts = index == 1;
          });
          if (index == 1) {
            _futureFriendsPosts.then((posts) {
              if (posts.isNotEmpty) {
                _currentPostId = posts.first.id;
                fetchComments(_currentPostId);
                fetchCommentSum(_currentPostId);
              }
            });
          } else {
            _futureMyPosts.then((posts) {
              if (posts.isNotEmpty) {
                _currentPostId = posts.first.id;
                fetchComments(_currentPostId);
                fetchCommentSum(_currentPostId);
              }
            });
          }
        },
        children: [
          _buildPostsPage(_futureMyPosts, isMyPosts: true),
          _buildPostsPage(_futureFriendsPosts, isMyPosts: false),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (_currentIndex == 3) {
            if (_isViewingFriendsPosts) {
              _futureFriendsPosts.then((posts) {
                if (posts.isNotEmpty) {
                  _currentPostId = posts.first.id;
                  fetchComments(_currentPostId);
                  fetchCommentSum(_currentPostId);
                }
              });
            } else {
              _futureMyPosts.then((posts) {
                if (posts.isNotEmpty) {
                  _currentPostId = posts.first.id;
                  fetchComments(_currentPostId);
                  fetchCommentSum(_currentPostId);
                }
              });
            }
          }
        },
      ),
    );
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

  Widget _buildPostsPage(Future<List<Post>> futurePosts,
      {required bool isMyPosts}) {
    return FutureBuilder<List<Post>>(
      future: futurePosts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildNoPostsWidget();
        }

        final posts = snapshot.data!;
        return PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: posts.length,
          onPageChanged: (index) {
            final postId = posts[index].id;
            if (postId != _currentPostId) {
              _currentPostId = postId;
              fetchComments(postId);
              fetchCommentSum(postId);
            }
          },
          itemBuilder: (context, index) {
            return _buildPostItem(posts[index], isMyPosts);
          },
        );
      },
    );
  }

  Widget _buildNoPostsWidget() {

    // 獲取台灣當地的日期（UTC+8）
    DateTime now = DateTime.now().toUtc().add(Duration(hours: 8));
    String formattedDate = DateFormat('yyyy.MM.dd').format(now);
    Color textColor = Color(0xFFA7BA89);
    
    return Padding(
      padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 日期
          Padding(
            padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
            child:Text(
            formattedDate,
            style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: textColor,
              ),
            ),
          ),

          SizedBox(height: 30),

          // 圖片和文字
          Center( 
            child: Column(
              children: [
                // 圖片
                Image.asset(
                  'assets/images/noPost.png',
                  width: 200,
                  height: 300,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 26), // 調整圖片和文字之間的間距
                // 文字
                Text(
                  "近三天內沒有新貼文...\n趕快發布貼文讓好友知道你在想甚麼吧！",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostItem(Post post, bool isMyPost) {
    Color textColor = getTextColor(post.backgroundColor);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: post.backgroundColor,
          child: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 50, left: 16, right: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              post.date,
                              style: TextStyle(
                                fontSize: 28, // 調整文本的字體大小
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            Stack(
                              // 右上icon
                              children: [
                                IconButton(
                                  // icon本人
                                  icon: Image.asset(
                                    'assets/images/comments.png',
                                    width: 30, // 調整圖標的大小
                                    height: 30,
                                    color: textColor,
                                  ),
                                  onPressed: () {
                                    savePostId(_currentPostId);
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.commentPage,
                                    ).then((_) {
                                      fetchComments(_currentPostId);
                                      fetchCommentSum(_currentPostId);
                                      FocusScope.of(context).unfocus();
                                    });
                                    ;
                                  },
                                ),
                                if (commentSum != 0)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      // 留言數輛
                                      width: 14, // 調整圓形容器的大小
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: textColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${commentSum}', // 後端回傳的留言數量
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 10, // 調整字體大小
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        // 日記標題
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: Text(
                          post.title,
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (!isMyPost)
                        Padding(
                          padding: const EdgeInsets.only(top: 10, left: 16),
                          child: Container(
                            width: 146,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0x80FFFFFF),
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          'http://163.22.32.24/smiley_backend/img/photo/${post.userPhoto}'),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    post.userName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 40),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            savePostId(_currentPostId);
                            Navigator.pushNamed(
                              context,
                              AppRoutes.commentPage,
                              // arguments: _currentPostId, // 傳遞 _currentPostId 作為 arguments
                            );
                          },
                          child: Image.network(
                            post.monster != null && post.monster!.isNotEmpty
                                ? 'http://163.22.32.24/smiley_backend/img/monster/${post.monster!}'
                                : 'http://163.22.32.24/smiley_backend/img/angel/${post.angel!}',
                            height: 200,
                            width: 200,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Center(
                          child: Text(
                            post.content,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      if (!isMyPost) ...[
                        SizedBox(height: 90),
                        _buildCommentSection(textColor),
                      ],
                      SizedBox(height: 56),
                    ],
                  ),
                ),
                StreamBuilder<List<Comment>>(
                  stream: _commentsController.stream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Container();
                    final comments = snapshot.data!;
                    final random = Random();

                    return Stack(
                      children: comments.map((comment) {
                        final horizontalPosition =
                            random.nextDouble() * constraints.maxWidth;
                        return FallingEmojiComment(
                          emojiId: comment.emojiId ?? 1,
                          screenHeight: constraints.maxHeight,
                          horizontalPosition: horizontalPosition,
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommentSection(Color textColor) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 230,
              height: 33,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCommentIcon = index;
                      });
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_selectedCommentIcon == index)
                          Container(
                            width: 35,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: textColor, width: 2.0),
                            ),
                          ),
                        Image.asset(
                          'assets/images/comments_${index + 1}.png',
                          width: 31.7705,
                          height: 28.71112,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
          SizedBox(height: 5),
          Center(
            child: Container(
              width: 254,
              height: 44,
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      focusNode: _commentFocusNode,
                      decoration: InputDecoration(
                        hintText: "輸入回覆",
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontSize: 18,
                          height: 1.2,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFC5C5C5),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      controller: commentsController,
                      onChanged: (value) {
                        setState(() {
                          _commentText = value;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: textColor),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () {
                      submitComment(_currentPostId, _selectedCommentIcon);
                      fetchComments(_currentPostId);
                      fetchCommentSum(_currentPostId);
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> savePostId(int _currentPostId) async {
    String? postId = _currentPostId.toString();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('postId', postId);
  }

  void submitComment(int postId, int? _selectedCommentIcon) async {
    final String? userId = await getUserId();
    int? emojiId =
        _selectedCommentIcon == null ? null : _selectedCommentIcon + 1;

    print("進入提交評論函式");
    print('user_id: $userId');
    print('post_id: $postId');
    print('emoji_id: $emojiId');
    print("提交評論: $_commentText");

    final response = await http.post(
      Uri.parse(API.submitComment),
      body: {
        'user_id': userId.toString(),
        'post_id': postId.toString(),
        'emoji_id': emojiId.toString() ?? '',
        'content': _commentText ?? '',
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      if (data['success'] == true) {
        print("頻論提交已完成是 : ${data}");
        showSnackBar('留言已發送');
        commentsController.clear();
        // FocusScope.of(context).unfocus();
        // _replyControlle.clear();
        fetchCommentSum(postId);
      } else {
        print('評論提交未完成... $data');
      }
    } else {
      print('提交評論失敗...');
    }
  }

  final List<User> users = const [
    User(
        id: 1,
        name: "AliceAliceAliceAliceAliceAlice",
        photo: "assets/images/default_avatar_1.png"),
    User(id: 2, name: "Bob", photo: "assets/images/default_avatar_2.png"),
  ];

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<List<Post>> fetchMyPosts() async {
    final String? userId = await getUserId();

    print("進入瀏覽自己的貼文函式");
    print('user_id: $userId');

    final response = await http.post(
      Uri.parse(API.getPost),
      body: {
        'user_id': userId!,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      if (data['success'] == true) {
        List<dynamic> postsJson = data['posts'];
        print("data['posts'] 是 : ${postsJson.toString()}");
        return postsJson.map((json) => Post.fromJson(json)).toList();
      } else {
        print('貼文瀏覽失敗... ${data['message']}');
        return [];
      }
    } else {
      print('貼文瀏覽失敗...');
      return [];
    }
  }

  Future<List<Post>> fetchFriendsPosts() async {
    final String? userId = await getUserId();

    print("進入瀏覽好友貼文函式");
    print('user_id: $userId');

    final response = await http.post(
      Uri.parse(API.getFriendsPost),
      body: {
        'user_id': userId!,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      if (data['success'] == true) {
        List<dynamic> postsJson = data['posts'];
        print("data['posts'] 是 : ${postsJson.toString()}");
        return postsJson.map((json) => Post.fromJson(json)).toList();
      } else if (data['success'] == false &&
          data['message'] == "No posts found for the given user and date.") {
        print('無好友發布貼文... ${data['message']}');
        return [];
      } else {
        print('貼文瀏覽失敗... ${data['message']}');
        return [];
      }
    } else {
      print('貼文瀏覽失敗...');
      return [];
    }
  }

  void fetchComments(int postId) async {
    final String? userId = await getUserId();

    print("抓取 emoji_id 函式");
    print('posId 是: $postId userId 是: $userId');

    final response = await http.post(
      Uri.parse(API.getFallingEmoji), // 请确保你有定义这个 API 地址
      body: {'user_id': userId, 'post_id': postId.toString()},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      if (data['success'] == true) {
        List<dynamic> commentsJson = data['comments'];
        List<Comment> comments =
            commentsJson.map((json) => Comment.fromJson(json)).toList();
        _commentsController.add(comments);
        print("抓取 emoji_id 成功 comments: $comments");
      } else {
        _commentsController.add([]);
        print("無符合的 emoji_id ");
      }
    } else {
      _commentsController.add([]);
      print("抓取 emoji_id 失敗...");
    }
  }

  Color getTextColor(Color colorId) {
    switch (colorId.value) {
      case 0xFF222222:
        return Color(0xFFFFFF53);
      case 0xFFAF333A:
        return Color(0xFFFFFF00);
      case 0xFF374295:
        return Color(0xFFECA8A4);
      case 0xFFA1E0E4:
        return Color(0xFF4285F4);
      case 0xFFCD95BC:
        return Color(0xFFFFFFFF);
      case 0xFFECA8A4:
        return Color(0xFF29979E);
      case 0xFFA7BA89:
        return Color(0xFF6B6C39);
      case 0xFFFBBC05:
        return Color(0xFF34A853);
      case 0xFFFFFF4E:
        return Color(0xFFEB4335);
      case 0xFFF4F4E6:
        return Color(0xFF545453);
      case 0xFFDDCCC0:
        return Color(0xFF545453);
      case 0xFF6F5032:
        return Color(0xFFD1BA7E);
      default:
        return Colors.black;
    }
  }
}

class Post {
  final int id;
  final int userId;
  final Color textColor;
  final Color backgroundColor;
  final String? monster;
  final String? angel;
  final String title;
  final String date;
  final String content;
  // final String emotionImage;
  final String userPhoto;
  final String userName;

  const Post({
    required this.id,
    required this.userId,
    required this.textColor,
    required this.backgroundColor,
    this.monster,
    this.angel,
    required this.title,
    required this.date,
    required this.content,
    // required this.emotionImage,
    required this.userPhoto,
    required this.userName,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] != null ? json['id'] as int : 0, // 默認值為 0
      userId: json['user_id'] != null ? json['user_id'] as int : 0, // 默認值為 0
      textColor: Color(int.parse(json['text_color'])),
      backgroundColor: Color(int.parse(json['background_color'])),
      monster: json['monster'] != null && json['monster'].isNotEmpty
          ? json['monster'] as String
          : null,
      angel: json['angel'] != null && json['angel'].isNotEmpty
          ? json['angel'] as String
          : null,
      title: json['title'] as String,
      date: json['date'] as String,
      content: json['content'] as String,
      // emotionImage: json['emotion_image'] as String,
      userPhoto: json['user_photo'] as String,
      userName: json['user_name'] as String,
    );
  }
}

class User {
  final int id;
  final String name;
  final String photo;

  const User({
    required this.id,
    required this.name,
    required this.photo,
  });
}

class Comment {
  final int id;
  final int userId;
  final int postId;
  final int postUserId;
  final int? emojiId;
  final String? content;

  Comment({
    required this.id,
    required this.userId,
    required this.postId,
    required this.postUserId,
    this.emojiId,
    this.content,
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
      content: json['content'] as String,
    );
  }
}

/*
前端：
- 原設計是自己貼文垂直滑動 好友貼文左右滑動 自己貼文左滑能進入好友貼文，但一直無法實現區塊來回切換。
  因此先用左右滑動切塊區塊 好友與自己貼文都是上下滑動的方式實現
  - 如果滑動真的不行的話，看要不要新增懸浮紐: 可切換自己好友貼文(一律左右滑動)、呼叫下方的功能鍵
- 調整怪獸大小(放大)
- browsePage 再按一次表情貼要消失
- 掉落的表情貼沒有留在地板
- 功能鍵要可隱藏 (看是要點一下畫面，會出現消失 or 上下滑出現消失 or ...)

- new 從browsepage回來會自動對焦到輸入框...
*/

