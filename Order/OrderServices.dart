import '../core/app_response.dart';
import 'Order.dart';


class Orderservices {
  final List<Order> orders = [];
  Order? _currentOrder;

  AppResponse<Order> addOrder(Order order) {
    final exists = orders.any((element) => element.id == order.id);
    if (exists) {
      return AppResponse.failure(
        'Order with id ${order.id} already exists.',
        code: ErrorCode.conflict,
      );
    }

    orders.add(order);
    _currentOrder = order;
    return AppResponse.success(order, message: 'Order ${order.id} added.');
  }

  AppResponse<List<Order>> getAllOrders() {
    return AppResponse.success(
      List<Order>.unmodifiable(orders),
      message: 'Fetched ${orders.length} orders.',
    );
  }

  AppResponse<Order> setCurrentOrder(Order order) {
    final exists = orders.any((element) => element.id == order.id);
    if (!exists) {
      return AppResponse.failure(
        'Order with id ${order.id} not tracked.',
        code: ErrorCode.notFound,
      );
    }

    _currentOrder = order;
    return AppResponse.success(
      order,
      message: 'Current order set to ${order.id}.',
    );
  }

  AppResponse<Order> getCurrentOrder() {
    if (_currentOrder == null) {
      return AppResponse.failure(
        'No current order selected.',
        code: ErrorCode.notFound,
      );
    }

    return AppResponse.success(
      _currentOrder!,
      message: 'Current order retrieved.',
    );
  }

  AppResponse<Order> findOrder(int orderId) {
    Order? found;
    for (final order in orders) {
      if (order.id == orderId) {
        found = order;
        break;
      }
    }

    if (found == null) {
      return AppResponse.failure(
        'Order with id $orderId not found.',
        code: ErrorCode.notFound,
      );
    }

    return AppResponse.success(found, message: 'Order $orderId found.');
  }
}
