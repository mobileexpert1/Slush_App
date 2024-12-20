import 'dart:convert';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/screens/events/free_event.dart';
import 'package:slush/screens/events/you_ticket.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:http/http.dart'as http;
import 'package:slush/widgets/toaster.dart';

class MyEventListScreen extends StatefulWidget {
  MyEventListScreen({Key? key,required this.myEvent,required this.pageNum}) : super(key: key);
  final bool myEvent;
  final int pageNum;
  @override
  State<MyEventListScreen> createState() => _MyEventListScreenState();
}

class _MyEventListScreenState extends State<MyEventListScreen> {
  var data;
  int totalpages=0;
  int totalitems=-1;
  int currentpage=0;
  List post=[];
  int _page = 1;
  bool _isLoadMoreRunning=false;
  bool _hasNextPage = true;
  ScrollController? _controller;
  String eventType="";

  getEventList()async{
    final url= "${ApiList.getEvent}${LocaleHandler.miliseconds}&distance=${LocaleHandler.distancee}$eventType&latitude=${LocaleHandler.latitude}&longitude=${LocaleHandler.longitude}&page=1&limit=10";
    print(url);
    var uri=Uri.parse(url);
    var response=await http.get(uri,
        headers: {'Content-Type':'application/json', 'Authorization':'Bearer ${LocaleHandler.accessToken}'});
    if(response.statusCode==200){
      setState(() {data=jsonDecode(response.body)["data"];});
      totalpages=data["meta"]["totalPages"];
      totalitems=data["meta"]["totalItems"];
      currentpage=data["meta"]["currentPage"];
      post=data["items"];
    }
    else if(response.statusCode==401){showToastMsgTokenExpired();}
    else{Fluttertoast.showToast(msg: 'Something Went Wrong');
    setState(() {data="no data";});}
  }

  Future loadmore()async{
    // if(widget.myEvent){
      // Map<String,dynamic> lists = {"items":widget.myEventData};
      // data=lists;
      // post=lists["items"];
    // }
    if (_page<totalpages&& _hasNextPage == true &&  _isLoadMoreRunning == false &&
        currentpage<totalpages&& _controller!.position.extentAfter < 300) {
      setState(() {_isLoadMoreRunning=true;});
      _page=_page+1;
      final url="${ApiList.getEvent}${LocaleHandler.miliseconds}&distance=${LocaleHandler.distancee}&events=$eventType&latitude=${LocaleHandler.latitude}&longitude=${LocaleHandler.longitude}&page=$_page&limit=10";
      print(url);
      var uri=Uri.parse(url);
      var response=await http.get(uri, headers: {'Content-Type':'application/json', 'Authorization':'Bearer ${LocaleHandler.accessToken}'});
      setState(() {_isLoadMoreRunning=false;});
      if(response.statusCode==200){
        setState(() {
          var data = jsonDecode(response.body)['data'];
          currentpage=data["meta"]["currentPage"];
          final List fetchedPosts = data["items"];
          if (fetchedPosts.isNotEmpty) {setState(() {post.addAll(fetchedPosts);});}
        });
      }}
  }

  @override
  void initState() {
    _page=widget.pageNum;
    // post=widget.myEventData;
    eventType=widget.myEvent?"&events=me":"";
    getEventList();
    _controller = ScrollController()..addListener(loadmore);
    super.initState();
  }

  void tapped(int index){
    if(widget.myEvent){
      setState(() {
        LocaleHandler.isProtected = data["items"][index]["hasPassword"];
        LocaleHandler.freeEventImage = data["items"][index]["coverImage"];
      });
      sendtoEventDetail(data["items"],index);
      // Get.to(()=>EventYourTicketScreen(eventId: data["items"][index]["eventId"]));
    }
    else {
      setState(() {
        LocaleHandler.isProtected = data["items"][index]["hasPassword"];
        LocaleHandler.freeEventImage = data["items"][index]["coverImage"];
      });
      bool isParticipant = false;
      var dataa = data["items"][index]["participants"];
      var i;
      for (i = 0; i < dataa.length; i++) {
        if (dataa[i]["user"]["userId"].toString() == LocaleHandler.userId) {
          setState(() {
            isParticipant = true;
          });
          break;
        }
      }
      if (isParticipant) {
        Get.to(() => EventYourTicketScreen(eventId: data["items"][index]["eventId"]));
      } else {
        Get.to(() => EvenetFreeScreen(eventId: data["items"][index]["eventId"]));
      }
    }
  }

