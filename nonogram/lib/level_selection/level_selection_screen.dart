// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nonogram/game_internals/score.dart';
import 'package:nonogram/level_selection/level_provider.dart';
import 'package:provider/provider.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../player_progress/player_progress.dart';
import '../style/my_button.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  Widget levelSolution(List<List<int>> grid) {
    final int maxDimension = max(grid.length, grid[0].length);
    final List<List<int>> newGrid = List.generate(maxDimension, (_) => List.generate(maxDimension, (_) => 0));

    final int rowOffset = (maxDimension - grid.length) ~/ 2;
    final int colOffset = (maxDimension - grid[0].length) ~/ 2;

    for (int i = 0; i < grid.length; i++) {
      for (int j = 0; j < grid[i].length; j++) {
        newGrid[i + rowOffset][j + colOffset] = grid[i][j];
      }
    }

    return Container(
      color: Colors.white,
      height: 50,
      width: 50,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: newGrid[0].length),
        itemCount: newGrid.length * newGrid[0].length,
        itemBuilder: (context, index) {
          final row = index ~/ newGrid[0].length;
          final col = index % newGrid[0].length;
          final cell = newGrid[row][col];
          return Container(
            decoration: BoxDecoration(
              color: cell == 1 ? Colors.black : Colors.white,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final playerProgress = context.watch<PlayerProgress>();
    final levelProvider = context.watch<LevelProvider>();

    if (levelProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      backgroundColor: palette.backgroundLevelSelection,
      body: ResponsiveScreen(
        squarishMainArea: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Select level',
                  style: TextStyle(fontFamily: 'Permanent Marker', fontSize: 30),
                ),
              ),
            ),
            const SizedBox(height: 50),
            Expanded(
                child: ListView(
                    children: levelProvider.levels.map((level) {
              Score? score = playerProgress.highestScores
                  .cast<Score?>()
                  .firstWhere((e) => e!.name == level.puzzleName, orElse: () => null);

              return score != null
                  ? ListTile(
                      onTap: () {
                        final audioController = context.read<AudioController>();
                        audioController.playSfx(SfxType.buttonTap);

                        GoRouter.of(context).go('/play/session/${level.number}');
                      },
                      leading: Text(level.number.toString()),
                      title: Row(
                        children: [
                          Text(
                            level.puzzleName,
                            style: TextStyle(color: palette.ink),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'in ${playerProgress.highestScores.firstWhere((e) => e.level == level.number).formattedTime}',
                            style: TextStyle(color: palette.ink.withOpacity(0.5)),
                          )
                        ],
                      ),
                      trailing: levelSolution(
                          playerProgress.highestScores.firstWhere((e) => e.name == level.puzzleName).goal))
                  : ListTile(
                      onTap: () {
                        final audioController = context.read<AudioController>();
                        audioController.playSfx(SfxType.buttonTap);

                        GoRouter.of(context).go('/play/session/${level.number}');
                      },
                      leading: Text(level.number.toString()),
                      title: Row(
                        children: [
                          Text(level.puzzleName, style: TextStyle(color: palette.darkPen)),
                        ],
                      ),
                      trailing: const Icon(Icons.lock),
                    );
            }).toList())),
          ],
        ),
        rectangularMenuArea: Padding(
          padding: const EdgeInsets.all(8),
          child: MyButton(
            onPressed: () {
              GoRouter.of(context).go('/');
            },
            child: const Text('Back'),
          ),
        ),
      ),
    );
  }
}
