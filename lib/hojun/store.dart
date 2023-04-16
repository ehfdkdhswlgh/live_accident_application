import 'package:flutter/material.dart';

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
}