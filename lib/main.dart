import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/home.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dot. News',
      home: Home(),
    );
  }
}

