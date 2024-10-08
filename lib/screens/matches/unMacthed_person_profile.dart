import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
import 'package:slush/screens/profile/spark_purchase.dart';
import 'package:slush/screens/profile/view_profile.dart';
import 'package:slush/screens/video_call/congo_match_screen.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/distance_calculate.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:slush/widgets/toaster.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart'as http;

import '../../constants/loader.dart';

class UnMatchedPersonProfileScreen extends StatefulWidget {
  const UnMatchedPersonProfileScreen({Key? key,required this.id}) : super(key: key);
  final String id;
  @override
  State<UnMatchedPersonProfileScreen> createState() => _UnMatchedPersonProfileScreenState();
}

class _UnMatchedPersonProfileScreenState extends State<UnMatchedPersonProfileScreen> {
  List reportingMatter = [
    "Fake Account",
    "Nudity / inappropriate",
    "Swearing / Aggression",
    "Harassment","Other"
  ];
  PageController controller = PageController();
  int currentPage = 0;
  int indicatorIndex = 0;

  bool isScrolled=false;
  bool likedProfile=false;
  bool sparked=false;
  bool crossPressed=false;
  var hi=0.0;

  var dataa;
  VideoPlayerController? _controller;
  VideoPlayerController? _controller2;
  VideoPlayerController? _controller3;
  Future<void>? _initializeVideoPlayerFuture;
  Future<void>? _initializeVideoPlayerFuture2;
  Future<void>? _initializeVideoPlayerFuture3;

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
    if (startIndex < 0) {return "";}
    else {return splitList.getRange(startIndex, splitList.length).join(',');}
  }

  @override
  void initState() {
    getProfileDetails();
    super.initState();
  }

  Future actionForHItLike(String action,String id)async{
    final url= "${ApiList.action}${id}/action";
    print(url);
    var uri=Uri.parse(url);
    var response=await http.post(uri,
        headers: {'Content-Type': 'application/json', "Authorization": "Bearer ${LocaleHandler.accessToken}"},
        body: jsonEncode({"action":action})
    );
    print(response.statusCode);
    var data=jsonDecode(response.body);
    if(response.statusCode==201){
      Get.back(result: true);
      Provider.of<profileController>(context,listen: false).getTotalSparks();
      if(data["isMatch"]&&action!="DISLIKED"){
        Get.to(()=> const CongratMatchScreen(likedscreen: true));
      }
    }
    else if(response.statusCode==401){}
    else{}
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
  Future reportUser(String reason)async{
    final url = '${ApiList.reportUser}${widget.id}/report';
    print(url);
    try {
      var uri = Uri.parse(url);
      var response = await http.post(uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${LocaleHandler.accessToken}'
          },
          body: jsonEncode({'reason': reason})
      );
      setState(() {LoaderOverlay.hide();});
      if(response.statusCode==201)
      {
        Get.back();
        print('User Reported Successfully:::::::::::::::::::::;');
        Fluttertoast.showToast(msg: 'User Reported');
        setState(() {
          // Get.back(result: true);
          // snackBaar(context, AssetsPics.reportbannerSvg,false);
          Provider.of<profileController>(context,listen: false).showMtchReportBnr();
          // LocaleHandler.reportedSuccesfuly=true;
          LocaleHandler.curentIndexNum=3;
          LocaleHandler.isThereAnyEvent=false;
          LocaleHandler.isThereCancelEvent=false;
          LocaleHandler.unMatchedEvent=false;
          LocaleHandler.subScribtioonOffer=false;
          Get.offAll(()=>BottomNavigationScreen());
        });
      }
      else if(response.statusCode==401){
        showToastMsgTokenExpired();
      }
      else{
        print('Reported Failed With Status Code :${response.statusCode}');
        Fluttertoast.showToast(msg: 'Something Went Wrong');
      }
    }
    catch(error)
    {
      print('Error ::::::::::::::::::: ${error.toString()}');
      Fluttertoast.showToast(msg: 'Something Went Wrong::');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body:dataa==null?const Center(child: CircularProgressIndicator(color: color.txtBlue)): CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            collapsedHeight: 10.h,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.0),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(height: 4.h,
                    width: size.width,
                    decoration: const BoxDecoration(color: color.txtWhite, borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40),)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(onTap:(){
                        if(crossPressed==false&&likedProfile==false){
                        setState(() {crossPressed=true;});
                        actionForHItLike("DISLIKED", dataa["userId"].toString());
                        }},
                          child: buildColumn(crossPressed?AssetsPics.orangecross:AssetsPics.cross,8.h)),
                      const SizedBox(width: 15),
                      GestureDetector(onTap:(){
                       if(crossPressed==false&&likedProfile==false){
                         setState((){likedProfile=true;});
                         actionForHItLike("LIKED", dataa["userId"].toString());
                       }
                        },
                          child: buildColumn(likedProfile?AssetsPics.heart:AssetsPics.blueheart,10.h)),
                      const SizedBox(width: 15),
                      Consumer<profileController>(
                          builder: (context,val,child){
                            return GestureDetector(
                                onTap: (){
                                  customSparkBottomSheeet(context,AssetsPics.sparkleft, "Are you sure you would like to\n use 1x Spark?", "Cancel", "Yes",
                                      sparks: val.sparks,
                                      onTap2: (){Get.back();
                                      if(val.sparks<=0){
                                        customSparkBottomSheeet(context,AssetsPics.sparkempty,
                                            " You have run out of Sparks, please\n purchase  more.", "Cancel", "Purchase",onTap2: (){
                                          Get.back();
                                          Get.to(()=>const SparkPurchaseScreen());
                                        });
                                      }else{
                                        setState(() {sparked=true;});
                                      // Provider.of<profileController>(context,listen: false).actionForHItLike("SPARK LIKE", dataa["userId"].toString());
                                       actionForHItLike("SPARK LIKE", dataa["userId"].toString());
                                      }
                                      });
                                },
                                child: buildColumn(sparked?AssetsPics.superlikewhite:AssetsPics.superlike,8.h));
                          }
                      ),
                    ],),
                ],
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(onTap: (){Get.back();},
                    child: Container(
                        padding: const EdgeInsets.all(9),
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                          // color: Colors.red,
                            borderRadius: BorderRadius.circular(20)
                        ),
                        child: SvgPicture.asset(AssetsPics.arrowLeft))),
                GestureDetector(
                  onTap: (){
                    customBuilderSheet(context, 'Report User',"Submit",reportingMatter,onTap: (){
                      setState(() {
                        reportUser(reportingMatter[selectedIndex]);
                      });
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: size.height*0.04,
                    width: size.width*0.07,
                    color: Colors.transparent,
                    child: SvgPicture.asset(AssetsPics.infoicon,height: 20),),
                ),
              ],),
            expandedHeight: 45.5.h,
            flexibleSpace: FlexibleSpaceBar(
              background:  SizedBox(height: size.height/2, width: size.width, child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  PageView.builder(
                    controller: controller,
                    itemCount: imgvideitems.length,
                    onPageChanged: (indexx) {
                      setState(() {currentPage = indexx;});
                      indicatorIndex = indexx;
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {},
                        child:imgvideitems[index]["key"]=="photo"? CachedNetworkImage(
                          imageUrl: imgvideitems.length == 0 ? "" : imgvideitems[index]["url"],
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: color.txtBlue)),
                        ):VideoScreen(url: imgvideitems[index]["url"]),
                      );
                    },
                  ),
                  IgnorePointer(child: SvgPicture.asset(AssetsPics.eventbg,fit: BoxFit.cover)),
                  Positioned(bottom: 85.0,
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
                    var dis;
                    if(dataa["latitude"] != null) {
                        dis = distance(double.parse(dataa["latitude"]),
                            double.parse(dataa["longitude"]));
                      } else{
                      dis = 0.0.toString();
                    }
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
                        children: [
                          Flexible(child: buildTextOverFlow(dataa['firstName'] == null ? "" : "${dataa["firstName"] ?? ''}", 24, FontWeight.w600, color.txtBlack)),
                          Flexible(child: buildTextOverFlow(", ${dataa['dateOfBirth'] == null ? "" : calculateAge(dataa['dateOfBirth'] ?? '')}",24, FontWeight.w600, color.txtBlack)),
                          const SizedBox(width: 10),
                          SvgPicture.asset(dataa["isVerified"] == null ?
                          AssetsPics.verifygrey : dataa["isVerified"] ? AssetsPics.verify:AssetsPics.verifygrey),
                        ],
                      ),
                      // buildText("Professional model", 15, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
                      dataa["jobTitle"]==null?const SizedBox(): buildText(dataa["jobTitle"]??"", 15, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          splitted.contains("gender")
                              ? Container(margin: const EdgeInsets.symmetric(horizontal: 2),
                              child: SvgPicture.asset(
                                  gender == "male" ? AssetsPics.greyman : gender == "female"
                                      ? AssetsPics.greyfemale : AssetsPics.transGenderBlack, height: 15))
                              : const SizedBox(),
                          splitted.contains("gender")
                              ? buildText(gender == "male" ? "Male" : gender == "female" ? "Female" : "Other",
                              15, FontWeight.w500, color.txtgrey, fontFamily: FontFamily.hellix)
                              : const SizedBox(),
                          splitted.contains("gender")
                              ? Container(margin: const EdgeInsets.symmetric(horizontal: 5),
                              child: SvgPicture.asset(AssetsPics.greydivider, height: 15))
                              : const SizedBox(),
                          splitted.contains("height")?Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              child: SvgPicture.asset(AssetsPics.greyhieght, height: 15,)):const SizedBox(),
                          splitted.contains("height")? buildText(dataa["height"] + "cm", 15,
                              FontWeight.w500, color.txtgrey, fontFamily: FontFamily.hellix):const SizedBox(),

                          splitted.contains("height")?Container(margin: const EdgeInsets.symmetric(horizontal: 5),
                              child: SvgPicture.asset(AssetsPics.greydivider, height: 15)):const SizedBox(),
                          splitted.contains("sexuality")? buildText(capitalizeWords(dataa["sexuality"]), 15,
                              FontWeight.w500, color.txtgrey, fontFamily: FontFamily.hellix):const SizedBox(),
                          splitted.contains("sexuality")?Container(margin: const EdgeInsets.symmetric(horizontal: 5),
                              child: SvgPicture.asset(AssetsPics.greydivider, height: 15)):const SizedBox(),

                          for (var ii = 0; ii < dataa["ethnicity"].length; ii++)
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                buildText(dataa["ethnicity"][ii]["name"],
                                    15, FontWeight.w500, color.txtgrey, fontFamily: FontFamily.hellix),
                                ii== dataa["ethnicity"].length-1?const SizedBox(): Container(margin: const EdgeInsets.symmetric(horizontal: 5),
                                    child: SvgPicture.asset(AssetsPics.greydivider, height: 15)),

                              ],
                            )
                        ],
                      ),
                      SizedBox(height:splitted.contains("lookingFor")? 2.h:0),
                      splitted.contains("lookingFor")? buildText("Relationship basics", 20, FontWeight.w600, color.txtBlack):const SizedBox(),
                      splitted.contains("lookingFor")?  Row(
                        children: [
                          Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              child: SvgPicture.asset(AssetsPics.greyoutlineheart, height: 14)),
                          buildText(capitalizeWords(dataa["lookingFor"] ?? ''), 15,
                              FontWeight.w500, color.txtgrey, fontFamily: FontFamily.hellix),],):const SizedBox(),
                      SizedBox(height: 2.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildText("Location", 20, FontWeight.w600, color.txtBlack),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            height: 4.h,
                            // width: 9.h+3,
                            decoration: BoxDecoration(color: const Color.fromRGBO(230, 240, 255, 1),
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
                      buildText(dataa["country"]==null? printme(dataa["address"]??""):
                     "${dataa["state"]}, ${dataa["country"]}", 15, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
                      SizedBox(height: 2.h),
                      dataa["bio"]==null ? const SizedBox() : buildText("About", 20, FontWeight.w600, color.txtBlack),
                      // buildText(LocaleText.personDescription, 16, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
                      /*  Text(LocaleText.personDescription,style: TextStyle(
                         fontSize: 16,fontFamily: FontFamily.hellix,fontWeight: FontWeight.w500,
                         color: color.txtgrey
                       )),*/
                      dataa["bio"]==null?const SizedBox():  ExpandableText(
                        dataa["bio"]??"",
                        style: const TextStyle(fontSize: 16,fontFamily: FontFamily.hellix,fontWeight: FontWeight.w500, color: color.txtBlack),
                        expandText: '\nRead more',
                        collapseText: 'Read less',
                        maxLines: 3,
                        animation: true,
                        animationDuration: const Duration(seconds: 1),
                        linkColor: Colors.blue,
                        linkStyle: const TextStyle(color: color.txtBlue,fontWeight: FontWeight.w600,fontFamily: FontFamily.hellix,fontSize: 15),
                        linkEllipsis: false,
                      ),
                      SizedBox(height:dataa["bio"]==null?0: 2.h),
                      dataa["ideal_vacation"] != null||dataa["cooking_skill"] != null||dataa["smoking_opinion"] != null?
                      buildText("More about me", 20, FontWeight.w600, color.txtBlack):const SizedBox(),
                      Wrap(
                        children: [
                          dataa["ideal_vacation"] == null ? const SizedBox() : Container(
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
                                    margin: const EdgeInsets.only(right: 6),
                                    child: SvgPicture.asset(
                                        AssetsPics.greyideal)),
                                buildText(dataa["ideal_vacation"], 16, FontWeight.w600, color.txtBlack),
                              ],
                            ),
                          ),
                          dataa["cooking_skill"] == null ? const SizedBox() : Container(
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
                                    margin: const EdgeInsets.only(right: 6),
                                    child: SvgPicture.asset(
                                        AssetsPics.greyshefhat)),
                                buildText(dataa["cooking_skill"], 16, FontWeight.w600, color.txtBlack),
                              ],
                            ),
                          ),
                          dataa["smoking_opinion"] == null ? const SizedBox() : Container(
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
                                    margin: const EdgeInsets.only(right: 6),
                                    child: SvgPicture.asset(
                                        AssetsPics.greysmoking)),
                                buildText(dataa["smoking_opinion"], 16, FontWeight.w600, color.txtBlack),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height:dataa["interests"].length==0?0: 2.h),
                      dataa["interests"].length==0?const SizedBox():buildText("Interests", 20, FontWeight.w600, color.txtBlack),
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
                              ? Container( height: size.height*0.3,child: buildPhotoContainer(dataa["profilePictures"][0]["key"],0))
                              : Container( height: size.height*0.3,child: buildContainer())),
                          const SizedBox(width: 10),
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
                              ? buildVideoContainer(_controller!, _initializeVideoPlayerFuture!)
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
      // floatingActionButton: FloatingActionButton(
      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      //   backgroundColor: color.txtBlue,
      //   onPressed: () {},
      //   child: SvgPicture.asset(AssetsPics.floatiAction),
      // ),
    );
  }

  Widget buildPhotoContainer(String img,int i) {
    return GestureDetector(
      onTap: (){
        // Get.to(()=>ImageViewScreen(indexId: i, pictureItems: dataa["profilePictures"]));
        customSlidingImage(context,i,dataa["profilePictures"]);
      },      child: ClipRRect(borderRadius: BorderRadius.circular(16),
          // child: Image.asset(AssetsPics.photo,fit: BoxFit.cover)
          child: CachedNetworkImage(imageUrl: img, fit: BoxFit.cover, errorWidget: (context, url, error) => const Icon(Icons.error))
      ),
    );
  }

  Widget buildContainer() => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: color.txtgrey4,
    ),
    // child: Icon(Icons.info),
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
                      // Provider.of<profileController>(context,listen: false).videoUrl = cntrl.dataSource;
                      Get.to(()=>ProfileVideoViewer(url: cntrl.dataSource));
                    },
                    child: SvgPicture.asset(AssetsPics.videoplayicon)))
          ],
        ));
  }

  AnimatedContainer buildColumn(String img,double hii){
   return AnimatedContainer(
     duration: const Duration(milliseconds: 500),
      alignment: Alignment.center,
      height:isScrolled?0: hii,
      width: hii,
      decoration: BoxDecoration(
          color:img==AssetsPics.heart? color.txtBlue:img==AssetsPics.cross?color.darkcrossgrey:img==AssetsPics.superlikewhite?color.sparkPurple:Colors.white,
          shape: BoxShape.circle,
          boxShadow:const [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 20.0,
                offset: Offset(0.0,10.0)
            )
          ]
      ),
      child: SvgPicture.asset(img),
    );
  }
}
