import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Sms extends StatefulWidget {
  @override
  _SmsState createState() => _SmsState();
}

class _SmsState extends State<Sms> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filteredItems = [];
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  void filterItems(String query) {
    List<Map<String, dynamic>> tempList = [];
    for (int i = 0; i < items.length; i++) {
      if ((items[i]['MSG_CN']?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
          (items[i]['RCV_AREA_NM']?.toLowerCase().contains(query.toLowerCase()) ?? false)) {
        tempList.add(items[i]);
      }
    }
    setState(() {
      filteredItems.clear();
      filteredItems.addAll(tempList);
    });
  }

  Future<void> _fetchItems() async {
    List<Map<String, dynamic>> smsItems = [];

    QuerySnapshot querySnapshot = await _firestore.collection('sms').get();
    querySnapshot.docs.forEach((doc) {
      smsItems.add({
        'CREAT_DT': doc['CREAT_DT'],
        'MSG_CN': doc['MSG_CN'],
        'RCV_AREA_NM': doc['RCV_AREA_NM'],
        'EMRGNCY_STEP_NM': doc['EMRGNCY_STEP_NM'],
        'DSSTR_SE_NM': doc['DSSTR_SE_NM'],
      });
    });

    setState(() {
      items = smsItems;
      filteredItems = List.from(items);
    });
  }

  void _showDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("상세 정보"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("생성일시: ${filteredItems[index]['CREAT_DT'] ?? ''}"),
              Text("메시지 내용: ${filteredItems[index]['MSG_CN'] ?? ''}"),
              Text("수신지역명: ${filteredItems[index]['RCV_AREA_NM'] ?? ''}"),
              Text("긴급단계 명: ${filteredItems[index]['EMRGNCY_STEP_NM'] ?? ''}"),
              Text("재해구분 명: ${filteredItems[index]['DSSTR_SE_NM'] ?? ''}"),
            ],
          ),
          actions: <Widget>[
            new TextButton(
              child: new Text("닫기"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '긴급 재난 문자',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[300],
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: Colors.white,
              ),
              padding: EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '검색',
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
                child: ListView.separated(
                  itemCount: filteredItems.length,
                  separatorBuilder: (context, index) => Divider(color: Colors.grey),
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(filteredItems[index]['MSG_CN'] ?? ''),
                      subtitle: Text(
                          '${filteredItems[index]['CREAT_DT'] ?? ''} | ${filteredItems[index]['RCV_AREA_NM'] ?? ''}'),
                      onTap: () {
                        _showDialog(index);
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
