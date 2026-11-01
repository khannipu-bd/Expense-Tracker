import 'package:flutter/material.dart';

class CategoryIconBadge extends StatelessWidget {
  final String iconName;
  final int colorValue;
  final double size;
  final double iconSize;

  const CategoryIconBadge({
    super.key,
    required this.iconName,
    required this.colorValue,
    this.size = 44,
    this.iconSize = 22,
  });

  static IconData getIconData(String name) {
    switch (name) {
      case 'restaurant':
      case 'food':
        return Icons.restaurant_rounded;
      case 'directions_car':
      case 'transport':
        return Icons.directions_car_rounded;
      case 'shopping_bag':
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'receipt_long':
      case 'bills':
        return Icons.receipt_long_rounded;
      case 'home':
      case 'rent':
        return Icons.home_rounded;
      case 'medical_services':
      case 'health':
        return Icons.medical_services_rounded;
      case 'school':
      case 'education':
        return Icons.school_rounded;
      case 'movie':
      case 'entertainment':
        return Icons.movie_rounded;
      case 'flight':
      case 'travel':
        return Icons.flight_rounded;
      case 'face':
      case 'personal':
        return Icons.face_rounded;
      case 'people':
      case 'family':
        return Icons.people_rounded;
      case 'payments':
      case 'salary':
        return Icons.payments_rounded;
      case 'work':
      case 'freelance':
        return Icons.work_rounded;
      case 'store':
      case 'business':
        return Icons.store_rounded;
      case 'trending_up':
      case 'investments':
        return Icons.trending_up_rounded;
      case 'card_giftcard':
      case 'gifts':
        return Icons.card_giftcard_rounded;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet_rounded;
      case 'more_horiz':
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(colorValue);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(getIconData(iconName), color: color, size: iconSize),
      ),
    );
  }
}
