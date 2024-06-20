import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/localkeys.dart';
import 'package:slush/controller/profile_controller.dart';
import 'package:slush/screens/events/bottomNavigation.dart';
import 'package:slush/screens/profile/basic_info/profile_video_view.dart';
import 'package:slush/screens/profile/profile_img_view.dart';
import 'package:slush/screens/profile/profile_video_screen.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/distance_calculate.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:slush/widgets/toaster.dart';
import 'package:http/http.dart'as http;
import 'package:video_player/video_player.dart';

class MatchedPersonProfileScreen extends StatefulWidget {
  const MatchedPersonProfileScreen({Key? key,required this.id}) : super(key: key);
  final String id;
  @override
  State<MatchedPersonProfileScreen> createState() =>
      _MatchedPersonProfileScreenState();
}

class _MatchedPersonProfileScreenState
    extends State<MatchedPersonProfileScreen> {
  List items=[
    "Travelling","Modeling","Dancing","Books","Music","Dancing"
  ];
  PageController controller = PageController();
  int numberOfPages = 3;
  int currentPage = 0;
  int indicatorIndex = 0;

  bool isScrolled=false;
  var hi=0.0;

  @override
  void initState() {
    getProfileDetails();
    // TODO: implement initState
    super.initState();
  }

  var dataa;
  VideoPlayerController? _controller;
  VideoPlayerController? _controller2;
  VideoPlayerController? _controller3;
  Future<void>? _initializeVideoPlayerFuture;
  Future<void>? _initializeVideoPlayerFuture2;
  Future<void>? _initializeVideoPlayerFuture3;

  @override
  void dispose() {
    _controller!.dispose();
    _controller2!.dispose();
    _controller3!.dispose();
    super.dispose();
  }

  Future getProfileDetails() async {
    final url = ApiList.getUser + widget.id;
    print(url);
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${LocaleHandler.accessToken}'
      });
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          dataa=data["data"];
          addImgVid();

          // calculateDistance(LocaleHandler.latitude, LocaleHandler.longitude, data["data"]["latitude"], data["data"]["longitude"]);
          print(dataa);
          if (dataa["profileVideos"].length != 0) {
            _controller = VideoPlayerController.networkUrl(Uri.parse(dataa["profileVideos"][0]["key"]),);
            _initializeVideoPlayerFuture = _controller!.initialize().then((value) {_controller!.setVolume(0.0);});
          }
          if (dataa["profileVideos"].length >= 2) {
            _controller2 = VideoPlayerController.networkUrl(Uri.parse(dataa["profileVideos"][1]["key"]),);
            _initializeVideoPlayerFuture2 = _controller2!.initialize().then((value) {_controller2!.setVolume(0.0);});
          }
          if (dataa["profileVideos"].length >= 3) {
            _controller3 = VideoPlayerController.networkUrl(Uri.parse(dataa["profileVideos"][2]["key"]),);
            _initializeVideoPlayerFuture3 = _controller3!.initialize().then((value) {_controller3!.setVolume(0.0);});
          }
          showOnProfile();

        });
      } else if (response.statusCode == 401) {
        showToastMsgTokenExpired();
        print('Token Expire:::::::::::::');
      } else {
        print('Faoled to Load Data With Status Code ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  List splitted = [];
  void showOnProfile() {
    if (dataa["showOnProfile"] == null) return;
    String text=dataa["showOnProfile"].toString().replaceAll(" ", "");
    splitted = text.split(',');
    print(splitted);
  }

  int calculateAge(String dobString) {
    DateTime dob = DateTime.parse(dobString);
    DateTime now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  String printme(String text) {
    List<String> splitList = text.split(',');
    int startIndex = splitList.length - 2;
    if (startIndex < 0) {
      return "============== No Sufficient Commas ==============";
    } else {
      return splitList.getRange(startIndex, splitList.length).join(',');
    }
  }

  List<Map<String, dynamic>> imgvideitems = [];
  void addImgVid(){
    for(var i=0;i<dataa["profilePictures"].length;i++) {
      var ii={"key":"photo", "url":dataa["profilePictures"][i]["key"]};
      imgvideitems.add(ii);
    }
    for(var i=0;i<dataa["profileVideos"].length;i++) {
      var ii={"key":"video", "url":dataa["profileVideos"][i]["key"]};
      imgvideitems.add(ii);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
         body:dataa==null?const Center(child: CircularProgressIndicator(color: color.txtBlue)): CustomScrollView(
           physics: ClampingScrollPhysics(),
           slivers: [
             SliverAppBar(
               bottom: PreferredSize(
                 preferredSize: const Size.fromHeight(0.0),
                 child: Container(
                   height: 3.h,
                   width: size.width,
                   decoration: const BoxDecoration(color: color.txtWhite,
                       borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40))
                   ),
                 ),
               ),
               automaticallyImplyLeading: false,
               title: Row(
                 mainAxisAlignment: MainAxisAlignment.start,
                 children: [
                   GestureDetector(onTap: (){Get.back();},
                       child: Container(
                           padding: EdgeInsets.all(9),
                           height: 35,
                           width: 35,
                           decoration: BoxDecoration(
                             // color: Colors.red,
                               borderRadius: BorderRadius.circular(20)
                           ),
                           child: SvgPicture.asset(AssetsPics.arrowLeft))),
                 ],),
               expandedHeight: 43.3.h,
               flexibleSpace: FlexibleSpaceBar(
                 background:  SizedBox(height: size.height/2, width: size.width, child: Stack(
                   fit: StackFit.expand,
                   alignment: Alignment.center,
                   children: [
                     PageView.builder(
                       controller: controller,
                       itemCount: imgvideitems.length,
                       onPageChanged: (indexx) {
                         setState(() {currentPage = indexx;
                         });indicatorIndex = indexx;
                       },
                       itemBuilder: (BuildContext context, int index) {
                         return GestureDetector(
                           onTap: () {},
                           child:imgvideitems[index]["key"]=="photo"? CachedNetworkImage(
                             imageUrl: imgvideitems.length == 0 ? "" :
                             imgvideitems[index]["url"],
                             fit: BoxFit.cover,
                             errorWidget: (context, url, error) => Icon(Icons.error),
                             placeholder: (context, url) => Center(child: CircularProgressIndicator(color: color.txtBlue)),
                           ):VideoScreen(url: imgvideitems[index]["url"]),
                         );
                       },
                     ),
                     IgnorePointer(child: SvgPicture.asset(AssetsPics.eventbg,fit: BoxFit.cover)),
                     Positioned(
                       top:defaultTargetPlatform==TargetPlatform.iOS?70: 50.0,
                       child:   IgnorePointer(
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: List<Widget>.generate(imgvideitems.length, (int index) {
                             return Container(
                               margin: const EdgeInsets.only(left: 2.5,right: 2.5,bottom: 12.0),
                               width: indicatorIndex == index?15: 12.0,
                               height: indicatorIndex == index?15: 12.0,
                               decoration: BoxDecoration(
                                 color:indicatorIndex == index? color.txtWhite:Colors.transparent,
                                 borderRadius: BorderRadius.circular(20),
                                 border: Border.all(color: indicatorIndex == index ? Colors.blue : Colors.white, width: indicatorIndex == index ? 3 : 1.5 ,),
                               ),
                             );
                           }),
                         ),
                       ),
                     ),
                   ],
                 )),
               ),
             ),
             SliverList(
               delegate: SliverChildBuilderDelegate(
                     (BuildContext context, int index) {
                       String gender = dataa["gender"];
                       var dis =distance(double.parse(dataa["latitude"]), double.parse(dataa["longitude"]));
                       var dis2 = dis.toString().split(".").first;
                   return Container(width: size.width,
                     decoration: const BoxDecoration(
                         borderRadius: BorderRadius.vertical(top: Radius.circular(40)),color: Colors.white
                     ),
                     padding: const EdgeInsets.only(left: 15,right: 15,top: 0),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Row(
                           mainAxisAlignment: MainAxisAlignment.start,
                           children: [
                             Flexible(child: buildTextOverFlow(dataa['firstName'] == null ? "" : "${dataa["firstName"] ?? ''}", 24, FontWeight.w600, color.txtBlack)),
                             buildTextOverFlow(", ${dataa['dateOfBirth'] == null ? "" : calculateAge(dataa['dateOfBirth'] ?? '')}",24, FontWeight.w600, color.txtBlack),
                             SizedBox(width: 10),
                             SvgPicture.asset(dataa["isVerified"]? AssetsPics.verify:AssetsPics.verifygrey),
                             SizedBox(width: 55),
                             Spacer(),
                             InkWell(
                               onTap: () {
                                 customUnmatchBoxWithtwobutton(context, "Are you sure you want to\n unmatch?", " ",img: AssetsPics.unMatch,isPng: true,
                                     btnTxt1: "No",btnTxt2: "Unmatch",onTap2: (){
                                       Get.offAll(()=>BottomNavigationScreen());
                                       snackBaar(context, AssetsPics.unMatchedbg,true);
                                     }
                                 );
                               },
                               child: Container(
                                 alignment: Alignment.center,
                                 padding: EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                                 decoration: BoxDecoration(color: color.lightestBlue,
                                     borderRadius: BorderRadius.circular(8)),
                                 child: Icon(Icons.group_off_outlined,color: color.txtBlue,),
                               ),
                             ),
                           ],
                         ),
                         // buildText("Professional model", 15, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
                         dataa["jobTitle"]==null?SizedBox(): buildText(dataa["jobTitle"]??"", 15, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
                         Wrap(
                           crossAxisAlignment: WrapCrossAlignment.center,
                           children: [
                             splitted.contains("gender")
                                 ? Container(margin: EdgeInsets.symmetric(horizontal: 2),
                                 child: SvgPicture.asset(
                                     gender == "male" ? AssetsPics.greyman : gender == "female"
                                         ? AssetsPics.greyfemale : AssetsPics.transGenderBlack, height: 15))
                                 : SizedBox(),
                             splitted.contains("gender")
                                 ? buildText(gender == "male" ? "Male" : gender == "female" ? "Female" : "Other",
                                 15, FontWeight.w500, color.txtgrey, fontFamily: FontFamily.hellix)
                                 : SizedBox(),
                             splitted.contains("gender")
                                 ? Container(margin: EdgeInsets.symmetric(horizontal: 5),
                                 child: SvgPicture.asset(AssetsPics.greydivider, height: 15))
                                 : SizedBox(),
                             splitted.contains("height")?Container(
                                 margin: EdgeInsets.symmetric(horizontal: 2),
                                 child: SvgPicture.asset(AssetsPics.greyhieght, height: 15,)):SizedBox(),
                             splitted.contains("height")? buildText(dataa["height"] + "cm", 15,
                                 FontWeight.w500, color.txtgrey, fontFamily: FontFamily.hellix):SizedBox(),

                             splitted.contains("height")?Container(margin: EdgeInsets.symmetric(horizontal: 5),
                                 child: SvgPicture.asset(AssetsPics.greydivider, height: 15)):SizedBox(),
                             splitted.contains("sexuality")? buildText(dataa["sexuality"], 15,
                                 FontWeight.w500, color.txtgrey, fontFamily: FontFamily.hellix):SizedBox(),
                             splitted.contains("sexuality")?Container(margin: EdgeInsets.symmetric(horizontal: 5),
                                 child: SvgPicture.asset(AssetsPics.greydivider, height: 15)):SizedBox(),

                             for (var ii = 0; ii < dataa["ethnicity"].length; ii++)
                               Wrap(
                                 crossAxisAlignment: WrapCrossAlignment.center,
                                 children: [
                                   buildText(dataa["ethnicity"][ii]["name"],
                                       15, FontWeight.w500, color.txtgrey, fontFamily: FontFamily.hellix),
                                   ii== dataa["ethnicity"].length-1?SizedBox(): Container(margin: EdgeInsets.symmetric(horizontal: 5),
                                       child: SvgPicture.asset(AssetsPics.greydivider, height: 15)),

                                 ],
                               )
                           ],
                         ),
                         SizedBox(height:splitted.contains("lookingFor")? 2.h:0),
                         splitted.contains("lookingFor")? buildText("Relationship basics", 20, FontWeight.w600, color.txtBlack):SizedBox(),
                         splitted.contains("lookingFor")?  Row(
                           children: [
                             Container(
                                 margin: EdgeInsets.symmetric(horizontal: 5),
                                 child: SvgPicture.asset(AssetsPics.greyoutlineheart, height: 14)),
                             buildText(dataa["lookingFor"] ?? '', 15,
                                 FontWeight.w500, color.txtgrey, fontFamily: FontFamily.hellix),],):SizedBox(),
                         SizedBox(height: 2.h),
                         Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             buildText("Location", 20, FontWeight.w600, color.txtBlack),
                             Container(
                               padding: EdgeInsets.symmetric(horizontal: 5),
                               height: 4.h,
                               // width: 9.h+3,
                               decoration: BoxDecoration(color: Color.fromRGBO(230, 240, 255, 1),
                                   borderRadius: BorderRadius.circular(17)
                               ),
                               child: Row(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   SvgPicture.asset(AssetsPics.blueMapPoint),
                                   const SizedBox(width: 6),
                                   buildText("$dis2 km", 15, FontWeight.w600, color.txtBlue,fontFamily: FontFamily.hellix)
                                 ],),
                             )
                           ],),
                         // buildText("Chicago, IL United States", 15, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
                         buildText(dataa["country"]==null? printme(dataa["address"]):
                         dataa["state"]+", "+dataa["country"], 15, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
                         SizedBox(height: 2.h),
                         dataa["bio"]==null?SizedBox() :  buildText("About", 20, FontWeight.w600, color.txtBlack),
                         // buildText(LocaleText.personDescription, 16, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
                         /*  Text(LocaleText.personDescription,style: TextStyle(
                         fontSize: 16,fontFamily: FontFamily.hellix,fontWeight: FontWeight.w500,
                         color: color.txtgrey
                       )),*/
                         dataa["bio"]==null?SizedBox():  ExpandableText(
                           dataa["bio"]??"",
                           style: TextStyle(fontSize: 16,fontFamily: FontFamily.hellix,fontWeight: FontWeight.w500, color: color.txtBlack),
                           expandText: '\nRead more',
                           collapseText: 'Read less',
                           maxLines: 3,
                           animation: true,
                           animationDuration: Duration(seconds: 1),
                           linkColor: Colors.blue,
                           linkStyle: TextStyle(color: color.txtBlue,fontWeight: FontWeight.w600,fontFamily: FontFamily.hellix,fontSize: 15),
                           linkEllipsis: false,
                         ),
                         SizedBox(height:dataa["bio"]==null?0: 2.h),
                         dataa["ideal_vacation"] != null||dataa["cooking_skill"] != null||dataa["smoking_opinion"] != null?
                         buildText("More about me", 20, FontWeight.w600, color.txtBlack):SizedBox(),
                         Wrap(
                           children: [
                             dataa["ideal_vacation"] == null ? SizedBox() : Container(
                               margin: const EdgeInsets.only(top: 10, right: 9),
                               padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                               decoration: BoxDecoration(
                                   borderRadius: BorderRadius.circular(19),
                                   border: Border.all(width: 1, color: color.lightestBlueIndicator),
                                   color: color.lightestBlue),
                               child: Row(
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                   Container(
                                       margin: EdgeInsets.only(right: 6),
                                       child: SvgPicture.asset(
                                           AssetsPics.greyideal)),
                                   buildText(dataa["ideal_vacation"], 16, FontWeight.w600, color.txtBlack),
                                 ],
                               ),
                             ),
                             dataa["cooking_skill"] == null ? SizedBox() : Container(
                               margin:
                               const EdgeInsets.only(top: 10, right: 9),
                               padding: const EdgeInsets.symmetric(
                                   horizontal: 9, vertical: 6),
                               decoration: BoxDecoration(
                                   borderRadius: BorderRadius.circular(19),
                                   border: Border.all(
                                       width: 1,
                                       color: color.lightestBlueIndicator),
                                   color: color.lightestBlue),
                               child: Row(
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                   Container(
                                       margin: EdgeInsets.only(right: 6),
                                       child: SvgPicture.asset(
                                           AssetsPics.greyshefhat)),
                                   buildText(dataa["cooking_skill"], 16, FontWeight.w600, color.txtBlack),
                                 ],
                               ),
                             ),
                             dataa["smoking_opinion"] == null ? SizedBox() : Container(
                               margin:
                               const EdgeInsets.only(top: 10, right: 9),
                               padding: const EdgeInsets.symmetric(
                                   horizontal: 9, vertical: 6),
                               decoration: BoxDecoration(
                                   borderRadius: BorderRadius.circular(19),
                                   border: Border.all(
                                       width: 1,
                                       color: color.lightestBlueIndicator),
                                   color: color.lightestBlue),
                               child: Row(
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                   Container(
                                       margin: EdgeInsets.only(right: 6),
                                       child: SvgPicture.asset(
                                           AssetsPics.greysmoking)),
                                   buildText(dataa["smoking_opinion"], 16, FontWeight.w600, color.txtBlack),
                                 ],
                               ),
                             ),
                           ],
                         ),
                         SizedBox(height:dataa["interests"].length==0?0: 2.h),
                         dataa["interests"].length==0?SizedBox():buildText("Interests", 20, FontWeight.w600, color.txtBlack),
                         Wrap(children: [
                           for(var i=0;i<dataa["interests"].length;i++)
                             Container(
                               margin: const EdgeInsets.only(top: 10,right: 10),
                               padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 6),
                               decoration: BoxDecoration(
                                   borderRadius: BorderRadius.circular(19),
                                   border: Border.all(width: 1,color: color.lightestBlue)
                               ),
                               child: buildText(dataa["interests"][i]["name"], 16, FontWeight.w600, color.txtBlack),
                             )
                         ],),
                         SizedBox(height: 2.h),
                         buildText("Gallery", 20, FontWeight.w600, color.txtBlack),
                         SizedBox(height:1.h),
                         SizedBox(
                           // color: Colors.red,
                           height: size.height*0.3,
                           width: size.width,
                           child: Row(children: [
                             Expanded(child: dataa["profilePictures"].length != 0
                                 ? Container(
                                 height: size.height*0.3,
                                 child: buildPhotoContainer(dataa["profilePictures"][0]["key"],0))
                                 : Container(
                                 height: size.height*0.3,child: buildContainer())),
                             SizedBox(width: 10),
                             Column(children: [
                               Expanded(
                                 child: SizedBox(
                                     width: size.width/2-80,
                                     child:dataa["profilePictures"].length >= 2
                                         ? buildPhotoContainer(dataa["profilePictures"][1]["key"],1)
                                         : buildContainer()),
                               ),
                               SizedBox(height: 1.h),
                               Expanded(
                                 child: SizedBox(
                                     width: size.width/2-80,
                                     child: dataa["profilePictures"].length >= 3
                                         ? buildPhotoContainer(dataa["profilePictures"][2]["key"],2)
                                         : buildContainer()),
                               ),
                             ],),
                             // SizedBox(width: 10),
                           ],),
                         ),
                         SizedBox(height:2.h),
                         buildText("Video", 20, FontWeight.w600, color.txtBlack),
                         SizedBox(height:1.h),
                         SizedBox(
                           // color: Colors.red,
                           height: size.height*0.3,
                           width: size.width,
                           child: Row(children: [
                             Expanded(child: dataa["profileVideos"].length != 0
                                 ? Container( height: size.height*0.3,child: buildVideoContainer(_controller!, _initializeVideoPlayerFuture!))
                                 : buildContainer()),
                             // Expanded(child: buildContainer()),
                             const SizedBox(width: 10),
                             Column(children: [
                               Expanded(
                                 child: SizedBox(
                                   width: size.width/2-80,
                                   child:  dataa["profileVideos"].length >=2
                                       ? buildVideoContainer(_controller2!, _initializeVideoPlayerFuture2!)
                                       : buildContainer(),
                                 ),
                               ),
                               SizedBox(height: 1.h),
                               Expanded(
                                 child: SizedBox(
                                   width: size.width/2-80,
                                   child:  dataa["profileVideos"].length >=3
                                       ? buildVideoContainer(_controller3!, _initializeVideoPlayerFuture3!)
                                       : buildContainer(),
                                 ),
                               ),
                             ],),
                             // SizedBox(width: 10),

                           ],),
                         ),
                         SizedBox(height:5.h),
                       ],),
                   );
                 },
                 childCount: 1, // SliverList displaying 20 items, each on a ListTile
               ),
             ),

           ],
         ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        backgroundColor: color.txtBlue,
        onPressed: () {},
        child: SvgPicture.asset(AssetsPics.floatiAction),
      ),
    );
  }

  Widget buildPhotoContainer(String img,int i) {
    return GestureDetector(
      onTap: (){
        // Get.to(()=>ImageViewScreen(indexId: i, pictureItems: dataa["profilePictures"]));
        customSlidingImage(context,i,dataa["profilePictures"]);
      },
      child: ClipRRect(borderRadius: BorderRadius.circular(16),
          // child: Image.asset(AssetsPics.photo,fit: BoxFit.cover)
          child: CachedNetworkImage(imageUrl: img, fit: BoxFit.cover, errorWidget: (context, url, error) => Icon(Icons.error))
      ),
    );
  }

  Widget buildContainer() => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: color.txtgrey4,
    ),
    child: Icon(Icons.info),
  );

  Widget buildVideoContainer(VideoPlayerController cntrl, Future<void> func) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            // Image.asset("assets/sample/photo.png",fit: BoxFit.cover,),
            FutureBuilder(
              future: func,
              builder: (context, snapshot) {
                return AspectRatio(
                  aspectRatio: cntrl.value.aspectRatio,
                  child: VideoPlayer(cntrl),
                );
              },
            ),
            Container(
                alignment: Alignment.center,
                child: GestureDetector(
                    onTap: () {
                      // cntrl.play();
                      Provider.of<profileController>(context,listen: false).videoUrl = cntrl.dataSource;
                      Get.to(()=>ProfileVideoViewer());
                    },
                    child: SvgPicture.asset(AssetsPics.videoplayicon)))
          ],
        ));
  }

  void callFunction(){
    setState(() {
      LocaleHandler.isThereAnyEvent=false;
      LocaleHandler.isThereCancelEvent=false;
      // LocaleHandler.unMatchedEvent=true;
      snackBaar(context, AssetsPics.unMatchedbgsvg,false);
      LocaleHandler.subScribtioonOffer=false;
      Get.offAll(()=>BottomNavigationScreen());
    });
  }
}
