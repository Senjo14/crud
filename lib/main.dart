import "package:flutter/material.dart";
import "package:infoemcrud/view/Screen/homepage.dart";

void main(){
  return runApp( const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Homepage(),
    );
  }
}
