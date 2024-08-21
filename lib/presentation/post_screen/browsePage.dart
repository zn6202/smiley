import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smiley/core/app_export.dart';
import '../../widgets/bottom_navigation.dart';
import 'FallingEmojiComment.dart';

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
  String _commentText = '';
  int _currentPostId = -1;
  
  final StreamController<List<Comment>> _commentsController = StreamController<List<Comment>>.broadcast();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _commentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _mainPageController = PageController();
    _futureMyPosts = fetchMyPosts();
    _futureFriendsPosts = fetchFriendsPosts();

    _futureMyPosts.then((posts) {
      if (posts.isNotEmpty) {
        _currentPostId = posts.first.id;
        fetchComments(_currentPostId);
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
              }
            });
          } else {
            _futureMyPosts.then((posts) {
              if (posts.isNotEmpty) {
                _currentPostId = posts.first.id;
                fetchComments(_currentPostId);
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
                }
              });
            } else {
              _futureMyPosts.then((posts) {
                if (posts.isNotEmpty) {
                  _currentPostId = posts.first.id;
                  fetchComments(_currentPostId);
                }
              });
            }
          }
        },
      ),
    );
  }

  Widget _buildPostsPage(Future<List<Post>> futurePosts, {required bool isMyPosts}) {
    return FutureBuilder<List<Post>>(
      future: futurePosts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No posts available"));
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
            }
          },
          itemBuilder: (context, index) {
            return _buildPostItem(posts[index], isMyPosts);
          },
        );
      },
    );
  }

  Widget _buildPostItem(Post post, bool isMyPost) {
    Color textColor = getTextColor(post.colorId);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: post.colorId,
          child: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
                        child: Text(
                          post.date,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                      Padding(
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
                                    image: AssetImage(post.userPhoto),
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
                        child: Image.asset(
                          'assets/images/${post.emotionImage}',
                          height: 200,
                          width: 200,
                          fit: BoxFit.contain,
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
                        final horizontalPosition = random.nextDouble() * constraints.maxWidth;
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
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
              padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
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
                      ),
                      controller: TextEditingController(text: _commentText),
                      onChanged: (value) {
                        setState(() {
                          _commentText = value;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: textColor),
                    onPressed: () {
                      submitComment();
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

  void submitComment() {
    // TODO: 將評論內容傳送到後端
    print("提交評論: $_commentText");
  }

  final List<User> users = const [
    User(id: 1, name: "AliceAliceAliceAliceAliceAlice", photo: "assets/images/default_avatar_1.png"),
    User(id: 2, name: "Bob", photo: "assets/images/default_avatar_2.png"),
  ];

  Future<List<Post>> fetchMyPosts() async {
    return [
      Post(
        id: 1,
        userId: 1,
        colorId: const Color(0xFFF4F4E6),
        monsterId: 1,
        angelId: null,
        title: "測試標題1",
        date: DateFormat('yyyy.MM.dd').format(DateTime.now().subtract(Duration(hours: 1))),
        content: "這是測試的貼文內容1。",
        emotionImage: "monster_1.png",
        userPhoto: getUserPhotoById(1),
        userName: getUserNameById(1),
      ),
      Post(
        id: 2,
        userId: 1,
        colorId: Color(0xFFDDCCC0),
        monsterId: 2,
        angelId: null,
        title: "測試標題2",
        date: DateFormat('yyyy.MM.dd').format(DateTime.now().subtract(Duration(hours: 3))),
        content: "這是測試的貼文內容2。",
        emotionImage: "monster_2.png",
        userPhoto: getUserPhotoById(1),
        userName: getUserNameById(1),
      ),
      Post(
        id: 3,
        userId: 1,
        colorId: Color(0xFFA7BA89),
        monsterId: 3,
        angelId: null,
        title: "測試標題3",
        date: DateFormat('yyyy.MM.dd').format(DateTime.now().subtract(Duration(hours: 5))),
        content: "這是測試的貼文內容3。",
        emotionImage: "monster_3.png",
        userPhoto: getUserPhotoById(1),
        userName: getUserNameById(1),
      ),
    ];
  }

  Future<List<Post>> fetchFriendsPosts() async {
    return [
      Post(
        id: 4,
        userId: 2,
        colorId: Color(0xFF6F5032),
        monsterId: 4,
        angelId: null,
        title: "好友貼文1",
        date: DateFormat('yyyy.MM.dd').format(DateTime.now().subtract(Duration(hours: 2))),
        content: "這是好友的貼文內容1。",
        emotionImage: "monster_4.png",
        userPhoto: getUserPhotoById(2),
        userName: getUserNameById(2),
      ),
      Post(
        id: 5,
        userId: 2,
        colorId: Color(0xFF374295),
        monsterId: 4,
        angelId: null,
        title: "好友貼文2",
        date: DateFormat('yyyy.MM.dd').format(DateTime.now().subtract(Duration(hours: 2))),
        content: "這是好友的貼文內容2。",
        emotionImage: "monster_1.png",
        userPhoto: getUserPhotoById(2),
        userName: getUserNameById(2),
      ),
    ];
  }

  Future<void> fetchComments(int postId) async {
    List<Comment> comments = [
      Comment(userId: 1, emojiId: 1, content: "這是評論3。"),
      Comment(userId: 1, emojiId: 2, content: "這是評論3。"),
    ];
    _commentsController.add(comments);
  }
  
  String getUserPhotoById(int userId) {
    try {
      return users.firstWhere((user) => user.id == userId).photo;
    } catch (e) {
      return 'assets/images/default_avatar.png';
    }
  }

  String getUserNameById(int userId) {
    try {
      return users.firstWhere((user) => user.id == userId).name;
    } catch (e) {
      return 'Unknown';
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
  final Color colorId;
  final int? monsterId;
  final int? angelId;
  final String title;
  final String date;
  final String content;
  final String emotionImage;
  final String userPhoto;
  final String userName;

  const Post({
    required this.id,
    required this.userId,
    required this.colorId,
    this.monsterId,
    this.angelId,
    required this.title,
    required this.date,
    required this.content,
    required this.emotionImage,
    required this.userPhoto,
    required this.userName,
  });
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
  final int userId;
  final int? emojiId;
  final String? content;

  Comment({
    required this.userId,
    this.emojiId,
    this.content,
  });
}

/*
前端：
- 原設計是自己貼文垂直滑動 好友貼文左右滑動 自己貼文左滑能進入好友貼文，但一直無法實現區塊來回切換。
因此先用左右滑動切塊區塊 好友與自己貼文都是上下滑動的方式實現
*/