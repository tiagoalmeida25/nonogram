import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nonogram/game_internals/score.dart';
import 'package:nonogram/level_selection/filter_dialog.dart';
import 'package:nonogram/level_selection/level_provider.dart';
import 'package:nonogram/settings/settings.dart';
import 'package:provider/provider.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../player_progress/player_progress.dart';
import '../style/my_button.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  Widget levelSolution(List<List<int>> grid, SettingsController settings) {
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
              color: cell == 1 ? settings.colorChosen.value : Colors.white,
            ),
          );
        },
      ),
    );
  }

  Widget searchAndFilterArea(LevelProvider levelProvider, Palette palette, BuildContext context) {
    return GestureDetector(
      onTap: () => showCustomFilterDialog(context, levelProvider),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
                width: 100,
                height: 35,
                decoration: BoxDecoration(
                  color: palette.buttonColor,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.filter_alt, color: palette.ink),
                      onPressed: () {},
                    ),
                    Text('Filter', style: TextStyle(color: palette.ink, fontWeight: FontWeight.bold)),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final playerProgress = context.watch<PlayerProgress>();
    final levelProvider = context.watch<LevelProvider>();
    final settings = context.watch<SettingsController>();

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
            searchAndFilterArea(levelProvider, palette, context),
            Expanded(
                child: ListView(
                    children: levelProvider.levels.map((level) {
              Score? score = playerProgress.highestScores
                  .cast<Score?>()
                  .firstWhere((e) => e!.name == level.puzzleName, orElse: () => null);
              Color difficultyColor = level.difficulty == null
                  ? Colors.white.withOpacity(0.5)
                  : level.difficulty! <= 1
                      ? Colors.green.withOpacity(0.5)
                      : level.difficulty! <= 2
                          ? Colors.lightGreen.withOpacity(0.5)
                          : level.difficulty! <= 3
                              ? Colors.amber.withOpacity(0.5)
                              : level.difficulty! <= 4
                                  ? Colors.orange.withOpacity(0.5)
                                  : Colors.red.withOpacity(0.5);

              return score != null
                  ? ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: () {
                        final audioController = context.read<AudioController>();
                        audioController.playSfx(SfxType.buttonTap);

                        GoRouter.of(context).go('/play/session/${level.number}');
                      },
                      leading: CircleAvatar(
                          maxRadius: 12,
                          backgroundColor: difficultyColor,
                          child: FittedBox(child: Text(level.number.toString()))),
                      title: Row(
                        children: [
                          Text(
                            level.puzzleName,
                            style: TextStyle(color: palette.ink),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'in ${score.formattedTime}',
                            style: TextStyle(color: palette.ink.withOpacity(0.5)),
                          )
                        ],
                      ),
                      trailing: levelSolution(score.goal, settings))
                  : ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: () {
                        final audioController = context.read<AudioController>();
                        audioController.playSfx(SfxType.buttonTap);

                        GoRouter.of(context).go('/play/session/${level.number}');
                      },
                      leading: CircleAvatar(
                          maxRadius: 12,
                          backgroundColor: difficultyColor,
                          child: FittedBox(child: Text(level.number.toString()))),
                      title: Row(
                        children: [
                          Text(level.puzzleName, style: TextStyle(color: palette.pen)),
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
