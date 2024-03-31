import 'dart:convert';
import 'package:nonogram/game_internals/score.dart';

// List<GameLevel> gameLevels = [
//   GameLevel(
//     number: 1,
//     height: 5,
//     width: 5,
//     columnIndications: [
//       [1],
//       [3],
//       [2, 2],
//       [3],
//       [1]
//     ],
//     goal: [
//       [0, 0, 1, 0, 0],
//       [0, 1, 1, 1, 0],
//       [1, 1, 0, 1, 1],
//       [0, 1, 1, 1, 0],
//       [0, 0, 1, 0, 0]
//     ],
//     rowIndications: [
//       [1],
//       [3],
//       [2, 2],
//       [3],
//       [1]
//     ],
//     puzzleName: 'Star',
//   ),
//   GameLevel(
//     number: 2,
//     puzzleName: 'Person',
//     width: 5,
//     height: 10,
//     goal: [
//       [
//         0,
//         1,
//         1,
//         0,
//         0,
//       ],
//       [0, 1, 1, 0, 1],
//       [0, 0, 1, 0, 1],
//       [0, 1, 1, 1, 0],
//       [1, 0, 1, 0, 0],
//       [1, 0, 1, 0, 0],
//       [0, 0, 1, 1, 0],
//       [0, 1, 0, 1, 0],
//       [0, 1, 0, 1, 1],
//       [1, 1, 0, 0, 0],
//     ],
//     columnIndications: [
//       [2, 1],
//       [2, 1, 3],
//       [7],
//       [1, 3],
//       [2, 1],
//     ],
//     rowIndications: [
//       [2],
//       [2, 1],
//       [1, 1],
//       [3],
//       [1, 1],
//       [1, 1],
//       [2],
//       [1, 1],
//       [1, 2],
//       [2]
//     ],
//   ),
//   GameLevel(
//     number: 3,
//     goal: [
//       [1, 1, 1, 0, 0, 0, 0, 1, 1, 0],
//       [1, 1, 1, 0, 0, 0, 0, 0, 0, 0],
//       [1, 1, 0, 0, 0, 0, 1, 1, 0, 0],
//       [0, 0, 0, 0, 0, 1, 1, 1, 1, 0],
//       [0, 0, 0, 0, 0, 1, 1, 1, 1, 0],
//       [0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
//       [0, 1, 1, 1, 1, 0, 0, 0, 0, 1],
//       [0, 1, 1, 1, 1, 0, 0, 0, 1, 1],
//       [0, 0, 1, 1, 0, 0, 0, 0, 1, 1],
//       [0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
//     ],
//     width: 10,
//     height: 10,
//     rowIndications: [
//       [3, 2],
//       [3],
//       [2, 2],
//       [4],
//       [4],
//       [2, 2],
//       [4, 1],
//       [4, 2],
//       [2, 2],
//       [1],
//     ],
//     columnIndications: [
//       [3],
//       [3, 2],
//       [2, 4],
//       [4],
//       [2],
//       [2],
//       [4],
//       [1, 4],
//       [1, 2, 2],
//       [4],
//     ],
//     puzzleName: 'Galaxies',
//   ),
//   GameLevel(
//     number: 4,
//     puzzleName: 'Apple',
//     goal: [
//       [0, 0, 0, 0, 1, 1, 0, 0, 0, 0],
//       [0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
//       [0, 1, 1, 1, 0, 1, 1, 1, 1, 0],
//       [1, 1, 0, 1, 1, 1, 1, 1, 1, 1],
//       [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
//       [1, 0, 1, 1, 1, 1, 1, 1, 1, 1],
//       [1, 0, 1, 1, 1, 1, 1, 1, 1, 1],
//       [1, 1, 0, 1, 1, 1, 1, 1, 1, 1],
//       [0, 1, 1, 1, 1, 1, 1, 1, 1, 0],
//       [0, 0, 1, 1, 1, 1, 1, 1, 0, 0]
//     ],
//     width: 10,
//     height: 10,
//     columnIndications: [
//       [5],
//       [3, 2],
//       [1, 3, 2],
//       [8],
//       [2, 7],
//       [1, 8],
//       [8],
//       [8],
//       [7],
//       [5],
//     ],
//     rowIndications: [
//       [2],
//       [1],
//       [3, 4],
//       [2, 7],
//       [10],
//       [1, 8],
//       [1, 8],
//       [2, 7],
//       [8],
//       [6],
//     ],
//   ),
// ];

class GameLevel {
  int number;
  final String puzzleName;
  final List<List<int>> goal;
  final int width;
  final int height;
  final String difficulty;
  final List<List<int>> columnIndications;
  final List<List<int>> rowIndications;

  List<List<int>>? solution;
  Score? score;

  GameLevel({
    required this.number,
    required this.puzzleName,
    required this.goal,
    required this.columnIndications,
    required this.rowIndications,
    required this.width,
    required this.height,
    this.difficulty = 'easy',
    this.solution,
    this.score,
  });

  void setSolution(List<List<int>> solution) {
    this.solution = solution;
  }

  static GameLevel fromFirestore(var element, int number) {
    final level = GameLevel(
      number: number,
      puzzleName: element['name'] as String,
      goal: (jsonDecode(element['goal'] as String) as List).map((e) => (e as List).cast<int>()).toList(),
      columnIndications: (jsonDecode(element['columnIndications'] as String) as List)
          .map((e) => (e as List).cast<int>())
          .toList(),
      rowIndications: (jsonDecode(element['rowIndications'] as String) as List)
          .map((e) => (e as List).cast<int>())
          .toList(),
      width: element['width'] as int,
      height: element['height'] as int,
    );

    return level;
  }
}
