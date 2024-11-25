
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/controller/chat_controller.dart';
import 'package:slush/controller/controller.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/prefs.dart';
import 'package:slush/controller/event_controller.dart';
import 'package:slush/controller/profile_controller.dart';
import 'package:slush/notification.dart';
import 'package:slush/screens/chat/chat_screen.dart';
import 'package:slush/screens/events/event.dart';
import 'package:slush/screens/events/transparentcongo.dart';
import 'package:slush/screens/matches/match_screen.dart';
import 'package:slush/screens/profile/Profile_screem.dart';
import 'package:slush/screens/splash/splash_controller.dart';
import 'package:slush/screens/video_call/notification_serivce.dart';
import 'package:slush/video_player/reel_screen.dart';
import 'package:slush/widgets/alert_dialog.dart';
import 'package:slush/widgets/customtoptoaster.dart';


class BottomNavigationScreen extends StatefulWidget {
  BottomNavigationScreen({Key? key}) : super(key: key);

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  // int _selectedIndex = 0;
  final ValueNotifier<int> _selectedIndex = ValueNotifier(0);
  String alreadySeenReelTutorials = "";
  bool notification = false;
  bool isLiked = false;

  static const List<Widget> _widgetOptions = <Widget>[
    EventScreen(),
    ChatScreen(),
    ReelViewScreen(),
    MatchesScreen(),
    UserProfileScreen(),
  ];


  void _onItemTapped(int index) {
    LocaleHandler.liked=false;
    if (LocaleHandler.matchedd || LocaleHandler.bioAuth) {}
    else {
      _selectedIndex.value = index;
      if (_selectedIndex.value != 2) {
        Provider.of<ReelController>(context, listen: false).videoPause(true, LocaleHandler.pageIndex);
        Provider.of<ReelController>(context, listen: false).remove();
        if(_selectedIndex.value!=0){Provider.of<eventController>(context, listen: false).timerCancel();}}
      else if(_selectedIndex.value!=0){
        Provider.of<eventController>(context, listen: false).timerCancel();
      }
    }
    Provider.of<SplashController>(context, listen: false).checkInterenetConnection();
  }

  final NotificationService _notificationService = NotificationService();
  final OnesignalNotificationNavigation _onesignal = OnesignalNotificationNavigation();

  @override
  void initState() {
    Provider.of<SplashController>(context, listen: false).checkInterenetConnection();
    callFunction();
    _onesignal.initPlatformState();
    super.initState();
  }

  void callFunction() async {
    _selectedIndex.value=LocaleHandler.bottomSheetIndex;
    alreadySeenReelTutorials = await Preferences.getReelAlreadySeen() ?? "";
    if (alreadySeenReelTutorials == "true") {LocaleHandler.feedTutorials = false;}
      if (LocaleHandler.curentIndexNum == 2) {_selectedIndex.value = 2;}
      else {}
    LocaleHandler.curentIndexNum=0;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    bool isCongo=false;
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          Scaffold(
            // backgroundColor: color.backGroundClr,
            extendBody: true,
            body: Stack(
              children: [
                SizedBox(
                  height: size.height, width: size.width,
                  child: ValueListenableBuilder(valueListenable: _selectedIndex,
                  builder: (context,val,child){
                    return _widgetOptions.elementAt(_selectedIndex.value);
                  }
                  ),
                  // child: _widgetOptions.elementAt(widget.i!=null?widget.i:_selectedIndex),
                ),
                // Consumer<reelController>(builder: (ctx,val,child){return isCongo?const SizedBox(): stackbuild(context, "asasas");}),
                bioAlert(context),
                connectionAlert(context),
                // Consumer<reelController>(builder: (context,child,val){return LocaleHandler.matchedd? TransparentCongoWithBottomScreen():SizedBox();})
              ],
            ),
            bottomNavigationBar:Consumer<ReelController>(builder: (ctx,val,child){return !val.congo?ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: ValueListenableBuilder(valueListenable: _selectedIndex,builder: (ctx,val,child){
                return Theme(
                  data: ThemeData(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent),
                  child: BottomNavigationBar(
                    items: <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                          icon: SvgPicture.asset(_selectedIndex.value == 0
                              ? AssetsPics.selectedevnetIcon
                              : AssetsPics.evnetIcon),
                          label: 'Event',
                          backgroundColor: color.txtBlue),
                      BottomNavigationBarItem(
                          icon: Stack(
                            children: [
                              SvgPicture.asset(_selectedIndex.value == 1 && Provider.of<ChatController>(context,listen: false).unreadMsg ? AssetsPics.selctedredmessage
                              :_selectedIndex.value == 1
                                  ? AssetsPics.selectedmsgIcon
                                  : AssetsPics.msgIcon),
                               Positioned(
                                  right: 10.0,
                                  top: 10.0,
                                  child:_selectedIndex.value != 1 && Provider.of<ChatController>(context,listen: false).unreadMsg? const CircleAvatar(radius: 3,backgroundColor: Colors.red):const SizedBox())
                            ],
                          ),
                          label: 'Message'),
                      BottomNavigationBarItem(
                        icon: SvgPicture.asset(_selectedIndex.value == 2
                            ? AssetsPics.selectedreelIcon
                            : AssetsPics.reelIcon),
                        label: 'Reel',
                      ),
                      BottomNavigationBarItem(
                        icon: SvgPicture.asset(_selectedIndex.value == 3 && LocaleHandler.isLikedTabUpdate
                            ? AssetsPics.selectedredheartIcon
                            : _selectedIndex.value == 3 && !LocaleHandler.isLikedTabUpdate
                            ? AssetsPics.selectedheartIcon : AssetsPics.heartIcon),
                        label: 'Heart',
                      ),
                      BottomNavigationBarItem(
                        icon: SvgPicture.asset(_selectedIndex.value == 4 ? AssetsPics.selectedprofileIcon : AssetsPics.profileIcon),
                        label: 'Profile',
                      ),
                    ],
                    type: BottomNavigationBarType.fixed,
                    currentIndex: _selectedIndex.value,
                    selectedItemColor: Colors.black,
                    iconSize: 40,
                    onTap: _onItemTapped,
                    elevation: 5,
                    backgroundColor: color.txtWhite,
                    showSelectedLabels: false,
                    enableFeedback: true,
                    showUnselectedLabels: false,
                  ),
                );
              }),
            ): stackbuild(context, val.name,val.id);}),

          ),
          Consumer<profileController>(builder: (context,val,child){
            return val.unmatched? CustomTopToaster(textt: "Unmatched successfully"):const SizedBox.shrink();
          }),
        ],
      ),
    );
  }


}
