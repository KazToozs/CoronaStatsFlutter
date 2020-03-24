class Countries {
  List<CountryData> countries;

  Countries({this.countries});
  factory Countries.fromJson(Map<String, dynamic> json) {
    List<CountryData> countryDataList = [];

    json.forEach((index, value) =>
        countryDataList.add(new CountryData.fromJson(index, value)));

    countryDataList.sort((a, b) {
      return a.country.toLowerCase().compareTo(b.country.toLowerCase());
    });
    return Countries(countries: countryDataList);
  }
}

class CountryData {
  final String country;
  final List<DailyData> dailyData;

  CountryData({this.country, this.dailyData});

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

    return CountryData(country: country, dailyData: countryData);
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