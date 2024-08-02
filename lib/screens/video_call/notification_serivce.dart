import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:slush/screens/video_call/videoCall.dart';
// import 'video_call.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permissions for iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message in the foreground: ${message.messageId}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // Show a dialog or notification to the user
        _showCallDialog(message.notification?.title ?? '', message.notification?.body ?? '', message.data);
      }
    });

    // Handle background and terminated state messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
      // Navigate to call screen or show notification
      _navigateToCallScreen(message.data);
    });
  }

  void _showCallDialog(String title, String body, Map<String, dynamic> data) {
    showDialog(
      context: navigatorKey.currentState!.context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: <Widget>[
            TextButton(
              child: Text('Reject'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Accept'),
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToCallScreen(data);
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToCallScreen(Map<String, dynamic> data) {
    navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (context) => VideoCallScreen(
          // channelName: data['channelName'],
          // token: data['token'],
        ),
      ),
    );
  }

  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
