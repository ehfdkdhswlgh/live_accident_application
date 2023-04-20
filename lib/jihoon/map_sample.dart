import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'tags.dart';

import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';


class MapSample extends StatefulWidget {
  @override
  _MapSampleState createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();
  TextEditingController controller = TextEditingController();

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
          Container(
            child: Tags(), height: 80,
          ),
          placesAutoCompleteTextField(),
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


placesAutoCompleteTextField() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 20),
    child: GooglePlaceAutoCompleteTextField(
        textEditingController: controller,
        googleAPIKey: "AIzaSyDWq89VaEKZdEWpv6VoHQ8EVM5JSqE4JJs",
        inputDecoration: InputDecoration(hintText: "위치를 입력하세요."),
        debounceTime: 800,
        countries: ["in", "fr"],
        isLatLngRequired: true,
        getPlaceDetailWithLatLng: (Prediction prediction) {
          print("placeDetails" + prediction.lng.toString());
        },
        itmClick: (Prediction prediction) {
          controller.text = prediction.description!;

          controller.selection = TextSelection.fromPosition(
              TextPosition(offset: prediction.description!.length));
        }
      // default 600 ms ,
    ),
  );
}
}