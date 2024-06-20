
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/loader.dart';
import 'package:slush/controller/edit_profile_controller.dart';
import 'package:slush/controller/profile_controller.dart';
import 'package:slush/screens/events/bottomNavigation.dart';
import 'package:slush/screens/profile/Intereset.dart';
import 'package:slush/screens/profile/basic_info/profile_video_view.dart';
import 'package:slush/screens/profile/edit_profile_basic_info.dart';
import 'package:slush/screens/profile/phoneNumber.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:slush/widgets/toaster.dart';
import 'package:video_player/video_player.dart';

import '../sign_up/details/video_trimmer.dart';
class BasicInfoclass{
  late int id;
  late String name;
  late String handler;
  BasicInfoclass(this.id,this.name,this.handler);
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController bioController =TextEditingController(text: LocaleHandler.dataa["bio"]??"");
  // List<BasicInfoclass> basicInfo=[
  //   BasicInfoclass(1, "Gender", LocaleHandler.gender),
  //   BasicInfoclass(2, "Height", "${LocaleHandler.dataa["height"]} cm"),
  //   BasicInfoclass(3, "Work", LocaleHandler.dataa["jobTitle"]??""),
  //   BasicInfoclass(4, "Education", ""),
  //   // BasicInfoclass(5, "Date of birth", "Add"),
  //   // BasicInfoclass(6, "Location", "Add"),
  //   BasicInfoclass(7, "Sexual Orientation", LocaleHandler.dataa["sexuality"]??""),
  //   BasicInfoclass(8, "Ethnicity", "${LocaleHandler.dataa["ethnicity"].length} items"),
  // ];

  // List<BasicInfoclass> moreaboutme = [//"Ideal vacation", "Cooking skill", "Smoking"
  //   BasicInfoclass(1, "Ideal vacation", LocaleHandler.ideal),
  //   BasicInfoclass(2, "Cooking skill", LocaleHandler.cookingSkill),
  //   BasicInfoclass(3, "Smoking", LocaleHandler.smokingopinion),
  // ];

  PageController pageController = PageController();
  int currentIndex = 0;
  int value = 0;
  String PictureId = "";
  List slidingImages = [AssetsPics.sample, AssetsPics.sample, AssetsPics.sample];
  bool itemDelted = false;

  // VideoPlayerController? _controller;
  // VideoPlayerController? _controller2;
  // VideoPlayerController? _controller3;
  VideoPlayerController? _controller4;
  // Future<void>? _initializeVideoPlayerFuture;
  // Future<void>? _initializeVideoPlayerFuture2;
  // Future<void>? _initializeVideoPlayerFuture2;
  // Future<void>? _initializeVideoPlayerFuture3;

  String selcetedIndex = "";
  String? imageBase64;


  // File? videoFile;
  final picker = ImagePicker();
  File? galleryFile;
  var imgdata;

  @override
  void initState() {
    profileData();

    // if (LocaleHandler.dataa["profileVideos"].length != 0) {
    //   _controller = VideoPlayerController.networkUrl(Uri.parse(LocaleHandler.dataa["profileVideos"][0]["key"]));
    //   _initializeVideoPlayerFuture = _controller!.initialize();
    // }
    // if (LocaleHandler.dataa["profileVideos"].length >= 2) {
    //   _controller2 = VideoPlayerController.networkUrl(Uri.parse(LocaleHandler.dataa["profileVideos"][1]["key"]));
    //   _initializeVideoPlayerFuture2 = _controller2!.initialize();
    // }
    // if (LocaleHandler.dataa["profileVideos"].length >= 3) {
    //   _controller3 = VideoPlayerController.networkUrl(Uri.parse(LocaleHandler.dataa["profileVideos"][2]["key"]));
    //   _initializeVideoPlayerFuture3 = _controller3!.initialize();
    // }
    // futuredelayed(1, true);
    // futuredelayed(3, false);
    super.initState();
  }

  // void futuredelayed(int i, bool val) {
  //   Future.delayed(Duration(seconds: i), () {
  //     setState(() {
  //       itemDelted = val;
  //     });
  //   });
  // }
  //
  //
  // Future getVideo(ImageSource img) async {
  //   const allowedTimeLimit = Duration(seconds: 16);
  //   Get.back();
  //   final pickedFile = await picker.pickVideo(
  //       source: img,
  //       preferredCameraDevice: CameraDevice.front,
  //       maxDuration: const Duration(seconds: 15));
  //   XFile? xfilePick = pickedFile;
  //   setState((){
  //     if (xfilePick != null) {
  //       galleryFile = File(pickedFile!.path);
  //       _controller4 = VideoPlayerController.networkUrl(Uri.parse(galleryFile!.path))..initialize().then((_) {
  //         setState(() {
  //           if(_controller4!.value.duration<=allowedTimeLimit){
  //             UploadVideo(galleryFile!);
  //           } else {
  //             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video should be less then 15 seconds')));}
  //         });});
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nothing is selected')));
  //     }
  //   });
  // }

