import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  CustomBottomNavigationBar({required this.currentIndex, required this.onTap});

  @override
  _CustomBottomNavigationBarState createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  late int _currentIndex = widget.currentIndex;

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

  void _onTap(int index) {
    if (index == 2) {
      _handleLogout(context);
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
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              height: 24.0,
              width: 24.0,
              child: Image.asset(
                _currentIndex == 0 ? 'assets/images/chatRobot_on.png' : 'assets/images/chatRobot_off.png',
              ),
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              height: 24.0,
              width: 24.0,
              child: Image.asset(
                _currentIndex == 1 ? 'assets/images/analyze_on.png' : 'assets/images/analyze_off.png',
              ),
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              height: 24.0,
              width: 24.0,
              child: Image.asset(
                _currentIndex == 2 ? 'assets/images/diary_on.png' : 'assets/images/diary_off.png',
              ),
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              height: 24.0,
              width: 24.0,
              child: Image.asset(
                _currentIndex == 3 ? 'assets/images/social_on.png' : 'assets/images/social_off.png',
              ),
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              height: 24.0,
              width: 24.0,
              child: Image.asset(
                _currentIndex == 4 ? 'assets/images/setting_on.png' : 'assets/images/setting_off.png',
              ),
            ),
          ),
          label: '',
        ),
      ],
      type: BottomNavigationBarType.fixed,
    );
  }
}
