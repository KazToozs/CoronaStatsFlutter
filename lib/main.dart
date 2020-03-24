import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

Future<Countries> fetchCountries() async {
  final response =
      await http.get('https://pomber.github.io/covid19/timeseries.json');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.

    return Countries.fromJson(json.decode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class Countries {
  List<CountryData> countries;

  Countries({this.countries});
  factory Countries.fromJson(Map<String, dynamic> json) {
    List<CountryData> countryDataList = [];

    json.forEach((index, value) =>
        countryDataList.add(new CountryData.fromJson(index, value)));
    return Countries(countries: countryDataList);
  }
}

class CountryData {
  final String country;
  final List<DailyData> countryData;

  CountryData({this.country, this.countryData});

  factory CountryData.fromJson(String country, List<dynamic> list) {
    List<DailyData> countryData = [];

    list.forEach((value) => countryData.add(new DailyData(
        date: value['date'],
        confirmed: value['confirmed'],
        deaths: value['deaths'],
        recovered: value['recovered'])));
    // for (var i = 0; i < (json.keys.length); i++) {
    //   print(json[json.keys[i]].toString());
    //   // countries.add(new CountryData(json.values[i]));
    // }
    return CountryData(country: country, countryData: countryData);
  }
}

class DailyData {
  final String date;
  final int confirmed;
  final int deaths;
  final int recovered;

  DailyData({this.date, this.confirmed, this.deaths, this.recovered});

  factory DailyData.fromJson(Map<String, dynamic> json) {
    return DailyData(
        date: json['date'],
        confirmed: json['confirmed'],
        deaths: json['deaths'],
        recovered: json['recovered']);
  }
}

class _MyAppState extends State<MyApp> {
  Future<Countries> futureCountries;

  @override
  void initState() {
    super.initState();
    futureCountries = fetchCountries();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text('Test App'),
          ),
          body: FutureBuilder<Countries>(
              future: futureCountries,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.none &&
                    snapshot.hasData == null) {
                  //print('project snapshot data is: ${projectSnap.data}');
                  return CircularProgressIndicator();
                }
                return ListView.builder(
                  itemCount: snapshot.data.countries.length,
                  itemBuilder: (context, index) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data.countries[index].country);
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  // By default, show a loading spinner.
                });
              }),
        ));
  }
}
