import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSample extends StatefulWidget {
  @override
  _MapSampleState createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();

  // 이 값은 지도가 시작될 때 첫 번째 위치입니다.
  CameraPosition _currentPosition = CameraPosition(
    target: LatLng(37.4537251, 126.7960716),
    zoom: 14.4746,
  );

  List<Marker> markers = [];

  @override
  void initState() {
    super.initState();
    //marker 추가
    markers.add(Marker(
        markerId: MarkerId("1"),
        draggable: true,
        onTap: () => print("Marker!"),
        position: LatLng(37.4537251, 126.7960716)));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google Maps"),
      ),
      body: Container(
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
    );
  }
}