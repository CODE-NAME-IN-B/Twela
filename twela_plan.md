# خطة Twela الكاملة — تطبيق تتبع المصاريف (Flutter)
> نسخة نهائية جاهزة للتنفيذ — تتضمن الميزات، البنية، الـ Widgets، وتقسيم الملفات بالتفصيل.

---

## 1. فكرة التطبيق

تطبيق موبايل بالدينار الليبي (LYD) اسمه **Twela**:
- محفظتين: **كاش** و**مصرف** — كل حركة (دخل/صرف) مربوطة بواحدة منهم.
- تسجيل صرف: مبلغ + تصنيف + طريقة الدفع + ملاحظة اختيارية.
- حدود صرف (يومي/شهري/لكل تصنيف) + تنبيه رصيد منخفض — **كلها قابلة للتعديل من المستخدم بأي وقت**.
- الديون: تتبع أشخاص تديهم فلوس، كم دفعت، كم باقي.
- ميزة "يتعلم منك": تكتشف روتين الصرف المتكرر وتقترح عليك تسجيله تلقائيًا (بدون خصم صامت أبدًا كافتراضي).
- Widgets للشاشة الرئيسية: رصيد، صرف اليوم، إضافة سريعة.
- واجهة نظيفة عصرية (Apple × Notion)، لون أساسي `#0A846B` من الشعار.

---

## 2. التقنيات (Tech Stack)

| الغرض | المكتبة |
|---|---|
| إدارة الحالة | `provider` |
| تخزين محلي | `shared_preferences` (JSON) — ترقية لاحقة إلى `sqflite`/`Hive` ممكنة بدون كسر المعمارية |
| إشعارات محلية | `flutter_local_notifications` |
| Widgets الشاشة الرئيسية | `home_widget` |
| تنسيق أرقام/تواريخ | `intl` |
| معرّفات فريدة | `uuid` |
| رسوم بيانية | `fl_chart` |
| خطوط | `google_fonts` (Inter / Manrope) |
| توليد أيقونة التطبيق تلقائيًا لكل المقاسات | `flutter_launcher_icons` (dev dependency) |

---

## 3. نماذج البيانات (Data Models)

### 3.1 `ExpenseCategory`
```
id, name, icon, color, monthlyLimit: double?
```

### 3.2 `TwelaTransaction`
```
id: String
amount: double
type: enum { income, expense }
walletType: enum { cash, bank }
categoryId: String              // فارغ إذا income
note: String
date: DateTime
```

### 3.3 `WalletSettings`
```
initialCashBalance: double
initialBankBalance: double
```
```
cashBalance  = initialCashBalance + مجموع transactions (cash)
bankBalance  = initialBankBalance + مجموع transactions (bank)
totalBalance = cashBalance + bankBalance
```

### 3.4 `Debt`
```
id, personName, itemDescription, totalAmount, paidAmount, date
remaining  => totalAmount - paidAmount
isPaidOff  => remaining <= 0
```

### 3.5 `RoutinePattern` (تعلم الروتين)
```
id: String
categoryId: String
approxAmount: double
amountTolerance: double
timeWindowStart / timeWindowEnd: TimeOfDay
daysOfWeek: List<int>
occurrenceCount: int
status: enum { learning, suggesting, autoConfirmed, dismissed }
lastTriggeredDate: DateTime?
note: String
```

### 3.6 إعدادات الحدود (BudgetSettings)
```
monthlyBudgetTotal: double?
dailySpendingLimit: double?
lowBalanceThreshold: double?
```
> بيانات مستخدم عادية تُقرأ/تُكتب عبر `StorageService`، قابلة للتعديل في أي وقت من الإعدادات.

---

## 4. منطق التنبيهات (Notification Rules)

بعد كل عملية **صرف جديدة** يتفحص:
1. سقف التصنيف الشهري → 80% تحذير، 100% تجاوز.
2. سقف الصرف اليومي → تنبيه فوري عند التجاوز.
3. سقف الميزانية الشهرية الإجمالية → 80% / 100%.
4. الرصيد المنخفض (إجمالي) → تنبيه.

