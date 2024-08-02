import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/controller/video_call_controller.dart';
import 'package:slush/screens/chat/text_chat_screen.dart';
import 'package:slush/screens/events/bottomNavigation.dart';
import 'package:slush/screens/video_call/didnofind.dart';
import 'package:slush/screens/waiting_room/waiting_completed_screen.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:slush/widgets/toaster.dart';

class CongratMatchScreen extends StatefulWidget {
  const CongratMatchScreen({Key? key}) : super(key: key);

  @override
  State<CongratMatchScreen> createState() => _CongratMatchScreenState();
}

class _CongratMatchScreenState extends State<CongratMatchScreen> {
  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(children: [
        SizedBox(
          height: size.height,
          width: size.width,
          child: Image.asset(AssetsPics.bluebg,fit: BoxFit.cover,),
        ),
        Positioned(bottom: 0.0,child: SvgPicture.asset(AssetsPics.hearts,fit: BoxFit.cover,)),
        SafeArea(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(left: 18,right: 18,top: 25),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                GestureDetector(
                  onTap: (){
                    setState(() {
                      LocaleHandler.isThereAnyEvent=false;
                      LocaleHandler.isThereCancelEvent=false;
                      LocaleHandler.unMatchedEvent=false;
                      LocaleHandler.subScribtioonOffer=false;
                    });
                    // Provider.of<TimerProvider>(context,listen: false).gotoWaitingRoom();
                    if(LocaleHandler.dateno==LocaleHandler.totalDate){
                      showToastMsg("Event is over");
                      Get.offAll(()=>BottomNavigationScreen());
                    Provider.of<TimerProvider>(context).stopTimerr();}
                    else{Get.offAll(()=>WaitingCompletedFeedBack(data: LocaleHandler.eventdataa));}

                    // Get.offAll(()=> BottomNavigationScreen());
                    // Get.back();
                    // Get.back();
                    // Get.back();
                  },
                  child: Container(
                    height: 26,width: 26,
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(shape: BoxShape.circle,color: Colors.white,
                        boxShadow:[
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 20.0,
                              offset: Offset(0.0,10.0)
                          )
                        ]
                    ),
                    child: const Icon(Icons.clear,color: color.txtBlue,size: 20),
                  ),
                )
              ],),
              const SizedBox(height: 24),
              buildText2("It’s a Match!", 28, FontWeight.w600, color.txtWhite),
            buildText2("Congratulations!", 28, FontWeight.w600, color.txtWhite),
            const SizedBox(height: 22),
            // buildText2("“Steve liked you back”", 16, FontWeight.w500, color.txtWhite,fontFamily: FontFamily.hellix),
            buildText2("“${LocaleHandler.eventParticipantData["firstName"]} liked you back”", 16, FontWeight.w500, color.txtWhite,fontFamily: FontFamily.hellix),
              const SizedBox(height: 20),
              // SvgPicture.asset("assets/sample/matchingSample.svg"),

              Stack(
                children: [
                  Container(
                      // color: Colors.red,
                      width: size.width, height: 41.h),
                  Positioned(
                    top: 50.0,
                    right: 60.0,
                    child: RotationTransition(
                        turns:  const AlwaysStoppedAnimation(10 / 360),
                        child: Container(
                          decoration:BoxDecoration(
                            color: Colors.white54,
                            borderRadius: BorderRadius.circular(40)
                          ),
                          padding: const EdgeInsets.all(4),
                            height: 19.h,
                            width: 17.h,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                // child: Image.asset(AssetsPics.sample,fit: BoxFit.cover)
                                child:CachedNetworkImage(imageUrl: LocaleHandler.eventParticipantData["avatar"],fit: BoxFit.cover)
                            ))),
                  ),
                  Positioned(
                    bottom: 40.0,
                    left: 60.0,
                    child: RotationTransition(
                        turns:  const AlwaysStoppedAnimation(-10 / 360),
                        child: Container(
                            decoration:BoxDecoration(
                                color: Colors.white54,
                                borderRadius: BorderRadius.circular(40)
                            ),
                            padding: const EdgeInsets.all(4),
                            height: 19.h,
                            width: 17.h,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(40),child:
                            // Image.asset(AssetsPics.sample,fit: BoxFit.cover),
                              CachedNetworkImage(imageUrl: LocaleHandler.avatar,fit: BoxFit.cover)
                            ))),
                  ),
                  Positioned(
                      top: 30.0,
                      left: 50.0,
                      child: SvgPicture.asset(AssetsPics.twoHeart)),
                  Positioned(
                      bottom: 30.0,
                      right: 50.0,
                      child: SvgPicture.asset(AssetsPics.twoHeart)),
                  Positioned(
                      top: 27.0,
                      right: 150.0,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                          // color: Colors.red,
                          child: SvgPicture.asset(AssetsPics.redHeart))),
                  Positioned(
                      bottom: 20.0,
                      left: 60.0,
                      child: CircleAvatar(
                          backgroundColor: Colors.white,
                          // color: Colors.red,
                          child: SvgPicture.asset(AssetsPics.redHeart))),
                ],
              ),
              /*Image.asset(AssetsPics.matchingSample),*/

              const Spacer(),
              blue_button(context,"Chat",press: (){
                Get.to(()=> TextChatScreen(id: LocaleHandler.eventParticipantData["userId"],
                name: LocaleHandler.eventParticipantData["firstName"],
                ));
              }),
              const SizedBox(height: 15),
              white_button(context, "View your match list",press: (){
                setState(() {
                  LocaleHandler.bottomSheetIndex=3;
                });
                // Get.to(()=>const DidnotFindAnyoneScreen());
                Get.offAll(()=>BottomNavigationScreen());
              }),
               SizedBox(height:defaultTargetPlatform==TargetPlatform.iOS?10: 25),
          ],),),
        )
      ],),
    );
  }
}
