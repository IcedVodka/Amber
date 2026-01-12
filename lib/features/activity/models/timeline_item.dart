part 'note.dart';
part 'time_record.dart';

enum ItemType { record, note }

abstract class TimelineItem {
  TimelineItem({required this.id});

  final String id;

  ItemType get type;

  DateTime get sortTime;

  Map<String, dynamic> toJson();

  factory TimelineItem.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type == 'record') {
      return TimeRecord.fromJson(json);
    }
    if (type == 'note') {
      return Note.fromJson(json);
    }
    throw Exception('Unknown type');
  }
}
