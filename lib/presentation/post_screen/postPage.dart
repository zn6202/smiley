import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../core/app_export.dart';

class PostPage extends StatefulWidget {
  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  Color backgroundColor = Color(0xFFF4F4E6);
  Color textColor = Color(0xFF4C543E);
  int selectedColor = 0xFFF4F4E6;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  void updateColors(int colorId) {
    setState(() {
      backgroundColor = Color(colorId);
      textColor = getColor(colorId);
      selectedColor = colorId;
    });
  }

  void submitPost() {
    String colorId = selectedColor.toRadixString(16);
    String title = titleController.text;
    String date = DateFormat('yyyy.MM.dd').format(DateTime.now());
    String content = contentController.text;

    // 這裡是傳遞資料給後端的地方
    print('Color ID: $colorId');
    print('Title: $title');
    print('Date: $date');
    print('Content: $content');

    // 在這裡可以使用 HTTP 請求將資料傳遞給後端
    // 例如: http.post('https://yourapi.com/posts', body: {'color_id': colorId, 'title': title, 'date': date, 'content': content});
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl =
        ModalRoute.of(context)!.settings.arguments as String;
    final String currentDate = DateFormat('yyyy.MM.dd').format(DateTime.now());

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/images/img_arrow_left.svg',
            color: textColor,
          ),
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text(
                currentDate,
                style: TextStyle(
                  fontSize: 25,
                  height: 20 / 25,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              SizedBox(height: 40),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 400,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Color(0x80FFFFFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        style: TextStyle(
                          fontSize: 18,
                          height: 12 / 18,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          hintText: "輸入情緒名稱 ...",
                          hintStyle: TextStyle(
                            fontSize: 18,
                            height: 12 / 18,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFC5C5C5),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    Container(
                      width: 254,
                      height: 280,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    Container(
                      width: 350,
                      height: 80,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildColorRow1(),
                          buildColorRow2(),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: 400,
                      height: 220,
                      decoration: BoxDecoration(
                        color: Color(0x80FFFFFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: TextField(
                        style: TextStyle(
                          fontSize: 18,
                          height: 23 / 18,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          hintText: "輸入情緒貼文內容...",
                          hintStyle: TextStyle(
                            fontSize: 18,
                            height: 12 / 18,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFC5C5C5),
                          ),
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        submitPost();
                        // Navigator.pushNamed(context, AppRoutes.myPost);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0x80FFFFFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(
                            color: Color(0xFFC5C5C5),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Container(
                        width: 100,
                        height: 30,
                        alignment: Alignment.center,
                        child: Text(
                          "發布",
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFC5C5C5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildColorRow1() {
    List<int> colors1 = [
      0xFFF4F4E6,
      0xFFDDCCC0,
      0xFFFFFF4E,
      0xFFFBBC05,
      0xFFA7BA89,
      0xFF6F5032,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: colors1.map((color) {
        return GestureDetector(
          onTap: () => updateColors(color),
          child: Padding(
            padding: EdgeInsets.all(1),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Color(color),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color == selectedColor
                      ? Colors.black
                      : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildColorRow2() {
    List<int> colors2 = [
      0xFFECA8A4,
      0xFFCD95BC,
      0xFFA1E0E4,
      0xFF374295,
      0xFFAF333A,
      0xFF222222,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: colors2.map((color) {
        return GestureDetector(
          onTap: () => updateColors(color),
          child: Padding(
            padding: EdgeInsets.all(1),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Color(color),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color == selectedColor
                      ? Colors.black
                      : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color getColor(int colorId) {
    switch (colorId) {
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

/**
後端確認submitPost的資料格式是否可以
 */