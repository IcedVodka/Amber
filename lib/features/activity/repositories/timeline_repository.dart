import '../../../core/services/file_service.dart';
import '../models/timeline_item.dart';

class TimelineRepository {
  TimelineRepository(this._fileService);

  final FileService _fileService;

  Future<List<TimelineItem>> loadFor(DateTime date) async {
    final data = await _fileService.readJson(_filePath(date));
    if (data == null) {
      return [];
    }
    final items = (data['items'] as List<dynamic>? ?? [])
        .map((item) => TimelineItem.fromJson(item as Map<String, dynamic>))
        .toList();
    items.sort((a, b) => a.sortTime.compareTo(b.sortTime));
    return items;
  }

  Future<void> saveFor(DateTime date, List<TimelineItem> items) async {
    final payload = {
      'date': _formatDate(date),
      'items': items.map((item) => item.toJson()).toList(),
    };
    await _fileService.writeJson(_filePath(date), payload);
  }

  String _filePath(DateTime date) {
    return 'data/${_formatMonth(date)}/${_formatDate(date)}.json';
  }

  String _formatMonth(DateTime date) {
    return '${date.year}-${_two(date.month)}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${_two(date.month)}-${_two(date.day)}';
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}
