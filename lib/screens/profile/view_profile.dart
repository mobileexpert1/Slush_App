import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/controller/edit_profile_controller.dart';
import 'package:slush/controller/profile_controller.dart';
import 'package:slush/screens/profile/basic_info/profile_video_view.dart';
import 'package:slush/screens/profile/edit_profile.dart';
import 'package:slush/screens/profile/profile_video_screen.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:video_player/video_player.dart';

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({Key? key}) : super(key: key);

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

/*class _ViewProfileScreenState extends State<ViewProfileScreen> {
  PageController controller = PageController();

  // int numberOfPages = 3;
  // int currentPage = 0;
  // int indicatorIndex = 0;
  ValueNotifier<int> indicatorIndex=ValueNotifier<int>(0);

  // bool isScrolled = false;
  // var hi = 0.0;
  String jobTitle = LocaleHandler.dataa["jobTitle"] ?? "";
  CachedVideoPlayerPlusController? _controller;
  CachedVideoPlayerPlusController? _controller2;
  CachedVideoPlayerPlusController? _controller3;

  // late VideoPlayerController _controller;
  // late VideoPlayerController _controller2;
  // late VideoPlayerController _controller3;
  // Future<void>? _initializeVideoPlayerFuture;
  // Future<void>? _initializeVideoPlayerFuture2;
  // Future<void>? _initializeVideoPlayerFuture3;

  cacheVideoPlay1(url) {
    _controller = CachedVideoPlayerPlusController.networkUrl(
      Uri.parse(url),
      httpHeaders: {
        'Connection': 'keep-alive',
      },
      invalidateCacheIfOlderThan: const Duration(seconds: 100),
    )..initialize().then((value) async {
        await _controller!.setLooping(true);
        _controller!.play();
        _controller!.setVolume(0.0);
        setState(() {});
      });
  }

  cacheVideoPlay2(url) {
    _controller2 = CachedVideoPlayerPlusController.networkUrl(
      Uri.parse(
        url,
      ),
      httpHeaders: {
        'Connection': 'keep-alive',
      },
      // invalidateCacheIfOlderThan: const Duration(seconds: 100),
    )..initialize().then((value) async {
        await _controller2!.setLooping(true);
        _controller2!.play();
        _controller2!.setVolume(0.0);
        setState(() {});
      });
  }

  cacheVideoPlay3(url) {
    _controller3 = CachedVideoPlayerPlusController.networkUrl(
      Uri.parse(
        url,
      ),
      httpHeaders: {
        'Connection': 'keep-alive',
      },
      // invalidateCacheIfOlderThan: const Duration(seconds: 100),
    )..initialize().then((value) async {
        await _controller3!.setLooping(true);
        _controller3!.play();
        _controller3!.setVolume(0.0);
        setState(() {});
      });
  }

  @override
  void initState() {
    addImgVid();
    if (LocaleHandler.dataa["profileVideos"].length != 0) {
      cacheVideoPlay1(LocaleHandler.dataa["profileVideos"][0]["key"]);
      // _controller  = VideoPlayerController.networkUrl(Uri.parse(LocaleHandler.dataa["profileVideos"][0]["key"]));
      // _initializeVideoPlayerFuture = _controller.initialize();
    }
    if (LocaleHandler.dataa["profileVideos"].length >= 2) {
      cacheVideoPlay2(LocaleHandler.dataa["profileVideos"][1]["key"]);
      // _controller2 = VideoPlayerController.networkUrl(Uri.parse(LocaleHandler.dataa["profileVideos"][1]["key"]));
      // _initializeVideoPlayerFuture2 = _controller2.initialize();
    }
    if (LocaleHandler.dataa["profileVideos"].length >= 3) {
      cacheVideoPlay3(LocaleHandler.dataa["profileVideos"][2]["key"]);
      // _controller3 = VideoPlayerController.networkUrl(Uri.parse(LocaleHandler.dataa["profileVideos"][2]["key"]));
      // _initializeVideoPlayerFuture3 = _controller3.initialize();
    }
    showOnProfile();
    // getINterest();
    super.initState();
  }

  @override
  void dispose() {
    // _controller.dispose();
    // _controller2.dispose();
    // _controller3.dispose();
    super.dispose();
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

  List splitted = [];

  void showOnProfile() {
    if (LocaleHandler.dataa["showOnProfile"] == null) return;
    String text =
        LocaleHandler.dataa["showOnProfile"].toString().replaceAll(" ", "");
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

  List<Map<String, dynamic>> imgvideitems = [];

  void addImgVid() {
    for (var i = 0; i < LocaleHandler.dataa["profilePictures"].length; i++) {
      var ii = {
        "key": "photo",
        "url": LocaleHandler.dataa["profilePictures"][i]["key"]
      };
      imgvideitems.add(ii);
    }
    for (var i = 0; i < LocaleHandler.dataa["profileVideos"].length; i++) {
      var ii = {
        "key": "video",
        "url": LocaleHandler.dataa["profileVideos"][i]["key"]
      };
      imgvideitems.add(ii);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.0),
              child: Container(
                height: 4.h,
                width: size.width,
                decoration: const BoxDecoration(
                    color: color.txtWhite,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    )),
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                        padding: const EdgeInsets.all(9),
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20)),
                        child: SvgPicture.asset(AssetsPics.arrowLeft))),
                GestureDetector(
                  onTap: () {
                    LocaleHandler.entencityname.clear();
                    Provider.of<editProfileController>(context, listen: false).saveValue(
                            LocaleHandler.dataa["gender"],
                            LocaleHandler.dataa["height"],
                            LocaleHandler.dataa["jobTitle"] ?? "",
                            LocaleHandler.education,
                            LocaleHandler.dataa["sexuality"] ?? "",
                            LocaleHandler.dataa["ideal_vacation"] ?? "",
                            LocaleHandler.dataa["cooking_skill"] ?? "",
                            LocaleHandler.dataa["smoking_opinion"] ?? "",
                        LocaleHandler.dataa["ethnicity"],
                    );
                    Get.to(() => const EditProfileScreen())!.then((value) {setState(() {});});
                  },
                  child: Container(
                      height: 36,
                      alignment: Alignment.center,
                      child: SvgPicture.asset(AssetsPics.editProfileBlack)),
                ),
              ],
            ),
            expandedHeight: 43.3.h,
            flexibleSpace: FlexibleSpaceBar(
              background: SizedBox(
                  height: size.height / 2,
                  width: size.width,
                  child: Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.center,
                    children: [
                      PageView.builder(
                        controller: controller,
                        itemCount: imgvideitems.length,
                        onPageChanged: (indexx) {
                          indicatorIndex.value = indexx;
                        },
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {},
                            child: imgvideitems[index]["key"] == "photo"
                                ? CachedNetworkImage(
                                    imageUrl: imgvideitems.length == 0
                                        ? ""
                                        : imgvideitems[index]["url"],
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                    placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator(
                                            color: color.txtBlue)),
                                  )
                                : VideoScreen(url: imgvideitems[index]["url"]),
                          );
                          // child: Image.network(LocaleHandler.dataa["profilePictures"][index]["key"],fit: BoxFit.cover,));
                          // Provider.of<profileController>(context,listen: false).videoUrl = imgvideitems[index]["url"];
                        },
                      ),
                      IgnorePointer(
                          child: SvgPicture.asset(AssetsPics.eventbg,
                              fit: BoxFit.cover)),
                      Positioned(
                        bottom: 40.0,
                        child: ValueListenableBuilder(valueListenable: indicatorIndex,
                        builder: (context,value,child){
                          return IgnorePointer(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List<Widget>.generate(imgvideitems.length, (int index) {
                                    return Container(
                                      margin: const EdgeInsets.only(
                                          left: 2.5, right: 2.5, bottom: 12.0),
                                      width: indicatorIndex.value == index ? 15 : 12.0,
                                      height: indicatorIndex.value == index ? 15 : 12.0,
                                      decoration: BoxDecoration(
                                        color: indicatorIndex.value == index ? color.txtWhite : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: indicatorIndex.value == index ? Colors.blue : Colors.white,
                                          width: indicatorIndex.value == index ? 3 : 1.5,
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          );
                        }
                        ),
                      ),
                    ],
                  )),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                String gender = LocaleHandler.dataa["gender"];
                // double distance=calculateDistance(30.6990782, 76.691354);
                // var dis =distance(30.6990482, 76.691154);
                // var dis2 = dis.toStringAsFixed(2).substring(0, 2);
                return Container(
                  width: size.width,
                  decoration: const BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(40)),
                      color: Colors.white),
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          FittedBox(
                              child: buildTextOverFlow(
                                  LocaleHandler.dataa['firstName'] == null ? ""
                                      : "${LocaleHandler.dataa["firstName"] ?? ''}",
                                  24,
                                  FontWeight.w600,
                                  color.txtBlack)),
                          buildTextOverFlow(", ${LocaleHandler.dataa['dateOfBirth'] == null ? "" : calculateAge(LocaleHandler.dataa['dateOfBirth'] ?? '')}",
                              24,
                              FontWeight.w600,
                              color.txtBlack),
                          // const SizedBox(width: 70)
                          // SvgPicture.asset(AssetsPics.verifywithborder),
                        ],
                      ),
                      jobTitle == "" ? const SizedBox()
                          : buildText("$jobTitle", 15, FontWeight.w500, color.txtgrey,
                              fontFamily: FontFamily.hellix),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          splitted.contains("gender")
                              ? Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  child: SvgPicture.asset(
                                      gender == "male"
                                          ? AssetsPics.greyman
                                          : gender == "female"
                                              ? AssetsPics.greyfemale
                                              : AssetsPics.transGenderBlack,
                                      height: 15))
                              : const SizedBox(),
                          splitted.contains("gender")
                              ? buildText(gender == "male" ? "Male" : gender == "female" ? "Female" : "Other",
                                  15,
                                  FontWeight.w500,
                                  color.txtgrey,
                                  fontFamily: FontFamily.hellix)
                              : const SizedBox(),
                          splitted.contains("gender")
                              ? Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 5),
                                  child: SvgPicture.asset(
                                      AssetsPics.greydivider,
                                      height: 15))
                              : const SizedBox(),
                          splitted.contains("height")
                              ? Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  child: SvgPicture.asset(
                                    AssetsPics.greyhieght,
                                    height: 15,
                                  ))
                              : const SizedBox(),
                          splitted.contains("height")
                              ? buildText(LocaleHandler.dataa["height"] + "cm",
                                  15, FontWeight.w500, color.txtgrey,
                                  fontFamily: FontFamily.hellix)
                              : const SizedBox(),
                          splitted.contains("height")
                              ? Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 5),
                                  child: SvgPicture.asset(
                                      AssetsPics.greydivider,
                                      height: 15))
                              : const SizedBox(),
                          splitted.contains("sexuality")
                              ? buildText(LocaleHandler.dataa["sexuality"], 15,
                                  FontWeight.w500, color.txtgrey,
                                  fontFamily: FontFamily.hellix)
                              : const SizedBox(),
                          splitted.contains("sexuality")
                              ? Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 5),
                                  child: SvgPicture.asset(
                                      AssetsPics.greydivider,
                                      height: 15))
                              : const SizedBox(),
                          for (var ii = 0; ii < LocaleHandler.dataa["ethnicity"].length; ii++)
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                buildText(
                                    LocaleHandler.dataa["ethnicity"][ii]["name"],
                                    15,
                                    FontWeight.w500,
                                    color.txtgrey,
                                    fontFamily: FontFamily.hellix),
                                ii == LocaleHandler.dataa["ethnicity"].length - 1
                                    ? const SizedBox()
                                    : Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 5),
                                        child: SvgPicture.asset(
                                            AssetsPics.greydivider,
                                            height: 15)),
                              ],
                            )
                        ],
                      ),
                      SizedBox(
                          height: splitted.contains("lookingFor") ? 2.h : 0),
                      splitted.contains("lookingFor")
                          ? buildText("Relationship basics", 20, FontWeight.w600, color.txtBlack)
                          : const SizedBox(),
                      splitted.contains("lookingFor")
                          ? Row(
                              children: [
                                Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 5),
                                    child: SvgPicture.asset(
                                        AssetsPics.greyoutlineheart,
                                        height: 14)),
                                buildText(
                                    LocaleHandler.dataa["lookingFor"] ?? '',
                                    15,
                                    FontWeight.w500,
                                    color.txtgrey,
                                    fontFamily: FontFamily.hellix),
                              ],
                            )
                          : const SizedBox(),
                      SizedBox(height: 2.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildText("Location", 20, FontWeight.w600, color.txtBlack),
                        ],
                      ),
                      buildText(LocaleHandler.dataa["state"] + ", " + LocaleHandler.dataa["country"],
                          15,
                          FontWeight.w500,
                          color.txtgrey,
                          fontFamily: FontFamily.hellix),
                      Container(
                          height: LocaleHandler.dataa["bio"] == null ? 0 : 2.h),
                      buildText(
                          LocaleHandler.dataa["bio"] == null ? "" : "About",
                          20,
                          FontWeight.w600,
                          color.txtBlack),
                      LocaleHandler.dataa["bio"] == null
                          ? const SizedBox()
                          : ExpandableText(
                              // LocaleText.personDescription,
                              ' ${LocaleHandler.dataa["bio"] ?? ''}',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: FontFamily.hellix,
                                  fontWeight: FontWeight.w500,
                                  color: color.txtBlack),
                              expandText: '\nRead more',
                              collapseText: 'Read less',
                              maxLines: 3,
                              animation: true,
                              animationDuration: const Duration(seconds: 1),
                              linkColor: Colors.blue,
                              linkStyle: const TextStyle(
                                  color: color.txtBlue,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: FontFamily.hellix,
                                  fontSize: 15),
                              linkEllipsis: false,
                            ),
                      SizedBox(
                          height: LocaleHandler.dataa["bio"] == null ? 0 : 2.h),
                      LocaleHandler.dataa["ideal_vacation"] != null ||
                              LocaleHandler.dataa["cooking_skill"] != null ||
                              LocaleHandler.dataa["smoking_opinion"] != null
                          ? buildText("More about me", 20, FontWeight.w600,
                              color.txtBlack)
                          : const SizedBox(),
                      LocaleHandler.dataa["ideal_vacation"] != null ||
                              LocaleHandler.dataa["cooking_skill"] != null ||
                              LocaleHandler.dataa["smoking_opinion"] != null
                          ? Wrap(
                              children: [
                                LocaleHandler.dataa["ideal_vacation"] == null
                                    ? const SizedBox()
                                    : Container(
                                        margin: const EdgeInsets.only(
                                            top: 10, right: 9),
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
                                                child: SvgPicture.asset(AssetsPics.greyideal)),
                                            buildText(LocaleHandler.dataa["ideal_vacation"],
                                                16,
                                                FontWeight.w600,
                                                color.txtBlack),
                                          ],
                                        ),
                                      ),
                                LocaleHandler.dataa["cooking_skill"] == null
                                    ? const SizedBox()
                                    : Container(
                                        margin: const EdgeInsets.only(
                                            top: 10, right: 9),
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
                                                child: SvgPicture.asset(AssetsPics.greyshefhat)),
                                            buildText(
                                                LocaleHandler.dataa["cooking_skill"],
                                                16,
                                                FontWeight.w600,
                                                color.txtBlack),
                                          ],
                                        ),
                                      ),
                                LocaleHandler.dataa["smoking_opinion"] == null
                                    ? const SizedBox()
                                    : Container(
                                        margin: const EdgeInsets.only(top: 10, right: 9),
                                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
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
                                                child: SvgPicture.asset(AssetsPics.greysmoking)),
                                            buildText(LocaleHandler.dataa["smoking_opinion"],
                                                16,
                                                FontWeight.w600,
                                                color.txtBlack),
                                          ],
                                        ),
                                      ),
                              ],
                            )
                          : const SizedBox(),
                      SizedBox(
                          height: LocaleHandler.dataa["interests"].length == 0 ? 0 : 2.h),
                      LocaleHandler.dataa["interests"].length == 0
                          ? const SizedBox()
                          : buildText("Interests", 20, FontWeight.w600, color.txtBlack),
                      LocaleHandler.dataa["interests"].length == 0
                          ? const SizedBox()
                          : Wrap(
                              children: [
                                // for(var i=0;i<data.length;i++)
                                for (var i = 0; i < LocaleHandler.dataa["interests"].length; i++)
                                  Container(
                                    margin: const EdgeInsets.only(top: 10, right: 10),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(19),
                                        border: Border.all(
                                            width: 1,
                                            color: color.lightestBlue)),
                                    // child: buildText(data[i]["name"], 16, FontWeight.w600, color.txtBlack),
                                    child: buildText(LocaleHandler.dataa["interests"][i]["name"],
                                        16,
                                        FontWeight.w600,
                                        color.txtBlack),
                                  )
                              ],
                            ),
                      SizedBox(
                          height: LocaleHandler.dataa["interests"].length == 0
                              ? 0
                              : 2.h),
                      buildText("Gallery", 20, FontWeight.w600, color.txtBlack),
                      SizedBox(height: 1.h),
                      SizedBox(
                        // color: Colors.red,
                        height: size.height * 0.3,
                        width: size.width,
                        child: Row(
                          children: [
                            Expanded(
                                child: LocaleHandler.dataa["profilePictures"].length == 0
                                    ? SizedBox(
                                        height: size.height * 0.3,
                                        child: buildContainer())
                                    : SizedBox(
                                        height: size.height * 0.3,
                                        child: buildPhotoContainer(LocaleHandler.dataa["profilePictures"][0]["key"], 0))),
                            const SizedBox(width: 10),
                            Column(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                      width: size.width / 2 - 80,
                                      child: LocaleHandler.dataa["profilePictures"].length >= 2
                                          ? buildPhotoContainer(LocaleHandler.dataa["profilePictures"][1]["key"], 1)
                                          : buildContainer()),
                                ),
                                SizedBox(height: 1.h),
                                Expanded(
                                  child: SizedBox(
                                    width: size.width / 2 - 80,
                                    child: LocaleHandler.dataa["profilePictures"].length >= 3
                                        ? buildPhotoContainer(
                                            LocaleHandler.dataa["profilePictures"][2]["key"], 2)
                                        : buildContainer(),
                                  ),
                                ),
                              ],
                            ),
                            // const SizedBox(width: 10),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      buildText("Video", 20, FontWeight.w600, color.txtBlack),
                      SizedBox(height: 1.h),
                      SizedBox(
                        height: size.height * 0.3,
                        width: size.width,
                        child: Row(
                          children: [
                            Expanded(
                                child: LocaleHandler.dataa["profileVideos"].length != 0
                                    ? SizedBox(
                                        height: size.height * 0.3,
                                        child: buildVideoContainer(_controller!))
                                    : SizedBox(
                                        height: size.height * 0.3,
                                        child: buildContainer())),
                            const SizedBox(width: 10),
                            Column(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    width: size.width / 2 - 80,
                                    child: LocaleHandler.dataa["profileVideos"].length >= 2
                                        ? buildVideoContainer(_controller2!)
                                        : buildContainer(),
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Expanded(
                                  child: SizedBox(
                                    width: size.width / 2 - 80,
                                    child: LocaleHandler.dataa["profileVideos"].length >= 3
                                        ? buildVideoContainer(_controller3!)
                                        : buildContainer(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5.h),
                    ],
                  ),
                );
              },
              childCount: 1, // SliverList displaying 20 items, each on a ListTile
            ),
          ),
        ],
      ),
    );
  }

  Container buildContainer() => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color.txtgrey4,
        ),
      );

  Widget buildPhotoContainer(String img, int i) {
    return GestureDetector(
      onTap: () {
        customSlidingImage(context, i, LocaleHandler.dataa["profilePictures"]);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: img,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => buildContainer(),
          placeholder: (ctx, url) => const Center(child: CircularProgressIndicator(color: color.txtBlue)),
        ),
        // Image.network(LocaleHandler.dataa["avatar"],fit: BoxFit.cover,)
      ),
    );
  }

  Widget buildVideoContainer(CachedVideoPlayerPlusController cntrl) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            AspectRatio(
              aspectRatio: cntrl.value.aspectRatio,
              child: CachedVideoPlayerPlus(cntrl),
            ),
            GestureDetector(
                onTap: () {
                  Provider.of<profileController>(context, listen: false).videoUrl = cntrl.dataSource;
                  Get.to(() => ProfileVideoViewer());
                },
                child: Container(
                    alignment: Alignment.center,
                    child: SvgPicture.asset(AssetsPics.videoplayicon)))
          ],
        ));
  }

  Widget buildColumn(String img, double hii) {
    return Container(
      alignment: Alignment.center,
      height: hii,
      width: hii,
      decoration: BoxDecoration(
          color: img == AssetsPics.heart ? color.txtBlue
              : img == AssetsPics.cross ? color.darkcrossgrey : Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 20.0,
                offset: Offset(0.0, 10.0))
          ]),
      child: SvgPicture.asset(img),
    );
  }
}*/


