import '../../activity/models/timeline_item.dart';
import '../../activity/repositories/timeline_repository.dart';

class StatsRepository {
  StatsRepository(this._timelineRepository);

  final TimelineRepository _timelineRepository;

  Future<List<TimelineItem>> loadFor(DateTime date) {
    return _timelineRepository.loadFor(date);
  }

  Future<Map<DateTime, List<TimelineItem>>> loadRange(
    DateTime start,
    DateTime end,
  ) async {
    final result = <DateTime, List<TimelineItem>>{};
    var cursor = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);
    while (!cursor.isAfter(last)) {
      final items = await _timelineRepository.loadFor(cursor);
      result[cursor] = items;
      cursor = cursor.add(const Duration(days: 1));
    }
    return result;
  }
}
