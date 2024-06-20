import 'dart:io';
import 'package:camera/camera.dart';
import 'package:http/http.dart'as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/localkeys.dart';
import 'package:slush/constants/prefs.dart';
import 'package:slush/controller/edit_profile_controller.dart';
import 'package:slush/controller/login_controller.dart';
import 'package:slush/controller/profile_controller.dart';
import 'package:slush/screens/profile/edit_profile.dart';
import 'package:slush/screens/profile/spark_purchase.dart';
import 'package:slush/screens/profile/view_profile.dart';
import 'package:slush/screens/setting/settings_screen.dart';
import 'package:slush/screens/subscritption/subscription_screen1%203.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:slush/widgets/toaster.dart';
import 'package:video_player/video_player.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  List<ListItem> item = [
    ListItem(1, AssetsPics.verifyWhite, "Get verified", LocaleText.des,color.txtGetVeirfy),
    ListItem(2, AssetsPics.star, "Spark", LocaleText.des2,color.darkPink)];
  bool accountVerificationStar=false;
  late CameraController _controller;
  VideoPlayerController? controller;

  @override
  void initState() {
    Provider.of<profileController>(context,listen: false).profileData(context);
    super.initState();
  }

  int calculateAge(String dobString) {
    DateTime dob = DateTime.parse(dobString);
    DateTime now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {age--;}
    return age;
  }

  Future<void>? _initializeVideoPlayerFuture;

  void _initializeCamera(loginControllerr getControl) async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front);
    _controller = CameraController(front, ResolutionPreset.medium);
    await _controller.initialize();
    customDialogBoxVideo(context,"I’m ready",getControl);
    if (!mounted) {return;}
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    final getControl=Provider.of<loginControllerr>(context,listen: false);
    final size=MediaQuery.of(context).size;
    return Scaffold(
      body:Consumer<profileController>(builder: (ctx,val,child){
        return val.dataa.length==0?const Center(child: CircularProgressIndicator(color: color.txtBlue)): Stack(children: [
          SizedBox(height: size.height, width: size.width, child: Image.asset(AssetsPics.background,fit: BoxFit.cover)),
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Stack(
              children: [
                SafeArea(
                  child: Column(children: [
                    Container(
                      padding: EdgeInsets.only(left: 15,top: accountVerificationStar?60:10,right: 15),
                      child: Column(children: [
                        Row(
                          children: [
                            buildText("Profile", 24, FontWeight.w600, color.txtBlack),
                            const Spacer(),
                            GestureDetector(
                                onTap: (){
                                  Get.to(()=>const SettingsScreen());
                                }
                                ,child: SvgPicture.asset(AssetsPics.setting))
                          ],),
                        circle_progress_bar(val),
                        SizedBox(height: 2.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(child: buildTextOverFlow(val.dataa['firstName']==null?"":"${val.dataa["firstName"]??""}, ${val.dataa['dateOfBirth']==null?"":calculateAge(val.dataa['dateOfBirth']??"")}", 28, FontWeight.w600, color.txtBlack)),
                             const SizedBox(width: 5),
                            SvgPicture.asset(LocaleHandler.isVerified?AssetsPics.verifywithborder:AssetsPics.verifygrey)
                          ],),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            LocaleHandler.sparkAndVerification? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 33,vertical: 6.9),
                              decoration: BoxDecoration(color:const Color.fromRGBO(239, 230, 243, 1),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Row(children: [
                                SvgPicture.asset(AssetsPics.star),
                                const SizedBox(width: 5),
                                buildText("3 Sparks", 16, FontWeight.w500, color.txtBlack,fontFamily: FontFamily.hellix)
                              ]),
                            ):const SizedBox(),
                            SizedBox(width:LocaleHandler.sparkAndVerification? 14:0),
                            GestureDetector(
                                onTap: (){
                                  Get.to(()=>const ViewProfileScreen());
                                },child: SvgPicture.asset(AssetsPics.viewProfile,height: 37,)),
                          ],
                        )
                      ],),),
                    SizedBox(height: 3.h),
                    LocaleHandler.sparkAndVerification?const SizedBox(): SizedBox(
                      // height: 12.h,
                      height:MediaQuery.of(context).size.height/8,
                      child: ListView.builder(
                          padding: const EdgeInsets.only(left: 10,right: 15),
                          shrinkWrap: true,
                          // physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: item.length,
                          itemBuilder: (context,index){
                            return GestureDetector(
                              onTap: (){
                                print(item[index].Id);
                                if(item[index].Id==1||item[index].Id==3){
                                  customDialogBox2(context: context,
                                      title: 'How does it work?', secontxt: "",
                                      heading: "We'll record a short video to match your face with your profile pictures for verification. We'll keep screenshots from the video, not the full video itself.",
                                      btnTxt: "I’m ready",
                                      img: AssetsPics.getVerified,isPng: true,
                                      onTap: (){
                                        Get.back();
                                        _initializeCamera(getControl);
                                        /*  Future.delayed(Duration(seconds: 1),(){
                                customDialogBoxVideo(context,"I’m ready",getControl);
                              });*/
                                      });
                                }else if(item[index].Id==2){
                                  Get.to(()=>const SparkPurchaseScreen())?.then((value) {//setState(() {LocaleHandler.sparkAndVerification=true;});
                                  });
                                }},
                              child: LocaleHandler.isVerified && item[index].Id==1? const SizedBox() :Container(
                                width: size.width*0.9,
                                // padding:  EdgeInsets.all(Platform.isAndroid?8.0:17.0),
                                padding: EdgeInsets.symmetric(//vertical:16,//horizontal:12
                                    vertical: MediaQuery.of(context).devicePixelRatio*5.6,
                                  horizontal: MediaQuery.of(context).devicePixelRatio*3.5
                                ),
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: item[index].clr),
                                child: FittedBox(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset( item[index].img),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          buildText( item[index].title, 17, FontWeight.w600, color.txtWhite),
                                          SizedBox(width: size.width/1.2-2.h-3,
                                              child: buildText( item[index].description, 15, FontWeight.w500, color.txtWhite,fontFamily: FontFamily.hellix))
                                        ],)],),
                                ),),);}),
                    ),
                    Container(
                        padding: const EdgeInsets.only(left: 15,right: 15,bottom: 15,top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 2.h),
                            buildText("Slush Subscription", 20, FontWeight.w600, color.txtBlack),
                            SizedBox(height: 2.h),
                            subScriptionOption(context,val),
                            SizedBox(height: 2.h+2),
                            white_button_woBorder(context, "View more",press: (){Get.to(()=>const Subscription1());}),
                          ],
                        )),
                  ],),
                ),
                AnimatedContainer(
                  width: size.width.w,
                  height: accountVerificationStar?13.h:0,
                  // width: size.width,
                  // height: accountVerificationStar?11.h:0,
                  duration:const Duration(seconds: 1),
                  child: Image.asset(AssetsPics.verifyinprocess,fit: BoxFit.fill),
                ),
              ],
            ),
          )
        ],);
      })
    );
  }

  Widget subScriptionOption(BuildContext context,profileController val) {
    final prfileControl=Provider.of<profileController>(context,listen: false);
   final size=MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.only(left: 2),
                      height: 25.h+2,
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Row(children: [
                            GestureDetector(
                              onTap: (){prfileControl.setSelectedIndex(1);},
                              child: buildContainer(context, "Silver", "£9.99"),
                            ),
                            GestureDetector(
                              onTap: (){prfileControl.setSelectedIndex(2);},
                              child: buildContainer(context, "Gold", "£19.99"),
                            ),
                            GestureDetector(
                              onTap: (){prfileControl.setSelectedIndex(3);},
                              child: buildContainer(context, "Platinum", "£29.99"),
                            ),
                          ],),
                          val.selectedIndex==2? GestureDetector(
                            onTap: () {
                              prfileControl.setSelectedIndex(2);
                            },
                            child: Container(
                              height: 185 ,
                              // width: MediaQuery.of(context).size.width/3.5,
                              width: MediaQuery.of(context).size.width/2.9,
                              decoration: BoxDecoration(color: color.txtBlue ,
                                  border: Border.all(color: color.example3),
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(AssetsPics.crownOn ,fit: BoxFit.fill,semanticsLabel: "Splash_svg",),
                                  buildText("Slush", 20, FontWeight.w600, color.txtWhite ),
                                  buildText("Gold", 20, FontWeight.w600,color.txtWhite ),
                                  const SizedBox(height: 10,),
                                  buildText("£19.99", 20, FontWeight.w600, color.txtWhite ),
                                ],
                              ),
                            ),
                          ):const SizedBox(),
                          Positioned(
                            bottom:Platform.isAndroid ? val.selectedIndex == 2 ? 0 : 8.0 :val.selectedIndex == 2 ? 11 : 22,
                            child: Container(
                              alignment: Alignment.center,
                              height: 22,
                              width: 82,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(6),
                                  color: val.selectedIndex == 2 ? color.txtWhite : color.txtBlue),
                              child: buildText("Popular", 13, FontWeight.w600,val.selectedIndex == 2 ? color.txtBlue : color.txtWhite,fontFamily: FontFamily.hellix),
                            ),
                          ),
                          val.selectedIndex==1? Positioned(
                            left: 0.0,
                            child: Container(
                              height: 185 ,
                              width: MediaQuery.of(context).size.width/3.1,
                              decoration: BoxDecoration(color: color.txtBlue , border: Border.all(color: color.example3), borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(AssetsPics.crownOn ,fit: BoxFit.fill,semanticsLabel: "Splash_svg",),
                                  buildText("Slush", 20, FontWeight.w600, color.txtWhite ),
                                  buildText("Silver", 20, FontWeight.w600,color.txtWhite ),
                                  const SizedBox(height: 10,),
                                  buildText("£9.99", 20, FontWeight.w600, color.txtWhite ),
                                ],
                              ),
                            ),
                          ):const SizedBox(),
                          val.selectedIndex==3? Positioned(
                            right: 0.0,
                            child: Container(
                              height: 185 ,
                              width: MediaQuery.of(context).size.width/3.1,
                              decoration: BoxDecoration(color: color.txtBlue ,
                                  border: Border.all(color: color.example3),
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(AssetsPics.crownOn ,fit: BoxFit.fill,semanticsLabel: "Splash_svg",),
                                  buildText("Slush", 20, FontWeight.w600, color.txtWhite ),
                                  buildText("PLatinum", 20, FontWeight.w600,color.txtWhite ),
                                  const SizedBox(height: 10,),
                                  buildText("£29.99", 20, FontWeight.w600, color.txtWhite ),
                                ],
                              ),
                            ),
                          ):const SizedBox(),
                        ],
                      ),
                    );
  }

  Widget buildContainer(BuildContext context,String type,String price) {
    return Container(
      height: 164,
      width: MediaQuery.of(context).size.width/3.3,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: color.example3),
          borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        SvgPicture.asset( AssetsPics.crownOff,fit: BoxFit.fill,semanticsLabel: "Splash_svg"),
        buildText("Slush", 20, FontWeight.w600, color.txtBlack),
        buildText(type, 20, FontWeight.w600, color.txtBlack),
        const SizedBox(height: 10,),
        buildText(price, 20, FontWeight.w600, color.txtBlack),],),);
  }

  Widget circle_progress_bar(profileController val) {
    return Stack(
      alignment: Alignment.center,
      children: [
        val.dataa["avatar"]!=null?CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 75.0,
          backgroundImage: NetworkImage(val.dataa["avatar"]),
          // child: CachedNetworkImage(imageUrl: LocaleHandler.dataa["avatar"], fit: BoxFit.cover),
        ):const CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 75.0,
          backgroundImage: AssetImage(AssetsPics.demouser),
          // child: CachedNetworkImage(imageUrl: LocaleHandler.dataa["avatar"], fit: BoxFit.cover),
        ),
        CircularPercentIndicator(
            radius: 86.0,
            backgroundColor: color.lightestBlue,
            progressColor: color.txtBlue,
            animation: true,
            animateFromLastPercent: true,
            circularStrokeCap: CircularStrokeCap.round,
            lineWidth: 6,
            percent: val.value),
        Positioned(
          bottom: 0.0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 2,horizontal: 9),
            alignment: Alignment.center,
            // height: 4.h-2, width: 8.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [color.txtBlue, color.gradientDarkBlue],),),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildText("${val.percent}".split(".").first, 18, FontWeight.w600, color.txtWhite,fontFamily: FontFamily.hellix),
                buildText("%", 18, FontWeight.w600, color.txtWhite,fontFamily: FontFamily.hellix),
              ],
            ),
          ),
        ),
        Positioned(
            top:defaultTargetPlatform==TargetPlatform.iOS? 15.0:18.0,
            right: 10.0,
            child: GestureDetector(
              onTap: (){
                Provider.of<editProfileController>(context,listen: false).saveValue(LocaleHandler.dataa["gender"],
                    LocaleHandler.dataa["height"],LocaleHandler.dataa["jobTitle"]??"",LocaleHandler.education,LocaleHandler.dataa["sexuality"]??"",
                    LocaleHandler.dataa["ideal_vacation"]??"",LocaleHandler.dataa["cooking_skill"]??"",
                    LocaleHandler.dataa["smoking_opinion"]??"");
                // setState(() { LocaleHandler.EditProfile=true;});
                Get.to(()=>const EditProfileScreen());
              },
              child: SizedBox(height: 4.h+5, width: 4.h+5, child: SvgPicture.asset(AssetsPics.profileEdit)),
            ))
      ],
    );
  }
  // ScreenshotController screenshotController = ScreenshotController();
  customDialogBoxVideo(BuildContext context, String btntxt,loginControllerr cntrl, {VoidCallback? onTap = pressed}) {
    return showGeneralDialog(
        barrierLabel: "Label",
        transitionDuration: const Duration(milliseconds: 500),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  // height: MediaQuery.of(context).size.height/2.5,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(vertical: 1.h),
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
                    decoration: BoxDecoration(color: Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        buildText2("Let’s get you verified", 24, FontWeight.w600, color.txtWhite),
                        SizedBox(height: 1.h),
                        Container(
                          height: 58.h,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: color.txtWhite
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child://recordingOff?
                           Consumer<loginControllerr>(builder: (context,value,index){
                             return value.recordingOfff?  AspectRatio(
                               aspectRatio: controller!.value.aspectRatio,
                               // child: Screenshot(controller: screenshotController, child: VideoPlayer(controller!)),
                               child: VideoPlayer(controller!),
                             ): AspectRatio(
                             aspectRatio: _controller.value.aspectRatio,
                             child: Stack(
                               children: [
                                 SizedBox(
                                     width: double.infinity,
                                     height: double.infinity,
                                     child: CameraPreview(_controller)),
                                value.recordingOff?const SizedBox(): Container(
                                    alignment: Alignment.center,
                                    height: 30,width: 30,
                                    child: buildText(value.secondsLeft.toString(),18,FontWeight.w500,color.txtBlack)),
                               ],
                             ),
                             );
                           })
                          ),
                        ),
                        SizedBox(height: 1.h),
                        buildText2("Make sure to frame your face in the rectangle!", 24, FontWeight.w600, color.txtWhite),
                        SizedBox(height: 1.h),
                        Consumer<loginControllerr>(builder: (context,value,index){
                          XFile? file;
                          return blue_button(context,value.recordingOff?"Submit": btntxt, press: ()async{
                            if(value.recordingOff){setState(() {
                              Get.back();
                              file=null;
                              customDialogBox(context: context,
                                  title: "Verification under review",
                                  secontxt: "",
                                  heading: "We are currently reviewing your video and will get back to you soon.",
                                  btnTxt: "Ok",
                                  img: AssetsPics.verificationComplete,isPng: true,
                                  onTap: (){
                                    Get.back();
                                    // snackBaar(context, AssetsPics.verifyinprocesssvg,false);
                                    // setState(() {accountVerificationStar=true;});
                                  cntrl.changebool(context,false);
                                    Future.delayed(const Duration(seconds: 5),(){setState(() {accountVerificationStar=false;
                                    });});
                                    
                                  });});
                            } else{
                              cntrl.startTimer();
                              await _controller.prepareForVideoRecording();
                              await _controller.startVideoRecording();
                              Future.delayed(const Duration(seconds: 5),()async{
                                 file=  await _controller.stopVideoRecording();
                                 XFile picture =  await _controller.takePicture();
                                 print("picture.path==="+picture.path);
                                 uploadVerifyImage(picture);
                                 controller = VideoPlayerController.file(File(file!.path));
                                _initializeVideoPlayerFuture = controller!.initialize().then((value)async {
                                  controller!.setVolume(0.0);
                                  controller!.play();
                                });
                                cntrl.changebool(context,true);
                              });
                            }
                          });}),
                        SizedBox(height: defaultTargetPlatform == TargetPlatform.iOS ? 1.h : 0),
                      ],
                    )),
              ),
            ),
          );
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(anim1),
            child: child,
          );
        }
    );
  }


  Future uploadVerifyImage(XFile image) async {
    const url = ApiList.imagevarificationUpload;
    print(url);
    var uri = Uri.parse(url);
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = "Bearer ${LocaleHandler.accessToken}";
    // Add image file
    if (image != null) {
      File imageFile = File(image!.path);
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile('verification_image', stream, length, filename: image.toString().split("/").last);
      request.files.add(multipartFile);
    }
    var response = await request.send();
    final respStr = await response.stream.bytesToString();
    print("respStr=="+respStr);
    print("response.statusCode==${response.statusCode}");
    if (response.statusCode == 201) {
      LocaleHandler.isVerified=true;
      snackBaar(context, AssetsPics.verifyinprocesssvg,false);
      Provider.of<profileController>(context,listen: false).profileData(context);
    } else if (response.statusCode == 401) {
      showToastMsgTokenExpired();
    } else {}
  }
}

