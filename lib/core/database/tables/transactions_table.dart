import 'package:drift/drift.dart';
import 'categories_table.dart';

@DataClassName('TransactionTableData')
class TransactionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()(); // 'expense' or 'income'
  IntColumn get amountCents => integer()();
  TextColumn get categoryId => text().references(CategoriesTable, #id)();
  DateTimeColumn get date => dateTime()();
  TextColumn get paymentMethod =>
      text()(); // 'cash', 'bank', 'mobileWallet', 'card'
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
