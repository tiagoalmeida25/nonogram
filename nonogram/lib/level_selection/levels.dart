// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

const gameLevels = [
  GameLevel(
    number: 1,
    puzzleName: '1',
    goal: [],
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
      [2],
    ],
    // You configure this in App Store Connect.
    achievementIdIOS: 'first_win',
    // You get this string when you configure an achievement in Play Console.
    achievementIdAndroid: 'NhkIwB69ejkMAOOLDb',
  ),
  GameLevel(
    number: 2,
    goal: [],
    width: 5,
    height: 5,
    columnIndications: [
      [1, 1],
      [1, 1],
      [1, 1],
      [1, 1],
      [1, 1],
    ],
    rowIndications: [],
    puzzleName: 'flower',
  ),
  GameLevel(
    number: 3,
    puzzleName: 'house',
    goal: [],
    width: 5,
    height: 10,
    columnIndications: [
      [1, 1],
      [1, 1],
      [1, 1],
      [1, 1],
      [1, 1],
    ],
    rowIndications: [
      [1],
      [1, 1],
      [1, 1],
      [1],
      [1],
      [1],
      [1],
      [1],
      [1],
      [1],
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

  final String? achievementIdAndroid;

  bool get awardsAchievement => achievementIdAndroid != null;

  const GameLevel({
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
  }) : assert(
            (achievementIdAndroid != null && achievementIdIOS != null) ||
                (achievementIdAndroid == null && achievementIdIOS == null),
            'Either both iOS and Android achievement ID must be provided, '
            'or none');
}
