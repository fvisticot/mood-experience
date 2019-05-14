import 'package:meta/meta.dart';

enum MoodStatus {inProgress, completed, unknown}

class Mood {
  double value;
  DateTime timestamp;
  MoodStatus status;

  Mood({@required this.value, @required this.timestamp, this.status=MoodStatus.unknown});

  @override
  String toString() {
    return 'Mood{value: $value, timestamp: $timestamp}';
  }
}