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
  final duplicateCountries = List<CountryData>();
  var searchItems = List<CountryData>();
  TextEditingController editingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureCountries = fetchCountries();
    futureCountries.then((value) => value.countries.forEach((country) {
          duplicateCountries.add(country);
          searchItems.addAll(duplicateCountries);
        }));
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
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                              builder: (context) => CountryDetailPage(details: searchItems[index]),
                                            ),
                                      ),
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
