import '../../../../core/constants/app_constants.dart';

class CategoryEntity {
  final String id;
  final String name;
  final String iconName;
  final int colorValue;
  final TransactionType type;
  final bool isDefault;
  final bool isArchived;
  final DateTime createdAt;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorValue,
    required this.type,
    this.isDefault = false,
    this.isArchived = false,
    required this.createdAt,
  });

  CategoryEntity copyWith({
    String? id,
    String? name,
    String? iconName,
    int? colorValue,
    TransactionType? type,
    bool? isDefault,
    bool? isArchived,
    DateTime? createdAt,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      colorValue: colorValue ?? this.colorValue,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
