// repositories/order_repository.dart
import '../models/Order.dart'; // عدّل المسار: المجلد/الاسم عندك

abstract class OrderRepository {
  List<Order> getAll();
  Order? byId(int id);
  void add(Order o);
  bool removeById(int id);
  bool update(Order o); // يستبدل الطلب المطابق لنفس id
  bool exists(int id) => byId(id) != null;
}

class InMemoryOrderRepository implements OrderRepository {
  final List<Order> _items = [];

  @override
  List<Order> getAll() => List<Order>.unmodifiable(_items);

  @override
  Order? byId(int id) {
    for (final o in _items) {
      if (o.id == id) return o;
    }
    return null;
  }

  @override
  void add(Order o) {
    _items.add(o);
  }

  @override
  bool removeById(int id) {
    final before = _items.length;
    _items.removeWhere((e) => e.id == id);
    return _items.length != before;
  }

  @override
  bool update(Order o) {
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].id == o.id) {
        _items[i] = o;
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
