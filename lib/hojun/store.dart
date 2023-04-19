import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Store extends ChangeNotifier{
  var likeState = false;
  var likeNum = 0;
  var commentNum = 10;

  liked(){
    if(likeState) {
      likeNum--;
      likeState = false;
    } else {
      likeNum++;
      likeState = true;
    }
    notifyListeners();
  }

  Future<String> downloadImage(String path) async {
    try {
      // Firebase Storage 인스턴스 생성
      final FirebaseStorage storage = FirebaseStorage.instance;
      // 다운로드할 파일의 경로 지정
      String filePath = path;
      // 파일 다운로드
      final ref = storage.ref().child(filePath);
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return "Null";
    }
  }
}
