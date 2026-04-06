import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'daos/categories_dao.dart';
import 'daos/transactions_dao.dart';
import 'daos/budgets_dao.dart';
import 'daos/settings_dao.dart';

part 'app_database.g.dart';

@DataClassName('Category')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get emoji => text()();
  TextColumn get colorHex => text()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Transaction')
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1, max: 50)();
  RealColumn get amount => real()();
  TextColumn get type => text()(); // 'expense' or 'income'
  TextColumn get categoryId => text()();
  TextColumn get note => text().nullable()();
  IntColumn get date => integer()(); // epoch ms
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  IntColumn get recurringIntervalDays => integer().nullable()();
  IntColumn get lastRecurringDate => integer().nullable()(); // epoch ms
  IntColumn get createdAt => integer()();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Budget')
class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get categoryId => text()();
  RealColumn get limitAmount => real()();
  TextColumn get period => text()(); // 'weekly' or 'monthly'
  IntColumn get startDate => integer()(); // epoch ms
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get createdAt => integer()();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AppSetting')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [Categories, Transactions, Budgets, AppSettings],
  daos: [CategoriesDao, TransactionsDao, BudgetsDao, SettingsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'fyniq.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
