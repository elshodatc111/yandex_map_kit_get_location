import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int MyCurrentIndex = 0;
  List pages = const [
    
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My widget'),
      ),
      bottomNavigationBar: BottomNavigationBar(items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home),label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.search),label: "Settings"),
        BottomNavigationBarItem(icon: Icon(Icons.heart_broken),label: "Forward"),
        BottomNavigationBarItem(icon: Icon(Icons.person),label: "Profel"),
      ],),
    );;
  }
}

