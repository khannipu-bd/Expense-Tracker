import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../constants/app_constants.dart';
import '../utils/currency_formatter.dart';

class AmountText extends StatelessWidget {
  final int amountCents;
  final String currencySymbol;
  final TransactionType? type;
  final TextStyle? style;
  final bool showSign;

  const AmountText({
    super.key,
    required this.amountCents,
    required this.currencySymbol,
    this.type,
    this.style,
    this.showSign = true,
  });

  @override
  Widget build(BuildContext context) {
    Color? color;
    if (type == TransactionType.income) {
      color = AppColors.incomeGreen;
    } else if (type == TransactionType.expense) {
      color = AppColors.expenseRed;
    }

    final formattedText = CurrencyFormatter.formatCents(
      amountCents,
      currencySymbol: currencySymbol,
      showSign: showSign && type != null,
      isExpense: type == TransactionType.expense,
    );

    final defaultStyle = Theme.of(context).textTheme.titleMedium;
    final effectiveStyle = (style ?? defaultStyle)?.copyWith(
      color: color ?? (style?.color ?? defaultStyle?.color),
      fontWeight: FontWeight.bold,
    );

    return Text(formattedText, style: effectiveStyle);
  }
}
