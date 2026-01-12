part of 'timeline_item.dart';

class Note extends TimelineItem {
  Note({
    required super.id,
    required this.content,
    required this.createdAt,
  });

  final String content;
  final DateTime createdAt;

  @override
  ItemType get type => ItemType.note;

  @override
  DateTime get sortTime => createdAt;

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      content: json['content'] as String,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'note',
      'id': id,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
