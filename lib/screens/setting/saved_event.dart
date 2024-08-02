import 'dart:convert';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/screens/events/free_event.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:http/http.dart'as http;
import 'package:slush/widgets/toaster.dart';

class MySavedEvent extends StatefulWidget {
  MySavedEvent({Key? key}) : super(key: key);

  @override
  State<MySavedEvent> createState() => _MyEventListScreenState();
}

class _MyEventListScreenState extends State<MySavedEvent> {
  var data;
  bool isFree = false;

  // getEventList(){
  //   if(LocaleHandler.items.length!=0){
  //     var i=0;
  //     for(i;i<LocaleHandler.items.length;i++){
  //       // getEventDetail(LocaleHandler.items[i]);
  //     }
  //   }
  // }
  //
  // Future getEventDetail(int id)async{
  //   print(LocaleHandler.accessToken);
  //   final url=ApiList.eventDetail+id.toString();
  //   print(url);
  //   var uri=Uri.parse(url);
  //   var response=await http.get(uri,
  //       headers: {'Content-Type': 'application/json', "Authorization": "Bearer ${LocaleHandler.accessToken}"});
  //   var i=jsonDecode(response.body);
  //   if(response.statusCode==200){
  //     setState(() {data=i["data"];
  //       LocaleHandler.itemss.add(i["data"]);});
  //   }
  //   else if(response.statusCode==401){showToastMsgTokenExpired();}
  //   else{}
  // }

  Future savedEvents()async{
    final url=ApiList.savedEvents;
    print(url);
    var response= await http.post(Uri.parse(url),
      headers: <String,String>{'Content-Type': 'application/json',
        'Authorization': 'Bearer ${LocaleHandler.accessToken}'},
    );
    print("Response ----------- -----------${response.statusCode}");
    if(response.statusCode==201){
      data=jsonDecode(response.body);
      setState((){});
      return "Ok";
    } else if(response.statusCode==401){showToastMsgTokenExpired();}
    else {return  Error();}
  }

  @override
  void initState() {
    // LocaleHandler.itemss.clear();
    // getEventList();
    savedEvents();
    super.initState();
  }
  void tapped(int index){
    setState(() {
      LocaleHandler.isProtected = data[index]["event"]["isFree"];
      LocaleHandler.freeEventImage = data[index]["event"]["coverImage"];
    });
    Get.to(() => EvenetFreeScreen(eventId: data[index]["event"]["eventId"]))!.then((value) {savedEvents();});
  }
  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      // backgroundColor: color.backGroundClr,
      appBar: commonBarWithTextleft(context, color.backGroundClr,"My Saved Event List"),
      body: data==null ? Center(child: CircularProgressIndicator(color: color.txtBlue)) :Stack(
        children: [
          SizedBox(height: size.height, width: size.width, child: Image.asset(AssetsPics.background,fit: BoxFit.cover),),
          data.length==0?Center(child:// CircularProgressIndicator(color: color.txtBlue)
          buildText("No Saved Event",16,FontWeight.w500,color.txtBlue)
          ):
          SingleChildScrollView(
            child: Padding(padding: const EdgeInsets.only(left: 15,right: 15,top: 20),
              child: Column(children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 50),
                  padding: const EdgeInsets.only(left: 15,right: 15),
                  decoration: BoxDecoration(color: color.txtWhite,borderRadius: BorderRadius.circular(12)),
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: data.length,
                      padding: const EdgeInsets.only(top: 10,bottom: 10),
                      itemBuilder: (context,index){
                        int timestamp = data[index]["event"]["startsAt"];
                        DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
                        String formattedDate = DateFormat('dd').format(dateTime);
                        String formattedmon = DateFormat('MMM').format(dateTime);
                        String formattedTime = DateFormat.jm().format(dateTime);
                        return GestureDetector(
                          onTap: (){tapped(index);},
                          child: Column(children: [
                            Row(children: [
                              imagewithdate(index,formattedDate,formattedmon),
                              const SizedBox(width: 10),
                              details(index,formattedTime)
                            ],),
                            index==data.length-1 ?const SizedBox():const Divider(color: color.lightestBlue),
                          ],),
                        );
                      }
                  ),
                )
              ],),
            ),
          ),
        ],
      ),
    );
  }

  Widget selectedButton(String btntxt) {
    return Container(
      padding: const EdgeInsets.only(left: 18,right: 18,top: 6,bottom: 6),
      margin: const EdgeInsets.only(right: 4,left: 4),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          gradient:  const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
            colors:[color.gradientLightBlue, color.txtBlue],)
      ),
      child: buildText(btntxt, 16, FontWeight.w600, color.txtWhite),
    );
  }

  Widget unselectedButton(String btntxt) {
    return Container(
      padding: const EdgeInsets.only(left: 18,right: 18,top: 6,bottom: 6),
      margin: const EdgeInsets.only(right: 4,left: 4),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
              width: 1,color: color.disableButton
          )
      ),
      child: buildText(btntxt, 16, FontWeight.w600, color.txtBlack),
    );
  }

  Column details(int index,String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            margin: const EdgeInsets.only(bottom: 5),
            width: 170,child: buildTextOverFlow(data[index]["event"]["title"]+" - "+data[index]["event"]["type"], 16, FontWeight.w600, color.txtBlack)),
        Row(
          children: [
            SvgPicture.asset(AssetsPics.blueClock,color: Colors.transparent,),const SizedBox(width: 2),
            buildText(data[index]["event"]["gender"], 14, FontWeight.w500, color.txtgrey2,fontFamily: FontFamily.hellix),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(AssetsPics.blueClock),
            const SizedBox(width: 4),
            buildTextOverFlow(time, 13, FontWeight.w500, color.txtgrey2,fontFamily: FontFamily.hellix),
            const SizedBox(width: 40),
            buildTextOverFlow(data[index]["event"]["isFree"]==true? "" : "£", 13, FontWeight.w600, color.txtgrey2,fontFamily: FontFamily.hellix),
            const SizedBox(width: 1),
            buildTextOverFlow(data[index]["event"]["isFree"]==false? data[index]["event"]["eventFee"].toString() : "Free", 13, FontWeight.w500, color.txtgrey2,fontFamily: FontFamily.hellix),

          ],),
      ],);
  }

  Widget imagewithdate(int index,String date,String mon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 3,top: 3),
      height: 84,
      width: 118,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 84,
            width: 118,
            // child: Image.asset(historyItem[index].img,fit: BoxFit.fill),
            child: CachedNetworkImage(fit: BoxFit.fill, imageUrl: data[index]["event"]["coverImage"]),

          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 5,top: 4),
          // height:44,
          width: 42,
          decoration: BoxDecoration(color: color.txtWhite,borderRadius: BorderRadius.circular(8)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // buildText("30", 15, FontWeight.w600, color.txtBlack,fontFamily: FontFamily.hellix),
              // Text("30"),
              // Text("30"),
              // buildText("Nov", 15, FontWeight.w600, color.txtBlack,fontFamily: FontFamily.hellix),
              // buildText2(date, 15, FontWeight.w600, color.txtBlack,fontFamily: FontFamily.hellix),
              buildText2( "$date\n$mon", 16, FontWeight.w600, color.txtBlack,fontFamily: FontFamily.hellix),
            ],),
        ),

      ],),
    );
  }
}