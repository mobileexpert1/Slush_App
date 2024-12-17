import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart'as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/localkeys.dart';
import 'package:slush/controller/edit_profile_controller.dart';
import 'package:slush/controller/login_controller.dart';
import 'package:slush/controller/profile_controller.dart';
import 'package:slush/screens/profile/edit_profile.dart';
import 'package:slush/screens/profile/spark_purchase.dart';
import 'package:slush/screens/profile/view_profile.dart';
import 'package:slush/screens/setting/settings_screen.dart';
import 'package:slush/screens/subscritption/subscription_screen1%203.dart';
import 'package:slush/services/IAPurchase.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/customtoptoaster.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:slush/widgets/toaster.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);
  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late profileController profileCntrl;
  late profileController profileWatcher;

  List<ProductDetails> _products = [];
  List<ListItem> item = [
    ListItem(1, AssetsPics.verifyWhite, "Get verified", LocaleText.des, color.txtGetVeirfy),
    ListItem(2, AssetsPics.star, "Spark", LocaleText.des2, color.darkPink)];
  bool accountVerificationStar=false;
  late CameraController _controller;
  VideoPlayerController? controller;

  @override
  void initState() {
    profileCntrl=Provider.of<profileController>(context,listen: false);

    profileCntrl.profileData(context);
    getInAppPurchaseDetails();
    super.initState();
  }

  void getInAppPurchaseDetails()async{_products=await IAPurchases().initialize();}

  Future<void>? _initializeVideoPlayerFuture;

  void _initializeCamera(loginControllerr getControl) async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front);
    _controller = CameraController(front, ResolutionPreset.medium);
    await _controller.initialize();
    customDialogBoxVideo(context,"I’m ready",getControl);
    if (!mounted) {return;}
  }

  @override
  Widget build(BuildContext context) {
    final getControl=Provider.of<loginControllerr>(context,listen: false);
    final size=MediaQuery.of(context).size;
    print(size.height);
    return Scaffold(
      body:Consumer<profileController>(builder: (ctx,val,child){
        return val.dataa.isEmpty ?const Center(child: CircularProgressIndicator(color: color.txtBlue)): Stack(children: [
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
                                onTap: ()async{
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
                            Flexible(child: buildTextOverFlow(val.dataa['firstName']==null?"":"${val.dataa["firstName"]??""}", 28, FontWeight.w600, color.txtBlack)),
                            Flexible(child: buildTextOverFlow(", ${val.dataa['dateOfBirth']==null?"":ProfileScreenFunction().calculateAge(val.dataa['dateOfBirth']??"")}", 28, FontWeight.w600, color.txtBlack)),
                             const SizedBox(width: 5),
                            SvgPicture.asset(LocaleHandler.isVerified?AssetsPics.verifywithborder:AssetsPics.verifygrey)
                          ],),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // LocaleHandler.sparkAndVerification?
                            GestureDetector(
                              onTap: (){
                                Get.to(()=> const SparkPurchaseScreen())?.then((value) {setState(() {});});
                              },
                              child: Container(
                                // height: size.height*0.04,
                                padding: const EdgeInsets.symmetric(horizontal: 27,vertical: 5.5),
                                decoration: BoxDecoration(color:color.example4,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Row(children: [
                                  SvgPicture.asset(AssetsPics.star),
                                  const SizedBox(width: 10),
                                  buildText("${val.sparks} Sparks", 15, FontWeight.w500, color.txtBlack,fontFamily: FontFamily.hellix)
                                ]),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // GestureDetector(onTap: (){Get.to(()=>const ViewProfileScreen());},
                            //     child: SvgPicture.asset(LocaleHandler.isVerified?AssetsPics.viewProfileplain:AssetsPics.viewProfile,height: 37)),

                            GestureDetector(onTap: (){Get.to(()=>const ViewProfileScreen());},
                              child: Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5.5),
                                    decoration: BoxDecoration(color:const Color(0xFFE6F0FF),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Row(children: [
                                      SvgPicture.asset(AssetsPics.whiteeye),
                                      const SizedBox(width: 10),
                                      buildText("View Profile", 15, FontWeight.w500, color.txtBlack,fontFamily: FontFamily.hellix)
                                    ]),
                                  ),
                                  Positioned(
                                    right: 0.0,
                                    child: Container(
                                      padding: const EdgeInsets.all(1.5),
                                      decoration: BoxDecoration(color: const Color(0xFFFFFFFF),borderRadius: BorderRadius.circular(10)),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(color: Colors.red,borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )

                          ],
                        )
                      ],),),
                    SizedBox(height: 3.h),
                     LocaleHandler.isVerified ? const SizedBox() : SizedBox(
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
                                if(item[index].Id==1){
                                  customDialogBox2(context: context,
                                      title: 'How does it work?', secontxt: "",
                                      heading: "We'll record a short video to match your face with your profile pictures for verification. We'll keep screenshots from the video, not the full video itself.",
                                      btnTxt: "I’m ready",
                                      img: AssetsPics.getVerified,isPng: true,
                                      onTap: (){
                                        Get.back();
                                        _initializeCamera(getControl);
                                          // Future.delayed(Duration(seconds: 1),(){customDialogBoxVideo(context,"I’m ready",getControl);});
                                      });
                                }else if(item[index].Id==2){
                                  Get.to(()=> const SparkPurchaseScreen())?.then((value) {
                                    setState(() {});
                                    //setState(() {LocaleHandler.sparkAndVerification=true;});
                                  });
                                }},
                              child: !LocaleHandler.isVerified && item[index].Id==1?
                              buildContainerverifiedspark(size, context, 0):
                              val.sparks==0 && item[index].Id==2?buildContainerverifiedspark(size, context, 1): const SizedBox(),);}),
                    ),
                    Container(
                        padding: const EdgeInsets.only(left: 15,right: 15,bottom: 15,top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 2.h),
                            buildText("Slush Subscription", 20, FontWeight.w600, color.txtBlack),
                            // SizedBox(height: 2.h),
                            subScriptionOption(context,val),
                            SizedBox(height: size.height>750.0?size.width*0.05: 0),
                            clrchangeBUtton(context, "Upgrade",press: (){Get.to(()=>const Subscription1());}),
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
          ),
         val.accVerfy? CustomBlueTopToaster(textt: "Account verification under review"):const SizedBox.shrink()
        ],);
      }),
    );
  }

  Container buildContainerverifiedspark(Size size, BuildContext context, int index) {
    return Container(width: size.width*0.9,
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
                                        buildText(item[index].title, 17, FontWeight.w600, color.txtWhite),
                                        SizedBox(width: size.width/1.2-2.h-3,
                                            child: buildText( item[index].description, 15, FontWeight.w500, color.txtWhite,fontFamily: FontFamily.hellix))
                                      ],)],),
                              ),);
  }

  Widget subScriptionOption(BuildContext context,profileController val) {
    final prfileControl=Provider.of<profileController>(context,listen: false);
   final size=MediaQuery.of(context).size;
    return Container(
      // color: Colors.red,
      padding: const EdgeInsets.only(left: 2),
                      // height: 25.h+2,
                      height: 20.h,
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Row(children: [
                          //   GestureDetector(
                          //     onTap: (){prfileControl.setSelectedIndex(1);},
                          //     child: buildContainer(context,"Gold", "£19.99"),
                          //   ),
                          //   GestureDetector(
                          //     onTap: (){prfileControl.setSelectedIndex(2);},
                          //     child: buildContainer(context, "Silver", "£9.99"),
                          //   ),
                          //   GestureDetector(
                          //     onTap: (){prfileControl.setSelectedIndex(3);},
                          //     child: buildContainer(context, "Platinum", "£29.99"),
                          //   ),
                          // ],),
                          Container(
                            // height: 185 ,
                            height: MediaQuery.of(context).size.width*0.4-28 ,
                            // width: MediaQuery.of(context).size.width/2.9,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(color: Colors.transparent ,
                                border: Border.all(color: color.example3),
                                borderRadius: BorderRadius.circular(12)
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // SvgPicture.asset(AssetsPics.crownOn ,fit: BoxFit.fill,semanticsLabel: "Splash_svg",height: 40),
                                // Spacer(),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // SvgPicture.asset(AssetsPics.crownOn ,fit: BoxFit.fill,semanticsLabel: "Splash_svg",),
                                    // buildText("Slush Silver", 25, FontWeight.w600, color.txtWhite ),
                                    buildText(_products.isEmpty?"...":_products[0].title, 15, FontWeight.w600, color.txtBlack ),
                                    // buildText("1 month subscription plan", 25, FontWeight.w600,color.txtWhite ),
                                    buildText(_products.isEmpty?"...":_products[0].description, 15, FontWeight.w600,color.txtBlack ),
                                    const SizedBox(height: 2),
                                    // buildText("£9.99", 25, FontWeight.w600, color.txtWhite ),
                                    buildText(_products.isEmpty?"...":"${_products[0].price}", 15, FontWeight.w600, color.txtBlack ),
                                    // buildText("privacy policy", 25, FontWeight.w600,color.txtWhite ),
                                    Text.rich(textAlign: TextAlign.center,
                                      TextSpan(
                                        children: <TextSpan>[
                                          TextSpan(text: 'Privacy Policy', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500, color: color.txtBlack,fontFamily:FontFamily.hellix,
                                              decoration: TextDecoration.underline,decorationColor: color.txtBlack,decorationThickness: 1),
                                              recognizer: TapGestureRecognizer()..onTap=() async {
                                                var url = Uri.parse('https://www.slushdating.com/privacy-policy');
                                                if (await canLaunchUrl(url)) {await launchUrl(url, mode: LaunchMode.inAppWebView);}
                                                else {throw 'Could not launch $url';}}),
                                          TextSpan(text: ' and ', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500, color: color.txtBlack,fontFamily:FontFamily.hellix ),),
                                          TextSpan(text: 'Terms & Conditions', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500, color:color.txtBlack,fontFamily:FontFamily.hellix,
                                              decoration: TextDecoration.underline,decorationColor: color.txtBlack,decorationThickness: 1),
                                              recognizer: TapGestureRecognizer()..onTap=() async {
                                                var url = Uri.parse('https://www.slushdating.com/terms-of-use');
                                                if (await canLaunchUrl(url)) {await launchUrl(url, mode: LaunchMode.inAppWebView);}
                                                else {throw 'Could not launch $url';}}),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                // SvgPicture.asset(AssetsPics.crownOn ,fit: BoxFit.fill,semanticsLabel: "Splash_svg",height: 40),
                              ],
                            ),

                            // Column(
                            //     mainAxisAlignment: MainAxisAlignment.center,
                            //     children: [
                            //       SvgPicture.asset(AssetsPics.crownOn ,fit: BoxFit.fill,semanticsLabel: "Splash_svg",),
                            //       buildText("Slush", 20, FontWeight.w600, color.txtWhite ),
                            //       // buildText("Gold", 20, FontWeight.w600,color.txtWhite ),
                            //       buildText("Silver", 20, FontWeight.w600,color.txtWhite ),
                            //       const SizedBox(height: 10,),
                            //       // buildText("£19.99", 20, FontWeight.w600, color.txtWhite ),
                            //       buildText("£9.99", 20, FontWeight.w600, color.txtWhite ),
                            //     ],
                            //   )
                          ),
                          // Positioned(
                          //   bottom:Platform.isAndroid ? val.selectedIndex == 2 ? 0 : 8.0 :val.selectedIndex == 2 ? 11 : 22,
                          //   child: Container(
                          //     alignment: Alignment.center,
                          //     height: 22,
                          //     width: 82,
                          //     decoration: BoxDecoration(borderRadius: BorderRadius.circular(6),
                          //         color: val.selectedIndex == 2 ? color.txtWhite : color.txtBlue),
                          //     child: buildText("Popular", 13, FontWeight.w600,val.selectedIndex == 2 ? color.txtBlue : color.txtWhite,fontFamily: FontFamily.hellix),
                          //   ),
                          // ),
                          // val.selectedIndex==1? Positioned(
                          //   left: 0.0,
                          //   child: Container(
                          //     height: 185 ,
                          //     width: MediaQuery.of(context).size.width/3.1,
                          //     decoration: BoxDecoration(color: color.txtBlue , border: Border.all(color: color.example3), borderRadius: BorderRadius.circular(12)),
                          //     child: Column(
                          //       mainAxisAlignment: MainAxisAlignment.center,
                          //       children: [
                          //         SvgPicture.asset(AssetsPics.crownOn ,fit: BoxFit.fill,semanticsLabel: "Splash_svg",),
                          //         buildText("Slush", 20, FontWeight.w600, color.txtWhite ),
                          //         // buildText("Silver", 20, FontWeight.w600,color.txtWhite ),
                          //         buildText("Gold", 20, FontWeight.w600,color.txtWhite ),
                          //         const SizedBox(height: 10,),
                          //         // buildText("£9.99", 20, FontWeight.w600, color.txtWhite ),
                          //         buildText("£19.99", 20, FontWeight.w600, color.txtWhite ),
                          //       ],
                          //     ),
                          //   ),
                          // ):const SizedBox(),
                          // val.selectedIndex==3? Positioned(
                          //   right: 0.0,
                          //   child: Container(
                          //     height: 185 ,
                          //     width: MediaQuery.of(context).size.width/3.1,
                          //     decoration: BoxDecoration(color: color.txtBlue ,
                          //         border: Border.all(color: color.example3),
                          //         borderRadius: BorderRadius.circular(12)
                          //     ),
                          //     child: Column(
                          //       mainAxisAlignment: MainAxisAlignment.center,
                          //       children: [
                          //         SvgPicture.asset(AssetsPics.crownOn ,fit: BoxFit.fill,semanticsLabel: "Splash_svg",),
                          //         buildText("Slush", 20, FontWeight.w600, color.txtWhite ),
                          //         buildText("Platinum", 20, FontWeight.w600,color.txtWhite ),
                          //         const SizedBox(height: 10,),
                          //         buildText("£29.99", 20, FontWeight.w600, color.txtWhite ),
                          //       ],
                          //     ),
                          //   ),
                          // ):const SizedBox(),
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
        val.dataa["avatar"]!=null ?CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 75.0,
          // backgroundImage: NetworkImage(val.dataa["avatar"]),
          child: CachedNetworkImage(imageUrl: val.dataa["avatar"]??val.dataa["profilePictures"][0]["key"], fit: BoxFit.cover,
           imageBuilder: (context, imageProvider) => Container(decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: imageProvider, fit: BoxFit.cover)),),
            errorWidget: (context, url, error) => ClipRRect(borderRadius: BorderRadius.circular(70), child: Image.asset(AssetsPics.demouser)),
          ),
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
                // buildText("${val.percent}".split(".").first, 18, FontWeight.w600, color.txtWhite,fontFamily: FontFamily.hellix),
                buildText("${val.dataa["profileCompletion"]}", 18, FontWeight.w600, color.txtWhite,fontFamily: FontFamily.hellix),
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
                LocaleHandler.entencityname.clear();
                Provider.of<editProfileController>(context,listen: false).saveValue(LocaleHandler.dataa["gender"],
                    LocaleHandler.dataa["height"],LocaleHandler.dataa["jobTitle"]??"",LocaleHandler.education,LocaleHandler.dataa["sexuality"]??"",
                    LocaleHandler.dataa["ideal_vacation"]??"",LocaleHandler.dataa["cooking_skill"]??"",
                    LocaleHandler.dataa["smoking_opinion"]??"",LocaleHandler.dataa["ethnicity"]);
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
            onTap: () {Get.back();},
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
                                 SizedBox(width: double.infinity, height: double.infinity,
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
      File imageFile = File(image.path);
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
      // snackBaar(context, AssetsPics.verifyinprocess,true);
      Provider.of<profileController>(context,listen: false).showaccVerfyBnr();
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