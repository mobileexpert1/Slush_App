import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import '../../constants/api.dart';
import '../../constants/image.dart';
import '../../constants/loader.dart';
import '../../controller/login_controller.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/text_widget.dart';
import 'package:http/http.dart'as http;
import '../../widgets/toaster.dart';
import 'add_location.dart';

class DiscoverySettings extends StatefulWidget {
  const DiscoverySettings({super.key});

  @override
  State<DiscoverySettings> createState() => _DiscoverySettingsState();
}
List genderList = [
  "Male",
  "Female",
  "Everyone",
];
int selectedIndex = -1;
int selectedLocation = -1;
var _value = 250;
var agevalue = 30;
double _startValue = 20.0;
double _endValue = 90.0;

final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
String latitude = "";
String longitude = "";

class _DiscoverySettingsState extends State<DiscoverySettings> {

  void check(){
    if(LocaleHandler.dataa["gender"]=="male"){
      selectedIndex = 1;
    }else if(LocaleHandler.dataa["gender"]=="female"){
      selectedIndex = 0;
    }else if(LocaleHandler.dataa["gender"]=="other"){
      selectedIndex = 2;
    }else selectedIndex = -1;
  }

   @override
  void initState() {
    check();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      appBar: commonBarWithTextleft(context, color.backGroundClr, "Discovery Settings"),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            SizedBox(
              height: size.height,
              width: size.width,
              child: Image.asset(AssetsPics.background,fit: BoxFit.cover,),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  const SizedBox(height: 30,),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: color.txtWhite,
                    ),
                    child:  Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _getCurrentPosition();
                              selectedLocation = 1;
                            });
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15,right: 15,top: 15,bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.my_location_sharp),
                                      const SizedBox(width: 10,),
                                      buildText("My current location", 18, FontWeight.w500, Colors.black),
                                    ],
                                  ),
                                  selectedLocation == 1 ? const Icon(Icons.done_rounded,color: Colors.green,): const SizedBox(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedLocation = 2;
                              Get.to(()=>AddLocation());
                            });
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15,right: 15,top: 6,bottom: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.add_circle_outline,color: Colors.blue,),
                                      const SizedBox(width: 4,),
                                      buildText("Add a new location", 18, FontWeight.w600, Colors.black),
                                    ],
                                  ),
                                  selectedLocation == 2 ? const Icon(Icons.done_rounded,color: Colors.green,): const SizedBox(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15,),
                  Container(
                    padding: const EdgeInsets.only(left: 20,right: 20,bottom: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: color.txtWhite,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 15,bottom: 10),
                          child: buildText("Show me", 18, FontWeight.w600, Colors.black),
                        ),
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: genderList.length,
                            itemBuilder: (context,index){
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15,bottom: 15),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedIndex = index;
                                          // button = true;
                                        });
                                      },
                                      child: Container(
                                        color: Colors.transparent,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            buildText(genderList[index], 18, FontWeight.w500, color.txtBlack),
                                            CircleAvatar(
                                              backgroundColor: selectedIndex==index?color.txtBlue:color.txtBlack,
                                              radius: 9,
                                              child: CircleAvatar(
                                                radius: 8,
                                                backgroundColor: selectedIndex==index?color.txtWhite:color.txtWhite,
                                                // backgroundImage: SvgPicture.asset(AssetsPics.arrowLeft),
                                                child: selectedIndex==index?SvgPicture.asset(AssetsPics.blueTickCheck,fit: BoxFit.cover,):const SizedBox(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  index == genderList.length -1 ? const SizedBox() : const Divider(
                                    height: 5,
                                    thickness: 1,
                                    color: color.example3,
                                  ),
                                ],
                              );
                            }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15,),
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
                          buildText("Distance", 18, FontWeight.w600, color.txtBlack),
                          Container(
                            height: 13.h,
                            width: size.width,
                            padding: const EdgeInsets.only(top: 20),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Consumer<loginControllerr>(builder: (context,valuee,index){return SliderTheme(
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
                                    // valueIndicatorShape: DropSliderValueIndicatorShape(),
                                    valueIndicatorColor: Colors.blue,
                                    valueIndicatorTextStyle: TextStyle(color: Colors.white, fontSize: 16.0),

                                    disabledThumbColor: Colors.red,
                                    disabledInactiveTrackColor: Colors.red,
                                    disabledActiveTrackColor: Colors.red,
                                    allowedInteraction: SliderInteraction.tapAndSlide,
                                    disabledActiveTickMarkColor: Colors.red,
                                    disabledInactiveTickMarkColor: Colors.red,
                                    disabledSecondaryActiveTrackColor: Colors.red,
                                    minThumbSeparation: 20.0,
                                    overlappingShapeStrokeColor: Colors.red,
                                    secondaryActiveTrackColor: Colors.red,
                                    showValueIndicator: ShowValueIndicator.onlyForDiscrete,

                                  ),
                                  child: Slider(
                                    min: 5.0,
                                    max: 500.0,
                                    value: _value.toDouble(),
                                    divisions: 99,
                                    label: '${_value.round()} km',
                                    onChanged: (value) {
                                      _value = value.toInt();
                                      Provider.of<loginControllerr>(context,listen: false).changeValue(_value);
                                    },
                                  ),
                                );}),
        
                                Positioned(
                                  left: 13.0,
                                  child: IgnorePointer(
                                    child: CircleAvatar(radius: 10,
                                      child: SvgPicture.asset(AssetsPics.sliderleft),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],),
                    ),
                  ),
                  const SizedBox(height: 15,),
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
                ],
              ),
            )
         ]
            ),
      )
    );
  }
  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handlePermission();
    // if (!hasPermission) {Get.to(()=>VacationDetailsScreen());}
    final position = await _geolocatorPlatform.getCurrentPosition();
    latitude = position.latitude.toString();
    longitude = position.longitude.toString();
    // setState(() {LoaderOverlay.show(context);});
    updaetLocation();
    // Get.to(()=>VacationDetailsScreen());
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
      print("Latitude========-----------=========${latitude}");
      print("Longitude========-----------=========${longitude}");
      // Fluttertoast.showToast(msg: "Internal Server error");
    }else if(response.statusCode==401){
      showToastMsgTokenExpired();
    }
    else{
      Fluttertoast.showToast(msg: "Internal Server error");
    }
  }
}
