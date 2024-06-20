import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart'as http;
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/controller/controller.dart';
import 'package:slush/screens/login/login.dart';

import '../../widgets/toaster.dart';

class SplashController extends ChangeNotifier{
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticating = false;
  bool get isAuthenticating=>_isAuthenticating;


  Future<void> getAvailableBiometrics() async {
    late List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
      authenticate();
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      print(e);
    }
    print("availableBiometrics$availableBiometrics");
    notifyListeners();
    // if (!mounted) {return;}
  }

  Future<void> authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Enter phoe screen lock pattern, PIN, password or fingerprint',
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } on PlatformException catch (e) {
      print(e);
      LocaleHandler.bioAuth = true;
      notifyListeners();
      return;
    }
    if (authenticated) {LocaleHandler.bioAuth = false;print("Welcome");
    notifyListeners();
    }
    else {LocaleHandler.bioAuth = true;print(" NO Welcome ji");
    notifyListeners();}
    // if (!mounted) {return;}
  }

  Future<void> checkInterenetConnection()async{
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        LocaleHandler.noInternet=false;
      }
    } on SocketException catch (_) {
     LocaleHandler.noInternet=true;
    }
    notifyListeners();
  }





  Future getProfileDetails(BuildContext context,String userId) async {
    final url = ApiList.getUser + userId;
    print(url);
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${LocaleHandler.accessToken}'
      });
      if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      // My.i=data["data"];
      LocaleHandler.dataa=data["data"];
      LocaleHandler.name=data["data"]["firstName"];
      LocaleHandler.avatar=data["data"]["avatar"];
      // age= calculateAge(data["data"]["dateOfBirth"].toString());
      // usergender=data["data"]["gender"];
      // location=data["data"]["state"]+", "+data["data"]["country"];
      // userSexuality=data["data"]["sexuality"];
      LocaleHandler.gender=data["data"]["gender"];
      LocaleHandler.subscriptionPurchase=data["data"]["isSubscriptionPurchased"];
      if(data["data"]["isVerified"]==null){LocaleHandler.isVerified = false;}
      else{LocaleHandler.isVerified=data["data"]["isVerified"];}
      }
      else if (response.statusCode == 401) {Get.offAll(()=>LoginScreen());}
      else {throw Exception('Failed to load data');}
    } catch (e) {throw Exception('Failed to fetch data: $e');}
    notifyListeners();
  }
}

