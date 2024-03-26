import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:nonogram/models/puzzle.dart';
import 'package:flutter/foundation.dart';
import 'package:nonogram/pages/puzzle_page.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nonogram'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PuzzlePage()));
                },
                child: const Text('Play'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
                child: const Text('Settings'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/about');
                },
                child: const Text('About'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
