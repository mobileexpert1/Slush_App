import 'dart:convert';
// import 'package:country_state_city/utils/city_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:http/http.dart'as http;
import 'package:uuid/uuid.dart';

class DetailLocationScreen extends StatefulWidget {
  const DetailLocationScreen({Key? key}) : super(key: key);

  @override
  State<DetailLocationScreen> createState() => _DetailLocationScreenState();
}

class _DetailLocationScreenState extends State<DetailLocationScreen> {
  TextEditingController locationController=TextEditingController();
  FocusNode locationNode=FocusNode();
  String enableField="";
  List state=[];
  List statesList=[];

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

  String _searchQuery='';
  var uuid =  Uuid();
  String _sessionToken =  Uuid().toString();
  List<dynamic>_placeList = [];

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 3.h-3),
        LocaleHandler.EditProfile?  buildText("Discover potential matches in your area.", 28, FontWeight.w600, color.txtBlack):
        buildText2("Your location?", 28, FontWeight.w600, color.txtBlack),
        const SizedBox(height: 5),
        LocaleHandler.EditProfile?SizedBox():buildText("Discover potential matches in your area.", 15, FontWeight.w500, color.txtBlack,fontFamily: FontFamily.hellix),
         SizedBox(height: 4.h-1),
        buildContainer(
          "Enter your location", locationController, AutovalidateMode.onUserInteraction, locationNode,
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
       _searchQuery==""?SizedBox():
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
                                LocaleHandler.location=_placeList[index]["description"];
                                _searchQuery="";
                                statesList.clear();
                                FocusManager.instance.primaryFocus?.unfocus();
                              });
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
                                      padding: EdgeInsets.only(top: 5),
                                      child: SvgPicture.asset(AssetsPics.locationIcon,width: 14,)),
                                  SizedBox(width: 12),
                                  Flexible(child: buildText(_placeList[index]["description"],18,FontWeight.w500,color.txtgrey))
                                ],)

                          ),
                          ),
                          index==_placeList.length-1?SizedBox():Divider(thickness: 0.2,)
                        ],
                      );
                    }),
              ),
            ),
         SizedBox(height: 2.h-3)
      ],);
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