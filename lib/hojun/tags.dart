import 'package:flutter/material.dart';

class Tags extends StatefulWidget {
  const Tags({Key? key}) : super(key: key);

  @override
  State<Tags> createState() => _TagsState();
}

class _TagsState extends State<Tags> {

  final List<String> _acc = ['전체','사고','공사','행사','통제','기타'];
  final List<String> _ord = ['거리순','최신순','추천순'];
  int _selectedAccIndex = 0;
  int _selectedOrdIndex = 0;

  Widget accTags(String txt, int index){
    return OutlinedButton(
      onPressed: (){
        setState(() {
          _selectedAccIndex = index;
        });
      },
      child: Text(txt),
      style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8.0),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))
          ),
          side: BorderSide(
              width: (_selectedAccIndex == index) ? 2.0 : 0.5,
              color: (_selectedAccIndex == index)
                  ? Colors.red
                  : Colors.black
          )
      ),
    );
  }

  Widget orderTags(String txt, int index){
    return TextButton(
      onPressed: (){
        setState(() {
          _selectedOrdIndex = index;
        });
      },
      child: Text(txt),
      style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))
          ),
          side: BorderSide(
              width: (_selectedOrdIndex == index) ? 2.0 : 0.5,
              color: (_selectedOrdIndex == index)
                  ? Colors.red
                  : Colors.black
          )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              accTags(_acc[0], 0),
              accTags(_acc[1], 1),
              accTags(_acc[2], 2),
              accTags(_acc[3], 3),
              accTags(_acc[4], 4),
              accTags(_acc[5], 5),
            ],
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
      )
    );
  }
}