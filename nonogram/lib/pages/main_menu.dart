import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:nonogram/models/puzzle.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  late Puzzle puzzle;
  List<List<int>> userGrid = [];
  double cellSize = 48;

  @override
  void initState() {
    super.initState();
    loadPuzzle().then((value) {
      setState(() {
        puzzle = value;
        userGrid = List.generate(puzzle.puzzleHeight, (index) => List.generate(puzzle.puzzleWidth, (index) => 0));
      });
    });
  }

  Future<Puzzle> loadPuzzle() async {
    const String path = 'assets/puzzles/1.non';

    final data = await rootBundle.loadString(path);
    final lines = data.split('\n');

    int width = 0;
    int height = 0;
    List<List<List<int>>> grid = [];
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
    grid = [rows, cols];
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

    return Puzzle(puzzle: grid, solution: solution, puzzleHeight: height, puzzleWidth: width);
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
      itemCount: puzzle.puzzleHeight * puzzle.puzzleWidth,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: puzzle.puzzleWidth,
        childAspectRatio: 1, // Ensures the cells are square, matching width to height
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
      ),
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            if (userGrid == puzzle.solution) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Congratulations! You solved the puzzle!'),
              ));
            }

            setState(() {
              userGrid[index ~/ puzzle.puzzleWidth][index % puzzle.puzzleWidth] =
                  userGrid[index ~/ puzzle.puzzleWidth][index % puzzle.puzzleWidth] == 1 ? 0 : 1;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: userGrid[index ~/ puzzle.puzzleWidth][index % puzzle.puzzleWidth] == 1
                  ? Colors.black
                  : Colors.white,
              border: Border.all(color: Colors.black, width: 0.5),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadPuzzle(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Nonogram'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildRowIndications(puzzle.puzzle[0], cellSize),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildColumnIndications(puzzle.puzzle[1], cellSize),
                          SizedBox(
                              height: cellSize * puzzle.puzzleHeight + 8,
                              width: cellSize * puzzle.puzzleWidth + 8,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _buildPuzzleGrid(cellSize),
                              )),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
