
import 'package:corona_app/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CountryDetailPage extends StatelessWidget {
  CountryData details;

  CountryDetailPage({Key key, @required this.details}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(details.country),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Confirmed Cases: " + details.dailyData.last.confirmed.toString()),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Related Deaths: " + details.dailyData.last.deaths.toString()),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Recovered: " + details.dailyData.last.recovered.toString()),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Last updated: " + details.dailyData.last.date.toString()),
            ),
          ),
        ],
      ),
    );  
    }
}