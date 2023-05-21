import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:live_accident_application/hojun/top_rank.dart';
import 'store.dart';
import 'package:provider/provider.dart';
import 'main_post.dart';

class Feed extends StatefulWidget {
  const Feed({Key? key, required this.selectedType}) : super(key: key);
  final selectedType;
  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool _hasMoreData = true;
  var scroll = ScrollController();
  List<Post> posts = [];
  var post2;

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

  @override
  void didUpdateWidget(Feed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedType != oldWidget.selectedType) {
      _isLoading = false;
      _hasMoreData = true;
      setState(() {
        posts = [];
      });
      _fetchData();
    }
  }


  @override
  Future<void> _fetchData() async {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    QuerySnapshot querySnapshot;
    if (context.read<Store>().selectedPostType == 0) {
      if (posts.isEmpty) {
        querySnapshot = await _db
            .collection('posts')
            .where('is_visible', isEqualTo: true)
            .orderBy('timestamp', descending: true)
            .limit(5)
            .get();
      } else {
        final lastPostId = posts.last.postId;
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
      if (posts.isEmpty) {
        querySnapshot = await _db
            .collection('posts')
            .where('is_visible', isEqualTo: true)
            .where('post_type', isEqualTo: context.read<Store>().selectedPostType)
            .orderBy('timestamp', descending: true)
            .limit(5)
            .get();
      } else {
        final lastPostId = posts.last.postId;
        final lastDocSnapshot = await _db
            .collection('posts')
            .where('is_visible', isEqualTo: true)
            .where('post_type', isEqualTo: context.read<Store>().selectedPostType)
            .where('post_id', isEqualTo: lastPostId)
            .get()
            .then((querySnapshot) => querySnapshot.docs.first);
        querySnapshot = await _db
            .collection('posts')
            .where('is_visible', isEqualTo: true)
            .where('post_type', isEqualTo: context.read<Store>().selectedPostType)
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
    }//
    final newPosts = await Future.wait(querySnapshot.docs.map((doc) async {
      final _postId = doc.get('post_id').toString();
      final _imageLinks = doc.get('images').toString();
      final _postMain = doc.get('post_content').toString();
      final _userId = doc.get('user_id').toString();
      final _postName = doc.get('title').toString();
      final _timestamp = doc.get('timestamp').toString();
      var _like = doc.get('like');
      String _userNickname = '';
      try {
        final _nickname = await getNickname(_userId);
        _userNickname = _nickname;
      } catch (error) {}
      return Post(postId: _postId, imageLinks: _imageLinks, postMain: _postMain, userId: _userId, userNickname: _userNickname, postName: _postName, timestamp: _timestamp, like: _like);
    }).toList());

    setState(() {
      _isLoading = false;
      posts.addAll(newPosts);
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
    if (posts.isNotEmpty) {
      return ListView.builder(itemCount: posts.length, controller: scroll, itemBuilder: (c, i) {
        return Column(
          children: [
            MainPost(postContent: posts[i]),
          ],
        );
      },
      );
    } else {
      return Text("로딩중");
    }
  }
}

//posts테이블 확장 될 때마다 유지보수 할 것
class Post {
  final String postId;
  final String imageLinks;
  final String postMain;
  final String userId;
  final String userNickname;
  final String postName;
  final String timestamp;
  var like;
  Post({required this.postId, required this.imageLinks, required this.postMain, required this.userId, required this.userNickname, required this.postName, required this.timestamp, required this.like});
}