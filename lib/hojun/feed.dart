import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_post.dart';

class Feed extends StatefulWidget {
  const Feed({Key? key, required this.postType}) : super(key: key);
  final postType;
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
    });
  }

  Future<void> _fetchData() async {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    QuerySnapshot querySnapshot;
    if (widget.postType == 0) {
      if (_posts.isEmpty) {
        querySnapshot = await _db
            .collection('posts')
            .where('is_visible', isEqualTo: true)
            .orderBy('timestamp', descending: true)
            .limit(5)
            .get();
      } else {
        final lastPostId = _posts.last.postId;
        final lastDocSnapshot = await _db
            .collection('posts')
            .where('is_visible', isEqualTo: true)
            .where('post_id', isEqualTo: lastPostId)
            .get()
            .then((querySnapshot) => querySnapshot.docs.first);
        querySnapshot = await _db
            .collection('posts')
            .where('is_visible', isEqualTo: true)
            .orderBy('timestamp', descending: true)
            .startAfterDocument(lastDocSnapshot)
            .limit(5)
            .get();
      }
    } else {
      if (_posts.isEmpty) {
        querySnapshot = await _db
            .collection('posts')
            .where('is_visible', isEqualTo: true)
            .where('post_type', isEqualTo: widget.postType)
            .orderBy('timestamp', descending: true)
            .limit(5)
            .get();
      } else {
        final lastPostId = _posts.last.postId;
        final lastDocSnapshot = await _db
            .collection('posts')
            .where('is_visible', isEqualTo: true)
            .where('post_type', isEqualTo: widget.postType)
            .where('post_id', isEqualTo: lastPostId)
            .get()
            .then((querySnapshot) => querySnapshot.docs.first);
        querySnapshot = await _db
            .collection('posts')
            .where('is_visible', isEqualTo: true)
            .where('post_type', isEqualTo: widget.postType)
            .orderBy('timestamp', descending: true)
            .startAfterDocument(lastDocSnapshot)
            .limit(5)
            .get();
      }
    }


    if (querySnapshot.docs.isEmpty) {
      setState(() {
        _isLoading = false;
        _hasMoreData = false;
      });
      return;
    }
    final newPosts = await Future.wait(querySnapshot.docs.map((doc) async {
      final postId = doc.get('post_id').toString();
      final imageLinks = doc.get('images').toString();
      final postMain = doc.get('post_content').toString();
      final userId = doc.get('user_id').toString();
      String userNickname = '';
      try {
        final nickname = await getNickname(userId);
        userNickname = nickname;
      } catch (error) {
      }
      return Post(postId: postId, imageLinks: imageLinks, postMain: postMain, userId: userId, userNickname: userNickname);
    }).toList());

    setState(() {
      _isLoading = false;
      _posts.addAll(newPosts);
    });
  }
  Future<String> getNickname(String user_id) async{
    QuerySnapshot userquery = await _db
      .collection('user')
      .where('uid', isEqualTo: user_id)
      .get();
    final userNickname = userquery.docs.first.get('name').toString();
    return userNickname;
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
  final String userId;
  final String userNickname;
  Post({required this.postId, required this.imageLinks, required this.postMain, required this.userId, required this.userNickname});
}