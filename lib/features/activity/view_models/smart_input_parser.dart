import '../../categories/models/category.dart';
import '../models/timeline_item.dart';

class SmartInputParser {
  SmartInputParser(this._categories);

  final List<Category> _categories;

  static final RegExp _pattern = RegExp(
    r'^#(\S+)\s+(.+?)(\s+(\d+)[hH:]((\d+)[mM]?)?)?(\s*\*([\d\.]+))?$',
  );

  TimelineItem? parse(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    if (!trimmed.startsWith('#')) {
      return Note(
        id: _newId('note'),
        content: trimmed,
        createdAt: DateTime.now(),
      );
    }
    final match = _pattern.firstMatch(trimmed);
    if (match == null) {
      return Note(
        id: _newId('note'),
        content: trimmed,
        createdAt: DateTime.now(),
      );
    }
    final categoryKey = match.group(1) ?? '';
    final content = (match.group(2) ?? '').trim();
    final hours = int.parse(match.group(4) ?? '0');
    final minutes = int.parse((match.group(6) ?? '0').replaceAll('m', ''));
    final hasDuration = match.group(3) != null;
    final category = _findCategory(categoryKey);
    if (!hasDuration || category == null) {
      return Note(
        id: _newId('note'),
        content: trimmed,
        createdAt: DateTime.now(),
      );
    }
    final durationSec = (hours * 60 + minutes) * 60;
    final weight = match.group(8) == null
        ? category.defaultWeight
        : double.parse(match.group(8)!);
    final endAt = DateTime.now();
    final startAt = endAt.subtract(Duration(seconds: durationSec));
    return TimeRecord(
      id: _newId('record'),
      categoryId: category.id,
      content: content,
      startAt: startAt,
      endAt: endAt,
      durationSec: durationSec,
      weight: weight,
    );
  }

  Category? _findCategory(String key) {
    for (final item in _categories) {
      if (item.id == key || item.name == key) {
        return item;
      }
    }
    return null;
  }

  String _newId(String prefix) {
    return '${prefix}_${DateTime.now().microsecondsSinceEpoch}';
  }
}
