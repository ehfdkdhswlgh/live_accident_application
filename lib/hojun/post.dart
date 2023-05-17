import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'store.dart';
import 'tags.dart';
import 'feed.dart';

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
        Expanded(child: [
          Feed(postType: 0),
          Feed(postType: 1),
          Feed(postType: 2),
          Feed(postType: 3),
          Feed(postType: 4),
          Feed(postType: 5)
        ][context.read<Store>().selectedPostType]),
      ],
    );
  }
}
