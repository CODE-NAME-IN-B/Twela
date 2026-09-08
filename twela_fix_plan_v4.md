# Twela — خطة إصلاح شاملة v4
> مبنية على فحص فعلي لكل ملفات السورس كود ذات الصلة بتاريخ اليوم. الأولوية بالترتيب: P0 أولًا وإلا باقي الإصلاحات ما راح تظهر نتيجتها للمستخدم أبدًا.

## ⚠️ قبل أي شي: لا تنفذ أي بند تحت غير P0-1 قبل ما تتأكد إنه انحل ويشتغل فعليًا على جهاز حقيقي.

---

## P0-1 (حرج جدًا، لسا غير محلول): توقيع الإصدارات

**الحالة الحالية المؤكدة الآن:** `android/app/build.gradle` لسا فيه:
```gradle
buildTypes {
    release {
        signingConfig signingConfigs.debug
    }
}
```
هذا **نفس المشكلة من الجولة اللي فاتت، ما انطبق الإصلاح لسا**. طالما هذا موجود، أي بناء جديد (حتى لو صلحت كل شي تحت) بيصير بتوقيع عشوائي مختلف عن التثبيت الحالي، وما راح يثبت فوقه.

**الإصلاح (كرره بالضبط، هذا أهم بند بالملف كله):**
1. أنشئ Keystore ثابت مرة وحدة: `keytool -genkey -v -keystore twela-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias twela`
2. أضف `*.jks` و`key.properties` لـ`.gitignore`.
3. حوّله Base64 (`base64 -w 0 twela-release.jks`) وخزنه بـGitHub Secrets باسم `KEYSTORE_BASE64` + `KEYSTORE_PASSWORD` + `KEY_ALIAS` + `KEY_PASSWORD`.
4. عدّل `build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```
5. عدّل `.github/workflows/build.yml` — أضف قبل خطوة "Build APK":
```yaml
      - name: Decode Keystore
        run: |
          echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/app/twela-release.jks
          cat <<EOF > android/key.properties
          storePassword=${{ secrets.KEYSTORE_PASSWORD }}
          keyPassword=${{ secrets.KEY_PASSWORD }}
          keyAlias=${{ secrets.KEY_ALIAS }}
          storeFile=twela-release.jks
          EOF
```

**معيار القبول (لا تكمل قبل ما تتأكد منه فعليًا):** ابنِ تاق جديد (مثلًا `v1.0.8`)، ثبّته (بعد إلغاء التثبيت اليدوي الأخير مرة وحدة بس)، بعدين ابنِ `v1.0.9` وحدّث فوق `v1.0.8` **بدون حذف** — لازم يثبت مباشرة. لو ما اشتغل هذا، توقف هنا ولا تكمل باقي البنود.

---

## P0-2: الديون والادخار معزولة تمامًا عن رصيدك (خلل حسابي حقيقي)

**التأكيد من الكود:** `DebtProvider.addDebt/addPayment` و`SavingsProvider.addEntry` كلهم يحفظون بياناتهم الخاصة بس (`saveDebts`, `saveSavingsEntries`) **بدون** ما يمرّون أبدًا عبر `TwelaProvider.addTransaction()`. النتيجة:
- تعطي شخص 200 د.ل → رصيدك بالرئيسية ما يتغير أبدًا (خطأ محاسبي خطير بتطبيق فلوس).
- تستلم دفعة سداد → نفس الشي، ما ينعكس على رصيدك.
- تضيف ادخار يومي → ما يُخصم من كاش/مصرف فعليًا.
- فلتر "ديون" و"ادخار" بشاشة السجل فاضي **دايمًا وبكل الحالات** — لأنه ما فيه أي كود بالمشروع كله ينشئ `TwelaTransaction` بنوع `debtGiven`/`debtReceived`/`debtPayment`/`savings` (رغم إن الـenum نفسه معرّف بـ`transaction.dart`).

**خطوات الإصلاح:**

### أ) اربط الـProviders ببعض بـ`ChangeNotifierProxyProvider`
عدّل `lib/main.dart`، غيّر ترتيب وتعريف الـProviders عشان `DebtProvider` و`SavingsProvider` ياخذوا مرجع لـ`TwelaProvider`:
```dart
ChangeNotifierProvider(create: (_) => TwelaProvider(storageService)),
ChangeNotifierProxyProvider<TwelaProvider, DebtProvider>(
  create: (_) => DebtProvider(storageService, null),
  update: (_, twelaProvider, debtProvider) =>
      debtProvider!..attachLedger(twelaProvider),
),
ChangeNotifierProxyProvider<TwelaProvider, SavingsProvider>(
  create: (_) => SavingsProvider(storageService, null),
  update: (_, twelaProvider, savingsProvider) =>
      savingsProvider!..attachLedger(twelaProvider),
),
```

