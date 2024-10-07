import 'dart:convert';
import 'dart:io';

import 'package:agora_uikit/agora_uikit.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/prefs.dart';
import 'package:slush/controller/event_controller.dart';
import 'package:slush/controller/profile_controller.dart';
import 'package:slush/screens/events/bottomNavigation.dart';
import 'package:slush/screens/getstarted/slider_scree.dart';
import 'package:slush/screens/onboarding/introscreen.dart';
import 'package:slush/screens/sign_up/create_account.dart';
import 'package:slush/screens/splash/splash_controller.dart';

import '../../notification.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;


  String _debugLabelString = "";
  bool _enableConsentButton = false;
  // CHANGE THIS parameter to true if you want to test GDPR privacy consent
  bool _requireConsent = false;

  Future<void> initPlatformState() async {
    if (!mounted) return;
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.Debug.setAlertLevel(OSLogLevel.none);
    OneSignal.consentRequired(_requireConsent);
    OneSignal.initialize("482a292e-4c3a-48f0-ad0b-8b0f4b653fd8");

    OneSignal.LiveActivities.setupDefault();
    // OneSignal.LiveActivities.setupDefault(options: new LiveActivitySetupOptions(enablePushToStart: false, enablePushToUpdate: true));

    OneSignal.Notifications.clearAll();
    OneSignal.User.pushSubscription.addObserver((state) {
      print(OneSignal.User.pushSubscription.optedIn);
      print(OneSignal.User.pushSubscription.id);
      print(OneSignal.User.pushSubscription.token);
      print(state.current.jsonRepresentation());
    });
    OneSignal.User.addObserver((state) {var userState = state.jsonRepresentation();});
    OneSignal.Notifications.addPermissionObserver((state) {print("Has permission " + state.toString());});

    OneSignal.Notifications.addClickListener((event) {
      print('NOTIFICATION CLICK LISTENER CALLED WITH EVENT: $event');
      setState(() {
        _debugLabelString = "Clicked notification: \n${event.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      print('NOTIFICATION WILL DISPLAY LISTENER CALLED WITH: ${event.notification.jsonRepresentation()}');
      /// Display Notification, preventDefault to not display
      event.preventDefault();
      /// Do async work
      /// notification.display() to display after preventing default
      event.notification.display();
      setState(() {
        _debugLabelString = "Notification received in foreground notification: \n${event.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    OneSignal.InAppMessages.addClickListener((event) {setState(() {_debugLabelString = "In App Message Clicked: \n${event.result.jsonRepresentation().replaceAll("\\n", "\n")}";});});
    OneSignal.InAppMessages.addWillDisplayListener((event) {print("ON WILL DISPLAY IN APP MESSAGE ${event.message.messageId}");});
    OneSignal.InAppMessages.addDidDisplayListener((event) {print("ON DID DISPLAY IN APP MESSAGE ${event.message.messageId}");});
    OneSignal.InAppMessages.addWillDismissListener((event) {print("ON WILL DISMISS IN APP MESSAGE ${event.message.messageId}");});
    OneSignal.InAppMessages.addDidDismissListener((event) {print("ON DID DISMISS IN APP MESSAGE ${event.message.messageId}");});

    setState(() {_enableConsentButton = _requireConsent;});

    // Some examples of how to use In App Messaging public methods with OneSignal SDK
    // oneSignalInAppMessagingTriggerExamples();
    // Some examples of how to use Outcome Events public methods with OneSignal SDK
    // oneSignalOutcomeExamples();
    OneSignal.InAppMessages.paused(true);
  }

  @override
  void initState() {
    _initDynamicLinks();
    callFunction();
    _register();
    // firebaseNotificationHandling();
    auth.isDeviceSupported().then((bool isSupported) => _supportState = isSupported ? _SupportState.supported : _SupportState.unsupported);
    // initPlatformState();
    super.initState();
  }

// calling biometrics
  void openBio() {
    if (_supportState == _SupportState.supported) {
      Provider.of<SplashController>(context, listen: false).getAvailableBiometrics();
    }
  }

  // genearte FCM
  _register() {
    if (LocaleHandler.fcmToken == "") {
      FirebaseMessaging.instance.getToken().then((value) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("fcmToken", value!);
        if (mounted) {LocaleHandler.fcmToken = prefs.getString("fcmToken")!;}
        print("fcmToken===========>>>   ${LocaleHandler.fcmToken}");
      });
    }
  }

  String jsonString="";
  // function to check user navigation scnerio
  void callFunction() async {
    String alreadyIn = "";
    LocaleHandler.bioAuth2 = await Preferences.getValue("BioAuth") ?? "";
    alreadyIn = await Preferences.getValue("tutorialScreen") ?? "";
    LocaleHandler.accessToken = await Preferences.getValue("token") ?? "";
    LocaleHandler.refreshToken = await Preferences.getrefreshToken() ?? "";
    LocaleHandler.nextAction = await Preferences.getNextAction() ?? "";
    LocaleHandler.emailVerified = await Preferences.getValue("emailVerified") ?? "";
    LocaleHandler.userId = await Preferences.getValue("userId") ?? "";
    LocaleHandler.socialLogin = await Preferences.getValue("socialLogin") ?? "";
    print(LocaleHandler.accessToken);
    Future.delayed(const Duration(seconds: 3), () async {
      if (alreadyIn == "done") {
        if (LocaleHandler.accessToken != "") {
          if (LocaleHandler.emailVerified == "true" || LocaleHandler.socialLogin=="yes") {
            if (LocaleHandler.nextAction == "none") {
              Provider.of<SplashController>(context, listen: false).getProfileDetails(context, LocaleHandler.userId);
              Provider.of<eventController>(context, listen: false).getmeEvent(context, "me");
              Provider.of<profileController>(context, listen: false).getTotalSparks();
              Get.offAll(() => BottomNavigationScreen());
              jsonString = await Preferences.getValue('filterList')??"";
              getFeedFilter();
              initPlatformState();
            } else {
              Get.offAll(() => const SliderScreen());
            }
          } else {
            Get.offAll(() => const SliderScreen());
          }
        } else {
          Get.offAll(() => const SliderScreen());
        }
      } else {
        Get.offAll(() => const IntroScreen());
      }
      if (LocaleHandler.bioAuth2 == "true") {
        openBio();
      }
    });
  }

  void getFeedFilter(){
    if (jsonString != "") {
      List<dynamic> jsonList = jsonDecode(jsonString);
      LocaleHandler.selectedIndexGender=jsonList[0];
    LocaleHandler.startage=jsonList[1];
    LocaleHandler.endage=jsonList[2];
    LocaleHandler.distancevalue=jsonList[3];
    LocaleHandler.isChecked=jsonList[4];
    if(LocaleHandler.selectedIndexGender==0){LocaleHandler.filtergender="male";}
    else if(LocaleHandler.selectedIndexGender==1){LocaleHandler.filtergender="female";}
    else {LocaleHandler.filtergender="";}
    }
  }

  // Deep link
  Future<void> _initDynamicLinks() async {
    final PendingDynamicLinkData? data = await FirebaseDynamicLinksPlatform.instance.getInitialLink();
    _handleDynamicLink(data);

    FirebaseDynamicLinksPlatform.instance.onLink.listen((dynamicLinkData) {
      _handleDynamicLink(dynamicLinkData);
    }).onError((error) {
      print('onLink error');
      print(error.message);
    });
  }

  void _handleDynamicLink(PendingDynamicLinkData? data) {
    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      Get.to(() => const CreateNewAccount());
      // Handle the deep link and navigate to the relevant screen
      print('Deep Link;-;-;-: ${deepLink.toString()}');
    }
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

  permission() async {
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {print("onMessage: $message");});
    } else {print('User declined or has not accepted permission');}
  }

  void firebaseNotificationHandling() {
    Permission.notification.request();
    permission();
    _register();

    LocalNotificationService.initialize(context);
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {}
    });
    //forground

    FirebaseMessaging.onMessage.listen((message) {
      LocalNotificationService.display(message);
    });

    FirebaseMessaging.onBackgroundMessage(backGroundHandler);

    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    //Background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
  }

  Future<void> backGroundHandler(RemoteMessage message) async {
    LocalNotificationService.display(message);
  }
}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}
