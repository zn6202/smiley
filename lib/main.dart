import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Circle Navigation App',
      home: HomePage(),
      routes: {
        '/diary': (context) => DetailPage(title: '日記'),
        '/myMood': (context) => DetailPage(title: '我的情緒'),
        '/games': (context) => DetailPage(title: '遊戲'),
        '/emotionAngel': (context) => DetailPage(title: '情緒小天使'),
        '/expertArticles': (context) => DetailPage(title: '專家文章'),
        '/myAccount': (context) => DetailPage(title: '我的帳號'),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('首頁'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: <Widget>[
            _buildCircleButton(context, '日記', '/diary'),
            _buildCircleButton(context, '我的情緒', '/myMood'),
            _buildCircleButton(context, '遊戲', '/games'),
            _buildCircleButton(context, '情緒小天使', '/emotionAngel'),
            _buildCircleButton(context, '專家文章', '/expertArticles'),
            _buildCircleButton(context, '我的帳號', '/myAccount'),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(BuildContext context, String label, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(route);
      },
      child: CircleAvatar(
        radius: 50.0,
        backgroundColor: Colors.blue,
        child: Text(
          label,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String title;

  DetailPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _buildPageContent(context),
    );
  }

  Widget _buildPageContent(BuildContext context) {
    if (title == '日記') {
      return CalendarWidget();
    } else {
      return Center(
        child: Text('歡迎來到 $title 頁面', style: TextStyle(fontSize: 24)),
      );
    }
  }
}

class CalendarWidget extends StatefulWidget {
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => DiaryEntryPage(date: _selectedDay)));
          },
          child: Text('寫日記'),
        ),
      ],
    );
  }
}

class DiaryEntryPage extends StatelessWidget {
  final DateTime? date;
  final TextEditingController _controller = TextEditingController();

  DiaryEntryPage({this.date});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('寫日記'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '日期：${date?.toString().substring(0, 10) ?? '未選擇'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: '請在這裡輸入您的日記...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => _saveEntry(context),
              child: Text('儲存'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveEntry(BuildContext context) async {
    final String apiUrl = 'http://192.168.56.1/smiley_appAPI/api.php';

    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'date': date?.toString().substring(0, 10) ?? '',
        'content': _controller.text,
      },
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['status'] == 'success') {
        _showDialog(context, '日記已儲存', '今天辛苦了~ 給自己一個大大的微笑ㄅ！');
      } else {
        _showDialog(context, '儲存失敗', '日記儲存時出現問題。');
      }
    } else {
      _showDialog(context, '錯誤', '無法連接到伺服器。');
    }
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text('好的'),
              onPressed: () {
                Navigator.of(context).pop(); // 關閉對話框
                if (title == '日記已儲存') {
                  Navigator.of(context).pop(); // 返回前一個頁面
                }
              },
            ),
          ],
        );
      },
    );
  }
}
