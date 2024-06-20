import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/prefs.dart';
import 'package:slush/screens/events/bottomNavigation.dart';
import 'package:slush/screens/getstarted/slider_scree.dart';
import 'package:slush/screens/onboarding/introscreen.dart';
import 'package:slush/screens/sign_up/details.dart';
import 'package:slush/screens/splash/splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;

  // List<BiometricType>? _availableBiometrics;
  // String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  @override
  void initState() {
    callFunction();
    auth.isDeviceSupported().then((bool isSupported) => setState(() => _supportState = isSupported ?
    _SupportState.supported : _SupportState.unsupported));
    super.initState();
  }

  void openBio() {
    if (_supportState == _SupportState.supported) {//_getAvailableBiometrics();
    Provider.of<SplashController>(context,listen: false).getAvailableBiometrics();
    }
  }

  void callFunction() async {
    String alreadyIn = "";
    LocaleHandler.bioAuth2=await Preferences.getValue("BioAuth")??"";
    alreadyIn = await Preferences.getValue("tutorialScreen") ?? "";
    LocaleHandler.accessToken = await Preferences.getValue("token") ?? "";
    LocaleHandler.refreshToken = await Preferences.getrefreshToken() ?? "";
    LocaleHandler.nextAction = await Preferences.getNextAction() ?? "";
    // LocaleHandler.nextDetailAction = await Preferences.getNextDetailAction() ?? "";
    LocaleHandler.emailVerified = await Preferences.getValue("emailVerified") ?? "";
    // LocaleHandler.name = await Preferences.getValue("name") ?? "";
    // LocaleHandler.location = await Preferences.getValue("location") ?? "";
    LocaleHandler.userId = await Preferences.getValue("userId") ?? "";
    // LocaleHandler.role = await Preferences.getValue("role") ?? "";
    // LocaleHandler.subscriptionPurchase = await Preferences.getValue("subscriptionPurchase") ?? "";
    // LocaleHandler.avatar = await Preferences.getValue("avatar") ?? "";
    // var itemss=await Preferences.getValue("EventIds")??"";
    // LocaleHandler.latitude=await Preferences.getValue("latitude")??"";
    // LocaleHandler.longitude=await Preferences.getValue("longitude")??"";
    // if(itemss!=""){LocaleHandler.items=jsonDecode(itemss);}
    print(LocaleHandler.accessToken);
    Future.delayed(const Duration(seconds: 3), () {
      if (alreadyIn == "done") {
        if (LocaleHandler.accessToken != "") {
          if (LocaleHandler.emailVerified == "true") {
            if (LocaleHandler.nextAction == "none") {
              Provider.of<SplashController>(context, listen: false).getProfileDetails(context, LocaleHandler.userId);
              Get.offAll(() => BottomNavigationScreen());}
            else {Get.offAll(() => const SliderScreen());}}
          else {Get.offAll(() => const SliderScreen());}}
        else {Get.offAll(() => const SliderScreen());}
      }
      else {Get.offAll(() => const IntroScreen());}
      if(LocaleHandler.bioAuth2=="true"){ openBio();}
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            Image.asset(AssetsPics.splash, fit: BoxFit.fill),
            Center(
                child: Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(AssetsPics.splashp, height: 100),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}
