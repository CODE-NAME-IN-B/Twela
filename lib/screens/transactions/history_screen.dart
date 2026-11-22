import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../design/format.dart';
import '../../design/motion.dart';
import '../../design/screen.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/transaction.dart';
import '../../providers/twela_provider.dart';
import '../../services/storage_service.dart';
import '../transactions/add_transaction_screen.dart';

enum TransactionFilter { all, income, expense, debt, savings }

/// السجل — the month's ledger.
///
/// Order comes from DESIGN-PLAN section C: a 36 px Arabic title with the
/// indigo count badge, a compact island for the month's net, search + filter
/// capsules, and one bordered cell frame holding day headers and borderless
/// rows. No app bar, no English label, no card inside a card.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
    this.embedded = false,
    this.bottomBarHeight = 0,
  });

  final bool embedded;
  final double bottomBarHeight;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  TransactionFilter _filter = TransactionFilter.all;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ─── data ──────────────────────────────────────────────────────────────

  List<TwelaTransaction> _filterTransactions(
    TwelaProvider provider,
    List<TwelaTransaction> transactions,
  ) {
    var filtered = transactions;

    switch (_filter) {
      case TransactionFilter.all:
        break;
      case TransactionFilter.income:
        filtered =
            filtered.where((t) => t.type == TransactionType.income).toList();
        break;
      case TransactionFilter.expense:
        filtered =
            filtered.where((t) => t.type == TransactionType.expense).toList();
        break;
      case TransactionFilter.debt:
        filtered = filtered
            .where((t) =>
                t.type == TransactionType.debtGiven ||
                t.type == TransactionType.debtReceived ||
                t.type == TransactionType.debtPayment)
            .toList();
        break;
      case TransactionFilter.savings:
        filtered = filtered
            .where((t) =>
                t.type == TransactionType.savings ||
                t.type == TransactionType.savingsWithdrawal)
            .toList();
        break;
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((t) {
        final category = provider.getCategoryById(t.categoryId);
        return t.note.toLowerCase().contains(query) ||
            (category?.name.toLowerCase().contains(query) ?? false) ||
            formatNumber(t.amount).contains(query);
      }).toList();
    }

    // Newest first: storage is add-ordered, the screen is date-ordered.
    return filtered..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Money in or out, in one place — the sign and the colour come from here.
  bool _isInflow(TwelaTransaction t) => switch (t.type) {
        TransactionType.income ||
        TransactionType.savingsWithdrawal ||
        TransactionType.debtReceived =>
          true,
        _ => false,
      };

  Color _amountColor(BuildContext context, TwelaTransaction t) {
    final sem = context.sem;
    return switch (t.type) {
      TransactionType.income => sem.income,
      TransactionType.expense => sem.expense,
      TransactionType.savings ||
      TransactionType.savingsWithdrawal =>
        sem.savings,
      _ => sem.debt,
    };
  }

  IconData _rowIcon(TwelaTransaction t) => switch (t.type) {
        TransactionType.savings ||
        TransactionType.savingsWithdrawal =>
          LucideIcons.piggyBank,
        TransactionType.debtGiven ||
        TransactionType.debtReceived ||
        TransactionType.debtPayment =>
          LucideIcons.handshake,
        _ =>
          _isInflow(t) ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight,
      };

  String _typeLabel(BuildContext context, TransactionType type) {
    final l10n = AppLocalizations.of(context)!;
    return switch (type) {
      TransactionType.income => l10n.income,
      TransactionType.expense => l10n.expenseShort,
      TransactionType.debtGiven => l10n.debtGiven,
      TransactionType.debtReceived => l10n.debtReceived,
      TransactionType.debtPayment => l10n.debtRepayment,
      TransactionType.savings => l10n.savings,
      TransactionType.savingsWithdrawal => l10n.withdrawFromSavings,
    };
  }

  String _title(TwelaProvider provider, TwelaTransaction t) {
    if (t.note.isNotEmpty) return t.note;
    final category = provider.getCategoryById(t.categoryId);
    return category?.name ?? _typeLabel(context, t.type);
  }

  // ─── actions ───────────────────────────────────────────────────────────

  void _editTransaction(TwelaTransaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(existingTransaction: transaction),
      ),
    );
  }

  /// Delete is instant and undoable — the plan retired the confirm dialog.
  Future<void> _deleteTransaction(TwelaTransaction transaction) async {
    final provider = context.read<TwelaProvider>();
    final l10n = AppLocalizations.of(context)!;
    final index = provider.transactions.indexOf(transaction);
    await provider.removeTransaction(transaction.id);
    if (!mounted) return;
    showInbToast(
      context,
      l10n.entryDeleted,
      undoLabel: l10n.undo,
      onUndo: () => provider.restoreTransaction(transaction, index: index),
    );
  }

  Future<void> _showRowMenu(TwelaTransaction transaction) async {
    final l10n = AppLocalizations.of(context)!;
    final c = context.inb;
    // AddTransactionScreen edits income and expense only.
    final editable = transaction.isExpense || transaction.isIncome;

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => InbSheet(
        title: _title(context.read<TwelaProvider>(), transaction),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (editable)
              _SheetRow(
                icon: LucideIcons.pencil,
                label: l10n.edit,
                color: c.fg,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _editTransaction(transaction);
                },
              ),
            _SheetRow(
              icon: LucideIcons.trash2,
              label: l10n.delete,
              color: context.sem.danger,
              onTap: () {
                Navigator.pop(sheetContext);
                _deleteTransaction(transaction);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final provider = context.watch<TwelaProvider>();

    final content = ColoredBox(
      color: c.paper,
      child: _body(context, provider),
    );

    if (widget.embedded) {
      return InbScreen(embedded: true, child: Reveal(child: content));
    }
    return Scaffold(
      backgroundColor: c.paper,
      body: SafeArea(child: content),
    );
  }

  Widget _body(BuildContext context, TwelaProvider provider) {
    if (provider.isLoading) return const _HistorySkeleton();
    if (provider.loadFailed) {
      final l10n = AppLocalizations.of(context)!;
      final storage = context.read<StorageService>();
      return InbErrorState(
        title: l10n.loadFailedTitle,
        subtitle: l10n.operationFailedRetry,
        retryLabel: l10n.retry,
        onRetry: () => provider.retryBoot(storage, provider.reloadData),
      );
    }

    final l10n = AppLocalizations.of(context)!;
    final transactions = _filterTransactions(provider, provider.transactions);
    final monthExpenses = _monthTotal(provider.transactions, expense: true);
    final monthIncome = _monthTotal(provider.transactions, expense: false);

    final bottomPadding = widget.embedded
        ? widget.bottomBarHeight + S.md
        : MediaQuery.of(context).padding.bottom + S.lg;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsetsDirectional.only(
          start: 20, top: 16, end: 20, bottom: bottomPadding),
      children: [
        _buildHeader(context, count: transactions.length),
        const SizedBox(height: S.md),
        _buildNetIsland(context,
            net: monthIncome - monthExpenses,
            income: monthIncome,
            expense: monthExpenses),
        const SizedBox(height: S.md),
        _buildSearchField(context),
        const SizedBox(height: S.sm),
        _buildFilters(context),
        const SizedBox(height: S.md),
        if (provider.transactions.isEmpty)
          InbEmptyState(
            icon: LucideIcons.receipt,
            title: l10n.noEntriesYet,
            subtitle: l10n.recordFirstTransaction,
            actionLabel: l10n.addTransaction,
            onAction: () => Navigator.pushNamed(context, '/add-transaction'),
          )
        else if (transactions.isEmpty)
          InbEmptyState(
            icon: LucideIcons.searchX,
            title: l10n.noSearchResults,
            subtitle: l10n.tryOtherKeywords,
          )
        else
          CellFrame(
            label: formatMonthYear(DateTime.now()),
            padding: const EdgeInsets.fromLTRB(S.md, S.md, S.md, S.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildRows(context, provider, transactions),
            ),
          ),
      ],
    );
  }

  double _monthTotal(List<TwelaTransaction> all, {required bool expense}) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    return all
        .where((t) =>
            !t.date.isBefore(start) &&
            t.type ==
                (expense ? TransactionType.expense : TransactionType.income))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Title + count badge. 36 px Arabic, no tracking, no app bar.
  Widget _buildHeader(BuildContext context, {required int count}) {
    final c = context.inb;
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Text(l10n.history, style: arabicDisplay(context, size: 36)),
        const SizedBox(width: S.sm),
        InbBadge('$count'),
        const Spacer(),
        PressScale(
          onTap: () => Navigator.pushNamed(context, '/add-transaction'),
          child: Semantics(
            button: true,
            label: l10n.addTransaction,
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(R.inner),
                border: Border.all(color: c.line),
              ),
              child: const Icon(LucideIcons.plus, size: 22),
            ),
          ),
        ),
      ],
    );
  }

  /// Compact island: the month's net, then its two directions. No 3D object
  /// here — the coin stack belongs to Home only.
  Widget _buildNetIsland(
    BuildContext context, {
    required double net,
    required double income,
    required double expense,
  }) {
    final c = context.inb;
    final l10n = AppLocalizations.of(context)!;
    return IslandCard(
      padding: const EdgeInsets.all(S.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.netMonth, style: microStyle(context, color: c.mint)),
          const SizedBox(height: S.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Money(net, size: 34, color: c.onIsland),
          ),
          const SizedBox(height: S.md),
          Row(
            children: [
              Expanded(
                child: _IslandStat(
                  label: l10n.income,
                  value: income,
                  tone: c.mint,
                ),
              ),
              const SizedBox(width: S.sm),
              Expanded(
                child: _IslandStat(
                  label: l10n.expenseShort,
                  value: -expense,
                  tone: c.onIsland,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: l10n.searchHint,
        prefixIcon: const Icon(LucideIcons.search, size: 18),
        suffixIcon: _searchQuery.isEmpty
            ? null
            : IconButton(
                icon: const Icon(LucideIcons.x, size: 18),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              ),
      ),
      onChanged: (value) => setState(() => _searchQuery = value),
    );
  }

  /// Capsules: exactly one is filled with ink (the island tone of the chip).
  Widget _buildFilters(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filters = <(TransactionFilter, String)>[
      (TransactionFilter.all, l10n.all),
      (TransactionFilter.income, l10n.income),
      (TransactionFilter.expense, l10n.expenseShort),
      (TransactionFilter.debt, l10n.debtsShort),
      (TransactionFilter.savings, l10n.savings),
    ];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: S.sm),
        itemBuilder: (context, index) {
          final (filter, label) = filters[index];
          return InbChip(
            label: label,
            selected: _filter == filter,
            onTap: () => setState(() => _filter = filter),
          );
        },
      ),
    );
  }

  /// Day headers and borderless rows, inside the one cell frame.
  List<Widget> _buildRows(
    BuildContext context,
    TwelaProvider provider,
    List<TwelaTransaction> transactions,
  ) {
    final children = <Widget>[];
    DateTime? lastDay;
    for (final t in transactions) {
      final day = DateTime(t.date.year, t.date.month, t.date.day);
      if (lastDay == null || day != lastDay) {
        children.add(_DayHeader(date: day, first: lastDay == null));
        lastDay = day;
      }
      children.add(_TransactionRow(
        transaction: t,
        title: _title(provider, t),
        subtitle: '${_typeLabel(context, t.type)} · ${formatTime(t.date)}',
        amount: _isInflow(t) ? t.amount : -t.amount,
        color: _amountColor(context, t),
        icon: _rowIcon(t),
        onMenu: () => _showRowMenu(t),
      ));
    }
    return children;
  }
}