يُحفظ "آخر نسبة تم التنبيه عندها" لكل حد لتفادي تكرار نفس التنبيه بلا داعي.

---

## 5. الميزة الذكية: تعلم روتين الصرف

### مراحل الثقة
1. **`learning`**: أول 1-2 تكرار، تسجيل داخلي بس، بدون أي إشعار.
2. **`suggesting`**: بعد 3-4 تكرارات متتالية بنفس التصنيف/المبلغ التقريبي/الوقت، يبعث إشعار اقتراح وقت النافذة الزمنية المتوقعة، بزر "نعم/لا" مباشر.
3. **`autoConfirmed`**: يفعّله المستخدم يدويًا لكل نمط من الإعدادات. حتى بهذي الحالة، يوصل إشعار إعلامي بعد كل خصم تلقائي — شفافية كاملة، بدون خصم صامت مطلقًا.

### المرونة
- نمط ما يتكرر لمدة 2-3 أسابيع → يرجع تلقائيًا لحالة `dismissed`.
- المبلغ/التوقيت يُحسب كمتوسط متحرك على آخر N حدوث (مو رقم ثابت)، فينزاح تدريجيًا مع تغيّر روتين المستخدم الفعلي.

### Pseudocode للاكتشاف
```
لكل عملية صرف جديدة:
  دوّر على حركات سابقة (30 يوم) بنفس التصنيف
  بمبلغ قريب (± amountTolerance) وبنفس نافذة الوقت (± 45 دقيقة)

  إذا عدد التطابقات >= 3:
     أنشئ/حدّث RoutinePattern (حالة learning)
     إذا occurrenceCount >= 4: الحالة => suggesting

  إذا الحالة suggesting ووصل وقت النافذة المتوقعة:
     أرسل إشعار اقتراح (يحتاج تأكيد المستخدم)

  إذا الحالة autoConfirmed ووصل وقت النافذة:
     سجّل الحركة تلقائيًا + أرسل إشعار إعلامي بعدها
```

### التحكم
شاشة `routine_settings_screen`: مفتاح تشغيل/إيقاف عام + قائمة الأنماط، كل نمط يقدر "يرفعه لتلقائي" أو "يوقفه" أو "يحذفه".

---

## 6. Widgets الشاشة الرئيسية

ثلاث ودجات (بناءً على تصاميم AI المعتمدة):

| Widget | المحتوى | التحديث |
|---|---|---|
| **Balance Widget** | الرصيد الإجمالي + وقت آخر تحديث | عند كل تغيّر بالرصيد |
| **Today Spending Widget** | صرف اليوم مقابل الحد اليومي + شريط تقدم | عند كل عملية صرف جديدة |
| **Quick Add Widget** | زر (+) يفتح `add_transaction_screen` مباشرة | ثابت، مو محتاج تحديث بيانات |

### آلية العمل التقنية
- الحزمة: `home_widget` (تدعم مزامنة بيانات بين Flutter وAndroid/iOS Widgets عبر `App Group` بـiOS و`SharedPreferences` بـAndroid).
- كل مرة يتغيّر الرصيد أو صرف اليوم في `TwelaProvider`، يستدعي `HomeWidgetService.updateWidgets()` اللي يسوي:
  ```dart
  await HomeWidget.saveWidgetData<String>('balance', formatLyd(balance));
  await HomeWidget.saveWidgetData<String>('today_spent', formatLyd(todaySpent));
  await HomeWidget.saveWidgetData<String>('daily_limit', formatLyd(dailyLimit ?? 0));
  await HomeWidget.updateWidget(
    androidName: 'TwelaWidgetProvider',
    iOSName: 'TwelaWidget',
  );
  ```
