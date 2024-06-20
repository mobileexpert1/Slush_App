import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/controller/controller.dart';
import 'package:slush/screens/chat/text_chat_screen.dart';
import 'package:slush/screens/events/bottomNavigation.dart';
import 'package:slush/screens/feed/profile.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/text_widget.dart';

class TransparentCongoWithBottomScreen extends StatefulWidget {
  const TransparentCongoWithBottomScreen({Key? key,required this.userId,required this.name}) : super(key: key);
  final int userId;
  final String name;

  @override
  State<TransparentCongoWithBottomScreen> createState() => _TransparentCongoWithBottomScreenState();
}

class _TransparentCongoWithBottomScreenState extends State<TransparentCongoWithBottomScreen> {
  @override
  Widget build(BuildContext context) {
    return //stackbuild();
      PopScope(
      canPop: false,
      // onPopInvoked: (bool didPop) async {
      //   setState(() {LocaleHandler.matchedd=false;});
      // },
      child: Scaffold(
        body: Stack(
          children: [
            BottomNavigationScreen(),
            stackbuild()
           // LocaleHandler.matchedd? stackbuild():SizedBox()
          ],
        ),
      ),
    );
  }


  Widget stackbuild(){
    final size=MediaQuery.of(context).size;
    return Stack(children: [
      Container(height: size.height, width: size.width, color: Colors.black.withOpacity(0.9)),
      SafeArea(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(left: 18,right: 18,top: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: (){
                      // setState(() {
                      // LocaleHandler.matchedd=false;
                      Provider.of<reelController>(context,listen: false).congoScreen(false,"",);
                      Get.back();
                      // Get.back();// });
                },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(shape: BoxShape.circle,color: Colors.transparent,
                          boxShadow:[
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 20.0,
                                offset: Offset(0.0,10.0)
                            )
                          ]
                      ),
                      // child: const Icon(Icons.clear,color: Colors.black87,size: 20),
                      child: SvgPicture.asset(AssetsPics.whiteCancel,width: 30,height: 30),
                    ),
                  )
                ],),
              SizedBox(height: 1.h),
              buildText2("It’s a Match!", 28, FontWeight.w600, color.txtWhite),
              buildText2("Congratulations!", 28, FontWeight.w600, color.txtWhite),
              SizedBox(height: 1.h),
              // Consumer<reelController>(builder: (ctx,val,child){return buildText2("“${val.name} liked you back”", 16, FontWeight.w500, color.txtWhite,fontFamily: FontFamily.hellix);}),

              buildText2("“${widget.name} liked you back”", 16, FontWeight.w500, color.txtWhite,fontFamily: FontFamily.hellix),
              // const SizedBox(height: 20),
              // SvgPicture.asset("assets/sample/matchingSample.svg"),

              Stack(
                children: [
                  Container(
                    // color: Colors.red,
                      width: MediaQuery.of(context).size.width, height: 41.h),
                  Positioned(
                    top: 50.0,
                    right: 60.0,
                    child: RotationTransition(
                        turns:  const AlwaysStoppedAnimation(10 / 360),
                        child: Container(
                            decoration:BoxDecoration(
                                color: Colors.white54,
                                borderRadius: BorderRadius.circular(40)
                            ),
                            padding: const EdgeInsets.all(4),
                            height: 19.h,
                            width: 17.h,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                // child: Image.asset(AssetsPics.sample,fit: BoxFit.cover),
                              child: Consumer<reelController>(builder: (ctx,val,child){
                                return CachedNetworkImage(imageUrl: val.imgurl,fit: BoxFit.cover);
                              })

                            ))),
                  ),
                  Positioned(
                    bottom: 40.0,
                    left: 60.0,
                    child: RotationTransition(
                        turns:  const AlwaysStoppedAnimation(-10 / 360),
                        child: Container(
                            decoration:BoxDecoration(
                                color: Colors.white54,
                                borderRadius: BorderRadius.circular(40)
                            ),
                            padding: const EdgeInsets.all(4),
                            height: 19.h,
                            width: 17.h,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                            //child: Image.asset(AssetsPics.sample,fit: BoxFit.cover)
                              child: CachedNetworkImage(imageUrl: LocaleHandler.avatar,fit: BoxFit.cover,)
                            ))),
                  ),
                  Positioned(
                      top: 30.0,
                      left: 50.0,
                      child: SvgPicture.asset(AssetsPics.twoHeart)),
                  Positioned(
                      bottom: 30.0,
                      right: 50.0,
                      child: SvgPicture.asset(AssetsPics.twoHeart)),
                  Positioned(
                      top: 27.0,
                      right: 150.0,
                      child: CircleAvatar(
                          backgroundColor: Colors.white,
                          // color: Colors.red,
                          child: SvgPicture.asset(AssetsPics.redHeart))),
                  Positioned(
                      bottom: 20.0,
                      left: 60.0,
                      child: CircleAvatar(
                          backgroundColor: Colors.white,
                          // color: Colors.red,
                          child: SvgPicture.asset(AssetsPics.redHeart))),
                ],
              ),
              // Image.asset(AssetsPics.matchingSample),
              const Spacer(),
              buildText("Ready to spark a connection?", 14, FontWeight.w500, color.txtWhite,fontFamily: FontFamily.hellix),
              SizedBox(height: 2.h-4),
              blue_button(context,"Start a conversation",press: (){
                Get.back();
                Get.to(()=>TextChatScreen());
                Provider.of<reelController>(context,listen: false).congoScreen(false,"");
              }),
              SizedBox(height: 2.h-4),
              white_button(context, "View profile",press: (){
                Get.back();
                Get.to(()=>FeedPersonProfileScreen(id: widget.userId.toString()));
                Provider.of<reelController>(context,listen: false).congoScreen(false,"");
                // Get.to(()=>const DidnotFindAnyoneScreen());
              }),
               SizedBox(height: 3.h),
            ],),),
      )
    ],);
  }

}
