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
import '../../models/debt.dart';
import '../../providers/debt_provider.dart';
import '../../services/storage_service.dart';

/// Which side of the ledger the island describes: money owed **to** the user
/// (a debt they gave) or money the user **owes** (a debt they received).
enum _Side { owedToMe, iOwe }

/// الديون — the debts ledger.
///
/// Order comes from DESIGN-PLAN section D: the History title style, a compact
/// island with لي / عليّ segments, the remaining total, the paid ratio and the
/// soft orb; one cell frame per debt; and a settled section that explains
/// itself when it is empty. One filled button: «سجّل دفعة».
class DebtsScreen extends StatefulWidget {
  const DebtsScreen({
    super.key,
    this.embedded = false,
    this.bottomBarHeight = 0,
  });

  final bool embedded;
  final double bottomBarHeight;

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> {
  _Side _side = _Side.owedToMe;

  List<Debt> _active(DebtProvider provider) => provider.activeDebts
      .where((d) => d.isGiven == (_side == _Side.owedToMe))
      .toList();

  List<Debt> _paid(DebtProvider provider) => provider.paidDebts
      .where((d) => d.isGiven == (_side == _Side.owedToMe))
      .toList();

  void _openDetail(Debt debt) {
    Navigator.pushNamed(context, '/debt-detail', arguments: debt);
  }

  /// The one filled button: pick which debt gets the payment, then hand over
  /// to the detail screen that owns the money field.
  Future<void> _openPaymentPicker() async {
    final provider = context.read<DebtProvider>();
    final l10n = AppLocalizations.of(context)!;
    final debts = _active(provider);
    if (debts.isEmpty) return;

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => InbSheet(
        title: l10n.chooseDebtToPay,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final debt in debts)
              PressScale(
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openDetail(debt);
                },
                child: SizedBox(
                  height: 56,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          debt.personName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: InbFonts.arabic,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: context.inb.fg,
                          ),
                        ),
                      ),
                      const SizedBox(width: S.sm),
                      Money(debt.remaining, size: 13, color: context.sem.debt),
                      Icon(LucideIcons.chevronLeft,
                          size: 16, color: context.inb.muted),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final provider = context.watch<DebtProvider>();

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