// ─── pieces ───────────────────────────────────────────────────────────────

class _IslandStat extends StatelessWidget {
  const _IslandStat({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final double value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: microStyle(context, color: c.onIslandMuted)),
        const SizedBox(height: 2),
        Money(value, size: 15, signed: true, color: tone),
      ],
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.date, required this.first});

  final DateTime date;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    return Padding(
      padding: EdgeInsetsDirectional.only(top: first ? 0 : S.md, bottom: S.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${formatWeekday(date)} · ${formatDateLong(date)}',
              style: microStyle(context, color: c.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.transaction,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.color,
    required this.icon,
    required this.onMenu,
  });

  final TwelaTransaction transaction;
  final String title;
  final String subtitle;
  final double amount;
  final Color color;
  final IconData icon;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: S.sm),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.paper,
              shape: BoxShape.circle,
              border: Border.all(color: c.line),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: S.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: InbFonts.arabic,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: c.fg,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: InbFonts.arabic,
                    fontSize: 11,
                    color: c.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: S.sm),
          Money(amount, signed: true, size: 14, color: color),
          SizedBox(
            width: 48,
            height: 48,
            child: PressScale(
              onTap: onMenu,
              child: Semantics(
                button: true,
                label: AppLocalizations.of(context)!.edit,
                child: Icon(LucideIcons.moreVertical, size: 18, color: c.muted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            Icon(icon, size: 19, color: color),
            const SizedBox(width: S.md),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: InbFonts.arabic,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The loading state: the same layout, drawn as bones.
class _HistorySkeleton extends StatelessWidget {
  const _HistorySkeleton();

  static const _radius = BorderRadius.all(Radius.circular(R.card));

  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      child: ListView(
        padding: const EdgeInsetsDirectional.only(
            start: 20, top: 16, end: 20, bottom: S.lg),
        children: [
          const Bone.text(width: 120, fontSize: 36),
          const SizedBox(height: S.md),
          const Bone(height: 168, borderRadius: _radius),
          const SizedBox(height: S.md),
          const Bone(height: 52, borderRadius: _radius),
          const SizedBox(height: S.sm),
          Row(
            children: const [
              Expanded(child: Bone(height: 40, borderRadius: _radius)),
              SizedBox(width: S.sm),
              Expanded(child: Bone(height: 40, borderRadius: _radius)),
              SizedBox(width: S.sm),
              Expanded(child: Bone(height: 40, borderRadius: _radius)),
            ],
          ),
          const SizedBox(height: S.md),
          for (var i = 0; i < 6; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: S.sm),
              child: Bone(
                  height: 56, borderRadius: BorderRadius.circular(R.inner)),
            ),
        ],
      ),
    );
  }
}
