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
        id: '睡眠',
        name: '睡眠',
        iconCode: 'sleep',
        colorHex: '#9B6CFF',
        order: 1,
        enabled: true,
      ),
      Category(
        id: '上网',
        name: '上网',
        iconCode: 'wifi',
        colorHex: '#3A86FF',
        order: 2,
        enabled: true,
      ),
      Category(
        id: '工作',
        name: '工作',
        iconCode: 'briefcase',
        colorHex: '#8D99AE',
        order: 3,
        enabled: true,
      ),
      Category(
        id: '通勤',
        name: '通勤',
        iconCode: 'commute',
        colorHex: '#00B4D8',
        order: 4,
        enabled: true,
      ),
      Category(
        id: '用餐',
        name: '用餐',
        iconCode: 'restaurant',
        colorHex: '#FF8A3D',
        order: 5,
        enabled: true,
      ),
      Category(
        id: '运动',
        name: '运动',
        iconCode: 'fitness',
        colorHex: '#FF6B6B',
        order: 6,
        enabled: true,
      ),
      Category(
        id: '娱乐',
        name: '娱乐',
        iconCode: 'movie',
        colorHex: '#F15BB5',
        order: 7,
        enabled: true,
      ),
      Category(
        id: '家务',
        name: '家务',
        iconCode: 'cleaning',
        colorHex: '#1AC98B',
        order: 8,
        enabled: true,
      ),
      Category(
        id: '游戏',
        name: '游戏',
        iconCode: 'game',
        colorHex: '#5A6CFF',
        order: 9,
        enabled: true,
      ),
      Category(
        id: '影音',
        name: '影音',
        iconCode: 'video',
        colorHex: '#FFC857',
        order: 10,
        enabled: true,
      ),
      Category(
        id: '聊天',
        name: '聊天',
        iconCode: 'chat',
        colorHex: '#7B9A3C',
        order: 11,
        enabled: true,
      ),
      Category(
        id: '休息',
        name: '休息',
        iconCode: 'coffee',
        colorHex: '#FFB000',
        order: 12,
        enabled: true,
      ),
      Category(
        id: '学习',
        name: '学习',
        iconCode: 'study',
        colorHex: '#3A86FF',
        order: 13,
        enabled: true,
      ),
      Category(
        id: '购物',
        name: '购物',
        iconCode: 'shopping_bag',
        colorHex: '#FF6B6B',
        order: 14,
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
