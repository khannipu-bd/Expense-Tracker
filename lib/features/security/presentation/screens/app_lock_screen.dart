import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/biometric_service.dart';

class AppLockScreen extends ConsumerStatefulWidget {
  final VoidCallback onUnlocked;

  const AppLockScreen({super.key, required this.onUnlocked});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  final BiometricService _biometricService = BiometricService();
  String _enteredPin = '';
  String _errorText = '';
  bool _canUseBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricsAndAttempt();
  }

  Future<void> _checkBiometricsAndAttempt() async {
    final isAvailable = await _biometricService.isBiometricsAvailable();
    if (mounted) {
      setState(() {
        _canUseBiometrics = isAvailable;
      });
    }

    if (isAvailable) {
      await _attemptBiometric();
    }
  }

  Future<void> _attemptBiometric() async {
    if (!_canUseBiometrics) return;
    final authenticated = await _biometricService.authenticate(
      reason: 'Unlock Hisably Expense Tracker',
    );
    if (authenticated && mounted) {
      widget.onUnlocked();
    }
  }

  void _onKeyPress(String digit) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += digit;
        _errorText = '';
      });

      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorText = '';
      });
    }
  }

  void _verifyPin() {
    final settings = ref.read(settingsNotifierProvider).value;
    final storedPin = settings?.appLockPin ?? '';

    if (storedPin.isEmpty || _enteredPin == storedPin) {
      widget.onUnlocked();
    } else {
      setState(() {
        _enteredPin = '';
        _errorText = 'Incorrect PIN. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Spacer(),
                      Icon(
                        Icons.lock_rounded,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Hisably Locked',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          _canUseBiometrics
                              ? 'Enter 4-digit PIN or use Biometrics'
                              : 'Enter your 4-digit PIN to unlock',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // PIN Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          final isFilled = index < _enteredPin.length;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isFilled
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.withValues(alpha: 0.3),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 1.5,
                              ),
                            ),
                          );
                        }),
                      ),

                      if (_errorText.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          _errorText,
                          style: const TextStyle(
                            color: AppColors.expenseRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const Spacer(),

                      // Keypad Grid
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        child: Column(
                          children: [
                            for (var row in [
                              ['1', '2', '3'],
                              ['4', '5', '6'],
                              ['7', '8', '9'],
                            ])
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: row
                                      .map((digit) => _buildKeypadButton(digit))
                                      .toList(),
                                ),
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if (_canUseBiometrics)
                                  IconButton(
                                    iconSize: 32,
                                    icon: Icon(
                                      Icons.fingerprint_rounded,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    onPressed: _attemptBiometric,
                                  )
                                else
                                  const SizedBox(width: 48, height: 48),
                                _buildKeypadButton('0'),
                                IconButton(
                                  iconSize: 28,
                                  icon: const Icon(Icons.backspace_outlined),
                                  onPressed: _onBackspace,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String digit) {
    return SizedBox(
      width: 64,
      height: 64,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          elevation: 0,
          backgroundColor: Theme.of(context).cardColor,
          foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        onPressed: () => _onKeyPress(digit),
        child: Text(
          digit,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
