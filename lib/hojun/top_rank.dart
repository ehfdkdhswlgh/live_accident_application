import 'package:flutter/material.dart';

class Rank extends StatefulWidget {
  const Rank({Key? key}) : super(key: key);

  @override
  State<Rank> createState() => _RankState();
}

class _RankState extends State<Rank> {
  var title = ["TOP5 멤버", "TOP5 제보글"];
  var _rankIndex = 0;

  void _rankTap(int index) {
    setState(() {
      _rankIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar (
        title: Text("${title[_rankIndex]}"),
        centerTitle: true,
      ),
      body: [TopMember(), TopPost()][_rankIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _rankIndex,
        onTap: _rankTap,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'TOP5 멤버',
          ),
            BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'TOP5 제보글',
          ),
        ],
      ),
    );
  }
}

class TopMember extends StatelessWidget {
  TopMember({Key? key}) : super(key: key);

  List<MemberRank> _rankingList = [
    MemberRank(userName: "User1", postNum: 33),
    MemberRank(userName: "User2", postNum: 22),
    MemberRank(userName: "User3", postNum: 11),
    MemberRank(userName: "User3", postNum: 5),
    MemberRank(userName: "User3", postNum: 1),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child:  GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1, // 칸의 수
                childAspectRatio: 5, // 가로와 세로의 비율 조정 (높이 조정)
              ),
              itemCount: _rankingList.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Container(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${index + 1}위"), // 순위
                            Text("이름: ${_rankingList[index].userName}"),
                            Text("제보 수: ${_rankingList[index].postNum}"),
                          ],
                        ),
                      ),
                    ),
                    Divider(height: 2.0,color: Colors.grey,)
                  ],
                );
              },
            ),
        ),

        // Text("제보 TOP5 멤버는 최근 7일간의 글쓰기 내역을 합산해 실시간으로 업데이트 됩니다.")
      ],
    );
  }
}

class MemberRank {
  String userName;
  int postNum;

  MemberRank({required this.userName, required this.postNum});
}



class Post {
  String title; // 게시글 제목
  int likes; // 좋아요 수
  Post(this.title, this.likes); // 생성자
}

// 게시글 리스트
List<Post> posts = [
  Post('Burger', 10),
  Post('French Fries', 15),
  Post('Pizza', 20),
  Post('Bengali Lamb Curry', 25),
  Post('Chingri Malai Curry', 30),
];

// 좋아요 수에 따라 게시글을 내림차순으로 정렬하는 함수
void sortPostsByLikes(List<Post> posts) {
  posts.sort((a, b) => b.likes.compareTo(a.likes));
}



class TopPost extends StatelessWidget {
  const TopPost({Key? key}) : super(key: key);

  // 상위 n개의 게시글을 반환하는 함수
  @override
  Widget build(BuildContext context) {
    // 좋아요 수를 기준으로 게시글 랭킹 정렬
    posts.sort((a, b) => b.likes.compareTo(a.likes));

    return Scaffold(
      appBar: AppBar(
        title: Text('게시글 랭킹'),
      ),
      body: ListView.builder(
        itemCount: 5, // 상위 5개 게시글만 보여줌
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              ListTile(
                title: Text('${index + 1}위: ${posts[index].title}'),
                subtitle: Text('좋아요 수: ${posts[index].likes}'),
              ),
              Divider( // 글 밑에 선 그리기
                height: 1,
                color: Colors.grey,
              ),
            ],
          );
        },
      ),
    );
  }
}