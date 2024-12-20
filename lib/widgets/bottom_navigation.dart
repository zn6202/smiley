import '../../core/app_export.dart';
import 'package:just_audio/just_audio.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isTransparent;
  final bool isHomeScreen;
  final AudioPlayer? audioPlayer; // 新增音樂播放器參數

  CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
    this.isTransparent = false,
    this.isHomeScreen = false,
    this.audioPlayer, // 初始化音樂播放器參數
  });

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  late int _currentIndex = widget.currentIndex;

  Future<void> disposeMusic() async {
    if (widget.audioPlayer != null) {
      if (widget.audioPlayer!.playing) {
        await widget.audioPlayer!.pause(); // 暫停音樂
        await widget.audioPlayer!.dispose(); // 釋放資源
        print('音樂已暫停並釋放資源');
      } else {
        print('音樂播放器未播放音樂');
      }
    } else {
      print('音樂播放器未初始化');
    }
  }

  void _onTap(int index, MessageProvider messageProvider) async {
    await disposeMusic(); // 等待 disposeMusic 完成

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
      Navigator.pushNamed(context, AppRoutes.chatbotScreen);
    } else {
      widget.onTap(index);
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void dispose() {
    // 不需要在這裡釋放音樂播放器資源，因為它應該由父元件負責
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 使用 Provider 取得 MessageProvider
    final messageProvider = Provider.of<MessageProvider>(context);
    final routeName = ModalRoute.of(context)?.settings.name;
    // 如果還未初始化，進行初始化，並傳送機器人歡迎訊息
    if (!messageProvider.isInitialized) {
      messageProvider.initialize();
    }
    // return Consumer<MessageProvider>(
    //   builder: (context, messageProvider, child) {
    //     if (routeName == '/ChatBot_screen') {
    //       messageProvider.clearUnread();
    //     }
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
                    label: Text(
                      '${messageProvider.newMessages}',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    isLabelVisible: (messageProvider.newMessages > 0 &&
                            routeName != '/ChatBot_screen')
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
    // );
  // }
}
