import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:live_accident_application/UserImfomation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'FirebaseMessaging/message.dart';
import 'firebase_options.dart';

import 'haechan/login.dart' as login;
import 'hojun/post.dart' as post;
import 'hojun/post_main_document.dart';
import 'hojun/store.dart';
import 'hojun/write_report_demo.dart' as test;
import 'jihwan/post_report_management.dart';
import 'jihoon/map_sample.dart';
import 'jihwan/yh_news.dart';

import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'jihwan/sms.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(
      MultiProvider( // privider를 위해 추가함 - 호준 4/16
        providers: [
          ChangeNotifierProvider(create: (c) => Store()),
        ],
        child: MaterialApp(
            routes: {
              '/': (context) => MyHomePage(),
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

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);


    //포그라운드 상태일 때
    FirebaseMessaging.onMessage.listen((RemoteMessage message)  async {
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
            ),
            payload: message.data.toString()
        );

      }
    });

    //백그라운드 상태일 때
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final MessageArguments args =
      ModalRoute
          .of(context)
          ?.settings
          .arguments as MessageArguments;
      RemoteMessage message = args.message;
      Map<String, dynamic> map = jsonDecode(message.data.toString());
      Navigator.push(
        context,
        MaterialPageRoute (
          builder: (BuildContext context) => PostDocument(
            postId: map['postId'],
            imageUrl: map['imageUrl'],
            postMain: map['postMain'],
            userNickname: map['userNickname'],
            postName: map['postName'],
            userId: map['userId'],
            timestamp: Timestamp.now(),
            like: 0,
            address: map['address'],
            profile: map['profileUrl'],
          ),
        ),
      );
    });

    //종료된 상태일 때
    // FirebaseMessaging.instance
    //     .getInitialMessage()
    //     .then((RemoteMessage message) async {
    //   Map<String, dynamic> map = jsonDecode(message.data.toString());
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute (
    //       builder: (BuildContext context) => PostDocument(
    //         postId: map['postId'],
    //         imageUrl: map['imageUrl'],
    //         postMain: map['postMain'],
    //         userNickname: map['userNickname'],
    //         postName: map['postName'],
    //         userId: map['userId'],
    //         timestamp: Timestamp.now(),
    //         like: 0,
    //         address: map['address'],
    //         profile: "",
    //       ),
    //     ),
    //   );
    // });

  }

  void onSelectNotification(String? payload) async {
    if (payload != null) {
      Map<String, dynamic> map = jsonDecode(payload);
      print(map);
      Navigator.push(
        context,
        MaterialPageRoute (
          builder: (BuildContext context) => PostDocument(
            postId: map['postId'],
            imageUrl: map['imageUrl'],
            postMain: map['postMain'],
            userNickname: map['userNickname'],
            postName: map['postName'],
            userId: map['userId'],
            timestamp: Timestamp.now(),
            like: 0,
            address: map['address'],
            profile: map['profileUrl'],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: SizedBox(
                height: 50.0,
                width: 50.0,
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        User? user = snapshot.data;

        if (user != null) {
          return FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('user')
                .where('uid', isEqualTo: user.uid)
                .limit(1)
                .get(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  backgroundColor: Colors.white,
                  body: Center(
                    child: SizedBox(
                      height: 50.0,
                      width: 50.0,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }

              if (userSnapshot.hasData && userSnapshot.data!.docs.isNotEmpty) {
                DocumentSnapshot documentSnapshot = userSnapshot.data!.docs.first;
                UserImfomation.uid = user.uid;
                // set other UserImfomation properties...
                UserImfomation.checker = true;
                UserImfomation.nickname = documentSnapshot.get('name').toString();
                UserImfomation.followCount = documentSnapshot.get('follow');
                UserImfomation.followingCount = documentSnapshot.get('following');
                UserImfomation.postCount = documentSnapshot.get('post_count');
                UserImfomation.athority = documentSnapshot.get('authority');

                print("다음 유저의 정보를 불러옴" + UserImfomation.nickname + " " + UserImfomation.athority + " " + UserImfomation.postCount.toString());




                return Scaffold(
                  body: [MapSample(selectedType: context.watch<Store>().selectedPostType,), post.Post(),test.ReportWriteScreen(onReportSubmitted: _goToPostScreen),Sms(), YHNews()][_currentIndex], //
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
                  bottomNavigationBar: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    currentIndex: _currentIndex,
                    onTap: _onTabTapped,
                    selectedItemColor: Colors.red,
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
                        icon: Icon(
                          Icons.add_box,
                          size: 35.0,
                        ),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.mail),
                        label: '재난문자',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.article),
                        label: '재난뉴스',
                      ),
                    ],
                  ),
                );
              } else {
                UserImfomation.checker = false;
                return login.Login();
              }
            },
          );
        } else {
          UserImfomation.checker = false;
          return login.Login();
        }
      },
    );
  }




}

