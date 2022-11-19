import 'package:flutter/material.dart'; //import material design widgets
import 'package:world_app/services/world.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
/**Loading Screen for fetching location/country information**/

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  Set<String> preprocessCountries({required List<String> countries}) {

    List<String> cs = countries;

    cs.remove('CuraÃ§ao');
    cs.remove('RÃ©union');
    cs.remove('Bahamas');
    cs.remove('Israel');
    cs.remove('Comoros');

    cs.remove('Virgin Islands (U.S.)');
    cs.remove('Virgin Islands (British)');
    cs.remove('Central African Republic');
    cs.remove('Saint Vincent and the Grenadines');
    cs.remove('Czech Republic');
    cs.remove('Faroe Islands');
    cs.remove('Cocos (Keeling) Islands');
    

    cs.remove('Swaziland');
    cs.remove('United Kingdom of Great Britain and Northern Ireland');



    for (int i = 0; i < cs.length; i++) {
        cs[i] = cs[i].trim();

      if (cs[i].contains('Island') ||
          cs[i].contains('Islands') ||
          cs[i].contains('Territory') ||
          cs[i].contains('Territories') ||
          cs[i].startsWith('Cocos') ||
          cs[i].contains('City') ||
          cs[i].contains('Coast') ||
          cs[i].startsWith('Lao') ||
          cs[i].startsWith('North') ||
          cs[i].contains('Kosovo') ||
          cs[i].contains('BarthÃ©lemy') ||
          cs[i].startsWith('Central')) {
        cs.remove(cs[i]);
      }
       if (cs[i].contains('(')) {
        int indexOfLeftBracket = cs[i].indexOf('(');
        cs[i] = cs[i].substring(0, indexOfLeftBracket);
        cs[i] = cs[i].trim();
      }
       if (cs[i].contains(',')) {
        int indexOfComma = cs[i].indexOf(',');
        cs[i] = cs[i].substring(0, indexOfComma);
        cs[i] = cs[i].trim();
      }
    }
    cs[cs.indexOf('Korea')] = 'North Korea';
    cs.remove('Korea');

    return cs.toSet();
  }

  void setupWorldInfo() async {
    World world = World();
    Map<String, List<String>> cToCC = await world.getCountriesData();
    
    String homeCountry = 'Qatar';
    await world.getTime(
        continent: cToCC[homeCountry]![1], location: cToCC[homeCountry]![0]);
    await world.getTempC(country: homeCountry);
    //date should be placed with the 'currentDate'
    await world.getAwayTeam(homeTeam: homeCountry, date: world.currentDate);

    // print(cToCC.keys.toList());
    Set<String> countries = preprocessCountries(countries: cToCC.keys.toList());
    // for (String c in countries) {
    //   // if(c != 'Virgin Islands')
    //   print('Country:\t$c\t${countries.toList().indexOf(c)}');
    // }

    List<ClipOval> flags = [];
    for (String c in countries) {
      // print('Country:\t$c');
      ClipOval f = world.getFlag2(country: c);
      flags.add(f);
    }

    //redirect the user to the home screen
    Navigator.pushReplacementNamed(
      context,
      '/home',
      arguments: {
        'country': homeCountry,
        'city': cToCC[homeCountry]![0],
        'flag': await world.getFlag2(country: homeCountry),
        'time': world.time,
        'matchDate': world.currentDate,
        'isDaytime': world.isDaytime,
        'tempC': world.tempC,
        'tempCIcon': Image.network(world.tempCIconLink),
        'awayTeam': world.awayTeam + "s",
        //'awayFlag':  await world.getFlag(country: world.awayTeam),
        'countries': countries.toList(),
        'flags': flags,
        'cToCC': cToCC,
      },
    ); //needs sometime to build the widget before using it
  }

  @override
  void initState() {
    super.initState(); //call initState from the superclass first
    setupWorldInfo(); //non-blocking
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      body: Center(
        child: SpinKitCubeGrid(
          color: Colors.blue,
          size: 100,
        ),
      ),
    );
  }
}
