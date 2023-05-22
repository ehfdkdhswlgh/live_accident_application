import 'package:flutter/material.dart';
import '../UserImfomation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../jihwan/post_report.dart';

class Modal extends StatefulWidget {
  const Modal({Key? key, required this.postId, required this.userId, required this.postName, required this.userNickname}) : super(key: key);
  final postId;
  final userId;
  final postName;
  final userNickname;
  @override
  State<Modal> createState() => _ModalState();
}

class _ModalState extends State<Modal> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> _deletePost() async {
    QuerySnapshot postSnapshot = await _db.collection('posts')
        .where('post_id', isEqualTo: widget.postId)
        .get();
    postSnapshot.docs.forEach((doc) async {
      await doc.reference.update({'is_visible': false});
    });

    // Show the snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('해당 게시글을 삭제하였습니다.'),
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if(UserImfomation.athority == "manager"){
      return Container(
        height: 200,
        child: ListView(
          children: [
            ListTile(
              title: Text('삭제하기'),
              onTap: () {
                Navigator.pop(context); // Bottom sheet 닫기
                _deletePost();
              },
            )
          ],
        ),
      );
    } else {
      if(UserImfomation.uid == widget.userId){
        return Container(
          height: 200,
          child: ListView(
            children: [
              ListTile(
                title: Text('삭제하기'),
                onTap: () {
                  Navigator.pop(context); // Bottom sheet 닫기
                  _deletePost();
                },
              )
              ,
              ListTile(
                title: Text('수정하기'),
                onTap: () {
                  // 선택된 항목에 대한 처리 로직
                  Navigator.pop(context); // Bottom sheet 닫기
                },
              ),
              // 추가적인 항목w들...
            ],
          ),
        );
      } else {
        return Container(
          height: 200,
          child: ListView(
            children: [
              ListTile(
                title: Text('신고하기'),
                onTap: () {
                  print("다음 게시글을 신고합니다. : " + widget.postName + " pid : " + widget.postId);
                  print("UID? : " + widget.userId + widget.userNickname);
                  Navigator.pop(context); // Bottom sheet 닫기
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportScreen(
                        name: widget.postName,
                        post_id: widget.postId,
                        user_id: widget.userId,
                        user_name: widget.userNickname,
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        );
      }
    }
  }
}
