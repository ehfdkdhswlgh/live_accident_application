import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'store.dart';
import 'package:provider/provider.dart';
import '../UserImfomation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:url_launcher/url_launcher.dart';

//애뮬레이터 실행시 오류날 시 https://www.youtube.com/watch?v=bTyLehofqvk
//https://www.flutterbeads.com/change-android-minsdkversion-in-flutter/


class ReportWriteScreen extends StatefulWidget {
  final VoidCallback onReportSubmitted;

  ReportWriteScreen({required this.onReportSubmitted});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportWriteScreen> {
  bool _isLoading = false; // New state variable
  LatLng? currentPosition;
  String address = "";
  @override
  void initState() {
    super.initState();
    getCurrentLocation();

  }
  int _selectedIndex = 0;
  final List<String> _reportTypes = ['제보하기', '긴급제보'];
  final List<Color> _selectedColors = [Colors.red, Colors.red];
  final ImagePicker _picker = ImagePicker();
  final List<XFile?> _pickedImages = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _mainController = TextEditingController();
  final TextEditingController emgergencyController = TextEditingController();


  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var geoHasher = GeoHasher();


  @override
  Widget build(BuildContext context) {
    if (currentPosition == null) {
      // 위치 정보가 아직 가져와지지 않았을 경우에 대한 처리
      print("로딩중...");
      return Center(
          child: SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                fit: StackFit.expand,
                children: const [
                  SizedBox(
                      width: 30, height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 10,
                        backgroundColor: Colors.black,
                        color: Colors.green,
                      )),
                  Center(
                      child: Text(
                        'Loading....',
                        style: TextStyle(fontSize: 10),
                      )),
                ],
              )
          )
      );
    }
    else {
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
            child: _buildContainer(_selectedIndex, context)
        ),
      );
    }
  }


  Widget _buildContainer(int index, BuildContext context){
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
                    child:
                    Text(
                      address,
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
                  controller: _titleController,
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
                  controller: _mainController,
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
                      onPressed: _isLoading ? null : () async { // disable button when loading
                        setState(() {
                          _isLoading = true;
                        });

                        List<String> strList = await uploadImages(_pickedImages);
                        String str = strList.join(","); // 리스트를 쉼표로 구분된 문자열로 변환
                        _uploadPost(UserImfomation.uid, str, context.read<Store>().postType);

                        widget.onReportSubmitted();

                        setState(() {
                          _isLoading = false;
                        });
                      },
                      child: _isLoading ? CircularProgressIndicator() : Text('제보하기'),
                    ),
                    SizedBox(width: 10),
                    OutlinedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                      ),
                      onPressed: () {
                        // '취소' 버튼 클릭 시 실행될 코드
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
                      controller: emgergencyController,
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
                            //문자API추가 위치
                            _launchSMSApp(emgergencyController.text);
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
                            // '취소' 버튼 클릭 시 실행될 코드
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

  //이미지 업로드용
  Future<List<String>> uploadImages(List<XFile?> images) async {
    List<String> imageUrls = [];

    for (var image in images) {
      // Firebase Storage에 저장될 경로 지정
      Reference storageReference = FirebaseStorage.instance.ref().child('images/${Uuid().v4()}');
      // 이미지 파일 업로드
      UploadTask uploadTask = storageReference.putFile(File(image!.path));
      TaskSnapshot storageTaskSnapshot = await uploadTask.whenComplete(() => null);
      // 업로드한 이미지 URL 반환
      String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }

    return imageUrls;
  }

  //제봇글 업로드 함수
  void _uploadPost(String userId, String url, int postType) async {
    String title = _titleController.text;
    String main = _mainController.text;
    String postId = '${userId}${DateTime.now().microsecondsSinceEpoch}';
    final timestamp = FieldValue.serverTimestamp();
    if (title.isNotEmpty) {

      //GeoFirePoint mygeo = geo.point(latitude: currentPosition!.latitude, longitude: currentPosition!.longitude);
      var geohash = geoHasher.encode(currentPosition!.longitude, currentPosition!.latitude, precision: 4);
      //
      _firestore.collection('posts').add({
        'user_id': userId,
        'post_id': postId,
        'title': title,
        'post_content': main,
        'post_type': postType,
        'images': url,
        'address_name': address,
        'is_visible': true,
        'timestamp': timestamp,
        'latitude' : currentPosition!.latitude,
        'longitude' : currentPosition!.longitude,
        'geohash': geohash, // Geohash 필드 추가
        'like':0,
      });

      // 해찬 추가
      DocumentReference userRef = _firestore.collection('user').doc(userId);
      _firestore.runTransaction((transaction) async {
        DocumentSnapshot userSnapshot = await transaction.get(userRef);
        if (userSnapshot.exists) {
          int postCount = userSnapshot.get('post_count') ?? 0;
          transaction.update(userRef, {'post_count': postCount + 1});
        }
      });
      // 해찬 추가 여기까지

      try {
        await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'key="AAAA2i-SWXA:APA91bEWfVsJxukDj9b7cJgMezjRl_SBNj3ey55SiYdhwH1mOxNfNjTSIkgPfOF0rlPyPDfI-DRDIr0UAw1YqG32wRUFSZ38CVnYO6AeA-qZGZLVMF7izh19n9oDHhmwqYdZa1WpCVoW"'
          },
          body: messageConstruct(postId, url, main, UserImfomation.nickname, title, userId, timestamp, 0, address),
        );
        print('FCM request for device sent!');
      } catch (e) {
        print(e);
      }

      _titleController.clear();
      _mainController.clear();
    }
  }



  Future<void> getCurrentLocation() async {

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );
    address =  await getAddress(position.latitude, position.longitude);

    setState(() {
      currentPosition = LatLng(position.latitude, position.longitude);
      address;
    });

    print(position.latitude);
    print(position.longitude);
  }

  Future<String> getAddress(double latitude, double longitude) async {
    String url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=AIzaSyDWq89VaEKZdEWpv6VoHQ8EVM5JSqE4JJs&language=ko';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          if (data['results'].length > 0) {
            return data['results'][0]['formatted_address'];
          }
        }
      }
    } catch (e) {
      print('Error: $e');
    }

    return '주소 변환 실패';
  }
}

