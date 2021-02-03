// Created by AMIT JANGID on 03/02/21.

import 'package:flutter/material.dart';
import 'package:jai_kisan/screens/maps_screen.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Location _location = Location();

  @override
  void initState() {
    super.initState();

    // calling request permission method
    _requestPermission();

    // calling navigate to maps screen method
    _navigateToMapsScreen();
  }

  _requestPermission() async {
    // await [Permission.location, Permission.locationWhenInUse].request();

    // calling request permission method
    await _location.requestPermission();
  }

  _navigateToMapsScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => MapsScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Jai Kisan', style: Theme.of(context).textTheme.headline4)));
  }
}