- **Android**: يحتاج ملف `TwelaWidgetProvider.kt` (Kotlin) + layout XML (`widget_balance.xml`) داخل `android/app/src/main/`. `home_widget` يعطيك تمبلت جاهز تعدل عليه.
- **iOS**: يحتاج إضافة **Widget Extension** من Xcode (كود Swift/SwiftUI منفصل) — هذا الجزء لازم يُعمل من ماك عبر Xcode مباشرة، مو من كود Flutter بس. لو ما عندك ماك حاليًا، ابدأ بـAndroid فقط وأضف iOS لاحقًا.
- **Quick Add Widget**: يستخدم `HomeWidget.registerInteractivityCallback` أو Deep Link (`twela://add`) يفتح `add_transaction_screen` مباشرة عند الضغط.

> **توصية**: نفّذ هذي الميزة آخر شي بعد ما تستقر بيانات `TwelaProvider`، لأنها تعتمد على بيانات جاهزة أصلاً.

---

## 7. تدفق المستخدم (User Flow)

```mermaid
flowchart TD
    A[فتح التطبيق لأول مرة] --> B[شاشة ترحيب: رصيد ابتدائي كاش+مصرف]
    B --> C[الشاشة الرئيسية]

    C --> D[+ إضافة صرف]
    C --> E[+ إضافة دخل]
    C --> F[الديون]
    C --> G[الإحصائيات]
    C --> H[الإعدادات]

    D --> D1[كاش أو مصرف؟] --> D2[اختيار التصنيف] --> D3[المبلغ + ملاحظة] --> D4[حفظ]
    D4 --> I{تجاوز حد؟}
    I -- نعم --> J[إشعار فوري]
    I -- لا --> C

    E --> E1[كاش أو مصرف؟] --> E2[المبلغ + ملاحظة] --> C

    F --> F1[+ دين جديد] 
    F --> F2[دين موجود: + إضافة دفعة]

    H --> H1[الميزانية الشهرية]
    H --> H2[الحد اليومي]
    H --> H3[حد الرصيد المنخفض]
    H --> H4[سقف كل تصنيف]
    H --> H5[الرصيد الابتدائي]
    H --> H6[إعدادات \"يتعلم منك\"]

    K[نمط متكرر مكتشف] --> L{مستوى الثقة؟}
    L -- suggesting --> M[إشعار اقتراح]
    M -- موافقة --> D4
    M -- رفض --> C
    L -- autoConfirmed --> N[تسجيل تلقائي + إشعار إعلامي]

    O[Home Screen Widget] -.-> C
    O -.->|Quick Add| D
```

---

## 8. هيكل المشروع الكامل (Folder Structure)