class _ViewProfileScreenState extends State<ViewProfileScreen> {
  PageController controller = PageController();

  ValueNotifier<int> indicatorIndex=ValueNotifier<int>(0);

  String jobTitle = LocaleHandler.dataa["jobTitle"] ?? "";
  // CachedVideoPlayerPlusController? _controller;
  // CachedVideoPlayerPlusController? _controller2;
  // CachedVideoPlayerPlusController? _controller3;

   VideoPlayerController? _controller;
   VideoPlayerController? _controller2;
   VideoPlayerController? _controller3;

/*  cacheVideoPlay1(url) {
    _controller = CachedVideoPlayerPlusController.networkUrl(
      Uri.parse(url),// httpHeaders: {'Connection': 'keep-alive'},
      invalidateCacheIfOlderThan: const Duration(seconds: 100),
    )..initialize().then((value) async {
      await _controller!.setLooping(true);
      _controller!.play();
      _controller!.setVolume(0.0);
      setState(() {});
    });
  }

  cacheVideoPlay2(url) {
    _controller2 = CachedVideoPlayerPlusController.networkUrl(
      Uri.parse(url),
      // httpHeaders: {
      //   'Connection': 'keep-alive',
      // },
      invalidateCacheIfOlderThan: const Duration(seconds: 100),
    )..initialize().then((value) async {
      await _controller2!.setLooping(true);
      _controller2!.play();
      _controller2!.setVolume(0.0);
      setState(() {});
    });
  }

  cacheVideoPlay3(url) {
    _controller3 = CachedVideoPlayerPlusController.networkUrl(
      Uri.parse(url),
      // httpHeaders: {
      //   'Connection': 'keep-alive',
      // },
      invalidateCacheIfOlderThan: const Duration(seconds: 100),
    )..initialize().then((value) async {
      await _controller3!.setLooping(true);
      _controller3!.play();
      _controller3!.setVolume(0.0);
      setState(() {});
    });
  }*/

