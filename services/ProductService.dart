
import '../models/Category.dart';                // للوصول لنوع Category
import 'CategoryService.dart';
import '../core/app_response.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';
       // لاستخدام Categoryservice().byId

class Productservice {
  // Singleton + Repo داخلية (يمكن تبديلها لاحقًا بدون لمس الخدمة)
  static final Productservice _instance =
      Productservice._internal(InMemoryProductRepository());

  final ProductRepository _repo;

  Productservice._internal(this._repo);
  factory Productservice() => _instance;

  // ===================== الإضافة =====================
  /// إضافة منتج جديد مع دعم تمرير category مباشرة أو عبر categoryId
  AppResponse<Product> addProduct({
    required int id,
    required String title,
    required String description,
    required double price,
    int? categoryId,
    Category? category,
  }) {
    // 1) تحقق من id فريد
    if (_repo.exists(id)) {
      return AppResponse.failure(
        'Product with id $id already exists.',
        code: ErrorCode.alreadyExists,
      );
    }

    // 2) تحقق من المدخلات الأساسية
    final t = title.trim();
    final d = description.trim();
    if (t.isEmpty) {
      return AppResponse.failure('Product title is required.', code: ErrorCode.invalidInput);
    }
    if (d.isEmpty) {
      return AppResponse.failure('Product description is required.', code: ErrorCode.invalidInput);
    }
    if (price.isNaN || price.isInfinite || price < 0) {
      return AppResponse.failure('Product price must be a non-negative number.', code: ErrorCode.invalidInput);
    }

    // 3) أنشئ المنتج
    final p = Product(
      id: id,
      title: t,
      description: d,
      price: price,
    );

    // 4) ربط التصنيف (اختياري)
    if (category != null) {
      p.category = category;
    } else if (categoryId != null) {
      final cat = Categoryservice().byId(categoryId);
      if (cat == null) {
        return AppResponse.failure('Category with id $categoryId not found.', code: ErrorCode.notFound);
      }
      p.category = cat;
    }
    // إن لم يُمرر category ولا categoryId، فلا مشكلة — الخاصية late تُضبط لاحقًا قبل الاستخدام.

    _repo.add(p);
    return AppResponse.success(
      p,
      message: 'Product "${p.title}" created.',
    );
  }

  // ===================== القراءة =====================
  AppResponse<List<Product>> getAllProducts() {
    final all = _repo.getAll();
    return AppResponse.success(
      List<Product>.unmodifiable(all),
      message: 'Fetched ${all.length} products.',
    );
  }

  Future<AppResponse<Product>> getProductDetails(int productId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final p = _repo.byId(productId);
    if (p == null) {
      return AppResponse.failure(
        'Product with id $productId not found.',
        code: ErrorCode.notFound,
      );
    }
    return AppResponse.success(
      p,
      message: 'Product details loaded.',
    );
  }

  // ===================== الحذف =====================
  AppResponse<Product> deleteProduct(int productId) {
    final current = _repo.byId(productId);
    if (current == null) {
      return AppResponse.failure(
        'Product with id $productId not found.',
        code: ErrorCode.notFound,
      );
    }
    final ok = _repo.removeById(productId);
    if (!ok) {
      return AppResponse.failure(
        'Product with id $productId not found.',
        code: ErrorCode.notFound,
      );
    }
    return AppResponse.success(
      current,
      message: 'Product "${current.title}" removed.',
    );
  }

  // ===================== التحديث =====================
  /// يقبل أي subset من الحقول التالية داخل [productData]:
  /// - 'title' (String), 'description' (String), 'price' (num/double),
  /// - 'categoryId' (int) أو 'category' (Category)
  Future<AppResponse<Product>> updateProduct(
    int productId,
    Map<String, dynamic> productData,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final original = _repo.byId(productId);
    if (original == null) {
      return AppResponse.failure(
        'Product with id $productId not found.',
        code: ErrorCode.notFound,
      );
    }

    // قراءة القيم الجديدة (أو إبقاء القديمة)
    String newTitle = (productData['title'] as String?)?.trim() ?? original.title;
    String newDesc  = (productData['description'] as String?)?.trim() ?? original.description;

    double newPrice;
    final rawPrice = productData['price'];
    if (rawPrice == null) {
      newPrice = original.price;
    } else if (rawPrice is num) {
      newPrice = rawPrice.toDouble();
    } else {
      return AppResponse.failure('Invalid price type.', code: ErrorCode.invalidInput);
    }

    if (newTitle.isEmpty) {
      return AppResponse.failure('Product title is required.', code: ErrorCode.invalidInput);
    }
    if (newDesc.isEmpty) {
      return AppResponse.failure('Product description is required.', code: ErrorCode.invalidInput);
    }
    if (newPrice.isNaN || newPrice.isInfinite || newPrice < 0) {
      return AppResponse.failure('Product price must be a non-negative number.', code: ErrorCode.invalidInput);
    }

    // بإنشاء نسخة جديدة من المنتج (نحافظ على المعرف)
    final updated = Product(
      id: original.id,
      title: newTitle,
      description: newDesc,
      price: newPrice,
    );

    // تعيين التصنيف (الأولوية لـ 'category' إن وُجد)
    if (productData.containsKey('category')) {
      final dynamic c = productData['category'];
      if (c is Category) {
        updated.category = c;
      } else {
        return AppResponse.failure('Invalid category object.', code: ErrorCode.invalidInput);
      }
    } else if (productData.containsKey('categoryId')) {
      final dynamic cid = productData['categoryId'];
      if (cid is int) {
        final cat = Categoryservice().byId(cid);
        if (cat == null) {
          return AppResponse.failure('Category with id $cid not found.', code: ErrorCode.notFound);
        }
        updated.category = cat;
      } else {
        return AppResponse.failure('Invalid categoryId type.', code: ErrorCode.invalidInput);
      }
    } else {
      // إن لم يُمرر شيء، أبقِ التصنيف القديم إن كان مضبوطًا
      try {
        updated.category = original.category;
      } catch (_) {
        // قد لا يكون مضبوطًا في الأصل — لا مشكلة، سيُضبط لاحقًا قبل الاستخدام.
      }
    }

    final ok = _repo.update(updated);
    if (!ok) {
      return AppResponse.failure(
        'Product with id $productId not found.',
        code: ErrorCode.notFound,
      );
    }

    return AppResponse.success(
      updated,
      message: 'Product "${updated.title}" updated.',
    );
  }
}
