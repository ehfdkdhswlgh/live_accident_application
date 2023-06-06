import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:live_accident_application/UserImfomation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../hojun/post_main_document.dart';
import '../hojun/store.dart';
import 'MarkerData.dart';
import 'location_service.dart';
import 'tags.dart' as tag;
import '../haechan/profile.dart' as profile;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:dart_geohash/dart_geohash.dart';


class MapSample extends StatefulWidget {
  const MapSample({super.key,required this.selectedType});
  final selectedType;
  _MapSampleState createState() => _MapSampleState();
}


class _MapSampleState extends State<MapSample> {

  bool _isLoading = false;
  var geoHasher = GeoHasher();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, String>> items = [];
  List<Map<String, dynamic>> post_items = [];
  List<Map<String, String>> earthquake_items = [];
  List<Map<String, String>> wildfire_items = [];
  List<MarkerData> markerDataList = [];

  List<Map<String, dynamic>> shelter_items = [];

  Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  TextEditingController _searchController = TextEditingController();

  LatLng? currentPosition;
  var selectedPostType = 1;
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
        earthquake_items = [];
        wildfire_items = [];
        markerDataList = [];
        markers.clear();
        shelter_items = [];
      });
    }
    _fetchData();
    print("데이터 정보 가운데 로딩완료");
  }


  Future<void> _fetchData() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });


    QuerySnapshot querySnapshotOD;
    QuerySnapshot querySnapshotPost;
    List<Map<String, dynamic>> postItems = [];
    List<Map<String, String>> opendatasItems = [];
    List<Map<String, String>> wildItems = [];
    List<Map<String, String>> eqItems = [];
    List<Map<String, dynamic>> shelterItem = [];




    if (context
        .read<Store>()
        .selectedPostType == 0) {
      if (items.isEmpty && post_items.isEmpty && earthquake_items.isEmpty &&
          wildfire_items.isEmpty) {
        _fetchAllData();
      }
    }
    else if (context
        .read<Store>()
        .selectedPostType == 4) {
      if (items.isEmpty && post_items.isEmpty && earthquake_items.isEmpty &&
          wildfire_items.isEmpty) {
        querySnapshotPost = await _firestore
            .collection('posts')
            .where('is_visible', isEqualTo: true)
            .where('post_type', isEqualTo: context
            .read<Store>()
            .selectedPostType)
            .get();


        querySnapshotOD = await _firestore
            .collection('opendatas')
            .where('incidenteTypeCd', isEqualTo: context
            .read<Store>()
            .selectedPostType
            .toString()).get();


        querySnapshotPost.docs.forEach((doc) {
          postItems.add({
            'address_name': doc['address_name'],
            'images': doc['images'],
            'is_visible': doc['is_visible'].toString(),
            'post_content': doc['post_content'],
            'post_id': doc['post_id'],
            'post_type': doc['post_type'].toString(),
            'timestamp': doc['timestamp'],
            'title': doc['title'],
            'user_id': doc['user_id'],
            'latitude': doc['latitude'].toString(),
            'longitude': doc['longitude'].toString(),
            'like': doc['like'].toString(),
            'fastTimeStamp': doc['timestamp'].toDate()
          });
        });

        postItems.sort((a, b) =>
            b['fastTimeStamp'].compareTo(a['fastTimeStamp']));

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

        QuerySnapshot querySnapFire = await _firestore.collection('wildfire')
            .get();
        querySnapFire.docs.forEach((doc) {
          wildItems.add({
            'FRFR_FRNG_DTM': doc['FRFR_FRNG_DTM'],
            'FRFR_INFO_ID': doc['FRFR_INFO_ID'],
            'FRFR_LCTN_XCRD': doc['FRFR_LCTN_XCRD'],
            'FRFR_LCTN_YCRD': doc['FRFR_LCTN_YCRD'],
            'FRFR_OCCRR_ADDR': doc['FRFR_OCCRR_ADDR'],
            'FRFR_OCCRR_TPCD': doc['FRFR_OCCRR_TPCD'],
            'FRFR_PRGRS_STCD': doc['FRFR_PRGRS_STCD'],
            'FRFR_STTMN_ADDR': doc['FRFR_STTMN_ADDR'],
            'FRFR_STTMN_DT': doc['FRFR_STTMN_DT'],
            'FRFR_STTMN_HMS': doc['FRFR_STTMN_HMS'],
            'FRST_RGSTN_DTM': doc['FRST_RGSTN_DTM'],
            'LAST_UPDT_DTM': doc['LAST_UPDT_DTM'],
            'RNO': doc['RNO'],
          });
        });

        QuerySnapshot querySnapEQ = await _firestore.collection('earthquake')
            .get();
        querySnapEQ.docs.forEach((doc) {
          eqItems.add({
            'CD_STN': doc['CD_STN'],
            'CORD_LAT': doc['CORD_LAT'],
            'CORD_LON': doc['CORD_LON'],
            'DT_REGT': doc['DT_REGT'],
            'DT_STFC': doc['DT_STFC'],
            'DT_TM_FC': doc['DT_TM_FC'],
            'LOC_LOC': doc['LOC_LOC'],
            'NO_ORD': doc['NO_ORD'],
            'NO_REF': doc['NO_REF'],
            'SECT_SCLE': doc['SECT_SCLE'],
            'STAT_OTHER': doc['STAT_OTHER'],
          });
        });

        QuerySnapshot querySnapEP = await _firestore.collection('shelter')
            .get();
        querySnapEP.docs.forEach((doc) {
          shelterItem.add({
            'longitudeDegree': doc['FACIL_LODE'],
            'longitudeMinute': doc['FACIL_LOMI'],
            'longitudeSecond': doc['FACIL_LOSE'],
            'latitudeDegree': doc['FACIL_LADE'],
            'latitudeMinute': doc['FACIL_LAMI'],
            'latitudeSecond': doc['FACIL_LASE'],
            'FacilityName': doc['FACIL_NM'],
            'FacilityAddress': doc['FACIL_RD_ADDR'],
            'FacilityPN': doc['MGT_ORG_TEL_NO'],
            'FacilityCapacity': doc['USE_CAN_STF_CNT'],
            'FacilityArea': doc['FACIL_POW'],
            'FacilityAreaUnit': doc['FACIL_UNIT'],
          });
        });

        setState(() {
          post_items = postItems;
          items = opendatasItems;
          wildfire_items = wildItems;
          earthquake_items = eqItems;
          shelter_items = shelterItem;
        });
      }
    } else {
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
            .where('incidenteTypeCd', isEqualTo: context
            .read<Store>()
            .selectedPostType
            .toString()).get();


        querySnapshotPost.docs.forEach((doc) {
          postItems.add({
            'address_name': doc['address_name'],
            'images': doc['images'],
            'is_visible': doc['is_visible'].toString(),
            'post_content': doc['post_content'],
            'post_id': doc['post_id'],
            'post_type': doc['post_type'].toString(),
            'timestamp': doc['timestamp'],
            'title': doc['title'],
            'user_id': doc['user_id'],
            'latitude': doc['latitude'].toString(),
            'longitude': doc['longitude'].toString(),
            'like': doc['like'].toString(),
            'fastTimeStamp': doc['timestamp'].toDate()
          });
        });

        postItems.sort((a, b) =>
            b['fastTimeStamp'].compareTo(a['fastTimeStamp']));

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

        QuerySnapshot querySnapEP = await _firestore.collection('shelter')
            .get();
        querySnapEP.docs.forEach((doc) {
          shelterItem.add({
            'longitudeDegree': doc['FACIL_LODE'],
            'longitudeMinute': doc['FACIL_LOMI'],
            'longitudeSecond': doc['FACIL_LOSE'],
            'latitudeDegree': doc['FACIL_LADE'],
            'latitudeMinute': doc['FACIL_LAMI'],
            'latitudeSecond': doc['FACIL_LASE'],
            'FacilityName': doc['FACIL_NM'],
            'FacilityAddress': doc['FACIL_RD_ADDR'],
            'FacilityPN': doc['MGT_ORG_TEL_NO'],
            'FacilityCapacity': doc['USE_CAN_STF_CNT'],
            'FacilityArea': doc['FACIL_POW'],
            'FacilityAreaUnit': doc['FACIL_UNIT'],
          });
        });

        setState(() {
          post_items = postItems;
          items = opendatasItems;
          shelter_items = shelterItem;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
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
                        '로딩중',
                        style: TextStyle(fontSize: 15),
                      )),
                ],
              )
          )
      );
    }
    else {
      _createPostMarkers(); // 제보글데이터
      _createOpendatasMarkers(); //공공데이터
      _createEarthQuackWMarkers();
      _createWildFireMarkers();
      _createShelterMarker();
      print("데이터 정보 : ${post_items.length}");

      print("로딩 완료"
          "...");
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'LIVE',
                  style: TextStyle(
                    color: Colors.red, // "Live" 텍스트를 빨간색으로 설정
                    fontSize: 24, // 글자 크기를 24로 설정
                    fontWeight: FontWeight.bold, // 굵게 설정
                  ),
                ),
                TextSpan(
                  text: ' 돌발사고',
                  style: TextStyle(
                    color: Colors.black, // "돌발사고" 텍스트를 검정색으로 설정
                    fontSize: 23, // 글자 크기를 16으로 설정
                    fontWeight: FontWeight.normal, // 폰트 굵기를 일반으로 설정
                  ),
                ),
              ],
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.account_circle, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        profile.ProfileScreen(UserImfomation.uid),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            tag.Tags(),
            Row(
              children: [
                Expanded(
                    child: TextFormField(
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
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: Colors.red,
          onPressed: _goToShelter,
          label: const Text('내 주변 대피소'),
          icon: const Icon(Icons.home_filled,color: Colors.white),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      );
    }
  }

  Future<void> _goToPlace(Map<String, dynamic> place) async {
    final double lat = place['geometry']['location']['lat'];
    final double lng = place['geometry']['location']['lng'];

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng),
            zoom: 14)
    ));
  }


  Future<void> _fetchAllData() async {
    List<Map<String, String>> opendatasItems = [];
    List<Map<String, dynamic>> postItems = [];
    List<Map<String, String>> wildItems = [];
    List<Map<String, String>> eqItems = [];
    List<Map<String, dynamic>> shelterItem = [];

    QuerySnapshot querySnapOD = await _firestore.collection('opendatas')
        .get();
    querySnapOD.docs.forEach((doc) {
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

    QuerySnapshot querySnapPost = await _firestore.collection('posts').where(
        'is_visible', isEqualTo: true).get();

    querySnapPost.docs.forEach((doc) {
      postItems.add({
        'address_name': doc['address_name'],
        'images': doc['images'],
        'is_visible': doc['is_visible'].toString(),
        'post_content': doc['post_content'],
        'post_id': doc['post_id'],
        'post_type': doc['post_type'].toString(),
        'timestamp': doc['timestamp'],
        'title': doc['title'],
        'user_id': doc['user_id'],
        'latitude': doc['latitude'].toString(),
        'longitude': doc['longitude'].toString(),
        'like': doc['like'].toString(),
        'fastTimeStamp': doc['timestamp'].toDate()
      });
    });

    postItems.sort((a, b) => b['fastTimeStamp'].compareTo(a['fastTimeStamp']));

    QuerySnapshot querySnapFire = await _firestore.collection('wildfire').get();
    querySnapFire.docs.forEach((doc) {
      wildItems.add({
        'FRFR_FRNG_DTM': doc['FRFR_FRNG_DTM'],
        'FRFR_INFO_ID': doc['FRFR_INFO_ID'],
        'FRFR_LCTN_XCRD': doc['FRFR_LCTN_XCRD'],
        'FRFR_LCTN_YCRD': doc['FRFR_LCTN_YCRD'],
        'FRFR_OCCRR_ADDR': doc['FRFR_OCCRR_ADDR'],
        'FRFR_OCCRR_TPCD': doc['FRFR_OCCRR_TPCD'],
        'FRFR_PRGRS_STCD': doc['FRFR_PRGRS_STCD'],
        'FRFR_STTMN_ADDR': doc['FRFR_STTMN_ADDR'],
        'FRFR_STTMN_DT': doc['FRFR_STTMN_DT'],
        'FRFR_STTMN_HMS': doc['FRFR_STTMN_HMS'],
        'FRST_RGSTN_DTM': doc['FRST_RGSTN_DTM'],
        'LAST_UPDT_DTM': doc['LAST_UPDT_DTM'],
        'RNO': doc['RNO'],
      });
    });

    QuerySnapshot querySnapEQ = await _firestore.collection('earthquake').get();
    querySnapEQ.docs.forEach((doc) {
      eqItems.add({
        'CD_STN': doc['CD_STN'],
        'CORD_LAT': doc['CORD_LAT'],
        'CORD_LON': doc['CORD_LON'],
        'DT_REGT': doc['DT_REGT'],
        'DT_STFC': doc['DT_STFC'],
        'DT_TM_FC': doc['DT_TM_FC'],
        'LOC_LOC': doc['LOC_LOC'],
        'NO_ORD': doc['NO_ORD'],
        'NO_REF': doc['NO_REF'],
        'SECT_SCLE': doc['SECT_SCLE'],
        'STAT_OTHER': doc['STAT_OTHER'],
      });
    });

    QuerySnapshot querySnapEP = await _firestore.collection('shelter').get();
    querySnapEP.docs.forEach((doc) {
      shelterItem.add({
        'longitudeDegree': doc['FACIL_LODE'],
        'longitudeMinute': doc['FACIL_LOMI'],
        'longitudeSecond': doc['FACIL_LOSE'],
        'latitudeDegree': doc['FACIL_LADE'],
        'latitudeMinute': doc['FACIL_LAMI'],
        'latitudeSecond': doc['FACIL_LASE'],
        'FacilityName': doc['FACIL_NM'],
        'FacilityAddress': doc['FACIL_RD_ADDR'],
        'FacilityPN': doc['MGT_ORG_TEL_NO'],
        'FacilityCapacity': doc['USE_CAN_STF_CNT'],
        'FacilityArea': doc['FACIL_POW'],
        'FacilityAreaUnit': doc['FACIL_UNIT'],
      });
    });


    setState(() {
      items = opendatasItems;
      post_items = postItems;
      wildfire_items = wildItems;
      earthquake_items = eqItems;
      shelter_items = shelterItem;
    });
  }

  Future<String> getNickname(String user_id) async {
    QuerySnapshot userquery = await _firestore
        .collection('user')
        .where('uid', isEqualTo: user_id)
        .get();
    final userNickname = userquery.docs.first.get('name').toString();
    return userNickname;
  }


  Future<void> getCurrentLocation() async {
    bool hasPermission = await requestLocationPermission();
    if (!hasPermission) {
      // 권한이 없는 경우 처리할 내용
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );

    setState(() {
      currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 권한 거부됨
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // 사용자가 영원히 권한을 거부함
      return false;
    }
    return true;
  }

  void _createPostMarkers() {
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
        MarkerData markerData = MarkerData(
            position: position, dataList: [item]);
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
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
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
      String startDate = data['startDate']!;
      String endDate = data['endDate']!;
      int i = markers.length + 1;

      Marker marker = Marker(
        markerId: MarkerId(i.toString()),
        position: LatLng(double.parse(longitude), double.parse(latitude)),
        infoWindow: InfoWindow(title: '', snippet: ''),
        // 비어있는 InfoWindow
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                child: Container(
                  width: 500, // 원하는 너비로 조정
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("[경찰청_교통돌발정보]",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 15, // 원하는 폰트 크기로 조정
                            )),
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("주소 : " + title,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 15, // 원하는 폰트 크기로 조정
                            )),
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(description, style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16, // 원하는 폰트 크기로 조정
                        )),
                      ),
                      SizedBox(height: 10),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("시작일: $startDate", style: TextStyle(
                            fontSize: 13)),
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("종료일: $endDate", style: TextStyle(
                            fontSize: 13)),
                      ),
                      SizedBox(height: 10),

                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          child: Text("닫기"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );

      markers.add(marker);
    }
  }


  void _createWildFireMarkers() {
    DateTime now = DateTime.now();
    for (var data in wildfire_items) {
      String latitude = data['FRFR_LCTN_XCRD']!;
      String longitude = data['FRFR_LCTN_YCRD']!;
      String address = data['FRFR_STTMN_ADDR']!;
      String startDate = data['FRFR_STTMN_DT']!;
      String startHMS = data['FRFR_STTMN_HMS']!;
      int i = markers.length + 1;

      String formattedStartDate = '${startDate.substring(0, 4)}년 ${startDate
          .substring(4, 6)}월 ${startDate.substring(6, 8)}일 ';
      String formattedStartHMS = '${startHMS.substring(0, 2)}시 ${startHMS
          .substring(2, 4)}분';


      String formattedDateTime = '$formattedStartDate $formattedStartHMS';

      DateTime markerStartDate = DateTime(int.parse(startDate.substring(0, 4)),
          int.parse(startDate.substring(4, 6)),
          int.parse(startDate.substring(6, 8)));


      if (markerStartDate
          .difference(now)
          .inDays >= -7) {
        Marker marker = Marker(
          markerId: MarkerId(i.toString()),
          position: LatLng(double.parse(longitude), double.parse(latitude)),
          infoWindow: InfoWindow(title: '', snippet: ''),
          // 비어있는 InfoWindow
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  child: Container(
                    width: 300, // 원하는 너비로 조정
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "[산림청_금일산불발생현황]",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15, // 원하는 폰트 크기로 조정
                            ),
                          ),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "주소 : " + address,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 15, // 원하는 폰트 크기로 조정
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("시작일: $formattedDateTime",
                              style: TextStyle(fontSize: 13)),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            child: Text("닫기"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen),
        );

        markers.add(marker);
      }
    }
  }


  void _createEarthQuackWMarkers() {
    DateTime now = DateTime.now();
    for (var data in earthquake_items) {
      String latitude = data['CORD_LON']!;
      String longitude = data['CORD_LAT']!;
      String address = data['LOC_LOC']!;
      String scale = data['SECT_SCLE']!;
      String startDate = data['DT_STFC']!;
      String description = data['STAT_OTHER']!;


      int i = markers.length + 1;

      String year = startDate.substring(0, 4);
      String month = startDate.substring(4, 6);
      String day = startDate.substring(6, 8);
      String hour = startDate.substring(8, 10);
      String minute = startDate.substring(10, 12);

      String ymd = startDate.substring(0, 8);


      String formattedDate = '$year년 $month월 $day일 $hour시 $minute분';

      DateTime markerStartDate = DateTime(
          int.parse(ymd.substring(0, 4)), int.parse(ymd.substring(4, 6)),
          int.parse(ymd.substring(6, 8)));


      if (markerStartDate
          .difference(now)
          .inDays >= -30) {
        Marker marker = Marker(
          markerId: MarkerId(i.toString()),
          position: LatLng(double.parse(longitude), double.parse(latitude)),
          infoWindow: InfoWindow(title: '', snippet: ''),
          // 비어있는 InfoWiddow
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  child: Container(
                    width: 500, // 원하는 너비로 조정
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("[기상청_지진통보]",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15, // 원하는 폰트 크기로 조정
                              )),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("주소 : " + address,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 15, // 원하는 폰트 크기로 조정
                              )),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("규모 : " + scale, style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16, // 원하는 폰트 크기로 조정
                          )),
                        ),
                        SizedBox(height: 10),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("발표시각: $formattedDate",
                              style: TextStyle(fontSize: 13)),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("참고사항: $description",
                              style: TextStyle(fontSize: 13)),
                        ),
                        SizedBox(height: 10),

                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            child: Text("닫기"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueYellow),
        );

        markers.add(marker);
      }
    }
  }


  void _showListDialog(List<Map<String, dynamic>> dataList) {
    final dialogHeight = MediaQuery
        .of(context)
        .size
        .height * 0.95;

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
                    SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(
                                Icons.expand_circle_down_rounded,
                                size: 40
                            ),
                            onPressed: () {
                              Navigator.pop(buildContext);
                            },
                          ),
                          Text('제보현황', style: TextStyle(fontSize: 20,
                              color: Colors.red,
                              fontWeight: FontWeight.bold)),
                          // This is the new line for your text
                          SizedBox(width: 40),
                          // This is just a placeholder to keep the balance
                        ],
                      ),
                    ),
                    Container(
                      height: dialogHeight - 100,
                      // Subtract the height occupied by the title and the button
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
                                title: Text("  " + dataList[index]['title'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                onTap: () async {
                                  final String nickname = await getNickname(
                                      dataList[index]['user_id']);
                                  if (!mounted) return;
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (c, a1, a2) =>
                                          PostDocument(
                                              postId: dataList[index]['post_id'],
                                              imageUrl: dataList[index]['images'],
                                              postMain: dataList[index]['post_content'],
                                              userNickname: nickname,
                                              postName: dataList[index]['title'],
                                              userId: dataList[index]['user_id'],
                                              timestamp: dataList[index]['timestamp'],
                                              like: dataList[index]['like'],
                                              address: dataList[index]['address_name'],
                                              profile: ""
                                          ),
                                      transitionsBuilder: (c, a1, a2, child) =>
                                          FadeTransition(
                                              opacity: a1, child: child),
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
                    // SizedBox(height: 50, child: Center(
                    //   child: TextButton(
                    //     child: Text('닫기'),
                    //     onPressed: () {
                    //       Navigator.pop(buildContext);
                    //     },
                    //   ),
                    // )),

                  ],
                ),
              ),
            ),
          ),
        );
      },
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations
          .of(context)
          .modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        final begin = Offset(0.0, 1.0);
        final end = Offset.zero;
        final curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }


