import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:http/http.dart'as http;
import 'package:slush/constants/loader.dart';
import 'package:slush/controller/controller.dart';
import 'package:slush/widgets/toaster.dart';

class eventController extends ChangeNotifier{
var data;
List post=[];
int _page = 1;
var myEvent=null;
bool eventStored=false;
int totalpages=0;
int currentpage=0;

  Future getEvents(BuildContext context)async{
    // final url="${ApiList.getEvent}${LocaleHandler.userId}&distance=5000&events=popular&latitude=30.6990901&longitude=76.6913955&page=1&limit=15";
    final url=// LocaleHandler.latitude==""?"${ApiList.getEvent}${LocaleHandler.userId}&distance=${LocaleHandler.distancee}&events=popular":
        "${ApiList.getEvent}${LocaleHandler.miliseconds}&distance=${LocaleHandler.distancee}&events=popular&latitude=${LocaleHandler.latitude}&longitude=${LocaleHandler.longitude}&page=$_page&limit=10";
    print(url);
    var uri=Uri.parse(url);
    var response=await http.get(uri, headers: {'Content-Type':'application/json', 'Authorization':'Bearer ${LocaleHandler.accessToken}'});
    if(response.statusCode==200){print(response.statusCode);
    data=jsonDecode(response.body)["data"];
    totalpages=data["meta"]["totalPages"];
    currentpage=data["meta"]["currentPage"];
    post=data["items"];

    List<Map<String, dynamic>> j=[];
    for(var i=0;i<data["items"].length;i++){
      for(var ii=0;ii<data["items"][i]["participants"].length;ii++){
        if(data["items"][i]["participants"][ii]["user"]["userId"].toString()==LocaleHandler.userId){j.add(data["items"][i]);}}}
    LoaderOverlay.hide();
    if(eventStored==false){myEvent=j;eventStored=true;}}
    else if(response.statusCode==401){showToastMsgTokenExpired();}
    else{Fluttertoast.showToast(msg: 'Something Went Wrong');
    data="no data";
    }
  notifyListeners();
  }

  void futuredelayed(int i,bool val){
    Future.delayed(Duration(seconds: i),(){LocaleHandler.isBanner=val;notifyListeners();});
    notifyListeners();
  }

  Future saveEvent(String api,String event)async{
  final url=api+event;
  print(url);
  var response= await http.post(Uri.parse(url),
    headers: {'Content-Type': 'application/json',
      'Authorization': 'Bearer ${LocaleHandler.accessToken}'},);
  if(response.statusCode==201){
    var data=jsonDecode(response.body);
    LocaleHandler.ErrorMessage = data["message"];
  } else {
    return  Error();
  }
  notifyListeners();
}

  Future savedEvents()async{
  LocaleHandler.items.clear();
  final url=ApiList.savedEvents;
  print(url);
  final uri=Uri.parse(url);
  var response= await http.post(uri,
    headers: <String,String>{'Content-Type': 'application/json',
      'Authorization': 'Bearer ${LocaleHandler.accessToken}',
    },
  );
  data=jsonDecode(response.body);
  if(response.statusCode==201){
    for(var i=0;i<data.length;i++){
      LocaleHandler.items.add(data[i]["event"]["eventId"]);
    }
    return "Ok";
  } else if(response.statusCode == 401){
    showToastMsg(data["message"]);
  }
  else {
    LocaleHandler.ErrorMessage = data["message"];
    return  Error();}
  notifyListeners();
}


//-----------------------------------------
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  String latitude = "";
  String longitude = "";

  Future<void> _getCurrentPosition(BuildContext context) async {
    final hasPermission = await _handlePermission();
    if (!hasPermission) {
      Fluttertoast.showToast(msg: "Location permission is neccessary");
    }
    final position = await _geolocatorPlatform.getCurrentPosition();
    latitude = position.latitude.toString();
    longitude = position.longitude.toString();
    Provider.of<nameControllerr>(context,listen: false).setLocation(latitude, longitude);
    // getEvents();
    updaetLocation();
    notifyListeners();
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {return false;}
    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {return false;}
    }
    if (permission == LocationPermission.deniedForever) {return false;}
    notifyListeners();
    return true;
  }

  Future updaetLocation()async{
    const url=ApiList.location;
    var uri=Uri.parse(url);
    var response = await http.post(uri, headers: {'Content-Type': 'application/json',
      "Authorization": "Bearer ${LocaleHandler.accessToken}"},
        body: jsonEncode({"latitude":latitude, "longitude":longitude}));
    if(response.statusCode==200){}
    else if(response.statusCode==401){showToastMsgTokenExpired();}
    else{Fluttertoast.showToast(msg: "Internal Server error");}
    notifyListeners();
  }



}