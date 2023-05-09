
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_accident_application/jihoon/location_service.dart';
import 'tags.dart';
import 'package:place_picker/place_picker.dart';




class MapSample extends StatefulWidget {
  @override
  _MapSampleState createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> {

  final TextEditingController _searchController = TextEditingController();

  Completer<GoogleMapController> _controller = Completer();
  List<Marker> markers = [];



  // 이 값은 지도가 시작될 때 첫 번째 위치입니다.
  CameraPosition _currentPosition = CameraPosition(
    target: LatLng(37.382782, 127.1189054),
    zoom: 14,
  );

  var address = "한강로 1가";
  List<String> postTitle = ["실시간 한강로 상황", "한강로 집회 사람 많네 ㄷㄷ ", "집회 현황 ㅎㄷㄷ", "출근길 조심하세요!!"];

  @override
  void initState() {
    super.initState();
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
                        SingleChildScrollView(
                          child : ListView.builder(
                        itemCount: postTitle.length,
                        itemBuilder: (c,i){
                          return ListTile(
                            leading: Icon(
                              Icons.favorite, weight: 10,
                            ),
                            title: Text(postTitle[i]));
                        }),
                  )
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
              // 내정보 아이콘 클릭 시 동작 정의
            },
          ),
        ],
      ),
      body:
      Column(
        children : <Widget> [
          Row(children: [
            Expanded(child: TextFormField(
              controller: _searchController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(hintText: '장소를 검색하세요.'),
              onChanged: (value) {
              },
            )),
            IconButton(onPressed: () async {
              var place = await LocationService().getPlace(_searchController.text);
              _goToPlace(place);
            }, icon: Icon(Icons.search),),
          ],),
          Container(
            child: Tags(), height: 80,
          ),
          Expanded(
            child: Container(
            height: double.infinity,
            width: double.infinity,
            child: GoogleMap(
              initialCameraPosition: _currentPosition,
              markers: Set.from(markers), //마커 저장.
              onMapCreated: (GoogleMapController controller) {
                _controller.complete();
              },
              myLocationButtonEnabled: true,
            ),

          ),
          ),
      ],

    ),
    );
  }
    Future<void> _goToPlace(Map<String, dynamic> place) async {
      final double lat = place['geometry']['location']['lat'];
      final double lng = place['geometry']['location']['lng'];

      print(lat);
      print(lng);
      final GoogleMapController controller = await _controller.future;

      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 12),
        ),
      );
    }


}

