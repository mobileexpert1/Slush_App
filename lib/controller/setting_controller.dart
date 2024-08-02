import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart'as http;
import 'package:provider/provider.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/loader.dart';
import 'package:slush/controller/controller.dart';
import 'package:slush/widgets/toaster.dart';

class SettingController extends ChangeNotifier{
  String _adress="";
  String get  adress=>_adress;


  Future updaetLocation(String latitude,String longitude)async{
    const url=ApiList.location;
    print(url);
    var uri=Uri.parse(url);
    var response=await http.post(uri,
        headers: <String,String>{
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${LocaleHandler.accessToken}"
        },body: jsonEncode({"latitude":latitude, "longitude":longitude})
    );
    if(response.statusCode==200){
      saveAdress(jsonDecode(response.body)["data"]["address"]);
      LocaleHandler.latitude=latitude;
      LocaleHandler.longitude=longitude;
    }else if(response.statusCode==401){showToastMsgTokenExpired();}
    else{Fluttertoast.showToast(msg: "Internal Server error");}
    notifyListeners();
  }

  void saveAdress(String val){
    _adress=val;
    getCoordinates(val);
    notifyListeners();
  }

  Future<void> getCoordinates(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        LocaleHandler.latitude=locations[0].latitude.toString();
        LocaleHandler.longitude=locations[0].longitude.toString();

          // Provider.of<nameControllerr>(context, listen: false).setLocation(locations[0].latitude.toString(), locations[0].longitude.toString());
      } else {
          print('No coordinates found for this address');
      }
    } catch (e) {
        print('Error: $e');
    }
    notifyListeners();
  }

  void updateGender(int i,val){
    LocaleHandler.selectedIndexGender=i;
    LocaleHandler.filtergender=val;
    notifyListeners();
  }
  void updateDistance(val){
    LocaleHandler.distancevalue=val;
    notifyListeners();
  }
  void updateAgeRange(min,max){
    LocaleHandler.startage = min;
    LocaleHandler.endage = max;
    notifyListeners();
  }
}