import '../Product/product.dart';

class Category{
  final int id;
  final String name;
List<Product> products = [];
  Category({
    required this.id,
    required this.name,
  });

  @override
  String toString() {
    return 'Category(id: $id, name: $name)';  
  }
}