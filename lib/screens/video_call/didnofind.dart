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
import 'package:slush/screens/events/bottomNavigation.dart';
import 'package:slush/screens/waiting_room/waiting_completed_screen.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:slush/widgets/toaster.dart';

class DidnotFindAnyoneScreen extends StatefulWidget {
  const DidnotFindAnyoneScreen({Key? key}) : super(key: key);

  @override
  State<DidnotFindAnyoneScreen> createState() => _DidnotFindAnyoneScreenState();
}

class _DidnotFindAnyoneScreenState extends State<DidnotFindAnyoneScreen> {

  @override
  void initState() {
    callFunction();
    super.initState();
  }
  void callFunction(){
    Provider.of<TimerProvider>(context, listen: false).startTimerr();
  }
  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
        SizedBox(
          height: size.height,
          width: size.width,
          child: Image.asset(AssetsPics.bluebg,fit: BoxFit.cover,),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 100,left: 40),
          child: Container(
              height: 35.h,
              width: 36.h,
              alignment: Alignment.center,
              child: SvgPicture.asset(AssetsPics.bigheart,fit: BoxFit.cover,)),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 0,top: 200),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Positioned(
                    left: 130,
                    child: Container(
                      alignment: Alignment.center,
                      child: SvgPicture.asset(AssetsPics.threeDotsLeft),),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child:SvgPicture.asset(AssetsPics.whiteFace),
                  ),
                ],
              ),
            buildText("Didn't find anyone ?", 28, FontWeight.w600, color.txtWhite),
            SizedBox(height: 2.h),
            buildText("Don't worry, you will have plenty of\n opportunities to match on Slush.", 20, FontWeight.w500, color.txtWhite,fontFamily: FontFamily.hellix),
          ],),
        ),
          Positioned(
              bottom: 20.0,
              child: Container(
                  padding: const EdgeInsets.only(left: 15),
                  margin: EdgeInsets.only(bottom:defaultTargetPlatform==TargetPlatform.iOS? 15:0),
                  width: size.width-14,
                  child: white_button(context,LocaleHandler.dateno==LocaleHandler.totalDate? "Check out our other events":"Wait for next round",press: (){
                    setState(() {
                      LocaleHandler.isThereAnyEvent=false;
                      LocaleHandler.isThereCancelEvent=false;
                      LocaleHandler.unMatchedEvent=false;
                      LocaleHandler.subScribtioonOffer=false;
                    });
                    if(LocaleHandler.dateno==LocaleHandler.totalDate){
                      LocaleHandler.dateno=0;
                      LocaleHandler.totalDate = 1;
                      showToastMsg("Event is over");
                      Get.offAll(()=>BottomNavigationScreen());
                    Provider.of<TimerProvider>(context,listen: false).stopTimerr();}
                    else{Get.offAll(()=>WaitingCompletedFeedBack(data: LocaleHandler.eventdataa));}
                    // Provider.of<TimerProvider>(context,listen: false).gotoWaitingRoom();

                    // Get.to(()=> BottomNavigationScreen());
                  })))
        ],),
    );
  }
}
