import 'package:flutter/material.dart'; //import material design widgets

/** Main Screen of the APP **/
//Displaying all country information

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map<String, dynamic> dataFromLoadingSceen = {};

  Row setupFlags({required bool isDaytime, required String matchDate}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: Colors.transparent,
          child: dataFromLoadingSceen['flag'], //home flag
          radius: 40,
        ),
        Text(
          "vs\n\n$matchDate",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDaytime ? Colors.pink.shade400 : Colors.white,
          ),
        ),
        CircleAvatar(
          backgroundColor: Colors.transparent,
          child: dataFromLoadingSceen['awayFlag'],
          radius: 40,
        )
      ],
    );
  }

  Column worldCupBanner({required bool isDaytime}) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(0, 80, 0, 0),
          child: Text(
            'FIFA World Cup Qatar 2022',
            style: TextStyle(
              fontSize: 22,
              color: isDaytime ? Colors.black : Colors.white,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Divider(
            color: isDaytime ? Colors.brown.shade400 : Colors.grey.shade200,
            thickness: 3,
            height: 15,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    //first time loading the data
    //avoid overwritting the data if it already exists
    dataFromLoadingSceen = dataFromLoadingSceen.isEmpty
        ? ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>
        : dataFromLoadingSceen;
    // print(dataFromLoadingSceen);

    bool awayTeamExists =
        dataFromLoadingSceen['awayTeam'].toString().isNotEmpty;

    bool isDaytime = dataFromLoadingSceen['isDaytime'];

    //set Background image
    String backgroundImgPath = isDaytime ? 'imgs/sunny.jpg' : 'imgs/night.jpg';

    //set scaffold color
    var scaffoldBGColor =
        isDaytime ? Colors.blue.shade500 : Colors.indigo.shade900;

    //set font color
    var fontColor = isDaytime ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBGColor,
      body: SafeArea(
        child: Container(
          //draw an image in the background
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(backgroundImgPath),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 80, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    //push to location route
                    dynamic results = await Navigator.pushNamed(
                        context, '/location',
                        arguments: {
                          'countries': dataFromLoadingSceen['countries'],
                          'flags': dataFromLoadingSceen['flags'],
                          'matchDate': dataFromLoadingSceen['matchDate'],
                          'cToCC': dataFromLoadingSceen['cToCC'],
                        }); //previous screen is in the background

                    setState(() {
                      //data from Choose Location Screen
                      dataFromLoadingSceen = {
                        'time': results['time'],
                        'tempC': results['tempC'],
                        'matchDate': results['matchDate'],
                        'country': results['country'],
                        'flag': results['flag'], //home flag
                        //'awayTeam': results['awayTeam'],
                        //'awayFlag': results['awayFlag'],
                        'city': results['city'],
                        'isDaytime': results['isDaytime'],
                        'countries': dataFromLoadingSceen['countries'],
                        'flags': dataFromLoadingSceen['flags'],
                        'cToCC':dataFromLoadingSceen['cToCC'],
                        'tempCIcon': dataFromLoadingSceen['tempCIcon'],
                      };
                    });
                  },
                  label: Text(
                    'Choose Location',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  icon: Icon(Icons.edit_location),
                  style: TextButton.styleFrom(
                    foregroundColor: fontColor,
                    backgroundColor: Colors.transparent,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  //Flag - Country Name
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                      child: dataFromLoadingSceen['flag'],
                    ),
                    Text(
                      dataFromLoadingSceen['country'],
                      style: TextStyle(
                        fontSize: 28,
                        letterSpacing: 2,
                        color: fontColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dataFromLoadingSceen['city'],
                      style: TextStyle(
                        fontSize: 20,
                        letterSpacing: 1.5,
                        color: isDaytime
                            ? Colors.brown.shade800
                            : Colors.grey.shade200,
                      ),
                    ),
                  ],
                ),
                // SizedBox(height: 20),
                Container(
                  child: dataFromLoadingSceen['time'].toString().length < 13
                      ? SizedBox(height: 20)
                      : null,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      dataFromLoadingSceen['time'].toString().length < 13
                          ? dataFromLoadingSceen['time']
                          : "",
                      style: TextStyle(
                        fontSize:
                            dataFromLoadingSceen['time'].toString().length < 13
                                ? 40
                                : 15,
                        color: fontColor,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${dataFromLoadingSceen['tempC']}°C",
                            style: TextStyle(
                              fontSize: 20,
                              color: fontColor,
                            )),
                        CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: dataFromLoadingSceen['tempCIcon'],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        awayTeamExists
                            ? worldCupBanner(isDaytime: isDaytime)
                            : Container(),
                        Container(
                          margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: awayTeamExists
                              ? setupFlags(
                                  isDaytime: isDaytime,
                                  matchDate:
                                      dataFromLoadingSceen['matchDate'])
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
