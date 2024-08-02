import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/prefs.dart';
import 'package:slush/controller/event_controller.dart';
import 'package:slush/controller/profile_controller.dart';
import 'package:slush/screens/events/bottomNavigation.dart';
import 'package:slush/screens/getstarted/slider_scree.dart';
import 'package:slush/screens/onboarding/introscreen.dart';
import 'package:slush/screens/splash/splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;

  @override
  void initState() {
    callFunction();
    auth.isDeviceSupported().then((bool isSupported) => setState(() => _supportState = isSupported ?
    _SupportState.supported : _SupportState.unsupported));
    super.initState();
  }

  void openBio() {
    if (_supportState == _SupportState.supported) { //_getAvailableBiometrics();
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
    LocaleHandler.emailVerified = await Preferences.getValue("emailVerified") ?? "";
    LocaleHandler.userId = await Preferences.getValue("userId") ?? "";
    print(LocaleHandler.accessToken);
    Future.delayed(const Duration(seconds: 3), () {
      if (alreadyIn == "done") {
        if (LocaleHandler.accessToken != "") {
          if (LocaleHandler.emailVerified == "true") {
            if (LocaleHandler.nextAction == "none") {
              Provider.of<SplashController>(context, listen: false).getProfileDetails(context, LocaleHandler.userId);
              Provider.of<eventController>(context, listen: false).getmeEvent(context,"me");
              Provider.of<profileController>(context,listen: false).getTotalSparks();
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
            Center(child: Padding(
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
