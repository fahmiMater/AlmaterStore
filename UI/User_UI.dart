import '../Order/Order.dart';
import '../User/User.dart';
import 'UI_Consol.dart';


import '../Category/CategoryService.dart';
import '../Order/OrderItemsServices.dart';
import '../Order/OrderServices.dart';
import '../Product/ProductService.dart';
import '../Product/product.dart';
import '../User/UserService.dart';

import '../core/app_response.dart';

class UserUi extends UiConsole{
 

    
  final Categoryservice categoryService = Categoryservice();
  final Productservice productService = Productservice();
  final Userservice userService = Userservice();
  final Orderservices orderService = Orderservices();
  final OrderItemsService orderItemsService = OrderItemsService();

  int _nextOrderId = 1;

  printMenu() {
    
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
    final exists = userService.users.any((u) => u.id == id);
    if (exists) {
      print('User with id $id already exists.');
      return;
    }
    final name = prompt('Name');
    final email = prompt('Email');
    final password = prompt('Password');
    userService.addUser(
      User(id: id, name: name, email: email, password: password),
    );
    print('User $name registered.');
  }
  
  void _listUsers() {
    if (userService.users.isEmpty) {
      print('No users registered.');
      return;
    }
    print('\nUsers:');
    for (final user in userService.users) {
      print('- ${user.id}: ${user.name} (${user.email})');
    }
  }

  
  void _listProducts() {
    final response = productService.getallProducts();
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
    for (final product in products) {
      final categoryName = product.category.name;
      print(
        '- ${product.id}: ${product.title} (\$${product.price.toStringAsFixed(2)}) '
        'Category: $categoryName',
      );
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


  void _placeOrder() {
    if (userService.users.isEmpty) {
      print('Register a user before placing orders.');
      return;
    }
    if (productService.products.isEmpty) {
      print('No products available. Ask admin to add some.');
      return;
    }
    final userId = prompt('Enter your user id');
    final user = _findUser(userId);
    if (user == null) {
      print('User not found.');
      return;
    }
    final order = Order(id: _nextOrderId++, user: user);
    print('Enter items (leave product id empty to finish):');
    while (true) {
      _listProducts();
      final productId = prompt('Product id');
      if (productId.isEmpty) {
        break;
      }
      final product = _findProduct(productId);
      if (product == null) {
        print('Product not found.');
        continue;
      }
      final quantityStr = prompt('Quantity');
      final quantity = int.tryParse(quantityStr);
      if (quantity == null || quantity <= 0) {
        print('Quantity must be a positive integer.');
        continue;
      }
      final existing = _findOrderItem(order, product.id);
      if (existing != null) {
        existing.quantity += quantity;
        orderItemsService.updateOrderItemQuantity(
          existing.product.id,
          order.id,
          existing.quantity,
        );
        print('Updated ${product.title} quantity to ${existing.quantity}.');
      } else {
        final item = Orderitem(
          id: '${order.id}-${product.id}',
          product: product,
          quantity: quantity,
          order: order,
        );
        order.items.add(item);
        orderItemsService.addOrderItem(item);
        print('Added ${product.title} x$quantity to order.');
      }
    }
    if (order.items.isEmpty) {
      print('Order cancelled (no items).');
      _nextOrderId--;
      return;
    }
    orderService.addOrder(order);
    print(
      'Order ${order.id} placed. Total: \$${order.total.toStringAsFixed(2)}',
    );
  }
  
 
  void _viewUserOrders() {
    if (orderService.orders.isEmpty) {
      print('No orders placed yet.');
      return;
    }
    final userId = prompt('Enter your user id');
    final orders = orderService.orders
        .where((order) => order.user?.id == userId)
        .toList();
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
        print(
          '  * ${item.product.title} x${item.quantity} '
          '(\$${(item.product.price * item.quantity).toStringAsFixed(2)})',
        );
      }
    }
  }
   User? _findUser(String userId) {
    for (final user in userService.users) {
      if (user.id == userId) {
        return user;
      }
    }
    return null;
  }
   Product? _findProduct(String productId) {
    for (final product in productService.products) {
      if (product.id == productId) {
        return product;
      }
    }
    return null;
  }

   Orderitem? _findOrderItem(Order order, String productId) {
    for (final item in order.items) {
      if (item.product.id == productId) {
        return item;
      }
    }
    return null;
  }
}