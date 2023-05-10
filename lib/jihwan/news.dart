import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class News extends StatefulWidget {
  @override
  _NewsState createState() => _NewsState();
}

class _NewsState extends State<News> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, String>> items = [];

  @override
  void initState() {
    super.initState();
    _fetchRssItems();
  }

  Future<void> _fetchRssItems() async {
    List<Map<String, String>> rssItems = [];

    QuerySnapshot querySnapshot = await _firestore.collection('rss').get();
    querySnapshot.docs.forEach((doc) {
      rssItems.add({
        'title': doc['title'],
        'date': doc['pubDate'],
        'link': doc['link'],
      });
    });

    setState(() {
      items = rssItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '보도자료 조회',
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
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey,
        ),
        margin: EdgeInsets.all(16.0),
        child: ListView.separated(
          padding: EdgeInsets.all(16.0),
          separatorBuilder: (context, index) => Container(
            height: 1,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(items[index]['title']!),
            subtitle: Text(items[index]['date']!),
            onTap: () async {
              _launchUrl(items[index]['link']);
            },
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(str_url) async {
    var _url = Uri.parse(str_url);

    if (!await canLaunch(_url.toString())) {
      throw Exception('Could not launch $_url');
    } else {
      await launch(_url.toString());
    }
  }
}
