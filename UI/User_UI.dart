import '../models/product.dart';
import '../models/User.dart';

import 'UI_Consol.dart';
import '../core/app_response.dart';
import '../services/CategoryService.dart';
import '../services/ProductService.dart'; 
import '../services/UserService.dart';
import '../services/OrderServices.dart';

class UserUi extends UiConsole {
  final Categoryservice categoryService = Categoryservice();
  final Productservice productService = Productservice();
  final Userservice userService = Userservice();
  final Orderservice orderService = Orderservice();

  int _nextOrderId = 1;

  @override
  void printMenu() {
    while (true) {
      print('\nUser Menu:');
      print('1) Register');
      print('2) List users');
      print('3) Browse products');
      print('4) Place order');
      print('5) View my orders');
      print('0) Back');
      final choice = prompt('Enter choice');
      switch (choice) {
        case '1':
          _registerUser();
          break;
        case '2':
          _listUsers();
          break;
        case '3':
          _listProducts();
          break;
        case '4':
          _placeOrder();
          break;
        case '5':
          _viewUserOrders();
          break;
        case '0':
          return;
        default:
          print('Invalid option.');
      }
    }
  }

  void _registerUser() {
    final id = prompt('User id');
    if (id.isEmpty) {
      print('Id cannot be empty.');
      return;
    }

    final existing = userService.getAllUsers();
    if (existing.isSuccess) {
      final found = (existing.data ?? []).any((u) => u.id == id);
      if (found) {
        print('User with id $id already exists.');
        return;
      }
    }

    final name = prompt('Name');
    final email = prompt('Email');
    final password = prompt('Password');

    final res = userService.addUser(
      id: id,
      name: name,
      email: email,
      password: password,
    );
    _printResponse(res);
  }

  void _listUsers() {
    final res = userService.getAllUsers();
    if (!res.isSuccess) {
      _printResponse(res);
      return;
    }
    final users = res.data ?? [];
    if (users.isEmpty) {
      print('No users registered.');
      return;
    }
    print('\nUsers:');
    for (final user in users) {
      print('- ${user.id}: ${user.name} (${user.email})');
    }
  }

  void _listProducts() {
    final response = productService.getAllProducts();
    if (!response.isSuccess) {
      _printResponse(response);
      return;
    }

    final products = response.data ?? [];
    if (products.isEmpty) {
      print('No products found.');
      return;
    }

    print('\nProducts:');
    for (final p in products) {
      final categoryName = (() {
        try { return p.category.name; } catch (_) { return '(no category)'; }
      })();
      print('- ${p.id}: ${p.title} (\$${p.price.toStringAsFixed(2)}) Category: $categoryName');
    }
  }

  void _placeOrder() {
    final usersRes = userService.getAllUsers();
    if (!usersRes.isSuccess || (usersRes.data ?? []).isEmpty) {
      print('Register a user before placing orders.');
      return;
    }
    final productsRes = productService.getAllProducts();
    if (!productsRes.isSuccess || (productsRes.data ?? []).isEmpty) {
      print('No products available. Ask admin to add some.');
      return;
    }

    final userId = prompt('Enter your user id');
    final user = (usersRes.data ?? []).firstWhere(
      (u) => u.id == userId,
      orElse: () => User(id: '', name: '', email: '', password: ''),
    );
    if (user.id.isEmpty) {
      print('User not found.');
      return;
    }

    final createRes = orderService.createOrder(id: _nextOrderId++, user: user);
    if (!createRes.isSuccess || createRes.data == null) {
      _printResponse(createRes);
      _nextOrderId--;
      return;
    }
    final order = createRes.data!;

    print('Enter items (leave product id empty to finish):');
    while (true) {
      _listProducts();
      final pidStr = prompt('Product id');
      if (pidStr.isEmpty) break;

      final productId = int.tryParse(pidStr);
      if (productId == null) {
        print('Product id must be a number.');
        continue;
      }

      final latestProducts = (productService.getAllProducts().data) ?? [];
      final p = latestProducts.firstWhere(
        (x) => x.id == productId,
        orElse: () => Product(id: -1, title: '', description: '', price: 0),
      );
      if (p.id != productId) {
        print('Product not found.');
        continue;
      }

      final quantityStr = prompt('Quantity');
      final qty = int.tryParse(quantityStr);
      if (qty == null || qty <= 0) {
        print('Quantity must be a positive integer.');
        continue;
      }

      final addItemRes = orderService.addItem(
        orderId: order.id,
        itemId: '${order.id}-${p.id}',
        product: p,
        quantity: qty,
      );
      if (!addItemRes.isSuccess) {
        _printResponse(addItemRes);
      } else {
        print('Added ${p.title} x$qty to order.');
      }
    }

    final details = orderService.getOrderDetails(order.id);
    details.then((dr) {
      if (dr.isSuccess && dr.data != null && dr.data!.items.isEmpty) {
        orderService.deleteOrder(order.id);
        print('Order cancelled (no items).');
        _nextOrderId--;
      } else {
        print('Order ${order.id} placed. Total: \$${order.total.toStringAsFixed(2)}');
      }
    });
  }

  void _viewUserOrders() {
    final ordersRes = orderService.getAllOrders();
    if (!ordersRes.isSuccess) {
      _printResponse(ordersRes);
      return;
    }
    final all = ordersRes.data ?? [];
    if (all.isEmpty) {
      print('No orders placed yet.');
      return;
    }

    final userId = prompt('Enter your user id');
    final orders = all.where((o) => o.user?.id == userId).toList();
    if (orders.isEmpty) {
      print('No orders found for user $userId.');
      return;
    }

    for (final order in orders) {
      print(
        '\nOrder ${order.id} on ${order.orderDate} '
        '- Delivered: ${order.isDelivered ? 'Yes' : 'No'} '
        '- Total: \$${order.total.toStringAsFixed(2)}',
      );
      for (final item in order.items) {
        print('  * ${item.product.title} x${item.quantity} '
              '(\$${(item.product.price * item.quantity).toStringAsFixed(2)})');
      }
    }
  }

  void _printResponse<T>(AppResponse<T> response) {
    if (response.isSuccess) {
      print(response.message);
      return;
    }
    final code = response.error != null ? ' (${response.error})' : '';
    print('Error$code: ${response.message}');
  }
}
