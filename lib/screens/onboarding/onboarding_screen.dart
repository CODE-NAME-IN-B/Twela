import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../design/motion.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../models/wallet_settings.dart';
import '../../providers/twela_provider.dart';
import '../../services/notification_service.dart';
import '../../services/storage_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/motivational_messages.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../design/format.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _cashController = TextEditingController(text: '0');
  final _bankController = TextEditingController(text: '0');
  final _pageController = PageController();

  @override
  void dispose() {
    _cashController.dispose();
    _bankController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    if (await Permission.notification.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: Motion.base,
      curve: Motion.emphasized,
    );
  }

  void _completeOnboarding() async {
    final cash = double.tryParse(_cashController.text) ?? 0;
    final bank = double.tryParse(_bankController.text) ?? 0;

    final provider = context.read<TwelaProvider>();
    provider.updateWalletSettings(WalletSettings(
      initialCashBalance: cash,
      initialBankBalance: bank,
    ));

    final storage = context.read<StorageService>();
    await storage.setOnboardingComplete(true);

    await _requestPermissions();
    await NotificationService.init();

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  String get _logoAsset {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? 'assets/logo/twela_logo_mono.png'
        : 'assets/logo/twela_logo.png';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Reveal(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (_) {},
                  children: [
                    _buildWelcomePage(),
                    _buildBalancePage(),
                    _buildPreviewPage(),
                  ],
                ),
              ),
              // Pixel wordmark footer.
              Padding(
                padding: const EdgeInsets.only(bottom: S.md),
                child: Text(
                  'TWELA',
                  style: pixelStyle(context, color: context.inb.muted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    final c = context.inb;
    final message = getRandomMotivationalMessage();

    return Padding(
      padding: const EdgeInsets.all(S.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipOval(
            child: Padding(
              padding: const EdgeInsets.all(S.md),
              child: Image.asset(
                _logoAsset,
                width: 88,
                height: 88,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: S.lg),
          CoinStack(size: 80),
          const SizedBox(height: S.xl),
          Text(
            AppLocalizations.of(context)!.welcomeToTwela,
            style: arabicDisplay(context, size: 32),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: S.sm),
          Text(
            AppLocalizations.of(context)!.welcomeSubtitle,
            style: TextStyle(
              fontFamily: InbFonts.arabic,
              fontSize: 16,
              height: 1.6,
              color: c.muted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: S.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: S.md, vertical: S.sm + 2),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(R.inner),
              border: Border.all(color: c.line, width: 1),
            ),
            child: Text(
              message,
              style: TextStyle(
                fontFamily: InbFonts.arabic,
                fontSize: 12,
                height: 1.6,
                color: c.muted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: S.xl),
          InbButton(
            label: AppLocalizations.of(context)!.start,
            onPressed: _nextPage,
          ),
        ],
      ),
    );
  }

  Widget _buildBalancePage() {
    final c = context.inb;
    return Padding(
      padding: const EdgeInsets.all(S.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.openingBalance,
            style: arabicDisplay(context, size: 32),
          ),
          const SizedBox(height: S.sm),
          Text(
            AppLocalizations.of(context)!.enterOpeningBalance,
            style: TextStyle(
              fontFamily: InbFonts.arabic,
              fontSize: 14,
              color: c.muted,
            ),
          ),
          const SizedBox(height: S.xl),
          _buildBalanceField(
            controller: _cashController,
            icon: Icons.money_outlined,
            label: AppLocalizations.of(context)!.cashWallet,
          ),
          const SizedBox(height: S.md),
          _buildBalanceField(
            controller: _bankController,
            icon: Icons.account_balance_outlined,
            label: AppLocalizations.of(context)!.bankWallet,
          ),
          const SizedBox(height: S.xl),
          InbButton(
            label: AppLocalizations.of(context)!.saveAndContinue,
            onPressed: _nextPage,
          ),
        ],
      ),
    );
  }

  /// A live preview of the app's three data cells before the first entry.
  Widget _buildPreviewPage() {
    final c = context.inb;
    final l = AppLocalizations.of(context)!;

    Widget row({
      required IconData icon,
      required String title,
      required String label,
      required double amount,
      required Color amountColor,
    }) {
      return CellFrame(
        label: title,
        padding: const EdgeInsets.all(S.md),
        child: Row(
          children: [
            Icon(icon, size: 18, color: c.muted),
            const SizedBox(width: S.sm),
            Text(
              label,
              style: TextStyle(
                fontFamily: InbFonts.arabic,
                fontSize: 14,
                color: c.fg,
              ),
            ),
            const Spacer(),
            Money(
              amount,
              size: 14,
              signed: amount < 0,
              color: amountColor,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(S.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l.appDescription,
            style: arabicDisplay(context, size: 28),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: S.lg),
          row(
            icon: Icons.swap_horiz_rounded,
            title: l.activityLog,
            label: l.expenseShort,
            amount: -18,
            amountColor: AppColors.expense,
          ),
          const SizedBox(height: S.md),
          row(
            icon: Icons.people_outline_rounded,
            title: l.debts,
            label: l.iReceived,
            amount: 250,
            amountColor: AppColors.income,
          ),
          const SizedBox(height: S.md),
          row(
            icon: Icons.savings_outlined,
            title: l.savingsGoal,
            label: l.savedSoFar,
            amount: 120,
            amountColor: AppColors.savings,
          ),
          const SizedBox(height: S.xl),
          InbButton(
            label: l.done,
            onPressed: _completeOnboarding,
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
  }) {
    final c = context.inb;

    return Container(
      padding: const EdgeInsets.all(S.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(R.card),
        border: Border.all(color: c.line, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: c.mint.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(R.inner),
            ),
            child: Icon(icon, color: c.fg, size: 22),
          ),
          const SizedBox(width: S.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: InbFonts.arabic,
                    fontSize: 12,
                    color: c.muted,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: monoStyle(context, size: 16, color: c.fg),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    suffixText: AppLocalizations.of(context)!.currencyLyd,
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintStyle: TextStyle(color: c.muted),
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
