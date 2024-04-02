// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:nonogram/game_internals/score.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'player_progress_persistence.dart';

/// An implementation of [PlayerProgressPersistence] that uses
/// `package:shared_preferences`.
class LocalStoragePlayerProgressPersistence extends PlayerProgressPersistence {
  final Future<SharedPreferences> instanceFuture = SharedPreferences.getInstance();

  @override
  Future<int> getHighestLevelReached() async {
    final prefs = await instanceFuture;
    return prefs.getInt('highestLevelReached') ?? 0;
  }

  @override
  Future<void> saveHighestLevelReached(int level) async {
    final prefs = await instanceFuture;
    await prefs.setInt('highestLevelReached', level);
  }

  @override
  Future<List<Score>> getHighestScores() async {
    final prefs = await instanceFuture;
    final scores = prefs.getStringList('scores') ?? [];
    return scores.map((e) {
      return Score.fromJson(jsonDecode(e));
    }).toList();
  }

  @override
  Future<void> saveScore(Score score) async {
    final prefs = await instanceFuture;
    final scores = prefs.getStringList('scores') ?? [];

    final existingScores = scores.map((e) => Score.fromJson(jsonDecode(e))).toList();
    final existingScore = existingScores.firstWhere((s) => s.name == score.name);

    if (score.duration < existingScore.duration) {
      existingScores.remove(existingScore);
    } else if (score.duration >= existingScore.duration) {
      return;
    }

    existingScores.add(score);
    await prefs.setStringList('scores', existingScores.map((s) => jsonEncode(s.toJson())).toList());
  }

  @override
  Future<void> resetScores() async {
    final prefs = await instanceFuture;
    await prefs.setStringList('scores', []);
  }
}
