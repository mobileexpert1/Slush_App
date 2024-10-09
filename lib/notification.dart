import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class FirebaseLocalNotification {
  //TODO Permission for USer notification
  static FirebaseMessaging fmessaging = FirebaseMessaging.instance;

  //TODO Code to show notification on foreground
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static late FlutterLocalNotificationsPlugin fltNotification;

  static Future<void> initMessaging() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
    );
    // await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
    var androiInit = const AndroidInitializationSettings("@mipmap/ic_launcher");
    var initializationSettingsIOS =
    DarwinInitializationSettings(defaultPresentAlert: true,defaultPresentBadge: true,defaultPresentBanner: true,defaultPresentSound: true);
    // var iosInit = IOSInitializationSettings();
    const DarwinNotificationDetails iosNotificationDetails =
    DarwinNotificationDetails(
      categoryIdentifier: "Slush",
      presentAlert: true,
      presentSound: true,

    );
    var initSetting = InitializationSettings(android: androiInit,iOS: initializationSettingsIOS);
    fltNotification = FlutterLocalNotificationsPlugin();
    fltNotification.initialize(initSetting,onDidReceiveNotificationResponse: (NotificationResponse notify)async{

    });
    var androidDetails = const AndroidNotificationDetails(
      "Slush",
      "Slush",
      channelDescription: "Slush",
      importance: Importance.max,
      priority: Priority.high,
    );





    var generalNotificationDetails = NotificationDetails(android: androidDetails,iOS: iosNotificationDetails);
    FirebaseMessaging.onMessage.listen((RemoteMessage fffmessage) {
      RemoteNotification? notification = fffmessage.notification;
      AndroidNotification? android = fffmessage.notification?.android;
      // if (notification != null && android != null) {
      //   print("OnTApped====>");
      //   // fltNotification.show(notification.hashCode, notification.title,
      //   //     notification.body, generalNotificationDetails
      //   );
      // }
    });
  }
  // DocumentSnapshot userData = await FirebaseFirestore.instance.collection("chats").doc("widget.product").collection("sasazzzz").doc("dsd").get();

}



class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static void initialize(BuildContext context) {
    final InitializationSettings initializationSettings =
    InitializationSettings(
        android: const AndroidInitializationSettings("@mipmap/ic_launcher"),
        iOS: DarwinInitializationSettings(
            defaultPresentAlert: true,defaultPresentBadge: true,defaultPresentBanner: true,defaultPresentSound: true,
            // requestSoundPermission: false,
            // requestBadgePermission: false,
            // requestAlertPermission: false,
            onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
              print("sasasassa");
            }
        ));
    // _notificationsPlugin.initialize(initializationSettings,
    //   onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
    //     final String? payload = notificationResponse.payload;
    //     if (payload != null) {
    //       // Get.toNamed(payload);
    //     }
    //   },);
  }

  static void display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "Slush",
          "Slush",
          channelDescription: "Slush",
          importance: Importance.max,
          priority: Priority.high,
        ),
        //     iOS: DarwinNotificationDetails(
        //   categoryIdentifier: "Guard Demand",
        //   presentAlert: true,
        //   presentSound: true,
        // )
      );
      await _notificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: message.data["route"],
      );
    } on Exception catch (e) {
      print(e);
    }
  }
}


class OnesignalNotificationNavigation{
  String _debugLabelString = "";
  bool _enableConsentButton = false;
  bool _requireConsent = false;

  Future<void> initPlatformState() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.Debug.setAlertLevel(OSLogLevel.none);
    OneSignal.consentRequired(_requireConsent);
    // OneSignal.initialize("482a292e-4c3a-48f0-ad0b-8b0f4b653fd8");
    if(Platform.isAndroid){OneSignal.initialize("482a292e-4c3a-48f0-ad0b-8b0f4b653fd8");}
    else{OneSignal.initialize("4cee1d81-6350-4319-970d-3421754c0fa7");}
    OneSignal.Notifications.requestPermission(true);
    OneSignal.User.pushSubscription.optIn();
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
        _debugLabelString = "Clicked notification: \n${event.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
    });

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      print('NOTIFICATION WILL DISPLAY LISTENER CALLED WITH: ${event.notification.jsonRepresentation()}');
      /// Display Notification, preventDefault to not display
      event.preventDefault();
      /// Do async work
      /// notification.display() to display after preventing default
      event.notification.display();
        _debugLabelString = "Notification received in foreground notification: \n${event.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
    });

    OneSignal.InAppMessages.addClickListener((event) {_debugLabelString = "In App Message Clicked: \n${event.result.jsonRepresentation().replaceAll("\\n", "\n")}";});
    OneSignal.InAppMessages.addWillDisplayListener((event) {print("ON WILL DISPLAY IN APP MESSAGE ${event.message.messageId}");});
    OneSignal.InAppMessages.addDidDisplayListener((event) {print("ON DID DISPLAY IN APP MESSAGE ${event.message.messageId}");});
    OneSignal.InAppMessages.addWillDismissListener((event) {print("ON WILL DISMISS IN APP MESSAGE ${event.message.messageId}");});
    OneSignal.InAppMessages.addDidDismissListener((event) {print("ON DID DISMISS IN APP MESSAGE ${event.message.messageId}");});

    _enableConsentButton = _requireConsent;

    // Some examples of how to use In App Messaging public methods with OneSignal SDK
    // oneSignalInAppMessagingTriggerExamples();
    // Some examples of how to use Outcome Events public methods with OneSignal SDK
    // oneSignalOutcomeExamples();
    OneSignal.InAppMessages.paused(true);
  }
}