//message형식 지정, 사용위치530번대
String messageConstruct(String postId, String imageUrl, String postMain, String userNickname, String title, String userId, FieldValue timestamp, int like, String address) {
  return jsonEncode({
    "to" : "/topics/hojun",
    'data': {
      'via': 'FlutterFire Cloud Messaging!!!',
      'postId': postId,
      'imageUrl': imageUrl,
      'postMain': postMain,
      'userNickname': userNickname,
      'postName': title,
      'userId': userId,
      'timestamp': timestamp,
      'like': like,
      'address': address,
    },
    'notification': {
      'title': 'LIVE Accident!!',
      'body': title,
    },
  });
}
//

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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child:
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton('사고', context),
                _buildButton('공사', context),
                _buildButton('행사/시위', context),
                _buildButton('기상', context),
                _buildButton('통제', context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, BuildContext context) {
    bool isSelected = text == _selectedItem;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedItem = text;
          context.read<Store>().setPostType(text);
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

// _postRequest(String content, String phone_num) async {    // 50건이상 쓰면 건당 10원이니 적당히 쓸 것
//   try {
//     DateTime now = DateTime.now();
//     int timestamp = now.millisecondsSinceEpoch;
//     String url = 'https://sens.apigw.ntruss.com/sms/v2/services/ncp:sms:kr:308204771431:emergency_report/messages'; // 엔드포인트 URL
//     String serviceId = 'ncp:sms:kr:308204771431:emergency_report';
//     String timeStamp = timestamp.toString();
//     String accessKey = 'Qqqt0HxbM6qrEEhgNgZ1';
//     String secretKey = 'LxDG8TbpJNWEL7VnLXmP6MG0XLccXyjH8vN7YUO6';
//     String sigbiture = getSignature(serviceId, timeStamp, accessKey, secretKey);
//
//     http.Response response = await http.post(
//       Uri.parse(url),
//       headers: <String, String> {
//         'Content-Type': 'application/json; charset=utf-8',
//         'x-ncp-apigw-timestamp': timeStamp,
//         'x-ncp-iam-access-key': accessKey,
//         'x-ncp-apigw-signature-v2': sigbiture,
//       },
//       body: jsonEncode(<String, dynamic> {
//         'type': 'SMS',
//         'contentType': 'COMM',
//         'countryCode': '82',
//         'from': '01051186937',
//         'content': '입력할 내용',
//         'messages': [
//           {
//             'to': '01051186937',
//             // 'to': phone_num, // 112 또는 119
//             'content': content,
//           },
//         ],
//       }),
//     );
//     print('=========================='+'실행완료');
//     print(response.bodyBytes);
//   } catch (error) {
//     print('오류 발생: $error');
//   }
// }

void _launchSMSApp(String message) async {
  final String recipient = '01051186937'; // 받는이 전화번호
  // String message = '안녕하세요!'; // 내용

  final String encodedMessage = Uri.encodeComponent(message);
  final url = 'sms:$recipient?body=$encodedMessage';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Failed to launch SMS app.';
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
