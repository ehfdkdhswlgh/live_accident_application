import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:get/get.dart';
import '../jihoon/map_sample.dart';
import '../UserImfomation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../main.dart' as main2;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import '../jihwan/post_report_management.dart';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';



void main() { // 회원가입 버튼 누르고 회원가입 다시 누르면 됨
  // Firebase 초기화 코드
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();

  runApp(Login());
}

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '로그인 화면',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '로그인 화면'),
    );
  }
}

var logger = Logger(
  printer: PrettyPrinter(),
);

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController emailController = TextEditingController();


  void showEmailInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("이메일 입력"),
          content: TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: '이메일',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                sendPasswordResetEmail(context);
              },
              child: Text("확인"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("취소"),
            ),
          ],
        );
      },
    );
  }

  void sendPasswordResetEmail(BuildContext context) async {
    final String email = emailController.text;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("비밀번호 초기화 이메일 전송"),
            content: Text("비밀번호 초기화 이메일이 전송되었습니다."),
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
            content: Text("비밀번호 초기화 이메일을 전송하는 중에 오류가 발생했습니다."),
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
  }

  // String uid = UserImfomation.uid;

  String my_email = 'hae507@gmail.com';
  String my_pw = '123456';


  _login() async {
    //키보드 숨기기
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).requestFocus(FocusNode());
      // Firebase 사용자 인증, 사용자 등록
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        UserImfomation.uid = userCredential.user!.uid;

        //닉네임 가져오는 함수
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('user')
            .where('uid', isEqualTo: UserImfomation.uid)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
          UserImfomation.nickname = documentSnapshot.get('name').toString();
          UserImfomation.followCount = documentSnapshot.get('follow');
          UserImfomation.followingCount = documentSnapshot.get('following');
          UserImfomation.postCount = documentSnapshot.get('post_count');
          UserImfomation.athority = documentSnapshot.get('authority');
        }

        // print("UID : " + uid+ "\n" );
        print("UID : " + UserImfomation.uid);

        UserImfomation.checker = true;

        Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: (context) => main2.MyHomePage()),
              (Route<dynamic> route) => false,
        );

        // MapSample 화면에서 뒤로가기 버튼을 처리하는 부분
        // WillPopScope(
        //   onWillPop: () async => false, // 뒤로가기 버튼 처리를 위한 콜백 함수. false를 반환하여 뒤로가기 버튼을 무시하도록 설정
        //   child: Scaffold(
        //     // ...
        //   ),
        // ),
        //

        // Get.offAll(MapSample());
        //홈으로 넘어가게 하면 됨
      } on FirebaseAuthException catch (e) {
        logger.e(e);
        String message = '';

        if (e.code == 'user-not-found') {
          message = '사용자가 존재하지 않습니다.';
        } else if (e.code == 'wrong-password') {
          message = '비밀번호를 확인하세요';
        } else if (e.code == 'invalid-email') {
          message = '이메일을 확인하세요.';
        }

        /*final snackBar = SnackBar(
          content: Text(message),
          backgroundColor: Colors.deepOrange,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      */

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.deepOrange,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/icon.png', // 이미지 파일 경로
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Live돌발사고',
                        style: TextStyle(
                          fontSize: 48,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: '이메일',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return '이메일을 입력해주세요.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return '비밀번호를 입력해주세요.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                  ),
                  onPressed: _login,
                  child: Text('로그인'),
                ),
              ),
              SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    showEmailInputDialog(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                  child: Text("비밀번호를 잊어버리셨나요?"),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterPage(),
                      ),
                    );
                  },
                  child: Text('회원가입'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



}

  class RegisterPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  void create_account(BuildContext context) async  {
    String message = '';
    bool isNicknameExist = await checkNicknameExist(_nameController.text);

    if(_nameController.text.isEmpty){
      message = '닉네임을 입력해주세요';
    }else if (_passwordController.text.isEmpty){
      message = '비밀번호를 입력해주세요';
    }else if (_emailController.text.isEmpty){
      message = '이메일를 입력해주세요';
    }else if (_passwordController.text != _confirmPasswordController.text) {
      message = '비밀번호 확인과 비밀번호가 다릅니다';
    }else if (isNicknameExist) {
      message = '이미 존재하는 닉네임입니다.';
    }
    else {
      try {
        var result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        String? uid = result.user?.uid;

        CollectionReference users = FirebaseFirestore.instance.collection('user');


        FirebaseStorage storage = await FirebaseStorage.instance;
        // Generate a random number between 1 and 200
        var rng = new Random();
        int iconNumber = rng.nextInt(200) + 1;

        // Create a reference to the file
        Reference ref = storage.ref('profiles/icon$iconNumber.png');

        // Get the download URL
        String downloadURL = await ref.getDownloadURL();


        // Firestore에 사용자 정보 저장
        await users.doc(uid).set({
          'name': _nameController.text,
          'uid': uid,
          'authority': 'user',
          'following' : 0,
          'follow' : 0,
          'post_count' : 0,
          'profile' : downloadURL,
        });

        result.user?.updateDisplayName(_nameController.text);


        if (message == '') {
          ScaffoldMessenger
              .of(context)
              .showSnackBar(
            SnackBar(
              content: Text('${_nameController.text}님 회원가입에 성공하셨습니다.'),
              backgroundColor: Colors.deepOrange,
              duration: Duration(seconds: 1),
            ),
          )
              .closed
              .then((_) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Login()), // LoginPage로 화면 전환
            );
          });
        }


        // print(result.user);            //유저 정보 나중에 따로 처리
      } on FirebaseAuthException catch (e) {
        logger.e(e);


        if (e.code == 'email-already-in-use') {
          message = '이미 존재하는 이메일입니다';
        } else if (e.code == 'weak-password') {
          message = '비밀번호는 최소 6자이상이여야 합니다';
        } else if (e.code == 'invalid-email') {
          message = '이메일 형식이 올바르지 않습니다';
        } else if (e.code == 'unkown') {
          message = '빠진 내용이 있습니다';
        }
      }


    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }// create_account

  Future<bool> checkNicknameExist(String nickname) async {  //name이 존재하는지 확인
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('name', isEqualTo: nickname)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  //=================================================================

  // _postRequest() async {
  //   try {
  //   DateTime now = DateTime.now();
  //   int timestamp = now.millisecondsSinceEpoch;
  //   String url = 'https://sens.apigw.ntruss.com/sms/v2/services/ncp:sms:kr:308204771431:emergency_report/messages'; // 엔드포인트 URL
  //   String serviceId = 'ncp:sms:kr:308204771431:emergency_report';
  //   String timeStamp = timestamp.toString();
  //   String accessKey = 'Qqqt0HxbM6qrEEhgNgZ1';
  //   String secretKey = 'LxDG8TbpJNWEL7VnLXmP6MG0XLccXyjH8vN7YUO6';
  //   String sigbiture = getSignature(serviceId, timeStamp, accessKey, secretKey);
  //
  //   http.Response response = await http.post(
  //     Uri.parse(url),
  //     headers: <String, String> {
  //       'Content-Type': 'application/json; charset=utf-8',
  //       'x-ncp-apigw-timestamp': timeStamp,
  //       'x-ncp-iam-access-key': accessKey,
  //       'x-ncp-apigw-signature-v2': sigbiture,
  //     },
  //     body: jsonEncode(<String, dynamic> {
  //       'type': 'SMS',
  //       'contentType': 'COMM',
  //       'countryCode': '82',
  //       'from': '01051186937',
  //       'content': '입력할 내용',
  //       'messages': [
  //         {
  //           'to': '01051186937', // 112 또는 119
  //           'content': '이건 뭐지?',
  //         },
  //       ],
  //     }),
  //   );
  //   print('=========================='+'실행완료');
  //   print(response.bodyBytes);
  //   } catch (error) {
  //     print('오류 발생: $error');
  //   }
  // }



  // String getSignature(
  //     String serviceId, String timeStamp, String accessKey, String secretKey) {
  //   var space = " "; // one space
  //   var newLine = "\n"; // new line
  //   var method = "POST"; // method
  //   var url = "/sms/v2/services/$serviceId/messages";
  //
  //   var buffer = new StringBuffer();
  //   buffer.write(method);
  //   buffer.write(space);
  //   buffer.write(url);
  //   buffer.write(newLine);
  //   buffer.write(timeStamp);
  //   buffer.write(newLine);
  //   buffer.write(accessKey);
  //   print(buffer.toString());
  //
  //   /// signing key
  //   var key = utf8.encode(secretKey);
  //   var signingKey = new Hmac(sha256, key);
  //
  //   var bytes = utf8.encode(buffer.toString());
  //   var digest = signingKey.convert(bytes);
  //   String signatureKey = base64.encode(digest.bytes);
  //   return signatureKey;
  // }



  //========================================================


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
      ),
      resizeToAvoidBottomInset : false,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '닉네임',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return '닉네임을 입력해주세요.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: '이메일',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return '이메일을 입력해주세요.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return '비밀번호를 입력해주세요.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return '비밀번호 확인을 입력해주세요.';
                  }
                  if (value != _passwordController.text) {
                    return '비밀번호와 비밀번호 확인이 일치하지 않습니다.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                  // onPressed: () { _postRequest();},
                  onPressed: () {create_account(context);},

                  child: Text('회원가입'),
                ),
              ),
              // SizedBox(
              //   width: double.infinity,
              //   child:
              //   ElevatedButton.icon(
              //
              //     style: ElevatedButton.styleFrom(
              //       foregroundColor: Colors.white,
              //       backgroundColor: Colors.red,
              //     ),
              //     icon: Icon(Icons.account_circle_outlined), // 아이콘
              //     label: Text('구글 회원가입'),
              //     onPressed: () { signInWithGoogle(); },
              //   ),
              // )
            ],
          ),
        ),
      ),
    );

  }

}

Future<UserCredential> signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}