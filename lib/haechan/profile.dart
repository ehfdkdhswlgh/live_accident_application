import 'package:flutter/material.dart';
import 'account_management.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("회원 정보"),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountManagementScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 32.0,
                  backgroundImage: AssetImage('images/profile1.png'), // 프로필 이미지
                ),
                SizedBox(width: 16.0),
                Expanded(
                  flex: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "사용자 닉네임", // 닉네임
                        style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start, // 오른쪽 정렬
                        children: [
                          Text(
                            "게시물 200", // 게시물 수
                            style: TextStyle(fontSize: 16.0),
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            "팔로워 100", // 팔로워 수
                            style: TextStyle(fontSize: 16.0),
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            "팔로잉 50", // 팔로잉 수
                            style: TextStyle(fontSize: 16.0),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // 구독하기 버튼 동작 구현
                              // ...
                            },
                            child: Text("구독하기"),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                              textStyle: TextStyle(fontSize: 12.0), // 버튼 텍스트 스타일
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(thickness: 2.0), // 구분선 추가
            SizedBox(height: 16.0),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 한 줄에 보여줄 게시물 수
                  crossAxisSpacing: 8.0, // 아이템간의 가로 간격
                  mainAxisSpacing: 8.0, // 아이템간의 세로 간격
                ),
                itemCount: 9, // 게시물 수
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: AssetImage('images/profile1.png'), // 게시물 이미지
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
