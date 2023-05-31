import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'message.dart';
import 'message_list.dart';
import 'permissions.dart';
import 'token_monitor.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description: 'This channel is used for important notifications.', // description
  importance: Importance.high,
);

/// Initialize the [FlutterLocalNotificationsPlugin] package.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();


//보내는 메시지 형식
//"to" : "/topics/새로운형식"으로 사용
/// The API endpoint here accepts a raw FCM payload for demonstration purposes.
String constructFCMPayload(String post_id) {
  return jsonEncode({
    "to" : "/topics/hojun",
    'data': {
      'via': 'FlutterFire Cloud Messaging!!!',
      'post_id': post_id,
    },
    'notification': {
      'title': 'LIVE Accident!!',
      'body': '초비상!!!!!!!',
    },
  });
}


class Application {
  String _token = "";
  final String _serverKey = "AAAA2i-SWXA:APA91bEWfVsJxukDj9b7cJgMezjRl_SBNj3ey55SiYdhwH1mOxNfNjTSIkgPfOF0rlPyPDfI-DRDIr0UAw1YqG32wRUFSZ38CVnYO6AeA-qZGZLVMF7izh19n9oDHhmwqYdZa1WpCVoW";

  Future<void> sendPushMessage() async {
    if (_token == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }

    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key="AAAA2i-SWXA:APA91bEWfVsJxukDj9b7cJgMezjRl_SBNj3ey55SiYdhwH1mOxNfNjTSIkgPfOF0rlPyPDfI-DRDIr0UAw1YqG32wRUFSZ38CVnYO6AeA-qZGZLVMF7izh19n9oDHhmwqYdZa1WpCVoW"'
        },
        body: constructFCMPayload("5n0WBbvJgNO0bqkIgnM6febvPqD31684937410702117"),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
  }


  //구독자 버튼에 들어갈 내용
  Future<void> onActionSelected(String value) async {
    switch (value) {
      case 'subscribe':
        {
          print(
              'FlutterFire Messaging Example: Subscribing to topic "fcm_test".');
          await FirebaseMessaging.instance.subscribeToTopic('hojun');
          print(
              'FlutterFire Messaging Example: Subscribing to topic "fcm_test" successful.');
        }
        break;
      case 'unsubscribe':
        {
          print(
              'FlutterFire Messaging Example: Unsubscribing from topic "fcm_test".');
          await FirebaseMessaging.instance.unsubscribeFromTopic('hojun');
          print(
              'FlutterFire Messaging Example: Unsubscribing from topic "fcm_test" successful.');
        }
        break;
      case 'get_apns_token':
        {
          if (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS) {
            print('FlutterFire Messaging Example: Getting APNs token...');
            String? token = await FirebaseMessaging.instance.getAPNSToken();
            print('FlutterFire Messaging Example: Got APNs token: $token');
          } else {
            print(
                'FlutterFire Messaging Example: Getting an APNs token is only supported on iOS and macOS platforms.');
          }
        }
        break;
      default:
        break;
    }
  }

  Future<void> subscribe(String uid) async {
    print('FlutterFire Messaging Example: Subscribing to topic "fcm_test".');
    await FirebaseMessaging.instance.subscribeToTopic(uid);
    print('FlutterFire Messaging Example: Subscribing to topic "fcm_test" successful.');

  }

  Future<void> unSubscribe(String uid) async {
    print('FlutterFire Messaging Example: Subscribing to topic "fcm_test".');
    await FirebaseMessaging.instance.unsubscribeFromTopic(uid);
    print('FlutterFire Messaging Example: Subscribing to topic "fcm_test" successful.');
  }
}

/// UI Widget for displaying metadata.
class MetaCard extends StatelessWidget {
  final String _title;
  final Widget _children;

  // ignore: public_member_api_docs
  MetaCard(this._title, this._children);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(left: 8, right: 8, top: 8),
        child: Card(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child:
                      Text(_title, style: const TextStyle(fontSize: 18))),
                  _children,
                ]))));
  }
}