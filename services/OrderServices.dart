// services/order_service.dart
import '../core/app_response.dart';
import '../models/Order.dart';
import '../repositories/order_repository.dart';
      // Order, Orderitem
import '../models/product.dart';      // Product
import '../models/User.dart';            // User

class Orderservice {
  // Singleton + Repo داخلية (يمكن استبدالها لاحقًا بتخزين حقيقي)
  static final Orderservice _instance =
      Orderservice._internal(InMemoryOrderRepository());

  final OrderRepository _repo;

  Orderservice._internal(this._repo);
  factory Orderservice() => _instance;

  // ------------------ إنشاء وحذف وقراءة ------------------

  AppResponse<Order> createOrder({
    required int id,
    User? user,
    DateTime? orderDate,
  }) {
    if (_repo.exists(id)) {
      return AppResponse.failure(
        'Order with id $id already exists.',
        code: ErrorCode.alreadyExists,
      );
    }
    final o = Order(id: id, user: user, orderDate: orderDate);
    _repo.add(o);
    return AppResponse.success(o, message: 'Order #$id created.');
  }

  AppResponse<List<Order>> getAllOrders() {
    final all = _repo.getAll();
    return AppResponse.success(
      List<Order>.unmodifiable(all),
      message: 'Fetched ${all.length} orders.',
    );
  }

  Future<AppResponse<Order>> getOrderDetails(int orderId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final o = _repo.byId(orderId);
    if (o == null) {
      return AppResponse.failure(
        'Order with id $orderId not found.',
        code: ErrorCode.notFound,
      );
    }
    return AppResponse.success(o, message: 'Order details loaded.');
  }

  AppResponse<Order> deleteOrder(int orderId) {
    final current = _repo.byId(orderId);
    if (current == null) {
      return AppResponse.failure(
        'Order with id $orderId not found.',
        code: ErrorCode.notFound,
      );
    }
    final ok = _repo.removeById(orderId);
    if (!ok) {
      return AppResponse.failure(
        'Order with id $orderId not found.',
        code: ErrorCode.notFound,
      );
    }
    return AppResponse.success(current, message: 'Order #$orderId removed.');
  }

  // ------------------ عمليات على العناصر ------------------

  /// إضافة عنصر للطلب. لو رغبت لاحقًا أن تدمج العناصر المتشابهة بدلاً من تكرارها،
  /// نقدر نعدّلها خطوة صغيرة لاحقًا.
  AppResponse<Order> addItem({
    required int orderId,
    required String itemId,
    required Product product,
    int quantity = 1,
  }) {
    if (quantity <= 0) {
      return AppResponse.failure('Quantity must be > 0.', code: ErrorCode.invalidInput);
    }

    final o = _repo.byId(orderId);
    if (o == null) {
      return AppResponse.failure(
        'Order with id $orderId not found.',
        code: ErrorCode.notFound,
      );
    }

    // تأكد من عدم تكرار نفس itemId
    final exists = o.items.any((it) => it.id == itemId);
    if (exists) {
      return AppResponse.failure(
        'Order item with id $itemId already exists in order #$orderId.',
        code: ErrorCode.alreadyExists,
      );
    }

    final item = Orderitem(id: itemId, product: product, quantity: quantity, order: o);
    o.items.add(item);

    final ok = _repo.update(o);
    if (!ok) {
      return AppResponse.failure('Failed to update order.', code: ErrorCode.unknown);
    }

    return AppResponse.success(o, message: 'Item added to order #$orderId.');
  }

  AppResponse<Order> removeItem({
    required int orderId,
    required String itemId,
  }) {
    final o = _repo.byId(orderId);
    if (o == null) {
      return AppResponse.failure(
        'Order with id $orderId not found.',
        code: ErrorCode.notFound,
      );
    }

    final before = o.items.length;
    o.items.removeWhere((it) => it.id == itemId);
    if (o.items.length == before) {
      return AppResponse.failure(
        'Order item with id $itemId not found in order #$orderId.',
        code: ErrorCode.notFound,
      );
    }

    final ok = _repo.update(o);
    if (!ok) {
      return AppResponse.failure('Failed to update order.', code: ErrorCode.unknown);
    }

    return AppResponse.success(o, message: 'Item removed from order #$orderId.');
  }

  AppResponse<Order> updateItemQuantity({
    required int orderId,
    required String itemId,
    required int quantity,
  }) {
    if (quantity <= 0) {
      return AppResponse.failure('Quantity must be > 0.', code: ErrorCode.invalidInput);
    }

    final o = _repo.byId(orderId);
    if (o == null) {
      return AppResponse.failure(
        'Order with id $orderId not found.',
        code: ErrorCode.notFound,
      );
    }

    final idx = o.items.indexWhere((it) => it.id == itemId);
    if (idx == -1) {
      return AppResponse.failure(
        'Order item with id $itemId not found in order #$orderId.',
        code: ErrorCode.notFound,
      );
    }

    o.items[idx].quantity = quantity;

    final ok = _repo.update(o);
    if (!ok) {
      return AppResponse.failure('Failed to update order.', code: ErrorCode.unknown);
    }

    return AppResponse.success(o, message: 'Item quantity updated.');
  }

  // ------------------ إسناد مستخدم وتسليم ------------------

  AppResponse<Order> assignUser({
    required int orderId,
    required User user,
  }) {
    final o = _repo.byId(orderId);
    if (o == null) {
      return AppResponse.failure(
        'Order with id $orderId not found.',
        code: ErrorCode.notFound,
      );
    }

    o.user = user;

    final ok = _repo.update(o);
    if (!ok) {
      return AppResponse.failure('Failed to update order.', code: ErrorCode.unknown);
    }

    return AppResponse.success(o, message: 'User assigned to order #$orderId.');
  }

  AppResponse<Order> markDelivered(int orderId) {
    final o = _repo.byId(orderId);
    if (o == null) {
      return AppResponse.failure(
        'Order with id $orderId not found.',
        code: ErrorCode.notFound,
      );
    }

    o.isDelivered = true;

    final ok = _repo.update(o);
    if (!ok) {
      return AppResponse.failure('Failed to update order.', code: ErrorCode.unknown);
    }

    return AppResponse.success(o, message: 'Order #$orderId marked as delivered.');
  }
}
