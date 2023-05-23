import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../UserImfomation.dart';
import '../haechan/profile.dart' as profile;
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
    return Scaffold(
        appBar: AppBar(
          title: Text("Live돌발사고"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => profile.ProfileScreen(UserImfomation.uid)),
                );
              },
            ),
          ],
        ),
        body:
        Column(
          children: [
            Tags(),
            Expanded(child: Feed(selectedType: context.watch<Store>().selectedPostType, selectedOrder: context.watch<Store>().selectedPostOrder,))
          ]
        )
    );
  }
}
