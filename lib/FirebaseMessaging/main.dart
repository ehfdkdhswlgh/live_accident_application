import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  // 백그라운드에서 메세지 처리
  flutterLocalNotificationsPlugin.show(
      message.notification.hashCode,
      message.notification!.title,
      message.notification!.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id, channel.name, channelDescription: channel.description,
          icon: message.notification!.android!.smallIcon,
        ),
      ));

  print('Handling a background message ${message.messageId}');
}

/// 상단 알림을 위해 AndroidNotificationChannel 생성
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description: 'This channel is used for important notifications.', //description
  importance: Importance.high,
);

//FlutterLocalNotificationsPlugin 패키지 초기화
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 위에 정의한 백그라운드 메세지 처리 핸들러 연결
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler); // 백그라운드에서 동작하게 해줌
  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.

  // Android 알림 채널을 만듬
  // 상단 헤드업 알림을 활성화하는 기본 FCM 채널
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  runApp(MyApp());
}

// StatefulWidget 생성
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Android용 초기화 설정
    // 무조건 해야함 약속과 같음
    var initialzationsettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
    InitializationSettings(android: initialzationsettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // 포그라운드에서의 메세지처리
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                  channel.id, channel.name, channelDescription: channel.description,
                  // TODO add a proper drawable resource to android, for now using
                  //      one that already exists in example app.
                  icon: android.smallIcon //'launch_background',
              ),
            ));
      }
    });
    //토큰 받아옴
    getToken();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text("Hi"),
        ),
      ),
    );
  }

  // Token을 가져오는 함수 작성
  getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print(token);
  }
}