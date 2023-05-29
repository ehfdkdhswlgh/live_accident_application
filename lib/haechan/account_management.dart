import 'package:flutter/material.dart';
import '../haechan/login.dart';
import '../UserImfomation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountManagementScreen extends StatefulWidget {
  @override
  _AccountManagementScreenState createState() =>
      _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  String _nickname = UserImfomation.nickname;
  String _password = "";
  List<String> _interestAreas = [];
  TextEditingController _interestAreaController = TextEditingController();
  String _errorMessage = "";
  TextEditingController _nicknameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _nicknameController.text = _nickname;
    getInterestAreasFromFirebase(UserImfomation.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("계정 관리"),
      ),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _nicknameController,
              onChanged: (value) {
                setState(() {
                  _nickname = value;
                });
              },
              decoration: InputDecoration(labelText: "닉네임"),
            ),
            // TextField(
            //   onChanged: (value) {
            //     setState(() {
            //       _password = value;
            //     });
            //   },
            //   decoration: InputDecoration(labelText: "비밀번호 수정"),
            // ),
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
                                addInterestAreaToFirebase(UserImfomation.uid, _interestAreas); // 파이어베이스에 데이터 추가
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
                                if (_interestAreas.contains(
                                    _interestAreaController.text)) {
                                  _errorMessage = "이미 있는 지역입니다";
                                } else {
                                  _interestAreas.add(
                                      _interestAreaController.text);
                                  _errorMessage = "";
                                  Navigator.pop(context);
                                  _interestAreaController.clear();
                                  addInterestAreaToFirebase(UserImfomation.uid, _interestAreas); // 파이어베이스에 데이터 추가
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
                          addInterestAreaToFirebase(UserImfomation.uid, _interestAreas); // 파이어베이스에서 데이터 삭제
                        });
                      },
                    ),
                  ],
                );
              },
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  print('here11111111111111111111111');
                  DocumentReference userRef = _firestore
                      .collection('user')
                      .doc(UserImfomation.uid);

                  await _firestore.runTransaction((transaction) async {
                    DocumentSnapshot userSnapshot = await transaction.get(userRef);
                    Map<String, dynamic>? userData =
                    userSnapshot.data() as Map<String, dynamic>?;

                    if (userData == null) {
                      // 사용자 데이터가 없는 경우에 대한 처리 로직 추가
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("오류"),
                            content: Text("사용자 정보를 찾을 수 없습니다."),
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
                      return;
                    }

                    userData['name'] = _nickname;

                    transaction.update(userRef, userData);
                  });

                  print('here22222222222222222222222222222');

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
                } catch (error) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("오류"),
                        content: Text("계정 정보를 업데이트하는 중에 오류가 발생했습니다."),
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
                  print("오류 발생: $error");
                }
              },
              child: Text("수정하기"),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Add your logout logic here
                print("Logged out");
                // Navigate to the login screen
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                      (Route<dynamic> route) => false,
                );
                // You can navigate to the login screen or perform any other logout actions
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // Set the button color to red
              ),
              child: Text("로그아웃"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addInterestAreaToFirebase(
      String uid, List<String> interestAreas) async {
    try {
      DocumentReference userRef = _firestore.collection('user').doc(uid);
      await userRef.update({'interestAreas': interestAreas});
      print('관심지역이 성공적으로 업데이트되었습니다.');
    } catch (error) {
      print('관심지역 업데이트 오류: $error');
    }
  }

  Future<void> getInterestAreasFromFirebase(String uid) async {
    try {
      DocumentSnapshot userSnapshot = await _firestore
          .collection('user')
          .doc(uid)
          .get();

      Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;

      if (userData != null && userData.containsKey('interestAreas')) {
        List<dynamic> interestAreas = userData['interestAreas'];
        setState(() {
          _interestAreas = interestAreas.cast<String>().toList();
        });
      }
    } catch (error) {
      print('관심지역 가져오기 오류: $error');
    }
  }

}


