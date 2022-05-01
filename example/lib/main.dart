import 'package:flutter/material.dart';
import 'package:whatsappsticker_api_example/ui/StartPage.dart';
import 'ui/HomePage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Sticker Internet",
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: StartPage(),
    );
  }
}
