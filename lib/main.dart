import 'package:flutter/material.dart';
import 'package:live_accident_application/UserImfomation.dart';
import 'package:live_accident_application/hojun/post.dart';
import 'package:live_accident_application/hojun/post_main_document.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'haechan/login.dart' as login;
import 'haechan/report.dart' as report;
import 'haechan/profile.dart' as profile;
import 'haechan/account_management.dart' as account_management;
import 'hojun/post.dart' as post;
import 'hojun/store.dart';
import 'hojun/top_rank.dart';
import 'hojun/write_report_demo.dart' as test;
import 'jihwan/news.dart';
import 'jihwan/post_report.dart';
import 'jihwan/post_report_management.dart';
import 'jihwan/write_report.dart';
import 'jihoon/map_sample.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized(); //
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
      MultiProvider( // privider를 위해 추가함 - 호준 4/16
        providers: [
          ChangeNotifierProvider(create: (c) => Store()),
        ],
        child: MaterialApp(
            home: MyHomePage()
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



  @override
  Widget build(BuildContext context) {
    Widget checker_widget;
    Widget bottomNavigationBarWidget;

    if (UserImfomation.checker == false) {
      checker_widget = login.Login();
    } else {
      checker_widget = MapSample();
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
      body: [checker_widget, post.Post(),test.ReportWriteScreen(),TopMember(),News()]
      [_currentIndex],
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

// Widget build(BuildContext context) {
//   return Scaffold(
//       body: StreamBuilder(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (BuildContext context, snapshot) {
//           if (!snapshot.hasData) {
//             // 데이터가 있는 경우
//             return MapSample();
//           } else {
//             return MapSample();
//           }
//         },
//       )
//   );
// }
