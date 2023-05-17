import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location_service.dart';
import 'tags.dart' as tag;
import '../haechan/profile.dart' as profile;
import 'package:cloud_firestore/cloud_firestore.dart';


class MapSample extends StatefulWidget {
  const MapSample({super.key});

  _MapSampleState createState() => _MapSampleState();
}


class _MapSampleState extends State<MapSample> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, String>> items = [];
  List<String> _acc = ['전체','사고','공사','행사','통제','기타'];
  String tagType ="";

  Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  TextEditingController _searchController = TextEditingController();

  LatLng? currentPosition;



  var selectedPostType = 1;

  var address = "한강로 1가";
  List<String> postTitle = ["실시간 한강로 상황", "한강로 집회 사람 많네 ㄷㄷ ", "집회 현황 ㅎㄷㄷ", "출근길 조심하세요!!"];
  int i = 0;
  List<Marker> markers = [];


  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    _fetchOpendatasItems();



  }

  // selectedPostType = context.read<Store>().selectedPostType;
  // print("지금 선택된 위치는? : $selectedPostType");

  @override
  Widget build(BuildContext context) {
    if (currentPosition == null) {
      // 위치 정보가 아직 가져와지지 않았을 경우에 대한 처리
      print("로딩중...");
      return Stack(
        fit: StackFit.loose,
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
                      builder: (context) => profile.ProfileScreen()),
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
                markers: Set<Marker>.from(items.map((data) {
                  String latitude = data['locationDataX'] as String;
                  String longitude = data['locationDataY'] as String;
                  String title = data['addressJibun'] as String;
                  String description = data['incidentTitle'] as String;
                  tagType = description.substring(1, 3);
                  i++;


                  return Marker(
                      markerId: MarkerId(i.toString()),
                      position: LatLng(
                          double.parse(longitude), double.parse(latitude)),
                      infoWindow: InfoWindow(
                        title: title,
                        snippet: description,
                      ),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: 200,
                              child: ListView(
                                children: [
                                  ListTile(
                                    title: Text('항목 1'),
                                    onTap: () {
                                      // 선택된 항목에 대한 처리 로직
                                      Navigator.pop(context); // Bottom sheet 닫기
                                    },
                                  ),
                                  ListTile(
                                    title: Text('항목 2'),
                                    onTap: () {
                                      // 선택된 항목에 대한 처리 로직
                                      Navigator.pop(context); // Bottom sheet 닫기
                                    },
                                  ),
                                  // 추가적인 항목w들...
                                ],
                              ),
                            );
                          },
                        );
                      }
                  );
                })),
                //마커 저장.

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
  Future<void> _goToPlace(Map<String, dynamic> place) async{
    final double lat = place['geometry']['location']['lat'];
    final double lng = place['geometry']['location']['lng'];

    // print(lat);
    // print(lng);

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(lat,lng),
      zoom: 14)
    ));

  }


  Future<void> _fetchOpendatasItems() async {
    List<Map<String, String>> opendatasItems = [];

    QuerySnapshot querySnapshot = await _firestore.collection('opendatas').get();
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

  Future<void> getCurrentLocation() async {

    print("11111");
    LocationPermission permission = await Geolocator.requestPermission();
    print("222222");
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );

    print("3333333");
    setState(() {
      currentPosition = LatLng(position.latitude, position.longitude);
    });

    print("4444444");
    print(position.latitude);
    print(position.longitude);

  }


}