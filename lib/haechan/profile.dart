import 'package:flutter/material.dart';
import '../UserImfomation.dart';
import 'account_management.dart';
import '../UserImfomation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../hojun/post_main_document.dart';


String nickname = '';
String uid = '';
String followingCount = '';
String followCount = '';
String postCount = '';

// String buttonText = '';
bool followChecer = false;

// List<Map<String, dynamic>> dataList;

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
class ProfileScreen extends StatefulWidget {
  final String inputUid; // 생성자에서 input_uid를 인자로 받을 수 있도록 수정

  ProfileScreen(this.inputUid);


  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}


class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Widget followBtn = SizedBox.shrink();
  bool followChecker = false;
  // if(UserImfomation.uid == widget.inputUid){
  // followBtn = ElevatedButton(
  //
  // child: Text('구독하기'),
  // onPressed: () {},
  // );
  // }

  // String uid = UserImfomation.uid;
  // String followingCount = UserImfomation.followingCount.toString();
  // String followCount = UserImfomation.followCount.toString();
  // String postCount = UserImfomation.postCount.toString();


  List<Map<String, dynamic>> dataList = [];
  List<String> postImageUrls = []; // 게시물 이미지 URL을 저장할 리스트
  Map<String, dynamic>? postData;
  @override
  void initState() {
    super.initState();
    //프로필 사진 가져오기 ===================================================================================================
    getPosts(); // 게시물 이미지를 가져옴
    if (UserImfomation.uid == widget.inputUid) {
      // 구독하기 버튼을 위젯으로 만들어서 여기다가?
      nickname = UserImfomation.nickname;
      uid = UserImfomation.uid;
      followingCount = UserImfomation.followingCount.toString();
      followCount = UserImfomation.followCount.toString();
      postCount = UserImfomation.postCount.toString();
      followBtn = SizedBox.shrink();
    } else {
      getUserInformation();
      // 'follow' 컬렉션에서 해당 정보 가져오기
      FirebaseFirestore.instance
          .collection('follow')
          .where('follow', isEqualTo: UserImfomation.uid)
          .where('follower', isEqualTo: widget.inputUid)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.size > 0) {
          // follow == follower이면 구독중으로 설정
          setState(() {
            followBtn = ElevatedButton(
              child: Text('구독중'),
              onPressed: () {handleUnsubscribe();},
            );
          });
        } else {
          // follow != follower이면 구독하기로 설정
          setState(() {
            followBtn = ElevatedButton(
              child: Text('구독하기'),
              onPressed: () {handleSubscribe();},
            );
          });
        }
      });
    }
    print('hello');
  }

// 구독하기 버튼을 눌렀을 때
  void handleSubscribe() {
    FirebaseFirestore.instance.runTransaction((transaction) async {
      // 해당 uid에 해당하는 문서 가져오기
      DocumentSnapshot userSnapshot = await transaction.get(
          FirebaseFirestore.instance.collection('user').doc(widget.inputUid)
      );
      // 문서가 존재하면 'follow' 필드 +1, 현재 유저의 'following' 필드 +1 업데이트
      if (userSnapshot.exists) {
        int followCount = userSnapshot.data() != null ? (userSnapshot.data()! as Map<String, dynamic>)['follow'] ?? 0 : 0;
        transaction.update(userSnapshot.reference, {'follow': followCount + 1});
      }
      int followingCount = UserImfomation.followingCount ?? 0;
      setState(() {
        UserImfomation.followingCount++;
      });
      transaction.update(FirebaseFirestore.instance.collection('user').doc(UserImfomation.uid), {'following': followingCount + 1});
      // transaction.update(FirebaseFirestore.instance.collection('user').doc(widget.inputUid), {'follow': followingCount + 1});

      // 'follow' 컬렉션에 구독 정보 추가
      transaction.set(FirebaseFirestore.instance.collection('follow').doc(), {
        'follow': UserImfomation.uid,
        'follower': widget.inputUid,
      });
    }).then((_) {
      setState(() {
        followBtn = ElevatedButton(
          child: Text('구독중'),
          onPressed: handleUnsubscribe, // 구독중 버튼으로 변경되면 handleUnsubscribe 함수 실행
        );
        followCount = (int.parse(followCount) + 1).toString();
      });
    }).catchError((error) {
      // 업데이트 실패 시 에러 처리
      print('구독하기 실패: $error');
    });
    // UserImfomation.followingCount++;
  }

