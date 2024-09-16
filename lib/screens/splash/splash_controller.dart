import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/screens/login/login.dart';

class SplashController extends ChangeNotifier {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticating = false;
  int _age = 0;

  int get age => _age;

  bool get isAuthenticating => _isAuthenticating;

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
        localizedReason: 'Enter phone screen lock pattern, PIN, password or fingerprint',
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } on PlatformException catch (e) {
      print(e);
      LocaleHandler.bioAuth = true;
      return;
    }
    if (authenticated) {LocaleHandler.bioAuth = false;}
    else {LocaleHandler.bioAuth = true;}
    notifyListeners();
    // if (!mounted) {return;}
  }

  Future<void> checkInterenetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        LocaleHandler.noInternet = false;
      }
    } on SocketException catch (_) {
      LocaleHandler.noInternet = true;
    }
    notifyListeners();
  }

  Future getProfileDetails(BuildContext context, String userId) async {
    final url = ApiList.getUser + userId;
    print(url);
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${LocaleHandler.accessToken}'
      });
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        LocaleHandler.dataa = data["data"] ?? "";
        LocaleHandler.name = data["data"]["firstName"] ?? data["data"]["email"] ?? "";
        LocaleHandler.avatar = data["data"]["avatar"] ?? "";
        LocaleHandler.gender = data["data"]["gender"] ?? "male";
        LocaleHandler.subscriptionPurchase = data["data"]["isSubscriptionPurchased"] ?? "no";
        _age = calculateAge(data["data"]["dateOfBirth"].toString());
        LocaleHandler.isVerified = data["data"]["isVerified"] ?? false;
      } else if (response.statusCode == 401) {
        Get.offAll(() => const LoginScreen());
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
    notifyListeners();
  }

  int calculateAge(String dobString) {
    DateTime dob = DateTime.parse(dobString);
    DateTime now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }
}
