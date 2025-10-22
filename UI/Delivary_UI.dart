import '../Order/Order.dart';
import 'UI_Consol.dart';


import '../Category/CategoryService.dart';
import '../Order/OrderItemsServices.dart';
import '../Order/OrderServices.dart';
import '../Product/ProductService.dart';

import '../User/UserService.dart';


class DelivaryUi extends UiConsole{

    final Categoryservice categoryService = Categoryservice();
  final Productservice productService = Productservice();
  final Userservice userService = Userservice();
  final Orderservices orderService = Orderservices();
  final OrderItemsService orderItemsService = OrderItemsService();


  @override
  printMenu() {

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
    if (orderService.orders.isEmpty) {
      print('No orders available.');
      return;
    }
    final orders = orderService.orders.where((order) {
      if (deliveredOnly == null) {
        return true;
      }
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
    if (orderService.orders.isEmpty) {
      print('No orders available.');
      return;
    }
    final orderIdStr = prompt('Enter order id to mark delivered');
    final orderId = int.tryParse(orderIdStr);
    if (orderId == null) {
      print('Order id must be a number.');
      return;
    }
    final order = _findOrder(orderId);
    if (order == null) {
      print('Order not found.');
      return;
    }
    if (order.isDelivered) {
      print('Order ${order.id} already marked delivered.');
      return;
    }
    order.isDelivered = true;
    print('Order ${order.id} marked as delivered.');
  }

  
  Order? _findOrder(int orderId) {
    for (final order in orderService.orders) {
      if (order.id == orderId) {
        return order;
      }
    }
    return null;
  }
 
}