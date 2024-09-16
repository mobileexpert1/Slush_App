import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/loader.dart';
import 'package:slush/screens/matches/matched_person_profile.dart';
import 'package:slush/screens/matches/unMacthed_person_profile.dart';
import 'package:slush/screens/subscritption/subscription_screen1%203.dart';
import 'package:slush/screens/video_call/congo_match_screen.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:http/http.dart' as http;
import 'package:slush/widgets/toaster.dart';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';

import '../events/bottomNavigation.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({Key? key}) : super(key: key);
  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  bool isLiked = false;
  bool upgraded = false;
  int selectedButton = 0;
  ScrollController? _controller;
  List unLiked = [];
  List liked = [];
  final shakeKey = GlobalKey<ShakeWidgetState>();

  @override
  void initState() {
    isLiked=LocaleHandler.liked;
    getListData();
    _controller = ScrollController()..addListener(loadmore);
    // Future.delayed(const Duration(seconds: 10),(){
    // setState(() {LocaleHandler.noMatches=false;
    // LocaleHandler.nolikes=false; }); // });
    super.initState();
  }

  var data;
  int totalpages = 0;
  int currentpage = 0;
  List post = [];
  int _page = 1;
  bool _isLoadMoreRunning = false;
  bool _hasNextPage = true;

  Future getListData() async {
    post.clear();
    data = null;
    // setState(() {LoaderOverlay.show(context);});
    final url = isLiked
        ? "${ApiList.result}page=1&limit=10&type=liked"
        : "${ApiList.result}page=1&limit=10";
    print(url);
    var uri = Uri.parse(url);
    var response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${LocaleHandler.accessToken}'
    });
    var i = jsonDecode(response.body)["data"];
    if (response.statusCode == 200) {
      setState(() {
        data = i;
        totalpages = data["meta"]["totalPages"];
        currentpage = data["meta"]["currentPage"];
        post = data["items"];
      });
    } else if (response.statusCode == 401) {
      showToastMsgTokenExpired();
    } else {
      if (LocaleHandler.subscriptionPurchase == "yes") {
        Fluttertoast.showToast(msg: 'Something Went Wrong');
      }
      setState(() {
        data = i;
      });
    }
  }

  Future loadmore() async {
    if (_page < totalpages && _hasNextPage == true && _isLoadMoreRunning == false && currentpage < totalpages && _controller!.position.extentAfter < 300) {
      setState(() {_isLoadMoreRunning = true;});
      _page = _page + 1;
      final url = isLiked
          ? "${ApiList.result}page=$_page&limit=10&type=liked"
          : "${ApiList.result}page=$_page&limit=10";
      print(url);
      var uri = Uri.parse(url);
      var response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${LocaleHandler.accessToken}'
      });
      setState(() {_isLoadMoreRunning = false;});
      if (response.statusCode == 200) {
        setState(() {
          var data = jsonDecode(response.body)['data'];
          currentpage = data["meta"]["currentPage"];
          final List fetchedPosts = data["items"];
          if (fetchedPosts.isNotEmpty) {
            setState(() {post.addAll(fetchedPosts);});
          }
        });
      }
    }
  }

  Future actionForHItLike(String action, String id) async {
    final url = "${ApiList.action}$id/action";
    print(url);
    var uri = Uri.parse(url);
    var response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${LocaleHandler.accessToken}"
        },
        body: jsonEncode({"action": action}));
    print(response.statusCode);
    var data=jsonDecode(response.body);
    if (response.statusCode == 201) {
      getListData();
      // if(data["isMatch"]&&action!="DISLIKED"){
      //   Get.to(()=> const CongratMatchScreen(likedscreen: true));
      // }
    } else if (response.statusCode == 401) {
      showToastMsgTokenExpired();
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 160) / 2;
    final double itemWidth = size.width / 2;
    return RefreshIndicator(
      displacement: 100,
      backgroundColor: color.txtWhite,
      color: color.txtBlue,
      strokeWidth: 3,
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 4));
          getListData();
        },
    child: Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: size.height,
            width: size.width,
            child: Image.asset(AssetsPics.background, fit: BoxFit.cover),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _controller,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 22),
                    buildText(isLiked ? "Likes" : "Matches", 24, FontWeight.w600, color.txtBlack),
                    const SizedBox(height: 12),
                    buildText(
                        "This is a list of people who have liked you and your matches.",
                        16,
                        FontWeight.w500,
                        color.txtgrey,
                        fontFamily: FontFamily.hellix),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        isLiked ? white_button_half(context, "Matches", press: () {
                          setState(() {
                            isLiked = false;
                            getListData();
                          });
                        })
                            : blue_button_half(context, "Matches"),
                        isLiked ? blue_button_half(context, "Liked You")
                            : white_button_half(context, "Liked You",
                            press: () {
                              setState(() {isLiked = true;
                              getListData();});
                            }),
                      ]),
                    const SizedBox(height: 1),
                    // LocaleHandler.noMatches?Stack(
                    data == null ? buildStacknodata() : data["meta"]["totalItems"] == 0
                        ? buildStacknodata() : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 18.0,
                          mainAxisSpacing: 18.0,
                          childAspectRatio: (itemWidth / itemHeight),
                        ),
                        padding: const EdgeInsets.only(top: 10),
                        itemCount: post.length,
                        itemBuilder: (context, index) {
                          var item = post;
                          return isLiked
                              ? Visibility(
                              visible: unLiked.contains(item[index]["userId"]) ? false
                                  : liked.contains(item[index]["userId"]) ? false : true,
                              child: buildlikedStack(item, index)) : buildStack(item, index);
                        }),
                    const SizedBox(height: 60),
                    _isLoadMoreRunning
                        ? const Center(
                        child: CircularProgressIndicator(color: color.txtBlue))
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
          ),
          isLiked
              ? Positioned(
            bottom: 90.0,
            child: LocaleHandler.subscriptionPurchase == "yes" ? const SizedBox() :
            ShakeMe(
              // 4. pass the GlobalKey as an argument
              key: shakeKey,
              // 5. configure the animation parameters
              shakeCount: 3,
              shakeOffset: 10,
              shakeDuration: const Duration(milliseconds: 500),
              // 6. Add the child widget that will be animated
              child: GestureDetector(
                onTap: (){Get.to(()=>const Subscription1());},
                child: Container(
                  padding: const EdgeInsets.only(left: 15, right: 20),
                  margin: EdgeInsets.only(left: 15, bottom: Platform.isIOS ? 30 : 0),
                  height: 8.h, width: size.width - 35,
                  decoration: BoxDecoration(color: color.purpleColor, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Expanded(child: buildText("Update to Slush Silver to see who has liked you!", 18, FontWeight.w500, color.txtWhite)),
                      const SizedBox(width: 10),
                      SizedBox(height: 3.h, width: 3.h, child: SvgPicture.asset(AssetsPics.crownOn))
                    ],
                  ),
                ),
              ),
            ),
          ) : const SizedBox()
        ],
      ),
    ),);
  }

  Stack buildStacknodata() {
    return Stack(alignment: Alignment.center, children: [
      Positioned(
        top: 100.0,
        child: Container(
            height: 22.h,
            width: 23.h,
            alignment: Alignment.center,
            child: SvgPicture.asset(
              AssetsPics.bigheart,
              fit: BoxFit.cover,
            )),
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 13.h),
          Stack(
            children: [
              Positioned(
                left: 130,
                child: Container(
                  alignment: Alignment.center,
                  child: SvgPicture.asset(AssetsPics.threeDotsLeft),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: isLiked
                    ? Image.asset(AssetsPics.matchespng1, height: 80)
                    : Image.asset(AssetsPics.likedYoupng1, height: 80),
                // child: Image.asset(AssetsPics.likedYoupng1,height: 80),
              ),
            ],
          ),
          SizedBox(height: 7.h),
          buildText("No-one showing?", 30, FontWeight.w600, color.txtBlue),
          SizedBox(height: 2.h),
          buildText2(
              "Attend more events or find more\nmatches on the slush feed to increase\nyour chances of matching.",
              18,
              FontWeight.w500,
              color.txtgrey,
              fontFamily: FontFamily.hellix),
        ],
      ),
    ]);
  }

  Widget buildStack(item, int index) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Get.to(() => MatchedPersonProfileScreen(
                id: item[index]["userId"].toString()));
          },
          child: Container(
            decoration: BoxDecoration(
                border:item[index]["isSparkLike"]? Border.all(width: 1, color: color.darkPink):Border.all(width: 0,color: Colors.transparent),
                borderRadius: BorderRadius.circular(16)),
            height: 35.h,
            width: 21.h,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              // child: Image.asset(AssetsPics.photo, fit: BoxFit.cover),
              child:item[index]["profilePictures"].isEmpty?Image.asset(AssetsPics.demouser): CachedNetworkImage(
                imageUrl: item[index]["profilePictures"][0]["key"],
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const Icon(Icons.error),
                placeholder: (ctx, url) => const Center(child: CircularProgressIndicator(color: color.txtBlue)),
              ),
            ),
          ),
        ),
        IgnorePointer(
          child: Column(
            children: [
              const Spacer(),
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(16)),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                    child: Container(
                      height: 31.h / 3 - 5,
                      width: 21.h,
                      alignment: Alignment.bottomCenter,
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 28.0,
          left: 10.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 150,
                child: Row(
                  children: [
                    Flexible(child: buildTextOverFlow(item[index]['firstName']==null?"":"${item[index]['firstName']??""}", 15, FontWeight.w600, color.txtWhite)),
                    buildTextOverFlow(", ${item[index]['dateOfBirth']==null?"":calculateAge(item[index]['dateOfBirth']??"")}", 15, FontWeight.w600, color.txtWhite),
                    const SizedBox(width:5),
                    SvgPicture.asset(item[index]["isVerified"] == null ?
                    AssetsPics.verifygrey : item[index]["isVerified"] ? AssetsPics.verify:AssetsPics.verifygrey),
                  ],
                ),
              ),
              SizedBox(
                width: 150,
                child: buildTextOverFlow(item[index]['jobTitle']==null?"":"${item[index]['jobTitle']??""}", 13.5, FontWeight.w500, color.txtWhite),
              ),
            ],
          ),
        ),
        item[index]["isSparkLike"]? Positioned(  left: 10.0, top: 10.0, child: SvgPicture.asset(AssetsPics.star)):const SizedBox()
      ],
    );
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

  Widget buildlikedStack(item, int index) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if(LocaleHandler.subscriptionPurchase == "yes"){
              LocaleHandler.eventParticipantData=item[index];
            Get.to(() => UnMatchedPersonProfileScreen(id: item[index]["userId"].toString()))!.then((value) async {
              if (value == true) {setState(() {liked.add(item[index]["userId"]);});
              getListData();
              }});}
            else{
              shakeKey.currentState?.shake();
              // LocaleHandler.eventParticipantData=item[index];
              // Get.to(()=> const CongratMatchScreen(likedscreen: true));
            }
          },
          child: Container(
            decoration: BoxDecoration(
                border:item[index]["isSparkLike"]? Border.all(width: 1, color: color.darkPink):Border.all(width: 0,color: Colors.transparent),
                borderRadius: BorderRadius.circular(16)),
            height: 35.h,
            width: 21.h,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              // child: Image.asset(AssetsPics.photo, fit: BoxFit.cover),
              child:item[index]["profilePictures"].isEmpty?Image.asset(AssetsPics.demouser): CachedNetworkImage(
                imageUrl: item[index]["profilePictures"][0]["key"],
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const Icon(Icons.error),
                placeholder: (ctx, url) => const Center(
                    child: CircularProgressIndicator(
                  color: color.txtBlue,
                )),
              ),
            ),
          ),
        ),
        LocaleHandler.subscriptionPurchase == "yes"
            ? IgnorePointer(child: Column(
                children: [
                  const Spacer(),
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                        child: Container(
                          height: 31.h / 3 - 5,
                          width: 21.h,
                          alignment: Alignment.bottomCenter,
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ),
                ],
              ))
            : IgnorePointer(child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ClipRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                        child: Container(width: 21.h, alignment: Alignment.bottomCenter, color: Colors.black.withOpacity(0.1)))),
              )),
        LocaleHandler.subscriptionPurchase == "yes"
            ? Positioned(
                bottom: 28.0,
                left: 10.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      child: Row(
                        children: [
                          Flexible(child: buildTextOverFlow(item[index]['firstName']==null?"":"${item[index]['firstName']??""}", 15, FontWeight.w600, color.txtWhite)),
                          buildTextOverFlow(", ${item[index]['dateOfBirth']==null?"":calculateAge(item[index]['dateOfBirth']??"")}", 15, FontWeight.w600, color.txtWhite),
                          const SizedBox(width:5),
                          SvgPicture.asset(item[index]["isVerified"] == null ?
                          AssetsPics.verifygrey : item[index]["isVerified"] ? AssetsPics.verify:AssetsPics.verifygrey),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: buildTextOverFlow(item[index]['jobTitle']==null?"":"${item[index]['jobTitle']??""}", 13.5, FontWeight.w500, color.txtWhite),
                    ),
                  ],
                ),
              )
            : const SizedBox(),
        Container(
          margin: const EdgeInsets.only(bottom: 4),
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                  onTap: () {
                   if(LocaleHandler.subscriptionPurchase == "yes"){
                    setState(() {unLiked.remove(item[index]["userId"]);});
                    actionForHItLike("DISLIKED", item[index]["userId"].toString());}
                   else{//showToastMsg("Please Update to Slush Silver");
                   shakeKey.currentState?.shake();
                   }
                  },
                  child: const Icon(Icons.clear, color: Colors.white)),
              Container(
                width: 2,
                height: 18,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
              ),
              GestureDetector(
                  onTap: () {
                   if(LocaleHandler.subscriptionPurchase == "yes"){
                    setState((){liked.add(item[index]["userId"]);});
                    LocaleHandler.eventParticipantData=item[index];
                    Get.to(()=> const CongratMatchScreen(likedscreen: true));
                    actionForHItLike("LIKED", item[index]["userId"].toString());
                    // LoaderOverlay.show(context);
                    // LocaleHandler.liked=false;
                    // isLiked=false;
                    // LoaderOverlay.hide();
                    setState(() {getListData();});
                   }

                   else{shakeKey.currentState?.shake();
                     // showToastMsg("Please Update to Slush Silver");
                   }
                  },
                  child: SvgPicture.asset(AssetsPics.heartblnkbg))
            ],
          ),
        ),
        item[index]["isSparkLike"]? Positioned( left: 10.0, top: 10.0, child: SvgPicture.asset(AssetsPics.star)):const SizedBox()
      ],
    );
  }
}
