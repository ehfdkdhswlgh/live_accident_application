import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location_service.dart';
import 'tags.dart';
import '../haechan/profile.dart' as profile;
import 'package:cloud_firestore/cloud_firestore.dart';


class MapSample extends StatefulWidget {
  const MapSample({super.key});

  _MapSampleState createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, String>> items = [];

  Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  TextEditingController _searchController = TextEditingController();

  // 이 값은 지도가 시작될 때 첫 번째 위치입니다.
  CameraPosition _currentPosition = CameraPosition(
    target: LatLng(37.382782, 127.1189054),
    zoom: 14,
  );


  var address = "한강로 1가";
  List<String> postTitle = ["실시간 한강로 상황", "한강로 집회 사람 많네 ㄷㄷ ", "집회 현황 ㅎㄷㄷ", "출근길 조심하세요!!"];

  List<Marker> markers = [];
  @override
  void initState() {
    super.initState();

    _fetchOpendatasItems();

    //marker 추가
    markers.add(Marker(
        markerId: MarkerId("1"),
        draggable: false,
        infoWindow: InfoWindow(title: address, snippet: postTitle.length.toString() + "건"),
        onTap: () {
          showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  height: 1000,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0)
                    )
                  ),
                    child: Scaffold(
                      appBar: AppBar(title: Text(address)),
                    body:
                        ListView.builder(
                        itemCount: postTitle.length,
                        itemBuilder: (c,i){
                          return ListTile(
                            leading: Icon(
                              Icons.favorite, weight: 10,
                            ),
                            title: Text(postTitle[i]));
                        }),
                  )
                );
              });
        },
        position: LatLng(37.382782, 127.1189054)));

  }



  @override
  Widget build(BuildContext context) {
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
                MaterialPageRoute(builder: (context) => profile.ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body:
      Column(
        children : [
          Container(
            child: Tags(), height: 80,
          ),
          Row(
            children: [
              Expanded(child: TextFormField(
                controller: _searchController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(hintText: "장소를 입력하세요."),
              )),
              IconButton(onPressed: () async{
                var place = await LocationService().getPlace(_searchController.text);
                _goToPlace(place);
              },
                icon: Icon(Icons.search),)
            ],
          ),
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _currentPosition,
              markers: Set.from(markers), //마커 저장.
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              myLocationButtonEnabled: true,
            ),
          ),

      ],

    ),
    );
  }

  Future<void> _goToPlace(Map<String, dynamic> place) async{
    final double lat = place['geometry']['location']['lat'];
    final double lng = place['geometry']['location']['lng'];

    print(lat);
    print(lng);

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

    print('Items length: ${items.length}');
    print('Items contents:');
    items.forEach((item) => print(item));
  }


}