  void sendtoEventDetail(var item,int index){
    LocaleHandler.eventId=item[index]["eventId"];
    setState(() {
      LocaleHandler.isProtected = item[index]["hasPassword"];
      LocaleHandler.freeEventImage = item[index]["coverImage"];
    });
    bool isParticipant = false;
    var dataa = item[index]["participants"];
    var i;
    for (i = 0; i < dataa.length; i++) {
      if (dataa[i]["user"]["userId"].toString() == LocaleHandler.userId) {
        setState(() {
          isParticipant = true;
        });
        break;
      }
    }
    if (isParticipant) {
      Get.to(() => EventYourTicketScreen(eventId: item[index]["eventId"]))!.then((value) {setState(() {});});
    } else {Get.to(() => EvenetFreeScreen(eventId: data["items"][index]["eventId"]));
    }
  }


  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      // backgroundColor: color.backGroundClr,
      appBar: commonBarWithTextleft(context, color.backGroundClr,widget.myEvent?"My Event List": "Event List"),
      body: Stack(
        children: [
          SizedBox(height: size.height, width: size.width, child: Image.asset(AssetsPics.background,fit: BoxFit.cover),),
          post.isNotEmpty?
          SingleChildScrollView(
            controller: _controller,
            child: Padding(padding: const EdgeInsets.only(left: 15,right: 15,top: 20),
              child: Column(children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 50),
                  padding: const EdgeInsets.only(left: 15,right: 15),
                  decoration: BoxDecoration(color: color.txtWhite,borderRadius: BorderRadius.circular(12)),
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: post.length,
                      padding: const EdgeInsets.only(top: 10,bottom: 10),
                      itemBuilder: (context,index){
                        int timestamp = post[index]["startsAt"];
                        DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
                        String formattedDate = DateFormat('dd').format(dateTime);
                        String formattedmon = DateFormat('MMM').format(dateTime);
                        String formattedTime = DateFormat.jm().format(dateTime);
                        return
                          GestureDetector(
                            onTap: (){tapped(index);},
                            child: Container(color: Colors.transparent,
                              child: Column(children: [
                                Row(children: [
                                  imagewithdate(index,formattedDate,formattedmon),
                                  const SizedBox(width: 9),
                                  details(index,formattedTime)
                                ],),
                                index==post.length-1 ?const SizedBox():const Divider(color: color.lightestBlue),
                              ],),
                            ),
                          );
                      }),
                ),
                _isLoadMoreRunning? const Center(child: CircularProgressIndicator(color: color.txtBlue)):const SizedBox(),
              ],),
            ),
          )
              :totalitems==0?Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top:160.0,
                  child: Container(
                    // color: Colors.red,
                      height: 22.h,
                      width: 23.h,
                      alignment: Alignment.center,
                      child: SvgPicture.asset(AssetsPics.bigheart,fit: BoxFit.cover,)),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 15.h),
                    Stack(
                      children: [
                        Positioned(
                          left: 130,
                          child: Container(
                            alignment: Alignment.center,
                            child: SvgPicture.asset(AssetsPics.threeDotsLeft),),
                        ),
                        Container(
                            margin: const EdgeInsets.only(top: 20,left: 20),
                            alignment: Alignment.center,
                            child:Image.asset(AssetsPics.noevent)),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    buildText("No events yet? ", 30, FontWeight.w600, color.txtBlue),
                    SizedBox(height: 2.h),
                    buildText2("There is no new event yet.", 18, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
                    SizedBox(height: 25.h)
                  ],
                ),
              ],
            ),
          ):
          const Center(child: CircularProgressIndicator(color: color.txtBlue))
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
          border: Border.all(width: 1,color: color.disableButton)
      ),
      child: buildText(btntxt, 16, FontWeight.w600, color.txtBlack),
    );
  }

  Column details(int index,String time) {
    final size=MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            margin: const EdgeInsets.only(bottom: 5),
            width: size.width*0.48,child: buildTextOverFlow(post[index]["title"]+" - "+post[index]["type"], 16, FontWeight.w600, color.txtBlack)),
        Row(children: [
          SvgPicture.asset(AssetsPics.blueMapPoint),
          const SizedBox(width: 4),
          SizedBox(
               width: size.width*0.44,
              child: buildTextOverFlow(post[index]["country"], 13, FontWeight.w500, color.txtgrey2,fontFamily: FontFamily.hellix)),
        ],),
        const SizedBox(height: 4),
        Row(children: [
          SvgPicture.asset(AssetsPics.blueClock),
          const SizedBox(width: 4),
          buildTextOverFlow(time, 13, FontWeight.w500, color.txtgrey2,fontFamily: FontFamily.hellix),
        ],),
      ],);
  }

  Widget imagewithdate(int index,String date,String mon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 3,top: 3),
      height: 84,
      width: 118,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(height: 84, width: 118,
            // child: Image.asset(historyItem[index].img,fit: BoxFit.fill),
            child: CachedNetworkImage(fit: BoxFit.fill, imageUrl: post[index]["coverImage"]),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 5,top: 4),
          // height:44,
          width: 46,
          decoration: BoxDecoration(color: color.txtWhite,borderRadius: BorderRadius.circular(8)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // buildText("Nov", 15, FontWeight.w600, color.txtBlack,fontFamily: FontFamily.hellix),
              buildText2( "$date\n$mon", 16, FontWeight.w600, color.txtBlack,fontFamily: FontFamily.hellix),
            ],),
        ),

      ],),
    );
  }
}

