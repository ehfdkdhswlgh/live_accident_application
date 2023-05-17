import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:live_accident_application/hojun/feed.dart';
import 'package:provider/provider.dart';
import 'store.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'post_main_document.dart';

class MainPost extends StatefulWidget {
  const MainPost({Key? key, required this.postContent}) : super(key: key);
  final Post postContent;

  @override
  State<MainPost> createState() => _MainPostState();
}

class _MainPostState extends State<MainPost> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: GestureDetector(
              child: Profile(userNickname: widget.postContent.userNickname),
              onTap: () {
                // '제보하기' 버튼 클릭 시 실행될 코드
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('프로필 누름'),
                  ),
                );
              },
            ),
          ),
          GestureDetector(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Thumbnail(url: widget.postContent.imageLinks),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4.0),
                      Text(
                        widget.postContent.postMain,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (c, a1, a2) => PostDocument(
                    postId: widget.postContent.postId,
                    imageUrl: widget.postContent.imageLinks,
                    postMain: widget.postContent.postMain,
                    userNickname: widget.postContent.userNickname,
                  ),
                  transitionsBuilder: (c, a1, a2, child) =>
                      FadeTransition(opacity: a1, child: child),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.favorite_border),
                    SizedBox(width: 4.0),
                    Text('Like'),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.comment_outlined),
                    SizedBox(width: 4.0),
                    Text('Comment'),
                  ],
                ),
              ],
            ),
          ),
          Divider(thickness: 2.0),
        ],
      ),
    );
  }
}
class Profile extends StatelessWidget {
  Profile({Key? key, required this.userNickname}) : super(key: key);
  final userNickname;

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
            SizedBox(width: 8.0), // Add some spacing between the avatar and text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userNickname), // 닉네임 위치
                Text('홍천교'), // 제보 위치
              ],
            ),
          ],
        ),
        Column(
          children: [
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      height: 300, // 모달 높이 크기
                      margin: const EdgeInsets.only(
                        left: 25,
                        right: 25,
                        bottom: 40,
                      ), // 모달 좌우하단 여백 크기
                      decoration: const BoxDecoration(
                        color: Colors.white, // 모달 배경색
                        borderRadius: BorderRadius.all(
                          Radius.circular(20), // 모달 전체 라운딩 처리
                        ),
                      ),
                      child: [
                        // 모달 내부 디자인 영역
                      ][0],
                    );
                  },
                );
              },
              icon: Icon(Icons.more_horiz),
            ), // 아이콘
            Text('203일전'), // 업로드 날짜
          ],
        ),
      ],
    );
  }
}

class Thumbnail extends StatefulWidget {
  const Thumbnail({Key? key, required this.url}) : super(key: key);
  final url;
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
    // Firebase Storage에서 해당 경로의 모든 파일 가져오기
    imageList = widget.url.split(',');
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
  const Preview({Key? key, this.content}) : super(key: key);
  final content;
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
                    content,
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
