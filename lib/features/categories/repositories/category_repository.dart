import '../../../core/services/file_service.dart';
import '../models/category.dart';

class CategoryRepository {
  CategoryRepository(this._fileService);

  final FileService _fileService;

  static const String _filePath = 'current/categories.json';
  static const int _schemaVersion = 3;

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
        id: '上网探索',
        name: '上网探索',
        iconCode: 'wifi',
        colorHex: '#3A86FF',
        order: 1,
        enabled: true,
        defaultWeight: 1.0,
      ),
      Category(
        id: '学习',
        name: '学习',
        iconCode: 'study',
        colorHex: '#3A86FF',
        order: 2,
        enabled: true,
        defaultWeight: 1.0,
      ),
      Category(
        id: '工作',
        name: '工作',
        iconCode: 'briefcase',
        colorHex: '#8D99AE',
        order: 3,
        enabled: true,
        defaultWeight: 1.0,
      ),
      Category(
        id: '睡眠',
        name: '睡眠',
        iconCode: 'sleep',
        colorHex: '#9B6CFF',
        order: 4,
        enabled: true,
        defaultWeight: 1.0,
      ),
      Category(
        id: '运动',
        name: '运动',
        iconCode: 'fitness',
        colorHex: '#FF6B6B',
        order: 5,
        enabled: true,
        defaultWeight: 1.0,
      ),
      Category(
        id: '游戏',
        name: '游戏',
        iconCode: 'game',
        colorHex: '#5A6CFF',
        order: 6,
        enabled: true,
        defaultWeight: 1.0,
      ),
      Category(
        id: '影音',
        name: '影音',
        iconCode: 'video',
        colorHex: '#FFC857',
        order: 7,
        enabled: true,
        defaultWeight: 1.0,
      ),
      Category(
        id: '社交',
        name: '社交',
        iconCode: 'chat',
        colorHex: '#7B9A3C',
        order: 8,
        enabled: true,
        defaultWeight: 1.0,
      ),
      Category(
        id: '兴致',
        name: '兴致',
        iconCode: 'emoji',
        colorHex: '#FFB000',
        order: 9,
        enabled: true,
        defaultWeight: 1.0,
      ),
    ];
  }

  List<Category> _sorted(List<Category> items) {
    final sorted = [...items];
    sorted.sort((a, b) => a.order.compareTo(b.order));
    return sorted;
  }
}
