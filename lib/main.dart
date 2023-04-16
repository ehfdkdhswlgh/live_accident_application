import 'package:flutter/material.dart';
import 'package:live_accident_application/hojun/post.dart';
import 'haechan/login.dart' as login;
import 'haechan/report.dart' as report;
import 'hojun/feed.dart';
import 'hojun/store.dart';
import 'package:provider/provider.dart';

void main() {
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

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Live돌발사고"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // 돋보기 아이콘 클릭 시 동작 정의
            },
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // 내정보 아이콘 클릭 시 동작 정의
            },
          ),
        ],
      ),
      body: [Post()][0],
      bottomNavigationBar: BottomNavigationBar(
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
      ),
    );
  }
}