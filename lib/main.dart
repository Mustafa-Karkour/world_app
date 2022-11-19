import 'package:flutter/material.dart'; //import material design widgets
import 'package:world_app/pages/loading.dart';
import 'package:world_app/pages/home.dart';
import 'package:world_app/pages/choose_location.dart';


//entry point (first method to get called)
void main() => runApp(MaterialApp(
    //first 'home' screen
    //home: Home(),
    // initialRoute: '/home',
    routes: {
     '/': (context) => Loading(), 
     '/home' : (context) => Home(),
     '/location' : (context) => ChooseLocation(),
    },
  ));

