import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/recent_item.dart';

class TimerViewState {
  const TimerViewState({
    required this.now,
    required this.recentItems,
  });

  final DateTime now;
  final List<RecentItem> recentItems;

  TimerViewState copyWith({
    DateTime? now,
    List<RecentItem>? recentItems,
  }) {
    return TimerViewState(
      now: now ?? this.now,
      recentItems: recentItems ?? this.recentItems,
    );
  }
}

final timerViewModelProvider =
    NotifierProvider<TimerViewModel, TimerViewState>(TimerViewModel.new);

class TimerViewModel extends Notifier<TimerViewState> {
  @override
  TimerViewState build() {
    return TimerViewState(
      now: DateTime.now(),
      recentItems: const [
        RecentItem(
          color: Color(0xFF5A6CFF),
          title: 'Flutter UI 开发',
          subtitle: 'Side Project',
          duration: '1h 20m',
        ),
        RecentItem(
          color: Color(0xFF9B6CFF),
          title: '阅读技术文档',
          subtitle: 'Learning',
          duration: '45m',
        ),
        RecentItem(
          color: Color(0xFFFF8C5C),
          title: '产品头脑风暴',
          subtitle: 'Planning',
          duration: '30m',
        ),
      ],
    );
  }
}
