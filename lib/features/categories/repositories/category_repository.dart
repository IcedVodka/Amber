import '../../../core/services/file_service.dart';
import '../models/category.dart';

class CategoryRepository {
  CategoryRepository(this._fileService);

  final FileService _fileService;

  static const String _filePath = 'current/categories.json';
  static const int _schemaVersion = 2;

  Future<List<Category>> load() async {
    final data = await _fileService.readJson(_filePath);
    if (data == null) {
      final defaults = _defaultCategories();
      await save(defaults);
      return defaults;
    }
    final items = (data['items'] as List<dynamic>? ?? [])
        .map((item) => Category.fromJson(item as Map<String, dynamic>))
        .toList();
    return _sorted(items);
  }

  Future<void> save(List<Category> items) async {
    final payload = {
      'schemaVersion': _schemaVersion,
      'lastModified': DateTime.now().millisecondsSinceEpoch,
      'items': items.map((item) => item.toJson()).toList(),
    };
    await _fileService.writeJson(_filePath, payload);
  }

  List<Category> _defaultCategories() {
    return const [
      Category(
        id: '工作',
        name: '工作',
        iconCode: 'briefcase',
        colorHex: '#FFB000',
        order: 1,
        enabled: true,
      ),
      Category(
        id: '休息',
        name: '休息',
        iconCode: 'coffee',
        colorHex: '#1AC98B',
        order: 2,
        enabled: true,
      ),
    ];
  }

  List<Category> _sorted(List<Category> items) {
    final sorted = [...items];
    sorted.sort((a, b) => a.order.compareTo(b.order));
    return sorted;
  }
}
