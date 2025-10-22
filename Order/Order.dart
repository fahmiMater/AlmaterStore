import '../Product/product.dart';
import '../User/User.dart';

class Order {
  final int id;
  User? user;
  final DateTime orderDate;
  final List<Orderitem> items;
  bool isDelivered;

  Order({
    required this.id,
    this.user,
    DateTime? orderDate,
    List<Orderitem>? items,
    this.isDelivered = false,
  })  : orderDate = orderDate ?? DateTime.now(),
        items = items ?? [];

  double get total {
    var sum = 0.0;
    for (final item in items) {
      sum += item.product.price * item.quantity;
    }
    return sum;
  }

  @override
  String toString() {
    final userName = user?.name ?? 'Unassigned';
    return 'Order(id: $id, user: $userName, items: ${items.length}, total: $total, delivered: $isDelivered)';
  }
}

class Orderitem {
  final String id;
  final Product product;
  int quantity;
  final Order order;

  Orderitem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.order,
  });
}
