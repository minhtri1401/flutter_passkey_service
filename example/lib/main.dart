import 'package:flutter/material.dart';
import 'passkey_example.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Passkey Service Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: PasskeyExample(),
      debugShowCheckedModeBanner: false,
    );
  }
}
