// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:nonogram/level_selection/level_provider.dart';
import 'package:nonogram/level_selection/levels.dart';
import 'package:nonogram/settings/settings.dart';
import 'package:provider/provider.dart';

import '../game_internals/score.dart';
import '../style/my_button.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';

class WinGameScreen extends StatefulWidget {
  final Score score;
  final GameLevel level;

  const WinGameScreen({
    super.key,
    required this.score,
    required this.level,
  });

  @override
  State<WinGameScreen> createState() => _WinGameScreenState();
}

class _WinGameScreenState extends State<WinGameScreen> {
  double difficulty = 1;

  @override
  void initState() {
    super.initState();
  }

  Future<void> saveDifficulty(GameLevel level, double difficulty) async {
    final snapshot = await FirebaseFirestore.instance.collection('levels').doc(level.puzzleName).get();
    final data = snapshot.data();

    final ratings = (data?['ratings'] as List<dynamic>? ?? <dynamic>[]).map((e) => e as double).toList();
    ratings.add(difficulty);

    final avg = ratings.length > 1 ? ratings.reduce((a, b) => a + b) / ratings.length : difficulty;

    FirebaseFirestore.instance.collection('levels').doc(level.puzzleName).update({
      'ratings': ratings,
      'difficulty': avg,
    });
    updateExistingLevel(ratings, avg);
  }

  void updateExistingLevel(List<double> ratings, double avg) {
    Provider.of<LevelProvider>(context, listen: false)
        .levels
        .where((element) => element.puzzleName == widget.level.puzzleName)
        .first
        .difficulty = difficulty;

    Provider.of<LevelProvider>(context, listen: false)
        .levels
        .where((element) => element.puzzleName == widget.level.puzzleName)
        .first
        .ratings = ratings;
  }

  double calculateCellSize(List<List<int>> grid, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxPuzzleWidth = screenWidth - 64;
    final cellSize = maxPuzzleWidth / grid[0].length;

    final screenHeight = MediaQuery.of(context).size.height;
    final maxPuzzleHeight = screenHeight - 400;
    final cellSizeHeight = maxPuzzleHeight / grid.length;

    if (cellSizeHeight < cellSize) {
      return cellSizeHeight;
    }

    return cellSize;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final settings = context.watch<SettingsController>();
    final gap = SizedBox(height: 10);
    final cellSize = calculateCellSize(widget.score.goal, context);

    return Scaffold(
      backgroundColor: palette.backgroundPlaySession,
      body: ResponsiveScreen(
        squarishMainArea: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            gap,
            const Center(
              child: Text(
                'You won!',
                style: TextStyle(fontFamily: 'Permanent Marker', fontSize: 50),
              ),
            ),
            gap,
            Spacer(),
            SizedBox(
              height: cellSize * widget.score.goal.length.toDouble(),
              width: cellSize * widget.score.goal[0].length.toDouble(),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.score.goal[0].length,
                  childAspectRatio: 1,
                ),
                itemCount: widget.score.goal.length * widget.score.goal[0].length,
                itemBuilder: (context, index) {
                  final row = index ~/ widget.score.goal[0].length;
                  final col = index % widget.score.goal[0].length;
                  final cell = widget.score.goal[row][col];
                  return Container(
                    decoration: BoxDecoration(
                      color: cell == 1 ? settings.colorChosen.value : Colors.white,
                    ),
                  );
                },
              ),
            ),
            Spacer(),
            Center(
              child: Text(
                'Completed in ${widget.score.formattedTime}',
                style: const TextStyle(fontFamily: 'Permanent Marker', fontSize: 16),
              ),
            ),
            Spacer(),
            gap,
            Text(
              'Rate the difficulty of this puzzle:',
              style: const TextStyle(fontFamily: 'Permanent Marker', fontSize: 16),
            ),
            gap,
            gap,
            RatingBar.builder(
              initialRating: difficulty,
              itemCount: 5,
              minRating: 1,
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return Icon(
                      Icons.self_improvement_sharp,
                      color: Colors.green,
                    );
                  case 1:
                    return Icon(
                      Icons.sentiment_very_satisfied_rounded,
                      color: Colors.lightGreen,
                    );
                  case 2:
                    return Icon(
                      Icons.sentiment_satisfied,
                      color: Colors.amber,
                    );
                  case 3:
                    return Icon(
                      Icons.smart_toy_outlined,
                      color: Colors.orange,
                    );
                  case 4:
                    return Icon(
                      Icons.local_fire_department_outlined,
                      color: Colors.red,
                    );
                  default:
                    throw ArgumentError('Invalid index: $index');
                }
              },
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              updateOnDrag: true,
              onRatingUpdate: (rating) {
                setState(() {
                  difficulty = rating;
                });
              },
            ),
            gap,
            Text(
              difficulty == 1
                  ? 'Super Easy'
                  : difficulty == 2
                      ? 'Easy'
                      : difficulty == 3
                          ? 'Medium'
                          : difficulty == 4
                              ? 'Hard'
                              : 'Super Hard',
              style: const TextStyle(fontFamily: 'Permanent Marker', fontSize: 20),
            ),
            Spacer(),
          ],
        ),
        rectangularMenuArea: MyButton(
          onPressed: () {
            saveDifficulty(widget.level, difficulty);
            GoRouter.of(context).go('/play');
          },
          child: const Text('Continue'),
        ),
      ),
    );
  }
}
