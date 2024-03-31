import 'package:nonogram/game_internals/score.dart';

List<GameLevel> gameLevels = [
  GameLevel(
    number: 1,
    puzzleName: 'Person',
    goal: [
      [
        0,
        1,
        1,
        0,
        0,
      ],
      [0, 1, 1, 0, 1],
      [0, 0, 1, 0, 1],
      [0, 1, 1, 1, 0],
      [1, 0, 1, 0, 0],
      [1, 0, 1, 0, 0],
      [0, 0, 1, 1, 0],
      [0, 1, 0, 1, 0],
      [0, 1, 0, 1, 1],
      [1, 1, 0, 0, 0],
    ],
    width: 5,
    height: 10,
    columnIndications: [
      [2, 1],
      [2, 1, 3],
      [7],
      [1, 3],
      [2, 1],
    ],
    rowIndications: [
      [2],
      [2, 1],
      [1, 1],
      [3],
      [1, 1],
      [1, 1],
      [2],
      [1, 1],
      [1, 2],
      [2]
    ],
    achievementIdIOS: 'first_win',
    achievementIdAndroid: 'NhkIwB69ejkMAOOLDb',
  ),
  GameLevel(
    number: 2,
    goal: [
      [1, 1, 1, 0, 0, 0, 0, 1, 1, 0],
      [1, 1, 1, 0, 0, 0, 0, 0, 0, 0],
      [1, 1, 0, 0, 0, 0, 1, 1, 0, 0],
      [0, 0, 0, 0, 0, 1, 1, 1, 1, 0],
      [0, 0, 0, 0, 0, 1, 1, 1, 1, 0],
      [0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
      [0, 1, 1, 1, 1, 0, 0, 0, 0, 1],
      [0, 1, 1, 1, 1, 0, 0, 0, 1, 1],
      [0, 0, 1, 1, 0, 0, 0, 0, 1, 1],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    ],
    width: 10,
    height: 10,
    rowIndications: [
      [3, 2],
      [3],
      [2, 2],
      [4],
      [4],
      [2, 2],
      [4, 1],
      [4, 2],
      [2, 2],
      [1],
    ],
    columnIndications: [
      [3],
      [3, 2],
      [2, 4],
      [4],
      [2],
      [2],
      [4],
      [1, 4],
      [1, 2, 2],
      [4],
    ],
    puzzleName: 'Galaxies',
  ),
  GameLevel(
    number: 3,
    puzzleName: 'Apple',
    goal: [
      [0, 0, 0, 0, 1, 1, 0, 0, 0, 0],
      [0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
      [0, 1, 1, 1, 0, 1, 1, 1, 1, 0],
      [1, 1, 0, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 0, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 0, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 0, 1, 1, 1, 1, 1, 1, 1],
      [0, 1, 1, 1, 1, 1, 1, 1, 1, 0],
      [0, 0, 1, 1, 1, 1, 1, 1, 0, 0]
    ],
    width: 10,
    height: 10,
    columnIndications: [
      [5],
      [3, 2],
      [1, 3, 2],
      [8],
      [2, 7],
      [1, 8],
      [8],
      [8],
      [7],
      [5],
    ],
    rowIndications: [
      [2],
      [1],
      [3, 4],
      [2, 7],
      [10],
      [1, 8],
      [1, 8],
      [2, 7],
      [8],
      [6],
    ],
    achievementIdIOS: 'finished',
    achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
  ),
];

class GameLevel {
  final int number;
  final String puzzleName;
  final List<List<int>> goal;
  final int width;
  final int height;
  final String difficulty;
  final List<List<int>> columnIndications;
  final List<List<int>> rowIndications;

  /// The achievement to unlock when the level is finished, if any.
  final String? achievementIdIOS;
  List<List<int>>? solution;
  Score? score;

  final String? achievementIdAndroid;

  bool get awardsAchievement => achievementIdAndroid != null;

  GameLevel({
    required this.number,
    required this.puzzleName,
    required this.goal,
    required this.columnIndications,
    required this.rowIndications,
    required this.width,
    required this.height,
    this.achievementIdIOS,
    this.achievementIdAndroid,
    this.difficulty = 'easy',
    this.solution,
    this.score,
  }) : assert(
            (achievementIdAndroid != null && achievementIdIOS != null) ||
                (achievementIdAndroid == null && achievementIdIOS == null),
            'Either both iOS and Android achievement ID must be provided, '
            'or none');

  void setSolution(List<List<int>> solution) {
    this.solution = solution;
  }
}
