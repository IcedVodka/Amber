part of 'timeline_item.dart';

class TimeRecord extends TimelineItem {
  TimeRecord({
    required super.id,
    required this.categoryId,
    required this.content,
    required this.startAt,
    required this.endAt,
    required this.durationSec,
    required this.weight,
  });

  final String categoryId;
  final String content;
  final DateTime startAt;
  final DateTime endAt;
  final int durationSec;
  final double weight;

  @override
  ItemType get type => ItemType.record;

  @override
  DateTime get sortTime => startAt;

  double get effectiveSec => durationSec * weight;

  int get wallClockSec => endAt.difference(startAt).inSeconds;

  factory TimeRecord.fromJson(Map<String, dynamic> json) {
    return TimeRecord(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      content: json['content'] as String,
      startAt: DateTime.parse(json['startAt'] as String),
      endAt: DateTime.parse(json['endAt'] as String),
      durationSec: json['durationSec'] as int,
      weight: (json['weight'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'record',
      'id': id,
      'categoryId': categoryId,
      'content': content,
      'startAt': startAt.toIso8601String(),
      'endAt': endAt.toIso8601String(),
      'durationSec': durationSec,
      'weight': weight,
    };
  }
}
