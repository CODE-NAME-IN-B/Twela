// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get accentColor => 'لون التمييز';

  @override
  String get active => 'نشطة';

  @override
  String get activeShort => 'نشط';

  @override
  String get activityLog => 'سجل الحركة';

  @override
  String get add => 'إضافة';

  @override
  String get addDebt => 'إضافة دين';

  @override
  String get addDebtFirst => 'أضف دينًا أولًا لتتمكن من السداد منه.';

  @override
  String get addExpense => 'إضافة مصروف';

  @override
  String get addFirstDebt => 'أضف دين جديد للبدء في التتبع';

  @override
  String get addIncome => 'إضافة دخل';

  @override
  String get addNoteHint => 'أضف ملاحظة...';

  @override
  String get addTransaction => 'إضافة عملية';

  @override
  String get alert => 'تنبيه';

  @override
  String get all => 'الكل';

  @override
  String get amount => 'المبلغ';

  @override
  String get amountExceedsRemaining => 'المبلغ أكبر من المتبقي';

  @override
  String get appDescription => 'تطبيق تتبع المصاريف بالدينار الليبي';

  @override
  String get appSection => 'التطبيق';

  @override
  String get appTitle => 'تويلا';

  @override
  String get appearance => 'المظهر';

  @override
  String get availableInGoal => 'المتوفر في الحصالة';

  @override
  String get back => 'رجوع';

  @override
  String get backup => 'النسخ الاحتياطي';

  @override
  String get balance => 'رصيد';

  @override
  String get balanceTotal => 'الرصيد الإجمالي';

  @override
  String get bank => 'مصرف';

  @override
  String get bankWallet => 'محفظة المصرف';

  @override
  String get bar => 'شريط';

  @override
  String get biggestExpenses => 'أكبر المصروفات';

  @override
  String get borrowedMoney => 'استلمت مالًا من شخص';

  @override
  String get budget => 'ميزانية';

  @override
  String get budgetExceeded => 'تجاوزت ميزانيتك الشهرية';

  @override
  String get budgetTitle => 'الميزانية';

  @override
  String get cancel => 'إلغاء';

  @override
  String get cash => 'كاش';

  @override
  String get cashWallet => 'محفظة الكاش';

  @override
  String get category => 'التصنيف';

  @override
  String get changesSaved => 'تم حفظ التعديلات';

  @override
  String get checkForUpdate => 'التحقق من التحديث';

  @override
  String get checkForUpdates => 'التحقق من التحديثات';

  @override
  String get checkForUpdatesSubtitle => 'اضغط للتحقق من إصدار جديد';

  @override
  String get chooseCategory => 'يرجى اختيار التصنيف';

  @override
  String get chooseDebtToPay => 'اختر الدين المراد سداده';

  @override
  String get color => 'لون';

  @override
  String get completed => 'مكتملة';

  @override
  String get completedShort => 'مكتمل';

  @override
  String get confirm => 'تأكيد';

  @override
  String get confirmDelete => 'تأكيد الحذف';

  @override
  String get confirmImport => 'تأكيد الاستيراد';

  @override
  String get confirmImportBody =>
      'سيتم استبدال جميع البيانات الحالية. هل أنت متأكد؟';

  @override
  String get copyData => 'نسخ البيانات';

  @override
  String get copyDataSubtitle => 'نسخ البيانات كنص JSON';

  @override
  String copyFailed(Object error) {
    return 'خطأ في النسخ: $error';
  }

  @override
  String get createGoal => 'إنشاء الحصالة';

  @override
  String get createGoalAction => 'أنشئ الحصالة';

  @override
  String get createSavingsGoal => 'إنشاء حصالة';

  @override
  String get currencyLyd => 'د.ل';

  @override
  String get currentVersion => 'الإصدار الحالي';

  @override
  String currentVersionIs(Object version) {
    return 'الإصدار الحالي: $version';
  }

  @override
  String get customization => 'تخصيص';

  @override
  String get daily => 'يومي';

  @override
  String get dailyAmount => 'المبلغ اليومي';

  @override
  String get dailySpendLimit => 'حد الصرف اليومي';

  @override
  String get dark => 'داكن';

  @override
  String get data => 'البيانات';

  @override
  String get dataCopied => 'تم نسخ البيانات';

  @override
  String get dataLabel => 'بيانات';

  @override
  String get date => 'التاريخ';

  @override
  String get days => 'الأيام';

  @override
  String daysLeftInMonth(Object daysLeft) {
    return 'بقي $daysLeft يوم على نهاية الشهر';
  }

  @override
  String daysOfTotal(Object elapsed, Object total) {
    return '$elapsed من $total يوم';
  }

  @override
  String daysWithYou(Object days) {
    return '$days يوم معك';
  }

  @override
  String get debt => 'دين';

  @override
  String get debtDescription => 'وصف الدين';

  @override
  String get debtDue => 'الدين المستحق';

  @override
  String get debtFullyPaid => 'تم سداد الدين بالكامل';

  @override
  String get debtGiven => 'دين (إعطاء)';

  @override
  String get debtReceived => 'دين (استلام)';

  @override
  String get debtRepayment => 'دين (سداد)';

  @override
  String debtRepaymentNote(Object name) {
    return 'سداد دين $name';
  }

  @override
  String get debts => 'الديون';

  @override
  String get debtsShort => 'ديون';

  @override
  String get debtDeleted => 'حُذف الدين';

  @override
  String get delete => 'حذف';

  @override
  String get deleteDebt => 'حذف الدين';

  @override
  String get deleteDebtBody =>
      'هل أنت متأكد من حذف هذا الدين؟ سيتم حذف جميع المعاملات المرتبطة به.';

  @override
  String get deleteEntry => 'حذف الحركة';

  @override
  String get deleteGoal => 'احذف الحصالة';

  @override
  String get deleteTransaction => 'حذف المعاملة';

  @override
  String get deleteTransactionBody =>
      'هل أنت متأكد من حذف هذه المعاملة؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get deposit => 'ادخر';

  @override
  String get depositRecorded => 'تم تسجيل الادخار';

  @override
  String depositToGoal(Object name) {
    return 'ادخار - $name';
  }

  @override
  String get developer => 'المطور';

  @override
  String get device => 'الجهاز';

  @override
  String get distributionByCategory => 'التوزيع حسب التصنيف';

  @override
  String get done => 'تم';

  @override
  String get downloading => 'جاري التحميل';

  @override
  String get durationDaysLabel => 'المدة (بالأيام)';

  @override
  String get durationLabel => 'المدة (أيام)';

  @override
  String get edit => 'تعديل';

  @override
  String get editGoal => 'تعديل الحصالة';

  @override
  String get emptyStats => 'لا توجد بيانات كافية';

  @override
  String get enable => 'تفعيل';

  @override
  String get enabledAutomatically => 'تم التفعيل تلقائياً';

  @override
  String get enterAmount => 'أدخل المبلغ';

  @override
  String get enterAmountAboveZero => 'أدخل مبلغًا أكبر من صفر';

  @override
  String get enterAmountWithinAvailable => 'أدخل مبلغًا صحيحًا ضمن المتوفر';

  @override
  String get enterDebtDescription => 'أدخل وصف الدين';

  @override
  String get enterMinimum => 'أدخل الحد الأدنى';

  @override
  String get enterOpeningBalance => 'أدخل رصيدك الحالي لكل محفظة';

  @override
  String get enterPersonName => 'أدخل اسم الشخص';

  @override
  String get enterValidAmount => 'يرجى إدخال مبلغ صحيح';

  @override
  String get entryDeleted => 'حُذفت الحركة';

  @override
  String get expense => 'صرف';

  @override
  String get expenseShort => 'مصروف';

  @override
  String get export => 'تصدير';

  @override
  String get exportData => 'تصدير البيانات';

  @override
  String get exportDataSubtitle => 'حفظ نسخة احتياطية من جميع بياناتك';

  @override
  String exportFailed(Object error) {
    return 'خطأ في التصدير: $error';
  }

  @override
  String get exportImport => 'تصدير واستيراد';

  @override
  String get exportImportSubtitle => 'نسخة احتياطية ومشاركة البيانات';

  @override
  String get featureHighlights => 'المميزات';

  @override
  String get features => 'ميزات';

  @override
  String get fillAllFields => 'يرجى ملء جميع الحقول';

  @override
  String get fillAllFieldsCorrectly => 'يرجى ملء جميع الحقول بشكل صحيح';

  @override
  String get fillThreeFields => 'املأ الحقول الثلاثة بقيم صحيحة';

  @override
  String get glass => 'زجاج';

  @override
  String get glassMode => 'وضع الزجاج';

  @override
  String get glassModeSubtitle => 'خلفيات شبه شفافة للبطاقات';

  @override
  String get glyphBar => 'شريط Glyph';

  @override
  String get glyphBarSubtitle => 'معلومة سريعة أعلى الرصيد';

  @override
  String get goalCreated => 'تم إنشاء الحصالة';

  @override
  String get goalDeleted => 'حُذفت الحصالة';

  @override
  String get goalDeletedUndo => 'حُذفت الحصالة ورجع المبلغ إلى محفظتك';

  @override
  String get goalName => 'اسم الحصالة';

  @override
  String get goalNameExample => 'مثال: حصالة الشهر';

  @override
  String get goalNotFound => 'الحصالة غير موجودة';

  @override
  String get goalNotFoundBody =>
      'ربما تم حذفها. عد إلى القائمة لاختيار حصالة أخرى.';

  @override
  String get goalPaused => 'الحصالة موقوفة';

  @override
  String get goalPausedToast => 'تم إيقاف الحصالة مؤقتًا';

  @override
  String get goalResumed => 'تم استئناف الحصالة';

  @override
  String get goalWasCreated => 'أُنشئت الحصالة';

  @override
  String get hapticOnSave => 'اهتزاز عند الحفظ';

  @override
  String get hapticOnSaveSubtitle => 'نبضة خفيفة عند إضافة أي عملية';

  @override
  String get haptics => 'اهتزاز';

  @override
  String get history => 'السجل';

  @override
  String get home => 'الرئيسية';

  @override
  String get iGave => 'أنا أعطيت';

  @override
  String get iReceived => 'أنا استلمت';

  @override
  String get import => 'استيراد';

  @override
  String get importData => 'استيراد البيانات';

  @override
  String get importDataSubtitle => 'استعادة بيانات من نسخة احتياطية';

  @override
  String importFailed(Object error) {
    return 'خطأ في الاستيراد: $error';
  }

  @override
  String get importSucceeded => 'تم الاستيراد بنجاح';

  @override
  String get importWarning =>
      'سيتم استبدال جميع البيانات الحالية عند الاستيراد. تأكد من إنشاء نسخة احتياطية أولاً.';

  @override
  String get income => 'دخل';

  @override
  String get installing => 'جاري التثبيت';

  @override
  String get invalidFile => 'ملف غير صالح';

  @override
  String get isCompleted => 'اكتملت';

  @override
  String get later => 'لاحقاً';

  @override
  String get learning => 'قيد التعلم';

  @override
  String get learningFromYou => 'يتعلم منك';

  @override
  String get lentMoney => 'أعطيت مالًا لشخص';

  @override
  String get light => 'فاتح';

  @override
  String get limit => 'حد';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get low => 'منخفض';

  @override
  String get lowBalanceAlert => 'تنبيه الرصيد المنخفض';

  @override
  String get month => 'الشهر';

  @override
  String monthSummary(Object month) {
    return 'ملخص شهر $month';
  }

  @override
  String get monthly => 'شهري';

  @override
  String get monthlySummary => 'ملخص الشهر';

  @override
  String get monthlyTotalLimit => 'الحد الشهري الإجمالي';

  @override
  String get moodDawn => 'الفجر يناديك';

  @override
  String get moodEvening => 'مساء النشاط';

  @override
  String get moodGoodEvening => 'مساء الخير';

  @override
  String get moodMorning => 'صباح النشاط';

  @override
  String get moodNiceEvening => 'مساء جميل';

  @override
  String get moodNoon => 'ظهيرة مثالية';

  @override
  String get moodRest => 'وقت الراحة';

  @override
  String get name => 'الاسم';

  @override
  String get nameExample => 'مثال: عطلة الصيف';

  @override
  String get newGoal => 'حصالة جديدة';

  @override
  String get newVersion => 'الإصدار الجديد';

  @override
  String newVersionAvailable(Object version) {
    return 'الإصدار الجديد: $version';
  }

  @override
  String get noActiveDebts => 'لا توجد ديون نشطة';

  @override
  String get noDebts => 'لا توجد ديون';

  @override
  String get noDepositsYet => 'لا توجد عمليات ادخار بعد';

  @override
  String get noEntriesYet => 'لا توجد حركات بعد';

  @override
  String get noEntriesYetBody => 'ابدأ بالادخار اليومي لتظهر الحركات هنا.';

  @override
  String get noGoalsYet => 'لم تنشئ حصالة بعد';

  @override
  String get noGoalsYetBody => 'أنشئ حصالة لادخار المال بشكل يومي';

  @override
  String get noNewNotifications => 'لا توجد إشعارات جديدة';

  @override
  String get noPatterns => 'لا توجد أنماط';

  @override
  String get noSearchResults => 'لا توجد نتائج للبحث';

  @override
  String get note => 'ملاحظة';

  @override
  String get noteOptional => 'ملاحظة (اختياري)';

  @override
  String get ofGoal => 'من هدف';

  @override
  String ofTotalDays(Object total) {
    return 'من $total';
  }

  @override
  String get openingBalance => 'الرصيد الابتدائي';

  @override
  String get operationFailedRetry => 'تعذّرت العملية، حاول مجددًا';

  @override
  String get optional => 'اختياري';

  @override
  String get paid => 'تم السداد';

  @override
  String get paidAmount => 'المدفوع';

  @override
  String get patternsSubtitle => 'اكتشاف الأنماط المتكررة واقتراحها';

  @override
  String get pause => 'أوقف مؤقتًا';

  @override
  String get pausedShort => 'موقوف';

  @override
  String get pausedTemporarily => 'موقوفة مؤقتًا';

  @override
  String get payment => 'دفعة';

  @override
  String get paymentAdded => 'تم إضافة الدفعة';

  @override
  String get paymentHistory => 'سجل الدفعات';

  @override
  String percentComplete(Object percent) {
    return '$percent% مكتمل';
  }

  @override
  String get personName => 'اسم الشخص';

  @override
  String get personalization => 'التخصيص';

  @override
  String get projects => 'مشاريع';

  @override
  String get projectsSubtitle => 'مشاريع مفتوحة المصدر متنوعة';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String reachedPercentOfBudget(Object percent) {
    return 'وصلت $percent% من ميزانيتك';
  }

  @override
  String get recordFirstTransaction => 'ابدأ بتسجيل أول مصروف أو دخل';

  @override
  String get recordPayment => 'تسجيل دفعة';

  @override
  String get releaseNotes => 'ملاحظات الإصدار';

  @override
  String get releaseNotesHeader => 'ملاحظات الإصدار:';

  @override
  String get remaining => 'المتبقي';

  @override
  String get remindLater => 'ذكرني لاحقاً';

  @override
  String get resume => 'استأنف';

  @override
  String get returnedToWallet => 'أعدت المبلغ إلى محفظتك';

  @override
  String get routineSettings => 'إعدادات الروتين';

  @override
  String get save => 'حفظ';

  @override
  String get saveAction => 'ادخر';

  @override
  String get saveAndContinue => 'حفظ والمتابعة';

  @override
  String get saveChanges => 'احفظ التعديلات';

  @override
  String get saveNow => 'ادخِر';

  @override
  String get saveSettings => 'حفظ الإعدادات';

  @override
  String get saveTransaction => 'حفظ المعاملة';

  @override
  String get savedSoFar => 'المُدَّخر';

  @override
  String get savings => 'ادخار';

  @override
  String get savingsGoal => 'الحصالة';

  @override
  String get savingsLog => 'سجل الادخار';

  @override
  String get searchHint => 'بحث...';

  @override
  String get searchSettings => 'بحث في الإعدادات...';

  @override
  String get setAmountAndTime => 'حدّد المبلغ والزمن';

  @override
  String get settings => 'الإعدادات';

  @override
  String get settingsSaved => 'تم حفظ الإعدادات';

  @override
  String get share => 'مشاركة';

  @override
  String get shareAsFile => 'مشاركة كملف';

  @override
  String get shareAsFileSubtitle => 'مشاركة ملف JSON للبيانات';

  @override
  String shareFailed(Object error) {
    return 'خطأ في المشاركة: $error';
  }

  @override
  String get skip => 'تخطى';

  @override
  String get spent => 'المصروفات';

  @override
  String spentPercentOfBudget(Object percent) {
    return 'صرفت $percent% من ميزانيتك';
  }

  @override
  String get spentToday => 'صرف اليوم';

  @override
  String get start => 'ابدأ';

  @override
  String get startTrackingExpenses => 'ابدأ بتسجيل مصاريفك لرؤية الإحصائيات';

  @override
  String get stats => 'الإحصائيات';

  @override
  String get suggestions => 'اقتراحات';

  @override
  String get tagline => 'تتبع مصاريفك بالدينار الليبي';

  @override
  String timesRepeated(Object count) {
    return '$count مرات';
  }

  @override
  String get today => 'اليوم';

  @override
  String get total => 'الإجمالي';

  @override
  String get totalTarget => 'الهدف الكلي';

  @override
  String get trackExpensesLibya => 'تتبع مصاريفك بسهولة\nبالدينار الليبي';

  @override
  String get transferToDebt => 'حوّل إلى دين';

  @override
  String get transferToTheDebt => 'حوّل إلى الدين';

  @override
  String get transferredToDebt => 'حوّلت المبلغ إلى الدين';

  @override
  String get tryOtherKeywords => 'جرّب البحث بكلمات أخرى';

  @override
  String get twelaBackup => 'نسخة احتياطية من Twela';

  @override
  String get undo => 'تراجع';

  @override
  String get unknown => 'غير معروف';

  @override
  String get unspecified => 'غير محدد';

  @override
  String get update => 'تحديث';

  @override
  String get updateAvailable => 'تحديث جديد متاح';

  @override
  String get updateNow => 'تحديث الآن';

  @override
  String get updateReady => 'تحديث متاح';

  @override
  String get version => 'إصدار';

  @override
  String get wallet => 'المحفظة';

  @override
  String get welcomeSubtitle => 'تتبع مصاريفك بسهولة\nبالدينار الليبي';

  @override
  String get welcomeToTwela => 'مرحباً بك في Twela';

  @override
  String get withdraw => 'اسحب';

  @override
  String get withdrawFromGoal => 'اسحب من الحصالة';

  @override
  String get withdrawFromSavings => 'سحب من الادخار';

  @override
  String get withdrawToWallet => 'اسحب إلى المحفظة';

  @override
  String get withdrawal => 'سحب';

  @override
  String withinDays(Object duration) {
    return 'خلال $duration يوم';
  }

  @override
  String get youAreUpToDate => 'أنت تستخدم أحدث إصدار';

  @override
  String get yourGoal => 'هدفك';
}
