// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../game_internals/score.dart';
import '../style/my_button.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';

class WinGameScreen extends StatelessWidget {
  final Score score;

  const WinGameScreen({
    super.key,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

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

    const gap = SizedBox(height: 10);
    double cellSize = 0;
    if (score.goal.isNotEmpty) {
      cellSize = calculateCellSize(score.goal, context);
    } else {
      print(score.solution.toString());
    }

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
            Center(
              child: Text(
                'Score: ${score.score}\n'
                'Time: ${score.formattedTime}',
                style: const TextStyle(fontFamily: 'Permanent Marker', fontSize: 20),
              ),
            ),
            gap,
            gap,
            score.goal.isEmpty
                ? Text(score.solution.toString())
                : SizedBox(
                    height: cellSize * score.goal.length.toDouble(),
                    width: cellSize * score.goal[0].length.toDouble(),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: score.goal[0].length,
                        childAspectRatio: 1,
                      ),
                      itemCount: score.goal.length * score.goal[0].length,
                      itemBuilder: (context, index) {
                        final row = index ~/ score.goal[0].length;
                        final col = index % score.goal[0].length;
                        final cell = score.goal[row][col];
                        return Container(
                          decoration: BoxDecoration(
                            color: cell == 1 ? Colors.black : Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
        rectangularMenuArea: MyButton(
          onPressed: () {
            GoRouter.of(context).go('/play');
          },
          child: const Text('Continue'),
        ),
      ),
    );
  }
}
