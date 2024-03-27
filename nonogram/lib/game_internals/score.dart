// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Encapsulates a score and the arithmetic to compute it.
class Score {
  final int score;

  final int level;
  final Duration duration;

  factory Score(int level, String difficulty, Duration duration) {
    // The higher the difficulty, the higher the score.
    var score = 0;
    switch (difficulty) {
      case 'easy':
        score += 100;
        break;
      case 'medium':
        score += 500;
        break;
      case 'hard':
        score += 1000;
        break;
      default:
        throw ArgumentError('Unknown difficulty: $difficulty');
    }
    return Score._(score, duration, level);
  }

  const Score._(this.score, this.duration, this.level);

  String get formattedTime {
    final buf = StringBuffer();
    if (duration.inHours > 0) {
      buf.write('${duration.inHours}');
      buf.write(':');
    }
    final minutes = duration.inMinutes % Duration.minutesPerHour;
    if (minutes > 9) {
      buf.write('$minutes');
    } else {
      buf.write('0');
      buf.write('$minutes');
    }
    buf.write(':');
    buf.write((duration.inSeconds % Duration.secondsPerMinute).toString().padLeft(2, '0'));
    return buf.toString();
  }

  @override
  String toString() => 'Score<$score,$formattedTime,$level>';
}
