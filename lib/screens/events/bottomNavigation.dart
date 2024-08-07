import 'dart:convert';

import 'package:agora_uikit/controllers/rtc_token_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/controller/controller.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/prefs.dart';
import 'package:slush/controller/event_controller.dart';
import 'package:slush/screens/chat/chat_screen.dart';
import 'package:slush/screens/events/event.dart';
import 'package:slush/screens/events/transparentcongo.dart';
import 'package:slush/screens/matches/match_screen.dart';
import 'package:slush/screens/profile/Profile_screem.dart';
import 'package:slush/screens/splash/splash_controller.dart';
import 'package:slush/screens/video_call/notification_serivce.dart';
import 'package:slush/video_player/reel_screen.dart';
import 'package:slush/widgets/alert_dialog.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/text_widget.dart';

import '../../constants/api.dart';
import '../../widgets/toaster.dart';

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

  Future getListData() async {
    // setState(() {LoaderOverlay.show(context);});
    final url = isLiked
        ? "${ApiList.result}page=1&limit=10&type=liked"
        : "${ApiList.result}page=1&limit=10";
    print(url);
    var uri = Uri.parse(url);
    var response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${LocaleHandler.accessToken}'
    });
    var dataa = jsonDecode(response.body)["data"]["items"];
    if (response.statusCode == 200) {
      int i = 0;
      for(i = 0; i <= dataa.length; i++){
        if(dataa[i]["isLikedTabUpdate"] == true) {
          print("object++++++++++++");
          setState(() {
            LocaleHandler.isLikedTabUpdate = true;
          });
        }
        // break;
      }
    } else if (response.statusCode == 401) {
      showToastMsgTokenExpired();
    } else {
      if (LocaleHandler.subscriptionPurchase == "yes") {
        Fluttertoast.showToast(msg: 'Something Went Wrong');
      }
      // setState(() {
      //   data = i;
      // });
    }
  }

  void _onItemTapped(int index) {
    LocaleHandler.liked=false;
    if (LocaleHandler.matchedd || LocaleHandler.bioAuth) {}
    else {
      _selectedIndex.value = index;
      if (_selectedIndex.value != 2) {
        Provider.of<reelController>(context, listen: false).videoPause(true, LocaleHandler.pageIndex);
        Provider.of<reelController>(context, listen: false).remove();}
      else if(_selectedIndex.value!=0){
        Provider.of<eventController>(context, listen: false).timerCancel();
      }}
    Provider.of<SplashController>(context, listen: false).checkInterenetConnection();
  }

  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    // _notificationService.initialize();
    Provider.of<SplashController>(context, listen: false).checkInterenetConnection();
    // removeFeedList();
    getListData();
    callFunction();
    super.initState();
  }

  void callFunction() async {
    _selectedIndex.value=LocaleHandler.bottomSheetIndex;
    print("LocaleHandler.bottomSheetIndex::=============${LocaleHandler.bottomSheetIndex}");
    print("LocaleHandler::=============${_selectedIndex.value}");
    // if(widget.i!=null){ _selectedIndex=widget.i; }
    alreadySeenReelTutorials = await Preferences.getReelAlreadySeen() ?? "";
    // if (_selectedIndex.value != 0) {
        // _selectedIndex.value = 0;
    // }
    if (alreadySeenReelTutorials == "true") {
      LocaleHandler.feedTutorials = false;
    }
    // setState(() {
      if (LocaleHandler.curentIndexNum == 2) {
        // LocaleHandler.curentIndexNum = 0;
        _selectedIndex.value = 2;
      } else {
        // _selectedIndex.value = 0;
      }
    // });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    bool isCongo=false;
    return Scaffold(
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
      bottomNavigationBar:Consumer<reelController>(builder: (ctx,val,child){return !val.congo?ClipRRect(
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
                    icon: SvgPicture.asset(_selectedIndex.value == 1
                        ? AssetsPics.selectedmsgIcon
                        : AssetsPics.msgIcon),
                    label: 'Message'),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(_selectedIndex.value == 2
                      ? AssetsPics.selectedreelIcon
                      : AssetsPics.reelIcon),
                  label: 'Reel',
                ),
                // BottomNavigationBarItem(
                //   // icon: SvgPicture.asset(_selectedIndex==3?AssetsPics.selectedredheartIcon:AssetsPics.heartIcon),
                //   icon:
                //   SvgPicture.asset(_selectedIndex.value == 3 && notification == true
                //       ? AssetsPics.selectedredheartIcon
                //       : _selectedIndex.value == 3 && notification == false
                //       ? AssetsPics.selectedheartIcon
                //       : AssetsPics.heartIcon),
                //   label: 'Heart',
                // ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(_selectedIndex.value == 3 && LocaleHandler.isLikedTabUpdate ? AssetsPics.selectedredheartIcon
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

    );
  }


}
