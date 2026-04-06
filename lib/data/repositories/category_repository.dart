import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../database/daos/categories_dao.dart';

class CategoryRepository {
  final CategoriesDao _dao;
  final Uuid _uuid = const Uuid();

  CategoryRepository(this._dao);

  Stream<List<Category>> watchAllCategories() => _dao.watchAllCategories();

  Future<List<Category>> getAllCategories() => _dao.getAllCategories();

  Future<void> addCategory({
    required String name,
    required String emoji,
    required String colorHex,
    bool isDefault = false,
  }) async {
    final entry = CategoriesCompanion.insert(
      id: _uuid.v4(),
      name: name,
      emoji: emoji,
      colorHex: colorHex,
      isDefault: Value(isDefault),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _dao.insertCategory(entry);
  }

  Future<void> updateCategory(Category category) => _dao.updateCategory(category);

  Future<void> deleteCategory(String id) => _dao.deleteCategory(id);

  Future<void> seedDefaultCategories() => _dao.seedDefaultCategories();
}
