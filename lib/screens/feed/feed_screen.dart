import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:chewie/chewie.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart'as http;
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/controller/controller.dart';
import 'package:slush/screens/feed/tutorials/controller_class.dart';
import 'package:slush/video_player/reel_screen.dart';
import 'package:slush/widgets/toaster.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/screens/events/transparentcongo.dart';
import 'package:slush/screens/feed/profile.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:video_player/video_player.dart';

import '../../controller/login_controller.dart';

class FeedScreen extends StatefulWidget {
  FeedScreen({super.key, required this.reels, required this.index, this.data});
  final List<String> reels;
  var data;

  final int index;
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with WidgetsBindingObserver{

  bool isLiked = false;
  bool isChecked = false;
  int selectedIndex = -1;
  String selectedGender="";
  List gender = ["Male", "Female", "Everyone"];
  late PageController _pageController;
  int distancevalue=250;
  int agevalue=30;
  double _startValue = 20.0;
  double _endValue = 90.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: LocaleHandler.pageIndex);
    callFuntion();
    Future.delayed(Duration(seconds: 5),(){
      // Provider.of<reelController>(context,listen: false).videoPause(false,LocaleHandler.pageIndex);
      Provider.of<reelController>(context,listen: false).videoPause(false,LocaleHandler.pageCurrentIndex);
      Provider.of<reelController>(context,listen: false).playNextReel(LocaleHandler.pageIndex);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    //   Provider.of<reelController>(context,listen: false).cntrlDispose();
    super.dispose();
  }

  void callFuntion(){
    if(LocaleHandler.reportedSuccesfuly){
  setState(() {
  LocaleHandler.curentIndexNum=0;
  LocaleHandler.reportedSuccesfuly=false;
  futuredelayed(1, true);
  futuredelayed(3, false);
  });}
    // swippedVideo(widget.data[0]["id"]);
  }

  void futuredelayed(int i,bool val){
    Future.delayed(Duration(seconds: i),(){setState(() {LocaleHandler.bannerInReel=val;});});
  }


 Future interactAPi(String action,int userId)async{
    final url=ApiList.interact;
    print(url);
    var uri=Uri.parse(url);
    var response=await http.post(uri,
      headers: {'Content-Type': 'application/json', "Authorization": "Bearer ${LocaleHandler.accessToken}"},
      body: jsonEncode({
        "status": action,
        "user": userId
      }));
    if(response.statusCode==201){}else{}
 }


  final debounce = Debounce(milliseconds: 300);
  bool isPLaying=false;

  double videoContainerRatio = 0.5;

  double getScale(double val) {
    // double videoRatio = _videoPlayerController.value.aspectRatio;
    double videoRatio = val;

    if (videoRatio < videoContainerRatio) {
      ///for tall videos, we just return the inverse of the controller aspect ratio
      return videoContainerRatio / videoRatio;
    } else {
      ///for wide videos, divide the video AR by the fixed container AR
      ///so that the video does not over scale
      return videoRatio / videoContainerRatio;
    }
  }


  @override
  Widget build(BuildContext context) {
    final reelcntrol=Provider.of<reelController>(context,listen: false);
    final size=MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: AppBar(backgroundColor: Colors.black),
      body: Stack(
        children: [
          Consumer<reelController>(builder: (build,val,child){
            return mounted ? PageView.builder(
                // physics: NeverScrollableScrollPhysics(),
                physics:LocaleHandler.subscriptionPurchase=="no"&&val.count==0 ?
                NeverScrollableScrollPhysics():ClampingScrollPhysics(),
                scrollDirection: Axis.vertical,
                controller: _pageController,
                // itemCount: widget.reels.length,
                itemCount: val.videocntroller.length,
                onPageChanged: (index) {
                  print("=======================");
                  if(index==widget.reels.length-1){
                    reelcntrol.loadmore(context,1,50,5000, LocaleHandler.latitude,LocaleHandler.longitude,
                        selectedGender=="Everyone"?"":selectedGender.toLowerCase());
                  }
                  if (index > LocaleHandler.pageIndex) {
                    debounce.run(() async {
                      reelcntrol.videoPause(true,index-1);
                      // reelcntrol.setVolumne(false,index-1);
                      reelcntrol.playNextReel(index);
                      isPLaying=!isPLaying;
                      // reelcntrol.videoPause(isPLaying,index-1);
                    });
                  } else {
                    debounce.run(() async {
                      reelcntrol.videoPause(true,index+1);
                      // reelcntrol.setVolumne(false,index+1);
                      reelcntrol.playPreviousReel(index);
                      isPLaying=!isPLaying;
                      // reelcntrol.videoPause(isPLaying,index+1);
                    });
                  }
                  reelcntrol.swippedVideo(context, widget.data[index]["id"]);
                },
                itemBuilder: (context, index) {
                  // isLiked=widget.data[index]["hasLiked"];
                  // String name=widget.data[index]["user"]["fullName"]!=null?widget.data[index]["user"]["fullName"] :widget.data[index]["user"]["nickName"]??"";
                  String name=widget.data[index]["user"]["fullName"] ?? widget.data[index]["user"]["nickName"]??"";
                  return GestureDetector(onTap: (){
                    if(val.pause) {reelcntrol.videoPause(false,index);}
                    else {reelcntrol.videoPause(true,index);}
                  },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        val.videocntroller[index].value.isInitialized || context.mounted?
                        // val.videocntroller[index].value.isInitialized?
                        // VideoPlayerWidget(key: Key(val.videocntroller[index].dataSource), reelUrl: val.videocntroller[index].dataSource)
                        AspectRatio(
                            // aspectRatio: 9 / 16,
                            aspectRatio: val.videoPlayerController[index].value.aspectRatio,
                            child: VideoPlayer(val.videocntroller[index]))
                            :Center(child: CircularProgressIndicator(color: color.txtBlue)),
                        // SizedBox( height: size.height, width: size.width, child: Image.asset(AssetsPics.thirdBg,fit: BoxFit.cover,), ),
                        Padding(
                          padding:  EdgeInsets.symmetric(horizontal: 15,vertical:defaultTargetPlatform==TargetPlatform.iOS?45: 20),
                          child: Column(
                            children: [
                              SizedBox(height: 3.h-3),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Consumer<reelController>(builder:  (context,value,child) {
                                    return GestureDetector(
                                        onTap: (){reelcntrol.setVolumne(value.isMute?false:true,index);},
                                        child:Consumer<reelTutorialController>(builder: (context,val,child){return val.cou==4?SizedBox():SvgPicture.asset(value.isMute ? AssetsPics.Mute : AssetsPics.unMute,height: 50);}),
                             //child: SvgPicture.asset(value.isMute ? AssetsPics.Mute : AssetsPics.unMute,height: 50)
                                    );
                                  }),
                                  GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedIndex=LocaleHandler.selectedIndexGender;
                                          agevalue= LocaleHandler.agevalue;
                                          distancevalue=LocaleHandler.distancevalue;
                                          isChecked=LocaleHandler.isChecked ;
                                        });
                                        customReelBoxFilter(context);
                                      },
                                    child:Consumer<reelTutorialController>(builder: (context,val,child){return val.cou==5||val.cou==6?SizedBox():SvgPicture.asset(AssetsPics.reelFilterIcon,height: 50);}),
                                    // child: SvgPicture.asset(AssetsPics.reelFilterIcon,height: 50)
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: (){
                                          reelcntrol.videoPause(true,index);
                                          Get.to(()=>FeedPersonProfileScreen(id: widget.data[index]["user"]["id"].toString()))!.
                                          then((value) {
                                            if(value==true){
                                              _pageController.nextPage(duration: Duration(milliseconds: 1000), curve: Curves.easeIn);
                                            }
                                          });
                                        },
                                        child: Consumer<reelTutorialController>(builder: (context,val,child){
                                            return val.cou==1?SizedBox(): CircleAvatar(
                                              radius:30,
                                              child: SizedBox(width: 65, height: 65,
                                                  child: ClipOval(
                                                    child: CachedNetworkImage(imageUrl: widget.data[index]["user"]["avatar"],fit: BoxFit.cover),
                                                  )
                                              ),
                                            );
                                          }
                                        ),
                                      ),
                                      SizedBox(height: 1.h),
                                      Consumer<reelTutorialController>(builder: (context,val,child){
                                        return buildText(val.cou==3?"":name, 17, FontWeight.w600, color.txtWhite);
                                      }),
                                      // buildText(name, 17, FontWeight.w600, color.txtWhite),
                                      SizedBox(height: 1.h-5),
                                      Consumer<reelController>(builder: (context,value,i){return  SizedBox(
                                        height:value.biohieght? MediaQuery.of(context).size.height/2:45,
                                        width: MediaQuery.of(context).size.width/1.5,
                                        child:  Consumer<reelTutorialController>(builder: (ctx,val,child){
                                          return ExpandableText(val.cou==3?"":  widget.data[index]["user"]["bio"]??"",
                                            style: const TextStyle(color: color.txtWhite,fontWeight: FontWeight.w500,fontSize: 15,fontFamily: FontFamily.hellix),
                                            expandText: '',
                                            expandOnTextTap: true,
                                            collapseOnTextTap: true,
                                            maxLines: 3,
                                            linkColor: color.txtWhite,
                                            onExpandedChanged: (val){
                                              Provider.of<reelController>(context,listen: false).changeBioHieght(val);
                                            },
                                          );
                                        })
                                      );}),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom:defaultTargetPlatform==TargetPlatform.iOS?38: 20,
                          right: 15,
                          child: Column(
                            children: [
                              GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      reelcntrol.videoPause(true,index);
                                      // LocaleHandler.matchedd=true;
                                      reelcntrol.congoScreen(true,widget.data[index]["user"]["avatar"]);
                                      // LocaleHandler.curentIndexNum=2;
                                      Get.to(()=> TransparentCongoWithBottomScreen(userId: widget.data[index]["user"]["id"],name: name,));
                                    });
                                  },
                                  child: CircleAvatar(backgroundColor: Colors.white, radius: 30,
                                      child: SvgPicture.asset(AssetsPics.superlike,height: 25))),
                              // child: SvgPicture.asset(AssetsPics.superlike,height: 57))),
                              SizedBox(height:2.h),
                              GestureDetector(onTap: () {
                                setState(() {isLiked=!isLiked;});
                            /*    if(widget.data[index]["hasLiked"] == false){ setState(() {widget.data[index]["hasLiked"] = true; isLiked=true; });
                                  // _pageController.nextPage(duration: Duration(milliseconds: 1000), curve: Curves.easeIn);
                                  interactAPi("LIKED", widget.data[index]["user"]["id"]);   } else {isLiked=false;
                                  interactAPi("DISLIKED", widget.data[index]["user"]["id"]);
                                }*/
                              },
                                  // child: SvgPicture.asset(isLiked? AssetsPics.active:AssetsPics.inactive,height: 70)
                                child: Consumer<reelTutorialController>(builder: (context,val,child){return val.cou==2?SizedBox(
                                  height: size.height*0.1-8,width: size.width*0.2-6,): SvgPicture.asset(isLiked? AssetsPics.active:AssetsPics.inactive,height:70);})
                              ),
                              SizedBox(height: 10.h),
                            ],
                          ),
                        ),
                        if (val.pause)
                          const Center(
                            child: Icon(
                              Icons.play_arrow,
                              size: 50.0,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  );}):Center(child: CircularProgressIndicator());
          }),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
          // padding: EdgeInsets.only(top: 30),
          height: LocaleHandler.bannerInReel?
          13.5.h:0,
            // width: size.width,
            width: size.width.w,
            child: FittedBox(fit: BoxFit.fill,
                child: Image.asset(AssetsPics.reportbanner,fit: BoxFit.fill)),
          ),
        ],
      ),
    );
  }
  customReelBoxFilter(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return showGeneralDialog(
        barrierLabel: "Label",
        transitionDuration: const Duration(milliseconds: 500),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return StatefulBuilder(
              builder: (context,setState) {
                return GestureDetector(
                  // onTap: onTap,
                  child: Scaffold(
                    backgroundColor: Colors.transparent,
                    body: Align(
                      alignment: Alignment.bottomCenter,
                      child: Stack(
                        children: [
                          Container(
                            // height: MediaQuery.of(context).size.height/2.5,
                              width: MediaQuery.of(context).size.width/1.1,
                              margin:  EdgeInsets.only(bottom:defaultTargetPlatform==TargetPlatform.iOS?24: 12,top: 8,right: 7),
                              // padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(color: color.txtWhite, borderRadius: BorderRadius.circular(15),),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(padding: const EdgeInsets.only(left: 15,right: 15,bottom: 10,top: 15),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(alignment: Alignment.center, height: 10, width: 80,),
                                        // SizedBox(height: 10,),
                                        buildText("Filter", 28, FontWeight.w600, color.txtBlack),
                                        const SizedBox(height: 10),
                                        buildText("Distance", 18, FontWeight.w600, color.txtBlack),
                                        const SizedBox(height: 50),
                                        Container(
                                          height: 30,
                                          width: MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: color.txtWhite),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [

                                              SliderTheme(
                                                data: SliderTheme.of(context).copyWith(
                                                  trackHeight: 5.0,
                                                  inactiveTickMarkColor: Colors.transparent,
                                                  trackShape: const RoundedRectSliderTrackShape(),
                                                  activeTrackColor: color.txtBlue,
                                                  inactiveTrackColor: color.lightestBlueIndicator,
                                                  activeTickMarkColor: Colors.transparent,
                                                  thumbShape: const RoundSliderThumbShape(
                                                    enabledThumbRadius: 14.0,
                                                    pressedElevation: 8.0,
                                                  ),
                                                  thumbColor: Colors.white,
                                                  overlayColor: const Color(0xff2280EF).withOpacity(0.2),
                                                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
                                                  valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                                                  valueIndicatorColor: Colors.blue,
                                                  valueIndicatorTextStyle: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20.0,
                                                  ),
                                                ),
                                                child: Slider(
                                                  min: 5.0,
                                                  max: 500.0,
                                                  value: distancevalue.toDouble(),
                                                  divisions: 99,
                                                  label: '${distancevalue.round()} km',
                                                  onChanged: (value) {setState(() {distancevalue = value.toInt();});},
                                                ),
                                              ),
                                              Positioned(left: 13.0,
                                                child: IgnorePointer(
                                                  child: CircleAvatar(
                                                    radius: 7,
                                                    child: SvgPicture.asset(AssetsPics.sliderleft),
                                                  ),
                                                ),
                                              ),
                                              /*      IgnorePointer(
                child: CircleAvatar(
                  radius: 16,
                  child: SvgPicture.asset("assets/icons/sliderright.svg"),
                ),
              ),*/
                                              // Container(height: 20,width: 100,color: Colors.red,)
                                            ],
                                          ),
                                        ),
                                      ],),
                                  ),
                                  // Padding(
                                  //   padding: const EdgeInsets.only(left: 15,right: 15,bottom: 0,top: 10),
                                  //   child: Column(
                                  //     crossAxisAlignment: CrossAxisAlignment.start,
                                  //     children: [
                                  //       buildText("Age", 18, FontWeight.w600, color.txtBlack),
                                  //       const SizedBox(height: 50),
                                  //       Container(
                                  //         height: 30,
                                  //         width: MediaQuery.of(context).size.width,
                                  //         decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: color.txtWhite),
                                  //         child: Stack(
                                  //           alignment: Alignment.center,
                                  //           children: [
                                  //             /*SfSliderTheme(
                                  //               data: SfSliderThemeData(tooltipBackgroundColor: Colors.blue, thumbRadius: 8,
                                  //                 tooltipTextStyle: const TextStyle(fontSize: 16),
                                  //               ),
                                  //               child: SfSlider(
                                  //                 // numberFormat: ,
                                  //                   shouldAlwaysShowTooltip: false,
                                  //                   // thumbIcon: CircleAvatar(radius: 50, child: Image.asset("assets/images/eventProfile.png")),
                                  //                   thumbIcon: const Stack(
                                  //                     alignment: Alignment.center,
                                  //                     children: [
                                  //                       CircleAvatar(backgroundColor: color.txtBlue),
                                  //                       CircleAvatar(radius: 5, backgroundColor: color.txtWhite),
                                  //                     ],
                                  //                   ),
                                  //                   min: 18,
                                  //                   max: 70.0,
                                  //                   value: agevalue.toDouble(),
                                  //                   interval: 1,
                                  //                   showTicks: false,
                                  //                   showLabels: false,
                                  //                   enableTooltip: true,
                                  //                   minorTicksPerInterval: 1,
                                  //                   onChanged: (dynamic value) {setState(() {agevalue = value.toInt();});},
                                  //                   activeColor: color.txtBlue,
                                  //                   dividerShape: const SfDividerShape(),
                                  //                   tooltipShape: const SfPaddleTooltipShape(),
                                  //                   edgeLabelPlacement: EdgeLabelPlacement.inside,
                                  //                   inactiveColor: color.lightestBlueIndicator,
                                  //                   labelPlacement: LabelPlacement.betweenTicks,
                                  //                   tooltipTextFormatterCallback: (dynamic actualValue, String formattedText) {
                                  //                     return formatValue(actualValue.toDouble());}
                                  //               ),
                                  //             ),*/
                                  //             SliderTheme(
                                  //               data: SliderTheme.of(context).copyWith(
                                  //                 trackHeight: 5.0,
                                  //                 inactiveTickMarkColor: Colors.transparent,
                                  //                 trackShape: const RoundedRectSliderTrackShape(),
                                  //                 activeTrackColor: color.txtBlue,
                                  //                 inactiveTrackColor: color.lightestBlueIndicator,
                                  //                 activeTickMarkColor: Colors.transparent,
                                  //                 thumbShape: const RoundSliderThumbShape(
                                  //                   enabledThumbRadius: 14.0,
                                  //                   pressedElevation: 8.0,
                                  //                 ),
                                  //                 thumbColor: Colors.white,
                                  //                 overlayColor: const Color(0xff2280EF).withOpacity(0.2),
                                  //                 overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
                                  //                 valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                                  //                 valueIndicatorColor: Colors.blue,
                                  //                 valueIndicatorTextStyle: const TextStyle(
                                  //                   color: Colors.white,
                                  //                   fontSize: 20.0,
                                  //                 ),
                                  //               ),
                                  //               child: Slider(
                                  //                 min: 18.0,
                                  //                 max: 70.0,
                                  //                 value: agevalue.toDouble(),
                                  //                 divisions: 100,
                                  //                 label: '${agevalue.round()}',
                                  //                 onChanged: (value) {setState((){agevalue = value.toInt();});},
                                  //               ),
                                  //             ),
                                  //             Positioned(left: 13.0,
                                  //               child: IgnorePointer(
                                  //                 child: CircleAvatar(
                                  //                   radius: 7,
                                  //                   child: SvgPicture.asset(AssetsPics.sliderleft),
                                  //                 ),
                                  //               ),
                                  //             ),
                                  //           ],
                                  //         ),
                                  //       ),
                                  //       const SizedBox(height: 20),
                                  //     ],),
                                  // ),
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: color.txtWhite
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15, right: 15, bottom: 10, top: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          buildText("Age Range", 18, FontWeight.w600, color.txtBlack),
                                          Container(
                                            height: 13.h,
                                            width: size.width,
                                            padding: const EdgeInsets.only(top: 20),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Consumer<loginControllerr>(builder: (context,valuee,index){
                                                  return SliderTheme(
                                                      data: SliderTheme.of(context).copyWith(
                                                        trackHeight: 5.0,
                                                        inactiveTickMarkColor: Colors.transparent,
                                                        trackShape: RoundedRectSliderTrackShape(),
                                                        activeTrackColor: color.txtBlue,
                                                        inactiveTrackColor: color.lightestBlueIndicator,
                                                        activeTickMarkColor: Colors.transparent,
                                                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14.0, pressedElevation: 8.0),
                                                        thumbColor: Colors.white,
                                                        overlayColor: Color(0xff2280EF).withOpacity(0.2),
                                                        overlayShape: RoundSliderOverlayShape(overlayRadius: 20.0),
                                                        valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                                                        // valueIndicatorShape: ,

                                                        valueIndicatorColor: Colors.blue,
                                                        valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
                                                      ),
                                                      child: RangeSlider(
                                                        divisions: 9,
                                                        labels: RangeLabels(
                                                          _startValue.round().toString(),
                                                          _endValue.round().toString(),
                                                        ),

                                                        min: 18.0,
                                                        max: 100.0,
                                                        values: RangeValues(_startValue, _endValue),

                                                        onChanged: (values) {
                                                          setState(() {
                                                            _startValue = values.start;
                                                            _endValue = values.end;
                                                          });
                                                        },
                                                      )
                                                  );}),
                                              ],
                                            ),
                                          )
                                        ],),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15,right: 15,bottom: 0,top: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        buildText("Show me", 18, FontWeight.w600, color.txtBlack),
                                        Container(
                                          // padding: const EdgeInsets.only(left: 5),
                                            alignment: Alignment.center,
                                            height: 46,
                                            width: MediaQuery.of(context).size.width,
                                            // color: Colors.red,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                              ListView.builder(
                                                shrinkWrap: true,
                                                  physics: NeverScrollableScrollPhysics(),
                                                  scrollDirection: Axis.horizontal,
                                                  itemCount: gender.length,
                                                  itemBuilder: (context,index){
                                                    return Row(
                                                      children: [
                                                        GestureDetector(onTap: (){
                                                          setState(() {selectedIndex=index;
                                                          selectedGender=gender[index];});},
                                                            child:selectedIndex==index?
                                                            selectedButton(gender[index],size):unselectedButton(gender[index],size)),
                                                        SizedBox(width: size.width*0.02)
                                                      ],);})
                                            ],)
                                        ),
                                      ],),
                                  ),
                                  const SizedBox(height: 8,),
                                  const Divider(thickness: 0.5,color: color.lightestBlue),
                                  const SizedBox(height: 4,),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15,right: 15,bottom: 0,top: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      //crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        buildText("Verified users only", 18, FontWeight.w600, color.txtBlack),
                                        GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                isChecked = !isChecked;
                                              });
                                            },
                                            child: SvgPicture.asset(isChecked == true ? AssetsPics.checkbox : AssetsPics.blankCheckbox)),
                                      ],),
                                  ),
                                  const SizedBox(height: 8,),
                                  const Divider(thickness: 0.5,color: color.lightestBlue),
                                  const SizedBox(height: 11),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15,right: 15,bottom: 15),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: (){
                                            LocaleHandler.selectedIndexGender=-1;
                                            LocaleHandler.agevalue=30;
                                            LocaleHandler.distancevalue=250;
                                            LocaleHandler.isChecked = false;
                                            Get.back();
                                            },
                                          child: Container(
                                            alignment: Alignment.center,
                                            height: 56,
                                            width: MediaQuery.of(context).size.width/2-40,
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                                                color: color.txtWhite,
                                                border: Border.all(width: 1.5,color: color.txtBlue)
                                            ),
                                            child: buildText("Clear all",18,FontWeight.w600,color.txtBlue),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: (){
                                            Provider.of<reelController>(context,listen: false).videoPause(true,LocaleHandler.pageIndex);
                                            Provider.of<reelController>(context,listen: false).getVidero(context, 1,agevalue,distancevalue, LocaleHandler.latitude,LocaleHandler.longitude,
                                                selectedGender=="Everyone"?"":selectedGender.toLowerCase());
                                            setState(() {
                                              LocaleHandler.selectedIndexGender=selectedIndex;
                                              LocaleHandler.agevalue=agevalue;
                                              LocaleHandler.distancevalue=distancevalue;
                                              LocaleHandler.isChecked = isChecked;
                                            });
                                          Get.back();
                                            },
                                          // onTap: onTap2,
                                          child: Container(
                                            alignment: Alignment.center,
                                            height: 56,
                                            width: MediaQuery.of(context).size.width/2-40,
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                                                gradient:  const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
                                                  colors:[color.gradientLightBlue, color.txtBlue],)
                                            ),
                                            child: buildText("Apply",18,FontWeight.w600,color.txtWhite),
                                          ),
                                        ),
                                      ],),),
                                  const SizedBox(height: 4),
                                ],
                              )),
                          Positioned(
                            right: 0.15,
                            top: 0.15,
                            child: GestureDetector(
                              onTap: (){Get.back();},
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: color.txtWhite,
                                child: SvgPicture.asset(AssetsPics.cancel),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }
          );
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(anim1),
            child: child,
          );}
    );
  }

}