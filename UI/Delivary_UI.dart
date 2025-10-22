
import '../services/CategoryService.dart';
import '../services/OrderServices.dart';
import '../services/ProductService.dart';
import '../services/UserService.dart';
import 'UI_Consol.dart';


class DelivaryUi extends UiConsole {
  final Categoryservice categoryService = Categoryservice();
  final Productservice productService = Productservice();
  final Userservice userService = Userservice();
  final Orderservice orderService = Orderservice();

  @override
  void printMenu() {
    while (true) {
      print('\nDelivery Menu:');
      print('1) View pending orders');
      print('2) Mark order as delivered');
      print('3) View all orders');
      print('0) Back');
      final choice = prompt('Enter choice');
      switch (choice) {
        case '1':
          _listOrders(deliveredOnly: false);
          break;
        case '2':
          _markOrderDelivered();
          break;
        case '3':
          _listOrders();
          break;
        case '0':
          return;
        default:
          print('Invalid option.');
      }
    }
  }

  void _listOrders({bool? deliveredOnly}) {
    final res = orderService.getAllOrders();
    if (!res.isSuccess) {
      print('Failed to fetch orders.');
      return;
    }
    final all = res.data ?? [];
    if (all.isEmpty) {
      print('No orders available.');
      return;
    }

    final orders = all.where((order) {
      if (deliveredOnly == null) return true;
      return deliveredOnly ? order.isDelivered : !order.isDelivered;
    }).toList();

    if (orders.isEmpty) {
      final label = deliveredOnly == true ? 'delivered' : 'pending';
      print('No $label orders found.');
      return;
    }

    for (final order in orders) {
      print(
        '\nOrder ${order.id} for ${order.user?.name ?? 'Unknown'} '
        '- Total: \$${order.total.toStringAsFixed(2)} '
        '- Delivered: ${order.isDelivered ? 'Yes' : 'No'}',
      );
      for (final item in order.items) {
        print('  * ${item.product.title} x${item.quantity}');
      }
    }
  }

  void _markOrderDelivered() {
    final res = orderService.getAllOrders();
    if (!res.isSuccess || (res.data ?? []).isEmpty) {
      print('No orders available.');
      return;
    }

    final orderIdStr = prompt('Enter order id to mark delivered');
    final orderId = int.tryParse(orderIdStr);
    if (orderId == null) {
      print('Order id must be a number.');
      return;
    }

    final mark = orderService.markDelivered(orderId);
    if (!mark.isSuccess) {
      print(mark.message);
      return;
    }
    print('Order $orderId marked as delivered.');
  }
}