  Widget _body(BuildContext context, DebtProvider provider) {
    if (provider.isLoading) return const _DebtsSkeleton();
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
    final active = _active(provider);
    final paid = _paid(provider);
    final bottomPadding = widget.embedded
        ? widget.bottomBarHeight + S.md
        : MediaQuery.of(context).padding.bottom + S.lg;

    if (provider.debts.isEmpty) {
      return ListView(
        padding: EdgeInsetsDirectional.only(
            start: 20, top: 16, end: 20, bottom: bottomPadding),
        children: [
          _buildHeader(context, count: 0),
          const SizedBox(height: S.lg),
          InbEmptyState(
            icon: LucideIcons.handshake,
            title: l10n.noDebts,
            subtitle: l10n.addFirstDebt,
            actionLabel: l10n.addDebt,
            onAction: () => Navigator.pushNamed(context, '/add-debt'),
          ),
        ],
      );
    }

    final totalRemaining = active.fold(0.0, (sum, d) => sum + d.remaining);
    final totalPaid = active.fold(0.0, (sum, d) => sum + d.paidAmount);
    final ratio = totalPaid + totalRemaining > 0
        ? totalPaid / (totalPaid + totalRemaining)
        : 0.0;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsetsDirectional.only(
          start: 20, top: 16, end: 20, bottom: bottomPadding),
      children: [
        _buildHeader(context, count: provider.activeDebts.length),
        const SizedBox(height: S.md),
        _buildIsland(
          context,
          remaining: totalRemaining,
          ratio: ratio,
          count: active.length,
        ),
        const SizedBox(height: S.md),
        InbButton(
          label: l10n.payDebt,
          icon: LucideIcons.wallet,
          onPressed: active.isEmpty ? null : _openPaymentPicker,
        ),
        const SizedBox(height: S.lg),
        InbSectionHeader(
          title: l10n.active,
          trailing: InbBadge('${active.length}'),
        ),
        const SizedBox(height: S.sm),
        if (active.isEmpty)
          _InlineNote(
            icon: LucideIcons.handshake,
            title: l10n.noActiveDebts,
            body: l10n.addDebtFirst,
          )
        else
          for (final debt in active) ...[
            _DebtCard(debt: debt, onTap: () => _openDetail(debt)),
            const SizedBox(height: S.sm),
          ],
        const SizedBox(height: S.lg),
        InbSectionHeader(
          title: l10n.settledDebts,
          trailing: InbBadge('${paid.length}'),
        ),
        const SizedBox(height: S.sm),
        if (paid.isEmpty)
          _InlineNote(
            icon: LucideIcons.badgeCheck,
            title: l10n.paidDebtsEmptyTitle,
            body: l10n.paidDebtsEmptyBody,
          )
        else
          for (final debt in paid) ...[
            _DebtCard(
              debt: debt,
              settled: true,
              onTap: () => _openDetail(debt),
            ),
            const SizedBox(height: S.sm),
          ],
      ],
    );
  }

  Widget _buildHeader(BuildContext context, {required int count}) {
    final c = context.inb;
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Text(l10n.debts, style: arabicDisplay(context, size: 36)),
        const SizedBox(width: S.sm),
        InbBadge('$count'),
        const Spacer(),
        PressScale(
          onTap: () => Navigator.pushNamed(context, '/add-debt'),
          child: Semantics(
            button: true,
            label: l10n.addDebt,
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

  /// Island: لي / عليّ segments → the remaining total → paid ratio, with the
  /// small soft orb. No coin stack here: Home owns that object.
  Widget _buildIsland(
    BuildContext context, {
    required double remaining,
    required double ratio,
    required int count,
  }) {
    final c = context.inb;
    final l10n = AppLocalizations.of(context)!;
    return IslandCard(
      padding: const EdgeInsets.all(S.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InbSegmentedControl<_Side>(
            segments: {
              _Side.owedToMe: l10n.owedToMe,
              _Side.iOwe: l10n.iOwe,
            },
            selected: _side,
            onIsland: true,
            onSelected: (side) => setState(() => _side = side),
          ),
          const SizedBox(height: S.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.totalRemaining,
                        style: microStyle(context, color: c.mint)),
                    const SizedBox(height: S.xs),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Money(remaining, size: 34, color: c.onIsland),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: S.md),
              // The island's one 3D object: a soft mint orb, not an icon.
              const SoftOrb(size: 64),
            ],
          ),
          const SizedBox(height: S.md),
          Row(
            children: [
              Text(l10n.percentPaid,
                  style: microStyle(context, color: c.onIslandMuted)),
              const Spacer(),
              Text(
                formatPercent(ratio),
                style: monoStyle(context, size: 13, color: c.mint),
              ),
            ],
          ),
          const SizedBox(height: S.sm),
          // The ratio again as one thin line — the single allowed ratio visual.
          ClipRRect(
            borderRadius: BorderRadius.circular(R.pill),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: c.onIsland.withValues(alpha: 0.16),
              color: c.mint,
            ),
          ),
          const SizedBox(height: S.sm),
          Text(
            '$count · ${l10n.active}',
            style: microStyle(context, color: c.onIslandMuted),
          ),
        ],
      ),
    );
  }
}

/// One debt, in its own cell frame (1 px outline + corner brackets).
class _DebtCard extends StatelessWidget {
  const _DebtCard(
      {required this.debt, required this.onTap, this.settled = false});

  final Debt debt;
  final VoidCallback onTap;
  final bool settled;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final sem = context.sem;
    final l10n = AppLocalizations.of(context)!;
    final progress =
        debt.totalAmount > 0 ? debt.paidAmount / debt.totalAmount : 0.0;
    final initial = debt.personName.trim().isEmpty
        ? '?'
        : debt.personName.trim().characters.first;

