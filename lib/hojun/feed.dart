import 'package:flutter/material.dart';
import 'main_post.dart';
import 'tags.dart';

class Feed extends StatefulWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  var data = [0, 1, 2, 3, 4, 5];

  var scroll = ScrollController();

  addData() {
    setState(() {
      data.add(0);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scroll.addListener(() {
      if(scroll.position.pixels == scroll.position.maxScrollExtent){
        addData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if(data.isNotEmpty){
      return ListView.builder(itemCount: data.length, controller: scroll, itemBuilder: (c, i){
        return Column(
          children: [
            MainPost(),
          ],
        );
      });
    } else {
      return Text("로딩중");
    }
  }
}
