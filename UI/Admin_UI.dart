

import '../Category/Category.dart';
import '../Category/CategoryService.dart';
import '../Order/OrderItemsServices.dart';
import '../Order/OrderServices.dart';
import '../Product/ProductService.dart';
import '../Product/product.dart';
import '../User/UserService.dart';
import 'UI_Consol.dart';
import '../core/app_response.dart';

class AdminUi extends UiConsole{

  
  final Categoryservice categoryService = Categoryservice();
  final Productservice productService = Productservice();
  final Userservice userService = Userservice();
  final Orderservices orderService = Orderservices();
  final OrderItemsService orderItemsService = OrderItemsService();
  @override
  printMenu() {
   
    while (true) {
      print('\nAdmin Menu:');
      print('1) Add category');
      print('2) List categories');
      print('3) Add product');
      print('4) List products');
      print('5) Delete product');
      print('0) Back');
      final choice = prompt('Enter choice');
      switch (choice) {
        case '1':
       
          _addCategory();
          break;
        case '2':
          _listCategories();
          break;
        case '3':
          _addProduct();
          break;
        case '4':
          _listProducts();
          break;
        case '5':
          _deleteProduct();
          break;
        case '0':
          return;
        default:
          print('Invalid option.');
      }
    }
  }
  void _addCategory() {
    final id = prompt('Category id');
    final idValue = int.tryParse(id);
    if (idValue == null) {
      print('Id must be a number.');
      return;
    }

    final name = prompt('Category name');
    if (name.isEmpty) {
      print('Name cannot be empty.');
      return;
    }

    final response = categoryService.addCategory(idValue, name);
    _printResponse(response);
  }
  void _listCategories() {
    final response = categoryService.getallCategories();
    if (!response.isSuccess) {
      _printResponse(response);
      return;
    }

    final categories = response.data ?? [];
    if (categories.isEmpty) {
      print('No categories found.');
      return;
    }

    print('\nCategories:');
    for (final category in categories) {
      print(
        '- ${category.id}: ${category.name} (Products: ${category.products.length})',
      );
    }
  }

  void _addProduct() {
    final categoryResponse = categoryService.getallCategories();
    if (!categoryResponse.isSuccess) {
      _printResponse(categoryResponse);
      return;
    }
    final categories = categoryResponse.data ?? [];
    if (categories.isEmpty) {
      print('Create a category before adding products.');
      return;
    }

    final id = prompt('Product id');
    if (id.isEmpty) {
      print('Id cannot be empty.');
      return;
    }

    final productsResponse = productService.getallProducts();
    if (productsResponse.isSuccess) {
      final exists =
          (productsResponse.data ?? []).any((product) => product.id == id);
      if (exists) {
        print('Product with id $id already exists.');
        return;
      }
    }

    final title = prompt('Product title');
    final description = prompt('Product description');
    final priceStr = prompt('Product price');
    final price = double.tryParse(priceStr);
    if (price == null || price <= 0) {
      print('Price must be a positive number.');
      return;
    }

    _listCategories();
    final categoryId = prompt('Assign to category id');
    final categoryIdValue = int.tryParse(categoryId);
    if (categoryIdValue == null) {
      print('Category id must be a number.');
      return;
    }

    Category? category;
    for (final entry in categories) {
      if (entry.id == categoryIdValue) {
        category = entry;
        break;
      }
    }

    if (category == null) {
      print('Category not found.');
      return;
    }

    final product = Product(
      id: id,
      title: title,
      description: description,
      price: price,
    );
    product.category = category;

    final response = productService.addProduct(product);
    _printResponse(response);
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

  void _deleteProduct() {
    final id = prompt('Product id to delete');
    if (id.isEmpty) {
      print('Id cannot be empty.');
      return;
    }

    final response = productService.deleteProduct(id);
    _printResponse(response);
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
