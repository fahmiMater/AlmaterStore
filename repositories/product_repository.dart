// repositories/product_repository.dart

import '../models/product.dart';   // عدّل المسارات حسب مشروعك

abstract class ProductRepository {
  List<Product> getAll();
  Product? byId(int id);
  void add(Product p);
  bool removeById(int id);
  bool update(Product p);
  bool exists(int id);
}

class InMemoryProductRepository implements ProductRepository {
  final List<Product> _items = [];

  @override
  List<Product> getAll() => List<Product>.unmodifiable(_items);

  @override
  Product? byId(int id) {
    for (final p in _items) {
      if (p.id == id) return p;
    }
    return null;
  }

  @override
  void add(Product p) {
    _items.add(p);
  }

  @override
  bool removeById(int id) {
    final before = _items.length;
    _items.removeWhere((e) => e.id == id);
    return _items.length != before;
  }

  @override
  bool update(Product p) {
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].id == p.id) {
        _items[i] = p;
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
