import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../haechan/login.dart';
import '../UserImfomation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:remedi_kopo/remedi_kopo.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'dart:convert';

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
  var geoHasher = GeoHasher();
  String addressName = '';

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
        backgroundColor: Colors.white,
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '계정관리',
                style: TextStyle(
                  color: Colors.black, // "Live" 텍스트를 빨간색으로 설정
                  fontSize: 24, // 글자 크기를 24로 설정
                  fontWeight: FontWeight.bold, // 굵게 설정
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.black, // 뒤로가기 버튼의 색상을 검은색으로 설정
        ),
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
                _addressAPI();
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
              onPressed: () async {
                // Firebase 로그아웃
                await FirebaseAuth.instance.signOut();

                print("Logged out");
                // Navigate to the login screen
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                      (Route<dynamic> route) => false,
                );
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
          .collection('interest_area')
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


  _addressAPI() async {
    KopoModel model = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => RemediKopo(),
      ),
    );
    _searchAddress(model.address.toString());
  }

  _searchAddress(String searchData) async {
    final String url =
        "https://dapi.kakao.com/v2/local/search/address.json";
    final Map<String, String> headers = {
      "Authorization": "KakaoAK bbc69e19b84f6c642836ebbbbdf66ad9"
    };

    final String query =
        "?query=$searchData&page=1&size=10&analyze_type=similar";
    final http.Response response = await http.get(
      Uri.parse(url + query),
      headers: headers,
    );

    final Map<String, dynamic> result = json.decode(response.body);

    if (result.containsKey("documents")) {
      List<dynamic> documents = result["documents"];
      if (documents.isNotEmpty) {
        Map<String, dynamic> firstDocument = documents.first;
        addressName = firstDocument["address_name"];
        String x = firstDocument["x"];
        String y = firstDocument["y"];
        double double_x = double.parse(x);
        double double_y = double.parse(y);
        var geohash = geoHasher.encode(double_x, double_y, precision: 4);
        print('x : ' + x);
        print('y : ' + y);
        print('geohash : ' + geohash);

        try {
          await _firestore.collection("interest_area").add({
            "geohash": geohash,
            "interest_area": addressName,
            "uid": UserImfomation.uid,
          });
          print('Firestore에 값이 성공적으로 추가되었습니다.');
        } catch (error) {
          print('Firestore에 값 추가 중 오류가 발생했습니다: $error');
        }

      }
    }
  }


}


