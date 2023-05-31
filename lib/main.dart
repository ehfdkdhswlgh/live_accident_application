import 'package:flutter/material.dart';
import 'package:live_accident_application/UserImfomation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'haechan/login.dart' as login;
import 'hojun/post.dart' as post;
import 'hojun/store.dart';
import 'hojun/top_rank.dart';
import 'hojun/write_report_demo.dart' as test;
import 'jihwan/post_report_management.dart';
import 'jihoon/map_sample.dart';
import 'jihwan/yh_news.dart';

import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'message.dart';

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

void main() async{
  WidgetsFlutterBinding.ensureInitialized(); //
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  runApp(
      MultiProvider( // privider를 위해 추가함 - 호준 4/16
        providers: [
          ChangeNotifierProvider(create: (c) => Store()),
        ],
        child: MaterialApp(
          routes: {
            '/': (context) => MyHomePage(),
            '/message': (context) => MessageView(),
          }
        ),
      )

  );
}
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}




class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  bool checker = UserImfomation.checker;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _goToPostScreen() {
    setState(() {
      _currentIndex = 1; // '제보글' 화면의 인덱스는 1입니다.
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        Navigator.pushNamed(context, '/message',
            arguments: MessageArguments(message, true));
      }
    });

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

  @override
  Widget build(BuildContext context) {
    Widget checker_widget;
    Widget bottomNavigationBarWidget;

    if (UserImfomation.checker == false) {
      checker_widget = login.Login();
    } else {
      checker_widget = MapSample(selectedType: context.watch<Store>().selectedPostType,);
    }

    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Live돌발사고"),
      //   centerTitle: true,
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.search),
      //       onPressed: () {
      //         // 돋보기 아이콘 클릭 시 동작 정의
      //       },
      //     ),
      //     IconButton(
      //       icon: Icon(Icons.account_circle),
      //       onPressed: () {
      //         // 내정보 아이콘 클릭 시 동작 정의
      //       },
      //     ),
      //   ],
      // ),
      body: [checker_widget, post.Post(),test.ReportWriteScreen(onReportSubmitted: _goToPostScreen),TopMember(), YHNews()][_currentIndex], //
      floatingActionButton: UserImfomation.athority == 'manager'
          ? FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportManagementScreen(),
                ),
              );
            },
            backgroundColor: Colors.red,
            child: Icon(
              Icons.notifications_active,
              color: Colors.white,
            ),
          )
        : null,
      bottomNavigationBar: UserImfomation.checker ? BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: '제보글',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: '랭킹',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: '보도자료',
          ),
        ],
      ): null,
    );
  }



}

