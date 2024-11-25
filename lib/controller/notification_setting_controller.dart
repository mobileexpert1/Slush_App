import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:http/http.dart' as http;
import 'package:slush/constants/loader.dart';
import 'package:slush/widgets/toaster.dart';

class NotificationSettingController extends ChangeNotifier {

  Future<void> setNotificationSettings(BuildContext context,String type, int i) async {
    LoaderOverlay.show(context);
    const url = ApiList.notificationSetting;
    print(url);
    var uri = Uri.parse(url);
    try {
      var response = await http.post(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${LocaleHandler.accessToken}'
      }, body: jsonEncode({
            "notificationType": type,
            "status": i
          }));
      LoaderOverlay.hide();
      print("notiSet-${response.statusCode}");
      if (response.statusCode == 201) {print(jsonDecode(response.body));}
      else {Fluttertoast.showToast(msg: 'Something Went Wrong');}
    }
    catch (e){
      LoaderOverlay.hide();
      Fluttertoast.showToast(msg: 'Something Went Wrong');}
    notifyListeners();
  }

   String checkType(int index){
    switch (index) {
      case 0:
        return "match";
        break;
      case 1:
        return "event";
        break;
      case 2:
        return "message";
        break;
      case 3:
        return "like";
        break;
      default:
        return "";
    }
  }
  
}
