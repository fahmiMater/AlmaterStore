import '../core/app_response.dart';
import 'product.dart';

class Productservice {
  final List<Product> products = [];

  AppResponse<Product> addProduct(Product product) {
    final exists = products.any((element) => element.id == product.id);
    if (exists) {
      return AppResponse.failure(
        'Product with id ${product.id} already exists.',
        code: ErrorCode.alreadyExists,
      );
    }

    final hasLink = product.category.products.any((p) => p.id == product.id);
    if (!hasLink) {
      product.category.products.add(product);
    }
    products.add(product);
    return AppResponse.success(
      product,
      message: 'Product ${product.title} added.',
    );
  }

  AppResponse<List<Product>> getallProducts() {
    return AppResponse.success(
      List<Product>.unmodifiable(products),
      message: 'Fetched ${products.length} products.',
    );
  }

  AppResponse<Product> deleteProduct(String productId) {
    final index = products.indexWhere((product) => product.id == productId);
    if (index == -1) {
      return AppResponse.failure(
        'Product with id $productId not found.',
        code: ErrorCode.notFound,
      );
    }

    final product = products.removeAt(index);
    product.category.products.removeWhere((p) => p.id == product.id);
    return AppResponse.success(
      product,
      message: 'Product ${product.title} removed.',
    );
  }

  Future<AppResponse<Product>> getProductDetails(String productId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    Product? product;
    for (final element in products) {
      if (element.id == productId) {
        product = element;
        break;
      }
    }
    if (product == null) {
      return AppResponse.failure(
        'Product with id $productId not found.',
        code: ErrorCode.notFound,
      );
    }

    return AppResponse.success(product, message: 'Product details loaded.');
  }

  Future<AppResponse<Product>> updateProduct(
    String productId,
    Map<String, dynamic> productData,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = products.indexWhere((product) => product.id == productId);
    if (index == -1) {
      return AppResponse.failure(
        'Product with id $productId not found.',
        code: ErrorCode.notFound,
      );
    }

    final current = products[index];
    final title = (productData['title'] as String?) ?? current.title;
    final description =
        (productData['description'] as String?) ?? current.description;
    final price = (productData['price'] as num?)?.toDouble() ?? current.price;

    if (price <= 0) {
      return AppResponse.failure(
        'Price must be greater than zero.',
        code: ErrorCode.invalidInput,
      );
    }

    final updated = Product(
      id: current.id,
      title: title,
      description: description,
      price: price,
    );
    updated.category = current.category;
    final idxInCategory =
        current.category.products.indexWhere((product) => product.id == current.id);
    if (idxInCategory >= 0) {
      current.category.products[idxInCategory] = updated;
    }
    products[index] = updated;

    return AppResponse.success(
      updated,
      message: 'Product ${updated.title} updated.',
    );
  }
}
