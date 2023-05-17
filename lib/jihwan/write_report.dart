import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';


//애뮬레이터 실행시 오류날 시 https://www.youtube.com/watch?v=bTyLehofqvk
//https://www.flutterbeads.com/change-android-minsdkversion-in-flutter/


class ReportWriteScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportWriteScreen> {
  int _selectedIndex = 0;
  final List<String> _reportTypes = ['제보하기', '긴급제보'];
  final List<Color> _selectedColors = [Colors.red, Colors.red];
  final List<Color> _unselectedColors = [Colors.grey, Colors.grey];
  final ImagePicker _picker = ImagePicker();
  final List<XFile?> _pickedImages = [];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildReportTypeButton(0),
            SizedBox(width: 8),
            _buildReportTypeButton(1),
          ],
        ),
      ),
      body: Container(
          padding: EdgeInsets.all(16.0),
        child: _buildContainer(_selectedIndex)
      ),
    );
  }


  Widget _buildContainer(int index){
    if(index == 0){
      return SingleChildScrollView(
          child : Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyButton(),
                SizedBox(height: 16.0),
                Text(
                  '    위치',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8.0), // 약간의 여백 추가
                  color: Colors.grey.shade300,
                  child: Align(
                    alignment: Alignment.centerLeft, // Text를 좌측에 배치
                    child: Text(
                      '경상북도 구미시 대학로 42-10',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                _imageLoadButtons(),
                const SizedBox(height: 20),
                _gridPhoto(),
                const SizedBox(height: 20),
                Text(
                  '제목',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  maxLength: 50, // 글자수 20자 제한
                  maxLines: 1, // 줄바꿈 없음
                  textAlign: TextAlign.left, // 텍스트 왼쪽 정렬
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0), // 좌우 패딩 16.0
                    filled: true, // 배경 색상 채우기
                    fillColor: Colors.grey[200], // 배경 회색 색상
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none, // 외곽선 없음
                      borderRadius: BorderRadius.circular(8.0), // 모서리 둥글게 처리
                    ),
                    hintText: '제목을 입력해주세요', // 입력 안내 메시지
                    hintStyle: TextStyle(color: Colors.grey[400]), // 입력 안내 메시지 색상
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '제보 내용',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  maxLines: null,
                  maxLength: 500, // 글자수 20자 제한
                  textAlign: TextAlign.left, // 텍스트 왼쪽 정렬
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0), // 좌우 패딩 16.0
                    filled: true, // 배경 색상 채우기
                    fillColor: Colors.grey[200], // 배경 회색 색상
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none, // 외곽선 없음
                      borderRadius: BorderRadius.circular(8.0), // 모서리 둥글게 처리
                    ),
                    hintText: '본문을 입력해주세요', // 입력 안내 메시지
                    hintStyle: TextStyle(color: Colors.grey[400]), // 입력 안내 메시지 색상
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      ),
                      onPressed: () {
                        // '제보하기' 버튼 클릭 시 실행될 코드
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('제보하기화면에서 제보하기버튼 누름'),
                          ),
                        );
                      },
                      child: Text('제보하기'),
                    ),
                    SizedBox(width: 10),
                    OutlinedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('제보하기화면에서 취소버튼 누름'),
                          ),
                        );
                      },
                      child: Text('취소'),
                    ),
                  ],
                )



              ],
            ),
          )

      );

    }
    else
    {
      return SingleChildScrollView(
          child : Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  '제보 내용',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  maxLines: null,
                  maxLength: 500, // 글자수 20자 제한
                  textAlign: TextAlign.left, // 텍스트 왼쪽 정렬
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0), // 좌우 패딩 16.0
                    filled: true, // 배경 색상 채우기
                    fillColor: Colors.grey[200], // 배경 회색 색상
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none, // 외곽선 없음
                      borderRadius: BorderRadius.circular(8.0), // 모서리 둥글게 처리
                    ),
                    hintText: '본문을 입력해주세요', // 입력 안내 메시지
                    hintStyle: TextStyle(color: Colors.grey[400]), // 입력 안내 메시지 색상
                  ),
                ),
                const SizedBox(height: 20),
                SwitchButton(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('긴급제보화면에서 제보하기버튼 누름'),
                          ),
                        );
                      },
                      child: Text('제보하기'),
                    ),
                    SizedBox(width: 10),
                    OutlinedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('긴급제보화면에서 취소버튼 누름'),
                          ),
                        );
                      },
                      child: Text('취소'),
                    ),
                  ],
                )
//

              ]
            )
          )
      );
    }
  }



  // 카메라, 갤러리에서 이미지 1개 불러오기
  // ImageSource.galley , ImageSource.camera
  void getImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);

    setState(() {
      _pickedImages.add(image);
    });
  }

  // 이미지 여러개 불러오기
  void getMultiImage() async {
    final List<XFile>? images = await _picker.pickMultiImage();

    if (images != null) {
      setState(() {
        _pickedImages.addAll(images);
      });
    }
  }

  // 화면 상단 버튼
  Widget _imageLoadButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.grey, // 새로운 버튼 색상
              ),
              onPressed: () => getImage(ImageSource.camera),
              child: const Text('촬영하기'),
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.grey, // 새로운 버튼 색상
              ),
              onPressed: () => getMultiImage(),
              child: const Text('불러오기'),
            ),
          ),
        ],
      ),
    );
  }

