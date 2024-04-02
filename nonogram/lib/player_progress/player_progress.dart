// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nonogram/game_internals/score.dart';

import 'persistence/local_storage_player_progress_persistence.dart';
import 'persistence/player_progress_persistence.dart';

/// Encapsulates the player's progress.
class PlayerProgress extends ChangeNotifier {
  /// By default, settings are persisted using
  /// [LocalStoragePlayerProgressPersistence] (i.e. NSUserDefaults on iOS,
  /// SharedPreferences on Android or local storage on the web).
  final PlayerProgressPersistence _store;

  List<Score> _highestScores = [];

  /// Creates an instance of [PlayerProgress] backed by an injected
  /// persistence [store].
  PlayerProgress({PlayerProgressPersistence? store})
      : _store = store ?? LocalStoragePlayerProgressPersistence() {
    _getLatestFromStore();
  }

  /// The highest level that the player has reached so far.
  List<Score> get highestScores => _highestScores;

  /// Resets the player's progress so it's like if they just started
  /// playing the game for the first time.
  void reset() {
    _highestScores = [];
    notifyListeners();
    _store.resetScores();
  }

  void setLevelReached(int level, Score score) {
    _highestScores.add(score);
    unawaited(_store.saveScore(score));
    notifyListeners();
  }


  Future<void> _getLatestFromStore() async {
    final scores = await _store.getHighestScores();
    _highestScores = scores;

    notifyListeners();
  }
}
