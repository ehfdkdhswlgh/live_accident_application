import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:live_accident_application/hojun/store.dart';

class Tags extends StatefulWidget {
  const Tags({Key? key}) : super(key: key);

  @override
  State<Tags> createState() => _TagsState();
}

class _TagsState extends State<Tags> {

  final List<String> _acc = ['전체','사고','공사','행사','통제','기타'];
  var _selectedAccIndex = 0;

  Widget accTags(String txt, int index){
    return OutlinedButton(
      onPressed: (){
        setState(() {
          _selectedAccIndex = index;
          context.read<Store>().setReadPostType(index);
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

  int get index {
    return this._selectedAccIndex;
  }
  Widget orderTags(String txt, int index){
    return TextButton(
      onPressed: (){
        setState(() {
          context.read<Store>().setReadPostOrder(index);
        });
      },
      child: Text(txt),
      style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))
          ),

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

            Divider(thickness: 2.0),
          ],
        )
    );
  }
}