### ب) أضف بـ`TwelaProvider` دالة عامة لإضافة حركة من مصدر خارجي (تُستخدم بدل `addTransaction` مباشرة عشان توضح القصد):
لا حاجة لدالة جديدة فعليًا — الدالة `addTransaction()` الموجودة صالحة، بس المطلوب إن `DebtProvider`/`SavingsProvider` يستدعوها.

### ج) عدّل `DebtProvider`:
```dart
class DebtProvider extends ChangeNotifier {
  final StorageService _storage;
  TwelaProvider? _ledger;
  DebtProvider(this._storage, this._ledger);
  void attachLedger(TwelaProvider ledger) => _ledger = ledger;

  Future<void> addDebt(Debt debt) async {
    _debts.insert(0, debt);
    await _storage.saveDebts(_debts);

    // ⬅️ جديد: سجّل الحركة على الرصيد
    await _ledger?.addTransaction(TwelaTransaction(
      id: const Uuid().v4(),
      amount: debt.totalAmount,
      type: debt.isGiven ? TransactionType.debtGiven : TransactionType.debtReceived,
      walletType: WalletType.cash, // أو اسأل المستخدم كاش/مصرف بشاشة الإضافة (راجع P1-3)
      categoryId: '',
      note: '${debt.personName} - ${debt.itemDescription}',
      date: debt.date,
      relatedId: debt.id,
    ));

    notifyListeners();
  }

  Future<void> addPayment(String debtId, double amount) async {
    final index = _debts.indexWhere((d) => d.id == debtId);
    if (index == -1) return;
    final debt = _debts[index];
    _debts[index] = debt.copyWith(paidAmount: debt.paidAmount + amount);
    await _storage.saveDebts(_debts);

    // ⬅️ جديد: دفعة السداد تؤثر بعكس اتجاه الدين الأصلي
    await _ledger?.addTransaction(TwelaTransaction(
      id: const Uuid().v4(),
      amount: amount,
      type: TransactionType.debtPayment,
      walletType: WalletType.cash,
      categoryId: '',
      note: 'سداد: ${debt.personName}',
      date: DateTime.now(),
      relatedId: debt.id,
    ));

    notifyListeners();
  }
}
```
**⚠️ نقطة منطقية مهمة تحتاج تقرر فيها بنفسك قبل التنفيذ:** "أعطيت مالًا" لازم يُنقص الرصيد، و"استلمت مالًا" لازم يزيده — و`debtPayment` (سداد) يعتمد على اتجاه الدين الأصلي (لو أنا مديون وسددت = ينقص رصيدي، لو غيري مديون لي وسدد = يزيد رصيدي). لازم تتأكد إن `TwelaProvider.addTransaction` أو الحسابات (`cashBalance`/`bankBalance`) تفرّق فعليًا بين `debtGiven` (خصم) و`debtReceived` (إضافة) — راجع الـgetters بـ`twela_provider.dart` وأضف لهم شرط لهذي الأنواع الجديدة، مو بس `income`/`expense` زي الوضع الحالي.

### د) نفس المنطق بالضبط لـ`SavingsProvider.addEntry()`:
كل إدخال ادخار يومي ينشئ `TwelaTransaction` بنوع `savings` وينقص من الكاش/المصرف المختار.

**معيار القبول:** أعط شخصًا 100 د.ل من الكاش → رصيد الكاش بالرئيسية ينزل 100 فورًا. سجّل ادخار يومي 20 د.ل → نفس الشي. افتح شاشة السجل وفلتر "ديون" و"ادخار" → تشوف الحركات فعليًا مو فاضية.

---

## P1-3: شاشة "الإحصائيات" مفقودة من شريط التنقل السفلي
**الملف:** `lib/app.dart` (كلاس `MainScreen` و`_BottomNavBar`)
**التأكيد من الكود:** `_screens` الحالية = `[HomeScreen, HistoryScreen, SizedBox, DebtsScreen, SettingsScreen]` — و`_BottomNavBar` نفس الشي: الرئيسية، السجل، [+]، الديون، الإعدادات. **"الإحصائيات" مو موجودة أبدًا** رغم إن الراوت `/stats` موجود ومكتمل بالكود.

