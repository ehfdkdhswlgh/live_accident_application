import 'package:flutter/material.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String? _reportReason;
  String? _customReportReason; // 추가: 직접 입력한 신고 사유를 저장하는 변수
  List<String> _reportReasons = [
    "제보 관련 글이 아닙니다",
    "혐오표현, 욕을 사용했습니다",
    "비방 목적의 글입니다",
    "기타",
  ];

  void _handleReport() {
    // _reportReason 변수와 _customReportReason 변수를 사용하여 게시글을 신고하는 로직을 구현
    if (_reportReason == "기타" && _customReportReason == null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('알림'),
            content: Text('기타 신고 사유를 입력해주세요.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
    } else {
      print('Selected report reason: $_reportReason');
      print('Custom report reason: $_customReportReason');
      // 신고 완료 후 필요한 로직을 추가하세요.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시글 신고'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '신고 사유를 선택해주세요:',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _reportReason,
              onChanged: (value) {
                setState(() {
                  _reportReason = value!;
                });
              },
              items: _reportReasons.map((reason) {
                return DropdownMenuItem<String>(
                  value: reason,
                  child: Text(reason),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            // 추가: 기타를 선택한 경우에만 텍스트 필드를 보여줌
            if (_reportReason == "기타")
              TextFormField(
                decoration: InputDecoration(
                  labelText: '기타 신고 사유를 입력해주세요',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _customReportReason = value;
                  });
                },
              ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _handleReport,
              child: Text('신고하기'),
            ),
          ],
        ),
      ),
    );
  }
}