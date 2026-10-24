import 'package:flutter/material.dart';
import 'screens/map_screen.dart';

void main() {
  runApp(const DalliniApp());
}

class DalliniApp extends StatelessWidget {
  const DalliniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'دليني',
      theme: ThemeData(useMaterial3: true, fontFamily: 'Cairo'),
      home: const MapScreen(),
    );
  }
}
