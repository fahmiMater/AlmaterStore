import '../models/Category.dart';
import '../core/app_response.dart';
import '../repositories/category_repository.dart';

class Categoryservice {
  static final Categoryservice _instance =
      Categoryservice._internal(InMemoryCategoryRepository());

  final CategoryRepository _repo;

  Categoryservice._internal(this._repo);

  factory Categoryservice() => _instance;

  // ✅ الإضافة الجديدة
  /// إرجاع التصنيف حسب المعرّف (إن لم يوجد تُرجع null)
  Category? byId(int id) => _repo.byId(id);

  AppResponse<Category> addCategory(int id, String name) {
    if (_repo.exists(id)) {
      return AppResponse.failure(
        'Category with id $id already exists.',
        code: ErrorCode.alreadyExists,
      );
    }
    final category = Category(id: id, name: name);
    _repo.add(category);
    return AppResponse.success(
      category,
      message: 'Category $name created.',
    );
  }

  AppResponse<List<Category>> getallCategories() {
    final all = _repo.getAll();
    return AppResponse.success(
      List<Category>.unmodifiable(all),
      message: 'Fetched ${all.length} categories.',
    );
  }

  AppResponse<Category> deleteCategory(int categoryId) {
    final current = _repo.byId(categoryId);
    if (current == null) {
      return AppResponse.failure(
        'Category with id $categoryId not found.',
        code: ErrorCode.notFound,
      );
    }
    final ok = _repo.remove(categoryId); // ملاحظة: إن كان اسمها removeById في ريبوك، غيّرها هنا فقط
    if (!ok) {
      return AppResponse.failure(
        'Category with id $categoryId not found.',
        code: ErrorCode.notFound,
      );
    }
    return AppResponse.success(
      current,
      message: 'Category ${current.name} removed.',
    );
  }

  Future<AppResponse<Category>> getCategoryDetails(int categoryId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final category = _repo.byId(categoryId);
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

    final original = _repo.byId(categoryId);
    if (original == null) {
      return AppResponse.failure(
        'Category with id $categoryId not found.',
        code: ErrorCode.notFound,
      );
    }

    final newName = (categoryData['name'] as String?)?.trim();
    if (newName == null || newName.isEmpty) {
      return AppResponse.failure(
        'Category name is required.',
        code: ErrorCode.invalidInput,
      );
    }

    final updated = Category(id: original.id, name: newName);
    updated.products = List.of(original.products);

    final ok = _repo.update(updated);
    if (!ok) {
      return AppResponse.failure(
        'Category with id $categoryId not found.',
        code: ErrorCode.notFound,
      );
    }

    return AppResponse.success(
      updated,
      message: 'Category ${updated.name} updated.',
    );
  }
}
