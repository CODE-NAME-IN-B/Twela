import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../design/format.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../design/widgets.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/transaction.dart';
import '../providers/twela_provider.dart';

/// The hero of the home screen: the balance on a dark island, framed in rose.
///
/// Order is fixed by the owner (DESIGN-PLAN, section B):
/// segmented pills → mint label → the giant mono number → today's in / out →
/// the ↗ notch with its doodle arrow and label, and the soft 3D coin stack
/// leaning on the left.
class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key, this.onAction});

  /// Opens the movement sheet from the island's notch button.
  final VoidCallback? onAction;

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  /// الكل / كاش / مصرف — which wallet the giant number shows.
  _Wallet _wallet = _Wallet.all;

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TwelaProvider>();
    final c = context.inb;
    final l10n = AppLocalizations.of(context)!;

    final todayIncome = provider.transactions
        .where(
          (t) =>
              _isToday(t.date) &&
              (t.type == TransactionType.income ||
                  t.type == TransactionType.savingsWithdrawal),
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final (amount, label) = switch (_wallet) {
      _Wallet.all => (provider.totalBalance, l10n.totalBalanceLabel),
      _Wallet.cash => (provider.cashBalance, l10n.cashBalanceLabel),
      _Wallet.bank => (provider.bankBalance, l10n.bankBalanceLabel),
    };

    return RoseFrame(
      child: IslandCard(
        padding: const EdgeInsetsDirectional.fromSTEB(S.lg, S.lg, S.lg, S.lg),
        notchColor: c.rose,
        onAction: widget.onAction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Segmented pills: which wallet the number describes.
            InbSegmentedControl<_Wallet>(
              segments: {
                _Wallet.all: l10n.all,
                _Wallet.cash: l10n.cash,
                _Wallet.bank: l10n.bank,
              },
              selected: _wallet,
              onIsland: true,
              onSelected: (w) => setState(() => _wallet = w),
            ),
            const SizedBox(height: S.md),
            // 2 + 3. Mint label and the giant mono number, with the soft 3D
            // coin stack leaning on the left of it.
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: microStyle(context, color: c.mint)),
                      const SizedBox(height: S.xs),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Money(
                          amount,
                          size: 48,
                          color: c.onIsland,
                          animate: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: S.sm),
                _CoinGlow(child: CoinStack(size: 72, coins: 3, tiltable: true)),
              ],
            ),
            const SizedBox(height: S.md),
            // 4. Today's two directions. The sign carries the meaning, so no
            // dark green or dark red is ever painted on the island.
            Row(
              children: [
                Expanded(
                  child: _IslandStat(
                    label: l10n.todayIncome,
                    value: todayIncome,
                    signed: true,
                    tone: c.mint,
                  ),
                ),
                const SizedBox(width: S.sm),
                Expanded(
                  child: _IslandStat(
                    label: l10n.spentToday,
                    value: -provider.todaySpent,
                    signed: true,
                    tone: c.onIsland,
                  ),
                ),
              ],
            ),
            // 5. The notch band: the doodle arrow rises to the ↗ cutout and
            // names what the button does.
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 56),
              child: SizedBox(
                height: 60,
                child: Row(
                  children: [
                    DoodleArrow(color: c.mint, width: 58, height: 34),
                    const SizedBox(width: S.sm),
                    Text(
                      l10n.allAccounts,
                      style: TextStyle(
                        fontFamily: InbFonts.arabic,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: c.onIsland,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _Wallet { all, cash, bank }

/// The mint glow the coins sit in — the island's own glow, nothing else.
class _CoinGlow extends StatelessWidget {
  const _CoinGlow({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    return Container(
      width: 92,
      height: 92,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            c.mint.withValues(alpha: 0.26),
            c.mint.withValues(alpha: 0),
          ],
        ),
      ),
      child: child,
    );
  }
}

class _IslandStat extends StatelessWidget {
  const _IslandStat({
    required this.label,
    required this.value,
    required this.signed,
    this.tone,
  });

  final String label;
  final double value;
  final bool signed;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: microStyle(context, color: c.onIslandMuted)),
        const SizedBox(height: 2),
        Money(
          value,
          size: 15,
          signed: signed,
          color: tone ?? c.onIsland,
        ),
      ],
    );
  }
}
