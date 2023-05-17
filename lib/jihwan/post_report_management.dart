import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportManagementScreen extends StatefulWidget {
  @override
  _ReportManagementScreenState createState() => _ReportManagementScreenState();
}

class _ReportManagementScreenState extends State<ReportManagementScreen> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> items = [];


  @override
  void initState() {
    super.initState();
    _fetchItems();
  }


  Future<void> _fetchItems() async {
    List<Map<String, dynamic>> Items = [];

    QuerySnapshot querySnapshot = await _firestore.collection('reported_post').get();
    querySnapshot.docs.forEach((doc) {
      Items.add({
        'post_id': doc['post_id'],
        'post_name': doc['post_name'],
        'reason': doc['reason'],
        'user_id': doc['user_id'],
        'user_name': doc['user_name'],
      });
    });

    setState(() {
      items = Items;
    });
  }

  Future<void> _deleteReport(int index, bool isCanceled) async {
    if (!isCanceled) {
      String postId = items[index]['post_id'];

      // Update 'is_visible' to false in Firestore for matching 'post_id'
      QuerySnapshot postSnapshot = await _firestore.collection('posts')
          .where('post_id', isEqualTo: postId)
          .get();
      postSnapshot.docs.forEach((doc) async {
        await doc.reference.update({'is_visible': false});
      });

      // Delete the reports with the same 'post_id' in Firestore
      QuerySnapshot reportSnapshot = await _firestore.collection('reported_post')
          .where('post_id', isEqualTo: postId)
          .get();
      reportSnapshot.docs.forEach((doc) async {
        await doc.reference.delete();
      });

      // Filter out items with the same 'post_id'
      items = items.where((item) => item['post_id'] != postId).toList();

      // Show the snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('해당 게시글을 삭제하였습니다.'),
        ),
      );
    }
    else {
      items.removeAt(index);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '게시글 신고 관리',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '게시글 제목: ${items[index]['post_name']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5.0),
                Text(
                  '게시글 작성자: ${items[index]['user_name']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5.0),
                Text('신고사유: ${items[index]['reason']}'),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      child: Text('취소'),
                      onPressed: () {
                        _deleteReport(index, true);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.grey,
                      ),
                    ),
                    SizedBox(width: 10.0),
                    ElevatedButton(
                      child: Text('게시글 삭제'),
                      onPressed: () {
                        _deleteReport(index, false);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                      ),
                    ),
                  ],
                ),
                Divider(thickness: 1, color: Colors.grey),
              ],
            );
          },
        ),
      ),
    );
  }
}
