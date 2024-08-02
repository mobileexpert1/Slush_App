import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/controller/controller.dart';
import 'package:slush/controller/profile_controller.dart';
import 'package:slush/screens/feed/tutorials/controller_class.dart';
import 'package:slush/screens/profile/spark_purchase.dart';
import 'package:slush/video_player/reel_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/screens/feed/profile.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:slush/widgets/toaster.dart';
import 'package:video_player/video_player.dart';
import '../../controller/login_controller.dart';
import '../../widgets/thumb_class.dart';

class FeedScreen extends StatefulWidget {
  FeedScreen({super.key, required this.reels, required this.index, this.data});

  final List<String> reels;
  var data;

  final int index;

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with WidgetsBindingObserver {

  bool isChecked = false;
  int selectedIndex = -1;
  String selectedGender = "";
  List gender = ["Male", "Female", "Everyone"];
  late PageController _pageController;
  int distancevalue = 250;
  double _startValue = 18.0;
  double _endValue = 90.0;
  var _value = 250;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: LocaleHandler.pageIndex);
    callFuntion();
    Future.delayed(const Duration(seconds: 5), () {
      // Provider.of<reelController>(context,listen: false).videoPause(false,LocaleHandler.pageIndex);
      Provider.of<reelController>(context, listen: false).videoPause(false, LocaleHandler.pageCurrentIndex);
      Provider.of<reelController>(context, listen: false).playNextReel(LocaleHandler.pageIndex);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void callFuntion() {
    if (LocaleHandler.reportedSuccesfuly) {
      setState(() {
        LocaleHandler.reportedSuccesfuly = false;
        futuredelayed(1, true);
        futuredelayed(3, false);
      });
    }
    // swippedVideo(widget.data[0]["id"]);
  }

  void futuredelayed(int i, bool val) {
    Future.delayed(Duration(seconds: i), () {
      setState(() {
        LocaleHandler.bannerInReel = val;
      });
    });
  }

  Future interactAPi(String action, int userId,int index,String name) async {
    final url = ApiList.interact;
    print(url);
    var uri = Uri.parse(url);
    var response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${LocaleHandler.accessToken}"
        },
        body: jsonEncode({"status": action, "user": userId}));
    if (response.statusCode == 201) {
      var data=jsonDecode(response.body);
      Provider.of<profileController>(context,listen: false).getTotalSparks();
      if(data["isMatch"]&&action!="DISLIKED") {
        Provider.of<reelController>(context, listen: false).videoPause(true, index);
        Provider.of<reelController>(context, listen: false).congoScreen(true, widget.data[index]["user"]["avatar"],name,userId);
        // Get.to(() => TransparentCongoWithBottomScreen(userId: widget.data[index]["user"]["id"], name: name));
      }
    } else {}
  }

  final debounce = Debounce(milliseconds: 300);
  bool isPLaying = false;

  double videoContainerRatio = 0.5;

  double getScale(double val) {
    // double videoRatio = _videoPlayerController.value.aspectRatio;
    double videoRatio = val;
    if (videoRatio < videoContainerRatio) {return videoContainerRatio / videoRatio;}
    else {return videoRatio / videoContainerRatio;}
  }

  List user=[];