```
twela/
  pubspec.yaml

  assets/
    logo/
      twela_logo.png              // الشعار الكامل (يُستخدم داخل التطبيق: onboarding، شاشة تحميل...)
      twela_logo_mono.png         // نسخة أحادية اللون (للوضع الداكن أو الطباعة)
    icon/
      app_icon_source.png         // ⚠️ ملف مصدر وحيد بمقاس 1024x1024 — منه تتولد كل أيقونات المنصات تلقائيًا (لا تحطه بنفسك بكل مقاس)

  lib/
    main.dart
    app.dart                        // MaterialApp + الثيم + المسارات (Routes)

    models/
      category.dart
      transaction.dart
      wallet_settings.dart
      budget_settings.dart
      debt.dart
      routine_pattern.dart

    services/
      storage_service.dart          // كل القراءة/الكتابة المحلية (shared_preferences)
      notification_service.dart     // تهيئة وإرسال الإشعارات
      routine_detection_service.dart // منطق اكتشاف الأنماط (القسم 5)
      home_widget_service.dart      // مزامنة البيانات مع Widgets (القسم 6)

    providers/
      twela_provider.dart           // رصيد، حركات، تصنيفات، محافظ، تنبيهات الحدود
      debt_provider.dart            // منطق الديون بالكامل
      routine_provider.dart         // حالة أنماط الروتين + التفاعل معها

    screens/
      onboarding/
        onboarding_screen.dart
      home/
        home_screen.dart
      transactions/
        add_transaction_screen.dart
        history_screen.dart
      budget/
        settings_screen.dart
        routine_settings_screen.dart
      debts/
        debts_screen.dart
        add_debt_screen.dart
        debt_detail_screen.dart
      stats/
        stats_screen.dart

    widgets/                         // ودجات Flutter داخل التطبيق نفسه (مو home screen widgets)
      balance_card.dart
      wallet_mini_card.dart          // كارت كاش/مصرف الصغير بالرئيسية
      wallet_toggle.dart             // Segmented control كاش/مصرف
      transaction_tile.dart
      debt_tile.dart
      category_picker.dart
      limit_progress_bar.dart        // قابل لإعادة الاستخدام (تصنيفات + ديون + حدود)

    theme/
      app_theme.dart                 // الألوان، الخطوط، الزوايا (جدول القسم 9)
      app_colors.dart                // ثوابت الألوان بس (يُستدعى من app_theme)

    utils/
      formatters.dart                // formatLyd, formatDate, formatDateTime

  android/
    app/src/main/
      kotlin/.../TwelaWidgetProvider.kt   // Android Home Widget (القسم 6)
      res/
        layout/
          widget_balance.xml
          widget_today_spending.xml
          widget_quick_add.xml
        mipmap-mdpi/ic_launcher.png       // ⚠️ تُولّد تلقائيًا من app_icon_source.png
        mipmap-hdpi/ic_launcher.png       //     عبر flutter_launcher_icons — ما تسويها يدوي
        mipmap-xhdpi/ic_launcher.png
        mipmap-xxhdpi/ic_launcher.png
        mipmap-xxxhdpi/ic_launcher.png

  ios/
    TwelaWidget/                     // Xcode Widget Extension (يُضاف لاحقًا من Xcode)
    Runner/
      Assets.xcassets/
        AppIcon.appiconset/          // ⚠️ تُولّد تلقائيًا من app_icon_source.png عبر flutter_launcher_icons
```

### توليد أيقونة التطبيق (خطوة واحدة بس)
ما تحتاج تصدّر كل مقاس بنفسك. تحط ملف واحد فقط `assets/icon/app_icon_source.png` بمقاس **1024×1024** (بدون زوايا دائرية — الأداة تسوي القص المناسب لكل منصة)، وتضيف بـ`pubspec.yaml`:
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon_source.png"
```
وتشغّل مرة وحدة:
```
flutter pub run flutter_launcher_icons
```
وتتوزع تلقائيًا على كل مجلدات `mipmap-*` (أندرويد) و`AppIcon.appiconset` (آيفون).

### الشعار داخل التطبيق (غير أيقونة التطبيق)
الشعار اللي يظهر بشاشة onboarding أو شاشة تحميل (Splash) هو ملف عادي بمجلد `assets/logo/`، لازم يُسجّل بـ`pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/logo/
```
ويُستخدم بالكود عادي: `Image.asset('assets/logo/twela_logo.png')`.

### مبدأ التقسيم
- **حسب النوع (Type-first)** مو حسب الميزة — مناسب لحجم المشروع الحالي ولأنك تبدأ لحالك؛ أسهل تتنقل فيه بأداة AI IDE. لو المشروع كبر كثير مستقبلًا (5+ مطورين أو عشرات الشاشات)، ينتقل بسهولة إلى تنظيم `features/` لأن الفصل بين models/services/providers واضح من البداية.
- **كل شاشة كبيرة بمجلدها الخاص** (`transactions/`, `debts/`, `budget/`, `stats/`) — حتى لو فيها ملف واحد الحين، يسهل تضيف ملفات مساعدة (widgets خاصة بالشاشة) بدون ما تفوضي `widgets/` العام.
- **`theme/` منفصل عن `utils/`**: التصميم (ألوان/خطوط) شي، والدوال المساعدة (تنسيق أرقام) شي ثاني — يوضح الفرق لأي شخص يفتح المشروع.

---

## 9. نظام التصميم (UI Design System) — Apple × Notion

- **البساطة**: شاشة وحدة = مهمة وحدة، بدون ازدحام.
- **البطاقات**: زوايا 16-20px، ظل ناعم خفيف، بدون حدود ثقيلة.
- **الطباعة**: `google_fonts` (Inter/Manrope)، أرقام مالية كبيرة Bold وTabular.
- **الألوان**:

  | الاستخدام | اللون |
  |---|---|
  | Accent الأساسي (من الشعار) | `#0A846B` |
  | خلفية فاتحة/بطاقات | `#F5F9F8` |
  | نجاح/دخل | `#149C6D` |
  | تحذير 80% | `#F5A524` |
  | خطر/تجاوز | `#E5484D` |
  | نص أساسي (فاتح/داكن) | `#141414` / `#F5F5F5` |
  | نص ثانوي | `#6B7280` |

