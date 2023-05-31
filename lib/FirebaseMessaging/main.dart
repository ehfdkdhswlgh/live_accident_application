// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

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

/// Define a top-level named handler which background/terminated messages will
/// call.
///
/// To verify things are working, check out the native platform logs.
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(MessagingExampleApp());
}

/// Entry point for the example application.
class MessagingExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Messaging Example App',
      theme: ThemeData.dark(),
      routes: {
        '/': (context) => Application(),
        '/message': (context) => MessageView(),
      },
    );

  }
}

// Crude counter to make messages unique

//보내는 메시지 형식
//"to" : "/topics/새로운형식"으로 사용
/// The API endpoint here accepts a raw FCM payload for demonstration purposes.
String constructFCMPayload(String postId, String imageUrl, String postMain, String userNickname, String title, String userId, int like, String address) {
  final now = DateTime.now();
  final timestamp = now.millisecondsSinceEpoch;
  return jsonEncode({
    "to" : "/topics/hojun",
    'data': {
      'postId': postId,
      'imageUrl': imageUrl,
      'postMain': postMain,
      'userNickname': userNickname,
      'postName': title,
      'userId': userId,
      'timestamp': timestamp,
      'like': like,
      'address': address,
    },
    'notification': {
      'title': 'LIVE Accident!!',
      'body': title,
    },
  });
}

/// Renders the example application.
class Application extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Application();
}

class _Application extends State<Application> {
  String _token = "";
  final String _serverKey = "AAAA2i-SWXA:APA91bEWfVsJxukDj9b7cJgMezjRl_SBNj3ey55SiYdhwH1mOxNfNjTSIkgPfOF0rlPyPDfI-DRDIr0UAw1YqG32wRUFSZ38CVnYO6AeA-qZGZLVMF7izh19n9oDHhmwqYdZa1WpCVoW";
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      if (message != null) {
        Navigator.pushNamed(context, '/message',
            arguments: MessageArguments(message, true));
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                // TODO add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                icon: 'launch_background',
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      Navigator.pushNamed(context, '/message',
          arguments: MessageArguments(message, true));
    });

  }

  Future<void> sendPushMessage() async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=$_serverKey'
        },
        body: constructFCMPayload(
          'i0ycGkQl94dWeUG0YC1nTimLEP131685096361619653',
          'https://firebasestorage.googleapis.com/v0/b/live-accident.appspot.com/o/images%2F42a86e9b-c843-425c-aa2a-2469f6a20a25?alt=media&token=3ebfe1a1-2bf2-4fc9-9bc1-d02a93c345ef,https://firebasestorage.googleapis.com/v0/b/live-accident.appspot.com/o/images%2F105c6fec-56ee-444d-8bc2-77dbdb815637?alt=media&token=8ad6b3b4-7197-4908-a1ff-a3640ef57664',
          '판쵸우비상!!!!!!!!!!',
          'hojun',
          '비상!!!!!!!',
          'i0ycGkQl94dWeUG0YC1nTimLEP13',
          0,
          '대한민국 경상북도 경산시 진량읍 내리리 108-5번지 KR'
        ),
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
            String token = await FirebaseMessaging.instance.getAPNSToken();
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Messaging'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: onActionSelected,
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'subscribe',
                  child: Text('Subscribe to topic'),
                ),
                const PopupMenuItem(
                  value: 'unsubscribe',
                  child: Text('Unsubscribe to topic'),
                ),
                const PopupMenuItem(
                  value: 'get_apns_token',
                  child: Text('Get APNs token (Apple only)'),
                ),
              ];
            },
          ),
        ],
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          onPressed: sendPushMessage,
          backgroundColor: Colors.white,
          child: const Icon(Icons.send),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          MetaCard('Permissions', Permissions()),
          MetaCard('FCM Token', TokenMonitor((token) {
            _token = token;
            return token == null
                ? const CircularProgressIndicator()
                : Text(token, style: const TextStyle(fontSize: 12));
          })),
          MetaCard('Message Stream', MessageList()),
        ]),
      ),
    );
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