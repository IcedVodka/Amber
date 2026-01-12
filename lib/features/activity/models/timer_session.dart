class TimerSession {
  TimerSession({
    required this.isRunning,
    required this.categoryId,
    required this.content,
    required this.startAt,
    required this.accumulatedSec,
    required this.lastResumeAt,
  });

  final bool isRunning;
  final String categoryId;
  final String content;
  final DateTime startAt;
  final int accumulatedSec;
  final DateTime? lastResumeAt;

  int get currentDuration {
    if (!isRunning || lastResumeAt == null) {
      return accumulatedSec;
    }
    return accumulatedSec + DateTime.now().difference(lastResumeAt!).inSeconds;
  }

  TimerSession copyWith({
    bool? isRunning,
    String? categoryId,
    String? content,
    DateTime? startAt,
    int? accumulatedSec,
    DateTime? lastResumeAt,
  }) {
    return TimerSession(
      isRunning: isRunning ?? this.isRunning,
      categoryId: categoryId ?? this.categoryId,
      content: content ?? this.content,
      startAt: startAt ?? this.startAt,
      accumulatedSec: accumulatedSec ?? this.accumulatedSec,
      lastResumeAt: lastResumeAt ?? this.lastResumeAt,
    );
  }

  factory TimerSession.fromJson(Map<String, dynamic> json) {
    return TimerSession(
      isRunning: json['isRunning'] as bool,
      categoryId: json['categoryId'] as String,
      content: json['content'] as String,
      startAt: DateTime.parse(json['startAt'] as String),
      accumulatedSec: json['accumulatedSec'] as int,
      lastResumeAt: json['lastResumeAt'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(json['lastResumeAt'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isRunning': isRunning,
      'categoryId': categoryId,
      'content': content,
      'startAt': startAt.toIso8601String(),
      'accumulatedSec': accumulatedSec,
      'lastResumeAt': lastResumeAt?.millisecondsSinceEpoch,
    };
  }
}