- **الأيقونات**: Outline رفيع، رمادية افتراضيًا، تتلون بلون التصنيف عند الحاجة بس.
- **الحركة**: انتقالات 200-300ms، عدّاد متحرك للأرقام عند التحديث.
- **التنقل السفلي**: 5 عناصر ثابتة الاسم بكل الشاشات: **الرئيسية، السجل، الديون، الإحصائيات، الإعدادات**.
- **الوضع الليلي**: أصلي من اليوم الأول.
- **الفراغ**: هوامش كافية حول كل عنصر.

---

## 10. المرونة للمستقبل (Extensibility)

- كل وصول للبيانات يمر من `StorageService` فقط → ترقية التخزين مستقبلًا (sqflite/Hive) ما تلمس أي شاشة.
- الحدود والتنبيهات مبنية كنظام عام (Rule-based) → سهل تضيف نوع تنبيه جديد بدون تعديل المنطق الأساسي.
- أفكار جاهزة تنضاف على نفس الأساس: أهداف ادخار، فواتير متكررة، دعم أكثر من عملة، مزامنة سحابية، دعم عائلة/مستخدمين متعددين.

---

## 11. مراحل التنفيذ (Roadmap) — تفصيلية بالملفات

**المرحلة 1 — الأساس + المحافظ**
- `models/` كاملة (category, transaction, wallet_settings)
- `services/storage_service.dart`
- `providers/twela_provider.dart`
- `screens/onboarding/onboarding_screen.dart`
- `screens/home/home_screen.dart`
- `screens/transactions/add_transaction_screen.dart` + `history_screen.dart`
- `theme/app_theme.dart` بالألوان النهائية من الآن (مو لاحقًا)

**المرحلة 2 — الميزانيات والتنبيهات**
- `models/budget_settings.dart`
- `screens/budget/settings_screen.dart`
- `services/notification_service.dart` + منطق الفحص داخل `twela_provider.dart`

**المرحلة 3 — الديون**
- `models/debt.dart` + `providers/debt_provider.dart`
- `screens/debts/` الثلاث شاشات

**المرحلة 4 — الإحصائيات + تلميع الواجهة**
- `screens/stats/stats_screen.dart` (fl_chart)
- مراجعة كل شاشة على القسم 9، توحيد أسماء شريط التنقل

**المرحلة 5 — الذكاء: تعلم الروتين**
- `models/routine_pattern.dart` + `services/routine_detection_service.dart`
- `providers/routine_provider.dart` + `screens/budget/routine_settings_screen.dart`

**المرحلة 6 — Widgets الشاشة الرئيسية**
- `services/home_widget_service.dart`
- Android: `TwelaWidgetProvider.kt` + XML layouts
- iOS: Widget Extension من Xcode (لاحقًا لو توفر ماك)

**المرحلة 7 (مستقبلي)**
- ترقية التخزين لـ`sqflite`
- أهداف ادخار، فواتير متكررة، تصدير تقارير، نسخ احتياطي
