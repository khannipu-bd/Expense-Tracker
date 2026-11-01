import 'package:drift/drift.dart';
import 'categories_table.dart';

@DataClassName('BudgetTableData')
class BudgetsTable extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text().nullable().references(
    CategoriesTable,
    #id,
  )(); // null for overall total budget
  IntColumn get amountCents => integer()();
  TextColumn get period => text()(); // 'weekly', 'monthly'
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
