import '../../../../core/constants/app_constants.dart';
import '../../../categories/domain/entities/category_entity.dart';

class TransactionEntity {
  final String id;
  final TransactionType type;
  final int amountCents;
  final String categoryId;
  final CategoryEntity? category;
  final DateTime date;
  final PaymentMethod paymentMethod;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionEntity({
    required this.id,
    required this.type,
    required this.amountCents,
    required this.categoryId,
    this.category,
    required this.date,
    required this.paymentMethod,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  TransactionEntity copyWith({
    String? id,
    TransactionType? type,
    int? amountCents,
    String? categoryId,
    CategoryEntity? category,
    DateTime? date,
    PaymentMethod? paymentMethod,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      amountCents: amountCents ?? this.amountCents,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
