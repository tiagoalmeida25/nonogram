// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// An extremely silly example of a game state.
///
/// Tracks only a single variable, [progress], and calls [onWin] when
/// the value of [progress] reaches [goal].
class LevelState extends ChangeNotifier {
  final VoidCallback onWin;
  List<List<int>> goal;
  final String marker;

  LevelState({required this.onWin, this.goal = const <List<int>>[], this.marker = 'X'});

  List<List<String>> _progress = [];

  List<List<String>> get progress => _progress;

  void setGoal(List<List<int>> value) {
    goal.clear();
    goal = value;
  }

  void initProgress(int width, int height) {
    _progress = List.generate(height, (i) => List.filled(width, ''));
  }

  void setProgress(List<List<String>> value) {
    _progress = value;
    notifyListeners();
  }

  void evaluate() {
    int counter = 0;
    List<List<int>> userGrid = _progress.map((e) => e.map((e) => e == 'X' ? 1 : 0).toList()).toList();

    for (int i = 0; i < goal.length; i++) {
      if (listEquals(userGrid[i], goal[i])) {
        counter++;
      }
    }

    if (counter == goal.length) {
      onWin();
    }
  }
}
