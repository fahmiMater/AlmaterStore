import 'Category.dart';
import '../core/app_response.dart';

class Categoryservice {
  final List<Category> categories = [];

  AppResponse<Category> addCategory(int id, String name) {
    final exists = categories.any((category) => category.id == id);
    if (exists) {
      return AppResponse.failure(
        'Category with id $id already exists.',
        code: ErrorCode.alreadyExists,
      );
    }

    final category = Category(id: id, name: name);
    categories.add(category);
    return AppResponse.success(
      category,
      message: 'Category $name created.',
    );
  }

  AppResponse<List<Category>> getallCategories() {
    return AppResponse.success(
      List<Category>.unmodifiable(categories),
      message: 'Fetched ${categories.length} categories.',
    );
  }

  AppResponse<Category> deleteCategory(int categoryId) {
    final index = categories.indexWhere((category) => category.id == categoryId);
    if (index == -1) {
      return AppResponse.failure(
        'Category with id $categoryId not found.',
        code: ErrorCode.notFound,
      );
    }

    final removed = categories.removeAt(index);
    return AppResponse.success(
      removed,
      message: 'Category ${removed.name} removed.',
    );
  }

  Future<AppResponse<Category>> getCategoryDetails(int categoryId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    Category? category;
    for (final element in categories) {
      if (element.id == categoryId) {
        category = element;
        break;
      }
    }

    if (category == null) {
      return AppResponse.failure(
        'Category with id $categoryId not found.',
        code: ErrorCode.notFound,
      );
    }

    return AppResponse.success(
      category,
      message: 'Category details loaded.',
    );
  }

  Future<AppResponse<Category>> updateCategory(
    int categoryId,
    Map<String, dynamic> categoryData,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = categories.indexWhere((category) => category.id == categoryId);
    if (index == -1) {
      return AppResponse.failure(
        'Category with id $categoryId not found.',
        code: ErrorCode.notFound,
      );
    }

    final newName = categoryData['name'] as String?;
    if (newName == null || newName.trim().isEmpty) {
      return AppResponse.failure(
        'Category name is required.',
        code: ErrorCode.invalidInput,
      );
    }

    final original = categories[index];
    final updated = Category(id: original.id, name: newName.trim());
    updated.products = List.of(original.products);
    categories[index] = updated;

    return AppResponse.success(
      updated,
      message: 'Category ${updated.name} updated.',
    );
  }
}
