import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'store.dart';
import 'package:provider/provider.dart';

import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

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
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _mainController = TextEditingController();

  FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        child: _buildContainer(_selectedIndex, context)
      ),
    );
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
                      onPressed: () {
                        Future<List<String>> str = uploadImages(_pickedImages);
                        str.then((List<String> strList) {
                          String str = strList.join(","); // 리스트를 쉼표로 구분된 문자열로 변환
                          _uploadPost('useruseruser', str, context.read<Store>().postType);
                        });

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
                        // '제보하기' 버튼 클릭 시 실행될 코드
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

    if (title.isNotEmpty) {
      _firestore.collection('posts').add({
        'user_id': userId,
        'post_id': '${userId}123',
        'title': title,
        'post_content': main,
        'post_type': postType,
        'images': url,
        'address_name': '경상북도 구미시 대학로 42-10',
        'is_visible': true,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _titleController.clear();
      _mainController.clear();
    }
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
              _buildButton('사고', context),
              _buildButton('공사', context),
              _buildButton('행사/시위', context),
              _buildButton('통제', context),
              _buildButton('기타', context),
            ],
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


