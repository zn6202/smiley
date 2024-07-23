import 'package:flutter/material.dart';
import '../../core/app_export.dart'; 
import '../../widgets/app_bar/appbar_leading_image.dart';

class Notificationscreen extends StatefulWidget {
  @override
  _NotificationscreenState createState() => _NotificationscreenState();
}

class _NotificationscreenState extends State<Notificationscreen> {
  List<NotificationItem> notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      notifications = [
        NotificationItem(
            date: '2024.04.14',
            inform: '在您的貼文下留言',
            friendImage: 'default_avatar_1.png',
            friendName: 'www'),
        NotificationItem(
            date: '2024.04.15',
            inform: '在您的貼文留言',
            friendImage: 'default_avatar_4.png',
            friendName: 'bbb'),
        NotificationItem(
            date: '2024.04.15',
            inform: '在您的貼文留言',
            friendImage: 'default_avatar_4.png',
            friendName: 'bbb'),
        NotificationItem(
            date: '2024.04.15',
            inform: '在您的貼文留言',
            friendImage: 'default_avatar_4.png',
            friendName: 'bbb'),
        NotificationItem(
            date: '2024.04.15',
            inform: '在您的貼文留言',
            friendImage: 'default_avatar_4.png',
            friendName: 'bbb'),
        NotificationItem(
            date: '2024.04.15',
            inform: '在您的貼文留言',
            friendImage: 'default_avatar_4.png',
            friendName: 'bbb'),
        NotificationItem(
            date: '2024.04.15',
            inform: '在您的貼文留言',
            friendImage: 'default_avatar_4.png',
            friendName: 'bbb'),
        NotificationItem(
            date: '2024.04.15',
            inform: '在您的貼文留言',
            friendImage: 'default_avatar_4.png',
            friendName: 'bbb'),

      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F4E6), 
      appBar: AppBar(
        elevation: 0, 
        backgroundColor: Colors.transparent, 
        leading: AppbarLeadingImage(
          imagePath: 'assets/images/arrow-left-g.png',
          margin: EdgeInsets.only(
            top: 19.0,
            bottom: 19.0,
          ),
          onTap: () async {
            Navigator.pop(context);
          },
        ),
        title: Image.asset(
          'assets/images/notify.png',
          height: 30, 
        ),
        centerTitle: true, 
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              "通知中心",
              style: TextStyle(
                fontSize: 25,
                height: 1.2,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                color: Color(0xFF545453),
              ),
            ),
            SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.all(20),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white, 
                            backgroundImage: AssetImage('assets/images/${notification.friendImage}'),
                          ),
                          SizedBox(width: 30),
                          Expanded(
                            child: Text(
                              '${notification.friendName} ${notification.inform}',
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Inter',
                                color: Color(0xFF545453),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationItem {
  final String date;
  final String inform;
  final String friendImage;
  final String friendName;

  NotificationItem({
    required this.date,
    required this.inform,
    required this.friendImage,
    required this.friendName,
  });
}

/*
前端
- 太多筆資料時 會超過邊界

後端
- 修改_fetchNotifications
- 修改好友頭像顯示路徑(現在是預設會在assets裡 路徑寫在127)  
*/