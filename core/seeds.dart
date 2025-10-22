// seeds/boot.dart

import '../models/product.dart';
import '../services/CategoryService.dart';
import '../services/ProductService.dart';
import '../services/UserService.dart';
import '../services/OrderServices.dart';

class SeedData {
  static final _category = Categoryservice();
  static final _product  = Productservice();
  static final _user     = Userservice();
  static final _order    = Orderservice();

  /// استدعِ هذه الدالة مرة واحدة عند بداية التشغيل
  static void bootstrap() {
    _seedCategories();
    _seedProducts();
    _seedUsers();
    _seedOrders();
  }

  // ---------------------- Helpers ----------------------

  static void _seedCategories() {
    // فئات أساسية
    _ensureCategory(1, 'Electronics');
    _ensureCategory(2, 'Groceries');
    _ensureCategory(3, 'Books');
  }

  static void _seedProducts() {
    // منتجات نموذجيّة (ملاحظة: product.id = int, categoryId = int)
    _ensureProduct(
      id: 101,
      title: 'iPhone 15',
      description: '256GB, Black',
      price: 3999.0,
      categoryId: 1,
    );
    _ensureProduct(
      id: 102,
      title: 'Laptop Pro 14"',
      description: '16GB RAM, 512GB SSD',
      price: 5299.0,
      categoryId: 1,
    );
    _ensureProduct(
      id: 201,
      title: 'Milk',
      description: 'Fresh milk 1L',
      price: 12.5,
      categoryId: 2,
    );
    _ensureProduct(
      id: 202,
      title: 'Bread',
      description: 'Whole wheat bread',
      price: 7.0,
      categoryId: 2,
    );
    _ensureProduct(
      id: 301,
      title: 'Novel',
      description: 'Bestseller fiction book',
      price: 45.0,
      categoryId: 3,
    );
  }

  static void _seedUsers() {
    _ensureUser('u1', 'Fahmi', 'fahmi@qudev.net', '1234');
    _ensureUser('u2', 'Mona',  'mona@example.com', '1234');
  }

  static void _seedOrders() {
    // طلب واحد لمستخدم u1 فيه منتجين، إن لم يكن موجودًا
    final ordersRes = _order.getAllOrders();
    final exists = (ordersRes.data ?? []).any((o) => o.id == 5001);
    if (!exists) {
      final user = _user.byId('u1');
      final created = _order.createOrder(id: 5001, user: user);
      if (!created.isSuccess || created.data == null) return;

      // نجيب قائمة المنتجات الحالية ونبحث بالـ id
      final allProducts = _product.getAllProducts().data ?? [];
      Product? p101 = allProducts.firstWhere((p) => p.id == 101, orElse: () => Product(id: -1, title: '', description: '', price: 0));
      Product? p201 = allProducts.firstWhere((p) => p.id == 201, orElse: () => Product(id: -1, title: '', description: '', price: 0));

      if (p101.id == 101) {
        _order.addItem(orderId: 5001, itemId: '5001-101', product: p101, quantity: 1);
      }
      if (p201.id == 201) {
        _order.addItem(orderId: 5001, itemId: '5001-201', product: p201, quantity: 3);
      }
    }
  }

  // ---------------------- Ensure functions ----------------------

  static void _ensureCategory(int id, String name) {
    final exists = Categoryservice().byId(id) != null;
    if (!exists) {
      _category.addCategory(id, name);
    }
  }

  static void _ensureProduct({
    required int id,
    required String title,
    required String description,
    required double price,
    required int categoryId,
  }) {
    final all = _product.getAllProducts();
    final exists = all.isSuccess && (all.data ?? []).any((p) => p.id == id);
    if (!exists) {
      _product.addProduct(
        id: id,
        title: title,
        description: description,
        price: price,
        categoryId: categoryId,
      );
    }
  }

  static void _ensureUser(String id, String name, String email, String password) {
    final all = _user.getAllUsers();
    final exists = all.isSuccess && (all.data ?? []).any((u) => u.id == id);
    if (!exists) {
      _user.addUser(id: id, name: name, email: email, password: password);
    }
  }
}
