import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Store extends ChangeNotifier{
  // var likeState = false;
  // var likeNum = 0;
  var commentNum = 10;

  //제보글 업로드 할 때 타입
  var postType = 1;

  //제보글 조회에서 선택된 태그
  var selectedPostType = 0;


  //제보글 조회에서 선택된 정렬순서
  var selectedPostOrder = 0;

  //제보글 업로드에서 디비에 저장될 타입을 변환해서 저장
  setPostType(String text){
    if(text=="사고"){
      postType = 1;
    } else if (text=="공사"){
      postType = 2;
    } else if (text=="행사/시위") {
      postType = 3;
    } else if (text=='기상') {
      postType = 4;
    } else if (text=='통제') {
      postType = 5;
    } else if (text=='교통') {
      postType = 6;
    }
    notifyListeners();
  }

  setReadPostType(int selectedPostType){
    this.selectedPostType = selectedPostType;
    notifyListeners();
  }

  setReadPostOrder(int selectedPostOrder){
    this.selectedPostOrder = selectedPostOrder;
    notifyListeners();
  }

  void _goToPostScreen(int currentIndex) {
    currentIndex = 1;
    notifyListeners();
  }

  String formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final time = timestamp.toDate();

    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}
