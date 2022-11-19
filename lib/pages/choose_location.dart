import 'package:flutter/material.dart'; //import material design widgets
import 'package:world_app/services/world.dart';
import 'package:world_app/services/world.dart';
/** Choose Location/Country Screen from a List **/

class ChooseLocation extends StatefulWidget {
  const ChooseLocation({super.key});

  @override
  State<ChooseLocation> createState() => _ChooseLocationState();
}

class _ChooseLocationState extends State<ChooseLocation> {
  List<String> countries = ['x'];
  List<ClipOval> flags = [
    ClipOval(
      child: Image.network(
        'https://kubalubra.is/wp-content/uploads/2017/11/default-thumbnail.jpg',
        fit: BoxFit.fill,
        width: 50,
        height: 50,
      ),
    ),
  ];
  Map<String, List<String>> cToCC = {};
  Map<String, dynamic> dataFromHomeScreen = {};
  String currentDate = "";

  void setupChooseLoction() {
    World w = World();

    //first and last time loading the data
    dataFromHomeScreen =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    List<String> cs = dataFromHomeScreen['countries'];
    List<ClipOval> fs = dataFromHomeScreen['flags'];

    setState(() {
      countries = cs;
      flags = fs;
      currentDate = dataFromHomeScreen['matchDate'];
      cToCC = dataFromHomeScreen['cToCC'];
    });
  }

  @override
  void dispose() {
    super.dispose(); //needed
    print("Dispose got called");
  }

  @override
  Widget build(BuildContext context) {
    print("Build got called");

    setupChooseLoction(); //blocking

    return Scaffold(
      appBar: AppBar(
        title: Text('Choose a Location'),
        centerTitle: true,
        elevation: 0, //remove appbar drop-shadow
        backgroundColor: Colors.indigoAccent,
      ),
      body: ListView.builder(
        itemCount: countries.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 1,
              horizontal: 4,
            ),
            child: Card(
              color: Colors.grey.shade200,
              child: ListTile(
                onTap: () async {
                  //get time,weather,fifa(date) based on the selected country
                  String selectedCountry = countries[index];
                  String matchDate =
                      getMatchDate(selectedCountry: selectedCountry);

                  updateInfo(
                      selectedCountry: selectedCountry, matchDate: matchDate);

                  print(selectedCountry);
                  print(matchDate);
                },
                title: Text(countries[index]),
                leading: flags[index],
              ),
            ),
          );
        },
      ),
    );
  }

  String getMatchDate({required String selectedCountry}) {
    //TODO: get match dates for all countries if available
    switch (selectedCountry) {
      case ('Qatar'):
        return '2022-11-20';
      case ('Germany'):
        return '2022-11-23';
      case ('Japan'):
        return '2022-11-27';
      default: //return the current date 
        return currentDate;
    }
  }

  void updateInfo(
      {required String selectedCountry, required String matchDate}) async {
    World w = World();

    await w.getTime(
        continent: cToCC[selectedCountry]![1],
        location: cToCC[selectedCountry]![0]);
    String updatedTime = w.time;
    bool updatedIsDaytime = w.isDaytime;
    await w.getTempC(country: selectedCountry);

    String captial = cToCC[selectedCountry]![0];

    String updatedTempC = w.tempC.toString();

    await w.getAwayTeam(date: matchDate, homeTeam: selectedCountry);
    String awayTeam = w.awayTeam;

    int homeTeamIndex = countries.indexOf(selectedCountry);
    int awayTeamIndex = countries.indexOf(awayTeam);

    ClipOval homeTeamFlag = flags[homeTeamIndex];
    //ClipOval awayTeamFlag = flags[awayTeamIndex];

    //pop the current screen since the previous one is still available
    Navigator.pop(context, {
      'time': updatedTime,
      'tempC': updatedTempC,
      'matchDate': matchDate,
      'country': selectedCountry,
      'flag': homeTeamFlag,
      'awayTeam': awayTeam + "s",
      //'awayFlag': awayTeamFlag,
      'city': captial,
      'isDaytime': updatedIsDaytime,
      'countries': countries,
      'flags': flags,
    });
  }
}