  @override
  void initState() {
    addImgVid();
    if (LocaleHandler.dataa["profileVideos"].length != 0) {
      // cacheVideoPlay1(LocaleHandler.dataa["profileVideos"][0]["key"]);
      _controller  = VideoPlayerController.networkUrl(Uri.parse(LocaleHandler.dataa["profileVideos"][0]["key"]))
        ..initialize().then((value) {videoPlay(_controller!);});
    }
    if (LocaleHandler.dataa["profileVideos"].length >= 2) {
      // cacheVideoPlay2(LocaleHandler.dataa["profileVideos"][1]["key"]);
      _controller2 = VideoPlayerController.networkUrl(Uri.parse(LocaleHandler.dataa["profileVideos"][1]["key"]))
        ..initialize().then((value) {videoPlay(_controller2!);});
    }
    if (LocaleHandler.dataa["profileVideos"].length >= 3) {
      // cacheVideoPlay3(LocaleHandler.dataa["profileVideos"][2]["key"]);
      _controller3 = VideoPlayerController.networkUrl(Uri.parse(LocaleHandler.dataa["profileVideos"][2]["key"]))
        ..initialize().then((value) {videoPlay(_controller3!);});
    }
    showOnProfile();
    // getINterest();
    super.initState();
  }
  void videoPlay(VideoPlayerController cntrl){
    cntrl.play();
    cntrl.setLooping(true);
    cntrl.setVolume(0.0);
    setState(() {});
  }


