import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/loader.dart';
import 'package:slush/controller/edit_profile_controller.dart';
import 'package:slush/controller/profile_controller.dart';
import 'package:slush/screens/profile/Intereset.dart';
import 'package:slush/screens/profile/basic_info/profile_video_view.dart';
import 'package:slush/screens/profile/edit_profile_basic_info.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/customtoptoaster.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:slush/widgets/toaster.dart';
import 'package:video_player/video_player.dart';

class BasicInfoclass {
  late int id;
  late String name;
  late String handler;

  BasicInfoclass(this.id, this.name, this.handler);
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController bioController = TextEditingController(text: LocaleHandler.dataa["bio"] ?? "");

  PageController pageController = PageController();
  int imgIndex = 0;
  String PictureId = "";
  List slidingImages = [AssetsPics.sample, AssetsPics.sample, AssetsPics.sample];

  String selcetedIndex = "";

  // File? videoFile;
  final picker = ImagePicker();
  File? galleryFile;
  var imgdata;

  @override
  void initState() {
    profileData();
    super.initState();
  }

  Future profileData() async {
    final url = ApiList.getUser + LocaleHandler.userId;
    print(url);
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${LocaleHandler.accessToken}'
      });
      if (response.statusCode == 200) {
        Provider.of<editProfileController>(context, listen: false).changevalue();
        Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          LocaleHandler.dataa = data["data"];
          Provider.of<editProfileController>(context, listen: false).videoValToCont();
          showBanner();
          saveDta();
        });
      } else if (response.statusCode == 401) {
        showToastMsgTokenExpired();
        print('Token Expire:::::::::::::');
      } else {
        print('Faoled to Load Data With Status Code ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      throw Exception('Failed to fetch data: $e');
    }
  }

  void saveDta() {
    LocaleHandler.gender = LocaleHandler.dataa["gender"];
    LocaleHandler.height = LocaleHandler.dataa["height"];
    if (LocaleHandler.dataa["jobTitle"] != null) {
      LocaleHandler.jobtitle = LocaleHandler.dataa["jobTitle"];
    }
    LocaleHandler.sexualOreintation = LocaleHandler.dataa["sexuality"];
    if (LocaleHandler.dataa["ideal_vacation"] != null) {
      LocaleHandler.ideal = LocaleHandler.dataa["ideal_vacation"];
    }
    if (LocaleHandler.dataa["cooking_skill"] != null) {
      LocaleHandler.cookingSkill = LocaleHandler.dataa["cooking_skill"];
    }
    if (LocaleHandler.dataa["smoking_opinion"] != null) {
      LocaleHandler.smokingopinion = LocaleHandler.dataa["smoking_opinion"];
    }
    if (LocaleHandler.dataa["showOnProfile"] != null) {
      String text =
          LocaleHandler.dataa["showOnProfile"].toString().replaceAll(" ", "");
      splitted = text.split(',');
      if (splitted.contains("gender")) {
        LocaleHandler.showgenders = "true";
      }
      if (splitted.contains("height")) {
        LocaleHandler.showheights = "true";
      }
      if (splitted.contains("sexuality")) {
        LocaleHandler.showsexualOreintations = "true";
      }
    }

    if (LocaleHandler.dataa["ethnicity"] != null) {
      var i = 0;
      for (i = 0; i < LocaleHandler.dataa["ethnicity"].length; i++) {
        if (!LocaleHandler.entencity.contains(LocaleHandler.dataa["ethnicity"][i]["id"])) {
          LocaleHandler.entencity.add(LocaleHandler.dataa["ethnicity"][i]["id"]);
        }
      }
    }
  }

  List splitted = [];

  Future UpdateProfileDetail() async {
    const url = ApiList.updateProfileDetail;
    print(url);
    var uri = Uri.parse(url);
    var request = http.MultipartRequest('PATCH', uri);
    request.headers['Authorization'] = "Bearer ${LocaleHandler.accessToken}";

    if (LocaleHandler.dataa["height"] != LocaleHandler.height) {
      request.fields['height'] = LocaleHandler.height;
      request.fields['height_unit'] = LocaleHandler.heighttype;
    }

    request.fields['display_height'] = LocaleHandler.showheights;
    request.fields['display_gender'] = LocaleHandler.showgenders;
    request.fields['display_orientation'] =
        LocaleHandler.showsexualOreintations;

    if (LocaleHandler.dataa["gender"] != LocaleHandler.gender) {
      request.fields['gender'] = LocaleHandler.gender;
    }

    if (LocaleHandler.dataa["sexuality"] != LocaleHandler.sexualOreintation) {
      request.fields['sexuality'] = LocaleHandler.sexualOreintation;
    }

    if ((LocaleHandler.dataa["jobTitle"] ?? "") != LocaleHandler.jobtitle) {
      request.fields['jobTitle'] = LocaleHandler.jobtitle;
    }

    if (bioController.text.trim() != "") {
      request.fields['bio'] = bioController.text.trim();
    }

    if ((LocaleHandler.dataa["ideal_vacation"] ?? "") != LocaleHandler.ideal) {
      request.fields['ideal_vacation'] = LocaleHandler.ideal.toString();
    }

    if ((LocaleHandler.dataa["cooking_skill"] ?? "") !=
        LocaleHandler.cookingSkill) {
      request.fields['cooking_skill'] = LocaleHandler.cookingSkill.toString();
    }

    if ((LocaleHandler.dataa["smoking_opinion"] ?? "") !=
        LocaleHandler.smokingopinion) {
      request.fields['smoking_opinion'] =
          LocaleHandler.smokingopinion.toString();
    }

    var response = await request.send();
    print(response.statusCode);
    final respStr = await response.stream.bytesToString();
    print(respStr);
    if (response.statusCode == 200) {
      setState(() {
        LoaderOverlay.hide();
      });
      showToastMsg("Updated succesfully");
      updateEthnicity();
    } else if (response.statusCode == 401) {
      setState(() {
        LoaderOverlay.hide();
      });
      showToastMsgTokenExpired();
    } else {
      setState(() {
        LoaderOverlay.hide();
      });
      showToastMsg("Failed to update!");
    }
  }

  Future updateEthnicity() async {
    print(LocaleHandler.entencity);
    const url = ApiList.updateEthnicity;
    print(url);
    var uri = Uri.parse(url);
    var response = await http.patch(uri,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${LocaleHandler.accessToken}"
        },
        body: jsonEncode({"ethnicity": LocaleHandler.entencity}));
    if (response.statusCode == 200) {
      Provider.of<profileController>(context, listen: false).profileData(context);
      showToastMsg("Updated succesfully");
      setState(() {LoaderOverlay.hide();});
      Future.delayed(const Duration(seconds: 2), () {
        Get.back();
      });
    } else {
      Provider.of<profileController>(context, listen: false)
          .profileData(context);
      setState(() {
        LoaderOverlay.hide();
      });
      Future.delayed(const Duration(seconds: 2), () {
        Get.back();
      });
    }
  }

  bool _showNotification = false;

  void showBanner() {
    setState(() {
      _showNotification = true;
      LocaleHandler.isBanner2 = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Scaffold(
          appBar: commonBar(context, Colors.transparent),
          body: Consumer<profileController>(builder: (ctx, val, child) {
            return val.dataa.length == 0
                ? Center(child: CircularProgressIndicator(color: color.txtBlue))
                : Stack(
                    children: [
                      SizedBox(
                        height: size.height,
                        width: size.width,
                        child: Image.asset(AssetsPics.background, fit: BoxFit.cover),
                      ),
                      SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16, right: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 2.h),
                                  buildText("Edit Photo", 20, FontWeight.w600,
                                      color.txtBlack),
                                  SizedBox(height: 1.h),
                                  Consumer<editProfileController>(
                                      builder: (context, val, child) {
                                    imgdata = val.fromprov
                                        ? val.imagedata
                                        : LocaleHandler.dataa;
                                    return buildphotos(size, val);
                                  }),
                                  SizedBox(height: 2.h),
                                  buildText("Edit Video", 20, FontWeight.w600,
                                      color.txtBlack),
                                  SizedBox(height: 1.h),
                                  Consumer<editProfileController>(
                                      builder: (context, val, child) {
                                    imgdata = val.fromprov
                                        ? val.imagedata
                                        : LocaleHandler.dataa;
                                    return buildVideo(size);
                                  }),
                                  // buildVideo(size),
                                  SizedBox(height: 1.h + 5),
                                  // Center(child: buildText("Hold and drag media to reorder", 16, FontWeight.w500, color.txtgrey, fontFamily: FontFamily.hellix))
                                ],
                              ),
                            ),
                            buildDivider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildText("My bio", 20, FontWeight.w600,
                                      color.txtBlack),
                                  SizedBox(height: 1.h - 3),
                                  buildText("Write a fun intro", 16,
                                      FontWeight.w500, color.txtBlack),
                                  SizedBox(height: 1.h - 3),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            width: 1,
                                            color: color.lightestBlue),
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                    child: TextFormField(
                                      maxLines: 3,
                                      controller: bioController,
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      style: const TextStyle(
                                          color: color.txtBlack,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: FontFamily.hellix),
                                      keyboardType: TextInputType.multiline,
                                      decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: color.textFieldColor),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: color.textFieldColor),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          border: const OutlineInputBorder(),
                                          hintText: 'A little bit about you...',
                                          hintStyle: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: FontFamily.hellix,
                                              color: color.txtgrey2)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            buildDivider(),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildText("Basic info", 20, FontWeight.w600,
                                      color.txtBlack),
                                  SizedBox(height: 1.h - 5),
                                  Consumer<editProfileController>(
                                      builder: (ctx, val, child) {
                                    return ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: val.basicInfo.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                top: 4, bottom: 4),
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  LocaleHandler.basicInfo =
                                                      true;
                                                  LocaleHandler.EditProfile =
                                                      true;
                                                });
                                                Get.to(() =>
                                                        EditProfileBasicInfoScreen(
                                                            index: index))!
                                                    .then((value) {
                                                  setState(() {});
                                                });
                                              },
                                              child: Container(
                                                color: Colors.transparent,
                                                child: Row(
                                                  children: [
                                                    buildText(
                                                        val.basicInfo[index]
                                                            .name,
                                                        18,
                                                        FontWeight.w500,
                                                        color.txtgrey,
                                                        fontFamily:
                                                            FontFamily.hellix),
                                                    const Spacer(),
                                                    Consumer<
                                                            editProfileController>(
                                                        builder:
                                                            (ctx, val, child) {
                                                      return (val.basicInfo[index].name ==
                                                                      "Work" ||
                                                                  val
                                                                          .basicInfo[
                                                                              index]
                                                                          .name ==
                                                                      "Education") &&
                                                              val
                                                                      .basicInfo[
                                                                          index]
                                                                      .handler !=
                                                                  ""
                                                          ? SizedBox(
                                                              width:
                                                                  size.width *
                                                                          0.5 +
                                                                      4,
                                                              child: buildTextOverFlow2(
                                                                  val.basicInfo[index].handler ==
                                                                          ""
                                                                      ? "Add"
                                                                      : val
                                                                          .basicInfo[
                                                                              index]
                                                                          .handler,
                                                                  18,
                                                                  FontWeight
                                                                      .w500,
                                                                  color.txtgrey,
                                                                  fontFamily:
                                                                      FontFamily
                                                                          .hellix),
                                                            )
                                                          : buildText(
                                                              val.basicInfo[index].handler ==
                                                                      ""
                                                                  ? "Add"
                                                                  : val
                                                                      .basicInfo[
                                                                          index]
                                                                      .handler,
                                                              18,
                                                              FontWeight.w500,
                                                              color.txtgrey,
                                                              fontFamily:
                                                                  FontFamily
                                                                      .hellix);
                                                    }),
                                                    // buildText(basicInfo[index].handler==""?"Add":basicInfo[index].handler, 18, FontWeight.w500,
                                                    //     color.txtgrey, fontFamily: FontFamily.hellix),
                                                    const SizedBox(width: 12),
                                                    SvgPicture.asset(
                                                        AssetsPics.rightArrow),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                                  })
                                ],
                              ),
                            ),
                            buildDivider(),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildText("More about me", 20,
                                      FontWeight.w600, color.txtBlack),
                                  SizedBox(height: 1.h - 5),
                                  Consumer<editProfileController>(
                                      builder: (context, val, child) {
                                    return ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: val.moreaboutme.length,
                                        itemBuilder: (context, index) {
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                LocaleHandler.basicInfo = false;
                                                LocaleHandler.EditProfile =
                                                    true;
                                              });
                                              Get.to(() =>
                                                  EditProfileBasicInfoScreen(
                                                      index: index));
                                            },
                                            child: Container(
                                              color: Colors.transparent,
                                              padding: const EdgeInsets.only(
                                                  top: 4, bottom: 4),
                                              child: Row(
                                                children: [
                                                  buildText(
                                                      val.moreaboutme[index]
                                                          .name,
                                                      18,
                                                      FontWeight.w500,
                                                      color.txtgrey,
                                                      fontFamily:
                                                          FontFamily.hellix),
                                                  const Spacer(),
                                                  buildText(
                                                      val.moreaboutme[index]
                                                                  .handler ==
                                                              ""
                                                          ? "Add"
                                                          : val
                                                              .moreaboutme[
                                                                  index]
                                                              .handler,
                                                      16,
                                                      FontWeight.w500,
                                                      color.txtgrey,
                                                      fontFamily:
                                                          FontFamily.hellix),
                                                  const SizedBox(width: 12),
                                                  SvgPicture.asset(
                                                      AssetsPics.rightArrow),
                                                ],
                                              ),
                                            ),
                                          );
                                        });
                                  }),
                                ],
                              ),
                            ),
                            buildDivider(),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 15, right: 15, bottom: 5),
                              child: GestureDetector(
                                onTap: () {
                                  Get.to(() => const InterestListScreen())!
                                      .then((value) {
                                    setState(() {
                                      if (value ?? false) {
                                        UpdateProfileDetail();
                                      }
                                    });
                                  });
                                },
                                child: Container(
                                  color: Colors.transparent,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          buildText("My interest", 20,
                                              FontWeight.w600, color.txtBlack),
                                          const Spacer(),
                                          buildText(
                                              LocaleHandler.dataa["interests"].length == 0 || LocaleHandler.dataa == null
                                                  ? "Add"
                                                  : "${LocaleHandler.dataa["interests"].length} items",
                                              18,
                                              FontWeight.w500,
                                              color.txtgrey,
                                              fontFamily: FontFamily.hellix),
                                          const SizedBox(width: 12),
                                          SvgPicture.asset(
                                              AssetsPics.rightArrow),
                                        ],
                                      ),
                                      SizedBox(height: 1.h - 5),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 2, bottom: 2),
                                        child: buildText(
                                            "Get specific about the things you love",
                                            18,
                                            FontWeight.w500,
                                            color.txtgrey,
                                            fontFamily: FontFamily.hellix),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            buildDivider(),
                            /* Padding(
                      padding:
                      const EdgeInsets.only(left: 15, right: 15, bottom: 5),
                      child: GestureDetector(
                        onTap: (){
                          Get.to(()=>const PhoneNumberScreen());
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                buildText("Phone number", 20, FontWeight.w600,
                                    color.txtBlack),
                                const Spacer(),
                                buildText("Add", 18, FontWeight.w500, color.txtgrey, fontFamily: FontFamily.hellix),
                                const SizedBox(width: 12),
                                SvgPicture.asset(AssetsPics.rightArrow),
                              ],
                            ),
                            SizedBox(height: 1.h - 5),
                            Padding(
                              padding: const EdgeInsets.only(top: 2, bottom: 2),
                              child: buildText(
                                  LocaleHandler.dataa["phoneNumber"]??'Provide your mobile number',
                                  18,
                                  FontWeight.w500,
                                  color.txtgrey,
                                  fontFamily: FontFamily.hellix),
                            )
                          ],
                        ),
                      ),
                    ),*/
                            // buildDivider(),
                            /*    Padding(
                              padding: const EdgeInsets.only(
                                  left: 15, right: 15, bottom: 100),
                              child: GestureDetector(
                                onTap: () {
                                  // Get.to(()=>const ChangeEmailScreen());
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        buildText("Your email", 20,
                                            FontWeight.w600, color.txtBlack),
                                        const Spacer(),
                                        // buildText(LocaleHandler.dataa["email"]==""?"Add":"Change", 18, FontWeight.w500, color.txtgrey, fontFamily: FontFamily.hellix),
                                        const SizedBox(width: 12),
                                        // SvgPicture.asset(AssetsPics.rightArrow),
                                      ],
                                    ),
                                    SizedBox(height: 1.h - 5),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 2, bottom: 2),
                                      child: buildText(
                                          LocaleHandler.dataa["email"] ?? 'Provide your mobile number',
                                          18,
                                          FontWeight.w500,
                                          color.txtgrey,
                                          fontFamily: FontFamily.hellix),
                                    )
                                  ],
                                ),
                              ),
                            ),*/
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        height:  0,
                        duration: const Duration(milliseconds: 600),
                        width: size.width,
                        child: Image.asset(
                          AssetsPics.editBanner,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ],
                  );
          }),
          bottomSheet: Padding(
            padding: Platform.isIOS
                ? const EdgeInsets.only(bottom: 23, left: 16, right: 16, top: 2)
                : const EdgeInsets.only(
                    bottom: 10, left: 15, right: 15, top: 2),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 30,
              height: 50.0,
              child: blue_button(context, "Update", press: () {
                FocusManager.instance.primaryFocus?.unfocus();
                // print(selectedTitle);
                setState(() {
                  LoaderOverlay.show(context);
                });
                UpdateProfileDetail();
                // updateInterest();
              }),
            ),
          ),
        ),
        _showNotification
            ? CustomredTopToaster(textt: "Keep it clean. No explict content")
            : const SizedBox.shrink()
      ],
    );
  }

  Widget buildDivider() {
    return Column(
      children: [
        SizedBox(height: 1.h),
        const Divider(color: color.lightestBlue),
        SizedBox(height: 1.h),
      ],
    );
  }

  Widget buildVideo(Size size) {
    return SizedBox(
      // color: Colors.red,
      height: size.height * 0.3, width: size.width,
      child: Row(
        children: [
          Expanded(
              child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                  padding: const EdgeInsets.only(right: 4, bottom: 4),
                  child: Consumer<editProfileController>(
                      builder: (context, val, child) {
                    return val.imgLoad && val.imgindex == 1
                        ? buildCenterloader()
                        : imgdata["profileVideos"].length != 0
                            ? val.controller == null
                                ? const SizedBox()
                                : buildVideoContainer(val.controller!,
                                    val.initializeVideoPlayerFuture!, val)
                            : buildContainer();
                  })),
              Container(
                  padding: const EdgeInsets.only(right: 5, top: 5),
                  alignment: Alignment.topRight,
                  child:
                      SvgPicture.asset(AssetsPics.zoomIcon, fit: BoxFit.cover)),
              Positioned(
                right: 0.10,
                bottom: 0.0,
                child: Consumer<editProfileController>(
                    builder: (context, val, child) {
                  return val.imgLoad && val.imgindex == 1
                      ? SizedBox()
                      : GestureDetector(
                          onLongPress: () {
                            if (imgdata["profileVideos"].length != 0) {
                              buildCustomDialogBoxWithtwobuttonfordeletePicture(
                                  0, "video");
                            }
                          },
                          onTap: () {
                            imgIndex = 1;
                            PictureId = imgdata["profileVideos"].length != 0
                                ? imgdata["profileVideos"][0]["profileVideoId"]
                                    .toString()
                                : "-1";
                            buildShowModalBottomSheet("video");
                          },
                          child: Container(
                              alignment: Alignment.bottomRight,
                              child: SvgPicture.asset(AssetsPics.profileEdit1,
                                  width: 35, height: 35)),
                        );
                }),
              )
            ],
          )),
          const SizedBox(width: 6),
          Column(
            children: [
              Stack(
                children: [
                  Container(
                      padding: const EdgeInsets.only(right: 5, bottom: 5),
                      height: size.height * 0.3 / 2 - 2,
                      width: size.width / 2 - 75,
                      child: Consumer<editProfileController>(
                          builder: (context, val, child) {
                        return val.imgLoad && val.imgindex == 2
                            ? buildCenterloader()
                            : imgdata["profileVideos"].length >= 2
                                ? val.controller2 == null
                                    ? const SizedBox()
                                    : buildVideoContainer(val.controller2!,
                                        val.initializeVideoPlayerFuture2!, val)
                                : GestureDetector(
                                    onTap: () {
                                      imgIndex = 2;
                                      PictureId =
                                          imgdata["profileVideos"].length >= 2
                                              ? imgdata["profileVideos"][1]
                                                      ["profileVideoId"]
                                                  .toString()
                                              : "-1";
                                      buildShowModalBottomSheet("video");
                                    },
                                    child: buildContainer());
                      })),
                  Positioned(
                    right: 0.0,
                    bottom: 0.0,
                    child: Consumer<editProfileController>(
                        builder: (context, val, child) {
                      return val.imgLoad && val.imgindex == 2
                          ? SizedBox()
                          : GestureDetector(
                              onLongPress: () {
                                if (imgdata["profileVideos"].length >= 2) {
                                  buildCustomDialogBoxWithtwobuttonfordeletePicture(
                                      1, "video");
                                }
                              },
                              onTap: () {
                                imgIndex = 2;
                                PictureId = imgdata["profileVideos"].length >= 2
                                    ? imgdata["profileVideos"][1]
                                            ["profileVideoId"]
                                        .toString()
                                    : "-1";
                                buildShowModalBottomSheet("video");
                              },
                              child: Container(
                                  alignment: Alignment.bottomRight,
                                  child: SvgPicture.asset(
                                      imgdata["profileVideos"].length >= 2
                                          ? AssetsPics.profileEdit1
                                          : AssetsPics.addImage,
                                      width: 35,
                                      height: 35)),
                            );
                    }),
                  )
                ],
              ),
              const SizedBox(height: 2),
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.only(right: 5, bottom: 5),
                    height: size.height * 0.3 / 2 - 2,
                    width: size.width / 2 - 75,
                    child: Consumer<editProfileController>(
                        builder: (context, val, child) {
                      return val.imgLoad && val.imgindex == 3
                          ? buildCenterloader()
                          : imgdata["profileVideos"].length >= 3
                              ? val.controller3 == null
                                  ? const SizedBox()
                                  : buildVideoContainer(val.controller3!,
                                      val.initializeVideoPlayerFuture3!, val)
                              : GestureDetector(
                                  onTap: () {
                                    imgIndex = 3;
                                    PictureId =
                                        imgdata["profileVideos"].length >= 3
                                            ? imgdata["profileVideos"][2]
                                                    ["profileVideoId"]
                                                .toString()
                                            : "-1";
                                    buildShowModalBottomSheet("video");
                                  },
                                  child: buildContainer());
                    }),
                  ),
                  Positioned(
                    right: 0.0,
                    bottom: 0.0,
                    child: Consumer<editProfileController>(
                        builder: (context, val, child) {
                      return val.imgLoad && val.imgindex == 1
                          ? SizedBox()
                          : GestureDetector(
                              onLongPress: () {
                                if (imgdata["profileVideos"].length >= 3) {
                                  buildCustomDialogBoxWithtwobuttonfordeletePicture(
                                      2, "video");
                                }
                              },
                              onTap: () {
                                imgIndex = 3;
                                PictureId = imgdata["profileVideos"].length >= 3
                                    ? imgdata["profileVideos"][2]
                                            ["profileVideoId"]
                                        .toString()
                                    : "-1";
                                buildShowModalBottomSheet("video");
                              },
                              child: Container(
                                  alignment: Alignment.bottomRight,
                                  child: SvgPicture.asset(
                                      imgdata["profileVideos"].length >= 3
                                          ? AssetsPics.profileEdit1
                                          : AssetsPics.addImage,
                                      width: 35,
                                      height: 35)),
                            );
                    }),
                  )
                ],
              ),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget buildphotos(Size size, editProfileController val) {
    // Provider.of<editProfileController>(context,listen: false).addImages(imgdata["profilePictures"]);
    List items = [];
    var i;
    for (i = 0; i < imgdata["profilePictures"].length; i++) {
      items.add(imgdata["profilePictures"][i]["key"]);
    }
    return SizedBox(
      // color: Colors.red,
      height: size.height * 0.3,
      width: size.width,
      child: Row(
        children: [
          Expanded(
              child: Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                onTap: () {
                  pageController = PageController(initialPage: 0);
                  customSlidingImage(context, 0, imgdata["profilePictures"]);
                  // customSlidingImage(
                  //     context: context,
                  //     title: 'Coming soon',
                  //     secontxt: " ",
                  //     heading: "Events specific to this category\ncoming soon",
                  //     btnTxt: "Ok",
                  //     imges: imgdata["profilePictures"],
                  //     img: imgdata["profilePictures"].length != 0 ? imgdata["profilePictures"][0]["key"] : null);
                },
                child: Container(
                    height: size.height * 0.3,
                    padding: const EdgeInsets.only(right: 4, bottom: 4),
                    child: imgdata["profilePictures"].length != 0
                        ?
                        // isDraggable==false ? onLongPressedd(items[0]) : onDragTarget(items[0]) : buildContainer()
                        buildPhotoContainer(items[0])
                        : buildContainer()),
              ),
              Container(
                  padding: const EdgeInsets.only(right: 5, top: 5),
                  alignment: Alignment.topRight,
                  child:
                      SvgPicture.asset(AssetsPics.zoomIcon, fit: BoxFit.cover)),
              Positioned(
                right: 0.10,
                bottom: 0.0,
                child: GestureDetector(
                  onLongPress: () {
                    if (imgdata["profilePictures"].length != 0) {
                      imgIndex = 1;
                      buildCustomDialogBoxWithtwobuttonfordeletePicture(
                          0, "image");
                    }
                  },
                  onTap: () {
                    setState(() {
                      if (imgdata["profilePictures"].length != 0) {
                        imgIndex = 1;
                        PictureId = imgdata["profilePictures"][0]
                                ["profilePictureId"]
                            .toString();
                        buildShowModalBottomSheet("image");
                      }
                    });
                  },
                  child: Container(
                      alignment: Alignment.bottomRight,
                      child: SvgPicture.asset(AssetsPics.profileEdit1,
                          width: 35, height: 35)),
                ),
              )
            ],
          )),
          const SizedBox(width: 6),
          Column(
            children: [
              Stack(
                children: [
                  Container(
                      padding: const EdgeInsets.only(right: 5, bottom: 5),
                      height: size.height * 0.3 / 2 - 2,
                      width: size.width / 2 - 75,
                      child: val.showNetImg2
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(File(val.croppedFile2!.path),
                                  fit: BoxFit.cover))
                          : imgdata["profilePictures"].length >= 2
                              ? GestureDetector(
                                  onTap: () {
                                    pageController =
                                        PageController(initialPage: 1);
                                    customSlidingImage(
                                        context, 1, imgdata["profilePictures"]);
                                    /* customSlidingImage(
                                context: context,
                                title: 'Coming soon',
                                secontxt: " ",
                                heading: "Events specific to this category\ncoming soon",
                                btnTxt: "Ok",
                                imges: imgdata["profilePictures"],
                                img: imgdata["profilePictures"].length != 0 ? items[1] : null);*/
                                  },
                                  child: buildPhotoContainer(items[1])
                                  // onLongPressedd(items[1])
                                  )
                              : GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      imgIndex = 2;
                                      PictureId =
                                          imgdata["profilePictures"].length >= 2
                                              ? imgdata["profilePictures"][1]
                                                      ["profilePictureId"]
                                                  .toString()
                                              : "-1";
                                      buildShowModalBottomSheet("image");
                                    });
                                  },
                                  child: buildContainer())),
                  Positioned(
                    right: 0.0,
                    bottom: 0.0,
                    child: GestureDetector(
                      onLongPress: () {
                        if (imgdata["profilePictures"].length >= 2) {
                          imgIndex = 2;
                          buildCustomDialogBoxWithtwobuttonfordeletePicture(
                              1, "image");
                        }
                      },
                      onTap: () {
                        setState(() {
                          imgIndex = 2;
                          PictureId = imgdata["profilePictures"].length >= 2
                              ? imgdata["profilePictures"][1]
                                      ["profilePictureId"]
                                  .toString()
                              : "-1";
                          buildShowModalBottomSheet("image");
                        });
                      },
                      child: Container(
                          alignment: Alignment.bottomRight,
                          child: SvgPicture.asset(
                              imgdata["profilePictures"].length >= 2
                                  ? AssetsPics.profileEdit1
                                  : AssetsPics.addImage,
                              width: 35,
                              height: 35)),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 2),
              Stack(
                children: [
                  Container(
                      padding: const EdgeInsets.only(right: 5, bottom: 5),
                      height: size.height * 0.3 / 2 - 2,
                      width: size.width / 2 - 75,
                      child: val.showNetImg3
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(File(val.croppedFile3!.path),
                                  fit: BoxFit.cover))
                          : imgdata["profilePictures"].length >= 3
                              ? GestureDetector(
                                  onTap: () {
                                    pageController =
                                        PageController(initialPage: 2);
                                    customSlidingImage(
                                        context, 2, imgdata["profilePictures"]);
                                    /*          customSlidingImage(
                                context: context,
                                title: 'Coming soon',
                                secontxt: " ",
                                heading: "Events specific to this category\ncoming soon",
                                btnTxt: "Ok",
                                imges: imgdata["profilePictures"],
                                img: imgdata["profilePictures"].length != 0 ? items[2] : null);*/
                                  },
                                  child: buildPhotoContainer(items[2]))
                              : GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      imgIndex = 3;
                                      PictureId =
                                          imgdata["profilePictures"].length >= 3
                                              ? imgdata["profilePictures"][2]
                                                      ["profilePictureId"]
                                                  .toString()
                                              : "-1";
                                      buildShowModalBottomSheet("image");
                                    });
                                  },
                                  child: buildContainer())),
                  Positioned(
                    right: 0.0,
                    bottom: 0.0,
                    child: GestureDetector(
                      onLongPress: () {
                        if (imgdata["profilePictures"].length >= 3) {
                          imgIndex = 3;
                          buildCustomDialogBoxWithtwobuttonfordeletePicture(
                              2, "image");
                        }
                      },
                      onTap: () {
                        setState(() {
                          imgIndex = 3;
                          PictureId = imgdata["profilePictures"].length >= 3
                              ? imgdata["profilePictures"][2]
                                      ["profilePictureId"]
                                  .toString()
                              : "-1";
                          buildShowModalBottomSheet("image");
                        });
                      },
                      child: Container(
                          alignment: Alignment.bottomRight,
                          child: SvgPicture.asset(
                              imgdata["profilePictures"].length >= 3
                                  ? AssetsPics.profileEdit1
                                  : AssetsPics.addImage,
                              width: 35,
                              height: 35)),
                    ),
                  )
                ],
              ),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  buildCustomDialogBoxWithtwobuttonfordeletePicture(int i, String video) {
    final editCntrler =
        Provider.of<editProfileController>(context, listen: false);
    customDialogBoxWithtwobuttonfordeletePicture(
        context,
        video == "video"
            ? "do you want delete video"
            : "do you want delete picture",
        btnTxt1: "No",
        btnTxt2: "Yes, Delete", onTap2: () {
      Get.back();
      video == "video"
          ? editCntrler.DestroyVideo(
              context, imgdata["profileVideos"][i]["profileVideoId"])
          : editCntrler.DestroyPicture(
              context, imgdata["profilePictures"][i]["profilePictureId"]);
    });
  }

  Future<void> buildShowModalBottomSheet(String video) {
    final editCntrler =
        Provider.of<editProfileController>(context, listen: false);
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.only(left: 16, right: 16, bottom: 3.h - 2),
          padding: const EdgeInsets.only(top: 25, bottom: 25),
          decoration: BoxDecoration(
              color: color.txtWhite, borderRadius: BorderRadius.circular(16)),
          width: MediaQuery.of(context).size.width,
          child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selcetedIndex = "0";
                        Future.delayed(const Duration(seconds: 1), () async {
                          // Get.back();
                          // video == "video" ? getVideo(ImageSource.camera) : imgFromGallery(ImageSource.camera);
                          if (video == "video") {
                            final camStatus = await Permission.camera.status;
                            final micStatus =
                                await Permission.microphone.status;
                            // if (camStatus.isGranted && micStatus.isGranted) { editCntrler.getVideo(context,ImageSource.camera);}
                            if (camStatus.isGranted && micStatus.isGranted) {
                              editCntrler.callVideoRecordFunction(context,
                                  ImageSource.camera, PictureId, imgIndex);
                            } else if (camStatus.isDenied ||
                                micStatus.isDenied) {
                              var newcamStatus =
                                  await Permission.camera.request();
                              var newmicStatus =
                                  await Permission.microphone.request();
                              // if (newcamStatus.isGranted && newmicStatus.isGranted){  editCntrler.getVideo(context,ImageSource.camera);}
                              if (newcamStatus.isGranted &&
                                  newmicStatus.isGranted) {
                                editCntrler.callVideoRecordFunction(context,
                                    ImageSource.camera, PictureId, imgIndex);
                              } else if (newcamStatus.isPermanentlyDenied ||
                                  newmicStatus.isPermanentlyDenied) {
                                //openAppSettings();
                                showToastMsg(
                                    "Camera Permission is denied! please goto app setting and enable permission");
                                Get.back();
                              }
                            } else if (camStatus.isPermanentlyDenied ||
                                micStatus.isPermanentlyDenied) {
                              //openAppSettings();
                              showToastMsg(
                                  "Camera Permission is denied! please goto app setting and enable permission");
                              Get.back();
                            }
                          } else {
                            var status = await Permission.camera.status;
                            if (status.isGranted) {
                              editCntrler.tappedOPtion(context,
                                  ImageSource.camera, "0", PictureId, imgIndex);
                            } else if (status.isDenied) {
                              var newStatus = await Permission.camera.request();
                              if (newStatus.isGranted) {
                                editCntrler.tappedOPtion(
                                    context,
                                    ImageSource.camera,
                                    "0",
                                    PictureId,
                                    imgIndex);
                              } else if (newStatus.isPermanentlyDenied) {
                                //openAppSettings();
                                showToastMsg(
                                    "Camera Permission is denied! please goto app setting and enable permission");
                                Get.back();
                              }
                            } else if (status.isPermanentlyDenied) {
                              //openAppSettings();
                              showToastMsg(
                                  "Camera Permission is denied! please goto app setting and enable permission");
                              Get.back();
                            }
                          }
                          selcetedIndex = "";
                        });
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildText(
                              video == "video"
                                  ? "Take a Video"
                                  : "Take a Selfie",
                              18,
                              selcetedIndex == "0"
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color.txtBlack),
                          CircleAvatar(
                            backgroundColor: selcetedIndex == "0"
                                ? color.txtBlue
                                : color.txtWhite,
                            radius: 9,
                            child: CircleAvatar(
                              radius: 8,
                              backgroundColor: selcetedIndex == "0"
                                  ? color.txtWhite
                                  : color.txtWhite,
                              // backgroundImage: SvgPicture.asset(AssetsPics.arrowLeft),
                              child: selcetedIndex == "0"
                                  ? SvgPicture.asset(AssetsPics.blueTickCheck,
                                      fit: BoxFit.cover)
                                  : const SizedBox(),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const Divider(thickness: 0.2),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selcetedIndex = "1";
                        Future.delayed(const Duration(seconds: 1), () {
                          // Get.back();\
                          // video == "video" ? getVideo(ImageSource.gallery) : imgFromGallery(ImageSource.gallery);
                          video == "video"
                              ? editCntrler.getVideo(context, ImageSource.gallery, PictureId, imgIndex)
                              : editCntrler.tappedOPtion(
                                  context,
                                  ImageSource.gallery,
                                  "1",
                                  PictureId,
                                  imgIndex);
                          selcetedIndex = "";
                        });
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildText(
                              "Choose from Gallery",
                              18,
                              selcetedIndex == "1"
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color.txtBlack),
                          CircleAvatar(
                            backgroundColor: selcetedIndex == "1"
                                ? color.txtBlue
                                : color.txtWhite,
                            radius: 9,
                            child: CircleAvatar(
                              radius: 8,
                              backgroundColor: selcetedIndex == "1"
                                  ? color.txtWhite
                                  : color.txtWhite,
                              // backgroundImage: SvgPicture.asset(AssetsPics.arrowLeft),
                              child: selcetedIndex == "1"
                                  ? SvgPicture.asset(AssetsPics.blueTickCheck,
                                      fit: BoxFit.cover)
                                  : const SizedBox(),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                // buildText("Choose from Gallery", 18, FontWeight.w500, color.txtBlack),
              ],
            );
          }),
        );
      },
    );
  }

  bool isDraggable = false;

  Widget onLongPressedd(String img) {
    return LongPressDraggable(
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: DraggingListItem(photoProvider: img),
        onDragStarted: () {
          setState(() {
            isDraggable = true;
          });
        },
        onDragEnd: (val) {
          setState(() {
            isDraggable = false;
          });
        },
        child: buildPhotoContainer(img));
  }

  Widget onDragTarget(String img) {
    return DragTarget(builder: (context, candidateItems, rejectedItems) {
      return buildPhotoContainer(img);
    });
  }

  Widget buildPhotoContainer(String img) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CachedNetworkImage(
        imageUrl: img,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => buildContainer(),
        placeholder: (ctx, url) => const Center(
            child: CircularProgressIndicator(color: color.txtBlue)),
      ),
    );
  }

  Widget buildVideoContainer(VideoPlayerController cntrl, Future<void> func,
      editProfileController val) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
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
                      Get.to(() => ProfileVideoViewer(url: cntrl.dataSource));
                      ;
                    },
                    child: SvgPicture.asset(AssetsPics.videoplayicon)))
          ],
        ));
  }

  Center buildCenterloader() => const Center(
          child: CircularProgressIndicator(
        color: color.txtBlue,
        strokeWidth: 1.5,
      ));

  Widget buildContainer() => Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color.txtgrey4,
        ),
        child: SvgPicture.asset(AssetsPics.gallerygrey, height: 35),
      );
}

class DraggingListItem extends StatelessWidget {
  const DraggingListItem({
    super.key,
    // required this.dragKey,
    required this.photoProvider,
  });

  // final GlobalKey dragKey;
  final String photoProvider;

  @override
  Widget build(BuildContext context) {
    return FractionalTranslation(
      translation: const Offset(-0.5, -0.5),
      child: ClipRRect(
        // key: dragKey,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 150,
          width: 150,
          child: Opacity(
            opacity: 0.85,
            child:
                CachedNetworkImage(imageUrl: photoProvider, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
