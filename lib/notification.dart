import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