  @override
  void dispose() {
    _controller!.dispose();
    if(_controller2!=null){_controller2!.dispose();}
    if(_controller3!=null){_controller3!.dispose();}
    super.dispose();
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

  List splitted = [];

  void showOnProfile() {
    if (LocaleHandler.dataa["showOnProfile"] == null) return;
    String text =
    LocaleHandler.dataa["showOnProfile"].toString().replaceAll(" ", "");
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

  List<Map<String, dynamic>> imgvideitems = [];

  void addImgVid() {
    for (var i = 0; i < LocaleHandler.dataa["profilePictures"].length; i++) {
      var ii = {
        "key": "photo",
        "url": LocaleHandler.dataa["profilePictures"][i]["key"]
      };
      imgvideitems.add(ii);
    }
    for (var i = 0; i < LocaleHandler.dataa["profileVideos"].length; i++) {
      var ii = {
        "key": "video",
        "url": LocaleHandler.dataa["profileVideos"][i]["key"]
      };
      imgvideitems.add(ii);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.0),
              child: Container(
                height: 4.h,
                width: size.width,
                decoration: const BoxDecoration(
                    color: color.txtWhite,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    )),
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                        padding: const EdgeInsets.all(9),
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                        child: SvgPicture.asset(AssetsPics.arrowLeft))),
                GestureDetector(
                  onTap: () {
                    LocaleHandler.entencityname.clear();
                    Provider.of<editProfileController>(context, listen: false).saveValue(
                      LocaleHandler.dataa["gender"],
                      LocaleHandler.dataa["height"],
                      LocaleHandler.dataa["jobTitle"] ?? "",
                      LocaleHandler.education,
                      LocaleHandler.dataa["sexuality"] ?? "",
                      LocaleHandler.dataa["ideal_vacation"] ?? "",
                      LocaleHandler.dataa["cooking_skill"] ?? "",
                      LocaleHandler.dataa["smoking_opinion"] ?? "",
                      LocaleHandler.dataa["ethnicity"],
                    );
                    Get.to(() => const EditProfileScreen())!.then((value) {setState(() {});});
                  },
                  child: Container(
                      height: 36,
                      alignment: Alignment.center,
                      child: SvgPicture.asset(AssetsPics.editProfileBlack)),
                ),
              ],
            ),
            expandedHeight: 43.3.h,
            flexibleSpace: FlexibleSpaceBar(
              background: SizedBox(
                  height: size.height / 2,
                  width: size.width,
                  child: Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.center,
                    children: [
                      PageView.builder(
                        controller: controller,
                        itemCount: imgvideitems.length,
                        onPageChanged: (indexx) {
                          indicatorIndex.value = indexx;
                        },
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {},
                            child: imgvideitems[index]["key"] == "photo"
                                ? CachedNetworkImage(imageUrl: imgvideitems.isEmpty ? "" : imgvideitems[index]["url"],
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                              placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: color.txtBlue)),
                            ) : VideoScreen(url: imgvideitems[index]["url"]),
                          );
                          // child: Image.network(LocaleHandler.dataa["profilePictures"][index]["key"],fit: BoxFit.cover,));
                          // Provider.of<profileController>(context,listen: false).videoUrl = imgvideitems[index]["url"];
                        },
                      ),
                      IgnorePointer(child: SvgPicture.asset(AssetsPics.eventbg, fit: BoxFit.cover)),
                      Positioned(bottom: 40.0,
                        child: ValueListenableBuilder(valueListenable: indicatorIndex,
                            builder: (context,value,child){
                              return IgnorePointer(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List<Widget>.generate(imgvideitems.length, (int index) {
                                    return Container(
                                      margin: const EdgeInsets.only(left: 2.5, right: 2.5, bottom: 12.0),
                                      width: indicatorIndex.value == index ? 15 : 12.0,
                                      height: indicatorIndex.value == index ? 15 : 12.0,
                                      decoration: BoxDecoration(
                                        color: indicatorIndex.value == index ? color.txtWhite : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: indicatorIndex.value == index ? Colors.blue : Colors.white,
                                          width: indicatorIndex.value == index ? 3 : 1.5),
                                      ),
                                    );
                                  }),
                                ),
                              );
                            }
                        ),
                      ),
                    ],
                  )),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                String gender = LocaleHandler.dataa["gender"];
                // double distance=calculateDistance(30.6990782, 76.691354);
                // var dis =distance(30.6990482, 76.691154);
                // var dis2 = dis.toStringAsFixed(2).substring(0, 2);
                return Container(
                  width: size.width,
                  decoration: const BoxDecoration(
                      borderRadius:
                      BorderRadius.vertical(top: Radius.circular(40)),
                      color: Colors.white),
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          FittedBox(
                              child: buildTextOverFlow(
                                  LocaleHandler.dataa['firstName'] == null ? ""
                                      : "${LocaleHandler.dataa["firstName"] ?? ''}",
                                  24,
                                  FontWeight.w600,
                                  color.txtBlack)),
                          buildTextOverFlow(", ${LocaleHandler.dataa['dateOfBirth'] == null ? "" : calculateAge(LocaleHandler.dataa['dateOfBirth'] ?? '')}",
                              24,
                              FontWeight.w600,
                              color.txtBlack),
                          // const SizedBox(width: 70)
                          // SvgPicture.asset(AssetsPics.verifywithborder),
                        ],
                      ),
                      jobTitle == "" ? const SizedBox()
                          : buildText("$jobTitle", 15, FontWeight.w500, color.txtgrey,
                          fontFamily: FontFamily.hellix),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          splitted.contains("gender")
                              ? Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              child: SvgPicture.asset(gender == "male"
                                      ? AssetsPics.greyman : gender == "female"
                                      ? AssetsPics.greyfemale : AssetsPics.transGenderBlack, height: 15))
                              : const SizedBox(),
                          splitted.contains("gender")
                              ? buildText(gender == "male" ? "Male" : gender == "female" ? "Female" : "Other",
                              15, FontWeight.w500, color.txtgrey, fontFamily: FontFamily.hellix) : const SizedBox(),
                          splitted.contains("gender")
                              ? Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              child: SvgPicture.asset(
                                  AssetsPics.greydivider,
                                  height: 15))
                              : const SizedBox(),
                          splitted.contains("height")
                              ? Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              child: SvgPicture.asset(
                                AssetsPics.greyhieght,
                                height: 15,
                              ))
                              : const SizedBox(),
                          splitted.contains("height")
                              ? buildText(LocaleHandler.dataa["height"] + "cm",
                              15, FontWeight.w500, color.txtgrey,
                              fontFamily: FontFamily.hellix)
                              : const SizedBox(),
                          splitted.contains("height")
                              ? Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              child: SvgPicture.asset(
                                  AssetsPics.greydivider,
                                  height: 15))
                              : const SizedBox(),
                          splitted.contains("sexuality")
                              ? buildText(LocaleHandler.dataa["sexuality"], 15,
                              FontWeight.w500, color.txtgrey,
                              fontFamily: FontFamily.hellix)
                              : const SizedBox(),
                          splitted.contains("sexuality")
                              ? Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              child: SvgPicture.asset(
                                  AssetsPics.greydivider,
                                  height: 15))
                              : const SizedBox(),
                          for (var ii = 0; ii < LocaleHandler.dataa["ethnicity"].length; ii++)
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                buildText(
                                    LocaleHandler.dataa["ethnicity"][ii]["name"],
                                    15,
                                    FontWeight.w500,
                                    color.txtgrey,
                                    fontFamily: FontFamily.hellix),
                                ii == LocaleHandler.dataa["ethnicity"].length - 1
                                    ? const SizedBox()
                                    : Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 5),
                                    child: SvgPicture.asset(
                                        AssetsPics.greydivider,
                                        height: 15)),
                              ],
                            )
                        ],
                      ),
                      SizedBox(
                          height: splitted.contains("lookingFor") ? 2.h : 0),
                      splitted.contains("lookingFor")
                          ? buildText("Relationship basics", 20, FontWeight.w600, color.txtBlack)
                          : const SizedBox(),
                      splitted.contains("lookingFor")
                          ? Row(
                        children: [
                          Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              child: SvgPicture.asset(
                                  AssetsPics.greyoutlineheart,
                                  height: 14)),
                          buildText(
                              LocaleHandler.dataa["lookingFor"] ?? '',
                              15,
                              FontWeight.w500,
                              color.txtgrey,
                              fontFamily: FontFamily.hellix),
                        ],
                      )
                          : const SizedBox(),
                      SizedBox(height: 2.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildText("Location", 20, FontWeight.w600, color.txtBlack),
                        ],
                      ),
                      buildText(LocaleHandler.dataa["state"] + ", " + LocaleHandler.dataa["country"],
                          15,
                          FontWeight.w500,
                          color.txtgrey,
                          fontFamily: FontFamily.hellix),
                      Container(
                          height: LocaleHandler.dataa["bio"] == null ? 0 : 2.h),
                      buildText(
                          LocaleHandler.dataa["bio"] == null ? "" : "About",
                          20,
                          FontWeight.w600,
                          color.txtBlack),
                      LocaleHandler.dataa["bio"] == null
                          ? const SizedBox()
                          : ExpandableText(
                        // LocaleText.personDescription,
                        ' ${LocaleHandler.dataa["bio"] ?? ''}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontFamily: FontFamily.hellix,
                            fontWeight: FontWeight.w500,
                            color: color.txtBlack),
                        expandText: '\nRead more',
                        collapseText: 'Read less',
                        maxLines: 3,
                        animation: true,
                        animationDuration: const Duration(seconds: 1),
                        linkColor: Colors.blue,
                        linkStyle: const TextStyle(
                            color: color.txtBlue,
                            fontWeight: FontWeight.w600,
                            fontFamily: FontFamily.hellix,
                            fontSize: 15),
                        linkEllipsis: false,
                      ),
                      SizedBox(
                          height: LocaleHandler.dataa["bio"] == null ? 0 : 2.h),
                      LocaleHandler.dataa["ideal_vacation"] != null ||
                          LocaleHandler.dataa["cooking_skill"] != null ||
                          LocaleHandler.dataa["smoking_opinion"] != null
                          ? buildText("More about me", 20, FontWeight.w600,
                          color.txtBlack)
                          : const SizedBox(),
                      LocaleHandler.dataa["ideal_vacation"] != null ||
                          LocaleHandler.dataa["cooking_skill"] != null ||
                          LocaleHandler.dataa["smoking_opinion"] != null
                          ? Wrap(
                        children: [
                          LocaleHandler.dataa["ideal_vacation"] == null
                              ? const SizedBox()
                              : Container(
                            margin: const EdgeInsets.only(
                                top: 10, right: 9),
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
                                    child: SvgPicture.asset(AssetsPics.greyideal)),
                                buildText(LocaleHandler.dataa["ideal_vacation"],
                                    16,
                                    FontWeight.w600,
                                    color.txtBlack),
                              ],
                            ),
                          ),
                          LocaleHandler.dataa["cooking_skill"] == null
                              ? const SizedBox()
                              : Container(
                            margin: const EdgeInsets.only(
                                top: 10, right: 9),
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
                                    child: SvgPicture.asset(AssetsPics.greyshefhat)),
                                buildText(
                                    LocaleHandler.dataa["cooking_skill"],
                                    16,
                                    FontWeight.w600,
                                    color.txtBlack),
                              ],
                            ),
                          ),
                          LocaleHandler.dataa["smoking_opinion"] == null
                              ? const SizedBox()
                              : Container(
                            margin: const EdgeInsets.only(top: 10, right: 9),
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
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
                                    child: SvgPicture.asset(AssetsPics.greysmoking)),
                                buildText(LocaleHandler.dataa["smoking_opinion"],
                                    16,
                                    FontWeight.w600,
                                    color.txtBlack),
                              ],
                            ),
                          ),
                        ],
                      )
                          : const SizedBox(),
                      SizedBox(
                          height: LocaleHandler.dataa["interests"].length == 0 ? 0 : 2.h),
                      LocaleHandler.dataa["interests"].length == 0
                          ? const SizedBox()
                          : buildText("Interests", 20, FontWeight.w600, color.txtBlack),
                      LocaleHandler.dataa["interests"].length == 0
                          ? const SizedBox()
                          : Wrap(
                        children: [
                          // for(var i=0;i<data.length;i++)
                          for (var i = 0; i < LocaleHandler.dataa["interests"].length; i++)
                            Container(
                              margin: const EdgeInsets.only(top: 10, right: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(19),
                                  border: Border.all(
                                      width: 1,
                                      color: color.lightestBlue)),
                              // child: buildText(data[i]["name"], 16, FontWeight.w600, color.txtBlack),
                              child: buildText(LocaleHandler.dataa["interests"][i]["name"],
                                  16,
                                  FontWeight.w600,
                                  color.txtBlack),
                            )
                        ],
                      ),
                      SizedBox(
                          height: LocaleHandler.dataa["interests"].length == 0
                              ? 0
                              : 2.h),
                      buildText("Gallery", 20, FontWeight.w600, color.txtBlack),
                      SizedBox(height: 1.h),
                      SizedBox(
                        // color: Colors.red,
                        height: size.height * 0.3,
                        width: size.width,
                        child: Row(
                          children: [
                            Expanded(
                                child: LocaleHandler.dataa["profilePictures"].length == 0
                                    ? SizedBox(
                                    height: size.height * 0.3,
                                    child: buildContainer())
                                    : SizedBox(
                                    height: size.height * 0.3,
                                    child: buildPhotoContainer(LocaleHandler.dataa["profilePictures"][0]["key"], 0))),
                            const SizedBox(width: 10),
                            Column(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                      width: size.width / 2 - 80,
                                      child: LocaleHandler.dataa["profilePictures"].length >= 2
                                          ? buildPhotoContainer(LocaleHandler.dataa["profilePictures"][1]["key"], 1)
                                          : buildContainer()),
                                ),
                                SizedBox(height: 1.h),
                                Expanded(
                                  child: SizedBox(
                                    width: size.width / 2 - 80,
                                    child: LocaleHandler.dataa["profilePictures"].length >= 3
                                        ? buildPhotoContainer(
                                        LocaleHandler.dataa["profilePictures"][2]["key"], 2)
                                        : buildContainer(),
                                  ),
                                ),
                              ],
                            ),
                            // const SizedBox(width: 10),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      buildText("Video", 20, FontWeight.w600, color.txtBlack),
                      SizedBox(height: 1.h),
                      SizedBox(
                        height: size.height * 0.3,
                        width: size.width,
                        child: Row(
                          children: [
                            Expanded(
                                child: LocaleHandler.dataa["profileVideos"].length != 0
                                    ? SizedBox(
                                    height: size.height * 0.3,
                                    child: buildVideoContainer(_controller!))
                                    : SizedBox(
                                    height: size.height * 0.3,
                                    child: buildContainer())),
                            const SizedBox(width: 10),
                            Column(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    width: size.width / 2 - 80,
                                    child: LocaleHandler.dataa["profileVideos"].length >= 2
                                        ? buildVideoContainer(_controller2!)
                                        : buildContainer(),
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Expanded(
                                  child: SizedBox(
                                    width: size.width / 2 - 80,
                                    child: LocaleHandler.dataa["profileVideos"].length >= 3
                                        ? buildVideoContainer(_controller3!)
                                        : buildContainer(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5.h),
                    ],
                  ),
                );
              },
              childCount: 1, // SliverList displaying 20 items, each on a ListTile
            ),
          ),
        ],
      ),
    );
  }

  Container buildContainer() => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: color.txtgrey4,
    ),
  );

  Widget buildPhotoContainer(String img, int i) {
    return GestureDetector(
      onTap: () {
        customSlidingImage(context, i, LocaleHandler.dataa["profilePictures"]);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: img,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => buildContainer(),
          placeholder: (ctx, url) => const Center(child: CircularProgressIndicator(color: color.txtBlue)),
        ),
        // Image.network(LocaleHandler.dataa["avatar"],fit: BoxFit.cover,)
      ),
    );
  }

  Widget buildVideoContainer(VideoPlayerController cntrl) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            cntrl.value.isInitialized? AspectRatio(
              aspectRatio: cntrl.value.aspectRatio,
              child: VideoPlayer(cntrl),
            ):Container(alignment: Alignment.center, child: const CircularProgressIndicator(color: color.txtBlue)),
            cntrl.value.isInitialized? GestureDetector(
                onTap: () {
                  // Provider.of<profileController>(context, listen: false).videoUrl = cntrl.dataSource;
                  Get.to(() => ProfileVideoViewer(url: cntrl.dataSource));
                },
                child: Container(
                    alignment: Alignment.center,
                    child: SvgPicture.asset(AssetsPics.videoplayicon))):const SizedBox()
          ],
        ));
  }

  Widget buildColumn(String img, double hii) {
    return Container(
      alignment: Alignment.center,
      height: hii,
      width: hii,
      decoration: BoxDecoration(
          color: img == AssetsPics.heart ? color.txtBlue
              : img == AssetsPics.cross ? color.darkcrossgrey : Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 20.0,
                offset: Offset(0.0, 10.0))
          ]),
      child: SvgPicture.asset(img),
    );
  }
}