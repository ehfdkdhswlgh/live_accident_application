import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'tags.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_webservice/src/places.dart';

class MapSample extends StatefulWidget {
  @override
  _MapSampleState createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();

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
        title: TextField(
          decoration: InputDecoration(
            hintText: '장소를 검색하세요...',
            hintStyle: TextStyle(color: Colors.white),
          ),
          style: TextStyle(color: Colors.white),
          onSubmitted: (value) {
            // searchAndNavigate(value);
          },
        ),
      ),

      body:
      Column(
        children : <Widget> [
         Container(
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
      ],
    ),
    );
  }
}

// void searchAndNavigate(String address) {
//   GeocodingPlatform.instance.locationFromAddress(address).then((result) {
//     _controller.animateCamera(CameraUpdate.newCameraPosition(
//       CameraPosition(
//         target: LatLng(result[0].latitude, result[0].longitude),
//         zoom: 14.0,
//       ),
//     ));
//     _addMarker(LatLng(result[0].latitude, result[0].longitude), address);
//   });
// }


