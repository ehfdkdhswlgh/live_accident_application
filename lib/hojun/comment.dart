import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentPage extends StatefulWidget {
  final String postId;

  CommentPage({required this.postId});

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('comments')
                  .where('post_id', isEqualTo: widget.postId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Text("로딩중"),
                  );
                } else {

                }

                List<Comment> comments = [];
                snapshot.data!.docs.forEach((doc) {
                  comments.add(Comment.fromDocument(doc));
                });

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: comments.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(comments[index].username),
                      subtitle: Text(comments[index].comment),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _postComment(widget.postId);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _postComment(String postId) async {
    String comment = _commentController.text;

    if (comment.isNotEmpty) {
      FirebaseFirestore.instance.collection('comments').add({
        'post_id': postId,
        'comment': comment,
        'username': 'User', // Replace with actual username
        'timestamp': FieldValue.serverTimestamp(),
      });

      _commentController.clear();
    }
  }
}

class Comment {
  final String username;
  final String comment;
  final Timestamp timestamp;

  Comment({
    required this.username,
    required this.comment,
    required this.timestamp,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc['username'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
    );
  }
}