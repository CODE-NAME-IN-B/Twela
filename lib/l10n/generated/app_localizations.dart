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

  /// No description provided for @accentColor.
  ///
  /// In ar, this message translates to:
  /// **'لون التمييز'**
  String get accentColor;

  /// No description provided for @active.
  ///
  /// In ar, this message translates to:
  /// **'نشطة'**
  String get active;

  /// No description provided for @activeShort.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get activeShort;

  /// No description provided for @activityLog.
  ///
  /// In ar, this message translates to:
  /// **'سجل الحركة'**
  String get activityLog;

  /// No description provided for @add.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get add;

  /// No description provided for @addDebt.
  ///
  /// In ar, this message translates to:
  /// **'إضافة دين'**
  String get addDebt;

  /// No description provided for @addDebtFirst.
  ///
  /// In ar, this message translates to:
  /// **'أضف دينًا أولًا لتتمكن من السداد منه.'**
  String get addDebtFirst;

  /// No description provided for @addExpense.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مصروف'**
  String get addExpense;

  /// No description provided for @addFirstDebt.
  ///
  /// In ar, this message translates to:
  /// **'أضف دين جديد للبدء في التتبع'**
  String get addFirstDebt;

  /// No description provided for @addIncome.
  ///
  /// In ar, this message translates to:
  /// **'إضافة دخل'**
  String get addIncome;

  /// No description provided for @addNoteHint.
  ///
  /// In ar, this message translates to:
  /// **'أضف ملاحظة...'**
  String get addNoteHint;

  /// No description provided for @addTransaction.
  ///
  /// In ar, this message translates to:
  /// **'إضافة عملية'**
  String get addTransaction;

  /// No description provided for @alert.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه'**
  String get alert;

  /// No description provided for @all.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get all;

  /// No description provided for @amount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get amount;

  /// No description provided for @amountExceedsRemaining.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ أكبر من المتبقي'**
  String get amountExceedsRemaining;

  /// No description provided for @appDescription.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق تتبع المصاريف بالدينار الليبي'**
  String get appDescription;

  /// No description provided for @appSection.
  ///
  /// In ar, this message translates to:
  /// **'التطبيق'**
  String get appSection;

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'تويلا'**
  String get appTitle;

  /// No description provided for @appearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get appearance;

  /// No description provided for @availableInGoal.
  ///
  /// In ar, this message translates to:
  /// **'المتوفر في الحصالة'**
  String get availableInGoal;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// No description provided for @backup.
  ///
  /// In ar, this message translates to:
  /// **'النسخ الاحتياطي'**
  String get backup;

  /// No description provided for @balance.
  ///
  /// In ar, this message translates to:
  /// **'رصيد'**
  String get balance;

  /// No description provided for @balanceTotal.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد الإجمالي'**
  String get balanceTotal;

  /// No description provided for @bank.
  ///
  /// In ar, this message translates to:
  /// **'مصرف'**
  String get bank;

  /// No description provided for @bankWallet.
  ///
  /// In ar, this message translates to:
  /// **'محفظة المصرف'**
  String get bankWallet;

  /// No description provided for @bar.
  ///
  /// In ar, this message translates to:
  /// **'شريط'**
  String get bar;

  /// No description provided for @biggestExpenses.
  ///
  /// In ar, this message translates to:
  /// **'أكبر المصروفات'**
  String get biggestExpenses;

  /// No description provided for @borrowedMoney.
  ///
  /// In ar, this message translates to:
  /// **'استلمت مالًا من شخص'**
  String get borrowedMoney;

  /// No description provided for @budget.
  ///
  /// In ar, this message translates to:
  /// **'ميزانية'**
  String get budget;

  /// No description provided for @budgetExceeded.
  ///
  /// In ar, this message translates to:
  /// **'تجاوزت ميزانيتك الشهرية'**
  String get budgetExceeded;

  /// No description provided for @budgetTitle.
  ///
  /// In ar, this message translates to:
  /// **'الميزانية'**
  String get budgetTitle;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @cash.
  ///
  /// In ar, this message translates to:
  /// **'كاش'**
  String get cash;

  /// No description provided for @cashWallet.
  ///
  /// In ar, this message translates to:
  /// **'محفظة الكاش'**
  String get cashWallet;

  /// No description provided for @category.
  ///
  /// In ar, this message translates to:
  /// **'التصنيف'**
  String get category;

  /// No description provided for @changesSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ التعديلات'**
  String get changesSaved;

  /// No description provided for @checkForUpdate.
  ///
  /// In ar, this message translates to:
  /// **'التحقق من التحديث'**
  String get checkForUpdate;

  /// No description provided for @checkForUpdates.
  ///
  /// In ar, this message translates to:
  /// **'التحقق من التحديثات'**
  String get checkForUpdates;

  /// No description provided for @checkForUpdatesSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اضغط للتحقق من إصدار جديد'**
  String get checkForUpdatesSubtitle;

  /// No description provided for @chooseCategory.
  ///
  /// In ar, this message translates to:
  /// **'يرجى اختيار التصنيف'**
  String get chooseCategory;

  /// No description provided for @chooseDebtToPay.
  ///
  /// In ar, this message translates to:
  /// **'اختر الدين المراد سداده'**
  String get chooseDebtToPay;

  /// No description provided for @color.
  ///
  /// In ar, this message translates to:
  /// **'لون'**
  String get color;

  /// No description provided for @completed.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get completed;

  /// No description provided for @completedShort.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get completedShort;

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

  /// No description provided for @confirmImport.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الاستيراد'**
  String get confirmImport;

  /// No description provided for @confirmImportBody.
  ///
  /// In ar, this message translates to:
  /// **'سيتم استبدال جميع البيانات الحالية. هل أنت متأكد؟'**
  String get confirmImportBody;

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

  /// No description provided for @copyFailed.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في النسخ: {error}'**
  String copyFailed(Object error);

  /// No description provided for @createGoal.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء الحصالة'**
  String get createGoal;

  /// No description provided for @createGoalAction.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ الحصالة'**
  String get createGoalAction;

  /// No description provided for @createSavingsGoal.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حصالة'**
  String get createSavingsGoal;

  /// No description provided for @currencyLyd.
  ///
  /// In ar, this message translates to:
  /// **'د.ل'**
  String get currencyLyd;

  /// No description provided for @currentVersion.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار الحالي'**
  String get currentVersion;

  /// No description provided for @currentVersionIs.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار الحالي: {version}'**
  String currentVersionIs(Object version);

  /// No description provided for @customization.
  ///
  /// In ar, this message translates to:
  /// **'تخصيص'**
  String get customization;

  /// No description provided for @daily.
  ///
  /// In ar, this message translates to:
  /// **'يومي'**
  String get daily;

  /// No description provided for @dailyAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ اليومي'**
  String get dailyAmount;

  /// No description provided for @dailySpendLimit.
  ///
  /// In ar, this message translates to:
  /// **'حد الصرف اليومي'**
  String get dailySpendLimit;

  /// No description provided for @dark.
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get dark;

  /// No description provided for @data.
  ///
  /// In ar, this message translates to:
  /// **'البيانات'**
  String get data;

  /// No description provided for @dataCopied.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ البيانات'**
  String get dataCopied;

  /// No description provided for @dataLabel.
  ///
  /// In ar, this message translates to:
  /// **'بيانات'**
  String get dataLabel;

  /// No description provided for @date.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get date;

  /// No description provided for @days.
  ///
  /// In ar, this message translates to:
  /// **'الأيام'**
  String get days;

  /// No description provided for @daysLeftInMonth.
  ///
  /// In ar, this message translates to:
  /// **'بقي {daysLeft} يوم على نهاية الشهر'**
  String daysLeftInMonth(Object daysLeft);

  /// No description provided for @daysOfTotal.
  ///
  /// In ar, this message translates to:
  /// **'{elapsed} من {total} يوم'**
  String daysOfTotal(Object elapsed, Object total);

  /// No description provided for @daysWithYou.
  ///
  /// In ar, this message translates to:
  /// **'{days} يوم معك'**
  String daysWithYou(Object days);

  /// No description provided for @debt.
  ///
  /// In ar, this message translates to:
  /// **'دين'**
  String get debt;

  /// No description provided for @debtDescription.
  ///
  /// In ar, this message translates to:
  /// **'وصف الدين'**
  String get debtDescription;

  /// No description provided for @debtDue.
  ///
  /// In ar, this message translates to:
  /// **'الدين المستحق'**
  String get debtDue;

  /// No description provided for @debtFullyPaid.
  ///
  /// In ar, this message translates to:
  /// **'تم سداد الدين بالكامل'**
  String get debtFullyPaid;

  /// No description provided for @debtGiven.
  ///
  /// In ar, this message translates to:
  /// **'دين (إعطاء)'**
  String get debtGiven;

  /// No description provided for @debtReceived.
  ///
  /// In ar, this message translates to:
  /// **'دين (استلام)'**
  String get debtReceived;

  /// No description provided for @debtRepayment.
  ///
  /// In ar, this message translates to:
  /// **'دين (سداد)'**
  String get debtRepayment;

  /// No description provided for @debtRepaymentNote.
  ///
  /// In ar, this message translates to:
  /// **'سداد دين {name}'**
  String debtRepaymentNote(Object name);

  /// No description provided for @debts.
  ///
  /// In ar, this message translates to:
  /// **'الديون'**
  String get debts;

  /// No description provided for @debtsShort.
  ///
  /// In ar, this message translates to:
  /// **'ديون'**
  String get debtsShort;

  /// No description provided for @debtDeleted.
  ///
  /// In ar, this message translates to:
  /// **'حُذف الدين'**
  String get debtDeleted;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @deleteDebt.
  ///
  /// In ar, this message translates to:
  /// **'حذف الدين'**
  String get deleteDebt;

  /// No description provided for @deleteDebtBody.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذا الدين؟ سيتم حذف جميع المعاملات المرتبطة به.'**
  String get deleteDebtBody;

  /// No description provided for @deleteEntry.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحركة'**
  String get deleteEntry;

  /// No description provided for @deleteGoal.
  ///
  /// In ar, this message translates to:
  /// **'احذف الحصالة'**
  String get deleteGoal;

  /// No description provided for @deleteTransaction.
  ///
  /// In ar, this message translates to:
  /// **'حذف المعاملة'**
  String get deleteTransaction;

  /// No description provided for @deleteTransactionBody.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذه المعاملة؟ لا يمكن التراجع عن هذا الإجراء.'**
  String get deleteTransactionBody;

  /// No description provided for @deposit.
  ///
  /// In ar, this message translates to:
  /// **'ادخر'**
  String get deposit;

  /// No description provided for @depositRecorded.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الادخار'**
  String get depositRecorded;

  /// No description provided for @depositToGoal.
  ///
  /// In ar, this message translates to:
  /// **'ادخار - {name}'**
  String depositToGoal(Object name);

  /// No description provided for @developer.
  ///
  /// In ar, this message translates to:
  /// **'المطور'**
  String get developer;

  /// No description provided for @device.
  ///
  /// In ar, this message translates to:
  /// **'الجهاز'**
  String get device;

  /// No description provided for @distributionByCategory.
  ///
  /// In ar, this message translates to:
  /// **'التوزيع حسب التصنيف'**
  String get distributionByCategory;

  /// No description provided for @done.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get done;

  /// No description provided for @downloading.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل'**
  String get downloading;

  /// No description provided for @durationDaysLabel.
  ///
  /// In ar, this message translates to:
  /// **'المدة (بالأيام)'**
  String get durationDaysLabel;

  /// No description provided for @durationLabel.
  ///
  /// In ar, this message translates to:
  /// **'المدة (أيام)'**
  String get durationLabel;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @editGoal.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الحصالة'**
  String get editGoal;

  /// No description provided for @emptyStats.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات كافية'**
  String get emptyStats;

  /// No description provided for @enable.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل'**
  String get enable;

  /// No description provided for @enabledAutomatically.
  ///
  /// In ar, this message translates to:
  /// **'تم التفعيل تلقائياً'**
  String get enabledAutomatically;

  /// No description provided for @enterAmount.
  ///
  /// In ar, this message translates to:
  /// **'أدخل المبلغ'**
  String get enterAmount;

  /// No description provided for @enterAmountAboveZero.
  ///
  /// In ar, this message translates to:
  /// **'أدخل مبلغًا أكبر من صفر'**
  String get enterAmountAboveZero;

  /// No description provided for @enterAmountWithinAvailable.
  ///
  /// In ar, this message translates to:
  /// **'أدخل مبلغًا صحيحًا ضمن المتوفر'**
  String get enterAmountWithinAvailable;

  /// No description provided for @enterDebtDescription.
  ///
  /// In ar, this message translates to:
  /// **'أدخل وصف الدين'**
  String get enterDebtDescription;

  /// No description provided for @enterMinimum.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الحد الأدنى'**
  String get enterMinimum;

  /// No description provided for @enterOpeningBalance.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رصيدك الحالي لكل محفظة'**
  String get enterOpeningBalance;

  /// No description provided for @enterPersonName.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم الشخص'**
  String get enterPersonName;

  /// No description provided for @enterValidAmount.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال مبلغ صحيح'**
  String get enterValidAmount;

  /// No description provided for @entryDeleted.
  ///
  /// In ar, this message translates to:
  /// **'حُذفت الحركة'**
  String get entryDeleted;

  /// No description provided for @expense.
  ///
  /// In ar, this message translates to:
  /// **'صرف'**
  String get expense;

  /// No description provided for @expenseShort.
  ///
  /// In ar, this message translates to:
  /// **'مصروف'**
  String get expenseShort;

  /// No description provided for @export.
  ///
  /// In ar, this message translates to:
  /// **'تصدير'**
  String get export;

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

  /// No description provided for @exportFailed.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في التصدير: {error}'**
  String exportFailed(Object error);

  /// No description provided for @exportImport.
  ///
  /// In ar, this message translates to:
  /// **'تصدير واستيراد'**
  String get exportImport;

  /// No description provided for @exportImportSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'نسخة احتياطية ومشاركة البيانات'**
  String get exportImportSubtitle;

  /// No description provided for @featureHighlights.
  ///
  /// In ar, this message translates to:
  /// **'المميزات'**
  String get featureHighlights;

  /// No description provided for @features.
  ///
  /// In ar, this message translates to:
  /// **'ميزات'**
  String get features;

  /// No description provided for @fillAllFields.
  ///
  /// In ar, this message translates to:
  /// **'يرجى ملء جميع الحقول'**
  String get fillAllFields;

  /// No description provided for @fillAllFieldsCorrectly.
  ///
  /// In ar, this message translates to:
  /// **'يرجى ملء جميع الحقول بشكل صحيح'**
  String get fillAllFieldsCorrectly;

  /// No description provided for @fillThreeFields.
  ///
  /// In ar, this message translates to:
  /// **'املأ الحقول الثلاثة بقيم صحيحة'**
  String get fillThreeFields;

  /// No description provided for @glass.
  ///
  /// In ar, this message translates to:
  /// **'زجاج'**
  String get glass;

  /// No description provided for @glassMode.
  ///
  /// In ar, this message translates to:
  /// **'وضع الزجاج'**
  String get glassMode;

  /// No description provided for @glassModeSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'خلفيات شبه شفافة للبطاقات'**
  String get glassModeSubtitle;

  /// No description provided for @glyphBar.
  ///
  /// In ar, this message translates to:
  /// **'شريط Glyph'**
  String get glyphBar;

  /// No description provided for @glyphBarSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'معلومة سريعة أعلى الرصيد'**
  String get glyphBarSubtitle;

  /// No description provided for @goalCreated.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء الحصالة'**
  String get goalCreated;

  /// No description provided for @goalDeleted.
  ///
  /// In ar, this message translates to:
  /// **'حُذفت الحصالة'**
  String get goalDeleted;

  /// No description provided for @goalDeletedUndo.
  ///
  /// In ar, this message translates to:
  /// **'حُذفت الحصالة ورجع المبلغ إلى محفظتك'**
  String get goalDeletedUndo;

  /// No description provided for @goalName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الحصالة'**
  String get goalName;

  /// No description provided for @goalNameExample.
  ///
  /// In ar, this message translates to:
  /// **'مثال: حصالة الشهر'**
  String get goalNameExample;

  /// No description provided for @goalNotFound.
  ///
  /// In ar, this message translates to:
  /// **'الحصالة غير موجودة'**
  String get goalNotFound;

  /// No description provided for @goalNotFoundBody.
  ///
  /// In ar, this message translates to:
  /// **'ربما تم حذفها. عد إلى القائمة لاختيار حصالة أخرى.'**
  String get goalNotFoundBody;

  /// No description provided for @goalPaused.
  ///
  /// In ar, this message translates to:
  /// **'الحصالة موقوفة'**
  String get goalPaused;

  /// No description provided for @goalPausedToast.
  ///
  /// In ar, this message translates to:
  /// **'تم إيقاف الحصالة مؤقتًا'**
  String get goalPausedToast;

  /// No description provided for @goalResumed.
  ///
  /// In ar, this message translates to:
  /// **'تم استئناف الحصالة'**
  String get goalResumed;

  /// No description provided for @goalWasCreated.
  ///
  /// In ar, this message translates to:
  /// **'أُنشئت الحصالة'**
  String get goalWasCreated;

  /// No description provided for @hapticOnSave.
  ///
  /// In ar, this message translates to:
  /// **'اهتزاز عند الحفظ'**
  String get hapticOnSave;

  /// No description provided for @hapticOnSaveSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'نبضة خفيفة عند إضافة أي عملية'**
  String get hapticOnSaveSubtitle;

  /// No description provided for @haptics.
  ///
  /// In ar, this message translates to:
  /// **'اهتزاز'**
  String get haptics;

  /// No description provided for @history.
  ///
  /// In ar, this message translates to:
  /// **'السجل'**
  String get history;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @iGave.
  ///
  /// In ar, this message translates to:
  /// **'أنا أعطيت'**
  String get iGave;

  /// No description provided for @iReceived.
  ///
  /// In ar, this message translates to:
  /// **'أنا استلمت'**
  String get iReceived;

  /// No description provided for @import.
  ///
  /// In ar, this message translates to:
  /// **'استيراد'**
  String get import;

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

  /// No description provided for @importFailed.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الاستيراد: {error}'**
  String importFailed(Object error);

  /// No description provided for @importSucceeded.
  ///
  /// In ar, this message translates to:
  /// **'تم الاستيراد بنجاح'**
  String get importSucceeded;

  /// No description provided for @importWarning.
  ///
  /// In ar, this message translates to:
  /// **'سيتم استبدال جميع البيانات الحالية عند الاستيراد. تأكد من إنشاء نسخة احتياطية أولاً.'**
  String get importWarning;

  /// No description provided for @income.
  ///
  /// In ar, this message translates to:
  /// **'دخل'**
  String get income;

  /// No description provided for @installing.
  ///
  /// In ar, this message translates to:
  /// **'جاري التثبيت'**
  String get installing;

  /// No description provided for @invalidFile.
  ///
  /// In ar, this message translates to:
  /// **'ملف غير صالح'**
  String get invalidFile;

  /// No description provided for @isCompleted.
  ///
  /// In ar, this message translates to:
  /// **'اكتملت'**
  String get isCompleted;

  /// No description provided for @later.
  ///
  /// In ar, this message translates to:
  /// **'لاحقاً'**
  String get later;

  /// No description provided for @learning.
  ///
  /// In ar, this message translates to:
  /// **'قيد التعلم'**
  String get learning;

  /// No description provided for @learningFromYou.
  ///
  /// In ar, this message translates to:
  /// **'يتعلم منك'**
  String get learningFromYou;

  /// No description provided for @lentMoney.
  ///
  /// In ar, this message translates to:
  /// **'أعطيت مالًا لشخص'**
  String get lentMoney;

  /// No description provided for @light.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get light;

  /// No description provided for @limit.
  ///
  /// In ar, this message translates to:
  /// **'حد'**
  String get limit;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get loading;

  /// No description provided for @low.
  ///
  /// In ar, this message translates to:
  /// **'منخفض'**
  String get low;

  /// No description provided for @lowBalanceAlert.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه الرصيد المنخفض'**
  String get lowBalanceAlert;

  /// No description provided for @month.
  ///
  /// In ar, this message translates to:
  /// **'الشهر'**
  String get month;

  /// No description provided for @monthSummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص شهر {month}'**
  String monthSummary(Object month);

  /// No description provided for @monthly.
  ///
  /// In ar, this message translates to:
  /// **'شهري'**
  String get monthly;

  /// No description provided for @monthlySummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص الشهر'**
  String get monthlySummary;

  /// No description provided for @monthlyTotalLimit.
  ///
  /// In ar, this message translates to:
  /// **'الحد الشهري الإجمالي'**
  String get monthlyTotalLimit;

  /// No description provided for @moodDawn.
  ///
  /// In ar, this message translates to:
  /// **'الفجر يناديك'**
  String get moodDawn;

  /// No description provided for @moodEvening.
  ///
  /// In ar, this message translates to:
  /// **'مساء النشاط'**
  String get moodEvening;

  /// No description provided for @moodGoodEvening.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير'**
  String get moodGoodEvening;

  /// No description provided for @moodMorning.
  ///
  /// In ar, this message translates to:
  /// **'صباح النشاط'**
  String get moodMorning;

  /// No description provided for @moodNiceEvening.
  ///
  /// In ar, this message translates to:
  /// **'مساء جميل'**
  String get moodNiceEvening;

  /// No description provided for @moodNoon.
  ///
  /// In ar, this message translates to:
  /// **'ظهيرة مثالية'**
  String get moodNoon;

  /// No description provided for @moodRest.
  ///
  /// In ar, this message translates to:
  /// **'وقت الراحة'**
  String get moodRest;

  /// No description provided for @name.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get name;

  /// No description provided for @nameExample.
  ///
  /// In ar, this message translates to:
  /// **'مثال: عطلة الصيف'**
  String get nameExample;

  /// No description provided for @newGoal.
  ///
  /// In ar, this message translates to:
  /// **'حصالة جديدة'**
  String get newGoal;

  /// No description provided for @newVersion.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار الجديد'**
  String get newVersion;

  /// No description provided for @newVersionAvailable.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار الجديد: {version}'**
  String newVersionAvailable(Object version);

  /// No description provided for @noActiveDebts.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ديون نشطة'**
  String get noActiveDebts;

  /// No description provided for @noDebts.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ديون'**
  String get noDebts;

  /// No description provided for @noDepositsYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عمليات ادخار بعد'**
  String get noDepositsYet;

  /// No description provided for @noEntriesYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد حركات بعد'**
  String get noEntriesYet;

  /// No description provided for @noEntriesYetBody.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ بالادخار اليومي لتظهر الحركات هنا.'**
  String get noEntriesYetBody;

  /// No description provided for @noGoalsYet.
  ///
  /// In ar, this message translates to:
  /// **'لم تنشئ حصالة بعد'**
  String get noGoalsYet;

  /// No description provided for @noGoalsYetBody.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ حصالة لادخار المال بشكل يومي'**
  String get noGoalsYetBody;

  /// No description provided for @noNewNotifications.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات جديدة'**
  String get noNewNotifications;

  /// No description provided for @noPatterns.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أنماط'**
  String get noPatterns;

  /// No description provided for @noSearchResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج للبحث'**
  String get noSearchResults;

  /// No description provided for @note.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة'**
  String get note;

  /// No description provided for @noteOptional.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة (اختياري)'**
  String get noteOptional;

  /// No description provided for @ofGoal.
  ///
  /// In ar, this message translates to:
  /// **'من هدف'**
  String get ofGoal;

  /// No description provided for @ofTotalDays.
  ///
  /// In ar, this message translates to:
  /// **'من {total}'**
  String ofTotalDays(Object total);

  /// No description provided for @openingBalance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد الابتدائي'**
  String get openingBalance;

  /// No description provided for @operationFailedRetry.
  ///
  /// In ar, this message translates to:
  /// **'تعذّرت العملية، حاول مجددًا'**
  String get operationFailedRetry;

  /// No description provided for @optional.
  ///
  /// In ar, this message translates to:
  /// **'اختياري'**
  String get optional;

  /// No description provided for @paid.
  ///
  /// In ar, this message translates to:
  /// **'تم السداد'**
  String get paid;

  /// No description provided for @paidAmount.
  ///
  /// In ar, this message translates to:
  /// **'المدفوع'**
  String get paidAmount;

  /// No description provided for @patternsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اكتشاف الأنماط المتكررة واقتراحها'**
  String get patternsSubtitle;

  /// No description provided for @pause.
  ///
  /// In ar, this message translates to:
  /// **'أوقف مؤقتًا'**
  String get pause;

  /// No description provided for @pausedShort.
  ///
  /// In ar, this message translates to:
  /// **'موقوف'**
  String get pausedShort;

  /// No description provided for @pausedTemporarily.
  ///
  /// In ar, this message translates to:
  /// **'موقوفة مؤقتًا'**
  String get pausedTemporarily;

  /// No description provided for @payment.
  ///
  /// In ar, this message translates to:
  /// **'دفعة'**
  String get payment;

  /// No description provided for @paymentAdded.
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة الدفعة'**
  String get paymentAdded;

  /// No description provided for @paymentHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل الدفعات'**
  String get paymentHistory;

  /// No description provided for @percentComplete.
  ///
  /// In ar, this message translates to:
  /// **'{percent}% مكتمل'**
  String percentComplete(Object percent);

  /// No description provided for @personName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الشخص'**
  String get personName;

  /// No description provided for @personalization.
  ///
  /// In ar, this message translates to:
  /// **'التخصيص'**
  String get personalization;

  /// No description provided for @projects.
  ///
  /// In ar, this message translates to:
  /// **'مشاريع'**
  String get projects;

  /// No description provided for @projectsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'مشاريع مفتوحة المصدر متنوعة'**
  String get projectsSubtitle;

  /// No description provided for @quickActions.
  ///
  /// In ar, this message translates to:
  /// **'إجراءات سريعة'**
  String get quickActions;

  /// No description provided for @reachedPercentOfBudget.
  ///
  /// In ar, this message translates to:
  /// **'وصلت {percent}% من ميزانيتك'**
  String reachedPercentOfBudget(Object percent);

  /// No description provided for @recordFirstTransaction.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ بتسجيل أول مصروف أو دخل'**
  String get recordFirstTransaction;

  /// No description provided for @recordPayment.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل دفعة'**
  String get recordPayment;

  /// No description provided for @releaseNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات الإصدار'**
  String get releaseNotes;

  /// No description provided for @releaseNotesHeader.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات الإصدار:'**
  String get releaseNotesHeader;

  /// No description provided for @remaining.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي'**
  String get remaining;

  /// No description provided for @remindLater.
  ///
  /// In ar, this message translates to:
  /// **'ذكرني لاحقاً'**
  String get remindLater;

  /// No description provided for @resume.
  ///
  /// In ar, this message translates to:
  /// **'استأنف'**
  String get resume;

  /// No description provided for @returnedToWallet.
  ///
  /// In ar, this message translates to:
  /// **'أعدت المبلغ إلى محفظتك'**
  String get returnedToWallet;

  /// No description provided for @routineSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الروتين'**
  String get routineSettings;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @saveAction.
  ///
  /// In ar, this message translates to:
  /// **'ادخر'**
  String get saveAction;

  /// No description provided for @saveAndContinue.
  ///
  /// In ar, this message translates to:
  /// **'حفظ والمتابعة'**
  String get saveAndContinue;

  /// No description provided for @saveChanges.
  ///
  /// In ar, this message translates to:
  /// **'احفظ التعديلات'**
  String get saveChanges;

  /// No description provided for @saveNow.
  ///
  /// In ar, this message translates to:
  /// **'ادخِر'**
  String get saveNow;

  /// No description provided for @saveSettings.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الإعدادات'**
  String get saveSettings;

  /// No description provided for @saveTransaction.
  ///
  /// In ar, this message translates to:
  /// **'حفظ المعاملة'**
  String get saveTransaction;

  /// No description provided for @savedSoFar.
  ///
  /// In ar, this message translates to:
  /// **'المُدَّخر'**
  String get savedSoFar;

  /// No description provided for @savings.
  ///
  /// In ar, this message translates to:
  /// **'ادخار'**
  String get savings;

  /// No description provided for @savingsGoal.
  ///
  /// In ar, this message translates to:
  /// **'الحصالة'**
  String get savingsGoal;

  /// No description provided for @savingsLog.
  ///
  /// In ar, this message translates to:
  /// **'سجل الادخار'**
  String get savingsLog;

  /// No description provided for @searchHint.
  ///
  /// In ar, this message translates to:
  /// **'بحث...'**
  String get searchHint;

  /// No description provided for @searchSettings.
  ///
  /// In ar, this message translates to:
  /// **'بحث في الإعدادات...'**
  String get searchSettings;

  /// No description provided for @setAmountAndTime.
  ///
  /// In ar, this message translates to:
  /// **'حدّد المبلغ والزمن'**
  String get setAmountAndTime;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @settingsSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الإعدادات'**
  String get settingsSaved;

  /// No description provided for @share.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get share;

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

  /// No description provided for @shareFailed.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في المشاركة: {error}'**
  String shareFailed(Object error);

  /// No description provided for @skip.
  ///
  /// In ar, this message translates to:
  /// **'تخطى'**
  String get skip;

  /// No description provided for @spent.
  ///
  /// In ar, this message translates to:
  /// **'المصروفات'**
  String get spent;

  /// No description provided for @spentPercentOfBudget.
  ///
  /// In ar, this message translates to:
  /// **'صرفت {percent}% من ميزانيتك'**
  String spentPercentOfBudget(Object percent);

  /// No description provided for @spentToday.
  ///
  /// In ar, this message translates to:
  /// **'صرف اليوم'**
  String get spentToday;

  /// No description provided for @start.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ'**
  String get start;

  /// No description provided for @startTrackingExpenses.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ بتسجيل مصاريفك لرؤية الإحصائيات'**
  String get startTrackingExpenses;

  /// No description provided for @stats.
  ///
  /// In ar, this message translates to:
  /// **'الإحصائيات'**
  String get stats;

  /// No description provided for @suggestions.
  ///
  /// In ar, this message translates to:
  /// **'اقتراحات'**
  String get suggestions;

  /// No description provided for @tagline.
  ///
  /// In ar, this message translates to:
  /// **'تتبع مصاريفك بالدينار الليبي'**
  String get tagline;

  /// No description provided for @timesRepeated.
  ///
  /// In ar, this message translates to:
  /// **'{count} مرات'**
  String timesRepeated(Object count);

  /// No description provided for @today.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get today;

  /// No description provided for @total.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get total;

  /// No description provided for @totalTarget.
  ///
  /// In ar, this message translates to:
  /// **'الهدف الكلي'**
  String get totalTarget;

  /// No description provided for @trackExpensesLibya.
  ///
  /// In ar, this message translates to:
  /// **'تتبع مصاريفك بسهولة\nبالدينار الليبي'**
  String get trackExpensesLibya;

  /// No description provided for @transferToDebt.
  ///
  /// In ar, this message translates to:
  /// **'حوّل إلى دين'**
  String get transferToDebt;

  /// No description provided for @transferToTheDebt.
  ///
  /// In ar, this message translates to:
  /// **'حوّل إلى الدين'**
  String get transferToTheDebt;

  /// No description provided for @transferredToDebt.
  ///
  /// In ar, this message translates to:
  /// **'حوّلت المبلغ إلى الدين'**
  String get transferredToDebt;

  /// No description provided for @tryOtherKeywords.
  ///
  /// In ar, this message translates to:
  /// **'جرّب البحث بكلمات أخرى'**
  String get tryOtherKeywords;

  /// No description provided for @twelaBackup.
  ///
  /// In ar, this message translates to:
  /// **'نسخة احتياطية من Twela'**
  String get twelaBackup;

  /// No description provided for @undo.
  ///
  /// In ar, this message translates to:
  /// **'تراجع'**
  String get undo;

  /// No description provided for @unknown.
  ///
  /// In ar, this message translates to:
  /// **'غير معروف'**
  String get unknown;

  /// No description provided for @unspecified.
  ///
  /// In ar, this message translates to:
  /// **'غير محدد'**
  String get unspecified;

  /// No description provided for @update.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get update;

  /// No description provided for @updateAvailable.
  ///
  /// In ar, this message translates to:
  /// **'تحديث جديد متاح'**
  String get updateAvailable;

  /// No description provided for @updateNow.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الآن'**
  String get updateNow;

  /// No description provided for @updateReady.
  ///
  /// In ar, this message translates to:
  /// **'تحديث متاح'**
  String get updateReady;

  /// No description provided for @version.
  ///
  /// In ar, this message translates to:
  /// **'إصدار'**
  String get version;

  /// No description provided for @wallet.
  ///
  /// In ar, this message translates to:
  /// **'المحفظة'**
  String get wallet;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تتبع مصاريفك بسهولة\nبالدينار الليبي'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeToTwela.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك في Twela'**
  String get welcomeToTwela;

  /// No description provided for @withdraw.
  ///
  /// In ar, this message translates to:
  /// **'اسحب'**
  String get withdraw;

  /// No description provided for @withdrawFromGoal.
  ///
  /// In ar, this message translates to:
  /// **'اسحب من الحصالة'**
  String get withdrawFromGoal;

  /// No description provided for @withdrawFromSavings.
  ///
  /// In ar, this message translates to:
  /// **'سحب من الادخار'**
  String get withdrawFromSavings;

  /// No description provided for @withdrawToWallet.
  ///
  /// In ar, this message translates to:
  /// **'اسحب إلى المحفظة'**
  String get withdrawToWallet;

  /// No description provided for @withdrawal.
  ///
  /// In ar, this message translates to:
  /// **'سحب'**
  String get withdrawal;

  /// No description provided for @withinDays.
  ///
  /// In ar, this message translates to:
  /// **'خلال {duration} يوم'**
  String withinDays(Object duration);

  /// No description provided for @youAreUpToDate.
  ///
  /// In ar, this message translates to:
  /// **'أنت تستخدم أحدث إصدار'**
  String get youAreUpToDate;

  /// No description provided for @yourGoal.
  ///
  /// In ar, this message translates to:
  /// **'هدفك'**
  String get yourGoal;

  /// No description provided for @allAccounts.
  ///
  /// In ar, this message translates to:
  /// **'كل الحسابات'**
  String get allAccounts;

  /// No description provided for @myDebts.
  ///
  /// In ar, this message translates to:
  /// **'ديون لي'**
  String get myDebts;

  /// No description provided for @totalBalanceLabel.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد الكلي'**
  String get totalBalanceLabel;

  /// No description provided for @cashBalanceLabel.
  ///
  /// In ar, this message translates to:
  /// **'رصيد الكاش'**
  String get cashBalanceLabel;

  /// No description provided for @bankBalanceLabel.
  ///
  /// In ar, this message translates to:
  /// **'رصيد المصرف'**
  String get bankBalanceLabel;

  /// No description provided for @todayIncome.
  ///
  /// In ar, this message translates to:
  /// **'دخل اليوم'**
  String get todayIncome;

  /// No description provided for @quickIncome.
  ///
  /// In ar, this message translates to:
  /// **'دخل'**
  String get quickIncome;

  /// No description provided for @quickExpense.
  ///
  /// In ar, this message translates to:
  /// **'مصروف'**
  String get quickExpense;

  /// No description provided for @quickSavings.
  ///
  /// In ar, this message translates to:
  /// **'ادخار'**
  String get quickSavings;

  /// No description provided for @quickDebt.
  ///
  /// In ar, this message translates to:
  /// **'دين'**
  String get quickDebt;

  /// No description provided for @settled.
  ///
  /// In ar, this message translates to:
  /// **'مسدّدة'**
  String get settled;

  /// No description provided for @paidOff.
  ///
  /// In ar, this message translates to:
  /// **'تم السداد'**
  String get paidOff;
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
