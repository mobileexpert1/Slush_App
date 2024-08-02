import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/controller/controller.dart';
import 'package:slush/controller/setting_controller.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:uuid/uuid.dart';
import '../../constants/LocalHandler.dart';
import '../../constants/image.dart';
import 'package:http/http.dart' as http;
import '../../widgets/text_widget.dart';

class AddLocation extends StatefulWidget {
  const AddLocation({Key? key}) : super(key: key);

  @override
  State<AddLocation> createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {
  TextEditingController locationController=TextEditingController();
  FocusNode locationNode=FocusNode();
  String enableField="";
  List state=[];
  List statesList=[];

  String _searchQuery='';
  var uuid =  const Uuid();
  String _sessionToken =  const Uuid().toString();
  List<dynamic>_placeList = [];

  @override
  void initState() {
    locationController.addListener(() {
      _onChanged();
    });
    locationNode.addListener(() {
      if(locationNode.hasFocus){
        enableField="Enter FirstName";
      }else{
        enableField="";
      }
    });
    super.initState();
  }

  void _onChanged() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getLocationResults(locationController.text);
  }

  void getLocationResults(String input) async {
    // AIzaSyD2x5SDImQ-4Suz9pHXBEFkTskYnefKkv0
    String kPLACES_API_KEY = "AIzaSyAtb9qudpaPK2l0uoANyRE0zi4Nj4jNoT4";
    String type = '(regions)';
    String baseURL ="https://maps.googleapis.com/maps/api/place/autocomplete/json";
    String request ="$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken";
    var response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      setState(() {
        _placeList = jsonDecode(response.body)["predictions"];
      });
    } else {
      throw Exception("Failed to load predictions");
    }
  }

  String latitude="";
  String longitude="";
  Future<void> getCoordinates(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        setState(() {
          latitude = locations[0].latitude.toString();
          longitude = locations[0].longitude.toString();
          print("::++++++++++=$latitude,$longitude");
          Provider.of<nameControllerr>(context, listen: false).setLocation(latitude, longitude);
        });
      } else {
        setState(() {
          print('No coordinates found for this address');
        });
      }
    } catch (e) {
      setState(() {
        print('Error: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color.backGroundClr,
      appBar: commonBarWithTextleft(context, color.backGroundClr, ""),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 3.h-3),
            buildText2("Your location?", 28, FontWeight.w600, color.txtBlack),
            const SizedBox(height: 5),
            buildText("Discover potential matches in your area.", 15, FontWeight.w500, color.txtBlack,fontFamily: FontFamily.hellix),
            SizedBox(height: 4.h-1),
            buildContainer(
              "Enter your location",
              locationController, AutovalidateMode.onUserInteraction, locationNode,
              onChanged: (text){
                LocaleHandler.location=locationController.text.trim();
                // _searchLocations(text);
              },
              gesture: GestureDetector(
                  child: Container(
                      padding: const EdgeInsets.only(top: 10),
                      height: 20,width: 30,
                      alignment: Alignment.center,
                      child: SvgPicture.asset(AssetsPics.locationIcon,color:enableField == "Enter FirstName"? color.txtBlue:color.txtBlack))
              ),
            ),
            _searchQuery==""?const SizedBox():
            Flexible(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.only(bottom: 10,top: 5),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: color.txtWhite),
                child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _placeList.length,
                    itemBuilder: (context,index){
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                locationController.text=_placeList[index]["description"];
                                getCoordinates(locationController.text.trim());
                                LocaleHandler.location=_placeList[index]["description"];
                                _searchQuery="";
                                statesList.clear();
                                FocusManager.instance.primaryFocus?.unfocus();
                              });
                              Provider.of<SettingController>(context,listen: false).saveAdress(locationController.text);
                            }
                            ,child: Container(
                              color: Colors.transparent,
                              alignment: Alignment.topLeft,
                              margin: const EdgeInsets.only(left: 10,right: 10,top: 10),
                              padding: const EdgeInsets.only(left: 8,right: 8,top: 0),
                              // decoration:  BoxDecoration(border: Border(bottom: BorderSide(width: 0.5,color:index==statesList.length-1?color.txtWhite: color.txtBlue))),
                              child:Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: SvgPicture.asset(AssetsPics.locationIcon,width: 14,)),
                                  const SizedBox(width: 12),
                                  Flexible(child: buildText(_placeList[index]["description"],18,FontWeight.w500,color.txtgrey))
                                ],)

                          ),
                          ),
                          index==_placeList.length-1?const SizedBox():const Divider(thickness: 0.2,)
                        ],
                      );
                    }),
              ),
            ),
            SizedBox(height: 2.h-3)
          ],
        ),
      ),
    );
  }
  Widget buildContainer(String txt,
      TextEditingController controller,
      AutovalidateMode auto,FocusNode node,
      {FormFieldValidator<String>? validation,VoidCallback? press,GestureDetector? gesture,final ValueChanged<String>? onChanged,}) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: 56,
        width: MediaQuery.of(context).size.width,
        decoration:  BoxDecoration(color: color.txtWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color:enableField == "Enter FirstName"? color.txtBlue:color.txtWhite, width:1)),
        child: TextFormField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
              // searchItem();
            });
          },
          // readOnly: true,
          textInputAction: TextInputAction.done,
          onTap: press,
          focusNode: node,
          controller: controller,
          cursorColor: color.txtBlue,
          autovalidateMode: auto,
          validator: validation,
          decoration: InputDecoration(
            errorStyle: const TextStyle(height: 0, fontSize: 12),
            border: InputBorder.none,
            hintText: txt,hintStyle: const TextStyle(fontFamily: FontFamily.hellix,fontSize: 16,fontWeight: FontWeight.w500,color: color.txtgrey2),
            contentPadding: const EdgeInsets.only(left: 20,right: 18,top: 15),
            prefixIcon: gesture,
          ),
        ),
      ),
    );
  }
}
class Locations {
  final String name;
  final String address;

  Locations({required this.name, required this.address});

  factory Locations.fromJson(Map<String, dynamic> json) => Locations(
    name: json['name'],
    address: json['address'],
  );
}
