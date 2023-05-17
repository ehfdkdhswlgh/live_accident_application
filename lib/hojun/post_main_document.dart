import 'package:flutter/material.dart';
import 'main_post.dart';
import 'package:provider/provider.dart';
import 'store.dart';
import '../UserImfomation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostDocument extends StatefulWidget {
  PostDocument({required this.postId, required this.imageUrl, required this.postMain, required this.userNickname, required this.postName, required this.userId});
  final postId;
  final imageUrl;
  final postMain;
  final userNickname;
  final postName;
  final userId;
  @override
  State<PostDocument> createState() => _PostDocumentState();
}

class _PostDocumentState extends State<PostDocument> {
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: ListView(
          children: [
            Profile(userNickname: widget.userNickname, postId: widget.postId, postName: widget.postName, userId: widget.userId,),
            widget.imageUrl.isEmpty
                ? SizedBox.shrink()
                : Thumbnail(url: widget.imageUrl),
            MainDocument(postMain: widget.postMain),
            Divider(thickness: 2.0),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('comments')
                  .where('post_id', isEqualTo: widget.postId)
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
                  onPressed: (){
                    _postComment(widget.postId);
                  },
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ]
      ),
    );
  }
  void _postComment(String postId) async { //댓글 등록 함수
    String comment = _commentController.text;

    if (comment.isNotEmpty) {
      FirebaseFirestore.instance.collection('comments').add({
        'post_id': postId,
        'comment': comment,
        'username': UserImfomation.nickname, // Replace with actual username
        'timestamp': FieldValue.serverTimestamp(),
      });

      _commentController.clear();
    }
  }
}

class MainDocument extends StatelessWidget {
  const MainDocument({Key? key, this.postMain}) : super(key: key);
  final postMain;
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
                    postMain,
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

