import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart'as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/prefs.dart';
import 'package:slush/controller/event_controller.dart';
import 'package:slush/screens/events/bottomNavigation.dart';
import 'package:slush/screens/events/event_subscribe.dart';
import 'package:slush/screens/events/payment_history.dart';
import 'package:slush/screens/events/view_ticket.dart';
import 'package:slush/screens/events/you_ticket.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:slush/widgets/toaster.dart';
import 'package:intl/intl.dart';

class EvenetFreeScreen extends StatefulWidget {
  final eventId;
  const EvenetFreeScreen({Key? key,required this.eventId}) : super(key: key);

  @override
  State<EvenetFreeScreen> createState() => _EvenetFreeScreenState();
}

class _EvenetFreeScreenState extends State<EvenetFreeScreen> {
  FocusNode passNode=FocusNode();
  TextEditingController cntl=TextEditingController(text: "");

  @override
  void initState() {
    getEventDetail();
    passNode.addListener(() {
      if(passNode.hasFocus){
        LocaleHandler.passwordField=true;
      }else{
        LocaleHandler.passwordField=false;
      }
    });
    super.initState();
  }
  String formattedDate="";
  String formattedTime="";
  var data;
  bool isParticipant=false;
  bool inwaitlist=false;

  Future getEventDetail()async{
    print(LocaleHandler.accessToken);
    final url=ApiList.eventDetail+widget.eventId.toString();
    print(url);
    var uri=Uri.parse(url);
    var response=await http.get(uri,
    headers: {'Content-Type': 'application/json', "Authorization": "Bearer ${LocaleHandler.accessToken}"});
    var i=jsonDecode(response.body);
    if(response.statusCode==200){
      setState(() {data=i["data"];});
      int timestamp = data["startsAt"];
      int timestamp2 = data["endsAt"];
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      DateTime dateTime2 = DateTime.fromMillisecondsSinceEpoch(timestamp2 * 1000);
      formattedDate = DateFormat('dd MMMM, yyyy').format(dateTime);
      String formattedDay=DateFormat('EEEE').format(dateTime);
      String formattedstart=DateFormat.jm().format(dateTime);
      String formattedend=DateFormat.jm().format(dateTime2);
      formattedTime = "$formattedDay, $formattedstart - $formattedend";
      for(var i=0;i<data["participants"].length;i++)
        {data["participants"][i]["user"]["userId"];
          if(data["participants"][i]["user"]["userId"].toString()==LocaleHandler.userId){
            setState(() {isParticipant=true;});
            print(isParticipant);
            break;
          }
        }
      if(isParticipant==false){
        var ii;
        for(ii=0;ii<data["waitlist"].length;ii++)
        {{if(data["waitlist"][ii]["user"]["userId"].toString()==LocaleHandler.userId){
          setState(() {inwaitlist=true;});break;
        }}}}
    }
    else if(response.statusCode==401){showToastMsgTokenExpired();}
    else{}
  }

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return  isParticipant?EventYourTicketScreen(eventId: widget.eventId):inwaitlist?EvenetSuscribeScreen(data: data): Scaffold(
      // backgroundColor: color.backGroundClr,
      body: Stack(
        children: [
          SizedBox(
            height: size.height,
            width: size.width,
            child: Image.asset(AssetsPics.background,fit: BoxFit.cover),
          ),
          SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child:data==null?Center(child: Padding(
              padding: const EdgeInsets.only(top: 300),
              child: CircularProgressIndicator(color:color.txtBlue ),
            ),): Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              imagesSection(size),
              aboutSection(size),
              Padding(padding: const EdgeInsets.only(left: 15,right: 15,top: 8,bottom: 15),
              child: buildText("Event participants", 18, FontWeight.w600, color.txtBlack),),
                imageList(),
                 SizedBox(height: 13.h,width: 13.h)
            ],),
          ),
          bottomBooksection(size)
        ],
      ),
    );
  }

  Widget imagesSection(Size size) {
    final eventCntrller=Provider.of<eventController>(context,listen: false);
    return SizedBox(
        height: 246,
        width: size.width,
        child: Stack(
          children: [
            SizedBox(
                height: 246,
                width: size.width,child: CachedNetworkImage(imageUrl: LocaleHandler.freeEventImage,fit: BoxFit.cover)),
            IgnorePointer(child: Container(width: MediaQuery.of(context).size.width,
                child: SvgPicture.asset(AssetsPics.eventbg,fit: BoxFit.cover))),
            Container(
              padding: const EdgeInsets.only(left: 20,right: 20,top: 50),
              child: Column(
                children: [
                  Row(
                    children: [
                    GestureDetector(
                        onTap: (){
                          Get.back();
                        },
                        child: Container(
                            // color: Colors.red,
                            child: SvgPicture.asset(AssetsPics.whitearrowleft))),
                    const Spacer(),
                    GestureDetector(
                      onTap: (){
                        // Get.to(()=>PaymentHistoryScreen());
                        if(LocaleHandler.items.contains(data["eventId"]))
                        {eventCntrller.saveEvent(ApiList.unsaveEvent, data["eventId"].toString());
                          LocaleHandler.items.remove(data["eventId"]);}
                        else{
                          eventCntrller.saveEvent(ApiList.saveEvent, data["eventId"].toString());
                          LocaleHandler.items.add(data["eventId"]);}
                        setState(() {});
                        Preferences.setValue("EventIds", jsonEncode(LocaleHandler.items));
                      },
                      child: CircleAvatar(
                          radius: 18,
                          backgroundColor: color.txtWhite,
                          child: SvgPicture.asset(LocaleHandler.items.contains(data["eventId"])?AssetsPics.eventbluesaved:AssetsPics.greysaved)),
                    ),
                  ],),
                ],
              ),
            ),
          ],
        ),
      );
  }

  Widget headlines(Size size) {
    return SizedBox(
      width: size.width,
      child:
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildText(data["title"]+" - "+data["type"], 28, FontWeight.w600, color.txtBlack),
            SizedBox(
              height: 3.h+1,width: 24,
                child:data["hasPassword"]? SvgPicture.asset(AssetsPics.lock):const SizedBox())
            ],
          ),
          const SizedBox(height: 10),
          Row(children: [
            SvgPicture.asset(AssetsPics.evntfreeicon),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // buildText("30 November, 2023", 18, FontWeight.w600, color.txtBlack),
                buildText(formattedDate, 18, FontWeight.w600, color.txtBlack),
                // buildText("Tuesday, 10:00AM - 11:03AM", 14, FontWeight.w600, color.dropDowngreytxt,fontFamily: FontFamily.hellix),
                buildText(formattedTime, 14, FontWeight.w600, color.dropDowngreytxt,fontFamily: FontFamily.hellix),
              ],)
          ],),
          const SizedBox(height: 12),
          Row(children: [
            SvgPicture.asset(AssetsPics.eventmappoint),
            const SizedBox(width: 12),
            // buildText("London, UK", 18, FontWeight.w600, color.txtBlack),
            buildText(data["country"], 18, FontWeight.w600, color.txtBlack),
          ],),
        ],),);
  }

  Widget aboutSection(Size size) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.only(left: 15,right: 15,top: 20,bottom: 14),
        child: headlines(size),
      ),
      const Divider(thickness: 0.7,color: color.lightestBlue),
      Container(
        padding: const EdgeInsets.only(left: 15,right: 15,top: 10,bottom: 9),
        width: size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildText("About Event", 18, FontWeight.w600, color.txtBlack),
            SizedBox(height: 5),
            buildText(data["description"], 16, FontWeight.w500, color.txtgrey2,fontFamily: FontFamily.hellix),
          ],),
      ),
      const Divider(thickness: 0.7,color: color.lightestBlue),

    ],);
  }

  Widget imageList() {
    return SizedBox(
      height: 9.h,
      child:data["participants"].length==0?SizedBox(): ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.only(left: 15),
          scrollDirection: Axis.horizontal,
          itemCount: data["participants"].length
          ,itemBuilder: (context,index){
        return Container(
            margin: const EdgeInsets.only(right: 10),
            width: 70,
            child:  ClipRRect(
                borderRadius: BorderRadius.circular(12),
                // child: Image.asset(AssetsPics.eventProfile,fit: BoxFit.cover),
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                // child: Image.asset(AssetsPics.eventProfile, fit: BoxFit.cover),
                child: CachedNetworkImage(imageUrl: data["participants"][index]["user"]["profilePictures"][0]["key"],fit: BoxFit.cover),
              )
            )
        );
      }),
    );
  }

  Widget bottomBooksection(Size size) {
    return Positioned(
      bottom: 0.0,
      child: Container(
        alignment:defaultTargetPlatform==TargetPlatform.iOS? Alignment.topCenter:Alignment.center,
        height: 10.h,
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 8),
        width: size.width,
        color: color.txtWhite,
        child:data==null?SizedBox(): Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
           data["isFree"]? buildText("FREE", 25, FontWeight.w600, color.txtBlack):
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                 buildText("\$"+data["eventFee"].toString(), 20, FontWeight.w600, color.txtBlack),
                 Flexible(child: buildText("Join our event", 16, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix)),
               ],),
            GestureDetector(
              onTap: (){
             bottomSHeet();
              },
              child: Container(
                alignment: Alignment.center,
                height: 7.h,
                padding: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                    gradient:  const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
                      colors:[color.gradientLightBlue, color.txtBlue],)
                ),
                child: buildText(data["isFree"]?"Book now":"Subscribe",18,FontWeight.w600,color.txtWhite),
              ),
            )
          ],),
      ),
    );
  }

  void bottomSHeet(){
    if(data["isFree"]==false){
      customDialogBoxTextField(context, "Passport protected.", "Confirm",passNode,
          heading: "This event is password protected. Please contact the organiser.",img: AssetsPics.lockImg, onchng: (val){
            cntl.text=val;
          },cntroller: cntl,onTapbutton: (){
        FocusManager.instance.primaryFocus?.unfocus();
        if(cntl.text.trim()==data["password"]){
          Get.back();
          if(isParticipant){
            customDialogBoxWithtwobutton(context, "Already In", "Your are already joined this event",
                img: AssetsPics.bookconfirmpng,
                btnTxt1: "Go to home",btnTxt2: "View ticket",onTap2: (){Get.back();
                Get.to(()=> EventViewTicketScreen(data: data));
                },isPng: true);
          }else{bookEvent();}
          // setState(() {cntl.clear();});
        }else{showToastMsg("Incorrect Password");}
          });
    }else{
    customDialogBoxWithtwobutton(context, "Confirm your booking", "Please confirm you would like to\n book this event.",isPng: true,img: AssetsPics.freeEventbookpng,
        btnTxt1: "Cancel",btnTxt2: "Book",onTap2: (){
      Get.back();
      if(isParticipant){
        customDialogBoxWithtwobutton(context, "Already In", "Your are already joined this event",
            img: AssetsPics.bookconfirmpng,
            btnTxt1: "Go to home",btnTxt2: "View ticket",onTap2: (){Get.back();
            Get.to(()=> EventViewTicketScreen(data: data));
            },isPng: true);
      }else{bookEvent();}
        });}
  }

  Future bookEvent()async{
    Map<String, dynamic> formdata={
      "eventId": widget.eventId,
      "password": cntl.text.trim()
    };
    final url=ApiList.eventBook;
    var uri=Uri.parse(url);
    print(url);
    var response = await http.post(uri,
    headers:{'Content-Type': 'application/json',
      "Authorization":"Bearer ${LocaleHandler.accessToken}"},
      body: jsonEncode(formdata));
    var dataa=jsonDecode(response.body);
    if(response.statusCode==201){
      getEventDetail();

      customDialogBoxWithtwobutton(context, "You’re in!", "Your event has been booked successfully.",
          img: AssetsPics.bookconfirmpng,
          btnTxt1: "Go to home",btnTxt2: "View ticket",onTap2: (){Get.back();
            Get.to(()=> EventViewTicketScreen(data: data));
          },isPng: true);
    }else if(dataa["message"]=="Unauthorized"){showToastMsgTokenExpired();} else{
      // customWarningBox(context, dataa["error"], dataa["message"],
      customWarningBox(context, "Event not booked!", dataa["message"],
          img: AssetsPics.freeEventbookpng, isPng: true);
    }
  }
}
