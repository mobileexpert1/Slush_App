import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/screens/chat/text_chat_screen.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart'as http;
import 'package:slush/widgets/toaster.dart';

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
    Future.delayed(const Duration(seconds: 2),(){
      setState(() {
        isListEmpty=false;
      });});
    super.initState();
  }

  void futuredelayed(int i,bool val){
    Future.delayed(Duration(seconds: i),(){
      setState(() {
        itemDelted=val;
      });});
  }


  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar:itemDelted?null: commonBarWithTextleft(context, Colors.transparent, "Chat"),
      body: Stack(children: [
        SizedBox(
          height: size.height,
          width: size.width,
          child: Image.asset(AssetsPics.background,fit: BoxFit.cover,),
        ),
        SafeArea(
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:  EdgeInsets.only(left: 15,top:itemDelted?9.h: 2.h,bottom: 5),
                  child: buildText(" Matches", 20, FontWeight.w600, color.txtBlack),
                ),
                SizedBox(
                    height: 85,
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(left: 15),
                        itemCount: 10,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
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
                            child: isListEmpty?SizedBox():ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(AssetsPics.sample,fit: BoxFit.cover,)),
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
                       Container(
                         height: 60,
                         decoration: BoxDecoration(
                             color: color.example3,
                             borderRadius: BorderRadius.circular(12),
                             border: Border.all(color: color.example6)
                         ),
                         child:Row(children: [
                           Container(
                             margin: const EdgeInsets.only(left: 10),
                             alignment: Alignment.center,
                             height: 5.h,width: 5.h,
                           padding: const EdgeInsets.all(7),
                           decoration: const BoxDecoration(shape: BoxShape.circle,color: color.txtBlue),
                           child: SvgPicture.asset(AssetsPics.heart),
                           ),
                               const SizedBox(width: 10),
                               buildText(isListEmpty?"No likes yet": "Likes", 18, FontWeight.w600, color.txtBlack),
                           const Spacer(),
                           buildText(isListEmpty ?"": "32", 18, FontWeight.w600, color.txtBlack),
                           const SizedBox(width: 10),
                           const Icon(Icons.keyboard_arrow_right_rounded),
                           const SizedBox(width: 10),
                            ],)
          
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
                    child: SvgPicture.asset(AssetsPics.bannerheart),
                  transform: Matrix4.translationValues(MediaQuery.of(context).size.width * -.11, 0, 0.0),
                ),
                  Container(
                    child: SvgPicture.asset(AssetsPics.bannerheart),
                    transform: Matrix4.translationValues(MediaQuery.of(context).size.width * .01, 0, 10.0),
                  ),
              ],)
            ],
          ),
          
        ),
      ],),
    );
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
                         itemCount: 10,
                         padding: EdgeInsets.zero,
                         itemBuilder: (context,index){return
                       Column(
                         children: [
                           GestureDetector(
                             onTap: (){
                               Get.to(()=>const TextChatScreen());
                             },
                             child: Slidable(
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
                                         snackBaar(context,AssetsPics.removed,false);
                                         // futuredelayed(2, true);
                                         futuredelayed(10, false);
                                       });});
                                   },
                                   child: CircleAvatar(
                                     radius: 17,
                                     backgroundColor: const Color.fromRGBO(255,92,71,1),
                                     child: SvgPicture.asset(AssetsPics.deletechaticon),
                                   ),
                                 ),
                               ],),
                               child: Row(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     const CircleAvatar(radius: 25,backgroundImage: AssetImage(AssetsPics.sample),),
                                     const SizedBox(width: 10),
                                     Expanded(
                                       child: Column(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                           const SizedBox(height: 2),
                                           buildText("Ariana", 16, FontWeight.w600, color.txtBlack,fontFamily: FontFamily.hellix),
                                           buildText("Nice to meet you, darling", 15, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix)
                                         ],),
                                     ),
                                     Column(
                                       children: [
                                         const SizedBox(height: 2),
                                         buildText("7:09 pm", 14, FontWeight.w400, color.txtgrey,fontFamily: FontFamily.hellix),
                                       ],
                                     ),
                                   ],)
                             ),
                           ),
                           index==10-1?const SizedBox(): const Padding(
                             padding: EdgeInsets.only(left: 5.0,right: 5.0),
                             child:  Divider(thickness: 0.8,color: color.lightestBlue),
                           ),
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
