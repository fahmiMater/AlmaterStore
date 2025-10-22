import './Category.dart';

class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  late Category category;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
  });

  @override
  String toString() {
    return 'Product(id: $id, title: $title, description: $description, price: $price, category: $category)';
  }
}
