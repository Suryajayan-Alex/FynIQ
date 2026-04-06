import 'package:drift/drift.dart';
import '../../../core/constants/app_constants.dart';
import '../app_database.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  Stream<List<Category>> watchAllCategories() =>
    select(categories).watch();

  Future<List<Category>> getAllCategories() =>
    select(categories).get();

  Future<void> insertCategory(CategoriesCompanion entry) =>
    into(categories).insert(entry);

  Future<void> updateCategory(Category entry) =>
    update(categories).replace(entry);

  Future<void> deleteCategory(String id) =>
    (delete(categories)..where((t) => t.id.equals(id))).go();

  Future<void> seedDefaultCategories() async {
    final existing = await getAllCategories();
    if (existing.isNotEmpty) return;
    for (final cat in AppConstants.defaultCategories) {
      await insertCategory(CategoriesCompanion.insert(
        id: cat['id'] as String,
        name: cat['name'] as String,
        emoji: cat['emoji'] as String,
        colorHex: cat['colorHex'] as String,
        isDefault: Value(cat['isDefault'] as bool),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ));
    }
  }
}
