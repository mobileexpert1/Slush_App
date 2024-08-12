import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/loader.dart';
import 'package:slush/controller/event_controller.dart';
import 'package:slush/screens/chat/text_chat_screen.dart';
import 'package:slush/screens/events/bottomNavigation.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart'as http;
import 'package:slush/widgets/toaster.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  bool isListEmpty=true;
  bool itemDelted=false;

  @override
  void initState() {
    _startTimer();
    _controller = ScrollController()..addListener(loadmore);
    super.initState();
  }

  void futuredelayed(int i,bool val){
    Future.delayed(Duration(seconds: i),(){
      setState(() {
        itemDelted=val;
      });});
  }

  List data=[];
  int totalpages=0;
  int currentpage=0;
  int totalItems=-1;
  int _page=1;
  bool _isLoadMoreRunning=false;
  ScrollController? _controller;


  Future getChat()async{
    final url="${ApiList.getSingleChat}?page=$_page&limit=50";
    print(url);
    var uri =Uri.parse(url);
    var response=await http.get(uri,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${LocaleHandler.accessToken}'});
    var i =jsonDecode(response.body)["data"];
    if(response.statusCode==200){
      setState(() {data=i["items"];
      if(i["meta"]["totalItems"]==0){isListEmpty=true;}else{isListEmpty=false;}
      totalpages=i["meta"]["totalPages"];
      totalItems=i["meta"]["totalItems"];
      currentpage=i["meta"]["currentPage"];
      if(totalItems==0){data.length=1;}
      });}
    else if(response.statusCode==401){showToastMsgTokenExpired();}
    else{}
  }

  Future loadmore()async{
    if (_page<totalpages&& _isLoadMoreRunning == false && currentpage<totalpages&& _controller!.position.extentAfter < 300) {
      setState(() {_isLoadMoreRunning=true;});
      _page=_page+1;
      final url="${ApiList.getSingleChat}?page=$_page&limit=50";
      print(url);
      var uri =Uri.parse(url);
      var response=await http.get(uri, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${LocaleHandler.accessToken}'});
      setState(() {_isLoadMoreRunning=false;});
      if(response.statusCode==200){
        setState(() {
          var i = jsonDecode(response.body)['data'];
          currentpage=i["meta"]["currentPage"];
          final List fetchedPosts = i["items"];
          if (fetchedPosts.isNotEmpty) {setState(() {data.addAll(fetchedPosts);});}
        });
      }}
  }

  Timer? _timer;
  void _startTimer() {
    getChat();
    _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
      getChat();
    });
  }
  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  void chatDelete(int id,int i)async{
    final url="${ApiList.getSingleChat}$id/deleteconversation";
    print(url);
    var uri =Uri.parse(url);
    var response=await http.get(uri,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${LocaleHandler.accessToken}'});
    if(response.statusCode==200){
      snackBaar(context,AssetsPics.removed,false);
      setState(() {data.removeAt(i);});
    }
    else{}
  }

   SlidableController ? _slidableController ;
  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return RefreshIndicator(
      displacement: 100,
      backgroundColor: color.txtWhite,
      color: color.txtBlue,
      strokeWidth: 3,
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 4));
          _page=1;
          getChat();
        },
    child: Scaffold(
      // extendBodyBehindAppBar: true,
      // appBar:itemDelted?null: commonBarWithTextleft(context, Colors.transparent, "Chat"),
      body: Stack(children: [
        SizedBox(
          height: size.height,
          width: size.width,
          child: Image.asset(AssetsPics.background,fit: BoxFit.cover,),
        ),
        data.isEmpty? const Center(child: CircularProgressIndicator(color: color.txtBlue)): SafeArea(
          child: SingleChildScrollView(
            controller: _controller,
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20,top: 22),
                  child: buildText("Chat", 25, FontWeight.w600, color.txtBlack),
                ),
                Padding(
                  padding:  EdgeInsets.only(left: 15,top:itemDelted?9.h: 2.h,bottom: 5),
                  child: buildText(" Matches", 20, FontWeight.w600, color.txtBlack),
                ),
                SizedBox(
                    height: isListEmpty?0:85,
                    child: ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(left: 15),
                        itemCount: data.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          var items=data;
                          var personData=items[index]==null?"":  items[index]["sender"]["userId"].toString()==LocaleHandler.userId?items[index]["receiver"]:items[index]["sender"];
                          return personData==""?SizedBox(): Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 0,
                                    blurRadius: 1,
                                    offset: const Offset(0,0), // changes position of shadow
                                  ),
                                ],
                                color: color.example2,
                                borderRadius: BorderRadius.circular(8)
                            ),
                            margin: const EdgeInsets.all(5),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child:personData["profilePictures"].isEmpty?Image.asset(AssetsPics.demouser): CachedNetworkImage(imageUrl: personData["profilePictures"][0]["key"]??"", fit: BoxFit.cover,
                                  colorBlendMode: BlendMode.darken,
                                  // color:personData["onlineStatus"]?Colors.transparent: Colors.black.withOpacity(0.7),
                                  placeholder: (ctx, url) => const Center(child: SizedBox()),
                                )
                              // Image.asset(AssetsPics.sample,fit: BoxFit.cover),
                            ),
                          );
                        })
                ),
                const SizedBox(height: 15),
                Stack(
                  children: [
                    Padding(padding: const EdgeInsets.only(left: 15,right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: (){
                              int likecnt=Provider.of<eventController>(context,listen: false).likeCount;
                              if(likecnt>0){
                                _timer!.cancel();
                                setState(() {
                                  print("Daaaddaadd");
                                  LoaderOverlay.show(context);
                                  LocaleHandler.liked=true;
                                  LocaleHandler.bottomSheetIndex=3;
                                  Get.offAll(()=>BottomNavigationScreen());
                                  LoaderOverlay.hide();
                                });
                              }
                            },
                            child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                    color: color.example3,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: color.example6)
                                ),
                                child:Consumer<eventController>(builder: (ctx,val,child){
                                  return Row(children: [
                                    Container(
                                      margin: const EdgeInsets.only(left: 10),
                                      alignment: Alignment.center,
                                      height: 5.h,width: 5.h,
                                      padding: const EdgeInsets.all(7),
                                      decoration: const BoxDecoration(shape: BoxShape.circle,color: color.txtBlue),
                                      child: SvgPicture.asset(AssetsPics.heart),
                                    ),
                                    const SizedBox(width: 10),
                                    buildText(val.likeCount==0?"No likes yet": "Likes", 18, FontWeight.w600, color.txtBlack),
                                    const Spacer(),
                                    buildText(val.likeCount==0 ?"": val.likeCount.toString(), 18, FontWeight.w600, color.txtBlack),
                                    const SizedBox(width: 10),
                                    const Icon(Icons.keyboard_arrow_right_rounded),
                                    const SizedBox(width: 10),
                                  ],);
                                })

                            ),
                          ),
                          const SizedBox(height: 30),
                          buildText(" Messages", 20, FontWeight.w600, color.txtBlack),
                          const SizedBox(height: 10),
                          isListEmpty? noMessage():chatList()
                          // noMessage()
                        ],
                      ),
                    ),
                    Container(height: size.height, width: 14, color: color.backGroundClr)
                  ],
                ),
              ],
            ),
          ),
        ),
        AnimatedContainer(
          // height: itemDelted?11.h:0,
          // width: size.width,
          width: size.width.w,
          height: itemDelted?12.8.h:0,
          duration:const Duration(milliseconds: 600),
          // child: Image.asset(AssetsPics.delteChat,fit: BoxFit.fill),
          child: Stack(
            children: [
              SvgPicture.asset(AssetsPics.removed,fit: BoxFit.fill),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    transform: Matrix4.translationValues(MediaQuery.of(context).size.width * -.11, 0, 0.0),
                    child: SvgPicture.asset(AssetsPics.bannerheart),
                  ),
                  Container(
                    transform: Matrix4.translationValues(MediaQuery.of(context).size.width * .01, 0, 10.0),
                    child: SvgPicture.asset(AssetsPics.bannerheart),
                  ),
                ],)
            ],
          ),

        ),
      ],),
    ),);
  }

  Widget chatList() {
    return Container(
      margin: const EdgeInsets.only(bottom: 100),
                     padding: const EdgeInsets.all(8),
                     decoration: BoxDecoration(
                       color: color.txtWhite,
                       borderRadius: BorderRadius.circular(12)
                     ),
                     child: ListView.builder(
                       shrinkWrap: true,
                         physics: const NeverScrollableScrollPhysics(),
                         itemCount: data.length,
                         padding: EdgeInsets.zero,
                         itemBuilder: (context,index){
                         var items=data;
                         int timestamp=items[index]["createdAt"];
                         DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
                         String formattedTime = DateFormat.jm().format(dateTime);
                         var personData=items[index]==null?"": items[index]["sender"]["userId"].toString()==LocaleHandler.userId?items[index]["receiver"]:items[index]["sender"];
                         return Column(
                         children: [
                           personData==""?SizedBox(): GestureDetector(
                             onTap: (){
                               Get.to(()=> TextChatScreen(id: personData["userId"], name: personData["firstName"],))!.then((value) {
                                 setState(() {_startTimer();});
                                 getChat();
                               });
                               // LocaleHandler.chatUserId=personData["userId"];
                               _timer!.cancel();
                             },
                             child: Slidable(
                                 controller: _slidableController,
                                 // key: const ValueKey(0),
                               key: Key(index.toString()),
                               closeOnScroll: true,
                               enabled: true,
                               direction: Axis.horizontal,
                               endActionPane: ActionPane(
                                   extentRatio: 0.3,
                                   dragDismissible: false,
                                   motion: const ScrollMotion(),
                                   dismissible: DismissiblePane(onDismissed: () {}),
                                 children: [const SizedBox(width: 17),
                                 CircleAvatar(
                                   radius: 17,
                                   backgroundColor: color.txtBlue,
                                   child: SvgPicture.asset(AssetsPics.notificationicon),
                                 ),
                                 const SizedBox(width: 8),
                                 GestureDetector(
                                   onTap: (){
                                     customSparkBottomSheeet(context, AssetsPics.chatDelete, "Are you sure you want to\n delete this chat?", "Cancel", "Delete",
                                     onTap2: (){
                                       setState(() {
                                         Get.back();
                                         chatDelete(personData["userId"],index);
                                         setState(() {data.removeAt(index);});
                                         _slidableController?.close();
                                         // futuredelayed(2, true);
                                         futuredelayed(10, false);
                                       });});
                                   },
                                   child: CircleAvatar(radius: 17,
                                     backgroundColor: const Color.fromRGBO(255,92,71,1),
                                     child: SvgPicture.asset(AssetsPics.deletechaticon)))],),
                               child: Row(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     // const CircleAvatar(radius: 25,backgroundImage: AssetImage(AssetsPics.sample),),
                                     CircleAvatar(child:personData["profilePictures"].isEmpty?Image.asset(AssetsPics.demouser): CachedNetworkImage(imageUrl: personData["profilePictures"][0]["key"],
                                         fit: BoxFit.cover,
                                       imageBuilder: (context, imageProvider) => Container(
                                         width: 80.0, height: 80.0,
                                         decoration: BoxDecoration(
                                           shape: BoxShape.circle,
                                           image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                         ),
                                       ),
                                       placeholder: (ctx, url) => const Center(child: SizedBox()),)),
                                     const SizedBox(width: 10),
                                     Expanded(
                                       child: Column(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                           const SizedBox(height: 2),
                                           // buildText("Ariana", 16, FontWeight.w600, color.txtBlack,fontFamily: FontFamily.hellix),
                                           buildText(personData["firstName"], 16, FontWeight.w600, color.txtBlack,fontFamily: FontFamily.hellix),
                                           // buildText("Nice to meet you, darling", 15, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix)
                                           buildText(items[index]["content"], 15,items[index]["unreadCount"]==0?FontWeight.w500:FontWeight.w800,
                                               items[index]["unreadCount"]==0?color.txtgrey:color.txtBlack,fontFamily: FontFamily.hellix)
                                         ],),
                                     ),
                                     Column(
                                       children: [
                                         const SizedBox(height: 2),
                                         buildText(formattedTime, 14, FontWeight.w400, color.txtgrey,fontFamily: FontFamily.hellix),
                                       ],
                                     ),
                                   ],)
                             ),
                           ),
                           index==data.length-1?const SizedBox(): const Padding(
                             padding: EdgeInsets.only(left: 5.0,right: 5.0),
                             child:  Divider(thickness: 0.8,color: color.lightestBlue),
                           ),
                           _isLoadMoreRunning? const Center(child: CircularProgressIndicator(color: color.txtBlue)):SizedBox(),
                         ],
                       );
                     }),
                   );
  }

  Container noMessage() {
    return Container(
                 alignment: Alignment.center,
                 height: 320,
                 decoration: BoxDecoration(
                     color: color.txtWhite,
                     borderRadius: BorderRadius.circular(12)
                 ),
                 child: Stack(
                   alignment: Alignment.center,
                   children: [
                     Positioned(
                       left: 130,
                       top: 50,
                       child: Container(
                         alignment: Alignment.center,
                         child: SvgPicture.asset(AssetsPics.threeDotsLeft),),
                     ),
                     Container(
                       alignment: Alignment.center,
                       child:   SvgPicture.asset(AssetsPics.heartblankbg2),
                     ),
                     Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Image.asset(AssetsPics.noMessage,height: 60),
                         const SizedBox(height: 5),
                         buildText("No messages?", 30, FontWeight.w400, color.txtBlue),
                         const SizedBox(height: 10),
                         buildText2("Attend more events to increase\n your chances of matching to speak to\n others!", 18, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
                       ],
                     ),
                   ],
                 ),
               );
  }
}
