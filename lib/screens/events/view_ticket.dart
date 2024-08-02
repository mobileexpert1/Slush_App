import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart'as http;
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/controller/event_controller.dart';
import 'package:slush/controller/waitingroom_controller.dart';
import 'package:slush/screens/events/bottomNavigation.dart';
import 'package:slush/screens/waiting_room/waiting_room_screen.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/seprator.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:slush/widgets/toaster.dart';
import 'package:intl/intl.dart';

class EventViewTicketScreen extends StatefulWidget {
  EventViewTicketScreen({Key? key,required this.data}) : super(key: key);
  var data;
  @override
  State<EventViewTicketScreen> createState() => _EventViewTicketScreenState();
}

class _EventViewTicketScreenState extends State<EventViewTicketScreen> {
  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;

    int timestamp = widget.data["startsAt"];
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    String formattedDate = DateFormat('dd MMMM, yyyy').format(dateTime);
    String startTime = DateFormat.jm().format(dateTime);
    int timestamp2 = widget.data["endsAt"];
    DateTime dateTime2 = DateTime.fromMillisecondsSinceEpoch(timestamp2 * 1000);
    String endTime = DateFormat.jm().format(dateTime2);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: color.backGroundClr,
      appBar: commonBarWithTextleft(context, Colors.transparent,"Ticket Details"),
      body: Container(
        margin: EdgeInsets.only(top:defaultTargetPlatform==TargetPlatform.iOS? 15:0),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage(AssetsPics.ticketbackground),fit: BoxFit.cover)),
        child: Stack(
          children: [
            Padding(
              padding:  EdgeInsets.only(left: 18,right: 18,top: 12.h),
              child: SizedBox(
                height: size.height,
                width: size.width,
                child: Column(
                  children: [
                    Card(
                      child: Container(
                        // height: 65.h,
                        // height: size.height*0.64,
                        padding: const EdgeInsets.only(left: 15,right: 15,top: 20),
                        width: size.width,
                        decoration: const BoxDecoration(
                          color: color.txtWhite,
                          border: Border(top: BorderSide(width: 5.0, color: color.txtBlue)),
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12),bottomRight: Radius.circular(12)),
                        ),
                        child: Stack(
                          children: [
                            // SvgPicture.asset("assets/icons/ticketsheet.svg",fit: BoxFit.cover,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              SizedBox(
                                // height: 28.h,
                                height: size.height*0.6/2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildText(widget.data["title"]+" - "+widget.data["type"], 24, FontWeight.w600, color.txtBlack),
                                    buildTextOverFlowwithMaxLine(widget.data["description"], 15, FontWeight.w500, color.txtgrey2,fontFamily: FontFamily.hellix),
                                ],),
                              ),
                              const MySeparator(height: 0.8,color: Color.fromRGBO(202, 223, 255, 1)),
                              SizedBox(
                                // height: 32.h,
                                child: Column(children: [ // SizedBox(height: 20),
                                  const SizedBox(height: 10),
                                  buildText(widget.data["country"], 18, FontWeight.w600, color.txtBlack),
                                  buildText(formattedDate, 15, FontWeight.w600, color.dropDowngreytxt,fontFamily: FontFamily.hellix),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          buildText("Start Time", 15, FontWeight.w600, color.dropDowngreytxt,fontFamily: FontFamily.hellix),
                                          buildText(startTime, 20, FontWeight.w600, color.txtBlack),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          buildText("End Time", 15, FontWeight.w600, color.dropDowngreytxt,fontFamily: FontFamily.hellix),
                                          buildText(endTime, 20, FontWeight.w600, color.txtBlack),
                                        ],
                                      ),
                                    ],),
                                  const SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          buildText("Total participant", 15, FontWeight.w600, color.dropDowngreytxt,fontFamily: FontFamily.hellix),
                                          buildText(widget.data["totalParticipants"].toString(), 20, FontWeight.w600, color.txtBlack),
                                        ],
                                      ),
                                      const SizedBox(),
                                    ],),
                                  const SizedBox(height: 15),
                                  const MySeparator(height: 0.8,color: Color.fromRGBO(202, 223, 255, 1)),
                                  const SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      buildText("Total price", 15, FontWeight.w600, color.dropDowngreytxt,fontFamily: FontFamily.hellix),
                                      buildText(widget.data["eventFee"]==0?"Free":widget.data["eventFee"].toString(), 20, FontWeight.w600, color.txtBlack),
                                    ],),
                                  const SizedBox(height: 15),
                                ],),
                              )
                            ],),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    bottomButton(context)
                  ],
                ),
              ),
            ),
             Positioned(
              left: 0.50,
              child: Padding(
                // padding: EdgeInsets.only(top:defaultTargetPlatform==TargetPlatform.iOS?80: 75),
                padding: EdgeInsets.only(top: size.height*0.6/2),
                child: SizedBox(
                  // height: 68.h,
                  height: size.height*0.6/2,
                  child: const CircleAvatar(
                    backgroundColor: color.backGroundClr,
                  ),
                ),
              ),
            ),
             Positioned(
              right: 0.50,
              child: Padding(
                // padding: EdgeInsets.only(top:defaultTargetPlatform==TargetPlatform.iOS?80: 75),
                padding: EdgeInsets.only(top: size.height*0.6/2),
                child: SizedBox(
                  // height: 68.h,
                  height:  size.height*0.6/2,
                  child: const CircleAvatar(
                    backgroundColor: color.backGroundClr,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget bottomButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: (){
              customDialogBoxWithtwobutton(context, "Are you sure you would like to cancel?", "Continuous cancellations with less\n than 24 hour notice may result in account suspension.",
                  img: AssetsPics.cancelticketpng,btnTxt1: "No",btnTxt2: "Cancel Event",
                  onTap2: (){callFunction();},isPng: true
              );
            },
            child: Container(
              alignment: Alignment.center,
              height: 56,
              width: MediaQuery.of(context).size.width/2-24,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                  color: color.txtWhite,
                  border: Border.all(width: 1.5,color: color.txtBlue)
              ),
              child: buildText("Cancel event",18,FontWeight.w600,color.txtBlue),
            ),
          ),
          GestureDetector(
            onTap: (){
              DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(widget.data["startsAt"] * 1000);
              DateTime timeFormat=DateTime.now();
              // int endTime=widget.data["endsAt"];
              int endTime=widget.data["startsAt"];
              int nowTimestamp = timeFormat.microsecondsSinceEpoch ~/ 1000000;
              var timee = DateTime.tryParse(dateTime.toString());
              int min = timee!.difference(timeFormat).inSeconds;
              if(min<900 ){
              // if(min>900){
                if(nowTimestamp<endTime){
                  Provider.of<waitingRoom>(context,listen: false).timerStart(min);
                  Get.to(()=> WaitingRoom(data: widget.data,min: min));}
              else{showToastMsg("Event already started");}
              }
              else{ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Waiting room will open before 15 min of event Start')));}
                // Get.to(()=>const EventYourTicketScreen());
            },
            child: Container(
              alignment: Alignment.center,
              height: 56,
              width: MediaQuery.of(context).size.width/2-24,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                  gradient:  const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
                    colors:[color.gradientLightBlue, color.txtBlue])
              ),
              child: buildText("Join event",18,FontWeight.w600,color.txtWhite,),
            ),
          ),
        ],),
    );
  }

  void callFunction(){
    setState(() {
      cancelEventBooking();
      // LocaleHandler.isThereAnyEvent=false;
      // LocaleHandler.isThereCancelEvent=true;
      // LocaleHandler.unMatchedEvent=false;
      // LocaleHandler.subScribtioonOffer=false;
      // Get.to(()=>BottomNavigationScreen());
    });
  }

  Future cancelEventBooking()async{
    final url="${ApiList.cancelEvent}${widget.data["eventId"].toString()}/cancel";
    print(url);
    var uri=Uri.parse(url);
    var response= await http.post(uri,headers: {'Content-Type': 'application/json',
      "Authorization": "Bearer ${LocaleHandler.accessToken}"
    });
    var i =jsonDecode(response.body);
    if(response.statusCode==201){print("testtest");
    setState(() {
      Provider.of<eventController>(context, listen: false).getmeEvent(context,"me");
      snackBaar(context,AssetsPics.redbanner,false);
      LocaleHandler.isThereAnyEvent=false;
      // LocaleHandler.isThereCancelEvent=false;
      LocaleHandler.unMatchedEvent=false;
      LocaleHandler.subScribtioonOffer=false;
      LocaleHandler.bottomSheetIndex=0;
      Get.offAll(()=>BottomNavigationScreen());
    });
    }
    else if(response.statusCode==401){showToastMsgTokenExpired();}
    else{Fluttertoast.showToast(msg: i["message"]);
    Get.back();
    }
  }
}
