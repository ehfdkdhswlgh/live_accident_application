import 'package:flutter/material.dart';
import 'account_management.dart';
import '../UserImfomation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


String nickname = '';
String uid = '';
String followingCount = '';
String followCount = '';
String postCount = '';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
class ProfileScreen extends StatefulWidget {
  final String inputUid; // 생성자에서 input_uid를 인자로 받을 수 있도록 수정

  ProfileScreen(this.inputUid);


  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}


class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // String uid = UserImfomation.uid;
  // String followingCount = UserImfomation.followingCount.toString();
  // String followCount = UserImfomation.followCount.toString();
  // String postCount = UserImfomation.postCount.toString();

  List<String> postImageUrls = []; // 게시물 이미지 URL을 저장할 리스트

  @override
  void initState() {
    super.initState();
    getPosts(); // 게시물 이미지를 가져옴
    if (UserImfomation.uid == widget.inputUid) {
      nickname = UserImfomation.nickname;
      uid = UserImfomation.uid;
      followingCount = UserImfomation.followingCount.toString();
      followCount = UserImfomation.followCount.toString();
      postCount = UserImfomation.postCount.toString();
    } else {
      getUserInformation();
    }
    print('hello');
  }

  getPosts() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('posts')
      // .where('user_id', isEqualTo: '5n0WBbvJgNO0bqkIgnM6febvPqD3')
          .where('user_id', isEqualTo: widget.inputUid)
        .orderBy('timestamp', descending: true) // timestamp를 내림차순으로 정렬
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<String> urls = []; // 임시 리스트

        querySnapshot.docs.forEach((doc) {
          // 각 게시물의 이미지 URL을 가져와서 리스트에 추가
          if (doc.get('images') == '') {
            urls.add(
                'https://firebasestorage.googleapis.com/v0/b/live-accident.appspot.com/o/images%2F게시글로 이동.PNG?alt=media&token=e6a8edf5-6f18-4f88-a038-7fa0a36e59d4');
          } else
            urls.add(doc.get('images'));

          // print(doc.get('images'));
        });

        setState(() {
          postImageUrls = urls; // 게시물 이미지 URL을 저장한 리스트를 업데이트
        });
      }
      print('length : ' + postImageUrls.length.toString());
    } catch (e) {
      print('Error: $e');
    }
  }


  getUserInformation() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('user')
      // .where('user_id', isEqualTo: '5n0WBbvJgNO0bqkIgnM6febvPqD3')
          .where('uid', isEqualTo: widget.inputUid)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
        setState(() {
          nickname = documentSnapshot.get('name');
          followCount = documentSnapshot.get('follow').toString();
          followingCount = documentSnapshot.get('following').toString();
          postCount = documentSnapshot.get('post_count').toString();
        });
      }

    } catch (e) {
      print('Error: $e');
    }
  }

  // ProfileScreen() {
  //   get_information();
  // }
  //
  // get_information() async{
  //   QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //       .collection('user')
  //       .where('uid', isEqualTo: UserImfomation.uid)
  //       .limit(1)
  //       .get();
  //
  //   if (querySnapshot.docs.isNotEmpty) {
  //     DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
  //     UserImfomation.nickname = documentSnapshot.get('name');
  //     UserImfomation.followCount = documentSnapshot.get('follow');
  //     UserImfomation.followingCount = documentSnapshot.get('following');
  //     UserImfomation.postCount = documentSnapshot.get('post_count');
  //   }
  //   print('nickname : ' + UserImfomation.nickname);
  //   print('userid : ' + UserImfomation.uid);
  //   print('followCount : ' + UserImfomation.followCount.toString());
  //   print('followingCount : ' + UserImfomation.followingCount.toString());
  //   print('postCount : ' + UserImfomation.postCount.toString());
  //   nickname = UserImfomation.nickname;
  //   // return UserImfomation.nickname;
  // }

  void navigateToPostDetail() {
    // 게시물 상세 페이지로 이동하는 코드를 여기에 작성
  }



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
                        nickname, // 닉네임
                        style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start, // 오른쪽 정렬
                        children: [
                          Text(
                            '게시물: ' + postCount, // 게시물 수
                            style: TextStyle(fontSize: 16.0),
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            '팔로워: ' + followCount, // 팔로워 수
                            style: TextStyle(fontSize: 16.0),
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            '팔로잉: ' + followingCount + '  ', // 팔로잉 수
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
                itemCount: postImageUrls.length, // 게시물 수
                itemBuilder: (context, index) {
                  return GestureDetector(
                      onTap: () {
                    navigateToPostDetail(); // 게시물 상세 페이지로 이동하는 함수 호출
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: NetworkImage(postImageUrls[index]), // 게시물 이미지
                        fit: BoxFit.cover,
                      ),
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
