import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/firebase_option.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:slush/screens/splash/splash.dart';
import 'package:slush/screens/video_call/notification_serivce.dart';
import 'package:slush/services/uniservice.dart';
import 'package:slush/utils/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';


import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {print("Handling a background message: ${message.messageId}");}
// FirebaseAnalytics analytics = FirebaseAnalytics.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(name: 'virtual-speed-date-325915', options: DefaultFirebaseOptions.currentPlatform);
  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  UniServices.init();

  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  if(Platform.isAndroid){OneSignal.initialize(ApiList.android);}
  else{OneSignal.initialize(ApiList.ios);}
  OneSignal.Notifications.requestPermission(true);
  
  OneSignal.User.pushSubscription.optIn();
  InAppPurchase.instance.restorePurchases();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  MobileAds.instance.initialize();
  WakelockPlus.enable();
  // FirebaseLocalNotification.initMessaging();
  // final service = Rekognition(region: 'eu-west-2');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
        builder: (context, orientation, screenType){
          return MultiProvider(
            providers: ProvidersState.getAllProviders(),
            child: GetMaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
              debugShowCheckedModeBanner: false,
              navigatorKey: navigatorKey,
              home: const SplashScreen(),
              // home: DeatilProfileVideoScreen(),
            ),
          );
        });
  }
}
