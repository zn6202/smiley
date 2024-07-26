import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../main.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  CustomBottomNavigationBar({required this.currentIndex, required this.onTap});

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  late int _currentIndex = widget.currentIndex;
  /*
  Future<bool> _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      print("登出成功");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
        (route) => false,
      );
      return true;
    } catch (e) {
      print('signOut->$e');
      return false;
    }
  }
  */
  void _onTap(int index) {
    if (index == 4) {
      // _handleLogout(context);
      Navigator.pushNamed(context, AppRoutes.setting);
    } else if (index == 2) {
      Navigator.pushNamed(context, AppRoutes.diaryMainScreen);
    } else if (index == 3) {
      Navigator.pushNamed(context, AppRoutes.browsePage);
    } else if (index == 1) {
      Navigator.pushNamed(context, AppRoutes.analysis);
    } else if (index == 0) {
      //聊天機器人頁面
    } else {
      widget.onTap(index);
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _onTap,
      items: [
        BottomNavigationBarItem(
          icon: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SizedBox(
              height: 32.v,
              width: 32.h,
              child: Image.asset(
                _currentIndex == 0
                    ? 'assets/images/chatRobot_on.png'
                    : 'assets/images/chatRobot_off.png',
              ),
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.v),
            child: SizedBox(
              height: 32.v,
              width: 32.h,
              child: Image.asset(
                _currentIndex == 1
                    ? 'assets/images/analyze_on.png'
                    : 'assets/images/analyze_off.png',
              ),
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
            color: _currentIndex == 2 ? Color(0xFFA7BA89) : Color(0xFFC5C5C5),
            size: 32.adaptSize, 
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.v),
            child: SizedBox(
              height: 32.v,
              width: 32.h,
              child: Image.asset(
                _currentIndex == 3
                    ? 'assets/images/social_on.png'
                    : 'assets/images/social_off.png',
              ),
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.v),
            child: SizedBox(
              height: 32.v,
              width: 32.h,
              child: Image.asset(
                _currentIndex == 4
                    ? 'assets/images/setting_on.png'
                    : 'assets/images/setting_off.png',
              ),
            ),
          ),
          label: '',
        ),
      ],
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontSize: 0),
      unselectedLabelStyle: TextStyle(fontSize: 0),
    );
  }
}
