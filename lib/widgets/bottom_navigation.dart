// bottom_navigation.dart

import 'package:flutter/material.dart';
import '../../core/app_export.dart';  

class CustomBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  CustomBottomNavigationBar({required this.currentIndex, required this.onTap});

  @override
  _CustomBottomNavigationBarState createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  void _handleLogout() {
    Navigator.pushNamed(context, AppRoutes.loginScreen);
  }

  void _onTap(int index) {
    if (index == 2) { 
      _handleLogout();
    } else {
      widget.onTap(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      onTap: _onTap,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '首頁',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: '搜尋',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.exit_to_app),
          label: '登出',
        ),
      ],
    );
  }
}


/*
1. 未按照設計
 */