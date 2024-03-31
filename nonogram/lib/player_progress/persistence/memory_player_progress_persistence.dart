// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:nonogram/game_internals/score.dart';

import 'player_progress_persistence.dart';

/// An in-memory implementation of [PlayerProgressPersistence].
/// Useful for testing.
class MemoryOnlyPlayerProgressPersistence implements PlayerProgressPersistence {
  int level = 0;
  List<Score> scores = [];

  @override
  Future<int> getHighestLevelReached() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return level;
  }

  @override
  Future<void> saveHighestLevelReached(int level) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    this.level = level;
  }


  @override
  Future<List<Score>> getHighestScores() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return scores;
  }
  
  @override
  Future<void> saveScore(Score score) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    scores.add(score);
  }

  @override
  Future<void> resetScores() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    scores = [];
  }
}