    return PressScale(
      onTap: onTap,
      child: CellFrame(
        padding: const EdgeInsets.all(S.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c.paper,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.line),
                  ),
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontFamily: InbFonts.arabic,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: c.fg,
                    ),
                  ),
                ),
                const SizedBox(width: S.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Hero(
                              tag: 'debt-${debt.id}',
                              child: Material(
                                type: MaterialType.transparency,
                                child: Text(
                                  debt.personName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: InbFonts.arabic,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: c.fg,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: S.xs),
                          if (settled)
                            Row(
                              children: [
                                Icon(LucideIcons.badgeCheck,
                                    size: 14, color: sem.income),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.paidOff,
                                  style: TextStyle(
                                    fontFamily: InbFonts.arabic,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: sem.income,
                                  ),
                                ),
                              ],
                            )
                          else
                            InbBadge(
                                debt.isGiven ? l10n.iGave : l10n.iReceived),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        debt.itemDescription,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: InbFonts.arabic,
                          fontSize: 12,
                          color: c.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: S.md),
            Row(
              children: [
                Money(
                  debt.remaining,
                  size: 20,
                  color: settled ? c.muted : sem.debt,
                ),
                const Spacer(),
                Text(
                  formatPercent(progress),
                  style: monoStyle(
                    context,
                    size: 13,
                    color: settled ? c.muted : sem.debt,
                  ),
                ),
              ],
            ),
            const SizedBox(height: S.sm),
            _SegmentBar(progress: progress, tone: settled ? c.muted : sem.debt),
            const SizedBox(height: S.sm),
            Row(
              children: [
                Text(l10n.paidAmount,
                    style: microStyle(context, color: c.muted)),
                const SizedBox(width: S.xs),
                Money(debt.paidAmount, size: 12, color: c.muted),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: S.xs),
                  child:
                      Text('·', style: TextStyle(color: c.muted, fontSize: 12)),
                ),
                Text(l10n.remaining,
                    style: microStyle(context, color: c.muted)),
                const SizedBox(width: S.xs),
                Money(debt.remaining,
                    size: 12, color: settled ? c.muted : sem.debt),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 20 segments, filling from the start side: right-to-left in Arabic, and
/// mirrored automatically in LTR because the row follows the text direction.
class _SegmentBar extends StatelessWidget {
  const _SegmentBar({required this.progress, required this.tone});

  final double progress;
  final Color tone;

  static const _segments = 20;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final filled = (progress * _segments).round().clamp(0, _segments);
    return Row(
      children: [
        for (var i = 0; i < _segments; i++) ...[
          if (i > 0) const SizedBox(width: 3),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: i < filled ? tone : c.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// A small explanatory note where a section has nothing to show yet.
class _InlineNote extends StatelessWidget {
  const _InlineNote({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    return Container(
      padding: const EdgeInsets.all(S.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(R.inner),
        border: Border.all(color: c.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: c.muted),
          const SizedBox(width: S.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: InbFonts.arabic,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: c.fg,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: TextStyle(
                    fontFamily: InbFonts.arabic,
                    fontSize: 12,
                    color: c.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DebtsSkeleton extends StatelessWidget {
  const _DebtsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      child: ListView(
        padding: const EdgeInsetsDirectional.only(
            start: 20, top: 16, end: 20, bottom: S.lg),
        children: const [
          Bone.text(width: 110, fontSize: 36),
          SizedBox(height: S.md),
          Bone(
              height: 236,
              borderRadius: BorderRadius.all(Radius.circular(R.card))),
          SizedBox(height: S.md),
          Bone(
              height: 52,
              borderRadius: BorderRadius.all(Radius.circular(R.pill))),
          SizedBox(height: S.lg),
          Bone(
              height: 168,
              borderRadius: BorderRadius.all(Radius.circular(R.card))),
          SizedBox(height: S.sm),
          Bone(
              height: 168,
              borderRadius: BorderRadius.all(Radius.circular(R.card))),
        ],
      ),
    );
  }
}
