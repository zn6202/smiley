import '../../core/app_export.dart';

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

  void _onTap(int index, MessageProvider messageProvider) {
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
      messageProvider.clearUnread();
      Navigator.pushNamed(context, AppRoutes.chatbotScreen);
    } else {
      widget.onTap(index);
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final messageProvider = Provider.of<MessageProvider>(context); // 偵測未讀訊息
    final routeName = ModalRoute.of(context)?.settings.name;
    return Container(
      decoration: BoxDecoration(
        color:
            widget.isTransparent ? Colors.transparent : const Color(0xFFFCFCFE),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => _onTap(index, messageProvider),
        items: [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.v),
              child: Badge(
                // 顯示未讀訊息在按鈕上
                label: 
                  Text(
                  '${messageProvider.newMessages}',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                isLabelVisible: 
                  (messageProvider.newMessages > 0 && routeName != '/ChatBot_screen')
                  ? true
                  : false,
                child: SizedBox(
                  height: 32.v,
                  width: 32.h,
                  child: SvgPicture.asset(
                    'assets/images/chatRobot.svg',
                    colorFilter: ColorFilter.mode(
                      _currentIndex == 0
                          ? const Color(0xFFA7BA89)
                          : const Color(0xFFC5C5C5),
                      BlendMode.srcIn,
                    ),
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
                    _currentIndex == 1
                        ? const Color(0xFFA7BA89)
                        : const Color(0xFFC5C5C5),
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
                  widget.isHomeScreen
                      ? 'assets/images/diary.svg'
                      : 'assets/images/home.svg',
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
                    _currentIndex == 3
                        ? const Color(0xFFA7BA89)
                        : const Color(0xFFC5C5C5),
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
                    _currentIndex == 4
                        ? const Color(0xFFA7BA89)
                        : const Color(0xFFC5C5C5),
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