// 불러온 이미지 gridView
  Widget _gridPhoto() {
    return Container(
      child: _pickedImages.isNotEmpty
          ? GridView(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
        ),
        children: _pickedImages
            .where((element) => element != null)
            .map((e) => _gridPhotoItem(e!))
            .toList(),
      )
          : const SizedBox(),
    );
  }

  Widget _gridPhotoItem(XFile e) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.file(
              File(e.path),
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _pickedImages.remove(e);
                });
              },
              child: const Icon(
                Icons.cancel_rounded,
                color: Colors.black87,
              ),
            ),
          )
        ],
      ),
    );
  }






// 버튼을 생성하는 함수
  Widget _buildButton(String text) {
    bool isSelected = false; // 선택 여부
    return GestureDetector(
      onTap: () {
        isSelected = !isSelected; // 선택 여부 변경
        setState(() {}); // 변경된 상태를 적용
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // 버튼 내부 여백 설정
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.grey, // 선택 여부에 따른 색상 설정
          borderRadius: BorderRadius.circular(8.0), // 버튼 테두리 둥글게 설정
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white, // 버튼 텍스트 색상 설정
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }


  Widget _buildReportTypeButton(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: _selectedIndex == index
              ? _selectedColors[_selectedIndex]
              : Colors.grey,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          _reportTypes[index],
          style: TextStyle(
            color: _selectedIndex == index
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }


}

class MyButton extends StatefulWidget {
  const MyButton({Key? key}) : super(key: key);

  @override
  _MyButtonState createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  String? _selectedItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '제보유형',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton('사고'),
              _buildButton('공사'),
              _buildButton('행사/시위'),
              _buildButton('통제'),
              _buildButton('기타'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text) {
    bool isSelected = text == _selectedItem;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedItem = text;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.grey,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}




class SwitchButton extends StatefulWidget {
  const SwitchButton({Key? key}) : super(key: key);

  @override
  _SwitchButtonState createState() => _SwitchButtonState();
}

class _SwitchButtonState extends State<SwitchButton> {
  bool is112Selected = true; // 첫 번째 버튼이 선택되도록 초기화
  bool is119Selected = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 112 버튼
            GestureDetector(
              onTap: () {
                setState(() {
                  is112Selected = true;
                  is119Selected = false;
                });
                print('112 버튼 선택됨'); // 선택된 버튼 처리
              },
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: is112Selected ? Colors.red : Colors.grey, // 선택 여부에 따라 색상 변경
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '112',
                  style: TextStyle(
                    color: is112Selected ? Colors.white : Colors.black, // 선택 여부에 따라 글자 색상 변경
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            // 119 버튼
            GestureDetector(
              onTap: () {
                setState(() {
                  is112Selected = false;
                  is119Selected = true;
                });
                print('119 버튼 선택됨'); // 선택된 버튼 처리
              },
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: is119Selected ? Colors.red : Colors.grey, // 선택 여부에 따라 색상 변경
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '119',
                  style: TextStyle(
                    color: is119Selected ? Colors.white : Colors.black, // 선택 여부에 따라 글자 색상 변경
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}


_postRequest(String phone_num, String content) async {
  try {
    DateTime now = DateTime.now();
    int timestamp = now.millisecondsSinceEpoch;
    String url = 'https://sens.apigw.ntruss.com/sms/v2/services/ncp:sms:kr:308204771431:emergency_report/messages'; // 엔드포인트 URL
    String serviceId = 'ncp:sms:kr:308204771431:emergency_report';
    String timeStamp = timestamp.toString();
    String accessKey = 'Qqqt0HxbM6qrEEhgNgZ1';
    String secretKey = 'LxDG8TbpJNWEL7VnLXmP6MG0XLccXyjH8vN7YUO6';
    String sigbiture = getSignature(serviceId, timeStamp, accessKey, secretKey);

    http.Response response = await http.post(
      Uri.parse(url),
      headers: <String, String> {
        'Content-Type': 'application/json; charset=utf-8',
        'x-ncp-apigw-timestamp': timeStamp,
        'x-ncp-iam-access-key': accessKey,
        'x-ncp-apigw-signature-v2': sigbiture,
      },
      body: jsonEncode(<String, dynamic> {
        'type': 'SMS',
        'contentType': 'COMM',
        'countryCode': '82',
        'from': '01051186937',
        'content': '제목',
        'messages': [
          {
            'to': '01051186937', // 시연에서는 이 번호로 보냄
            // 'to': phone_num, // 112 또는 119
            'content': content,
          },
        ],
      }),
    );
    print('=========================='+'실행완료');
    print(response.bodyBytes);
  } catch (error) {
    print('오류 발생: $error');
  }
}



String getSignature(
    String serviceId, String timeStamp, String accessKey, String secretKey) {
  var space = " "; // one space
  var newLine = "\n"; // new line
  var method = "POST"; // method
  var url = "/sms/v2/services/$serviceId/messages";

  var buffer = new StringBuffer();
  buffer.write(method);
  buffer.write(space);
  buffer.write(url);
  buffer.write(newLine);
  buffer.write(timeStamp);
  buffer.write(newLine);
  buffer.write(accessKey);
  print(buffer.toString());

  /// signing key
  var key = utf8.encode(secretKey);
  var signingKey = new Hmac(sha256, key);

  var bytes = utf8.encode(buffer.toString());
  var digest = signingKey.convert(bytes);
  String signatureKey = base64.encode(digest.bytes);
  return signatureKey;
}

