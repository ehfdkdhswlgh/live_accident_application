import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerData {
  LatLng position;
  List<Map<String, dynamic>> dataList;

  MarkerData({required this.position, required this.dataList});

}