class Score {
  final int score;
  final List<List<int>> goal;
  final List<List<int>> solution;

  final int level;
  final Duration duration;

  factory Score(
      int level, String difficulty, Duration duration, List<List<int>> goal, List<List<int>> solution) {
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
    return Score._(score, duration, level, goal, solution);
  }

  const Score._(this.score, this.duration, this.level, this.goal, this.solution);

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