  Future profileData() async {
    final url = ApiList.getUser + LocaleHandler.userId;
    print(url);
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${LocaleHandler.accessToken}'
      });
      if (response.statusCode == 200) {
        Provider.of<editProfileController>(context,listen: false).changevalue();
        Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          LocaleHandler.dataa = data["data"];
          Provider.of<editProfileController>(context,listen: false).videoValToCont();
          // if (LocaleHandler.dataa["profileVideos"].length != 0) {
          //   _controller = VideoPlayerController.networkUrl(Uri.parse(LocaleHandler.dataa["profileVideos"][0]["key"]),);
          //   _initializeVideoPlayerFuture = _controller!.initialize();
          // }
          // if (LocaleHandler.dataa["profileVideos"].length >= 2) {
          //   _controller2 = VideoPlayerController.networkUrl(Uri.parse(LocaleHandler.dataa["profileVideos"][1]["key"]),);
          //   _initializeVideoPlayerFuture2 = _controller2!.initialize();
          // }
          // if (LocaleHandler.dataa["profileVideos"].length >= 3) {
          //   _controller3 = VideoPlayerController.networkUrl(Uri.parse(LocaleHandler.dataa["profileVideos"][2]["key"]),);
          //   _initializeVideoPlayerFuture3 = _controller3!.initialize();
          // }
          snackBaar(context, AssetsPics.editBannerSvg,false);
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
      throw Exception('Failed to fetch data: $e');
    }
  }

  void saveDta() {
    LocaleHandler.gender= LocaleHandler.dataa["gender"];
    LocaleHandler.height= LocaleHandler.dataa["height"];
    if(LocaleHandler.dataa["jobTitle"]!=null){LocaleHandler.jobtitle= LocaleHandler.dataa["jobTitle"];}
    LocaleHandler.sexualOreintation= LocaleHandler.dataa["sexuality"];
    if(LocaleHandler.dataa["ideal_vacation"]!=null){ LocaleHandler.ideal= LocaleHandler.dataa["ideal_vacation"];}
    if(LocaleHandler.dataa["cooking_skill"]!=null){ LocaleHandler.cookingSkill= LocaleHandler.dataa["cooking_skill"];}
    if(LocaleHandler.dataa["smoking_opinion"]!=null){ LocaleHandler.smokingopinion= LocaleHandler.dataa["smoking_opinion"];}
    if (LocaleHandler.dataa["showOnProfile"] != null) {
      String text=LocaleHandler.dataa["showOnProfile"].toString().replaceAll(" ", "");
      splitted = text.split(',');
      if(splitted.contains("gender")){LocaleHandler.showgenders="true";}
      if(splitted.contains("height")){LocaleHandler.showheights="true";}
      if(splitted.contains("sexuality")){LocaleHandler.showsexualOreintations="true";}
    }

    if(LocaleHandler.dataa["ethnicity"]!=null){
      var i=0;
      for(i=0;i<LocaleHandler.dataa["ethnicity"].length;i++){
        LocaleHandler.entencity.add(LocaleHandler.dataa["ethnicity"][i]["id"]);
      }
    }
  }

  List splitted = [];


  // Future UploadVideo(File video) async {
  //   const url = ApiList.uploadVideo;
  //   var uri = Uri.parse(url);
  //   var request = http.MultipartRequest('POST', uri);
  //   request.headers['Authorization'] = "Bearer ${LocaleHandler.accessToken}";
  //   if (video != null) {
  //     // final mediaInfo = await VideoCompress.compressVideo(video.path, quality: VideoQuality.LowQuality);
  //     File introVideo = File(video.path);
  //     // File introVideo = mediaInfo!.path as File;
  //     var stream = http.ByteStream(introVideo.openRead());
  //     var length = await introVideo.length();
  //     var multipartFile2 = http.MultipartFile('files', stream, length, filename: video.toString().split("/").last,contentType: MediaType('video','mp4'));
  //     // var multipartFile2 = await http.MultipartFile.fromPath('files',video.toString(),filename: video.toString().split("/").last,contentType: MediaType('files','mp4'));
  //     request.files.add(multipartFile2);
  //   }
  //   var response = await request.send();
  //   final respStr = await response.stream.bytesToString();
  //   print(respStr);
  //   if (response.statusCode == 201) {
  //     profileData();
  //   } else if (response.statusCode == 401) {
  //     showToastMsgTokenExpired();
  //   } else {}
  // }

  // Future DestroyVideo(int id) async {
  //   const url = ApiList.destroyVideo;
  //   print(url);
  //   var uri = Uri.parse(url);
  //   var response = await http.post(uri,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         "Authorization": "Bearer ${LocaleHandler.accessToken}"
  //       },
  //       body: jsonEncode({"ids": [id]}));
  //   print(response.statusCode);
  //   if (response.statusCode == 201) {profileData();}
  //   else if (response.statusCode == 401) {showToastMsgTokenExpired();} else {}
  // }

  Future UpdateProfileDetail()async{
    const url=ApiList.updateProfileDetail;
    print(url);
    var uri=Uri.parse(url);
    var request = http.MultipartRequest('PATCH', uri,);
    request.headers['Authorization'] = "Bearer ${LocaleHandler.accessToken}";

    // if(dateOfBirth)
    // if(notifications)

    if(LocaleHandler.dataa["height"]!=LocaleHandler.height){
      request.fields['height'] = LocaleHandler.height;
      request.fields['height_unit'] = LocaleHandler.heighttype;
      // request.fields['display_height'] = LocaleHandler.showheights;
    }

    request.fields['display_height'] = LocaleHandler.showheights;
    request.fields['display_gender'] = LocaleHandler.showgenders;
    request.fields['display_orientation'] = LocaleHandler.showsexualOreintations;


    if(LocaleHandler.dataa["gender"]!=LocaleHandler.gender){
      request.fields['gender'] = LocaleHandler.gender;
      // request.fields['display_gender'] = LocaleHandler.showgenders;
      // request.fields['display_gender'] = "true";

    }

    if( LocaleHandler.dataa["sexuality"]!= LocaleHandler.sexualOreintation){
      request.fields['sexuality'] = LocaleHandler.sexualOreintation;
      // request.fields['display_orientation'] = LocaleHandler.showsexualOreintations;
    }

    if(LocaleHandler.dataa["jobTitle"]!=LocaleHandler.jobtitle&&LocaleHandler.dataa["jobTitle"]!=null){
      request.fields['jobTitle'] = LocaleHandler.jobtitle;
    }
    // if(firstName)
    // if(lastName)
    // if(country)
    // if(address)
    // if(latitude)
    // if(longitude)
    // if(lookingFor)

    if(bioController.text.trim()!=""){
      request.fields['bio'] = bioController.text.trim();
    }

    // if(LocaleHandler.dataa["ideal_vacation"]!= LocaleHandler.ideal &&LocaleHandler.dataa["ideal_vacation"]!=null){
    if(LocaleHandler.dataa["ideal_vacation"]!= LocaleHandler.ideal || LocaleHandler.dataa["ideal_vacation"]==null){
      request.fields['ideal_vacation'] = LocaleHandler.ideal.toString();
    }

    // if(LocaleHandler.dataa["cooking_skill"]!= LocaleHandler.cookingSkill &&LocaleHandler.dataa["cooking_skill"]!=null){
    if(LocaleHandler.dataa["cooking_skill"]!= LocaleHandler.cookingSkill || LocaleHandler.dataa["cooking_skill"]==null){
      request.fields['cooking_skill'] = LocaleHandler.cookingSkill.toString();
    }

    // if(LocaleHandler.dataa["smoking_opinion"]!= LocaleHandler.smokingopinion &&LocaleHandler.dataa["smoking_opinion"]!=null){
    if(LocaleHandler.dataa["smoking_opinion"]!= LocaleHandler.smokingopinion || LocaleHandler.dataa["smoking_opinion"]==null){
      request.fields['smoking_opinion'] = LocaleHandler.smokingopinion.toString();
    }

    var response = await request.send();
    print(response.statusCode);
    final respStr = await response.stream.bytesToString();
    print(respStr);
    if(response.statusCode==200){
      // Provider.of<profileController>(context,listen: false).profileData(context);
      showToastMsg("Updated succesfully");
      // setState(() {LocaleHandler.bottomindex=4;});
        // Get.offAll(()=>BottomNavigationScreen());
      // setState(() {LoaderOverlay.hide();});
      // Future.delayed(Duration(seconds: 2),(){Get.back();});
      // if(LocaleHandler.dataa["ethnicity"]!= LocaleHandler.entencity){
        updateEthnicity();
      // }
    }else if(response.statusCode==401){
      setState(() {LoaderOverlay.hide();});
      showToastMsgTokenExpired();}else{
      setState(() {LoaderOverlay.hide();});
      showToastMsg("failed to update!");
    }

  }

  Future updateEthnicity ()async{
    print(LocaleHandler.entencity);
    const url=ApiList.updateEthnicity;
    print(url);
    var uri=Uri.parse(url);
    var response=await http.patch(uri,
    headers: {'Content-Type': 'application/json',
    "Authorization": "Bearer ${LocaleHandler.accessToken}"},
        body: jsonEncode({"ethnicity": LocaleHandler.entencity}));
    if(response.statusCode==200){
      Provider.of<profileController>(context,listen: false).profileData(context);
      showToastMsg("Updated succesfully");
      // setState(() {LocaleHandler.bottomindex=4;});
      // Get.offAll(()=>BottomNavigationScreen());
      setState(() {LoaderOverlay.hide();});
      Future.delayed(Duration(seconds: 2),(){Get.back();});
    }
    else{
      Provider.of<profileController>(context,listen: false).profileData(context);

      setState(() {LoaderOverlay.hide();});
    Future.delayed(Duration(seconds: 2),(){Get.back();});}
  }

  bool trimerStart=false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: itemDelted ? null : commonBar(context, Colors.transparent),
      body: Stack(
        children: [
          SizedBox(height: size.height, width: size.width,
            child: Image.asset(AssetsPics.background, fit: BoxFit.cover),
          ),
          SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.h),
                      buildText("Edit Photo", 20, FontWeight.w600, color.txtBlack),
                      SizedBox(height: 1.h),
                      Consumer<editProfileController>(
                          builder: (context,val,child){
                        imgdata=val.fromprov?val.imagedata:LocaleHandler.dataa;
                        return buildphotos(size);}),
                      SizedBox(height: 2.h),
                      buildText("Edit Video", 20, FontWeight.w600, color.txtBlack),
                      SizedBox(height: 1.h),
                      Consumer<editProfileController>(
                          builder: (context,val,child){
                            imgdata=val.fromprov?val.imagedata:LocaleHandler.dataa;
                            return buildVideo(size);}),
                      // buildVideo(size),
                      SizedBox(height: 1.h + 5),
                      Center(
                          child: buildText("Hold and drag media to reorder", 16,
                              FontWeight.w500, color.txtgrey,
                              fontFamily: FontFamily.hellix))
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
                      buildText("My bio", 20, FontWeight.w600, color.txtBlack),
                      SizedBox(height: 1.h - 3),
                      buildText("Write a fun intro", 16, FontWeight.w500, color.txtBlack),
                      SizedBox(height: 1.h - 3),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(width: 1, color: color.lightestBlue),
                            borderRadius: BorderRadius.circular(14)),
                        child: TextFormField(
                          maxLines: 3,
                          controller:bioController ,
                          textCapitalization: TextCapitalization.words,
                          style: const TextStyle(
                              color: color.txtBlack,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: FontFamily.hellix),
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: color.textFieldColor),
                                  borderRadius: BorderRadius.circular(8)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: color.textFieldColor),
                                  borderRadius: BorderRadius.circular(8)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildText("Basic info", 20, FontWeight.w600, color.txtBlack),
                      SizedBox(height: 1.h - 5),
                      Consumer<editProfileController>(builder: (ctx,val,child){
                        return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: val.basicInfo.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 4, bottom: 4),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      LocaleHandler.basicInfo = true;
                                      LocaleHandler.EditProfile = true;
                                    });
                                    Get.to(() => EditProfileBasicInfoScreen(index: index))!.then((value){setState(() {});});
                                  },
                                  child: Container(color: Colors.transparent,
                                    child: Row(
                                      children: [
                                        buildText(val.basicInfo[index].name, 18,
                                            FontWeight.w500, color.txtgrey,
                                            fontFamily: FontFamily.hellix),
                                        const Spacer(),
                                        Consumer<editProfileController>(builder: (ctx,val,child){
                                          return buildText(val.basicInfo[index].handler==""?"Add":val.basicInfo[index].handler, 18, FontWeight.w500,
                                              color.txtgrey, fontFamily: FontFamily.hellix);
                                        }),
                                        // buildText(basicInfo[index].handler==""?"Add":basicInfo[index].handler, 18, FontWeight.w500,
                                        //     color.txtgrey, fontFamily: FontFamily.hellix),
                                        const SizedBox(width: 12),
                                        SvgPicture.asset(AssetsPics.rightArrow),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            });})
                    ],
                  ),
                ),
                buildDivider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildText("More about me", 20, FontWeight.w600, color.txtBlack),
                      SizedBox(height: 1.h - 5),
                     Consumer<editProfileController>(builder: (context,val,child){
                       return  ListView.builder(
                         shrinkWrap: true,
                         physics: const NeverScrollableScrollPhysics(),
                         itemCount: val.moreaboutme.length,
                         itemBuilder: (context, index) {
                           return GestureDetector(
                             onTap: () {
                               setState(() {
                                 LocaleHandler.basicInfo = false;
                                 LocaleHandler.EditProfile = true;

                               });
                               Get.to(() => EditProfileBasicInfoScreen(index: index));
                             },
                             child: Container(color: Colors.transparent,
                               padding: const EdgeInsets.only(top: 4, bottom: 4),
                               child: Row(
                                 children: [
                                   buildText(val.moreaboutme[index].name, 18,
                                       FontWeight.w500, color.txtgrey,
                                       fontFamily: FontFamily.hellix),
                                   const Spacer(),
                                   buildText(val.moreaboutme[index].handler==""?"Add":val.moreaboutme[index].handler, 16, FontWeight.w500,
                                       color.txtgrey,
                                       fontFamily: FontFamily.hellix),
                                   const SizedBox(width: 12),
                                   SvgPicture.asset(AssetsPics.rightArrow),
                                 ],
                               ),
                             ),
                           );
                         });}),
                    ],
                  ),
                ),
                buildDivider(),
                Padding(
                  padding:
                  const EdgeInsets.only(left: 15, right: 15, bottom: 5),
                  child: GestureDetector(
                    onTap: (){
                      Get.to(()=>const InterestListScreen())!.then((value)  {setState(() {});});},
                    child: Container(color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              buildText("My interest", 20, FontWeight.w600, color.txtBlack),
                              const Spacer(),
                              buildText(LocaleHandler.dataa["interests"].length==0?"Add":"${LocaleHandler.dataa["interests"].length} items", 18, FontWeight.w500, color.txtgrey,
                                  fontFamily: FontFamily.hellix),
                              const SizedBox(width: 12),
                              SvgPicture.asset(AssetsPics.rightArrow),
                            ],
                          ),
                          SizedBox(height: 1.h - 5),
                          Padding(
                            padding: const EdgeInsets.only(top: 2, bottom: 2),
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
                Padding(
                  padding:
                  const EdgeInsets.only(left: 15, right: 15, bottom: 100),
                  child: GestureDetector(
                    onTap: (){
                      // Get.to(()=>const ChangeEmailScreen());
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            buildText("Your email", 20, FontWeight.w600,
                                color.txtBlack),
                            const Spacer(),
                            // buildText(LocaleHandler.dataa["email"]==""?"Add":"Change", 18, FontWeight.w500, color.txtgrey, fontFamily: FontFamily.hellix),
                            const SizedBox(width: 12),
                            // SvgPicture.asset(AssetsPics.rightArrow),
                          ],
                        ),
                        SizedBox(height: 1.h - 5),
                        Padding(
                          padding: const EdgeInsets.only(top: 2, bottom: 2),
                          child: buildText(
                              LocaleHandler.dataa["email"]??'Provide your mobile number',
                              18,
                              FontWeight.w500,
                              color.txtgrey,
                              fontFamily: FontFamily.hellix),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            height: itemDelted ? 15.h : 0,
            duration: const Duration(milliseconds: 600),
            width: size.width,
            child: Image.asset(
              AssetsPics.editBanner,
              fit: BoxFit.fill,
            ),
          ),
        ],
      ),
      bottomSheet: Padding(
        padding:Platform.isIOS? const EdgeInsets.only(bottom: 23, left: 16, right: 16, top: 2)
            : const EdgeInsets.only(bottom: 10, left: 15, right: 15, top: 2),
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 30,
          height: 50.0,
          child: blue_button(context, "Update",press: (){
            FocusManager.instance.primaryFocus?.unfocus();
            // print(selectedTitle);
            setState(() {LoaderOverlay.show(context);});
            UpdateProfileDetail();
            // updateInterest();
          }),
        ),
      ),
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
      height: size.height*0.3,
      width: size.width,
      child: Row(
        children: [
          Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                      padding: const EdgeInsets.only(right: 4, bottom: 4),
                      child: imgdata["profileVideos"].length != 0  // ? buildVideoContainer(_controller!, _initializeVideoPlayerFuture!)
                      ? Consumer<editProfileController>(builder: (context,val,child) {
                        return val.controller==null ? SizedBox():
                        buildVideoContainer(val.controller!,val.initializeVideoPlayerFuture!);})
                          : buildContainer()),
                  Container(
                      padding: const EdgeInsets.only(right: 5, top: 5),
                      alignment: Alignment.topRight,
                      child: SvgPicture.asset(AssetsPics.zoomIcon, fit: BoxFit.cover)),
                  Positioned(
                    right: 0.10,
                    bottom: 0.0,
                    child: GestureDetector(
                      onLongPress: () {
                        if (imgdata["profileVideos"].length != 0) {
                          buildCustomDialogBoxWithtwobuttonfordeletePicture(0,"video");
                        }
                      },
                      onTap: () {
                        buildShowModalBottomSheet("video");
                      },
                      child: Container(
                          alignment: Alignment.bottomRight,
                          child: SvgPicture.asset(AssetsPics.profileEdit1, width: 35, height: 35)),
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
                      height:  size.height*0.3 / 2 - 2,
                      width: size.width / 2 - 75,
                      child: imgdata["profileVideos"].length >= 2
                          // ? buildVideoContainer(_controller2!, _initializeVideoPlayerFuture2!)
                      ?Consumer<editProfileController>(builder: (context,val,child){
                        return  val.controller2==null ? SizedBox(): buildVideoContainer(val.controller2!, val.initializeVideoPlayerFuture2!);})
                          : GestureDetector(onTap: () {buildShowModalBottomSheet("video");},
                          child: buildContainer())),
                  Positioned(
                    right: 0.0,
                    bottom: 0.0,
                    child: GestureDetector(
                      onLongPress: () {
                        if (imgdata["profileVideos"].length >= 2) {
                          buildCustomDialogBoxWithtwobuttonfordeletePicture(1,"video");
                        }
                      },

                      child: Container(
                          alignment: Alignment.bottomRight,
                          child: SvgPicture.asset(imgdata["profileVideos"].length >= 2?AssetsPics.profileEdit1:AssetsPics.addImage,
                              width: 35, height: 35)),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 2),
              Stack(
                children: [
                  Container(
                      padding: const EdgeInsets.only(right: 5, bottom: 5),
                      height:  size.height*0.3 / 2 - 2,
                      width: size.width / 2 - 75,
                      child: imgdata["profileVideos"].length >= 3
                          // ? buildVideoContainer(_controller3!, _initializeVideoPlayerFuture3!)
                      ? Consumer<editProfileController>(builder: (context,val,child){
                        return val.controller3==null ? SizedBox():
                        buildVideoContainer(val.controller3!, val.initializeVideoPlayerFuture3!);})
                          : GestureDetector(onTap: () {buildShowModalBottomSheet("video");},child: buildContainer())),
                  Positioned(
                    right: 0.0,
                    bottom: 0.0,
                    child: GestureDetector(
                      onLongPress: () {
                        if (imgdata["profileVideos"].length >= 3) {
                          buildCustomDialogBoxWithtwobuttonfordeletePicture(2,"video");
                        }},
                      child: Container(alignment: Alignment.bottomRight,
                          child: SvgPicture.asset(imgdata["profileVideos"].length >= 3?AssetsPics.profileEdit1:AssetsPics.addImage,)),
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

  Widget buildphotos(Size size) {
    final size=MediaQuery.of(context).size;
    List items=[];
    var i;
    for(i=0;i<=imgdata["profilePictures"].length-1;i++){
      items.add(imgdata["profilePictures"][i]["key"]);}
    return SizedBox(
      // color: Colors.red,
      height: size.height*0.3,
      width: size.width,
      child: Row(
        children: [
          Expanded(child: Stack(
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
                    height: size.height*0.3,
                    padding: const EdgeInsets.only(right: 4, bottom: 4),
                    child: imgdata["profilePictures"].length != 0 ?
                    // isDraggable==false?onLongPressedd(items[0]): onDragTarget(items[0])
                    buildPhotoContainer(items[0]) : buildContainer()
                ),
              ),
              Container(
                  padding: const EdgeInsets.only(right: 5, top: 5),
                  alignment: Alignment.topRight,
                  child: SvgPicture.asset(AssetsPics.zoomIcon, fit: BoxFit.cover)),
              Positioned(
                right: 0.10,
                bottom: 0.0,
                child: GestureDetector(
                  onLongPress: () {
                    if (imgdata["profilePictures"].length != 0) {
                      buildCustomDialogBoxWithtwobuttonfordeletePicture(0,"image");
                    }
                  },
                  onTap: () {
                    setState(() {
                      if (imgdata["profilePictures"].length != 0) {
                        PictureId = imgdata["profilePictures"][0]["profilePictureId"].toString();
                        buildShowModalBottomSheet("image");
                      }});
                  },
                  child: Container( alignment: Alignment.bottomRight,
                      child: SvgPicture.asset(AssetsPics.profileEdit1, width: 35, height: 35)),
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
                      height:size.height*0.3/ 2 - 2,
                      width: size.width / 2 - 75,
                      child: imgdata["profilePictures"].length >= 2
                          ? GestureDetector(
                          onTap: () {
                            pageController = PageController(initialPage: 1);
                            customSlidingImage(context, 1, imgdata["profilePictures"]);
                           /* customSlidingImage(
                                context: context,
                                title: 'Coming soon',
                                secontxt: " ",
                                heading: "Events specific to this category\ncoming soon",
                                btnTxt: "Ok",
                                imges: imgdata["profilePictures"],
                                img: imgdata["profilePictures"].length != 0 ? items[1] : null);*/
                          },child:  buildPhotoContainer(items[1])
                        // onLongPressedd(items[1])
                      )
                          : GestureDetector(
                          onTap: () {
                            setState(() {
                              PictureId = imgdata["profilePictures"].length >= 2 ? imgdata["profilePictures"][1]["profilePictureId"].toString() : "-1";
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
                          buildCustomDialogBoxWithtwobuttonfordeletePicture(1,"image");
                        }
                      },
                      onTap: () {
                        setState(() {
                          PictureId = imgdata["profilePictures"].length >= 2 ? imgdata["profilePictures"][1]["profilePictureId"].toString() : "-1";
                          buildShowModalBottomSheet("image");
                        });
                      },
                      child: Container(
                          alignment: Alignment.bottomRight,
                          child: SvgPicture.asset(imgdata["profilePictures"].length >= 2?AssetsPics.profileEdit1:AssetsPics.addImage, width: 35, height: 35)),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 2),
              Stack(
                children: [
                  Container(
                      padding: const EdgeInsets.only(right: 5, bottom: 5),
                      height:size.height*0.3/ 2 - 2,
                      width: size.width / 2 - 75,
                      child: imgdata["profilePictures"].length >= 3
                          ? GestureDetector(
                          onTap: () {
                            pageController = PageController(initialPage: 2);
                            customSlidingImage(context, 2, imgdata["profilePictures"]);
                            /*          customSlidingImage(
                                context: context,
                                title: 'Coming soon',
                                secontxt: " ",
                                heading: "Events specific to this category\ncoming soon",
                                btnTxt: "Ok",
                                imges: imgdata["profilePictures"],
                                img: imgdata["profilePictures"].length != 0 ? items[2] : null);*/
                          },child: buildPhotoContainer(items[2]))
                          : GestureDetector(
                          onTap: () {
                            setState(() {
                              PictureId = imgdata["profilePictures"].length >= 3 ? imgdata["profilePictures"][2]["profilePictureId"].toString() : "-1";
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
                          buildCustomDialogBoxWithtwobuttonfordeletePicture(2,"image");
                        }
                      },
                      onTap: () {
                        setState(() {
                          PictureId = imgdata["profilePictures"].length >= 3 ? imgdata["profilePictures"][2]["profilePictureId"].toString() : "-1";
                          buildShowModalBottomSheet("image");
                        });
                      },
                      child: Container(
                          alignment: Alignment.bottomRight,
                          child: SvgPicture.asset(imgdata["profilePictures"].length >= 3?AssetsPics.profileEdit1:AssetsPics.addImage)),
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

  buildCustomDialogBoxWithtwobuttonfordeletePicture(int i,String video) {
    final editCntrler=Provider.of<editProfileController>(context,listen: false);
    customDialogBoxWithtwobuttonfordeletePicture(
        context, video=="video"?"do you want delete video": "do you want delete picture",
        btnTxt1: "No", btnTxt2: "Yes, Delete", onTap2: () {
      Get.back();video=="video"?
      editCntrler.DestroyVideo(context,imgdata["profileVideos"][i]["profileVideoId"])
      : editCntrler.DestroyPicture(context, imgdata["profilePictures"][i]["profilePictureId"]);
    });
  }

  Future<void> buildShowModalBottomSheet(String video) {
    final editCntrler=Provider.of<editProfileController>(context,listen: false);
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.only(left: 16, right: 16, bottom: 3.h - 2),
          padding: const EdgeInsets.only(top: 25, bottom: 25),
          decoration: BoxDecoration(color: color.txtWhite, borderRadius: BorderRadius.circular(16)),
          width: MediaQuery.of(context).size.width,
          child: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
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
                        Future.delayed(const Duration(seconds: 1), () {
                          // Get.back();
                          // video == "video" ? getVideo(ImageSource.camera) : imgFromGallery(ImageSource.camera);
                          video == "video" ? editCntrler.getVideo(context,ImageSource.camera) : editCntrler.tappedOPtion(context, ImageSource.camera, "0", PictureId);
                          selcetedIndex = "";
                        });
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildText( video == "video"?"Take a Video":"Take a Selfie", 18,
                              selcetedIndex == "0" ? FontWeight.w600 : FontWeight.w500,
                              color.txtBlack),
                          CircleAvatar(
                            backgroundColor: selcetedIndex == "0" ? color.txtBlue : color.txtWhite,
                            radius: 9,
                            child: CircleAvatar(
                              radius: 8,
                              backgroundColor: selcetedIndex == "0" ? color.txtWhite : color.txtWhite,
                              // backgroundImage: SvgPicture.asset(AssetsPics.arrowLeft),
                              child: selcetedIndex == "0" ? SvgPicture.asset(AssetsPics.blueTickCheck, fit: BoxFit.cover)
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
                          // Get.back();
                          // video == "video" ? getVideo(ImageSource.gallery) : imgFromGallery(ImageSource.gallery);
                          video == "video" ? editCntrler.getVideo(context,ImageSource.gallery) : editCntrler.tappedOPtion(context, ImageSource.gallery, "1", PictureId);
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
                              selcetedIndex == "1" ? FontWeight.w600 : FontWeight.w500,
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
                                  ? SvgPicture.asset(
                                AssetsPics.blueTickCheck,
                                fit: BoxFit.cover,
                              )
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

  bool isDraggable=false;
  Widget onLongPressedd(String img){
  return  LongPressDraggable(
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: DraggingListItem(photoProvider: img),
    onDragStarted: (){setState(() {isDraggable=true;});},
    onDragEnd: (val){setState(() {isDraggable=false;});},
    child:buildPhotoContainer(img));
  }

  Widget onDragTarget(String img){
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
        placeholder: (ctx,url)=>const Center(child: CircularProgressIndicator(color: color.txtBlue,)),
      ),
    );
  }

  Widget buildVideoContainer(VideoPlayerController cntrl, Future<void> func) {
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
                      Provider.of<profileController>(context,listen: false).videoUrl = cntrl.dataSource;
                      Get.to(()=>ProfileVideoViewer());;
                    },
                    child: SvgPicture.asset(AssetsPics.videoplayicon)))
          ],
        ));
  }
/*  customSlidingImage(
      {required BuildContext context,
        String? btnTxt,
        String? img,
        List? imges,
        String? secontxt,
        required String title,
        required String heading,
        VoidCallback? onTapp = pressed,
        VoidCallback? onTap = pressed,
        bool? forAdvanceTap}) {
    currentIndex = 0;
    return showGeneralDialog(
      barrierLabel: "Label",
      transitionDuration: const Duration(milliseconds: 500),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return StatefulBuilder(builder: (context, setState) {
          return Scaffold(
            backgroundColor: Colors.black87,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                          onTap: onTapp,
                          child: SvgPicture.asset(AssetsPics.whiteCancel))),
                ),
                Container(
                    height: MediaQuery.of(context).size.height / 2,
                    width: MediaQuery.of(context).size.width,
                    // padding: EdgeInsets.only(right: 20,left: 20),
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: imges!.length,
                      onPageChanged: (indexx) {
                        setState(() {
                          currentIndex = indexx;
                          if (indexx == 0) {
                            value = 40;
                          } else if (indexx == 1) {
                            value = 70;
                          } else {
                            value = 100;
                          }
                        });
                        currentIndex = indexx;
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            // child: Image.network(imges[index]["key"]!, fit: BoxFit.cover)
                            child: CachedNetworkImage(
                              imageUrl: imges[index]["key"]!,
                              fit: BoxFit.cover,
                              placeholder: (context,url)=> const Center(child: CircularProgressIndicator(color: color.txtBlue)),
                            ));
                      },
                    )),
                // SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(imges.length, (int index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      width: currentIndex == index ? 15 : 12,
                      height: currentIndex == index ? 15 : 12,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: currentIndex == index ? Colors.white : Colors.transparent,
                        border: Border.all(
                          color: currentIndex == index ? Colors.blue : Colors.white,
                          width: currentIndex == index ? 3.4 : 1,
                        ),
                        //shape: BoxShape.circle,
                        // color: currentIndex == index ? Colors.blue : Colors.grey,
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        });
      },
    );
  }*/

  Widget buildContainer() => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: color.txtgrey4,
    ),
    child: const Icon(Icons.add),
  );
}


/*
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
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
import 'package:slush/screens/events/bottomNavigation.dart';
import 'package:slush/screens/profile/Intereset.dart';
import 'package:slush/screens/profile/change_email.dart';
import 'package:slush/screens/profile/edit_profile_basic_info.dart';
import 'package:slush/screens/profile/phoneNumber.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:slush/widgets/toaster.dart';
import 'package:video_player/video_player.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController bioController =TextEditingController(text: LocaleHandler.dataa["bio"]??"");
  List<BasicInfoclass> basicInfo=[
    BasicInfoclass(1, "Gender", LocaleHandler.gender),
    BasicInfoclass(2, "Height", "${LocaleHandler.dataa["height"]} cm"),
    BasicInfoclass(3, "Work", LocaleHandler.dataa["jobTitle"]??""),
    BasicInfoclass(4, "Education", ""),
    // BasicInfoclass(5, "Date of birth", "Add"),
    // BasicInfoclass(6, "Location", "Add"),
    BasicInfoclass(7, "Sexual Orientation", LocaleHandler.dataa["sexuality"]??""),
    BasicInfoclass(8, "Ethnicity", "${LocaleHandler.dataa["ethnicity"].length} items"),
  ];

  List<BasicInfoclass> moreaboutme = [//"Ideal vacation", "Cooking skill", "Smoking"
    BasicInfoclass(1, "Ideal vacation", LocaleHandler.ideal),
    BasicInfoclass(2, "Cooking skill", LocaleHandler.cookingSkill),
    BasicInfoclass(3, "Smoking", LocaleHandler.smokingopinion),
  ];

  PageController pageController = PageController();
  int currentIndex = 0;
  int value = 0;
  String PictureId = "";
  List slidingImages = [AssetsPics.sample, AssetsPics.sample, AssetsPics.sample];
  bool itemDelted = false;

  VideoPlayerController? _controller;
  VideoPlayerController? _controller2;
  VideoPlayerController? _controller3;
  VideoPlayerController? _controller4;
  Future<void>? _initializeVideoPlayerFuture;
  Future<void>? _initializeVideoPlayerFuture2;
  Future<void>? _initializeVideoPlayerFuture3;

  String selcetedIndex = "";
  String? imageBase64;
  File? _image;

  // File? videoFile;
  final picker = ImagePicker();
  File? galleryFile;

  @override
  void initState() {
    profileData();

    if (LocaleHandler.dataa["profileVideos"].length != 0) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(LocaleHandler.dataa["profileVideos"][0]["key"]),);
      _initializeVideoPlayerFuture = _controller!.initialize();
    }
    if (LocaleHandler.dataa["profileVideos"].length >= 2) {
      _controller2 = VideoPlayerController.networkUrl(Uri.parse(LocaleHandler.dataa["profileVideos"][1]["key"]),);
      _initializeVideoPlayerFuture2 = _controller2!.initialize();
    }
    if (LocaleHandler.dataa["profileVideos"].length >= 3) {
      _controller3 = VideoPlayerController.networkUrl(Uri.parse(LocaleHandler.dataa["profileVideos"][2]["key"]),);
      _initializeVideoPlayerFuture3 = _controller3!.initialize();
    }
    futuredelayed(1, true);
    futuredelayed(3, false);

    super.initState();
  }

  void futuredelayed(int i, bool val) {
    Future.delayed(Duration(seconds: i), () {
      setState(() {
        itemDelted = val;
      });
    });
  }

  Future getVideo(ImageSource img) async {
    const allowedTimeLimit = Duration(seconds: 16);
    Get.back();
    final pickedFile = await picker.pickVideo(
        source: img,
        preferredCameraDevice: CameraDevice.front,
        maxDuration: const Duration(seconds: 15));
    XFile? xfilePick = pickedFile;
    setState(()async {
      if (xfilePick != null) {
        galleryFile = File(pickedFile!.path);
        _controller4 = VideoPlayerController.networkUrl(Uri.parse(galleryFile!.path))..initialize().then((_) {
          setState(() {
            if(_controller4!.value.duration<=allowedTimeLimit){
              UploadVideo(galleryFile!);
            }else{
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video should be less then 15 seconds')));}
          });});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nothing is selected')));
      }
    });
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
        Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          LocaleHandler.dataa = data["data"];
          if (LocaleHandler.dataa["profileVideos"].length != 0) {
            _controller = VideoPlayerController.networkUrl(Uri.parse(LocaleHandler.dataa["profileVideos"][0]["key"]),);
            _initializeVideoPlayerFuture = _controller!.initialize();
          }
          if (LocaleHandler.dataa["profileVideos"].length >= 2) {
            _controller2 = VideoPlayerController.networkUrl(Uri.parse(LocaleHandler.dataa["profileVideos"][1]["key"]),);
            _initializeVideoPlayerFuture2 = _controller2!.initialize();
          }
          if (LocaleHandler.dataa["profileVideos"].length >= 3) {
            _controller3 = VideoPlayerController.networkUrl(Uri.parse(LocaleHandler.dataa["profileVideos"][2]["key"]),);
            _initializeVideoPlayerFuture3 = _controller3!.initialize();
          }
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
      throw Exception('Failed to fetch data: $e');
    }
  }

  void saveDta(){
    LocaleHandler.gender= LocaleHandler.dataa["gender"];
    LocaleHandler.height= LocaleHandler.dataa["height"];
    if(LocaleHandler.dataa["jobTitle"]!=null){LocaleHandler.jobtitle= LocaleHandler.dataa["jobTitle"];}
    LocaleHandler.sexualOreintation= LocaleHandler.dataa["sexuality"];
    if(LocaleHandler.dataa["ideal_vacation"]!=null){ LocaleHandler.ideal= LocaleHandler.dataa["ideal_vacation"];}
    if(LocaleHandler.dataa["cooking_skill"]!=null){ LocaleHandler.cookingSkill= LocaleHandler.dataa["cooking_skill"];}
    if(LocaleHandler.dataa["smoking_opinion"]!=null){ LocaleHandler.smokingopinion= LocaleHandler.dataa["smoking_opinion"];}
    if (LocaleHandler.dataa["showOnProfile"] != null) {
      String text=LocaleHandler.dataa["showOnProfile"].toString().replaceAll(" ", "");
      splitted = text.split(',');
      if(splitted.contains("gender")){LocaleHandler.showgenders="true";}
      if(splitted.contains("height")){LocaleHandler.showheights="true";}
      if(splitted.contains("sexuality")){LocaleHandler.showsexualOreintations="true";}
    }

    if(LocaleHandler.dataa["ethnicity"]!=null){
      var i=0;
      for(i=0;i<LocaleHandler.dataa["ethnicity"].length;i++){
        LocaleHandler.entencity.add(LocaleHandler.dataa["ethnicity"][i]["id"]);
      }
    }
  }

  List splitted = [];
  Future DestroyPicture(int id) async {
    const url = ApiList.destroyPicture;
    print(url);
    var uri = Uri.parse(url);
    var response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${LocaleHandler.accessToken}"
        },
        body: jsonEncode({
          "ids": [id]
        }));
    print(response.statusCode);
    if (response.statusCode == 201) {
      profileData();
    } else if (response.statusCode == 401) {
      showToastMsgTokenExpired();
    } else {}
  }

  Future UploadVideo(File video) async {
    const url = ApiList.uploadVideo;
    var uri = Uri.parse(url);
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = "Bearer ${LocaleHandler.accessToken}";
    if (video != null) {
      File introVideo = File(video!.path);
      var stream = http.ByteStream(introVideo.openRead());
      var length = await introVideo.length();
      var multipartFile2 = http.MultipartFile('files', stream, length,
          filename: video.toString().split("/").last);
      request.files.add(multipartFile2);
    }
    var response = await request.send();
    if (response.statusCode == 201) {
      profileData();
    } else if (response.statusCode == 401) {
      showToastMsgTokenExpired();
    } else {}
  }

  Future DestroyVideo(int id) async {
    const url = ApiList.destroyVideo;
    print(url);
    var uri = Uri.parse(url);
    var response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${LocaleHandler.accessToken}"
        },
        body: jsonEncode({"ids": [id]}));
    print(response.statusCode);
    if (response.statusCode == 201) {profileData();}
    else if (response.statusCode == 401) {showToastMsgTokenExpired();} else {}
  }

  Future UpdateProfileDetail()async{
    const url=ApiList.updateProfileDetail;
    print(url);
    var uri=Uri.parse(url);
    var request = http.MultipartRequest('PATCH', uri,);
    request.headers['Authorization'] = "Bearer ${LocaleHandler.accessToken}";

    // if(dateOfBirth)
    // if(notifications)

    if(LocaleHandler.dataa["height"]!=LocaleHandler.height){
      request.fields['height'] = LocaleHandler.height;
      request.fields['height_unit'] = LocaleHandler.heighttype;
      // request.fields['display_height'] = LocaleHandler.showheights;
    }

    request.fields['display_height'] = LocaleHandler.showheights;
    request.fields['display_gender'] = LocaleHandler.showgenders;
    request.fields['display_orientation'] = LocaleHandler.showsexualOreintations;


    if(LocaleHandler.dataa["gender"]!=LocaleHandler.gender){
      request.fields['gender'] = LocaleHandler.gender;
      // request.fields['display_gender'] = LocaleHandler.showgenders;
      // request.fields['display_gender'] = "true";

    }

    if( LocaleHandler.dataa["sexuality"]!= LocaleHandler.sexualOreintation){
      request.fields['sexuality'] = LocaleHandler.sexualOreintation;
      // request.fields['display_orientation'] = LocaleHandler.showsexualOreintations;
    }

    if(LocaleHandler.dataa["jobTitle"]!=LocaleHandler.jobtitle&&LocaleHandler.dataa["jobTitle"]!=null){
      request.fields['jobTitle'] = LocaleHandler.jobtitle;
    }
    // if(firstName)
    // if(lastName)
    // if(country)
    // if(address)
    // if(latitude)
    // if(longitude)
    // if(lookingFor)

    if(bioController.text.trim()!=""){
      request.fields['bio'] = bioController.text.trim();
    }

    // if(LocaleHandler.dataa["ideal_vacation"]!= LocaleHandler.ideal &&LocaleHandler.dataa["ideal_vacation"]!=null){
    if(LocaleHandler.dataa["ideal_vacation"]!= LocaleHandler.ideal || LocaleHandler.dataa["ideal_vacation"]==null){
      request.fields['ideal_vacation'] = LocaleHandler.ideal.toString();
    }

    // if(LocaleHandler.dataa["cooking_skill"]!= LocaleHandler.cookingSkill &&LocaleHandler.dataa["cooking_skill"]!=null){
    if(LocaleHandler.dataa["cooking_skill"]!= LocaleHandler.cookingSkill || LocaleHandler.dataa["cooking_skill"]==null){
      request.fields['cooking_skill'] = LocaleHandler.cookingSkill.toString();
    }

    // if(LocaleHandler.dataa["smoking_opinion"]!= LocaleHandler.smokingopinion &&LocaleHandler.dataa["smoking_opinion"]!=null){
    if(LocaleHandler.dataa["smoking_opinion"]!= LocaleHandler.smokingopinion || LocaleHandler.dataa["smoking_opinion"]==null){
      request.fields['smoking_opinion'] = LocaleHandler.smokingopinion.toString();
    }

    var response = await request.send();
    print(response.statusCode);
    setState(() {LoaderOverlay.hide();});
    final respStr = await response.stream.bytesToString();
    print(respStr);
    if(response.statusCode==200){
      showToastMsg("Updated succesfully");
      setState(() {LocaleHandler.bottomindex=4;});
      Get.offAll(()=>BottomNavigationScreen());
      if(LocaleHandler.dataa["ethnicity"]!= LocaleHandler.entencity){
        updateEthnicity();
      }
    }else if(response.statusCode==401){showToastMsgTokenExpired();}else{
      showToastMsg("failed to update!");
    }

  }

  Future updateEthnicity ()async{
    const url=ApiList.updateEthnicity;
    print(url);
    var uri=Uri.parse(url);
    var response=await http.patch(uri,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${LocaleHandler.accessToken}"
        },
        body: jsonEncode({"ethnicity": LocaleHandler.entencity}));
    if(response.statusCode==200){}
  }

  @override
  Widget build(BuildContext context) {
    final cntrler=Provider.of<editProfileController>(context,listen: false);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: itemDelted ? null : commonBar(context, Colors.transparent),
      body: Stack(
        children: [
          SizedBox(height: size.height, width: size.width,
            child: Image.asset(AssetsPics.background, fit: BoxFit.cover),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.h),
                      buildText("Edit Photo", 20, FontWeight.w600, color.txtBlack),
                      SizedBox(height: 1.h),
                      buildphotos(size),
                      SizedBox(height: 2.h),
                      buildText("Edit Video", 20, FontWeight.w600, color.txtBlack),
                      SizedBox(height: 1.h),
                      buildVideo(size),
                      SizedBox(height: 1.h + 5),
                      Center(
                          child: buildText("Hold and drag media to reorder", 16,
                              FontWeight.w500, color.txtgrey,
                              fontFamily: FontFamily.hellix))
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
                      buildText("My bio", 20, FontWeight.w600, color.txtBlack),
                      SizedBox(height: 1.h - 3),
                      buildText("Write a fun intro", 16, FontWeight.w500, color.txtBlack),
                      SizedBox(height: 1.h - 3),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(width: 1, color: color.lightestBlue),
                            borderRadius: BorderRadius.circular(14)),
                        child: TextFormField(
                          maxLines: 3,
                          controller:bioController ,
                          style: const TextStyle(
                              color: color.txtBlack,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: FontFamily.hellix),
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: color.textFieldColor),
                                  borderRadius: BorderRadius.circular(8)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: color.textFieldColor),
                                  borderRadius: BorderRadius.circular(8)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildText("Basic info", 20, FontWeight.w600, color.txtBlack),
                      SizedBox(height: 1.h - 5),
                      ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: basicInfo.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 4, bottom: 4),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    LocaleHandler.basicInfo = true;
                                    LocaleHandler.EditProfile = true;
                                  });
                                  Get.to(() => EditProfileBasicInfoScreen(index: index));
                                },
                                child: Row(
                                  children: [
                                    buildText(basicInfo[index].name, 18,
                                        FontWeight.w500, color.txtgrey,
                                        fontFamily: FontFamily.hellix),
                                    const Spacer(),
                                    buildText(basicInfo[index].handler==""?"Add":basicInfo[index].handler, 18, FontWeight.w500,
                                        color.txtgrey,
                                        fontFamily: FontFamily.hellix),
                                    const SizedBox(width: 12),
                                    SvgPicture.asset(AssetsPics.rightArrow),
                                  ],
                                ),
                              ),
                            );
                          }),
                    ],
                  ),
                ),
                buildDivider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildText("More about me", 20, FontWeight.w600, color.txtBlack),
                      SizedBox(height: 1.h - 5),
                      ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: moreaboutme.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  LocaleHandler.basicInfo = false;
                                  LocaleHandler.EditProfile = true;

                                });
                                Get.to(() => EditProfileBasicInfoScreen(index: index));
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4, bottom: 4),
                                child: Row(
                                  children: [
                                    buildText(moreaboutme[index].name, 18,
                                        FontWeight.w500, color.txtgrey,
                                        fontFamily: FontFamily.hellix),
                                    const Spacer(),
                                    buildText(moreaboutme[index].handler==""?"Add":moreaboutme[index].handler, 16, FontWeight.w500,
                                        color.txtgrey,
                                        fontFamily: FontFamily.hellix),
                                    const SizedBox(width: 12),
                                    SvgPicture.asset(AssetsPics.rightArrow),
                                  ],
                                ),
                              ),
                            );
                          }),
                    ],
                  ),
                ),
                buildDivider(),
                Padding(
                  padding:
                  const EdgeInsets.only(left: 15, right: 15, bottom: 5),
                  child: GestureDetector(
                    onTap: (){Get.to(()=>const InterestListScreen());},
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            buildText("My interest", 20, FontWeight.w600,
                                color.txtBlack),
                            const Spacer(),
                            buildText(LocaleHandler.dataa["interests"].length==0?"Add":"${LocaleHandler.dataa["interests"].length} items", 18, FontWeight.w500, color.txtgrey,
                                fontFamily: FontFamily.hellix),
                            const SizedBox(width: 12),
                            SvgPicture.asset(AssetsPics.rightArrow),
                          ],
                        ),
                        SizedBox(height: 1.h - 5),
                        Padding(
                          padding: const EdgeInsets.only(top: 2, bottom: 2),
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
                buildDivider(),
                Padding(
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
                            buildText("Add", 18, FontWeight.w500, color.txtgrey,
                                fontFamily: FontFamily.hellix),
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
                ),
                buildDivider(),
                Padding(
                  padding:
                  const EdgeInsets.only(left: 15, right: 15, bottom: 100),
                  child: GestureDetector(
                    onTap: (){
                      Get.to(()=>const ChangeEmailScreen());
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            buildText("Change email", 20, FontWeight.w600,
                                color.txtBlack),
                            const Spacer(),
                            buildText(LocaleHandler.dataa["email"]==""?"Add":"Change", 18, FontWeight.w500, color.txtgrey,
                                fontFamily: FontFamily.hellix),
                            const SizedBox(width: 12),
                            SvgPicture.asset(AssetsPics.rightArrow),
                          ],
                        ),
                        SizedBox(height: 1.h - 5),
                        Padding(
                          padding: const EdgeInsets.only(top: 2, bottom: 2),
                          child: buildText(
                              LocaleHandler.dataa["email"]??'Provide your mobile number',
                              18,
                              FontWeight.w500,
                              color.txtgrey,
                              fontFamily: FontFamily.hellix),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            height: itemDelted ? 15.h : 0,
            duration: const Duration(milliseconds: 600),
            width: size.width,
            child: Image.asset(
              AssetsPics.editBanner,
              fit: BoxFit.fill,
            ),
          ),
        ],
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 15, right: 15, top: 2),
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 30,
          height: 50.0,
          child: blue_button(context, "Update",press: (){
            FocusManager.instance.primaryFocus?.unfocus();
            // print(selectedTitle);
            setState(() {LoaderOverlay.show(context);});
            UpdateProfileDetail();
            // updateInterest();
          }),
        ),
      ),
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
      height: 230,
      width: size.width,
      child: Row(
        children: [
          // Expanded(
          //   child: DragAndDropLists(
          //   children: _contents,
          //   onItemReorder: _onItemReorder,
          //   onListReorder: _onListReorder),
          // ),
          Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                      padding: const EdgeInsets.only(right: 4, bottom: 4),
                      child: LocaleHandler.dataa["profileVideos"].length != 0
                          ? buildVideoContainer(_controller!, _initializeVideoPlayerFuture!)
                          : buildContainer()),
                  Container(
                      padding: const EdgeInsets.only(right: 5, top: 5),
                      alignment: Alignment.topRight,
                      child: SvgPicture.asset(AssetsPics.zoomIcon, fit: BoxFit.cover)),
                  Positioned(
                    right: 0.10,
                    bottom: 0.0,
                    child: GestureDetector(
                      onLongPress: () {
                        if (LocaleHandler.dataa["profileVideos"].length != 0) {
                          buildCustomDialogBoxWithtwobuttonfordeletePicture(0,"video");
                        }
                      },
                      onTap: () {
                        buildShowModalBottomSheet("video",editProfileController());
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
                      height: 230 / 2 - 2,
                      width: size.width / 2 - 75,
                      child: LocaleHandler.dataa["profileVideos"].length >= 2
                          ? buildVideoContainer(_controller2!, _initializeVideoPlayerFuture2!)
                          : buildContainer()),
                  Positioned(
                    right: 0.0,
                    bottom: 0.0,
                    child: GestureDetector(
                      onLongPress: () {
                        if (LocaleHandler.dataa["profileVideos"].length >= 2) {
                          buildCustomDialogBoxWithtwobuttonfordeletePicture(1,"video");
                        }
                      },
                      onTap: () {
                        buildShowModalBottomSheet("video",editProfileController());
                      },
                      child: Container(
                          alignment: Alignment.bottomRight,
                          child: SvgPicture.asset(LocaleHandler.dataa["profileVideos"].length >= 2?AssetsPics.profileEdit1:AssetsPics.addImage,
                              width: 35, height: 35)),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 2),
              Stack(
                children: [
                  Container(
                      padding: const EdgeInsets.only(right: 5, bottom: 5),
                      height: 230 / 2 - 2,
                      width: size.width / 2 - 75,
                      child: LocaleHandler.dataa["profileVideos"].length >= 3
                          ? buildVideoContainer(_controller3!, _initializeVideoPlayerFuture3!)
                          : buildContainer()),
                  Positioned(
                    right: 0.0,
                    bottom: 0.0,
                    child: GestureDetector(
                      onLongPress: () {
                        if (LocaleHandler.dataa["profileVideos"].length >= 3) {
                          buildCustomDialogBoxWithtwobuttonfordeletePicture(2,"video");
                        }
                      },
                      onTap: () {
                        buildShowModalBottomSheet("video",editProfileController());
                      },
                      child: Container(
                          alignment: Alignment.bottomRight,
                          child: SvgPicture.asset(LocaleHandler.dataa["profileVideos"].length >= 3?AssetsPics.profileEdit1:AssetsPics.addImage,)),
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

  Widget buildphotos(Size size) {
    List items=[];
    var i;
    for( i=0;i<=LocaleHandler.dataa["profilePictures"].length-1;i++){
      items.add(LocaleHandler.dataa["profilePictures"][i]["key"]);
    }
    return SizedBox(
      // color: Colors.red,
      height: 230,
      width: size.width,
      child: Row(
        children: [
          Expanded(child: Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                onTap: () {
                  customSlidingImage(
                      context: context,
                      title: 'Coming soon',
                      secontxt: "",
                      heading: "Events specific to this category\ncoming soon",
                      btnTxt: "Ok",
                      imges: LocaleHandler.dataa["profilePictures"],
                      img: LocaleHandler.dataa["profilePictures"].length != 0 ? LocaleHandler.dataa["profilePictures"][0]["key"] : null);
                },
                child: Container(padding: const EdgeInsets.only(right: 4, bottom: 4),
                    child: LocaleHandler.dataa["profilePictures"].length != 0 ?
                    // isDraggable==false?onLongPressedd(items[0]): onDragTarget(items[0])
                    buildPhotoContainer(items[0])
                  : buildContainer()
                ),
              ),
              Container(
                  padding: const EdgeInsets.only(right: 5, top: 5),
                  alignment: Alignment.topRight,
                  child: SvgPicture.asset(AssetsPics.zoomIcon, fit: BoxFit.cover)),
              Positioned(
                right: 0.10,
                bottom: 0.0,
                child: GestureDetector(
                  onLongPress: () {
                    if (LocaleHandler.dataa["profilePictures"].length != 0) {
                      buildCustomDialogBoxWithtwobuttonfordeletePicture(0,"image");
                    }
                  },
                  onTap: () {
                    setState(() {
                      if (LocaleHandler.dataa["profilePictures"].length != 0) {
                        PictureId = LocaleHandler.dataa["profilePictures"][0]["profilePictureId"].toString();
                        buildShowModalBottomSheet("image",editProfileController());
                      }});
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
                      height: 230 / 2 - 2,
                      width: size.width / 2 - 75,
                      child: LocaleHandler.dataa["profilePictures"].length >= 2
                          ? GestureDetector(
                          onTap: () {
                            customSlidingImage(
                                context: context,
                                title: 'Coming soon',
                                secontxt: "",
                                heading: "Events specific to this category\ncoming soon",
                                btnTxt: "Ok",
                                imges: LocaleHandler.dataa["profilePictures"],
                                img: LocaleHandler.dataa["profilePictures"].length != 0 ? items[1] : null);
                          },child:  buildPhotoContainer(items[1])
                      // onLongPressedd(items[1])
                      )
                          : buildContainer()),
                  Positioned(
                    right: 0.0,
                    bottom: 0.0,
                    child: GestureDetector(
                      onLongPress: () {
                        if (LocaleHandler.dataa["profilePictures"].length >= 2) {
                          buildCustomDialogBoxWithtwobuttonfordeletePicture(1,"image");
                        }
                      },
                      onTap: () {
                        setState(() {
                          PictureId = LocaleHandler.dataa["profilePictures"].length >= 2 ? LocaleHandler.dataa["profilePictures"][1]["profilePictureId"].toString() : "-1";
                          buildShowModalBottomSheet("image",editProfileController());
                        });
                      },
                      child: Container(
                          alignment: Alignment.bottomRight,
                          child: SvgPicture.asset(LocaleHandler.dataa["profilePictures"].length >= 2?AssetsPics.profileEdit1:AssetsPics.addImage, width: 35, height: 35)),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 2),
              Stack(
                children: [
                  Container(
                      padding: const EdgeInsets.only(right: 5, bottom: 5),
                      height: 230 / 2 - 2,
                      width: size.width / 2 - 75,
                      child: LocaleHandler.dataa["profilePictures"].length >= 3
                          ? GestureDetector(
                          onTap: () {
                            customSlidingImage(
                                context: context,
                                title: 'Coming soon',
                                secontxt: "",
                                heading: "Events specific to this category\ncoming soon",
                                btnTxt: "Ok",
                                imges: LocaleHandler.dataa["profilePictures"],
                                img: LocaleHandler.dataa["profilePictures"].length != 0 ? items[2] : null);
                          },child: buildPhotoContainer(items[2]))
                          : buildContainer()),
                  Positioned(
                    right: 0.0,
                    bottom: 0.0,
                    child: GestureDetector(
                      onLongPress: () {
                        if (LocaleHandler.dataa["profilePictures"].length >= 3) {
                          buildCustomDialogBoxWithtwobuttonfordeletePicture(2,"image");
                        }
                      },
                      onTap: () {
                        setState(() {
                          PictureId =
                          LocaleHandler.dataa["profilePictures"].length >= 3
                              ? LocaleHandler.dataa["profilePictures"][2]["profilePictureId"].toString()
                              : "-1";
                          buildShowModalBottomSheet("image",editProfileController());
                        });
                        // DestroyPicture()
                      },
                      child: Container(
                          alignment: Alignment.bottomRight,
                          child: SvgPicture.asset(LocaleHandler.dataa["profilePictures"].length >= 3?AssetsPics.profileEdit1:AssetsPics.addImage)),
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
  buildCustomDialogBoxWithtwobuttonfordeletePicture(int i,String video) {
    customDialogBoxWithtwobuttonfordeletePicture(
        context, "do you want delete picture",
        btnTxt1: "No", btnTxt2: "Yes, Delete", onTap2: () {
      Get.back();
      video=="video"?
      DestroyVideo(LocaleHandler.dataa["profileVideos"][i]["profileVideoId"])
          : DestroyPicture(LocaleHandler.dataa["profilePictures"][i]["profilePictureId"]);
    });
  }

  Future<void> buildShowModalBottomSheet(String video,editProfileController cntrler) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.only(left: 16, right: 16, bottom: 3.h - 2),
          padding: const EdgeInsets.only(top: 25, bottom: 25),
          decoration: BoxDecoration(color: color.txtWhite, borderRadius: BorderRadius.circular(16)),
          width: MediaQuery.of(context).size.width,
          child: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
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
                        Future.delayed(const Duration(seconds: 1), () {
                          video == "video" ? getVideo(ImageSource.camera) : cntrler.tappedOPtion(context,ImageSource.camera,selcetedIndex,PictureId);
                          selcetedIndex = "";
                        });
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildText( video == "video"?"Take a Video":"Take a Selfie", 18,
                            selcetedIndex == "0" ? FontWeight.w600 : FontWeight.w500,
                            color.txtBlack),
                        CircleAvatar(
                          backgroundColor: selcetedIndex == "0" ? color.txtBlue : color.txtWhite,
                          radius: 9,
                          child: CircleAvatar(
                            radius: 8,
                            backgroundColor: selcetedIndex == "0" ? color.txtWhite : color.txtWhite,
                            // backgroundImage: SvgPicture.asset(AssetsPics.arrowLeft),
                            child: selcetedIndex == "0" ? SvgPicture.asset(AssetsPics.blueTickCheck, fit: BoxFit.cover)
                                : const SizedBox(),
                          ),
                        )
                      ],
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
                          video == "video"
                              ? getVideo(ImageSource.gallery)
                              : cntrler.tappedOPtion(context,ImageSource.gallery,selcetedIndex,PictureId);
                          selcetedIndex = "";
                        });
                      });
                    },
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
                                ? SvgPicture.asset(
                              AssetsPics.blueTickCheck,
                              fit: BoxFit.cover,
                            )
                                : const SizedBox(),
                          ),
                        )
                      ],
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

  bool isDraggable=false;
  Widget onLongPressedd(String img){
  return  LongPressDraggable(
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: DraggingListItem(photoProvider: img),
    onDragStarted: (){setState(() {isDraggable=true;});},
    onDragEnd: (val){setState(() {isDraggable=false;});},
    child:buildPhotoContainer(img));
  }

  Widget onDragTarget(String img){
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
        errorWidget: (context, url, error) => const Icon(Icons.error),
        placeholder: (ctx,url)=>const Center(child: CircularProgressIndicator(color: color.txtBlue,)),
      ),
    );
  }

  Widget buildVideoContainer(VideoPlayerController cntrl, Future<void> func) {
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
                      cntrl.play();
                    },
                    child: SvgPicture.asset(AssetsPics.videoplayicon)))
          ],
        ));
  }

  customSlidingImage(
      {required BuildContext context,
        String? btnTxt,
        String? img,
        List? imges,
        String? secontxt,
        required String title,
        required String heading,
        VoidCallback? onTapp = pressed,
        VoidCallback? onTap = pressed,
        bool? forAdvanceTap}) {
    currentIndex = 0;
    return showGeneralDialog(
      barrierLabel: "Label",
      transitionDuration: const Duration(milliseconds: 500),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return StatefulBuilder(builder: (context, setState) {
          return Scaffold(
            backgroundColor: Colors.black87,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                          onTap: onTapp,
                          child: SvgPicture.asset(AssetsPics.whiteCancel))),
                ),
                Container(
                    height: MediaQuery.of(context).size.height / 2,
                    width: MediaQuery.of(context).size.width,
                    // padding: EdgeInsets.only(right: 20,left: 20),
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: imges!.length,
                      onPageChanged: (indexx) {
                        setState(() {
                          currentIndex = indexx;
                          if (indexx == 0) {
                            value = 40;
                          } else if (indexx == 1) {
                            value = 70;
                          } else {
                            value = 100;
                          }
                        });
                        currentIndex = indexx;
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            // child: Image.network(imges[index]["key"]!, fit: BoxFit.cover)
                            child: CachedNetworkImage(
                              imageUrl: imges[index]["key"]!,
                              fit: BoxFit.cover,
                              placeholder: (context,url)=> const Center(child: CircularProgressIndicator(color: color.txtBlue)),
                            ));
                      },
                    )),
                // SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(imges.length, (int index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      width: currentIndex == index ? 15 : 12,
                      height: currentIndex == index ? 15 : 12,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: currentIndex == index ? Colors.white : Colors.transparent,
                        border: Border.all(
                          color: currentIndex == index ? Colors.blue : Colors.white,
                          width: currentIndex == index ? 3.4 : 1,
                        ),
                        //shape: BoxShape.circle,
                        // color: currentIndex == index ? Colors.blue : Colors.grey,
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget buildContainer() => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: color.txtgrey4,
    ),
    child: const Icon(Icons.add),
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
            child: CachedNetworkImage( imageUrl: photoProvider, fit: BoxFit.cover,),
          ),
        ),
      ),
    );
  }
}*/
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
            child: CachedNetworkImage(imageUrl: photoProvider, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}