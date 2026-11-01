import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/currencies.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/statement_exporter.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../domain/entities/app_settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Preferences')),
      body: settingsAsync.when(
        data: (settings) {
          return ListView(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 80,
            ),
            children: [
              const _SectionHeader(title: 'Preferences'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language_rounded),
                      title: const Text('Language / ভাষা'),
                      subtitle: Text(
                        settings.languageCode == 'bn'
                            ? 'বাংলা (Bangla)'
                            : 'English',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        _showLanguagePicker(context, ref, settings);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.currency_exchange_rounded),
                      title: const Text('Preferred Currency'),
                      subtitle: Text(
                        '${settings.currency.name} (${settings.currency.symbol})',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        _showCurrencyPicker(
                          context,
                          ref,
                          settings.currencyCode,
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.brightness_6_rounded),
                      title: const Text('App Theme'),
                      subtitle: Text(settings.themeMode.name.toUpperCase()),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        _showThemePicker(context, ref, settings.themeMode);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.account_balance_rounded),
                      title: const Text('Opening Balance'),
                      subtitle: Text(
                        CurrencyFormatter.formatCents(
                          settings.openingBalanceCents,
                          currencySymbol: settings.currency.symbol,
                        ),
                      ),
                      trailing: const Icon(Icons.edit_outlined),
                      onTap: () {
                        _showOpeningBalanceDialog(
                          context,
                          ref,
                          settings.openingBalanceCents,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const _SectionHeader(title: 'Security & Privacy'),
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.security_rounded),
                  title: const Text('App Lock'),
                  subtitle: Text(
                    settings.isAppLockEnabled
                        ? 'Fingerprint / PIN Lock Enabled'
                        : 'Protect app with Biometrics or PIN',
                  ),
                  value: settings.isAppLockEnabled,
                  onChanged: (enabled) async {
                    if (enabled) {
                      _showPinSetupDialog(context, ref, settings);
                    } else {
                      await ref
                          .read(settingsNotifierProvider.notifier)
                          .updateSettings(
                            settings.copyWith(
                              isAppLockEnabled: false,
                              appLockPin: '',
                            ),
                          );
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),

              const _SectionHeader(title: 'Management'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.category_rounded),
                      title: const Text('Manage Categories'),
                      subtitle: const Text(
                        'Customize income and expense categories',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        context.push('/categories');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const _SectionHeader(title: 'Data Export & Backup'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: Colors.red,
                      ),
                      title: const Text('Export Statement (PDF)'),
                      subtitle: const Text(
                        'Generate printable PDF financial report',
                      ),
                      onTap: () async {
                        try {
                          final txs = await ref
                              .read(transactionRepositoryProvider)
                              .getFilteredTransactions(
                                const TransactionFilter(),
                              );
                          await StatementExporter.exportPdfStatement(
                            transactions: txs,
                            settings: settings,
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('PDF Export failed: $e')),
                            );
                          }
                        }
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.table_chart_rounded,
                        color: Colors.green,
                      ),
                      title: const Text('Export Statement (Excel)'),
                      subtitle: const Text(
                        'Export transactions as .xlsx spreadsheet',
                      ),
                      onTap: () async {
                        try {
                          final txs = await ref
                              .read(transactionRepositoryProvider)
                              .getFilteredTransactions(
                                const TransactionFilter(),
                              );
                          await StatementExporter.exportExcelStatement(
                            transactions: txs,
                            settings: settings,
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Excel Export failed: $e'),
                              ),
                            );
                          }
                        }
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.delete_forever_rounded,
                        color: AppColors.expenseRed,
                      ),
                      title: const Text(
                        'Clear All Application Data',
                        style: TextStyle(color: AppColors.expenseRed),
                      ),
                      subtitle: const Text(
                        'Permanently erase all stored records',
                      ),
                      onTap: () {
                        _showClearDataSafetyModal(context, ref);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const _SectionHeader(title: 'About'),
              const Card(
                child: ListTile(
                  leading: Icon(Icons.info_outline_rounded),
                  title: Text(AppConstants.appName),
                  subtitle: Text(
                    'Version 1.0.0 • Offline First Expense Tracker',
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const AppLoadingWidget(),
        error: (err, _) => AppErrorDisplayWidget(errorMessage: err.toString()),
      ),
    );
  }

  void _showLanguagePicker(
    BuildContext context,
    WidgetRef ref,
    AppSettings currentSettings,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Language / ভাষা নির্বাচন করুন'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              trailing: currentSettings.languageCode == 'en'
                  ? const Icon(
                      Icons.check_rounded,
                      color: AppColors.incomeGreen,
                    )
                  : null,
              onTap: () async {
                await ref
                    .read(settingsNotifierProvider.notifier)
                    .updateSettings(
                      currentSettings.copyWith(languageCode: 'en'),
                    );
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              title: const Text('বাংলা (Bangla)'),
              trailing: currentSettings.languageCode == 'bn'
                  ? const Icon(
                      Icons.check_rounded,
                      color: AppColors.incomeGreen,
                    )
                  : null,
              onTap: () async {
                await ref
                    .read(settingsNotifierProvider.notifier)
                    .updateSettings(
                      currentSettings.copyWith(languageCode: 'bn'),
                    );
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPinSetupDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();
    String errorMsg = '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Set 4-Digit Security PIN'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: pinController,
                  obscureText: true,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Enter 4-Digit PIN',
                  ),
                ),
                TextField(
                  controller: confirmController,
                  obscureText: true,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Confirm 4-Digit PIN',
                  ),
                ),
                if (errorMsg.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    errorMsg,
                    style: const TextStyle(
                      color: AppColors.expenseRed,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final p1 = pinController.text.trim();
                  final p2 = confirmController.text.trim();

                  if (p1.length != 4) {
                    setState(() => errorMsg = 'PIN must be exactly 4 digits');
                    return;
                  }
                  if (p1 != p2) {
                    setState(() => errorMsg = 'PINs do not match');
                    return;
                  }

                  await ref
                      .read(settingsNotifierProvider.notifier)
                      .updateSettings(
                        settings.copyWith(
                          isAppLockEnabled: true,
                          appLockPin: p1,
                        ),
                      );
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
                child: const Text('Enable App Lock'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showClearDataSafetyModal(BuildContext context, WidgetRef ref) async {
    // Step 1 Confirmation
    final step1 = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.expenseRed),
            SizedBox(width: 8),
            Text('Erase All Data?'),
          ],
        ),
        content: const Text(
          'WARNING: This will permanently delete ALL transactions, categories, budgets, and application preferences. This action CANNOT be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expenseRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Continue to Delete'),
          ),
        ],
      ),
    );

    if (step1 != true || !context.mounted) return;

    // Step 2 Strong Double Confirmation (Typing DELETE)
    final confirmController = TextEditingController();
    final step2 = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          final text = confirmController.text.trim().toUpperCase();
          final isMatched = text == 'DELETE';

          return AlertDialog(
            title: const Text('Confirm Data Reset'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'To prevent accidental loss, please type "DELETE" below to confirm reset:',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    hintText: 'Type DELETE',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMatched
                      ? AppColors.expenseRed
                      : Colors.grey,
                  foregroundColor: Colors.white,
                ),
                onPressed: isMatched ? () => Navigator.of(ctx).pop(true) : null,
                child: const Text('Permanently Erase All Data'),
              ),
            ],
          );
        },
      ),
    );

    if (step2 == true && context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      await ref.read(settingsRepositoryProvider).clearAllAppData();
      ref.invalidate(settingsNotifierProvider);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('All application data cleared permanently.'),
        ),
      );
    }
  }

  void _showCurrencyPicker(
    BuildContext context,
    WidgetRef ref,
    String currentCode,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Currency'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: AppCurrencies.allCurrencies.length,
            itemBuilder: (context, index) {
              final c = AppCurrencies.allCurrencies[index];
              return ListTile(
                title: Text('${c.name} (${c.symbol})'),
                trailing: c.code == currentCode
                    ? const Icon(
                        Icons.check_rounded,
                        color: AppColors.incomeGreen,
                      )
                    : null,
                onTap: () async {
                  final currentSettings = await ref
                      .read(settingsRepositoryProvider)
                      .getSettings();
                  await ref
                      .read(settingsNotifierProvider.notifier)
                      .updateSettings(
                        currentSettings.copyWith(currencyCode: c.code),
                      );
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showThemePicker(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentMode,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            final isSelected = mode == currentMode;
            return ListTile(
              title: Text(mode.name.toUpperCase()),
              trailing: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: AppColors.incomeGreen,
                    )
                  : null,
              onTap: () async {
                final currentSettings = await ref
                    .read(settingsRepositoryProvider)
                    .getSettings();
                await ref
                    .read(settingsNotifierProvider.notifier)
                    .updateSettings(currentSettings.copyWith(themeMode: mode));
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showOpeningBalanceDialog(
    BuildContext context,
    WidgetRef ref,
    int currentCents,
  ) {
    final controller = TextEditingController(
      text: (currentCents / 100.0).toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Opening Balance'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Opening Balance Amount',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amt = double.tryParse(controller.text.trim()) ?? 0.0;
              final cents = CurrencyFormatter.doubleToCents(amt);
              final currentSettings = await ref
                  .read(settingsRepositoryProvider)
                  .getSettings();
              await ref
                  .read(settingsNotifierProvider.notifier)
                  .updateSettings(
                    currentSettings.copyWith(openingBalanceCents: cents),
                  );
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
