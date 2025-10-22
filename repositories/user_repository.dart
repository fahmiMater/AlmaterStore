// repositories/user_repository.dart
import '../models/User.dart'; // عدّل المسار لو مجلدك مختلف

abstract class UserRepository {
  List<User> getAll();
  User? byId(String id);
  void add(User u);
  bool removeById(String id);
  bool update(User u);
  bool exists(String id);
}

class InMemoryUserRepository implements UserRepository {
  final List<User> _items = [];

  @override
  List<User> getAll() => List<User>.unmodifiable(_items);

  @override
  User? byId(String id) {
    for (final u in _items) {
      if (u.id == id) return u;
    }
    return null;
  }

  @override
  void add(User u) {
    _items.add(u);
  }

  @override
  bool removeById(String id) {
    final before = _items.length;
    _items.removeWhere((e) => e.id == id);
    return _items.length != before;
  }

  @override
  bool update(User u) {
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].id == u.id) {
        _items[i] = u;
        return true;
      }
    }
    return false;
  }
  
  @override
  bool exists(String id) {
    // TODO: implement exists
    return byId(id) != null;
  }
}
