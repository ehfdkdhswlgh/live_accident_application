import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'store.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';


class ModifyScreen extends StatefulWidget {
  ModifyScreen({ required this.postId});

  final postId;

  @override
  _ModifyScreenState createState() => _ModifyScreenState();
}

class _ModifyScreenState extends State<ModifyScreen> {
  bool _isLoading = false; // New state variable
  String _address = "";
  String url = '';
  bool ready = false;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _mainController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetch();
  }
  final ImagePicker _picker = ImagePicker();
  final List<XFile?> _pickedImages = [];
  final List<String> _oldImages = [];

  void _fetch() async {
    await _fetchData();
    await downloadImages(url);
  }

  Future<void> _fetchData() async {
    QuerySnapshot query = await _firestore.collection('posts').where("post_id", isEqualTo: widget.postId).get();
    String title = query.docs.first.get('title').toString();
    String main = query.docs.first.get('post_content').toString();
    _titleController.text = title;
    _mainController.text = main;
    _address = query.docs.first.get('address_name').toString();
    url = query.docs.first.get('images').toString();
    if(url.isEmpty){url = 'empty';}
  }

  Future<void> downloadImages(String imageUrlString) async {
    if(url != 'empty'){
      List<String> imageUrls = imageUrlString.split(',');

      List<XFile> downloadedImages = [];

      for (String imageUrl in imageUrls) {
        _oldImages.add(imageUrl);
        final response = await http.get(Uri.parse(imageUrl.trim()));
        final appDir = await getTemporaryDirectory();
        final imagePath = '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        final File imageFile = File(imagePath);
        await imageFile.writeAsBytes(response.bodyBytes);
        downloadedImages.add(XFile(imagePath));
      }
      setState(() {
        _pickedImages.addAll(downloadedImages);
        ready = true;
      });
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    Uri uri = Uri.parse(imageUrl);
    String path = uri.path;
    String fileName = path.split('/').last;
    fileName = fileName.split('?').first;
    if (fileName.startsWith("images%2F")) {fileName = fileName.replaceFirst("images%2F", "");}
    print(fileName);
    Reference imageRef = FirebaseStorage.instance.ref().child('images/$fileName');
    await imageRef.delete();
  }


  @override
  Widget build(BuildContext context) {
    if (!ready) {
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
          title: Text("수정하기"),
        ),
        body: Container(
            padding: EdgeInsets.all(16.0),
            child:
            SingleChildScrollView(
              child : Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyButton(),
                    SizedBox(height: 16.0),
                    Text('    위치',
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
                          _address,
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
                            await _updatePost(widget.postId, str, context.read<Store>().postType);
                            if(_oldImages.isNotEmpty){
                              for(String image in _oldImages){
                                deleteImage(image);
                              }
                            }
                            setState(() {
                              _isLoading = false;
                            });
                            Navigator.pop(context);
                          },
                          child: _isLoading ? CircularProgressIndicator() : Text('수정하기'),
                        ),
                        SizedBox(width: 10),
                        OutlinedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                            foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('취소'),
                        ),
                      ],
                    )
                  ],
                ),
              )
            )
        ),
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
  Future<void> _updatePost(String postId, String url, int postType) async {
    String title = _titleController.text;
    String main = _mainController.text;

    if (title.isNotEmpty) {

      QuerySnapshot query = await _firestore.collection('posts').where('post_id', isEqualTo: postId).get();
      if(query.docs.isNotEmpty){
        DocumentReference documentRef = query.docs[0].reference;
        Map<String, dynamic> updatedData = {
          'post_main': title,
          'post_content': main,
          'post_type': postType,
          'images': url,
        };
        await documentRef.update(updatedData);
      } else {
        // 'posts' 컬렉션에서 'post_id' 필드가 'postId'와 동일한 문서를 찾지 못한 경우
        print('Document not found');
      }
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
                _buildButton('교통', context),
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
