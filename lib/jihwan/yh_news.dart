import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class YHNews extends StatefulWidget {
  @override
  _YHNewsState createState() => _YHNewsState();
}

class _YHNewsState extends State<YHNews> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, String>> items = [];
  List<Map<String, String>> filteredItems = [];
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  void filterItems(String query) {
    List<Map<String, String>> tempList = [];
    for (int i = 0; i < items.length; i++) {
      if (items[i]['MAIN']?.toLowerCase().contains(query.toLowerCase()) ?? false) {
        tempList.add(items[i]);
      }
    }
    setState(() {
      filteredItems.clear();
      filteredItems.addAll(tempList);
    });
  }

  Future<void> _fetchItems() async {
    List<Map<String, String>> rssItems = [];

    QuerySnapshot querySnapshot = await _firestore.collection('news').get();
    querySnapshot.docs.forEach((doc) {
      rssItems.add({
        'DATE': doc['YHN_DATE'],
        'MAIN': doc['YHN_CN'],
        'TITLE': doc['YHN_SJ'],
        'PRESS': doc['YHN_WRTER_NM'],
      });
    });

    setState(() {
      items = rssItems;
      filteredItems = List.from(items);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '사건∙사고 뉴스',
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
        color: Colors.grey[300],
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: Colors.white,
              ),
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: '검색...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      filterItems(searchController.text);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  color: Colors.white,
                ),
                padding: EdgeInsets.all(10.0),
                child: ListView.separated(
                  itemCount: filteredItems.length,
                  separatorBuilder: (context, index) => Divider(color: Colors.grey),
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(filteredItems[index]['TITLE'] ?? ''),
                      subtitle: Text(
                          '${filteredItems[index]['DATE'] ?? ''} | ${filteredItems[index]['PRESS'] ?? ''}'),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    NewsDetailsPage(filteredItems[index])));
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class NewsDetailsPage extends StatelessWidget {
  final Map<String, String> newsItem;

  NewsDetailsPage(this.newsItem);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '뉴스 상세보기',
          style: TextStyle(color: Colors.black),  // Text color changed to black
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black), // Icon color changed to black
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                newsItem['TITLE'] ?? '',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                '${newsItem['DATE'] ?? ''} | ${newsItem['PRESS'] ?? ''}',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 10),
              Text(newsItem['MAIN'] ?? ''),
            ],
          ),
        ),
      ),
    );
  }
}
