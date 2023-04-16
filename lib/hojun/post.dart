import 'package:flutter/material.dart';
import 'tags.dart';
import 'main_post.dart';

class Post extends StatefulWidget {
  const Post({Key? key}) : super(key: key);

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Tags(),
        MainPost(),

      ],
    );
  }
}

