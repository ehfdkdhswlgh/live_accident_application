import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'store.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'post_main_document.dart';

class MainPost extends StatefulWidget {
  const MainPost({Key? key}) : super(key: key);

  @override
  State<MainPost> createState() => _MainPostState();
}

class _MainPostState extends State<MainPost> {

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Profile(),
              GestureDetector(
                child: Thumbnail(),
                onTap: () {
                  Navigator.push(context,
                      PageRouteBuilder(
                          pageBuilder: (c, a1, a2) => PostDocument(postId: '950KJmoL4sK1viwfbBA8'),
                          transitionsBuilder: (c, a1, a2, child) =>
                              FadeTransition(opacity: a1, child: child)
                      )
                  );
                },
              ),
              Preview(),
              Divider(thickness: 2.0),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Like(),
              Comment(),
            ],
          ),
          Divider(thickness: 2.0),
        ],
      ),
    );
  }
}

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey, // 프사를 넣을 경우 backgroundImage
            ),
            Column(
              children: [
                Text('제보날씨'), // 닉네임 위치
                Text('홍천교'), // 제보 위치
              ],
            ),
          ],
        ),
        Column(
          children: [
            IconButton(onPressed: (){}, icon: Icon(Icons.more_horiz)), // 아이콘
            Text('203일전'), // 업로드 날짜
          ],
        )
      ],
    );
  }
}

class Thumbnail extends StatefulWidget {
  const Thumbnail({Key? key}) : super(key: key);

  @override
  State<Thumbnail> createState() => _ThumbnailState();
}

class _ThumbnailState extends State<Thumbnail> {
  int _current = 0;
  final CarouselController _controller = CarouselController();
  var imageList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final FirebaseStorage storage = FirebaseStorage.instance;
    // 경로 지정
    final String path = '';

    // Firebase Storage에서 해당 경로의 모든 파일 가져오기
    storage.ref().child(path).listAll().then((result) {
      // 모든 파일 URL 가져와서 imageList에 추가
      result.items.forEach((ref) {
        ref.getDownloadURL().then((url) {
          setState(() {
            imageList.add(url);
          });
        });
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Stack(
        children: [
          sliderWidget(),
          sliderIndicator(),
        ],
      ),
    );
  }

  Widget sliderWidget() {
    return CarouselSlider(
      carouselController: _controller,
      items: imageList.map(
            (imgLink) {
          return Builder(
            builder: (context) {
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Image(
                  fit: BoxFit.fill,
                  image: NetworkImage(
                    imgLink,
                  ),
                ),
              );
            },
          );
        },
      ).toList(),
      options: CarouselOptions(
        height: 500,
        viewportFraction: 1.0,
        autoPlay: false, //자동으로 넘어가기
        // autoPlayInterval: const Duration(seconds: 4), //자동 넘어가기 시간
        onPageChanged: (index, reason) {
          setState(() {
            _current = index;
          });
        },
      ),
    );
  }

  Widget sliderIndicator() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: imageList.asMap().entries.map((entry) {
          return GestureDetector(
            onTap: () => _controller.animateToPage(entry.key),
            child: Container(
              width: 12,
              height: 12,
              margin:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                Colors.white.withOpacity(_current == entry.key ? 0.9 : 0.4),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class Preview extends StatelessWidget {
  const Preview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: RichText(
              overflow: TextOverflow.ellipsis,
              maxLines: 2, //출력되는 최대 줄
              strutStyle: StrutStyle(fontSize: 12.0),
              text: TextSpan(
                text:
                "세계문자 가운데 한글,즉 훈민정음은 흔히들 신비로운 문자라 부르곤 합니다. 그것은 세계 문자 가운데 유일하게 한글만이 그것을 만든 사람과 반포일을 알며, 글자를 만든 원리까지 알기 때문입니다. 세계에 이런 문자는 없습니다. 그래서 한글은, 정확히 말해 [훈민정음 해례본](국보 70호)은 진즉에 유네스코 세계기록유산으로 등재되었습니다. ‘한글’이라는 이름은 1910년대 초에 주시경 선생을 비롯한 한글학자들이 쓰기 시작한 것입니다. 여기서 ‘한’이란 크다는 것을 뜻하니, 한글은 ‘큰 글’을 말한다고 하겠습니다.[네이버 지식백과] 한글 - 세상에서 가장 신비한 문자 (위대한 문화유산, 최준식)",
                style: TextStyle(
                  color: Colors.black,
                  height: 1.4,
                  fontSize: 12.0,
                  // fontFamily: // 글자 폰트 지정 가능 
                )
              ),
            )
          )
        ],
      ),
    );
  }
}

class Like extends StatelessWidget {
  const Like({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
            onPressed: (){
              context.read<Store>().liked();
            },
            icon: context.watch<Store>().likeState ? Icon(Icons.favorite) : Icon(Icons.favorite_border_outlined)
        ),
        Text('${context.watch<Store>().likeNum}'),
      ],
    );
  }
}

class Comment extends StatelessWidget {
  const Comment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
            onPressed: (){
            },
            icon: Icon(Icons.comment)
        ),
        Text('${context.watch<Store>().commentNum}'),
      ],
    );
  }
}
