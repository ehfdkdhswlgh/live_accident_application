import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'store.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'post_main_document.dart';
import '../jihwan/post_report.dart';
import '../haechan/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'modal.dart';

class MainPost extends StatefulWidget {
  const MainPost({Key? key, required this.postContent}) : super(key: key);
  final postContent;
  @override
  State<MainPost> createState() => _MainPostState();
}

class _MainPostState extends State<MainPost> {
  @override

  bool isLiked = false;  // 좋아요 상태를 추적하는 데 사용할 변수를 생성합니다.

  void initState() {
    super.initState();
    checkIfLikedOrNot();
  }

  void checkIfLikedOrNot() async {
    // Check if the current post is already liked by the user
    var user = FirebaseAuth.instance.currentUser;
    var likeRef = FirebaseFirestore.instance.collection('likes');
    var userLike = await likeRef
        .where('userId', isEqualTo: user?.uid)
        .where('postId', isEqualTo: widget.postContent.postId) // 'post_id'와 'user_id' 필드가 각 문서에 포함되어 있다고 가정합니다.
        .get();

    if (userLike.docs.length > 0) {
      setState(() {
        isLiked = true;
      });
    }
  }

  void handleLikePost() {
    var user = FirebaseAuth.instance.currentUser;

    if (isLiked) {
      // Already liked, so we need to unlike
      FirebaseFirestore.instance
          .collection('likes')
          .where('userId', isEqualTo: user?.uid)
          .where('postId', isEqualTo: widget.postContent.postId)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs[0].reference.delete();
      });

      FirebaseFirestore.instance
          .collection('posts')
          .where('post_id', isEqualTo: widget.postContent.postId)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs[0].reference.update({'like': FieldValue.increment(-1)});
      });

      setState(() {
        isLiked = false;
        widget.postContent.like -= 1;
      });

    } else {
      // Not liked yet, so we need to like
      FirebaseFirestore.instance.collection('likes').add({
        'userId': user?.uid,
        'postId': widget.postContent.postId,
        'timestamp': FieldValue.serverTimestamp(), // added this line
      });

      FirebaseFirestore.instance
          .collection('posts')
          .where('post_id', isEqualTo: widget.postContent.postId)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs[0].reference.update({'like': FieldValue.increment(1)});
      });

      setState(() {
        isLiked = true;
        widget.postContent.like += 1;
      });
    }
  }


  Widget build(BuildContext context) {
    return Container(
      width: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: GestureDetector(
              child: Profile(userNickname: widget.postContent.userNickname, postId: widget.postContent.postId, postName: widget.postContent.postName, userId: widget.postContent.userId, like: widget.postContent.like, address: widget.postContent.address, timestamp: widget.postContent.timestamp),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileScreen(widget.postContent.userId)),
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
                    postName: widget.postContent.postName,
                    userId: widget.postContent.userId,
                    timestamp: widget.postContent.timestamp,
                    like: widget.postContent.like,
                    address: widget.postContent.address,
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
                GestureDetector(
                  onTap: handleLikePost,
                  child: Row(
                    children: [
                      Icon(isLiked ? Icons.favorite : Icons.favorite_border),
                      SizedBox(width: 4.0),
                      Text(widget.postContent.like.toString()),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (c, a1, a2) => PostDocument(
                          postId: widget.postContent.postId,
                          imageUrl: widget.postContent.imageLinks,
                          postMain: widget.postContent.postMain,
                          userNickname: widget.postContent.userNickname,
                          postName: widget.postContent.postName,
                          userId: widget.postContent.userId,
                          timestamp: widget.postContent.timestamp,
                          like: widget.postContent.like,
                          address: widget.postContent.address,
                        ),
                        transitionsBuilder: (c, a1, a2, child) =>
                            FadeTransition(opacity: a1, child: child),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.comment_outlined),
                      SizedBox(width: 4.0),
                      Text('Comment'),
                    ],
                  ),
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
  Profile({Key? key, required this.userNickname, required this.postId, required this.postName, required this.userId, required this.like, required this.address, required this.timestamp}) : super(key: key);
  final userNickname;
  final postId;
  final postName;
  final userId;
  final address;
  final timestamp;
  var like;

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
                Container(
                  width: 125,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                          child: RichText(
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2, //출력되는 최대 줄
                            strutStyle: StrutStyle(fontSize: 10),
                            text: TextSpan(
                                text:
                                address,
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
                ),
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
                    return Modal(postId: postId, postName: postName, userId: userId, userNickname: userNickname);
                  },
                );
              },
              icon: Icon(Icons.more_horiz),
            ), // 아이콘
            Text(formatTimestamp(timestamp)), // 업로드 날짜
          ],
        ),
      ],
    );
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
    // Check if the imageList is empty
    if (imageList.length == 1 && imageList[0] == '') {
      return Container();  // or return any widget you want when there is no thumbnail
    } else {
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
                child: CachedNetworkImage(
                  imageUrl: imgLink,
                  placeholder: (context, url) => Center(child: SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: CircularProgressIndicator(),
                  )),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  fit: BoxFit.fill,
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
