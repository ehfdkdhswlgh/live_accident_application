import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class News extends StatelessWidget {
  final List<Map<String, String>> items = [
    {
      'title': '【경북 사건사고】 4차선 건너던 80대 여성 차에 치여 숨져...도내 강풍 ... - 안동인터넷뉴스',
      'date': 'Tue, 11 Apr 2023 04:15:36 GMT',
      'link': 'https://news.google.com/rss/articles/CBMiOmh0dHA6Ly93d3cuYWRpbmV3cy5jby5rci9uZXdzL2FydGljbGVWaWV3Lmh0bWw_aWR4bm89NjEzNTPSAQA?oc=5'
    },
    {
      'title': '경찰·국과수, 충주 사고버스 원인 규명 합동 감식 - 충청매일',
      'date': 'Fri, 14 Apr 2023 05:00:03 GMT',
      'link': 'https://news.google.com/rss/articles/CBMiOWh0dHBzOi8vd3d3LmNjZG4uY28ua3IvbmV3cy9hcnRpY2xlVmlldy5odG1sP2lkeG5vPTkwOTU5MNIBPGh0dHBzOi8vd3d3LmNjZG4uY28ua3IvbmV3cy9hcnRpY2xlVmlld0FtcC5odG1sP2lkeG5vPTkwOTU5MA?oc=5'
    },
    {
      'title': '원주서 굴삭기 전도 70대 숨져 < 사건/사고 < 사회 < 기사본문 - 강원도민일보',
      'date': 'Thu, 13 Apr 2023 15:36:07 GMT',
      'link': 'https://news.google.com/rss/articles/CBMiOGh0dHBzOi8vd3d3LmthZG8ubmV0L25ld3MvYXJ0aWNsZVZpZXcuaHRtbD9pZHhubz0xMTc4NDg40gEA?oc=5'
    },
    {
      'title': '【경북 사건사고】 4차선 건너던 80대 여성 차에 치여 숨져...도내 강풍 ... - 안동인터넷뉴스',
      'date': 'Tue, 11 Apr 2023 04:15:36 GMT',
      'link': 'https://news.google.com/rss/articles/CBMiOmh0dHA6Ly93d3cuYWRpbmV3cy5jby5rci9uZXdzL2FydGljbGVWaWV3Lmh0bWw_aWR4bm89NjEzNTPSAQA?oc=5'
    },
    {
      'title': '경찰·국과수, 충주 사고버스 원인 규명 합동 감식 - 충청매일',
      'date': 'Fri, 14 Apr 2023 05:00:03 GMT',
      'link': 'https://news.google.com/rss/articles/CBMiOWh0dHBzOi8vd3d3LmNjZG4uY28ua3IvbmV3cy9hcnRpY2xlVmlldy5odG1sP2lkeG5vPTkwOTU5MNIBPGh0dHBzOi8vd3d3LmNjZG4uY28ua3IvbmV3cy9hcnRpY2xlVmlld0FtcC5odG1sP2lkeG5vPTkwOTU5MA?oc=5'
    },
    {
      'title': '원주서 굴삭기 전도 70대 숨져 < 사건/사고 < 사회 < 기사본문 - 강원도민일보',
      'date': 'Thu, 13 Apr 2023 15:36:07 GMT',
      'link': 'https://news.google.com/rss/articles/CBMiOGh0dHBzOi8vd3d3LmthZG8ubmV0L25ld3MvYXJ0aWNsZVZpZXcuaHRtbD9pZHhubz0xMTc4NDg40gEA?oc=5'
    },
    {
      'title': '【경북 사건사고】 4차선 건너던 80대 여성 차에 치여 숨져...도내 강풍 ... - 안동인터넷뉴스',
      'date': 'Tue, 11 Apr 2023 04:15:36 GMT',
      'link': 'https://news.google.com/rss/articles/CBMiOmh0dHA6Ly93d3cuYWRpbmV3cy5jby5rci9uZXdzL2FydGljbGVWaWV3Lmh0bWw_aWR4bm89NjEzNTPSAQA?oc=5'
    },
    {
      'title': '경찰·국과수, 충주 사고버스 원인 규명 합동 감식 - 충청매일',
      'date': 'Fri, 14 Apr 2023 05:00:03 GMT',
      'link': 'https://news.google.com/rss/articles/CBMiOWh0dHBzOi8vd3d3LmNjZG4uY28ua3IvbmV3cy9hcnRpY2xlVmlldy5odG1sP2lkeG5vPTkwOTU5MNIBPGh0dHBzOi8vd3d3LmNjZG4uY28ua3IvbmV3cy9hcnRpY2xlVmlld0FtcC5odG1sP2lkeG5vPTkwOTU5MA?oc=5'
    },
    {
      'title': '원주서 굴삭기 전도 70대 숨져 < 사건/사고 < 사회 < 기사본문 - 강원도민일보',
      'date': 'Thu, 13 Apr 2023 15:36:07 GMT',
      'link': 'https://news.google.com/rss/articles/CBMiOGh0dHBzOi8vd3d3LmthZG8ubmV0L25ld3MvYXJ0aWNsZVZpZXcuaHRtbD9pZHhubz0xMTc4NDg40gEA?oc=5'
    },
  ];
//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '보도자료 조회',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey,
        ),
        margin: EdgeInsets.all(16.0),
        child: ListView.separated(
          padding: EdgeInsets.all(16.0),
          separatorBuilder: (context, index) => Container(
            height: 1,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(items[index]['title']!),
            subtitle: Text(items[index]['date']!),
            onTap: () async {
              _launchUrl(items[index]['link']);
            },
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(str_url) async {

    var _url = Uri.parse(str_url);

    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }


}