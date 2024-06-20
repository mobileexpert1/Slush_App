import 'dart:convert';
import 'package:http/http.dart'as http;
import 'package:flutter/cupertino.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/loader.dart';

class matchController extends ChangeNotifier{

  var dataa;
  get data=>dataa;

  Future getListData(BuildContext context, String apiUrl)async{
    LoaderOverlay.show(context);
    final url= apiUrl;
    print(url);
    var uri=Uri.parse(url);
    var response=await http.get(uri,headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${LocaleHandler.accessToken}'});
    var i=jsonDecode(response.body)["data"];
    LoaderOverlay.hide();
    if(response.statusCode==200){
      dataa=i;
      notifyListeners();
    } else {}
    notifyListeners();
  }
}