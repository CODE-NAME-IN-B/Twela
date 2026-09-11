import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/twela_provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../models/transaction.dart';
import '../../theme/app_colors.dart';
import '../../theme/daftar_theme.dart';
import '../../widgets/twela_design_system.dart';
import '../../widgets/wallet_toggle.dart';
import '../../widgets/category_picker.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionType? initialType;
  const AddTransactionScreen({super.key, this.initialType});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  late TransactionType _type;
  WalletType _walletType = WalletType.cash;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? TransactionType.expense;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Color get _semanticColor =>
      _type == TransactionType.expense ? AppColors.expense : AppColors.income;

  String get _title =>
      _type == TransactionType.expense ? 'إضافة صرف' : 'إضافة دخل';

  void _saveTransaction() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال مبلغ صحيح')),
      );
      return;
    }

    if (_type == TransactionType.expense && _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار التصنيف')),
      );
      return;
    }

    final transaction = TwelaTransaction(
      id: const Uuid().v4(),
      amount: amount,
      type: _type,
      walletType: _walletType,
      categoryId: _selectedCategoryId ?? '',
      note: _noteController.text,
      date: DateTime.now(),
    );

    context.read<TwelaProvider>().addTransaction(transaction);

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
      backgroundColor:
          isDark ? DaftarTheme.darkSurface : DaftarTheme.lightSurface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _title,
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TwelaSegmentedControl<TransactionType>(
                segments: const {
                  TransactionType.expense: 'صرف',
                  TransactionType.income: 'دخل',
                },
                selected: _type,
                onSelected: (type) => setState(() => _type = type),
                activeColor: _semanticColor,
              ),
              const SizedBox(height: 24),
              WalletToggle(
                selected: _walletType,
                onChanged: (type) => setState(() => _walletType = type),
              ),
              const SizedBox(height: 28),
              _buildAmountSection(isDark),
              const SizedBox(height: 28),
              if (_type == TransactionType.expense) ...[
                Text(
                  'التصنيف',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                CategoryPicker(
                  selectedId: _selectedCategoryId,
                  onSelect: (id) => setState(() => _selectedCategoryId = id),
                ),
                const SizedBox(height: 28),
              ],
              _buildNoteField(isDark),
              const SizedBox(height: 32),
              TwelaPrimaryButton(
                label: 'حفظ المعملة',
                color: _semanticColor,
                icon: Icons.check_rounded,
                onPressed: _saveTransaction,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountSection(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(TwelaRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: TwelaAmountField(
        controller: _amountController,
        accentColor: _semanticColor,
        suffixText: 'د.ل',
      ),
    );
  }

  Widget _buildNoteField(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(TwelaRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملاحظة (اختياري)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'أضف ملاحظة...',
              hintStyle: TextStyle(
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.textTertiary,
              ),
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
