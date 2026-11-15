import 'package:flutter/material.dart';
import '../../design/tokens.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/debt_provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../models/debt.dart';
import '../../models/transaction.dart';
import '../../widgets/wallet_toggle.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../design/motion.dart';

class AddDebtScreen extends StatefulWidget {
  const AddDebtScreen({super.key});

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final _personController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isGiven = true;
  WalletType _walletType = WalletType.cash;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['type'] == 'received') {
      _isGiven = false;
    }
  }

  @override
  void dispose() {
    _personController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveDebt() {
    final person = _personController.text.trim();
    final description = _descriptionController.text.trim();
    final amount = double.tryParse(_amountController.text);

    if (person.isEmpty ||
        description.isEmpty ||
        amount == null ||
        amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.fillAllFields)),
      );
      return;
    }

    final debt = Debt(
      id: const Uuid().v4(),
      personName: person,
      itemDescription: description,
      totalAmount: amount,
      date: DateTime.now(),
      isGiven: _isGiven,
      walletType: _walletType == WalletType.bank ? 'bank' : 'cash',
    );

    context.read<DebtProvider>().addDebt(debt);

    if (context.read<AppSettingsProvider>().hapticFeedback) {
      HapticFeedback.mediumImpact();
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_isGiven
            ? AppLocalizations.of(context)!.lentMoney
            : AppLocalizations.of(context)!.borrowedMoney),
      ),
      body: Reveal(
          child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.only(
            start: 20, top: 0, end: 20, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField(
              context,
              controller: _personController,
              label: AppLocalizations.of(context)!.personName,
              hint: AppLocalizations.of(context)!.enterPersonName,
              icon: Icons.person_outline,
              isDark: isDark,
              theme: theme,
            ),
            const SizedBox(height: 16),
            _buildField(
              context,
              controller: _descriptionController,
              label: AppLocalizations.of(context)!.debtDescription,
              hint: AppLocalizations.of(context)!.enterDebtDescription,
              icon: Icons.description_outlined,
              isDark: isDark,
              theme: theme,
            ),
            const SizedBox(height: 16),
            _buildField(
              context,
              controller: _amountController,
              label: AppLocalizations.of(context)!.amount,
              hint: AppLocalizations.of(context)!.enterAmount,
              icon: Icons.money_outlined,
              keyboardType: TextInputType.number,
              isDark: isDark,
              theme: theme,
            ),
            const SizedBox(height: 16),
            WalletToggle(
              selected: _walletType,
              onChanged: (type) => setState(() => _walletType = type),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveDebt,
                child: Text(AppLocalizations.of(context)!.save),
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    required ThemeData theme,
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.inb.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.inb.line,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, size: 20),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
