import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_post.dart';

class Feed extends StatefulWidget {
  const Feed({Key? key}) : super(key: key);
  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<String> _postIds = [];
  bool _isLoading = false;
  bool _hasMoreData = true;

  var scroll = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchData();
    scroll.addListener(() {
      if(scroll.position.pixels == scroll.position.maxScrollExtent){
        print('addData');
        print(_postIds);
        _fetchData();
      }
    });
  }

  Future<void> _fetchData() async {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    QuerySnapshot querySnapshot;
    if (_postIds.isEmpty) {
      querySnapshot = await _db
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();
    } else {
      final lastPostId = _postIds.last;
      final lastDocSnapshot = await _db
          .collection('posts')
          .where('post_id', isEqualTo: lastPostId)
          .get()
          .then((querySnapshot) => querySnapshot.docs.first);
      querySnapshot = await _db
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .startAfterDocument(lastDocSnapshot)
          .limit(5)
          .get();
    }

    if (querySnapshot.docs.isEmpty) {
      setState(() {
        _isLoading = false;
        _hasMoreData = false;
      });
      return;
    }

    final newPostIds = querySnapshot.docs.map((doc) => doc.get('post_id').toString()).toList();
    setState(() {
      _isLoading = false;
      _postIds.addAll(newPostIds);
    });
  }

  @override
  Widget build(BuildContext context) {
    if(_postIds.isNotEmpty){
      return ListView.builder(itemCount: _postIds.length, controller: scroll, itemBuilder: (c, i){
        return Column(
          children: [
            MainPost(postId: _postIds[i]),
          ],
        );
      });
    } else {
      return Text("로딩중");
    }
  }
}
