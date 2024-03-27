import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nonogram/models/puzzle.dart';
import 'package:nonogram/style/palette.dart';
import 'package:provider/provider.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../game_internals/level_state.dart';
import '../level_selection/levels.dart';

class GameWidget extends StatefulWidget {
  const GameWidget({super.key});

  @override
  State<GameWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  late LevelState levelState;
  late GameLevel level;
  late Palette palette;

  @override
  void initState() {
    super.initState();
    level = context.read<GameLevel>();
    levelState = context.read<LevelState>();
    palette = context.read<Palette>();

    levelState.initProgress(level.height, level.width);
  }

  Future<void> loadPuzzle() async {
    const String path = 'assets/puzzles/1.non';

    final data = await rootBundle.loadString(path);
    final lines = data.split('\n');

    int width = 0;
    int height = 0;
    List<List<int>> rows = [];
    List<List<int>> cols = [];
    String goal = '';
    List<List<int>> solution = [];

    for (var line in lines) {
      if (line.contains('width')) {
        final match = RegExp(r'\d+').firstMatch(line);
        if (match != null) {
          width = int.parse(match.group(0)!);
        }
      } else if (line.contains('height')) {
        final match = RegExp(r'\d+').firstMatch(line);
        if (match != null) {
          height = int.parse(match.group(0)!);
        }
      } else if (line.contains('rows')) {
        for (var i = 0; i < height; i++) {
          final newLine = lines[i + lines.indexOf('rows') + 1];
          if (newLine.contains(',')) {
            rows.add(newLine.split(',').map(int.parse).toList());
          } else {
            rows.add([int.parse(newLine)]);
          }
        }
      } else if (line.contains('columns')) {
        for (var i = 0; i < width; i++) {
          final newLine = lines[i + lines.indexOf('columns') + 1];
          if (newLine.contains(',')) {
            cols.add(newLine.split(',').map(int.parse).toList());
          } else {
            cols.add([int.parse(newLine)]);
          }
        }
      } else if (line.contains('goal')) {
        final match = RegExp(r'\d+').firstMatch(line);
        if (match != null) {
          goal = match.group(0)!;
        }
      }
    }
    List<int> line = [];
    int counter = 0;
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        line.add(int.parse(goal[counter]));
        counter++;
      }
      solution.add(line);
      line = [];
    }

    levelState.setGoal(solution);
    print(solution);
    print(levelState.goal);
  }

  Widget _buildRowIndications(List<List<int>> rows, double cellSize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: rows.map((row) {
          return SizedBox(
            height: cellSize,
            child: Row(
              children: [
                for (var val in row)
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Center(child: Text(val.toString())),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildColumnIndications(List<List<int>> cols, double cellSize) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: cols.map((col) {
        return SizedBox(
          width: cellSize,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: col
                .map((val) => Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(val.toString()),
                    ))
                .toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPuzzleGrid(double cellSize) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: level.height * level.width,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: level.width,
        childAspectRatio: 1,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
      ),
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            context.read<AudioController>().playSfx(SfxType.wssh);
            levelState.progress[index ~/ level.height][index % level.width] = levelState.marker;

            levelState.setProgress(levelState.progress);

            levelState.evaluate();
          },
          child: Container(
            decoration: BoxDecoration(
              color: levelState.progress[index ~/ level.height][index % level.width] == 'X'
                  ? Colors.black
                  : levelState.progress[index ~/ level.height][index % level.width] == '.'
                      ? Colors.grey
                      : Colors.white,
              border: Border.all(color: Colors.black, width: 0.5),
            ),
          ),
        );
      },
    );
  }

  Widget appBar() {
    return AppBar(
      centerTitle: false,
      title: Text('Level ${level.puzzleName}',
          style: TextStyle(
            color: palette.ink,
            fontSize: 24,
            fontFamily: 'Permanent Marker',
          )),
      elevation: 0,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        appBar(),
        FutureBuilder(
            future: loadPuzzle(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.start,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildRowIndications(level.rowIndications, 48),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildColumnIndications(level.columnIndications, 48),
                            SizedBox(
                                height: 48 * level.height + 8,
                                width: 48 * level.width + 8,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: _buildPuzzleGrid(48),
                                )),
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                return const CircularProgressIndicator();
              }
            }),
      ],
    );

    // return Column(
    //   children: [
    //     Text('Drag the slider to ${level.difficulty}% or above!'),
    //     Slider(
    //       label: 'Level Progress',
    //       autofocus: true,
    //       value: levelState.progress / 100,
    //       onChanged: (value) => levelState.setProgress((value * 100).round()),
    //       onChangeEnd: (value) {
    //         context.read<AudioController>().playSfx(SfxType.wssh);
    //         levelState.evaluate();
    //       },
    //     ),
    //   ],
    // );
  }
}
