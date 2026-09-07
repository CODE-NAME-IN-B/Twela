import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../theme/app_colors.dart';
import '../../providers/debt_provider.dart';
import '../../models/debt.dart';

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
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

    if (person.isEmpty || description.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول')),
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
    );

    context.read<DebtProvider>().addDebt(debt);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_isGiven ? 'أعطيت مالًا لشخص' : 'استلمت مالًا من شخص'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField(
              context,
              controller: _personController,
              label: 'اسم الشخص',
              hint: 'أدخل اسم الشخص',
              icon: Icons.person_outline,
              isDark: isDark,
              theme: theme,
            ),
            const SizedBox(height: 16),
            _buildField(
              context,
              controller: _descriptionController,
              label: 'وصف الدين',
              hint: 'أدخل وصف الدين',
              icon: Icons.description_outlined,
              isDark: isDark,
              theme: theme,
            ),
            const SizedBox(height: 16),
            _buildField(
              context,
              controller: _amountController,
              label: 'المبلغ',
              hint: 'أدخل المبلغ',
              icon: Icons.money_outlined,
              keyboardType: TextInputType.number,
              isDark: isDark,
              theme: theme,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveDebt,
                child: const Text('حفظ'),
              ),
            ),
          ],
        ),
      ),
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
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
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
