class Score {
  final int score;
  final String name;
  final List<List<int>> goal;
  final List<List<int>> solution;

  final int level;
  final Duration duration;

  factory Score(
    int level,
    String name,
    String difficulty,
    Duration duration,
    List<List<int>> goal,
    List<List<int>> solution,
  ) {
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
    return Score._(score, name, duration, level, goal, solution);
  }

  const Score._(this.score, this.name, this.duration, this.level, this.goal, this.solution);

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

  static Duration parseDuration(String durationString) {
    var parts = durationString.split(':').map((part) => double.parse(part)).toList();
    return Duration(
        hours: parts[0].toInt(), minutes: parts[1].toInt(), milliseconds: (parts[2] * 1000).toInt());
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'goal': goal,
      'solution': solution,
      'level': level,
      'name': name,
      'duration': duration.toString(),
    };
  }

  factory Score.fromJson(dynamic json) {
    return Score._(
      json['score'] as int,
      json['name'] != null ? json['name'] as String : '',
      Score.parseDuration(json['duration'] as String),
      json['level'] as int,
      (json['goal'] as List).map((e) => (e as List).map((i) => i as int).toList()).toList(),
      (json['solution'] as List).map((e) => (e as List).map((i) => i as int).toList()).toList(),
    );
  }
}