  @override
  Widget build(BuildContext context) {
    final reelcntrol = Provider.of<reelController>(context, listen: false);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Consumer<reelController>(builder: (build, val, child) {
            return mounted ? PageView.builder(
                    // physics: NeverScrollableScrollPhysics(),
                    physics: LocaleHandler.subscriptionPurchase == "no" && val.count == 0 ? const NeverScrollableScrollPhysics() : const ClampingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    controller: _pageController,
                    // itemCount: widget.reels.length,
                    itemCount: val.videocntroller.length,
                    onPageChanged: (index) {
                      print("=======================");
                      if (index == widget.reels.length - 2) {
                        reelcntrol.loadmore(context, 1, 50, 5000, LocaleHandler.latitude, LocaleHandler.longitude, selectedGender == "Everyone" ? "" : selectedGender.toLowerCase());
                      }
                      if (index > LocaleHandler.pageIndex) {
                        debounce.run(() async {
                          reelcntrol.videoPause(true, index - 1);
                          // reelcntrol.setVolumne(false,index-1);
                          reelcntrol.playNextReel(index);
                          isPLaying = !isPLaying;
                          // reelcntrol.swippedVideo(context, widget.data[index]["id"]);
                          // reelcntrol.videoPause(isPLaying,index-1);
                        });
                      } else {
                        debounce.run(() async {
                          reelcntrol.videoPause(true, index + 1);
                          // reelcntrol.setVolumne(false,index+1);
                          reelcntrol.playPreviousReel(index);
                          isPLaying = !isPLaying;
                          // reelcntrol.videoPause(isPLaying,index+1);
                        });
                      }
                      Provider.of<reelController>(context,listen: false).changeBioHieght(false);
                    },
                    itemBuilder: (context, index) {
                      // String name=widget.data[index]["user"]["fullName"]!=null?widget.data[index]["user"]["fullName"] :widget.data[index]["user"]["nickName"]??"";
                      String name = widget.data[index]["user"]["fullName"] ?? widget.data[index]["user"]["nickName"] ?? "";
                      print(":_------------${widget.data[index]["hasLiked"]}");
                      return GestureDetector(
                        onTap: () {
                          if (val.pause) {reelcntrol.videoPause(false, index);}
                          else {reelcntrol.videoPause(true, index);}
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // val.videocntroller[index+1].value.isInitialized || context.mounted?
                            val.videocntroller[index].value.isInitialized  ?
                                // VideoPlayerWidget(key: Key(val.videocntroller[index].dataSource), reelUrl: val.videocntroller[index].dataSource)
                                AspectRatio(
                                    aspectRatio: val.videoPlayerController[index].value.aspectRatio,
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: VideoPlayer(val.videocntroller[index])))
                                : const Center(child: CircularProgressIndicator(color: color.txtBlue)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15, vertical: defaultTargetPlatform == TargetPlatform.iOS ? 45 : 20),
                              child: Column(
                                children: [
                                  SizedBox(height: 3.h - 3),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Consumer<reelController>(builder: (context, value, child) {
                                        return GestureDetector(
                                          onTap: () {
                                            reelcntrol.setVolumne(value.isMute ? false : true, index);
                                          },
                                          child: Consumer<reelTutorialController>(
                                              builder: (context, val, child) {
                                            return val.cou == 4 ? const SizedBox() :
                                            SvgPicture.asset(value.isMute ? AssetsPics.Mute : AssetsPics.unMute, height: 50);
                                          }),
                                        );
                                      }),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedIndex = LocaleHandler.selectedIndexGender;
                                            _startValue = LocaleHandler.startage.toDouble();
                                            _endValue = LocaleHandler.endage.toDouble();
                                            distancevalue = LocaleHandler.distancevalue;
                                            isChecked = LocaleHandler.isChecked;
                                          });
                                          customReelBoxFilter(context);
                                        },
                                        child: Consumer<reelTutorialController>(
                                            builder: (context, val, child) {
                                          return val.cou == 5 || LocaleHandler.scrollLimitreached
                                              ? const SizedBox()
                                              : SvgPicture.asset(AssetsPics.reelFilterIcon, height: 50);
                                        }),
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
                                            onTap: () {
                                              reelcntrol.videoPause(true, index);
                                              Get.to(() => FeedPersonProfileScreen(id: widget.data[index]["user"]["id"].toString()))!
                                                  .then((value) {
                                                reelcntrol.videoPause(false, index);
                                                    if (value == true) {
                                                  _pageController.nextPage(duration: const Duration(milliseconds: 1000), curve: Curves.easeIn);
                                                }
                                              });
                                            },
                                            child: Consumer<reelTutorialController>(builder: (context, val, child) {
                                              return val.cou == 1
                                                  ? const SizedBox()
                                                  : CircleAvatar(
                                                      radius: 30,
                                                      child: SizedBox(
                                                          width: 65,
                                                          height: 65,
                                                          child: ClipOval(
                                                            child:widget.data[index]["user"]["avatar"]==null?
                                                                Image.asset(AssetsPics.demouser)
                                                                : CachedNetworkImage(
                                                              imageUrl: widget.data[index]["user"]["avatar"],fit: BoxFit.cover,
                                                              errorWidget: (context, url, error) => const SizedBox(),
                                                              // placeholder: (ctx,url)=>const Center(child: CircularProgressIndicator(color: color.txtBlue)),
                                                            ))),
                                                    );
                                            }),
                                          ),
                                          SizedBox(height: 1.h),
                                          Consumer<reelTutorialController>(builder: (context, val, child) {
                                            return Row(
                                              children: [
                                                buildText(val.cou == 3 ? "" : name, 17, FontWeight.w600, color.txtWhite),
                                                const SizedBox(width: 6),
                                                val.cou == 3?const SizedBox():  SvgPicture.asset(widget.data[index]["isVerified"] ==1 ? AssetsPics.verify : AssetsPics.verifygrey)
                                              ],
                                            );
                                          }),
                                          // buildText(name, 17, FontWeight.w600, color.txtWhite),
                                          SizedBox(height: 1.h - 5),
                                          Consumer<reelController>(builder: (context, value, i) {
                                            return SizedBox(
                                                height:value.biohieght? MediaQuery.of(context).size.height/6:45,
                                                // height:MediaQuery.of(context).size.height/2,
                                                width: MediaQuery.of(context).size.width /1.5,
                                                child: Consumer<reelTutorialController>(builder: (ctx, val, child) {
                                                  return SingleChildScrollView(
                                                    child: ExpandableText(
                                                      val.cou == 3 ? "" : widget.data[index]["user"]["bio"] ?? "",
                                                      style: const TextStyle(color: color.txtWhite,
                                                          fontWeight: FontWeight.w500, fontSize: 15,
                                                          fontFamily: FontFamily.hellix),
                                                      expandText: '',
                                                      expandOnTextTap: true,
                                                      collapseOnTextTap: true,
                                                      maxLines: 3,
                                                      linkColor: color.txtWhite,
                                                      onExpandedChanged: (val) {
                                                        Provider.of<reelController>(context, listen: false).changeBioHieght(val);
                                                      },
                                                    ),
                                                  );
                                                }));
                                          }),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.h),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: defaultTargetPlatform == TargetPlatform.iOS ? 38 : 20,
                              right: 15,
                              child: Column(
                                children: [
                                  Consumer<profileController>(
                                      builder: (context,val,child){
                                        return GestureDetector(
                                            onTap: (){
                                              customSparkBottomSheet(context,AssetsPics.sparkleft, "Are you sure you would like to use 1 x Spark?", "Cancel", "Yes",true,
                                                  sparks: val.sparks,
                                                  onTap2: (){Get.back();
                                                  if(val.sparks<=0) {
                                                    customSparkBottomSheet(context, AssetsPics.sparkempty,
                                                        " You have run out of Sparks, please purchase  more.",
                                                        "Cancel", "Purchase", false,onTap2: (){
                                                          Get.back();
                                                          Get.to(()=>const SparkPurchaseScreen());
                                                        });
                                                  }else{
                                                    if(LocaleHandler.sparkLiked.contains(widget.data[index]["user"]["id"])){
                                                      showToastMsg("already Spark liked");
                                                    }
                                                    else{
                                                      // Provider.of<reelController>(context, listen: false).videoPause(true, index);
                                                      // Provider.of<reelController>(context, listen: false).congoScreen(true, widget.data[index]["user"]["avatar"],name,widget.data[index]["user"]["id"]);
                                                    interactAPi("SPARK LIKE", widget.data[index]["user"]["id"],index,name);
                                                    Provider.of<reelController>(context, listen: false).alreadySparkLiked(widget.data[index]["user"]["id"]);
                                                    showToastMsg("Spark Liked");
                                                    }
                                                  }});},

                                            child: AnimatedSwitcher(
                                              duration: const Duration(milliseconds: 500),
                                              transitionBuilder: (Widget child, Animation<double> animation) {
                                                return FadeTransition(opacity: animation, child: child);
                                              },
                                              child:LocaleHandler.sparkLiked.contains(widget.data[index]["user"]["id"])?
                                              CircleAvatar(backgroundColor: color.sparkPurple, radius: 30, child: SvgPicture.asset(AssetsPics.superlikewhite, height: 25),
                                                  key: const ValueKey('sparked')
                                              )
                                              :CircleAvatar(backgroundColor: Colors.white, radius: 30, child: SvgPicture.asset(AssetsPics.superlike, height: 25,
                                                  key: const ValueKey('unsparked')
                                              )),
                                            ));
                                      }
                                  ),
                                  // child: SvgPicture.asset(AssetsPics.superlike,height: 57))),
                                  SizedBox(height: 2.h),
                                  GestureDetector(onTap: () {
                                    setState(() {widget.data[index]["hasLiked"]=!widget.data[index]["hasLiked"];});
                                    if(widget.data[index]["hasLiked"])
                                    {interactAPi("LIKED", widget.data[index]["user"]["id"],index,name);}
                                  else {interactAPi("DISLIKED", widget.data[index]["user"]["id"],index,name);}
                                  }, // child: SvgPicture.asset(isLiked? AssetsPics.active:AssetsPics.inactive,height: 70)
                                      child: Consumer<reelTutorialController>(builder: (context, val, child) {
                                    return val.cou == 2
                                        ? SizedBox(height: size.height * 0.1 - 8, width: size.width * 0.2 - 6)
                                        : AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 300),
                                        transitionBuilder: (Widget child, Animation<double> animation) {
                                          return FadeTransition(opacity: animation, child: child);
                                        },
                                        child:widget.data[index]["hasLiked"]? SvgPicture.asset(AssetsPics.active,height: 70,key: const ValueKey('like'))
                                            :SvgPicture.asset(AssetsPics.inactive,height: 70,key: const ValueKey('dislike')));
                                  })),
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
                      );
                    })
                : const Center(child: CircularProgressIndicator());
          }),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            // padding: EdgeInsets.only(top: 30),
            height: LocaleHandler.bannerInReel ? 13.5.h : 0,
            // width: size.width,
            width: size.width.w,
            child: FittedBox(
                fit: BoxFit.fill,
                child: Image.asset(AssetsPics.reportbanner, fit: BoxFit.fill)),
          ),],
      ),
    );
  }

  customReelBoxFilter(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return showGeneralDialog(
        barrierLabel: "Label",
        transitionDuration: const Duration(milliseconds: 500),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return StatefulBuilder(builder: (context, setState) {
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
                          width: MediaQuery.of(context).size.width / 1.1,
                          margin: EdgeInsets.only(
                              bottom: defaultTargetPlatform == TargetPlatform.iOS ? 24 : 12,
                              top: 8, right: 7),
                          // padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: color.txtWhite,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(alignment: Alignment.center,
                                      height: 10,
                                      width: 80,
                                    ),
                                    // SizedBox(height: 10,),
                                    buildText("Filter", 28, FontWeight.w600, color.txtBlack),
                                    const SizedBox(height: 10),
                                    buildText("Distance", 18, FontWeight.w600, color.txtBlack),
                                    const SizedBox(height: 50),
                                    Container(
                                      height: 30,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          color: color.txtWhite),
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
                                              thumbShape: CustomSliderThumb(
                                                displayValue: distancevalue,
                                              ),
                                              thumbColor: color.txtBlue,
                                              overlayColor: const Color(0xff2280EF).withOpacity(0.2),
                                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
                                              valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                                              valueIndicatorColor: Colors.blue,
                                              showValueIndicator: ShowValueIndicator.never,
                                              valueIndicatorTextStyle:
                                                  const TextStyle(
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
                                              onChanged: (value) {
                                                setState(() {
                                                  distancevalue = value.toInt();
                                                });
                                              },
                                            ),
                                          ),
                                          Positioned(
                                            left: 13.0,
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
                                  ],
                                ),
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
                                    color: color.txtWhite),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      buildText("Age Range", 18,
                                          FontWeight.w600, color.txtBlack),
                                      Container(
                                        height: 13.h,
                                        width: size.width,
                                        padding: const EdgeInsets.only(top: 20),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Consumer<loginControllerr>(builder:
                                                (context, valuee, index) {
                                              return Stack(
                                                children: [
                                                  RangeSlider(
                                                    activeColor: color.txtBlue,
                                                    inactiveColor: color.lightestBlueIndicator,
                                                    // divisions: 9,
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
                                                  ),
                                                  Positioned(
                                                    left: (size.width - 50) * (_startValue - 18) / (100 - 8), // Calculate left position dynamically
                                                    top: 1,
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue,
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Text(
                                                        '${_startValue.round()}',
                                                        style: const TextStyle(color: Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    right: (size.width - 50) * (100 - _endValue) / (100 - 8), // Calculate right position dynamically
                                                    top: 1,
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue,
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Text(
                                                        '${_endValue.round()}',
                                                        style: const TextStyle(color: Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                              // return SliderTheme(
                                              //     data: SliderTheme.of(context).copyWith(
                                              //       trackHeight: 5.0,
                                              //       inactiveTickMarkColor: Colors.transparent,
                                              //       trackShape: const RoundedRectSliderTrackShape(),
                                              //       activeTrackColor: color.txtBlue,
                                              //       inactiveTrackColor: color.lightestBlueIndicator,
                                              //       activeTickMarkColor: Colors.transparent,
                                              //       thumbShape:
                                              //           const RoundSliderThumbShape(
                                              //               enabledThumbRadius: 14.0,
                                              //               pressedElevation: 8.0),
                                              //       thumbColor: Colors.white,
                                              //       overlayColor: const Color(0xff2280EF).withOpacity(0.2),
                                              //       overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
                                              //       valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                                              //       // valueIndicatorShape: ,
                                              //
                                              //       valueIndicatorColor: Colors.blue,
                                              //       valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
                                              //     ),
                                              //     child: RangeSlider(
                                              //       divisions: 9,
                                              //       labels: RangeLabels(
                                              //         _startValue.round().toString(),
                                              //         _endValue.round().toString(),
                                              //       ),
                                              //       min: 18.0,
                                              //       max: 100.0,
                                              //       values: RangeValues(_startValue, _endValue),
                                              //       onChanged: (values) {
                                              //         setState(() {
                                              //           _startValue = values.start;
                                              //           _endValue = values.end;
                                              //         });
                                              //       },
                                              //     ));
                                            }),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 15, right: 15, bottom: 0, top: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildText("Show me", 18, FontWeight.w600, color.txtBlack),
                                    Container(
                                        padding: const EdgeInsets.only(left: 5),
                                        //   alignment: Alignment.center,
                                        height: 46,
                                        width: MediaQuery.of(context).size.width,
                                        // color: Colors.red,
                                        child: Row(
                                          // mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            ListView.builder(
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                scrollDirection: Axis.horizontal,
                                                itemCount: gender.length,
                                                itemBuilder: (context, index) {
                                                  return Row(
                                                    children: [
                                                      GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              selectedIndex = index;
                                                              selectedGender = gender[index];
                                                            });
                                                          },
                                                          child: selectedIndex == index
                                                              ? selectedButton(gender[index], size)
                                                              : unselectedButton(gender[index], size)),
                                                      SizedBox(width: size.width * 0.02)
                                                    ],
                                                  );
                                                })
                                          ],
                                        )),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Divider(thickness: 0.5, color: color.lightestBlue),
                              const SizedBox(height: 4),
                              Padding(padding: const EdgeInsets.only(left: 15, right: 15, bottom: 0, top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildText("Verified users only", 18, FontWeight.w600, color.txtBlack),
                                    GestureDetector(
                                        onTap: () {setState(() {isChecked = !isChecked;});},
                                        child: SvgPicture.asset(isChecked == true ? AssetsPics.checkbox : AssetsPics.blankCheckbox)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Divider(thickness: 0.5, color: color.lightestBlue),
                              const SizedBox(height: 11),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 15, right: 15, bottom: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        LocaleHandler.selectedIndexGender = -1;
                                        LocaleHandler.startage = 18;
                                        LocaleHandler.endage = 90;
                                        LocaleHandler.distancevalue = 250;
                                        LocaleHandler.isChecked = false;
                                        Get.back();
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 56,
                                        width: MediaQuery.of(context).size.width / 2 - 40,
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            color: color.txtWhite,
                                            border: Border.all(
                                                width: 1.5,
                                                color: color.txtBlue)),
                                        child: buildText("Clear all", 18, FontWeight.w600, color.txtBlue),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        int min = _startValue.toInt();
                                        int max = _endValue.toInt();
                                        setState(() {
                                          LocaleHandler.selectedIndexGender = selectedIndex;
                                          LocaleHandler.startage = min;
                                          LocaleHandler.endage = max;
                                          LocaleHandler.distancevalue = distancevalue;
                                          LocaleHandler.isChecked = isChecked;
                                          LocaleHandler.pageIndex = 0;
                                        });
                                        Provider.of<reelController>(context, listen: false).videoPause(true, LocaleHandler.pageIndex);
                                        Provider.of<reelController>(context, listen: false).getVidero(context, 1, min, max, distancevalue, LocaleHandler.latitude,
                                                LocaleHandler.longitude, selectedGender == "Everyone" ? "" : selectedGender.toLowerCase());
                                        Get.back();
                                      },
                                      // onTap: onTap2,
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 56,
                                        width: MediaQuery.of(context).size.width / 2 - 40,
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            gradient: const LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [
                                                color.gradientLightBlue,
                                                color.txtBlue
                                              ],
                                            )),
                                        child: buildText("Apply", 18, FontWeight.w600, color.txtWhite),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                          )),
                      Positioned(
                        right: 0.15,
                        top: 0.15,
                        child: GestureDetector(
                          onTap: () {
                            Get.back();
                          },
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
          });
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(anim1),
            child: child,
          );
        });
  }

  customSparkBottomSheet(BuildContext context,String img ,String title, String btnTxt1, String btnTxt2, bool isSparkLeft,{
    VoidCallback? onTapp = pressed,
    VoidCallback? onTap1=pressed,
    VoidCallback? onTap2=pressed,
    bool? forAdvanceTap,
    int sparks=0}) {
    return showGeneralDialog(
        barrierLabel: "Label",
        transitionDuration: const Duration(milliseconds: 500),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return GestureDetector(
            onTap: onTapp,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    width: MediaQuery.of(context).size.width / 1.1,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: color.txtWhite,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Image.asset(img,fit: BoxFit.cover,),
                        SizedBox(height:isSparkLeft? 10:0),
                        isSparkLeft? Container(
                          height: 32,
                          width: 140,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: color.example4
                          ),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(AssetsPics.star,height: 20),
                              const SizedBox(width: 5),
                              buildText("$sparks Sparks left",14,FontWeight.w600,color.txtBlack),
                            ],),):const SizedBox(),
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.only(left: 8,right: 8),
                          child: buildText2(title, 20, FontWeight.w600, color.txtBlack),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: onTap1,
                              child: Container(
                                alignment: Alignment.center,
                                height: 56,
                                width: MediaQuery.of(context).size.width/2-45,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                                    color: color.txtWhite,
                                    border: Border.all(width: 1.5,color: color.txtBlue)
                                ),
                                child: buildText(btnTxt1,18,FontWeight.w600,color.txtBlue),
                              ),
                            ),
                            GestureDetector(
                              onTap: onTap2,
                              child: Container(
                                alignment: Alignment.center,
                                height: 56,
                                width: MediaQuery.of(context).size.width/2-45,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                                    gradient:  const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
                                      colors:[color.gradientLightBlue, color.txtBlue],)
                                ),
                                child: buildText(btnTxt2,18,FontWeight.w600,color.txtWhite),
                              ),
                            ),
                          ],),
                        const SizedBox(height: 8),
                      ],
                    )),
              ),
            ),
          );
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
                .animate(anim1),
            child: child,
          );
        });
  }
}
