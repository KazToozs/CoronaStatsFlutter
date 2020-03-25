import 'dart:async';
import 'dart:convert';

import 'package:corona_app/country_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'country_detail_page.dart';

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

class _MyAppState extends State<MyApp> {
  Future<Countries> futureCountries;
  CountryData selected;
  final duplicateCountries = List<CountryData>();
  var searchItems = List<CountryData>();
  TextEditingController editingController = TextEditingController();
  int totalConfirmed;
  int totalDeaths;
  int totalRecovered;

  @override
  void initState() {
    super.initState();

    totalConfirmed = 0;
    totalDeaths = 0;
    totalRecovered = 0;
    selected =
        new CountryData(country: "WORLDWIDE", dailyData: List<DailyData>());
    selected.dailyData.add(new DailyData(
        date: "N/A",
        confirmed: totalConfirmed,
        deaths: totalDeaths,
        recovered: totalRecovered));
    futureCountries = fetchCountries();
    futureCountries.then((value) {
      setState(() {
        value.countries.forEach((country) {
          duplicateCountries.add(country);
          searchItems.add(country);
        });

        calculateWorldTotal(duplicateCountries);
        selected =
            new CountryData(country: "WORLDWIDE", dailyData: List<DailyData>());
        selected.dailyData.add(new DailyData(
            date: "N/A",
            confirmed: totalConfirmed,
            deaths: totalDeaths,
            recovered: totalRecovered));
      });
      duplicateCountries.insert(0, selected);
      searchItems.insert(0, selected);

    });
  }

  void calculateWorldTotal(List<CountryData> allCountryData) {
    var test = 0;
    for (int i = 0; i < allCountryData.length; i++) {
      totalConfirmed += (allCountryData[i].dailyData.last.confirmed != null)
          ? allCountryData[i].dailyData.last.confirmed
          : 0;
      totalDeaths += (allCountryData[i].dailyData.last.deaths != null)
          ? allCountryData[i].dailyData.last.deaths
          : 0;
      totalRecovered += (allCountryData[i].dailyData.last.recovered != null)
          ? allCountryData[i].dailyData.last.recovered
          : 0;
      test = totalRecovered;
    }
    // allCountryData.forEach((country) {
    //   totalConfirmed += country.dailyData.last.confirmed;
    //   totalDeaths += country.dailyData.last.deaths;
    //   totalRecovered += country.dailyData.last.recovered;
    //   test++;
    // });
    print(test);
  }

  void filterSearchResults(String query) {
    List<CountryData> dummySearchList = List<CountryData>();

    dummySearchList.addAll(duplicateCountries);

    if (query.isNotEmpty) {
      List<CountryData> dummyListData = List<CountryData>();
      dummySearchList.forEach((item) {
        if (item.country.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        searchItems.clear();
        searchItems.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        searchItems.clear();
        searchItems.addAll(dummySearchList);
      });
    }
  }

  String checkData(String string) {
    if (string.compareTo("null") == 0) {
      return ("No data");
    }
    return (string);
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
            title: Text('Select a Country'),
          ),
          body: Container(
            child: Column(
              children: <Widget>[
                // Country details block
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(selected.country)),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("Confirmed Cases: " +
                            checkData(
                                selected.dailyData.last.confirmed.toString())),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("Related Deaths: " +
                            checkData(
                                selected.dailyData.last.deaths.toString())),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("Recovered: " +
                            checkData(
                                selected.dailyData.last.recovered.toString())),
                      ),
                      // Center(
                      //   child: Padding(
                      //     padding: EdgeInsets.all(16.0),
                      //     child: Text("Last updated: " +
                      //         checkData(
                      //             selected.dailyData.last.date.toString())),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (value) {
                      filterSearchResults(value);
                    },
                    controller: editingController,
                    decoration: InputDecoration(
                        labelText: "Search",
                        hintText: "Search",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(25.0)))),
                  ),
                ),
                // List of countries
                Expanded(
                  child: FutureBuilder<Countries>(
                      future: futureCountries,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            snapshot.hasData == false) {
                          //print('project snapshot data is: ${projectSnap.data}');
                          return Center(child: CircularProgressIndicator());
                        }
                        return ListView.separated(
                            separatorBuilder: (context, index) => Divider(
                                  color: Colors.black,
                                ),
                            itemCount: searchItems.length,
                            itemBuilder: (context, index) {
                              if (snapshot.hasData) {
                                return ListTile(
                                  title: Text(searchItems[index].country),
                                  // onTap: () => Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => CountryDetailPage(
                                  //         details: searchItems[index]),
                                  //   ),
                                  // ),
                                  onTap: () => setState(() => selected = searchItems[index])
                                );
                              } else if (snapshot.hasError) {
                                return Text("${snapshot.error}");
                              }
                              // By default, show a loading spinner.
                            });
                      }),
                ),
              ],
            ),
          ),
        ));
  }
}
