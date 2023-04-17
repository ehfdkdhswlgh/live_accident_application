import 'package:flutter/material.dart';

class ReportManagementScreen extends StatefulWidget {
  @override
  _ReportManagementScreenState createState() => _ReportManagementScreenState();
}

class _ReportManagementScreenState extends State<ReportManagementScreen> {
  final List<Map<String, String>> reports = [
    {
      'title': '출근하기 귀찮네',
      'reason': '제보와 관련없는 글 게시',
    },
    {
      'title': 'ㄴㄴ',
      'reason': '음란물 게시',
    },
    {
      'title': 'ㅅㅂ',
      'reason': '부적절한 언어 사용',
    },
    {
      'title': 'ㅇㅇ',
      'reason': '저작권 침해',
    },
  ];
//
  void _deleteReport(int index, bool isCanceled) {
    setState(() {
      reports.removeAt(index);
      if (!isCanceled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('해당 게시글을 삭제하였습니다.'),
          ),
        );
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '게시글 신고 관리',
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
        child: ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '게시글 제목: ${reports[index]['title']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5.0),
                Text('신고사유: ${reports[index]['reason']}'),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      child: Text('취소'),
                      onPressed: () {
                        _deleteReport(index, true);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.grey,
                      ),
                    ),
                    SizedBox(width: 10.0),
                    ElevatedButton(
                      child: Text('게시글 삭제'),
                      onPressed: () {
                        _deleteReport(index, false);
                      },
                      style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                    ),
                    ),
                  ],
                ),
                Divider(thickness: 1, color: Colors.grey),
              ],
            );
          },
        ),
      ),
    );
  }
}