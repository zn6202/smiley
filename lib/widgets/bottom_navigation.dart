import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../main.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isTransparent;
  final bool isHomeScreen;

  CustomBottomNavigationBar({
    required this.currentIndex, 
    required this.onTap,
    this.isTransparent = false, 
    this.isHomeScreen = false,
  });

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  late int _currentIndex = widget.currentIndex;

  void _onTap(int index) {
    if (index == 4) {
      Navigator.pushNamed(context, AppRoutes.setting);
    } else if (index == 2) {
      if (widget.isHomeScreen) {
        Navigator.pushNamed(context, AppRoutes.diaryMainScreen);
      } else {
        Navigator.pushNamed(context, AppRoutes.homeScreen);
      }
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
    return Container(
      decoration: BoxDecoration(
        color: widget.isTransparent ? Colors.transparent : const Color(0xFFFCFCFE),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        items: [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.v),
              child: SizedBox(
                height: 32.v,
                width: 32.h,
                child: SvgPicture.asset(
                  'assets/images/chatRobot.svg',
                  colorFilter: ColorFilter.mode(
                    _currentIndex == 0 ? const Color(0xFFA7BA89) : const Color(0xFFC5C5C5),
                    BlendMode.srcIn,
                  ),
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
                child: SvgPicture.asset(
                  'assets/images/analyze.svg',
                  colorFilter: ColorFilter.mode(
                    _currentIndex == 1 ? const Color(0xFFA7BA89) : const Color(0xFFC5C5C5),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.v),
              child: SizedBox(
                height: 38.v,
                width: 38.h,
                child: SvgPicture.asset(
                  widget.isHomeScreen ? 'assets/images/diary.svg' : 'assets/images/home.svg',
                  colorFilter: ColorFilter.mode(
                    const Color(0xFFC5C5C5),
                    BlendMode.srcIn,
                  ),
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
                child: SvgPicture.asset(
                  'assets/images/social.svg',
                  colorFilter: ColorFilter.mode(
                    _currentIndex == 3 ? const Color(0xFFA7BA89) : const Color(0xFFC5C5C5),
                    BlendMode.srcIn,
                  ),
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
                child: SvgPicture.asset(
                  'assets/images/setting.svg',
                  colorFilter: ColorFilter.mode(
                    _currentIndex == 4 ? const Color(0xFFA7BA89) : const Color(0xFFC5C5C5),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            label: '',
          ),
          
        ],
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 0),
        unselectedLabelStyle: TextStyle(fontSize: 0),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
