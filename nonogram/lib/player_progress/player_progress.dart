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
  static const maxHighestScoresPerPlayer = 10;

  /// By default, settings are persisted using
  /// [LocalStoragePlayerProgressPersistence] (i.e. NSUserDefaults on iOS,
  /// SharedPreferences on Android or local storage on the web).
  final PlayerProgressPersistence _store;

  int _highestLevelReached = 0;

  List<Score> _highestScores = [];

  /// Creates an instance of [PlayerProgress] backed by an injected
  /// persistence [store].
  PlayerProgress({PlayerProgressPersistence? store})
      : _store = store ?? LocalStoragePlayerProgressPersistence() {
    _getLatestFromStore();
  }

  /// The highest level that the player has reached so far.
  int get highestLevelReached => _highestLevelReached;
  List<Score> get highestScores => _highestScores;

  /// Resets the player's progress so it's like if they just started
  /// playing the game for the first time.
  void reset() {
    _highestScores = [];
    notifyListeners();
    _store.resetScores();
  }

  /// Registers [level] as reached.
  ///
  /// If this is higher than [highestLevelReached], it will update that
  /// value and save it to the injected persistence store.
  void setLevelReached(int level, Score score) {
    if (level > _highestLevelReached) {
      _highestLevelReached = level;
      _highestScores.add(score);
      notifyListeners();

      unawaited(_store.saveHighestLevelReached(level));
      unawaited(_store.saveScore(score));
    }
  }

  /// Fetches the latest data from the backing persistence store.
  Future<void> _getLatestFromStore() async {
    final level = await _store.getHighestLevelReached();
    final scores =  await _store.getHighestScores();

    if (level > _highestLevelReached) {
      _highestLevelReached = level;
      _highestScores = scores;
      notifyListeners();
    } else if (level < _highestLevelReached) {
      await _store.saveHighestLevelReached(_highestLevelReached);
      _highestScores.map((e) => _store.saveScore(e));
    }
  }
}
