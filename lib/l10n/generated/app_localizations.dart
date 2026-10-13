import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'تويلا'**
  String get appTitle;

  /// No description provided for @balanceTotal.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد الإجمالي'**
  String get balanceTotal;

  /// No description provided for @currencyLyd.
  ///
  /// In ar, this message translates to:
  /// **'د.ل'**
  String get currencyLyd;

  /// No description provided for @today.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get today;

  /// No description provided for @month.
  ///
  /// In ar, this message translates to:
  /// **'الشهر'**
  String get month;

  /// No description provided for @cash.
  ///
  /// In ar, this message translates to:
  /// **'كاش'**
  String get cash;

  /// No description provided for @bank.
  ///
  /// In ar, this message translates to:
  /// **'مصرف'**
  String get bank;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @history.
  ///
  /// In ar, this message translates to:
  /// **'السجل'**
  String get history;

  /// No description provided for @debts.
  ///
  /// In ar, this message translates to:
  /// **'الديون'**
  String get debts;

  /// No description provided for @stats.
  ///
  /// In ar, this message translates to:
  /// **'الإحصائيات'**
  String get stats;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @add.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get add;

  /// No description provided for @addExpense.
  ///
  /// In ar, this message translates to:
  /// **'إضافة صرف'**
  String get addExpense;

  /// No description provided for @addIncome.
  ///
  /// In ar, this message translates to:
  /// **'إضافة دخل'**
  String get addIncome;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @saveAndContinue.
  ///
  /// In ar, this message translates to:
  /// **'حفظ والمتابعة'**
  String get saveAndContinue;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @confirmDelete.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحذف'**
  String get confirmDelete;

  /// No description provided for @category.
  ///
  /// In ar, this message translates to:
  /// **'التصنيف'**
  String get category;

  /// No description provided for @note.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة'**
  String get note;

  /// No description provided for @optional.
  ///
  /// In ar, this message translates to:
  /// **'اختياري'**
  String get optional;

  /// No description provided for @amount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get amount;

  /// No description provided for @date.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get date;

  /// No description provided for @wallet.
  ///
  /// In ar, this message translates to:
  /// **'المحفظة'**
  String get wallet;

  /// No description provided for @expense.
  ///
  /// In ar, this message translates to:
  /// **'صرف'**
  String get expense;

  /// No description provided for @income.
  ///
  /// In ar, this message translates to:
  /// **'دخل'**
  String get income;

  /// No description provided for @savings.
  ///
  /// In ar, this message translates to:
  /// **'ادخار'**
  String get savings;

  /// No description provided for @debt.
  ///
  /// In ar, this message translates to:
  /// **'دين'**
  String get debt;

  /// No description provided for @savingsGoal.
  ///
  /// In ar, this message translates to:
  /// **'الحصالة'**
  String get savingsGoal;

  /// No description provided for @createSavingsGoal.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حصالة'**
  String get createSavingsGoal;

  /// No description provided for @noDebts.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ديون'**
  String get noDebts;

  /// No description provided for @addDebt.
  ///
  /// In ar, this message translates to:
  /// **'إضافة دين'**
  String get addDebt;

  /// No description provided for @active.
  ///
  /// In ar, this message translates to:
  /// **'نشطة'**
  String get active;

  /// No description provided for @paid.
  ///
  /// In ar, this message translates to:
  /// **'تم السداد'**
  String get paid;

  /// No description provided for @total.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get total;

  /// No description provided for @spent.
  ///
  /// In ar, this message translates to:
  /// **'المصروفات'**
  String get spent;

  /// No description provided for @emptyStats.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات كافية'**
  String get emptyStats;

  /// No description provided for @startTrackingExpenses.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ بتسجيل مصاريفك لرؤية الإحصائيات'**
  String get startTrackingExpenses;

  /// No description provided for @distributionByCategory.
  ///
  /// In ar, this message translates to:
  /// **'التوزيع حسب التصنيف'**
  String get distributionByCategory;

  /// No description provided for @monthlySummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص الشهر'**
  String get monthlySummary;

  /// No description provided for @welcomeToTwela.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك في تويلا'**
  String get welcomeToTwela;

  /// No description provided for @trackExpensesLibya.
  ///
  /// In ar, this message translates to:
  /// **'تتبع مصاريفك بسهولة\nبالدينار الليبي'**
  String get trackExpensesLibya;

  /// No description provided for @start.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ'**
  String get start;

  /// No description provided for @data.
  ///
  /// In ar, this message translates to:
  /// **'البيانات'**
  String get data;

  /// No description provided for @backup.
  ///
  /// In ar, this message translates to:
  /// **'النسخ الاحتياطي'**
  String get backup;

  /// No description provided for @exportData.
  ///
  /// In ar, this message translates to:
  /// **'تصدير البيانات'**
  String get exportData;

  /// No description provided for @exportDataSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'حفظ نسخة احتياطية من جميع بياناتك'**
  String get exportDataSubtitle;

  /// No description provided for @importData.
  ///
  /// In ar, this message translates to:
  /// **'استيراد البيانات'**
  String get importData;

  /// No description provided for @importDataSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'استعادة بيانات من نسخة احتياطية'**
  String get importDataSubtitle;

  /// No description provided for @shareAsFile.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة كملف'**
  String get shareAsFile;

  /// No description provided for @shareAsFileSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة ملف JSON للبيانات'**
  String get shareAsFileSubtitle;

  /// No description provided for @copyData.
  ///
  /// In ar, this message translates to:
  /// **'نسخ البيانات'**
  String get copyData;

  /// No description provided for @copyDataSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'نسخ البيانات كنص JSON'**
  String get copyDataSubtitle;

  /// No description provided for @importWarning.
  ///
  /// In ar, this message translates to:
  /// **'سيتم استبدال جميع البيانات الحالية عند الاستيراد. تأكد من إنشاء نسخة احتياطية أولاً.'**
  String get importWarning;

  /// No description provided for @updateAvailable.
  ///
  /// In ar, this message translates to:
  /// **'تحديث جديد متاح'**
  String get updateAvailable;

  /// No description provided for @newVersion.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار الجديد'**
  String get newVersion;

  /// No description provided for @currentVersion.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار الحالي'**
  String get currentVersion;

  /// No description provided for @releaseNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات الإصدار'**
  String get releaseNotes;

  /// No description provided for @remindLater.
  ///
  /// In ar, this message translates to:
  /// **'ذكرني لاحقاً'**
  String get remindLater;

  /// No description provided for @skip.
  ///
  /// In ar, this message translates to:
  /// **'تخطى'**
  String get skip;

  /// No description provided for @updateNow.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الآن'**
  String get updateNow;

  /// No description provided for @downloading.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل'**
  String get downloading;

  /// No description provided for @installing.
  ///
  /// In ar, this message translates to:
  /// **'جاري التثبيت'**
  String get installing;

  /// No description provided for @checkForUpdate.
  ///
  /// In ar, this message translates to:
  /// **'التحقق من التحديث'**
  String get checkForUpdate;

  /// No description provided for @youAreUpToDate.
  ///
  /// In ar, this message translates to:
  /// **'أنت تستخدم أحدث إصدار'**
  String get youAreUpToDate;

  /// No description provided for @noNewNotifications.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات جديدة'**
  String get noNewNotifications;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
