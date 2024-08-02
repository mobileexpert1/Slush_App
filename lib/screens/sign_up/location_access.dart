import 'dart:convert';

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
import 'package:slush/screens/events/bottomNavigation.dart';
import 'package:slush/screens/sign_up/vacation.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart'as http;
import 'package:slush/widgets/toaster.dart';

class SignUpLocationAccessScreen extends StatefulWidget {
  const SignUpLocationAccessScreen({Key? key}) : super(key: key);

  @override
  State<SignUpLocationAccessScreen> createState() => _SignUpLocationAccessScreenState();
}

class _SignUpLocationAccessScreenState extends State<SignUpLocationAccessScreen> {
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  String latitude = "";
  String longitude = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: color.green,
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Image.asset(AssetsPics.bluebg,fit: BoxFit.cover,),
            // decoration: BoxDecoration(image: DecorationImage(image: Image.asset("assets/bg/blue_bg.png"))),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100,left: 40),
            child: Container(
                height: 35.h,
                width: 36.h,
                alignment: Alignment.center,
                child: SvgPicture.asset(AssetsPics.bigheart,fit: BoxFit.cover,)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15,right: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 SizedBox(height: 30.h),
                Container(
                  alignment: Alignment.center,
                  child: SvgPicture.asset(AssetsPics.locationAccess),),
                 SizedBox(height: 3.h-2),
                buildText("Allow location access", 28, FontWeight.w600, color.txtWhite),
                // buildText("Your profile setup is complete!", 20, FontWeight.w500, color.txtWhite),
                const SizedBox(height: 10),
                buildText2("We use your location to show you potential matches in your area.", 20, FontWeight.w400, color.txtWhite,fontFamily: FontFamily.hellix),
                const Spacer(),
                blue_button(context, "Enable Location",press: (){
                  _getCurrentPosition();
                }),
                 SizedBox(height: 2.h-1),
                white_button(context, "Skip",press: (){
                  Get.offAll(()=> BottomNavigationScreen());
                }),
                 SizedBox(height: 2.h+4),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handlePermission();
    setState(() {LoaderOverlay.show(context);});
    if (!hasPermission) {Get.to(()=>const VacationDetailsScreen());}
    final position = await _geolocatorPlatform.getCurrentPosition();
    latitude = position.latitude.toString();
    longitude = position.longitude.toString();
    // setState(() {LoaderOverlay.show(context);});
    Get.to(()=>const VacationDetailsScreen());
    updaetLocation();
    setState(() {LoaderOverlay.hide();});
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {return false;}
    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  Future updaetLocation()async{
    final url=ApiList.location;
    var uri=Uri.parse(url);
    var response=await http.post(uri,
    headers: <String,String>{
      'Content-Type': 'application/json',
      "Authorization": "Bearer ${LocaleHandler.accessToken}"
     },body: jsonEncode({"latitude":latitude, "longitude":longitude})
    );
    setState(() {LoaderOverlay.hide();});
    if(response.statusCode==200){
      LocaleHandler.latitude=latitude;
      LocaleHandler.longitude=longitude;
      // Fluttertoast.showToast(msg: "Internal Server error");
    }else if(response.statusCode==401){
      showToastMsgTokenExpired();
    }
    else{
      Fluttertoast.showToast(msg: "Internal Server error");
    }
  }
}
