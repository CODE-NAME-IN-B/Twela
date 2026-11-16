// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get accentColor => 'Accent color';

  @override
  String get active => 'Active';

  @override
  String get activeShort => 'Active';

  @override
  String get activityLog => 'Activity log';

  @override
  String get add => 'Add';

  @override
  String get addDebt => 'Add Debt';

  @override
  String get addDebtFirst => 'Add a debt first so you can pay it off.';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get addFirstDebt => 'Add a new debt to start tracking';

  @override
  String get addIncome => 'Add Income';

  @override
  String get addNoteHint => 'Add a note...';

  @override
  String get addTransaction => 'Add transaction';

  @override
  String get alert => 'Alert';

  @override
  String get all => 'All';

  @override
  String get amount => 'Amount';

  @override
  String get amountExceedsRemaining => 'Amount is greater than the remaining';

  @override
  String get appDescription => 'Expense tracker in Libyan dinar';

  @override
  String get appSection => 'App';

  @override
  String get appTitle => 'Twela';

  @override
  String get appearance => 'Appearance';

  @override
  String get availableInGoal => 'Available in the goal';

  @override
  String get back => 'Back';

  @override
  String get backup => 'Backup';

  @override
  String get balance => 'Balance';

  @override
  String get balanceTotal => 'Total Balance';

  @override
  String get bank => 'Bank';

  @override
  String get bankWallet => 'Bank wallet';

  @override
  String get bar => 'Bar';

  @override
  String get biggestExpenses => 'Biggest expenses';

  @override
  String get borrowedMoney => 'I borrowed money';

  @override
  String get budget => 'Budget';

  @override
  String get budgetExceeded => 'You exceeded your monthly budget';

  @override
  String get budgetTitle => 'Budget';

  @override
  String get cancel => 'Cancel';

  @override
  String get cash => 'Cash';

  @override
  String get cashWallet => 'Cash wallet';

  @override
  String get category => 'Category';

  @override
  String get changesSaved => 'Changes saved';

  @override
  String get checkForUpdate => 'Check for Update';

  @override
  String get checkForUpdates => 'Check for updates';

  @override
  String get checkForUpdatesSubtitle => 'Tap to check for a new version';

  @override
  String get chooseCategory => 'Please choose a category';

  @override
  String get chooseDebtToPay => 'Choose the debt to pay';

  @override
  String get color => 'Color';

  @override
  String get completed => 'Completed';

  @override
  String get completedShort => 'Done';

  @override
  String get confirm => 'Confirm';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get confirmImport => 'Confirm import';

  @override
  String get confirmImportBody =>
      'All current data will be replaced. Are you sure?';

  @override
  String get copyData => 'Copy Data';

  @override
  String get copyDataSubtitle => 'Copy data as JSON text';

  @override
  String copyFailed(Object error) {
    return 'Copy failed: $error';
  }

  @override
  String get createGoal => 'Create goal';

  @override
  String get createGoalAction => 'Create the goal';

  @override
  String get createSavingsGoal => 'Create Savings Goal';

  @override
  String get currencyLyd => 'LYD';

  @override
  String get currentVersion => 'Current Version';

  @override
  String currentVersionIs(Object version) {
    return 'Current version: $version';
  }

  @override
  String get customization => 'Customization';

  @override
  String get daily => 'Daily';

  @override
  String get dailyAmount => 'Daily amount';

  @override
  String get dailySpendLimit => 'Daily spending limit';

  @override
  String get dark => 'Dark';

  @override
  String get data => 'Data';

  @override
  String get dataCopied => 'Data copied';

  @override
  String get dataLabel => 'Data';

  @override
  String get date => 'Date';

  @override
  String get days => 'Days';

  @override
  String daysLeftInMonth(Object daysLeft) {
    return '$daysLeft days left until the end of the month';
  }

  @override
  String daysOfTotal(Object elapsed, Object total) {
    return '$elapsed of $total days';
  }

  @override
  String daysWithYou(Object days) {
    return '$days days with you';
  }

  @override
  String get debt => 'Debt';

  @override
  String get debtDescription => 'Debt description';

  @override
  String get debtDue => 'Debt due';

  @override
  String get debtFullyPaid => 'Debt fully paid';

  @override
  String get debtGiven => 'Debt (given)';

  @override
  String get debtReceived => 'Debt (received)';

  @override
  String get debtRepayment => 'Debt repayment)';

  @override
  String debtRepaymentNote(Object name) {
    return 'Debt repayment: $name';
  }

  @override
  String get debts => 'Debts';

  @override
  String get debtsShort => 'Debts';

  @override
  String get debtDeleted => 'Debt deleted';

  @override
  String get delete => 'Delete';

  @override
  String get deleteDebt => 'Delete debt';

  @override
  String get deleteDebtBody =>
      'Are you sure you want to delete this debt? All related transactions will be deleted too.';

  @override
  String get deleteEntry => 'Delete entry';

  @override
  String get deleteGoal => 'Delete goal';

  @override
  String get deleteTransaction => 'Delete transaction';

  @override
  String get deleteTransactionBody =>
      'Are you sure you want to delete this transaction? This cannot be undone.';

  @override
  String get deposit => 'Deposit';

  @override
  String get depositRecorded => 'Deposit recorded';

  @override
  String depositToGoal(Object name) {
    return 'Deposit to $name';
  }

  @override
  String get developer => 'Developer';

  @override
  String get device => 'Device';

  @override
  String get distributionByCategory => 'Distribution by Category';

  @override
  String get done => 'Done';

  @override
  String get downloading => 'Downloading';

  @override
  String get durationDaysLabel => 'Duration (days)';

  @override
  String get durationLabel => 'Duration (days)';

  @override
  String get edit => 'Edit';

  @override
  String get editGoal => 'Edit goal';

  @override
  String get emptyStats => 'Not Enough Data';

  @override
  String get enable => 'Enable';

  @override
  String get enabledAutomatically => 'Enabled automatically';

  @override
  String get enterAmount => 'Enter the amount';

  @override
  String get enterAmountAboveZero => 'Enter an amount greater than zero';

  @override
  String get enterAmountWithinAvailable =>
      'Enter a valid amount within what is available';

  @override
  String get enterDebtDescription => 'Enter the debt description';

  @override
  String get enterMinimum => 'Enter the minimum';

  @override
  String get enterOpeningBalance =>
      'Enter your current balance for each wallet';

  @override
  String get enterPersonName => 'Enter the person name';

  @override
  String get enterValidAmount => 'Please enter a valid amount';

  @override
  String get entryDeleted => 'Entry deleted';

  @override
  String get expense => 'Expense';

  @override
  String get expenseShort => 'Expense';

  @override
  String get export => 'Export';

  @override
  String get exportData => 'Export Data';

  @override
  String get exportDataSubtitle => 'Save a backup of all your data';

  @override
  String exportFailed(Object error) {
    return 'Export failed: $error';
  }

  @override
  String get exportImport => 'Export & import';

  @override
  String get exportImportSubtitle => 'Back up and share your data';

  @override
  String get featureHighlights => 'Features';

  @override
  String get features => 'Features';

  @override
  String get fillAllFields => 'Please fill in all fields';

  @override
  String get fillAllFieldsCorrectly => 'Please fill in all fields correctly';

  @override
  String get fillThreeFields => 'Fill the three fields with valid values';

  @override
  String get glass => 'Glass';

  @override
  String get glassMode => 'Glass mode';

  @override
  String get glassModeSubtitle => 'Semi-transparent card backgrounds';

  @override
  String get glyphBar => 'Glyph bar';

  @override
  String get glyphBarSubtitle => 'Quick info above the balance';

  @override
  String get goalCreated => 'Savings goal created';

  @override
  String get goalDeleted => 'Goal deleted';

  @override
  String get goalDeletedUndo =>
      'Goal deleted — the money went back to your wallet';

  @override
  String get goalName => 'Goal name';

  @override
  String get goalNameExample => 'Example: holiday fund';

  @override
  String get goalNotFound => 'Savings goal not found';

  @override
  String get goalNotFoundBody =>
      'It may have been deleted. Go back to the list and pick another goal.';

  @override
  String get goalPaused => 'Goal paused';

  @override
  String get goalPausedToast => 'Goal paused';

  @override
  String get goalResumed => 'Goal resumed';

  @override
  String get goalWasCreated => 'Goal created';

  @override
  String get hapticOnSave => 'Haptics on save';

  @override
  String get hapticOnSaveSubtitle =>
      'A light tick when any transaction is added';

  @override
  String get haptics => 'Haptics';

  @override
  String get history => 'History';

  @override
  String get home => 'Home';

  @override
  String get iGave => 'I gave';

  @override
  String get iReceived => 'I received';

  @override
  String get import => 'Import';

  @override
  String get importData => 'Import Data';

  @override
  String get importDataSubtitle => 'Restore data from a backup';

  @override
  String importFailed(Object error) {
    return 'Import failed: $error';
  }

  @override
  String get importSucceeded => 'Import successful';

  @override
  String get importWarning =>
      'All current data will be replaced when importing. Make sure to create a backup first.';

  @override
  String get income => 'Income';

  @override
  String get installing => 'Installing';

  @override
  String get invalidFile => 'Invalid file';

  @override
  String get isCompleted => 'Completed';

  @override
  String get later => 'Later';

  @override
  String get learning => 'Learning';

  @override
  String get learningFromYou => 'Learning from you';

  @override
  String get lentMoney => 'I lent money';

  @override
  String get light => 'Light';

  @override
  String get limit => 'Limit';

  @override
  String get loading => 'Loading...';

  @override
  String get low => 'Low';

  @override
  String get lowBalanceAlert => 'Low balance alert';

  @override
  String get month => 'Month';

  @override
  String monthSummary(Object month) {
    return 'Summary of $month';
  }

  @override
  String get monthly => 'Monthly';

  @override
  String get monthlySummary => 'Monthly Summary';

  @override
  String get monthlyTotalLimit => 'Total monthly limit';

  @override
  String get moodDawn => 'Dawn is calling';

  @override
  String get moodEvening => 'Active evening';

  @override
  String get moodGoodEvening => 'Good evening';

  @override
  String get moodMorning => 'Active morning';

  @override
  String get moodNiceEvening => 'Beautiful evening';

  @override
  String get moodNoon => 'Perfect noon';

  @override
  String get moodRest => 'Time to rest';

  @override
  String get name => 'Name';

  @override
  String get nameExample => 'Example: summer holiday';

  @override
  String get newGoal => 'New goal';

  @override
  String get newVersion => 'New Version';

  @override
  String newVersionAvailable(Object version) {
    return 'New version: $version';
  }

  @override
  String get noActiveDebts => 'No active debts';

  @override
  String get noDebts => 'No Debts';

  @override
  String get noDepositsYet => 'No deposits yet';

  @override
  String get noEntriesYet => 'No activity yet';

  @override
  String get noEntriesYetBody =>
      'Start saving daily and the activity will show up here.';

  @override
  String get noGoalsYet => 'You have no savings goal yet';

  @override
  String get noGoalsYetBody => 'Create a goal to save money every day';

  @override
  String get noNewNotifications => 'No new notifications';

  @override
  String get noPatterns => 'No patterns yet';

  @override
  String get noSearchResults => 'No search results';

  @override
  String get note => 'Note';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get ofGoal => 'of goal';

  @override
  String ofTotalDays(Object total) {
    return 'of $total days';
  }

  @override
  String get openingBalance => 'Opening balance';

  @override
  String get operationFailedRetry => 'The operation failed, try again';

  @override
  String get optional => 'Optional';

  @override
  String get paid => 'Paid';

  @override
  String get paidAmount => 'Paid';

  @override
  String get patternsSubtitle => 'Detects recurring patterns and suggests them';

  @override
  String get pause => 'Pause';

  @override
  String get pausedShort => 'Paused';

  @override
  String get pausedTemporarily => 'Paused';

  @override
  String get payment => 'Payment';

  @override
  String get paymentAdded => 'Payment added';

  @override
  String get paymentHistory => 'Payment history';

  @override
  String percentComplete(Object percent) {
    return '$percent% complete';
  }

  @override
  String get personName => 'Person name';

  @override
  String get personalization => 'Personalization';

  @override
  String get projects => 'Projects';

  @override
  String get projectsSubtitle => 'A variety of open-source projects';

  @override
  String get quickActions => 'Quick actions';

  @override
  String reachedPercentOfBudget(Object percent) {
    return 'You reached $percent% of your budget';
  }

  @override
  String get recordFirstTransaction => 'Record your first expense or income';

  @override
  String get recordPayment => 'Record payment';

  @override
  String get releaseNotes => 'Release Notes';

  @override
  String get releaseNotesHeader => 'Release notes:';

  @override
  String get remaining => 'Remaining';

  @override
  String get remindLater => 'Remind Me Later';

  @override
  String get resume => 'Resume';

  @override
  String get returnedToWallet => 'Amount returned to your wallet';

  @override
  String get routineSettings => 'Routine settings';

  @override
  String get save => 'Save';

  @override
  String get saveAction => 'Save';

  @override
  String get saveAndContinue => 'Save & Continue';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get saveNow => 'Save now';

  @override
  String get saveSettings => 'Save settings';

  @override
  String get saveTransaction => 'Save transaction';

  @override
  String get savedSoFar => 'Saved so far';

  @override
  String get savings => 'Savings';

  @override
  String get savingsGoal => 'Savings Goal';

  @override
  String get savingsLog => 'Savings log';

  @override
  String get searchHint => 'Search...';

  @override
  String get searchSettings => 'Search settings...';

  @override
  String get setAmountAndTime => 'Set the amount and the time';

  @override
  String get settings => 'Settings';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get share => 'Share';

  @override
  String get shareAsFile => 'Share as File';

  @override
  String get shareAsFileSubtitle => 'Share data as JSON file';

  @override
  String shareFailed(Object error) {
    return 'Sharing failed: $error';
  }

  @override
  String get skip => 'Skip';

  @override
  String get spent => 'Spent';

  @override
  String spentPercentOfBudget(Object percent) {
    return 'You spent $percent% of your budget';
  }

  @override
  String get spentToday => 'Spent today';

  @override
  String get start => 'Start';

  @override
  String get startTrackingExpenses =>
      'Start tracking expenses to see statistics';

  @override
  String get stats => 'Stats';

  @override
  String get suggestions => 'Suggestions';

  @override
  String get tagline => 'Track your expenses in Libyan dinar';

  @override
  String timesRepeated(Object count) {
    return '$count times';
  }

  @override
  String get today => 'Today';

  @override
  String get total => 'Total';

  @override
  String get totalTarget => 'Total target';

  @override
  String get trackExpensesLibya =>
      'Track your expenses easily\nin Libyan Dinar';

  @override
  String get transferToDebt => 'Transfer to debt';

  @override
  String get transferToTheDebt => 'Transfer to the debt';

  @override
  String get transferredToDebt => 'Amount transferred to the debt';

  @override
  String get tryOtherKeywords => 'Try searching with other words';

  @override
  String get twelaBackup => 'Twela backup';

  @override
  String get undo => 'Undo';

  @override
  String get unknown => 'Unknown';

  @override
  String get unspecified => 'Not specified';

  @override
  String get update => 'Update';

  @override
  String get updateAvailable => 'Update Available';

  @override
  String get updateNow => 'Update Now';

  @override
  String get updateReady => 'Update ready';

  @override
  String get version => 'Version';

  @override
  String get wallet => 'Wallet';

  @override
  String get welcomeSubtitle => 'Track your expenses easily\\nin Libyan dinar';

  @override
  String get welcomeToTwela => '';

  @override
  String get withdraw => 'Withdraw';

  @override
  String get withdrawFromGoal => 'Withdraw from the goal';

  @override
  String get withdrawFromSavings => 'Withdraw from savings';

  @override
  String get withdrawToWallet => 'Withdraw to wallet';

  @override
  String get withdrawal => 'Withdrawal';

  @override
  String withinDays(Object duration) {
    return 'within $duration days';
  }

  @override
  String get youAreUpToDate => 'You are using the latest version';

  @override
  String get yourGoal => 'Your goal';
}
