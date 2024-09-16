import 'dart:convert';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:slush/constants/localkeys.dart';
import 'package:slush/constants/prefs.dart';
import 'package:slush/controller/event_controller.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/text_widget.dart';

class EvenetSuscribeScreen extends StatefulWidget {
  const EvenetSuscribeScreen({Key? key,required this.data}) : super(key: key);
  final data;

  @override
  State<EvenetSuscribeScreen> createState() => _EvenetFreeScreenState();
}

class _EvenetFreeScreenState extends State<EvenetSuscribeScreen> {
  FocusNode passNode=FocusNode();
  bool saved=false;
  String formattedDate="";
  String formattedTime="";

  @override
  void initState() {
    getTime();
    super.initState();
  }

  void getTime(){
    int timestamp = widget.data["startsAt"];
    int timestamp2 = widget.data["endsAt"];
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    DateTime dateTime2 = DateTime.fromMillisecondsSinceEpoch(timestamp2 * 1000);
    formattedDate = DateFormat('dd MMMM, yyyy').format(dateTime);
    String formattedDay=DateFormat('EEEE').format(dateTime);
    String formattedstart=DateFormat.jm().format(dateTime);
    String formattedend=DateFormat.jm().format(dateTime2);
    formattedTime = "$formattedDay, $formattedstart - $formattedend";
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      // backgroundColor: color.backGroundClr,
      body: Stack(
        children: [
          SizedBox(
            height: size.height,
            width: size.width,
            child: Image.asset(AssetsPics.background,fit: BoxFit.cover,),
          ),
          SingleChildScrollView(
            child: Column(
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
              width: size.width,child: CachedNetworkImage(imageUrl: widget.data["coverImage"],fit: BoxFit.cover)),
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
                        if(LocaleHandler.items.contains(widget.data["eventId"]))
                        {eventCntrller.saveEvent(ApiList.unsaveEvent, widget.data["eventId"].toString());
                          LocaleHandler.items.remove(widget.data["eventId"]);}
                        else{eventCntrller.saveEvent(ApiList.saveEvent, widget.data["eventId"].toString());
                          LocaleHandler.items.add(widget.data["eventId"]);}
                        setState(() {});
                        Preferences.setValue("EventIds", jsonEncode(LocaleHandler.items));
                      },
                      child: CircleAvatar(
                          radius: 18,
                          backgroundColor: color.txtWhite,
                          child: SvgPicture.asset(LocaleHandler.items.contains(widget.data["eventId"])?AssetsPics.eventbluesaved:AssetsPics.greysaved)),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: size.width*0.8,child: buildText(widget.data["title"]+" - "+widget.data["type"], 28, FontWeight.w600, color.txtBlack)),
              SizedBox(
                  height: 3.h+1,width: 24,
                  child:widget.data["hasPassword"]? SvgPicture.asset(AssetsPics.lock):const SizedBox())
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
            buildText(widget.data["country"], 18, FontWeight.w600, color.txtBlack),
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
            buildText(widget.data["description"], 16, FontWeight.w500, color.txtgrey2,fontFamily: FontFamily.hellix),
          ],),
      ),
      const Divider(thickness: 0.7,color: color.lightestBlue),

    ],);
  }

  Widget imageList() {
    return SizedBox(
      height: 9.h,
      child:widget.data["participants"].length==0?SizedBox(): ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.only(left: 15),
          scrollDirection: Axis.horizontal,
          itemCount: widget.data["participants"].length
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
                  child: CachedNetworkImage(imageUrl: widget.data["participants"][index]["user"]["profilePictures"][0]["key"],fit: BoxFit.cover),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildText("FREE", 25, FontWeight.w600, color.txtBlack),
            GestureDetector(
              onTap: (){
                bottomSHeet();
              },
              child: Container(
                alignment: Alignment.center,
                height: 7.h,
                padding: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                  color: color.subscribeButton
                ),
                child: buildText("Waiting list",18,FontWeight.w600,color.txtWhite),
              ),
            )
          ],),
      ),
    );
  }

  void bottomSHeet(){
    customDialogBox(context: context,
        title: 'Join waiting list',
        secontxt: "",
        heading: "This event is full and you have now joined the waiting list, if someone drops out, we will notify you!",
        btnTxt: "Ok",
        // onTap: (){},
        onTapp: (){},
        img: AssetsPics.mailImg2);
  }
}
