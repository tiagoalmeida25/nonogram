class Score {
  final String name;
  final List<List<int>> goal;
  final int level;
  final Duration duration;
  final double? difficulty;
  final List<double>? ratings;

  const Score._(this.name, this.duration, this.level, this.goal, this.difficulty, this.ratings);

  Score.fromLevel(this.level, this.name, this.duration, this.goal, this.difficulty, this.ratings);

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
      'goal': goal,
      'difficulty': difficulty,
      'ratings': ratings,
      'level': level,
      'name': name,
      'duration': duration.toString(),
    };
  }

  factory Score.fromJson(dynamic json) {
    return Score._(
      json['name'] != null ? json['name'] as String : '',
      Score.parseDuration(json['duration'] as String),
      json['level'] as int,
      (json['goal'] as List).map((e) => (e as List).map((i) => i as int).toList()).toList(),
      json['difficulty'] != null ? json['difficulty'] as double : null,
      json['ratings'] != null ? (json['ratings'] as List).map((e) => e as double).toList() : null,
    );
  }
}
