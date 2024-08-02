import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:slush/controller/chat_provider.dart';
import 'package:slush/controller/controller.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/controller/create_account_controller.dart';
import 'package:slush/controller/detail_controller.dart';
import 'package:slush/controller/edit_profile_controller.dart';
import 'package:slush/controller/event_controller.dart';
import 'package:slush/controller/login_controller.dart';
import 'package:slush/controller/profile_controller.dart';
import 'package:slush/controller/setting_controller.dart';
import 'package:slush/controller/video_call_controller.dart';
import 'package:slush/controller/waitingroom_controller.dart';
import 'package:slush/firebase_option.dart';
import 'package:slush/screens/feed/tutorials/controller_class.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:slush/screens/splash/splash.dart';
import 'package:slush/screens/splash/splash_controller.dart';
import 'package:slush/screens/video_call/notification_serivce.dart';
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      name: 'virtual-speed-date-325915',
      options: DefaultFirebaseOptions.currentPlatform);
  InAppPurchase.instance.restorePurchases();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
   return ResponsiveSizer(
       builder: (context, orientation, screenType){
     return MultiProvider(
       providers: [
         // Create Account
         ChangeNotifierProvider(create: (_)=>SplashController()),
         ChangeNotifierProvider<createAccountController>(create: (_)=>createAccountController()),
         //details Screen
         ChangeNotifierProvider<detailedController>(create: (_)=>detailedController()),
         // profile
         ChangeNotifierProvider<profileController>(create: (_)=>profileController()),
         //event
         ChangeNotifierProvider<eventController>(create: (_)=>eventController()),
         // Update profile
         ChangeNotifierProvider<editProfileController>(create: (_)=>editProfileController()),
         // match
         // ChangeNotifierProvider<matchController>(create: (_)=>matchController()),
         ChangeNotifierProvider<reelTutorialController>(create: (_)=>reelTutorialController()),
         ChangeNotifierProvider<nameControllerr>(create: (_)=>nameControllerr()),
         ChangeNotifierProvider<reelController>(create: (_)=>reelController()),
         //login
         ChangeNotifierProvider<loginControllerr>(create: (_)=>loginControllerr()),
         //waitingRoom
         ChangeNotifierProvider<waitingRoom>(create: (_)=>waitingRoom()),
         ChangeNotifierProvider<TimerProvider>(create: (_)=>TimerProvider()),
         ChangeNotifierProvider<SettingController>(create: (_)=>SettingController()),


       ],
       child: GetMaterialApp(
         title: 'Flutter Demo',
         theme: ThemeData(
           colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
           // colorScheme: ColorScheme,
           useMaterial3: true),
         debugShowCheckedModeBanner: false,
         navigatorKey: navigatorKey,
         home: const SplashScreen(),
         // home: ReadyToCallScreen(data: "sasa"),
       ),
     );
   });
  }
}

