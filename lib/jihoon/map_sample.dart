import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_accident_application/UserImfomation.dart';
import '../hojun/post_main_document.dart';
import '../hojun/store.dart';
import 'MarkerData.dart';
import 'location_service.dart';
import 'tags.dart' as tag;
import '../haechan/profile.dart' as profile;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../hojun/feed.dart';


class MapSample extends StatefulWidget {
  const MapSample({super.key,required this.selectedType});
  final selectedType;
  _MapSampleState createState() => _MapSampleState();
}


class _MapSampleState extends State<MapSample> {

  bool _isLoading = false;


  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, String>> items = [];
  List<Map<String, String>> post_items = [];


  Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  TextEditingController _searchController = TextEditingController();

  LatLng? currentPosition;


  var selectedPostType = 1;

  var address = "한강로 1가";

  int i = 0;
  Set<Marker> markers = {};


  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    _fetchData();
  }

  @override
  void didUpdateWidget(MapSample oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedType != oldWidget.selectedType) {
      _isLoading = false;
      setState(() {
        items = [];
        post_items = [];
        markers = {};
      });
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });


    QuerySnapshot querySnapshotOD;
    QuerySnapshot querySnapshotPost;
    List<Map<String, String>> postItems = [];
    List<Map<String, String>> opendatasItems = [];


    if (context.read<Store>().selectedPostType == 0) {
      if (items.isEmpty && post_items.isEmpty) {
        _fetchOpendatasItems();
        _fetchPostItems();
      }
    }
      else{
        print("하이");
        print(context.read<Store>().selectedPostType.toString());
        if (items.isEmpty && post_items.isEmpty) {


          querySnapshotPost = await _firestore
              .collection('posts')
              .where('is_visible', isEqualTo: true)
              .where('post_type', isEqualTo: context
              .read<Store>()
              .selectedPostType)
              .get();


          querySnapshotOD = await _firestore
              .collection('opendatas')
              .where('incidenteTypeCd', isEqualTo: context.read<Store>().selectedPostType.toString()).get();


          querySnapshotPost.docs.forEach((doc) {
            postItems.add({
              'address_name': doc['address_name'],
              'images': doc['images'],
              'is_visible': doc['is_visible'].toString(),
              'post_content': doc['post_content'],
              'post_id': doc['post_id'],
              'post_type': doc['post_type'].toString(),
              'timestamp': doc['timestamp'].toString(),
              'title': doc['title'],
              'user_id': doc['user_id'],
              'latitude': doc['latitude'].toString(),
              'longitude': doc['longitude'].toString(),
              'like': doc['like'].toString()
            });
          });


          querySnapshotOD.docs.forEach((doc) {
            opendatasItems.add({
              'incidenteTypeCd': doc['incidenteTypeCd'],
              'incidenteSubTypeCd': doc['incidenteSubTypeCd'],
              'addressJibun': doc['addressJibun'],
              'locationDataX': doc['locationDataX'],
              'locationDataY': doc['locationDataY'],
              'incidentTitle': doc['incidentTitle'],
              'startDate': doc['startDate'],
              'endDate': doc['endDate'],
              'roadName': doc['roadName'],
            });
          });

          setState(() {
            post_items = postItems;
            items = opendatasItems;
          });
         }


        print('post_items: $post_items');
        print('items: $items');


        }


    }



  @override
  Widget build(BuildContext context) {
    
    _createPostMarkers(); // 제보글데이터
    _createOpendatasMarkers(); //공공데이터

    if (currentPosition == null) {
      // 위치 정보가 아직 가져와지지 않았을 경우에 대한 처리
      print("로딩중...");
      return Center(
          child: SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                fit: StackFit.expand,
                children: const [
                  SizedBox(
                      width: 30, height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 10,
                        backgroundColor: Colors.black,
                        color: Colors.green,
                      )),
                  Center(
                      child: Text(
                        'Loading....',
                        style: TextStyle(fontSize: 10),
                      )),
                ],
              )
          )
      );
    }
    else {
      print("로딩 완료...");
      return Scaffold(
        appBar: AppBar(
          title: Text("Live돌발사고"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                // 돋보기 아이콘 클릭 시 동작 정의
              },
            ),
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => profile.ProfileScreen(UserImfomation.uid)),
                );
              },
            ),
          ],
        ),
        body:
        Column(
          children: [
            tag.Tags(),
            Row(
              children: [
                Expanded(child: TextFormField(
                  controller: _searchController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(hintText: "장소를 입력하세요."),
                )),
                IconButton(onPressed: () async {
                  var place = await LocationService().getPlace(
                      _searchController.text);
                  _goToPlace(place);
                },
                  icon: Icon(Icons.search),)
              ],
            ),
            Expanded(
              child: GoogleMap(
                mapType: MapType.normal,

                initialCameraPosition: CameraPosition(
                  target: currentPosition!,
                  zoom: 15,
                ),
                markers: markers,


                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
            ),

          ],

        ),

      );
    }
  }

  Future<void> _goToPlace(Map<String, dynamic> place) async {
    final double lat = place['geometry']['location']['lat'];
    final double lng = place['geometry']['location']['lng'];

    // print(lat);
    // print(lng);

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng),
            zoom: 14)
    ));
  }


  Future<void> _fetchOpendatasItems() async {
    List<Map<String, String>> opendatasItems = [];

    QuerySnapshot querySnapshot = await _firestore.collection('opendatas')
        .get();
    querySnapshot.docs.forEach((doc) {
      opendatasItems.add({
        'incidenteTypeCd': doc['incidenteTypeCd'],
        'incidenteSubTypeCd': doc['incidenteSubTypeCd'],
        'addressJibun': doc['addressJibun'],
        'locationDataX': doc['locationDataX'],
        'locationDataY': doc['locationDataY'],
        'incidentTitle': doc['incidentTitle'],
        'startDate': doc['startDate'],
        'endDate': doc['endDate'],
        'roadName': doc['roadName'],
      });
    });

    setState(() {
      items = opendatasItems;
    });
  }

  Future<void> _fetchPostItems() async {
    List<Map<String, String>> postItems = [];
    QuerySnapshot querySnapshot = await _firestore.collection('posts').where('is_visible', isEqualTo: true).get();

    querySnapshot.docs.forEach((doc) {
      postItems.add({
        'address_name': doc['address_name'],
        'images': doc['images'],
        'is_visible': doc['is_visible'].toString(),
        'post_content': doc['post_content'],
        'post_id': doc['post_id'],
        'post_type': doc['post_type'].toString(),
        'timestamp': doc['timestamp'].toString(),
        'title': doc['title'],
        'user_id': doc['user_id'],
        'latitude': doc['latitude'].toString(),
        'longitude': doc['longitude'].toString(),
        'like': doc['like'].toString()
      });
    });

    setState(() {
      post_items = postItems;
    });

  }

  Future<String> getNickname(String user_id) async{
    QuerySnapshot userquery = await _firestore
        .collection('user')
        .where('uid', isEqualTo: user_id)
        .get();
    final userNickname = userquery.docs.first.get('name').toString();
    return userNickname;
  }


  Future<void> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );

    setState(() {
      currentPosition = LatLng(position.latitude, position.longitude);
    });
  }


  void _createPostMarkers() {
    List<MarkerData> markerDataList = [];

    for (var item in post_items) {
      int decimalIndex = item['latitude']!.indexOf('.') + 4;
      int decimalIndex2 = item['longitude']!.indexOf('.') + 4;

      LatLng position = LatLng(
        double.parse(item['latitude']!.substring(0, decimalIndex)),
        double.parse(item['longitude']!.substring(0, decimalIndex2)),
      );


      bool isDuplicate = false;

      for (var markerData in markerDataList) {

        if (markerData.position == position) {
          markerData.dataList.add(item);
          isDuplicate = true;
          break;
        }
      }

      // 중복된 위치가 아니면 새로운 MarkerData 객체 생성
      if (!isDuplicate) {
        MarkerData markerData = MarkerData(position: position, dataList: [item]);
        markerDataList.add(markerData);
      }
    }



    // 마커 생성
    for (var markerData in markerDataList) {
      final marker = Marker(
        markerId: MarkerId(markerData.position.toString()),
        position: markerData.position,
        onTap: () {
          _showListDialog(markerData.dataList);
        },
      );

      markers.add(marker);
    }
  }

  void _createOpendatasMarkers() {
    for (var data in items) {
      String latitude = data['locationDataX']!;
      String longitude = data['locationDataY']!;
      String title = data['addressJibun']!;
      String description = data['incidentTitle']!;
      int i = markers.length + 1;

      Marker marker = Marker(
        markerId: MarkerId(i.toString()),
        position: LatLng(double.parse(longitude), double.parse(latitude)),
        infoWindow: InfoWindow(
          title: title,
          snippet: description,
        ),
        icon : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
      );

      markers.add(marker);
    }
  }

  void _showListDialog(List<Map<String, dynamic>> dataList) {
    final dialogHeight = MediaQuery.of(context).size.height * 0.95;

    showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return SafeArea(
          child: Dialog(
            insetPadding: EdgeInsets.zero, // remove padding
            child: Container(
              height: dialogHeight,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 50, child: Center(child: Text("제보현황"))),
                    Container(
                      height: dialogHeight - 100, // Subtract the height occupied by the title and the button
                      child: dataList.isNotEmpty
                          ? ListView.builder(
                        itemCount: dataList.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Divider(),
                              ListTile(
                                leading: Column(
                                  children: [
                                    Icon(Icons.favorite),
                                    SizedBox(width: 2),
                                    Text(dataList[index]['like']),
                                  ],),
                                title: Text("  "+ dataList[index]['title']),
                                onTap: () async {
                                  final String nickname = await getNickname(dataList[index]['user_id']);
                                  if(!mounted) return;
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (c, a1, a2) => PostDocument(
                                        postId: dataList[index]['post_id'],
                                        imageUrl: dataList[index]['images'],
                                        postMain: dataList[index]['post_content'],
                                        userNickname: nickname,
                                        postName: dataList[index]['title'],
                                        userId: dataList[index]['user_id'],
                                        timestamp: dataList[index]['timestamp'],
                                        like: dataList[index]['like'],
                                      ),
                                      transitionsBuilder: (c, a1, a2, child) =>
                                          FadeTransition(opacity: a1, child: child),
                                    ),
                                  );
                                },
                              ),
                              Divider()
                            ],
                          );
                        },
                      )
                          : Text('해당 위치에 데이터가 없습니다.'),
                    ),
                    SizedBox(height: 50, child: Center(
                      child: TextButton(
                        child: Text('닫기'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 500),
      transitionBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        final begin = Offset(0.0, 1.0);
        final end = Offset.zero;
        final curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }







}