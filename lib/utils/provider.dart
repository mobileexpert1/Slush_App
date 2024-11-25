import 'package:slush/controller/create_account_controller.dart';
import 'package:slush/controller/detail_controller.dart';
import 'package:slush/controller/edit_profile_controller.dart';
import 'package:slush/controller/event_controller.dart';
import 'package:slush/controller/login_controller.dart';
import 'package:slush/controller/notification_setting_controller.dart';
import 'package:slush/controller/profile_controller.dart';
import 'package:slush/controller/setting_controller.dart';
import 'package:slush/controller/spark_Liked_controler.dart';
import 'package:slush/controller/video_call_controller.dart';
import 'package:slush/controller/waitingroom_controller.dart';
import 'package:provider/provider.dart';
import 'package:slush/screens/feed/tutorials/controller_class.dart';
import 'package:slush/screens/splash/splash_controller.dart';
import 'package:slush/controller/chat_controller.dart';
import 'package:slush/controller/controller.dart';

class ProvidersState {
  static List<ChangeNotifierProvider> getAllProviders() {
    return [
      // Create Account
      ChangeNotifierProvider<SplashController>(create: (_)=>SplashController()),
      ChangeNotifierProvider<createAccountController>(create: (_)=>createAccountController()),
      //details Screen
      ChangeNotifierProvider<detailedController>(create: (_)=>detailedController()),
      // profile
      ChangeNotifierProvider<profileController>(create: (_)=>profileController()),
      //event
      ChangeNotifierProvider<eventController>(create: (_)=>eventController()),
      // Update profile
      ChangeNotifierProvider<editProfileController>(create: (_)=>editProfileController()),
      ChangeNotifierProvider<ChatController>(create: (_)=>ChatController()),
      // match
      // ChangeNotifierProvider<matchController>(create: (_)=>matchController()),
      ChangeNotifierProvider<reelTutorialController>(create: (_)=>reelTutorialController()),
      ChangeNotifierProvider<nameControllerr>(create: (_)=>nameControllerr()),
      ChangeNotifierProvider<ReelController>(create: (_)=>ReelController()),
      //login
      ChangeNotifierProvider<loginControllerr>(create: (_)=>loginControllerr()),
      //waitingRoom
      ChangeNotifierProvider<waitingRoom>(create: (_)=>waitingRoom()),
      ChangeNotifierProvider<TimerProvider>(create: (_)=>TimerProvider()),
      ChangeNotifierProvider<SettingController>(create: (_)=>SettingController()),
      ChangeNotifierProvider<SparkLikedController>(create: (_)=>SparkLikedController()),
      ChangeNotifierProvider<CamController>(create: (_)=>CamController()),
      ChangeNotifierProvider<NotificationSettingController>(create: (_)=>NotificationSettingController()),
    ];
  }
}