**الإصلاح المقترح (يحافظ على الأزرار الخمسة الحقيقية بدون ما الزر العائم ياخذ مكان تبويب):**
1. غيّر `_screens` إلى: `[HomeScreen, HistoryScreen, DebtsScreen, StatsScreen, SettingsScreen]` (5 عناصر حقيقية، بدون `SizedBox`).
2. زر "+" لا يكون تبويب برقم index بالأساس — خليه `Stack` فوق شريط التنقل (مو ضمن `Row` العناصر الخمسة)، بحيث يطفو بمنتصف الشريط بس ما ياخذ مكان أي وجهة حقيقية. هذا نفس أسلوب أبل بالضبط (FAB عائم فوق التاب بار، مو بديل عن تاب).
3. رتّب الخمسة أزرار الحقيقية: الرئيسية، السجل، الديون، الإحصائيات، الإعدادات — بمسافات متساوية، والزر العائم بينهم بالمنتصف البصري فوقهم.

**معيار القبول:** من أي شاشة، تقدر توصل للإحصائيات مباشرة من شريط التنقل السفلي، وبنفس الوقت زر "+" لسا شغّال وواضح بالمنتصف.

---

## P2: النسخ الاحتياطي — خليه يخيّرك مكان الحفظ
**الملف:** `lib/services/data_export_service.dart` + `lib/screens/data/data_export_screen.dart`
**التأكيد من الكود:** `saveExportToFile()` يستخدم `getApplicationDocumentsDirectory()` — مجلد داخلي بالتطبيق ما تقدر توصله من مدير الملفات، والطريقة الوحيدة لإخراج الملف هي "مشاركة" (Share) بعد الحفظ، مو اختيار مباشر لمكان الحفظ. رغم إن `file_picker` (المستخدمة أصلًا بالاستيراد) عندها بالضبط الدالة المطلوبة لهذا: `FilePicker.platform.saveFile()`.

**الإصلاح:**
```dart
// بدل getApplicationDocumentsDirectory() في _exportData بشاشة data_export_screen.dart
Future<void> _exportData() async {
  setState(() => _isExporting = true);
  try {
    final storage = context.read<StorageService>();
    final jsonStr = await DataExportService.exportToJson(storage);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final bytes = utf8.encode(jsonStr);

    final savedPath = await FilePicker.platform.saveFile(
      dialogTitle: 'اختر مكان حفظ النسخة الاحتياطية',
      fileName: 'twela_backup_$timestamp.json',
      bytes: bytes, // على أندرويد/iOS يكتب الملف مباشرة بالمسار المختار
    );

    if (savedPath != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم الحفظ: $savedPath')),
      );
    }
  } catch (e) {
    // نفس معالجة الخطأ الموجودة
  } finally {
    if (mounted) setState(() => _isExporting = false);
  }
}
```
احتفظ بخيار "مشاركة كملف" (Share) الموجود حاليًا كخيار إضافي منفصل، بس خلي "تصدير البيانات" الأساسي يفتح نافذة اختيار مكان صريحة.

**معيار القبول:** تضغط "تصدير البيانات" → تنفتح نافذة نظام تختار فيها المجلد بنفسك (مثلًا Downloads) → الملف يترحفظ هناك فعليًا وتقدر تلقاه بمدير الملفات مباشرة بدون مشاركة.

---

## P3: تنظيف عام
1. `lib/app.dart` بدالة `onTap` بـ`MainScreen`: فيه سطر بلا فائدة `_currentIndex = index > 2 ? index : index;` (نفس النتيجة بكل الحالات). بسّطه إلى `_currentIndex = index;`.
2. **جرد شامل للأزرار غير الشغالة**: بما إن "بعض الأزرار لا تعمل" ملاحظة عامة، نفّذ هذا الجرد يدويًا بعد حل P0-1 و P0-2 (لأنها المسؤولة عن أغلب الأعراض)، وجرّب كل زر بالقائمة التالية وسجّل أي واحد فعليًا ما يستجيب:
   - الشاشة الرئيسية: إضافة صرف، إضافة دخل، سهم كاش، سهم مصرف
   - قائمة "إضافة" السفلية: الخمس خيارات كلهم
   - شاشة الدين: زر +، زر سداد لكل دين، زر حذف بالتفاصيل
   - شاشة الحصالة: زر +، زر "ادخر اليوم" بكل حصالة
   - شاشة الإعدادات: كل مفتاح/حقل فيها
   - شاشة الإحصائيات (بعد ما ترجع للتنقل بـP1-3)

---

## ترتيب التنفيذ النهائي
1. **P0-1** (التوقيع) — نفّذ وتأكد فعليًا قبل أي شي.
2. **P0-2** (ربط الديون/الادخار بالرصيد) — أهم إصلاح منطقي بالتطبيق كله.
3. **P1-3** (رجوع تبويب الإحصائيات).
4. **P2** (اختيار مكان النسخة الاحتياطية).
5. **P3** (تنظيف + جرد الأزرار).
