import 'package:http/http.dart' as http;
import 'dart:convert' as convert; //Json String -> Json Object
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class World {
  /** This class handles fetching time,temperature and worldcup info of countries **/

  //Map<String,List<String>>? countryToCapitalAndContinent;
  late String time, tempCIconLink, awayTeam;

  String currentDate = intl.DateFormat('yyyy-MM-dd').format(DateTime.now());

  List<String> homeTeams = [], awayTeams = [], groups = [], matchTimes = [];
  Map<String,String> homeTeamToWinner = {}, homeToScore = {}, awayToScore = {};
  late int tempC; //current temperature in Celsius
  late bool isDaytime;

  Future<Map<String, List<String>>> getCountriesData() async {
    /**This method gets the country names with there capitals and continents 
    * as a Map of String to a list of string**/

    try {
      var countryAndCapitalURL = Uri.parse(
          'https://restcountries.com/v2/all?fields=name,capital,region');
      //make the request
      http.Response response = await http.get(countryAndCapitalURL);

      var jsonResponse = convert.jsonDecode(response.body);

      Map<String, List<String>> countryToCapitalAndContinent = {};
      for (var ele in jsonResponse) {
        // print(ele);
        if (ele['capital'] != null)
          countryToCapitalAndContinent.addAll({
            ele['name']: [ele['capital'], ele['region']]
          });
      }
      //print(countryToCapitalAndContinent['Egypt']);
      //this.countryToCapitalAndContinent = countryToCapitalAndContinent;
      return countryToCapitalAndContinent;
    } catch (e) {
      print('getCountriesData() failed\n$e');
      return {};
    }
  }

  List<String> getCountryNames({required Map<String, List<String>> cToCC}) =>
      cToCC.keys.toList();

  Future<void> getTime(
      {required String continent, required String location}) async {
    /**Get the current time based on a location **/

    try {
      var timeURL = Uri.parse(
          "https://worldtimeapi.org/api/timezone/$continent/$location");
      http.Response response = await http.get(timeURL);
      var jsonResponse = convert.jsonDecode(response.body);
      String datatime = jsonResponse["utc_datetime"];
      String offset = jsonResponse['utc_offset'];
      offset = offset.substring(1, 3);

      //create a DateTime object
      DateTime now = DateTime.parse(datatime);
      //add offset to 'now' to get the current time
      now = now.add(Duration(hours: int.parse(offset)));
      // print(now.toString().substring(0,10));

      //Between 6AM and 6PM is considered daytime
      this.isDaytime = (now.hour >= 6 && now.hour <= 18);
      // this.time = intl.DateFormat.yMEd().add_jms().format(now);
      this.time = intl.DateFormat.jm().format(now);
      print('time: $time');
      // this.currentDate = time.substring(0,10);

    } catch (e) {
      print('getTime() failed\n$e');
      this.time = "failed to fetch the current time";
      this.isDaytime = false; //night time
      // this.currentDate = "failed to fetch the current date";
    }
  }

  Future<void> getWorldCupInfo({required String date}) async {
    //Returns Home Team vs Away Team, Winner and Scores of the given date
    //date format YYYY-MM-DD

    try {
      var worldURL = Uri.parse(
          'https://fifa-2022-schedule-and-stats.p.rapidapi.com/schedule?date=$date');
      http.Response response = await http.get(worldURL, headers: {
        'X-RapidAPI-Key': 'ecb5e9ece5msh1be3f522b55ca39p1718ccjsn46a9c14e86da',
        'X-RapidAPI-Host': 'fifa-2022-schedule-and-stats.p.rapidapi.com'
      });

      var json = convert.jsonDecode(response.body);
      //Home Team vs Away Team in Group X
      var matches = json['matches'];
      if (matches == null) return;
      for (var match in matches) {
        var groupName = match['GroupName'][0]['Description'];
        groups.add(groupName);

        var matchTime = match['LocalDate'].toString().substring(11, 16);
        this.matchTimes.add(matchTime);

        var home = match['Home'];
        var homeTeam = home['ShortClubName'];
        homeTeams.add(homeTeam);

        var homeScore = match['HomeTeamScore'].toString();
        this.homeToScore.addAll({homeTeam: homeScore});

        var away = match['Away'];
        var awayTeam = away['ShortClubName'];
        awayTeams.add(awayTeam);

        var awayScore = match['AwayTeamScore'].toString();
        this.awayToScore.addAll({awayTeam:awayScore});


        var winner = int.parse(homeScore) > int.parse(awayScore) ? homeTeam : awayTeam;
        if(int.parse(homeScore) == int.parse(awayScore))
          winner = 'Tie';


        this.homeTeamToWinner.addAll({homeTeam:winner});

        // print(
        //   'Home Team: $homeTeam \n'+
        //   'Away Team: $awayTeam \n'+
        //   'Group Stage: $groupName'
        // );
      }
    } catch (e) {
      print('getWorldCupInfo() failed\n$e');
      this.matchTimes = [];
    }
  }

//return an Image with of the country flag (slower version)
  Future<Image> getFlag({required String country}) async {
    if (country.isNotEmpty) {
      try {
        var url = Uri.parse(
            'https://restcountries.com/v3.1/name/$country?fields=flags');
        http.Response res = await http.get(url);
        var json = convert.jsonDecode(res.body);
        json = json[0];
        var flagLink = json['flags']['png'];
        return await Image.network(flagLink);
      } catch (e) {
        print('getFlag() failed\n$e');
        print('Failed on Flag: $country');
        return await Image.network(
            'https://kubalubra.is/wp-content/uploads/2017/11/default-thumbnail.jpg');
      }
    } else
      return await Image.network(
          'https://kubalubra.is/wp-content/uploads/2017/11/default-thumbnail.jpg');
  }

  //faster version
  ClipOval getFlag2({required String country}) {
    if(country.isNotEmpty){
      try {
//Image.network('https://countryflagsapi.com/png/$country')
        return ClipOval(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(
              'https://countryflagsapi.com/png/$country',
              fit: BoxFit.fill,
              width: 60,
              height: 60,
            ),
          ),
        );
      } catch (e) {
        print('getFlag2 Failed\n$e');
        print('Failed on Flag $country');
        //Image.network('https://kubalubra.is/wp-content/uploads/2017/11/default-thumbnail.jpg');
        return ClipOval(
          child: Image.network(
            'https://kubalubra.is/wp-content/uploads/2017/11/default-thumbnail.jpg',
            fit: BoxFit.fill,
            width: 50,
            height: 50,
          ),
        );
      }
    }else{
      return ClipOval(
        child: Image.network(
          'https://kubalubra.is/wp-content/uploads/2017/11/default-thumbnail.jpg',
          fit: BoxFit.fill,
          width: 50,
          height: 50,
        ),
      );
    }
  }

  Future<void> getTempC({required String country}) async {
    try {
      var tempURL = Uri.parse(
          'https://weatherapi-com.p.rapidapi.com/forecast.json?q=$country');

      http.Response response = await http.get(
        tempURL,
        headers: {
          'X-RapidAPI-Key':
              '9b1972294fmsh96e68b67561daecp1cfc77jsn1303a186425b',
          'X-RapidAPI-Host': 'weatherapi-com.p.rapidapi.com',
        },
      );

      var json = convert.jsonDecode(response.body);
      var current = json['current'];
      String tempCD = current['temp_c'].toString() + ".0";
      print('tempCD: ${tempCD}');

      String tempCS = tempCD.substring(0, tempCD.indexOf('.'));
      int tempC = int.parse(tempCS);
      this.tempC = tempC;

      var condition = current['condition'];
      var weatherDesc = condition['text'];
      var currentWeatherIconLink = condition['icon'];
      this.tempCIconLink = 'https:' + currentWeatherIconLink;
      // print('Current temperature is about ${tempC}C in $country');
    } catch (e) {
      print('getTempC() failed\n$e');
      this.tempC = -100; //failed to set the temperature
      this.tempCIconLink =
          "https://kubalubra.is/wp-content/uploads/2017/11/default-thumbnail.jpg";
    }
  }

  Future<void> getAwayTeam(
      {required String homeTeam, required String date}) async {
    await getWorldCupInfo(date: date); //save fifa api consumption
    int homeTeamIndex = homeTeams.indexOf(homeTeam) == -1
        ? awayTeams.indexOf(homeTeam)
        : homeTeams.indexOf(homeTeam);

    //team not found in home teams nor away teams
    if (homeTeamIndex == -1) {
      print('No matches for $homeTeam on $date');
      this.awayTeam = "";
      return;
    }

    //homeTeams[homeTeamIndex] or awayTeams[homeTeamIndex]
    String awayTeam = "";
    if (homeTeams.contains(homeTeam))
      awayTeam = awayTeams[homeTeamIndex];
    else if (awayTeams.contains(homeTeam)) awayTeam = homeTeams[homeTeamIndex];

    this.awayTeam = awayTeam;
  }
}
