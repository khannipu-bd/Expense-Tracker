import 'package:drift/drift.dart';

@DataClassName('CategoryTableData')
class CategoriesTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get iconName => text()();
  IntColumn get colorValue => integer()();
  TextColumn get type => text()(); // 'expense' or 'income'
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
