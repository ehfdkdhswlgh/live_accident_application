import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart';
import 'main_post.dart';

class Feed extends StatefulWidget {
  const Feed({Key? key}) : super(key: key);
  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Post> _posts = [];
  bool _isLoading = false;
  bool _hasMoreData = true;

  var scroll = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchData();
    scroll.addListener(() {
      if(scroll.position.pixels > scroll.position.maxScrollExtent - 50){
        _fetchData();
      }
      print(scroll.position.pixels);
    });
  }

  Future<void> _fetchData() async {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    QuerySnapshot querySnapshot;
    if (_posts.isEmpty) {
      querySnapshot = await _db
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();
    } else {
      final lastPostId = _posts.last.postId;
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

    final newPosts = querySnapshot.docs.map((doc) {
      final postId = doc.get('post_id').toString();
      final imageLinks = doc.get('images').toString();
      final postMain = doc.get('post_content').toString();
      return Post(postId: postId, imageLinks: imageLinks, postMain: postMain);
    }).toList();

    setState(() {
      _isLoading = false;
      _posts.addAll(newPosts);
    });
  }

  @override
  Widget build(BuildContext context) {
    if(_posts.isNotEmpty){
      return ListView.builder(itemCount: _posts.length, controller: scroll, itemBuilder: (c, i){
        return Column(
          children: [
            MainPost(postContent: _posts[i]),
          ],
        );
      });
    } else {
      return Text("로딩중");
    }
  }
}

class Post {
  final String postId;
  final String imageLinks;
  final String postMain;
  Post({required this.postId, required this.imageLinks, required this. postMain});
}