Future<void> _goToShelter() async {
    final GoogleMapController controller = await _controller.future;
    var mygeohash = GeoHash(geoHasher.encode(currentPosition!.longitude, currentPosition!.latitude, precision: 4));

    // 원하는 위치 좌표

    // 지도 이동 애니메이션

    // 마커 생성
    for(int i = 0; i < shelter_items.length; i++) {
      double latitude = convertToCoordinatesFromString(
          shelter_items[i]['latitudeDegree'] as String,
          shelter_items[i]['latitudeMinute'] as String,
          shelter_items[i]['latitudeSecond'] as String);
      double longitude = convertToCoordinatesFromString(
          shelter_items[i]['longitudeDegree'] as String,
          shelter_items[i]['longitudeMinute'] as String,
          shelter_items[i]['longitudeSecond'] as String);

      var shelterGeohash = GeoHash(
          geoHasher.encode(longitude, latitude, precision: 4));


      print(longitude);
      print(latitude);





      if (mygeohash.geohash == shelterGeohash.geohash) {

        await controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: LatLng(latitude, longitude), zoom: 13),
            ),
        );

        return;
      }
    }


    }


  void _createShelterMarker() {
    var mygeohash = GeoHash(geoHasher.encode(currentPosition!.longitude, currentPosition!.latitude, precision: 4));

    // 원하는 위치 좌표

    // 지도 이동 애니메이션

    // 마커 생성
    for(int i = 0; i < shelter_items.length; i++) {

      String name = shelter_items[i]['FacilityName'] as String;
      String address = shelter_items[i]['FacilityAddress'] as String;
      String pn = shelter_items[i]['FacilityPN'] as String;
      String capacity = shelter_items[i]['FacilityCapacity'] as String;
      String area = shelter_items[i]['FacilityArea'] as String;
      String areaUnit = shelter_items[i]['FacilityAreaUnit'] as String;


      double latitude = convertToCoordinatesFromString(
          shelter_items[i]['latitudeDegree'] as String,
          shelter_items[i]['latitudeMinute'] as String,
          shelter_items[i]['latitudeSecond'] as String);
      double longitude = convertToCoordinatesFromString(
          shelter_items[i]['longitudeDegree'] as String,
          shelter_items[i]['longitudeMinute'] as String,
          shelter_items[i]['longitudeSecond'] as String);

      var shelterGeohash = GeoHash(
          geoHasher.encode(longitude, latitude, precision: 4));


      print(longitude);
      print(latitude);




      if (mygeohash.geohash == shelterGeohash.geohash) {
        Marker marker = Marker(
          markerId: MarkerId(i.toString()),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(title: '', snippet: ''),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  child: Container(
                    width: 500, // 원하는 너비로 조정
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("[대피소 정보]",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15, // 원하는 폰트 크기로 조정
                              )),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("주소 : " + address,
                              style: TextStyle(
                                fontSize: 15, // 원하는 폰트 크기로 조정
                              )),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("시설명 : ${name}", style: TextStyle(
                            fontSize: 16, // 원하는 폰트 크기로 조정
                          )),
                        ),
                        SizedBox(height: 10),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RichText(
                            text: TextSpan(
                              text: '전화번호 : ',
                              style: TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                  text: '${pn}',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      launch('tel:${pn}');
                                    },
                                ),
                              ],
                            ),
                          ),

                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("수용인원 : ${capacity}명",
                              style: TextStyle(fontSize: 13)),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("면적 : ${area}${areaUnit}",
                              style: TextStyle(fontSize: 13)),
                        ),
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            child: Text("닫기"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        );

        markers.add(marker);
      }
    }
  }

  double convertToCoordinatesFromString(String degree, String minute,
      String second) {
    double coordinate = double.parse(degree) + (double.parse(minute) / 60) +
        (double.parse(second) / 3600);
    return double.parse(coordinate.toStringAsFixed(7));
  }

}
