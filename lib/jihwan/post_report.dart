import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ReportScreen extends StatelessWidget {
  final String name;

  ReportScreen({Key? key, required this.name}) : super(key: key);

  final List<String> reasons = [
    '제보와 관련없는 글 게시',
    '부적절한 언어 사용',
    '음란물 게시',
    '욕설 및 비방',
    '저작권 침해',
    '개인정보 노출',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '게시글 신고',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$name 게시글을 신고하는 이유를 선택해주세요.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            SizedBox(height: 30.0),
            Expanded(
              child: ListView.builder(
                itemCount: reasons.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(reasons[index]),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () {
                          _showReportDialog(context, reasons[index]);
                        },
                      ),
                      Divider(thickness: 1, color: Colors.grey),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _showReportDialog(BuildContext context, String reason) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text("'$reason'\n 해당 내용으로 신고하시겠습니까?"),
          backgroundColor: Colors.grey[800],
          contentTextStyle: TextStyle(color: Colors.white),
          actions: [
            ElevatedButton(
              child: Text(
                "        Cancel        ",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(primary: Colors.grey[600]),
            ),
            ElevatedButton(
              child: Text(
                "           OK           ",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Fluttertoast.showToast(
                  msg: "신고가 완료되었습니다.",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: Colors.grey[800],
                  textColor: Colors.white,
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(primary: Colors.red[800]),
            ),
          ],
        );
      },
    );
  }


}


