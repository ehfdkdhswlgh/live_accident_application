import 'package:flutter/material.dart';
import 'main_post.dart';
import 'package:provider/provider.dart';
import 'store.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostDocument extends StatefulWidget {
  final String postId;

  PostDocument({required this.postId});

  @override
  State<PostDocument> createState() => _PostDocumentState(postId: postId);
}

class _PostDocumentState extends State<PostDocument> {
  final TextEditingController _commentController = TextEditingController();
  late final String postId;

  _PostDocumentState({required this.postId});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: ListView(
          children: [
            Profile(),
            Thumbnail(),
            MainDocument(),
            Divider(thickness: 2.0),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('comments')
                  .where('post_id', isEqualTo: postId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading");
                }

                return ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(), // 스크롤 기능 없에주는 것
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['comment']),
                      subtitle: Text(data['username']),
                    );
                  }).toList(),
                );
              },
            ),
            Divider(thickness: 1.0),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: '댓글을 입력해주세요.',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: (){},
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ]
      ),
    );
  }

}

class MainDocument extends StatelessWidget {
  const MainDocument({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      width: 350,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
              child: RichText(
                overflow: TextOverflow.visible,
                strutStyle: StrutStyle(fontSize: 12.0),
                text: TextSpan(
                    text:
                    "세계문자 가운데 한글,즉 훈민정음은 흔히들 신비로운 문자라 부르곤 합니다. 그것은 세계 문자 가운데 유일하게 한글만이 그것을 만든 사람과 반포일을 알며, 글자를 만든 원리까지 알기 때문입니다. 세계에 이런 문자는 없습니다. 그래서 한글은, 정확히 말해 [훈민정음 해례본](국보 70호)은 진즉에 유네스코 세계기록유산으로 등재되었습니다. ‘한글’이라는 이름은 1910년대 초에 주시경 선생을 비롯한 한글학자들이 쓰기 시작한 것입니다. 여기서 ‘한’이란 크다는 것을 뜻하니, 한글은 ‘큰 글’을 말한다고 하겠습니다.[네이버 지식백과] 한글 - 세상에서 가장 신비한 문자 (위대한 문화유산, 최준식)",
                    style: TextStyle(
                      color: Colors.black,
                      height: 1.4,
                      fontSize: 12.0,
                      // fontFamily: // 글자 폰트 지정 가능
                    )
                ),
              )
          )
        ],
      ),
    );
  }
}

class PostComment extends StatelessWidget {
  const PostComment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey, // 프사를 넣을 경우 backgroundImage
            ),
            Column(
              children: [
                Text('제보날씨'), // 닉네임 위치
                Text('홍천교'), // 제보 위치
              ],
            ),
          ],
        ),
        Column(
          children: [
            IconButton(onPressed: (){}, icon: Icon(Icons.more_horiz)), // 아이콘
            Text('203일전'), // 업로드 날짜
          ],
        )
      ],
    );;
  }
}