class ListItem{
  int Id;
  String img;
  String title;
  String description;
  Color clr;
  ListItem(this.Id,this.img,this.title,this.description,this.clr);
}

/*
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:http/http.dart'as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:screenshot/screenshot.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/loader.dart';
import 'package:slush/constants/localkeys.dart';
import 'package:slush/controller/login_controller.dart';
import 'package:slush/screens/profile/edit_profile.dart';
import 'package:slush/screens/profile/spark_purchase.dart';
import 'package:slush/screens/profile/view_profile.dart';
import 'package:slush/screens/setting/settings_screen.dart';
import 'package:slush/screens/subscritption/subscription_screen1%203.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:slush/widgets/toaster.dart';
import 'package:video_player/video_player.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  int selectedIndex=2;
  double value = 0.0;
  var percent;
  Map<String,dynamic> dataa={};
  List<ListItem> item=[
    ListItem(1, AssetsPics.verifyWhite, "Get verified", LocaleText.des,color.txtBlue),
    ListItem(2, AssetsPics.star, "Spark", LocaleText.des2,color.darkPink)];

  bool accountVerificationStar=false;


  Future profileData() async {
    setState(() {dataa.clear();});
      final url = ApiList.getUser + LocaleHandler.userId;
      print(url);
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${LocaleHandler.accessToken}'
      });
      if (response.statusCode == 200) {
        Map<String,dynamic> data = jsonDecode(response.body);
        setState(() {
          dataa=data["data"];
          LocaleHandler.dataa=dataa;
          percantage();});
      } else if (response.statusCode == 401) {showToastMsgTokenExpired();
        print('Token Expire:::::::::::::');
      } else {print('Faoled to Load Data With Status Code ${response.statusCode}');
        throw Exception('Failed to load data');}
    } catch (e) {throw Exception('Failed to fetch data: $e');}
  }

  void percantage(){
    if(dataa["nextAction"]=="fill_firstname"){value=0.0;}
    else if(dataa["nextAction"]=="fill_dateofbirth"){value=0.1;}
    else if(dataa["nextAction"]=="fill_height"){value=0.2;}
    else if(dataa["nextAction"]=="choose_gender"){value=0.3;}
    else if(dataa["nextAction"]=="fill_lookingfor"){value=0.4;}
    else if(dataa["nextAction"]=="fill_sexual_orientation"){value=0.5;}
    else if(dataa["nextAction"]=="fill_ethnicity"){value=0.6;}
    else if(dataa["nextAction"]=="upload_avatar"){value=0.7;}
    else if(dataa["nextAction"]=="upload_video"){value=0.9;}
    // else if(dataa["nextAction"]=="fill_password"){value=0.0909*11;}
    else if(dataa["nextAction"]=="none"){value=1.0;}
    percent=value*100;
  }

  @override
  void initState() {
    profileData();
    // TODO: implement initState
    super.initState();
  }

  int calculateAge(String dobString) {
    DateTime dob = DateTime.parse(dobString);
    DateTime now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  late CameraController _controller;
  VideoPlayerController? controller;

  Future<void>? _initializeVideoPlayerFuture;

  void _initializeCamera(loginControllerr getControl) async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front);
    _controller = CameraController(front, ResolutionPreset.medium);
    await _controller.initialize();
    customDialogBoxVideo(context,"I’m ready",getControl);
    // setState(() => _isLoading = false);
    // CameraDescription description = await availableCameras().then((cameras) => cameras[1]);
    // _controller = CameraController(description, ResolutionPreset.medium);
    // await _controller.initialize();
    if (!mounted) {return;}
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    final getControl=Provider.of<loginControllerr>(context,listen: false);
    final size=MediaQuery.of(context).size;
    return Scaffold(
      body:dataa.length==0?Center(child: CircularProgressIndicator(color: color.txtBlue)): Stack(children: [
        SizedBox(height: size.height, width: size.width, child: Image.asset(AssetsPics.background,fit: BoxFit.cover)),
        SingleChildScrollView(
          child: Stack(
            children: [
              SafeArea(
                child: Column(children: [
                  Container(
                    padding: EdgeInsets.only(left: 15,top: accountVerificationStar?60:10,right: 15),
                    child: Column(children: [
                    Row(
                      children: [
                      buildText("Profile", 24, FontWeight.w600, color.txtBlack),
                      const Spacer(),
                      GestureDetector(
                          onTap: (){
                            Get.to(()=>const SettingsScreen());
                          }
                          ,child: SvgPicture.asset(AssetsPics.setting))
                    ],),
                      circle_progress_bar(),
                      SizedBox(height: 2.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        buildText(dataa['firstName']==null?"":"${dataa["firstName"]??""}, ${dataa['dateOfBirth']==null?"":calculateAge(dataa['dateOfBirth']??"")}", 28, FontWeight.w600, color.txtBlack),
                          const SizedBox(width: 5),
                          SvgPicture.asset(LocaleHandler.isVerified?AssetsPics.verifywithborder:AssetsPics.verifygrey)
                      ],),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LocaleHandler.sparkAndVerification? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 33,vertical: 6.9),
                            decoration: BoxDecoration(color:const Color.fromRGBO(239, 230, 243, 1),
                              borderRadius: BorderRadius.circular(8)),
                            child: Row(children: [
                              SvgPicture.asset(AssetsPics.star),
                              const SizedBox(width: 5),
                              buildText("3 Sparks", 16, FontWeight.w500, color.txtBlack,fontFamily: FontFamily.hellix)
                            ]),
                          ):const SizedBox(),
                          SizedBox(width:LocaleHandler.sparkAndVerification? 14:0),
                          GestureDetector(
                          onTap: (){
                            Get.to(()=>const ViewProfileScreen());
                          }
                          ,child: SvgPicture.asset(AssetsPics.viewProfile,height: 37,)),
                        ],
                      )
                  ],),),
                  SizedBox(height: 3.h),
                 LocaleHandler.sparkAndVerification?const SizedBox(): Container(
                    // height: 12.h,
                    height:MediaQuery.of(context).size.height/8,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(left: 10,right: 15),
                      shrinkWrap: true,
                      // physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                        itemCount: item.length,
                        itemBuilder: (context,index){
                        return GestureDetector(
                          onTap: (){
                            print(item[index].Id);
                            if(item[index].Id==1||item[index].Id==3){
                              customDialogBox2(context: context,
                                title: 'How does it work?', secontxt: "",
                                heading: "We'll record a short video to match your face with your profile pictures for verification. We'll keep screenshots from the video, not the full video itself.",
                                btnTxt: "I’m ready",
                                img: AssetsPics.getVerified,isPng: true,
                            onTap: (){
                              Get.back();
                              _initializeCamera(getControl);
                            /*  Future.delayed(Duration(seconds: 1),(){
                                customDialogBoxVideo(context,"I’m ready",getControl);
                              });*/
                            });
                          }else if(item[index].Id==2){
                              Get.to(()=>const SparkPurchaseScreen())?.then((value) {setState(() {LocaleHandler.sparkAndVerification=true;});});
                            }},
                          child: LocaleHandler.isVerified && item[index].Id==1? SizedBox() :Container(
                            padding: const EdgeInsets.all(8.0),
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: item[index].clr),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              SvgPicture.asset( item[index].img),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                buildText( item[index].title, 17, FontWeight.w600, color.txtWhite),
                                SizedBox(
                                    width: size.width/1.2-2.h-3,
                                    child: buildText( item[index].description, 15, FontWeight.w500, color.txtWhite,fontFamily: FontFamily.hellix))
                              ],)
                            ],),
                          ),
                        );}),
                  ),
                  Container(
                      padding: const EdgeInsets.only(left: 15,right: 15,bottom: 15,top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 2.h),
                          buildText("Slush Subscription", 20, FontWeight.w600, color.txtBlack),
                          SizedBox(height: 2.h),
                          subScriptionOption(context),
                          SizedBox(height: 2.h+2),
                          white_button_woBorder(context, "View more",press: (){Get.to(()=>const Subscription1());}),
                        ],
                      )),
                ],),
              ),
              AnimatedContainer(
                width: size.width.w,
                height: accountVerificationStar?13.h:0,
                // width: size.width,
                // height: accountVerificationStar?11.h:0,
                duration:const Duration(seconds: 1),
                child: Image.asset(AssetsPics.verifyinprocess,fit: BoxFit.fill,),
              ),
            ],
          ),
        )
      ],),
    );
  }

  Widget subScriptionOption(BuildContext context) {
    return Container(
                      height: 25.h+2,
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Row(children: [
                            GestureDetector(
                              onTap: (){setState(() {selectedIndex=1;});},
                              child: buildContainer(context, "Silver", "£9.99"),
                            ),
                            GestureDetector(
                              onTap: (){setState(() {selectedIndex=2;});},
                              child: buildContainer(context, "Gold", "£19.99"),
                            ),
                            GestureDetector(
                              onTap: (){setState(() {selectedIndex=3;});},
                              child: buildContainer(context, "Platinum", "£29.99"),
                            ),
                          ],),
                          selectedIndex==2? GestureDetector(
                            onTap: () {
                              setState(() {});
                              selectedIndex = 2 ;
                            },
                            child: Container(
                              height: 185 ,
                              // width: MediaQuery.of(context).size.width/3.5,
                              width: MediaQuery.of(context).size.width/2.9,
                              decoration: BoxDecoration(color: color.txtBlue ,
                                  border: Border.all(color: color.example3),
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(AssetsPics.crownOn ,fit: BoxFit.fill,semanticsLabel: "Splash_svg",),
                                  buildText("Slush", 20, FontWeight.w600, color.txtWhite ),
                                  buildText("Gold", 20, FontWeight.w600,color.txtWhite ),
                                  const SizedBox(height: 10,),
                                  buildText("£19.99", 20, FontWeight.w600, color.txtWhite ),
                                ],
                              ),
                            ),
                          ):const SizedBox(),
                          Positioned(
                            bottom: selectedIndex == 2 ? 0 : 8,
                            child: Container(
                              alignment: Alignment.center,
                              height: 22,
                              width: 82,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: selectedIndex == 2 ? color.txtWhite : color.txtBlue
                              ),
                              child: buildText("Popular", 13, FontWeight.w600,selectedIndex == 2 ? color.txtBlue : color.txtWhite,fontFamily: FontFamily.hellix),
                            ),
                          ),
                          selectedIndex==1? Positioned(
                            left: 0.0,
                            child: Container(
                              height: 185 ,
                              width: MediaQuery.of(context).size.width/3.1,
                              decoration: BoxDecoration(color: color.txtBlue , border: Border.all(color: color.example3), borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(AssetsPics.crownOn ,fit: BoxFit.fill,semanticsLabel: "Splash_svg",),
                                  buildText("Slush", 20, FontWeight.w600, color.txtWhite ),
                                  buildText("Silver", 20, FontWeight.w600,color.txtWhite ),
                                  const SizedBox(height: 10,),
                                  buildText("£9.99", 20, FontWeight.w600, color.txtWhite ),
                                ],
                              ),
                            ),
                          ):const SizedBox(),
                          selectedIndex==3? Positioned(
                            right: 0.0,
                            child: Container(
                              height: 185 ,
                              width: MediaQuery.of(context).size.width/3.1,
                              decoration: BoxDecoration(color: color.txtBlue ,
                                  border: Border.all(color: color.example3),
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(AssetsPics.crownOn ,fit: BoxFit.fill,semanticsLabel: "Splash_svg",),
                                  buildText("Slush", 20, FontWeight.w600, color.txtWhite ),
                                  buildText("PLatinum", 20, FontWeight.w600,color.txtWhite ),
                                  const SizedBox(height: 10,),
                                  buildText("£29.99", 20, FontWeight.w600, color.txtWhite ),
                                ],
                              ),
                            ),
                          ):const SizedBox(),
                        ],
                      ),
                    );
  }

  Widget buildContainer(BuildContext context,String type,String price) {
    return Container(
                              height: 164,
                              width: MediaQuery.of(context).size.width/3.3,
                              decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(color: color.example3),
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset( AssetsPics.crownOff,fit: BoxFit.fill,semanticsLabel: "Splash_svg",),
                                  buildText("Slush", 20, FontWeight.w600, color.txtBlack,),
                                  buildText(type, 20, FontWeight.w600, color.txtBlack,),
                                  const SizedBox(height: 10,),
                                  buildText(price, 20, FontWeight.w600, color.txtBlack,),
                                ],
                              ),
                            );
  }

  Widget circle_progress_bar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        dataa["avatar"]!=null?CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 75.0,
          backgroundImage: NetworkImage(dataa["avatar"]),
          // child: CachedNetworkImage(imageUrl: LocaleHandler.dataa["avatar"], fit: BoxFit.cover),
        ):CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 75.0,
          backgroundImage: AssetImage(AssetsPics.demouser),
          // child: CachedNetworkImage(imageUrl: LocaleHandler.dataa["avatar"], fit: BoxFit.cover,),
        ),
        CircularPercentIndicator(
            radius: 86.0,
            backgroundColor: color.lightestBlue,
            progressColor: color.txtBlue,
            animation: true,
            animateFromLastPercent: true,
            circularStrokeCap: CircularStrokeCap.round,
            lineWidth: 6,
            percent: value),
        Positioned(
          bottom: 0.0,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 2,horizontal: 9),
            alignment: Alignment.center,
            // height: 4.h-2, width: 8.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [color.txtBlue, color.gradientDarkBlue],),),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildText("$percent".split(".").first, 18, FontWeight.w600, color.txtWhite,fontFamily: FontFamily.hellix),
                buildText("%", 18, FontWeight.w600, color.txtWhite,fontFamily: FontFamily.hellix),
              ],
            ),
          ),
        ),
        Positioned(
            top:defaultTargetPlatform==TargetPlatform.iOS? 15.0:18.0,
            right: 10.0,
            child: GestureDetector(
              onTap: (){
                // setState(() { LocaleHandler.EditProfile=true;});
                Get.to(()=>const EditProfileScreen());
              },
              child: Container(height: 4.h+5, width: 4.h+5,
                  child: SvgPicture.asset(AssetsPics.profileEdit)),
            ))
      ],
    );
  }
  ScreenshotController screenshotController = ScreenshotController();
  customDialogBoxVideo(BuildContext context, String btntxt,loginControllerr cntrl,
      {VoidCallback? onTap = pressed}) {
    return showGeneralDialog(
        barrierLabel: "Label",
        transitionDuration: const Duration(milliseconds: 500),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  // height: MediaQuery.of(context).size.height/2.5,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(vertical: 1.h),
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
                    decoration: BoxDecoration(color: Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        buildText2("Let’s get you verified", 24, FontWeight.w600, color.txtWhite),
                        SizedBox(height: 1.h),
                        Container(
                          height: 58.h,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: color.txtWhite
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child://recordingOff?
                           Consumer<loginControllerr>(builder: (context,value,index){
                             return value.recordingOfff?  AspectRatio(
                               aspectRatio: controller!.value.aspectRatio,
                               child: Screenshot(
                                   controller: screenshotController,
                                   child: VideoPlayer(controller!)),
                             ): AspectRatio(
                             aspectRatio: _controller.value.aspectRatio,
                             child: Stack(
                               children: [
                                 Container(
                                     width: double.infinity,
                                     height: double.infinity,
                                     child: CameraPreview(_controller)),
                                value.recordingOff?SizedBox(): Container(
                                    alignment: Alignment.center,
                                    height: 30,width: 30,
                                    child: buildText(value.secondsLeft.toString(),18,FontWeight.w500,color.txtBlack)),
                               ],
                             ),
                             );
                           })
                          ),
                        ),
                        SizedBox(height: 1.h),
                        buildText2("Make sure to frame your face in the rectangle!", 24, FontWeight.w600, color.txtWhite),
                        SizedBox(height: 1.h),
                        Consumer<loginControllerr>(builder: (context,value,index){
                          XFile? file;
                          return blue_button(context,value.recordingOff?"Submit": btntxt, press: ()async{
                            if(value.recordingOff){setState(() {
                              file=null;
                              Get.back();
                              customDialogBox(context: context,
                                  title: "Verification under review",
                                  secontxt: "",
                                  heading: "We are currently reviewing your video and will get back to you soon.",
                                  btnTxt: "Ok",
                                  img: AssetsPics.verificationComplete,isPng: true,
                                  onTap: (){
                                    Get.back();
                                    // snackBaar(context, AssetsPics.verifyinprocesssvg);
                                    setState(() {
                                      accountVerificationStar=true;
                                    });
                                  cntrl.changebool(false);
                                    Future.delayed(const Duration(seconds: 5),(){setState(() {accountVerificationStar=false;
                                    });});
                                  });});
                            } else{
                              cntrl.startTimer();
                              await _controller.prepareForVideoRecording();
                              await _controller.startVideoRecording();
                              Future.delayed(Duration(seconds: 5),()async{
                                 file=  await _controller.stopVideoRecording();
                                 XFile picture =  await _controller.takePicture();
                                 print("picture.path==="+picture.path);
                                 uploadMultipleImage(picture);
                                 controller = VideoPlayerController.file(File(file!.path));
                                _initializeVideoPlayerFuture = controller!.initialize().then((value)async {
                                  controller!.setVolume(0.0);
                                  controller!.play();
                                });
                                cntrl.changebool(true);
                              });
                            }
                          });}),
                        SizedBox(height: defaultTargetPlatform == TargetPlatform.iOS ? 1.h : 0),
                      ],
                    )),
              ),
            ),
          );
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(anim1),
            child: child,
          );
        }
    );
  }


  Future uploadMultipleImage(XFile image) async {
    const url = ApiList.imagevarificationUpload;
    print(url);
    var uri = Uri.parse(url);
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = "Bearer ${LocaleHandler.accessToken}";
    // Add image file
    if (image != null) {
      File imageFile = File(image!.path);
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile('verification_image', stream, length, filename: image.toString().split("/").last);
      request.files.add(multipartFile);
    }
    // request.fields['key'] = "files";
    // request.fields['type'] = "file";
    var response = await request.send();
    final respStr = await response.stream.bytesToString();
    print("respStr=="+respStr);
    print("response.statusCode==${response.statusCode}");
    if (response.statusCode == 201) {
      profileData();
    } else if (response.statusCode == 401) {
      showToastMsgTokenExpired();
    } else {}
  }
}

class ListItem{
  int Id;
  String img;
  String title;
  String description;
  Color clr;
  ListItem(this.Id,this.img,this.title,this.description,this.clr);
}*/