import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/controller/controller.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/prefs.dart';
import 'package:slush/screens/chat/chat_screen.dart';
import 'package:slush/screens/events/event.dart';
import 'package:slush/screens/events/transparentcongo.dart';
import 'package:slush/screens/feed/feed_screen.dart';
import 'package:slush/screens/matches/match_screen.dart';
import 'package:slush/screens/profile/Profile_screem.dart';
import 'package:slush/screens/splash/splash_controller.dart';
import 'package:slush/video_player/reel_screen.dart';
import 'package:slush/widgets/alert_dialog.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/toaster.dart';

class BottomNavigationScreen extends StatefulWidget {
   BottomNavigationScreen({Key? key}) : super(key: key);
  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _selectedIndex = 0;
  String alreadySeenReelTutorials="";
  bool notification=false;

  static const List<Widget> _widgetOptions = <Widget>[
    EventScreen(),
    ChatScreen(),
    ReelViewScreen(),
    MatchesScreen(),
    UserProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if(LocaleHandler.matchedd || LocaleHandler.bioAuth){}
     else{ setState(() {_selectedIndex = index;});
    if(_selectedIndex!=2){
      Provider.of<reelController>(context,listen: false).videoPause(true,LocaleHandler.pageIndex);
      Provider.of<reelController>(context,listen: false).remove();}}
    Provider.of<SplashController>(context,listen: false).checkInterenetConnection();
  }

  @override
  void initState() {
    Provider.of<SplashController>(context,listen: false).checkInterenetConnection();
    // removeFeedList();s
    callFunction();
    super.initState();
  }

  // DateTime? currentBackPressTime;
  // Future<bool> onWillPop() {
  //   DateTime now = DateTime.now();
  //   if (currentBackPressTime == null || now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
  //     currentBackPressTime = now;
  //     Fluttertoast.showToast(msg: "press again to exit");
  //     // showToastMsg("press again to exit");
  //     return Future.value(false);
  //   }
  //   return Future.value(true);
  // }

  void callFunction()async{
    // if(widget.i!=null){ _selectedIndex=widget.i; }
    alreadySeenReelTutorials = await Preferences.getReelAlreadySeen()??"";
    if(LocaleHandler.bottomindex!=0){
      setState(() {_selectedIndex=LocaleHandler.bottomindex;
        LocaleHandler.bottomindex=0;});
    }
    if(alreadySeenReelTutorials=="true"){LocaleHandler.feedTutorials=false;}
    setState(() {
      if(LocaleHandler.curentIndexNum==2){
        LocaleHandler.curentIndexNum=0;
        _selectedIndex= 2;
      }else{
        _selectedIndex= 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      // backgroundColor: color.backGroundClr,
      extendBody: true,
      body: Stack(
        children: [
          SizedBox(
            height: size.height,width: size.width,
            child: _widgetOptions.elementAt(_selectedIndex),
            // child: _widgetOptions.elementAt(widget.i!=null?widget.i:_selectedIndex),
          ),
          bioAlert(context),
          connectionAlert(context),
          // Consumer<reelController>(builder: (context,child,val){return LocaleHandler.matchedd? TransparentCongoWithBottomScreen():SizedBox();})
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Theme(
          data: ThemeData(splashColor: Colors.transparent, highlightColor: Colors.transparent),
          child: BottomNavigationBar(
              items:  <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(_selectedIndex==0?AssetsPics.selectedevnetIcon:AssetsPics.evnetIcon),
                    label: 'Event',
                backgroundColor: color.txtBlue),
                BottomNavigationBarItem(
                    icon: SvgPicture.asset(_selectedIndex==1?AssetsPics.selectedmsgIcon:AssetsPics.msgIcon),
                    label: 'Message'),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(_selectedIndex==2?AssetsPics.selectedreelIcon:AssetsPics.reelIcon),
                    label: 'Reel',),
                BottomNavigationBarItem(
                  // icon: SvgPicture.asset(_selectedIndex==3?AssetsPics.selectedredheartIcon:AssetsPics.heartIcon),
                  icon: SvgPicture.asset(
                      _selectedIndex==3 && notification==true?AssetsPics.selectedredheartIcon:_selectedIndex==3 && notification == false ? AssetsPics.selectedheartIcon:AssetsPics.heartIcon
                  ),
                    label: 'Heart',),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(_selectedIndex==4?AssetsPics.selectedprofileIcon:AssetsPics.profileIcon),
                  label: 'Profile',
                ),
              ],
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.black,
              iconSize: 40,
              onTap: _onItemTapped,
              elevation: 5,
              backgroundColor: color.txtWhite,
              showSelectedLabels: false,
              enableFeedback: true,
              showUnselectedLabels: false,

          ),
        ),
      ),
    );
  }
}
