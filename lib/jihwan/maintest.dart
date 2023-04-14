import 'package:flutter/material.dart';
import 'news.dart';
import 'post_report.dart';
import 'post_report_management.dart';
import 'write_report.dart';

void main() {
  runApp(
      MaterialApp(
          home: MyHomePage()
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
      body: Container(


        //-------------------------------------------------------------------여기를 교체-----------------------------------------------------------------------

        //child: News(),   //보도자료 조회

        //child: ReportScreen(name : "출근하기 귀찮네"), //게시글 신고

        //child: ReportManagementScreen(), //제보글 관리 화면

        child: ReportWriteScreen(), //제보글 작성 화면
        //애뮬레이터 실행시 오류날 시 https://www.youtube.com/watch?v=bTyLehofqvk
        //https://www.flutterbeads.com/change-android-minsdkversion-in-flutter/

        //---------------------------------------------------------------------------------------------------------------------------------------------------

      ),
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