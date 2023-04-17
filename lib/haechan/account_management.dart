import 'package:flutter/material.dart';

class AccountManagementScreen extends StatefulWidget {
  @override
  _AccountManagementScreenState createState() => _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  String _nickname = "";
  String _password = "";
  List<String> _interestAreas = [];
  TextEditingController _interestAreaController = TextEditingController();
  String _errorMessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("계정 관리"),
      ),
      resizeToAvoidBottomInset : false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  _nickname = value;
                });
              },
              decoration: InputDecoration(labelText: "닉네임"),
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  _password = value;
                });
              },
              decoration: InputDecoration(labelText: "비밀번호 수정"),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("관심지역 추가"),
                      content: TextField(
                        controller: _interestAreaController,
                        decoration: InputDecoration(labelText: "관심지역"),
                        onSubmitted: (value) {
                          setState(() {
                            if (_interestAreas.length < 3) {
                              if (_interestAreas.contains(value)) {
                                _errorMessage = "이미 있는 지역입니다";
                              } else {
                                _interestAreas.add(value);
                                _errorMessage = "";
                                Navigator.pop(context);
                                _interestAreaController.clear();
                              }
                            } else {
                              Navigator.pop(context);
                            }
                          });
                        },
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("취소"),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              if (_interestAreas.length < 3) {
                                if (_interestAreas.contains(_interestAreaController.text)) {
                                  _errorMessage = "이미 있는 지역입니다";
                                } else {
                                  _interestAreas.add(_interestAreaController.text);
                                  _errorMessage = "";
                                  Navigator.pop(context);
                                  _interestAreaController.clear();
                                }
                              } else {
                                Navigator.pop(context);
                              }
                            });
                          },
                          child: Text("추가"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text("관심지역 추가"),
            ),
            SizedBox(height: 16.0),
            Text("관심지역"),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _interestAreas.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Expanded(
                      child: Text(_interestAreas[index]),
                    ),
                    IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _interestAreas.removeAt(index);
                        });
                      },
                    ),
                  ],
                );
              },
            ),
            ElevatedButton(
              onPressed: () {
                // 수정된 정보를 서버에 저장하는 로직 추가
                // _nickname, _password, _interestAreas 변수에 저장된 값을 활용
                print("닉네임: $_nickname");
                print("비밀번호: $_password");
                print("관심지역: $_interestAreas");

                // 서버에 수정된 정보를 전송하고 처리하는 로직을 추가해야 함

                // 수정된 정보를 서버에 성공적으로 전송하면
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("성공"),
                      content: Text("계정 정보가 성공적으로 저장되었습니다."),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("확인"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text("수정"),
            ),
          ],
        ),
      ),
    );
  }
}