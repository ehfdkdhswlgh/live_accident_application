import 'package:flutter/material.dart';
import 'main_post.dart';
import '../UserImfomation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostDocument extends StatefulWidget {
  PostDocument({required this.postId, required this.imageUrl, required this.postMain, required this.userNickname, required this.postName, required this.userId, required this.timestamp, required this.like, required this.address, required this.profile});
  final postId;
  final imageUrl;
  final postMain;
  final userNickname;
  final postName;
  final userId;
  final timestamp;
  final address;
  var like;
  final profile;
  @override
  State<PostDocument> createState() => _PostDocumentState();
}
//
class _PostDocumentState extends State<PostDocument> {
  final TextEditingController _commentController = TextEditingController();
  bool isLiked = false;

  void initState() {
    super.initState();
    checkIfLikedOrNot();
  }

  void checkIfLikedOrNot() async {
    var user = FirebaseAuth.instance.currentUser;
    var likeRef = FirebaseFirestore.instance.collection('likes');
    var userLike = await likeRef
        .where('userId', isEqualTo: user?.uid)
        .where('postId', isEqualTo: widget.postId)
        .get();

    if (userLike.docs.length > 0) {
      setState(() {
        isLiked = true;
      });
    }
  }
  void handleLikePost() {
    var user = FirebaseAuth.instance.currentUser;
    if (isLiked) {
      // Already liked, so we need to unlike
      FirebaseFirestore.instance
          .collection('likes')
          .where('userId', isEqualTo: user?.uid)
          .where('postId', isEqualTo: widget.postId)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs[0].reference.delete();
      });

      FirebaseFirestore.instance
          .collection('posts')
          .where('post_id', isEqualTo: widget.postId)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs[0].reference.update({'like': FieldValue.increment(-1)});
      });

      setState(() {
        isLiked = false;
        widget.like -= 1;
      });

    } else {
      // Not liked yet, so we need to like
      FirebaseFirestore.instance.collection('likes').add({
        'userId': user?.uid,
        'postId': widget.postId,
        'timestamp': FieldValue.serverTimestamp(), // added this line
      });

      FirebaseFirestore.instance
          .collection('posts')
          .where('post_id', isEqualTo: widget.postId)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs[0].reference.update({'like': FieldValue.increment(1)});
      });

      setState(() {
        isLiked = true;
        widget.like += 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: ListView(
          children: [
            Profile(userNickname: widget.userNickname, postId: widget.postId, postName: widget.postName, userId: widget.userId, like: widget.like, address: widget.address, timestamp: widget.timestamp, profile: widget.profile,),
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
            // GestureDetector(
            //   onTap: handleLikePost,
            //   child: Row(
            //     children: [
            //       Icon(isLiked ? Icons.favorite : Icons.favorite_border),
            //       SizedBox(width: 4.0),
            //       Text(widget.like.toString()),
            //     ],
            //   ),
            // ),
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
