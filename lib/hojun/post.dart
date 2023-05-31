import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
          backgroundColor: Colors.white,
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'LIVE',
                  style: TextStyle(
                    color: Colors.red, // "Live" 텍스트를 빨간색으로 설정
                    fontSize: 24, // 글자 크기를 24로 설정
                    fontWeight: FontWeight.bold, // 굵게 설정
                  ),
                ),
                TextSpan(
                  text: ' 돌발사고',
                  style: TextStyle(
                    color: Colors.black, // "돌발사고" 텍스트를 검정색으로 설정
                    fontSize: 23, // 글자 크기를 16으로 설정
                    fontWeight: FontWeight.normal, // 폰트 굵기를 일반으로 설정
                  ),
                ),
              ],
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.account_circle, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => profile.ProfileScreen(UserImfomation.uid),
                  ),
                );
              },
            ),
          ],
        ),

        body:
        Column(
          children: [
            Tags(),
            Expanded(child: Feed(selectedType: context.watch<Store>().selectedPostType, selectedOrder: context.watch<Store>().selectedPostOrder))
          ]
        )
    );
  }
}
