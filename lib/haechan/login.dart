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



void main() {
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

  String uid = UserImfomation.uid;

  String my_email = 'hae507@gmail.com';
  String my_pw = '123456';


  _login() async {
    //키보드 숨기기
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).requestFocus(FocusNode());

      // Firebase 사용자 인증, 사용자 등록
      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        uid = userCredential.user!.uid;

        print("UID : " + uid);

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
      appBar: AppBar(
        title: Text(widget.title),
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
                controller: _emailController,
                // initialValue: 'hae507@gmail.com',
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
                // initialValue: '123456',
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
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: _login,
                  child: Text('로그인'),
                ),
              ),
              SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    primary: Colors.blue,
                    side: BorderSide(color: Colors.blue),
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
              // SizedBox(
              //   width: double.infinity,
              //   child: ElevatedButton.icon(
              //     style: ElevatedButton.styleFrom(
              //       foregroundColor: Colors.white,
              //       backgroundColor: Colors.red,
              //     ),
              //     icon: Icon(Icons.account_circle_outlined), // 아이콘
              //     label: Text('구글 로그인'),
              //     onPressed: () { signInWithGoogle(); },
              //   ),
              // ),
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

        // Firestore에 사용자 정보 저장
        await users.doc(uid).set({
          'name': _nameController.text,
          'uid': uid,
          'authority': 'user',
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