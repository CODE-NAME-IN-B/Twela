import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../design/donut.dart';
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

enum _Wallet { all, cash, bank }

/// One segment of the stats donut, already merged and coloured.
class StatsSegment {
  const StatsSegment({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

/// Merges a month's filtered expenses into the donut's segments.
///
/// Pure on purpose: the invariant that the headline total is exactly the sum
/// of the segments is what keeps «المصروفات» honest, and it can be tested
/// without pumping a screen. Four major categories keep their own hue and the
/// rest merge into «فئات صغيرة»; the hue follows the category's stable
/// position in the catalogue, never its rank this month.
///
/// Ten categories share four major hues, so two of them can want the same
/// one (clothing 7 and groceries 3 both land on sage). Collisions are broken
/// in catalogue order, which keeps a category's hue stable while the month's
/// top four stay the same and guarantees four distinct slices.
List<StatsSegment> buildStatsSegments({
  required List<TwelaTransaction> transactions,
  required List<String> categoryIds,
  required String Function(String id) nameOf,
  required String smallLabel,
}) {
  final byCategory = <String, double>{};
  for (final t in transactions) {
    byCategory[t.categoryId] = (byCategory[t.categoryId] ?? 0) + t.amount;
  }
  final entries = byCategory.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  int naturalOf(String id) {
    final index = categoryIds.indexOf(id);
    return index < 0 ? id.hashCode.abs() : index;
  }

  final majors = entries.take(InbCharts.majorCount).toList();
  final hueOf = <String, int>{};
  final taken = <int>{};
  final stable = [...majors]..sort((a, b) {
      final byIndex = naturalOf(a.key).compareTo(naturalOf(b.key));
      return byIndex != 0 ? byIndex : a.key.compareTo(b.key);
    });
  for (final e in stable) {
    var hue = naturalOf(e.key) % InbCharts.majorCount;
    for (var step = 0; step < InbCharts.majorCount; step++) {
      if (taken.add(hue)) break;
      hue = (hue + 1) % InbCharts.majorCount;
    }
    hueOf[e.key] = hue;
  }

  final segments = <StatsSegment>[
    for (final e in majors)
      StatsSegment(
        label: nameOf(e.key),
        value: e.value,
        color: InbCharts.palette[hueOf[e.key]!],
      ),
  ];

  final rest = entries.skip(InbCharts.majorCount);
  if (rest.isNotEmpty) {
    segments.add(StatsSegment(
      label: smallLabel,
      value: rest.fold(0.0, (sum, e) => sum + e.value),
      color: InbCharts.palette.last,
    ));
  }
  return segments;
}

/// الإحصائيات — the month's spending, as one clay object.
///
/// Every section on this screen reads from the same filtered monthly set, and
/// the headline total is the sum of the donut's own segments — that is what
/// makes the old «المصروفات 0.00» against 1,096.50 impossible to repeat.
class StatsScreen extends StatefulWidget {
  const StatsScreen({
    super.key,
    this.embedded = false,
    this.bottomBarHeight = 0,
  });

  final bool embedded;
  final double bottomBarHeight;

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  _Wallet _wallet = _Wallet.all;
  int? _selected;
  double _rotation = 0;

  void _shiftMonth(int delta) {
    final next = DateTime(_month.year, _month.month + delta);
    final now = DateTime.now();
    final current = DateTime(now.year, now.month);
    if (next.isAfter(current)) return;
    setState(() {
      _month = next;
      _selected = null;
    });
  }

  bool _inWallet(TwelaTransaction t) => switch (_wallet) {
        _Wallet.all => true,
        _Wallet.cash => t.walletType == WalletType.cash,
        _Wallet.bank => t.walletType == WalletType.bank,
      };

  /// The one filtered set every section on this screen is built from.
  List<TwelaTransaction> _expenses(TwelaProvider provider) =>
      provider.transactions
          .where((t) =>
              t.type == TransactionType.expense &&
              t.date.year == _month.year &&
              t.date.month == _month.month &&
              _inWallet(t))
          .toList();

  List<StatsSegment> _segments(
      TwelaProvider provider, List<TwelaTransaction> tx) {
    final l10n = AppLocalizations.of(context)!;
    return buildStatsSegments(
      transactions: tx,
      categoryIds: provider.categories.map((c) => c.id).toList(),
      nameOf: (id) => provider.getCategoryById(id)?.name ?? l10n.unknown,
      smallLabel: l10n.smallCategories,
    );
  }

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
    if (provider.isLoading) return const _StatsSkeleton();
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
    final tx = _expenses(provider);
    final segments = _segments(provider, tx);
    final total = segments.fold(0.0, (sum, s) => sum + s.value);
    final bottomPadding = widget.embedded
        ? widget.bottomBarHeight + S.md
        : MediaQuery.of(context).padding.bottom + S.lg;

    if (tx.isEmpty) {
      return ListView(
        padding: EdgeInsetsDirectional.only(
            start: 20, top: 16, end: 20, bottom: bottomPadding),
        children: [
          _buildHeader(context),
          const SizedBox(height: S.md),
          _buildMonthNav(context),
          const SizedBox(height: S.sm),
          _buildFilters(context),
          const SizedBox(height: S.lg),
          InbEmptyState(
            icon: LucideIcons.chartPie,
            title: l10n.noMonthExpenses,
            subtitle: l10n.noMonthExpensesBody,
            actionLabel: l10n.addExpense,
            onAction: () => Navigator.pushNamed(context, '/add-transaction'),
          ),
        ],
      );
    }

    final selected = (_selected != null && _selected! < segments.length)
        ? segments[_selected!]
        : null;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsetsDirectional.only(
          start: 20, top: 16, end: 20, bottom: bottomPadding),
      children: [
        _buildHeader(context),
        const SizedBox(height: S.md),
        _buildMonthNav(context),
        const SizedBox(height: S.sm),
        _buildFilters(context),
        const SizedBox(height: S.md),
        _buildIsland(context, segments, total, selected),
        const SizedBox(height: S.lg),
        InbSectionHeader(title: l10n.biggestCategories),
        const SizedBox(height: S.sm),
        CellFrame(
          padding: const EdgeInsets.fromLTRB(S.md, S.md, S.md, S.xs),
          child: Column(
            children: [
              for (final segment in segments)
                _CategoryRow(
                  segment: segment,
                  total: total,
                  selected: selected == segment,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final c = context.inb;
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Text(l10n.stats, style: arabicDisplay(context, size: 36)),
        const Spacer(),
        PressScale(
          onTap: () => Navigator.pushNamed(context, '/add-transaction'),
          child: Semantics(
            button: true,
            label: l10n.addExpense,
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

  /// Month navigation lives in the content (no top navigation bar).
  Widget _buildMonthNav(BuildContext context) {
    final c = context.inb;
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final atCurrent = _month.year == now.year && _month.month == now.month;
    return Row(
      children: [
        _NavArrow(
          icon: LucideIcons.chevronRight,
          tooltip: l10n.previousMonth,
          onTap: () => _shiftMonth(-1),
        ),
        Expanded(
          child: Text(
            formatMonthYear(_month),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: InbFonts.arabic,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: c.fg,
            ),
          ),
        ),
        _NavArrow(
          icon: LucideIcons.chevronLeft,
          tooltip: l10n.nextMonth,
          onTap: atCurrent ? null : () => _shiftMonth(1),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final (wallet, label) in [
            (_Wallet.all, l10n.all),
            (_Wallet.cash, l10n.cash),
            (_Wallet.bank, l10n.bank),
          ]) ...[
            InbChip(
              label: label,
              selected: _wallet == wallet,
              onTap: () => setState(() {
                _wallet = wallet;
                _selected = null;
              }),
            ),
            if (wallet != _Wallet.bank) const SizedBox(width: S.sm),
          ],
        ],
      ),
    );
  }

  /// The screen's one island: the clay donut, the total in its hole, and the
  /// legend capsules. Tap a segment or a capsule to lift it and swap the
  /// centre text; tap again to clear.
  Widget _buildIsland(
    BuildContext context,
    List<StatsSegment> segments,
    double total,
    StatsSegment? selected,
  ) {
    final c = context.inb;
    final l10n = AppLocalizations.of(context)!;
    final claySlices = [
      for (final s in segments)
        ClaySlice(label: s.label, value: s.value, color: s.color),
    ];
    final selectedIndex = selected == null ? null : segments.indexOf(selected);

    return IslandCard(
      padding: const EdgeInsets.all(S.md),
      child: Column(
        children: [
          Row(
            children: [
              Text(l10n.spentThisMonth,
                  style: microStyle(context, color: c.mint)),
              const Spacer(),
              Text(
                formatMonthYear(_month),
                style: microStyle(context, color: c.onIslandMuted),
              ),
            ],
          ),
          const SizedBox(height: S.sm),
          ClayDonut(
            size: 268,
            slices: claySlices,
            selected: selectedIndex,
            rotation: _rotation,
            onRotation: (r) => setState(() => _rotation = r),
            cutColor: c.island,
            bevelColor: c.onIsland.withValues(alpha: 0.18),
            onSelected: (index) => setState(() => _selected = index),
            center: _buildDonutCenter(context, total, selected),
          ),
          const SizedBox(height: S.xs),
          Text(
            l10n.rotateHint,
            textAlign: TextAlign.center,
            style: microStyle(context, color: c.onIslandMuted),
          ),
          const SizedBox(height: S.md),
          _Legend(
            segments: segments,
            total: total,
            selected: selected,
            onSelected: (segment) => setState(() {
              _selected =
                  selected == segment ? null : segments.indexOf(segment);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDonutCenter(
      BuildContext context, double total, StatsSegment? selected) {
    final c = context.inb;
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: 136,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            selected?.label ?? l10n.spent,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: microStyle(context, color: c.onIslandMuted),
          ),
          const SizedBox(height: S.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Money(
              selected?.value ?? total,
              size: 22,
              color: c.onIsland,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            selected == null
                ? formatMonthYear(_month)
                : formatPercent(selected.value / total),
            style: monoStyle(context, size: 11, color: c.mint),
          ),
        ],
      ),
    );
  }
}

// ─── pieces ───────────────────────────────────────────────────────────────

class _NavArrow extends StatelessWidget {
  const _NavArrow({required this.icon, required this.tooltip, this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final disabled = onTap == null;
    return PressScale(
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            size: 20,
            color: disabled ? c.line : c.fg,
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.segments,
    required this.total,
    required this.selected,
    required this.onSelected,
  });

  final List<StatsSegment> segments;
  final double total;
  final StatsSegment? selected;
  final ValueChanged<StatsSegment> onSelected;

  @override
  Widget build(BuildContext context) {
    final mid = (segments.length + 1) ~/ 2;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              for (final s in segments.take(mid))
                _LegendCapsule(
                  segment: s,
                  ratio: total > 0 ? s.value / total : 0,
                  selected: s == selected,
                  onTap: () => onSelected(s),
                ),
            ],
          ),
        ),
        if (segments.length > mid) ...[
          const SizedBox(width: S.sm),
          Expanded(
            child: Column(
              children: [
                for (final s in segments.skip(mid))
                  _LegendCapsule(
                    segment: s,
                    ratio: total > 0 ? s.value / total : 0,
                    selected: s == selected,
                    onTap: () => onSelected(s),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _LegendCapsule extends StatelessWidget {
  const _LegendCapsule({
    required this.segment,
    required this.ratio,
    required this.selected,
    required this.onTap,
  });

  final StatsSegment segment;
  final double ratio;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    return Padding(
      padding: const EdgeInsets.only(bottom: S.xs),
      child: PressScale(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Motion.fast,
          curve: Motion.emphasized,
          padding: const EdgeInsets.symmetric(horizontal: S.sm, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? segment.color.withValues(alpha: 0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(R.pill),
            border: Border.all(
              color: selected
                  ? segment.color.withValues(alpha: 0.65)
                  : c.onIsland.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: segment.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  segment.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: InbFonts.arabic,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: c.onIsland,
                  ),
                ),
              ),
              const SizedBox(width: S.xs),
              Text(
                formatPercent(ratio),
                style: monoStyle(context, size: 10, color: c.mint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.segment,
    required this.total,
    required this.selected,
  });

  final StatsSegment segment;
  final double total;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final ratio = total > 0 ? segment.value / total : 0.0;
    return AnimatedContainer(
      duration: Motion.fast,
      curve: Motion.emphasized,
      margin: const EdgeInsets.only(bottom: S.sm),
      padding: const EdgeInsets.symmetric(horizontal: S.sm, vertical: S.sm),
      decoration: BoxDecoration(
        color: selected ? segment.color.withValues(alpha: 0.12) : null,
        borderRadius: BorderRadius.circular(R.inner),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: segment.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: S.sm),
              Expanded(
                child: Text(
                  segment.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: InbFonts.arabic,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: c.fg,
                  ),
                ),
              ),
              Text(
                formatPercent(ratio),
                style: monoStyle(context, size: 11, color: c.muted),
              ),
              const SizedBox(width: S.sm),
              Money(segment.value, size: 13, color: c.fg),
            ],
          ),
          const SizedBox(height: S.sm),
          InbProgress(value: ratio, color: segment.color, height: 6),
        ],
      ),
    );
  }
}

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      child: ListView(
        padding: const EdgeInsetsDirectional.only(
            start: 20, top: 16, end: 20, bottom: S.lg),
        children: const [
          Bone.text(width: 150, fontSize: 36),
          SizedBox(height: S.md),
          Bone(
              height: 40,
              borderRadius: BorderRadius.all(Radius.circular(R.pill))),
          SizedBox(height: S.md),
          Bone(
              height: 430,
              borderRadius: BorderRadius.all(Radius.circular(R.card))),
          SizedBox(height: S.lg),
          Bone(
              height: 200,
              borderRadius: BorderRadius.all(Radius.circular(R.card))),
        ],
      ),
    );
  }
}
