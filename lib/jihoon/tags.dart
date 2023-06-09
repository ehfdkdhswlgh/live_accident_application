import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:live_accident_application/hojun/store.dart';

class Tags extends StatefulWidget {
  const Tags({Key? key}) : super(key: key);

  @override
  State<Tags> createState() => _TagsState();
}

class _TagsState extends State<Tags> {

  final List<String> _acc = ['전체','사고','공사','행사','기상','통제','교통'];
  var _selectedAccIndex = 0;

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


  int get index {
    return this._selectedAccIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SingleChildScrollView(
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
            Divider(thickness: 2.0),
          ],
        )
    );
  }
}