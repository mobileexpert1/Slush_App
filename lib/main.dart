import 'package:aws_rekognition_api/rekognition-2016-06-27.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/firebase_option.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:slush/screens/splash/splash.dart';
import 'package:slush/screens/video_call/notification_serivce.dart';
import 'package:slush/services/uniservice.dart';
import 'package:slush/utils/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'screens/sign_up/details/profile_video.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {print("Handling a background message: ${message.messageId}");}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(name: 'virtual-speed-date-325915', options: DefaultFirebaseOptions.currentPlatform);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await UniServices.init();
  // OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  // if(Platform.isAndroid){OneSignal.initialize("482a292e-4c3a-48f0-ad0b-8b0f4b653fd8");}
  // else{OneSignal.initialize("4cee1d81-6350-4319-970d-3421754c0fa7");}
  // OneSignal.Notifications.requestPermission(true);
  // OneSignal.User.pushSubscription.optIn();
  await InAppPurchase.instance.restorePurchases();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await MobileAds.instance.initialize();
  await WakelockPlus.enable();
  // FirebaseLocalNotification.initMessaging();
  final service = Rekognition(region: 'eu-west-2');
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
