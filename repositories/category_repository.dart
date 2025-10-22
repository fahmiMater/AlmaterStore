// category_repository.dart
import 'dart:collection';
import '../models/Category.dart';
 

/// عقد عام للوصول إلى بيانات التصنيفات
abstract class CategoryRepository {
  UnmodifiableListView<Category> getAll();
  Category? byId(int id);
  void add(Category c);
  bool remove(int id);
  bool update(Category c); // اختياري الآن
  bool exists(int id);
}

/// تطبيق داخل الذاكرة (الافتراضي مؤقتًا)
class InMemoryCategoryRepository implements CategoryRepository {
  final List<Category> _items = [];

  @override
  UnmodifiableListView<Category> getAll() => UnmodifiableListView(_items);

  @override
  Category? byId(int id) {
    for (final c in _items) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  void add(Category c) {
    _items.add(c);
  }

  @override
  bool remove(int id) {
    final before = _items.length;
    _items.removeWhere((e) => e.id == id);
    return _items.length != before;
  }

  @override
  bool update(Category c) {
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].id == c.id) {
        _items[i] = c;
        return true;
      }
    }
    return false;
  }
  
  @override
  bool exists(int id) {
    return byId(id) != null;
  }
}