// 구독중 버튼을 눌렀을 때
  void handleUnsubscribe() {
    FirebaseFirestore.instance.runTransaction((transaction) async {
      // 해당 uid에 해당하는 문서 가져오기
      DocumentSnapshot userSnapshot = await transaction.get(
          FirebaseFirestore.instance.collection('user').doc(widget.inputUid)
      );
      // 문서가 존재하면 'follow' 필드 -1, 현재 유저의 'following' 필드 -1 업데이트
      if (userSnapshot.exists) {
        int followCount = userSnapshot.data() != null ? (userSnapshot.data()! as Map<String, dynamic>)['follow'] ?? 0 : 0;
        transaction.update(userSnapshot.reference, {'follow': followCount - 1});
      }
      int followingCount = UserImfomation.followingCount ?? 0;

      setState(() {
        UserImfomation.followingCount--;
      });
      transaction.update(FirebaseFirestore.instance.collection('user').doc(UserImfomation.uid), {'following': followingCount - 1});
      // transaction.update(FirebaseFirestore.instance.collection('user').doc(widget.inputUid), {'follow': followingCount - 1});

      // 'follow' 컬렉션에서 구독 정보 삭제
      QuerySnapshot querySnapshot = await _firestore
          .collection('follow')
          .where('follow', isEqualTo: UserImfomation.uid)
          .where('follower', isEqualTo: widget.inputUid)
          .get();

      // QuerySnapshot querySnapshot = await transaction.get(FirebaseFirestore.instance.collection('follow').where('follow', isEqualTo: UserImfomation.uid).where('follower', isEqualTo: widget.inputUid));
      querySnapshot.docs.forEach((doc) {
        transaction.delete(doc.reference);
      });
    }).then((_) {
      setState(() {
        followBtn = ElevatedButton(
          child: Text('구독하기'),
          onPressed: handleSubscribe, // 구독하기 버튼으로 변경되면 handleSubscribe 함수 실행
        );
        followCount = (int.parse(followCount) - 1).toString();
      });
    }).catchError((error) {
      // 업데이트 실패 시 에러 처리
      print('구독 취소 실패: $error');
    });
    // UserImfomation.followingCount--;
  }

  getPosts() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('posts')
          .where('user_id', isEqualTo: widget.inputUid)
          .orderBy('timestamp', descending: true)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> dataList = []; // 데이터를 저장할 리스트 생성
        List<String> urls = []; // 임시 리스트

        querySnapshot.docs.forEach((doc) {
          Map<String, dynamic> postData = doc.data() as Map<String, dynamic>; // 문서의 데이터를 가져옴

          if (postData['images'] == '') {
            urls.add('https://firebasestorage.googleapis.com/v0/b/live-accident.appspot.com/o/images%2F게시글로 이동.PNG?alt=media&token=e6a8edf5-6f18-4f88-a038-7fa0a36e59d4');
          } else {
            urls.add(postData['images']);
          }

          dataList.add(postData); // 데이터를 리스트에 추가
        });

        setState(() {
          this.dataList = dataList; // 데이터 리스트를 업데이트
          postImageUrls = urls; // 게시물 이미지 URL을 저장한 리스트를 업데이트
        });
      }

      print('length: ${postImageUrls.length}');
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


  Future<String> getNickname(String user_id) async{
    QuerySnapshot userquery = await _firestore
        .collection('user')
        .where('uid', isEqualTo: user_id)
        .get();
    final userNickname = userquery.docs.first.get('name').toString();
    return userNickname;
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
                          followBtn,
                          // ElevatedButton(
                          //   onPressed: () {
                          //     // 버튼 누르면 user 테이블도 update
                          //     // 다른 프로필 누르면 버튼도 바뀌게
                          //     // 내 프로필은 버튼 안보이게
                          //     // 함수 만드는게 좋을 듯 ===================================================================================================
                          //
                          //     if(followChecer = true){
                          //       buttonText = '구독하기';
                          //       followChecer = false;
                          //       //db 반영
                          //     }else {
                          //       buttonText = '구독중';
                          //       followChecer = true;
                          //       // db 반영
                          //     }
                          //     // 구독하기 버튼 동작 구현
                          //   },
                          //   child: Text(buttonText),
                          //   style: ElevatedButton.styleFrom(
                          //     padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          //     textStyle: TextStyle(fontSize: 12.0), // 버튼 텍스트 스타일
                          //   ),
                          // ),
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
                    onTap: () async {
                      final String nickname = await getNickname(widget.inputUid);
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (c, a1, a2) => PostDocument(
                            postId: dataList[index]['post_id'],
                            imageUrl: dataList[index]['images'],
                            postMain: dataList[index]['post_content'],
                            userNickname: nickname,
                            postName: dataList[index]['title'],
                            userId: dataList[index]['user_id'],
                            timestamp: dataList[index]['timestamp'],
                            like: dataList[index]['like'],
                          ),
                          transitionsBuilder: (c, a1, a2, child) =>
                              FadeTransition(opacity: a1, child: child),
                        ),
                      );
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
