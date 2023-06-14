import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'store.dart';

class Tags extends StatefulWidget {
  const Tags({Key? key}) : super(key: key);

  @override
  State<Tags> createState() => _TagsState();
}

class _TagsState extends State<Tags> {

  final List<String> _acc = ['전체','사고','공사','행사','기상','통제','교통'];
  final List<String> _ord = ['최신순','주변순','추천순'];



  Widget accTags(String txt, int index) {
    return Consumer<Store>(
      builder: (context, store, _) => Row(
        children: [
          OutlinedButton(
            onPressed: () {
              store.setReadPostType(index);
            },
            child: Text(
              txt,
              style: TextStyle(
                color: (store.selectedPostType == index) ? Colors.white : Colors.black, // 선택 여부에 따른 텍스트 색상 설정
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8.0),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              side: BorderSide(
                width: (store.selectedPostType == index) ? 2.0 : 0.5,
                color: (store.selectedPostType == index) ? Colors.red : Colors.grey,
              ),
              backgroundColor: (store.selectedPostType == index) ? Colors.red : Colors.white, // 선택 여부에 따른 배경 색상 설정
            ),
          ),
          SizedBox(width: 3), // 태그들 간의 간격을 8픽셀로 설정
        ],
      ),
    );
  }

  Widget orderTags(String txt, int index){
    return Consumer<Store>(
      builder: (context, store, _) => Row(
        children: [
          TextButton(
            onPressed: () {
              store.setReadPostOrder(index);
            },
            child: Text(
              txt,
              style: TextStyle(
                color: (store.selectedPostOrder == index) ? Colors.black : Colors.black54, // 선택 여부에 따른 텍스트 색상 설정
                fontWeight: (store.selectedPostOrder == index) ? FontWeight.bold : FontWeight.normal, // 선택 여부에 따른 폰트 굵기 설정
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8.0),
            ),
          ),
          SizedBox(width: 4), // 태그들 간의 간격을 4픽셀로 설정
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final double msgWindow = 50; // MSG_WINDOW 값에 해당하는 값으로 수정해주세요

    return Container(
      margin: EdgeInsets.all(5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            height: msgWindow, // MSG_WINDOW 값으로 상단 영역의 높이를 지정합니다
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  accTags(_acc[0], 0),
                  accTags(_acc[1], 1),
                  accTags(_acc[2], 2),
                  accTags(_acc[3], 3),
                  accTags(_acc[4], 4),
                  accTags(_acc[5], 5),
                  accTags(_acc[6], 6),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              orderTags(_ord[0], 0),
              orderTags(_ord[1], 1),
              orderTags(_ord[2], 2),
            ],
          ),
          Divider(thickness: 2.0),
        ],
      ),
    );
  }
}