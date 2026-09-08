# Twela — خطة الإصلاح الأخيرة (v6)
> ملف نهائي واحد يجمع كل ما تبقى. نفّذ بالترتيب، وبعد كل بند تأكد من معيار القبول قبل ما تكمل.

---

## P0 — السبب الجذري المؤكد لمربع "السجل" الرمادي

**الملف:** `lib/main.dart`
**السبب المؤكد 100%:** دوال التاريخ بـ`lib/utils/formatters.dart` (`formatDate`, `formatDateTime`, `formatMonthYear`) تستخدم `DateFormat(..., 'ar')`، وهذا يتطلب استدعاء `initializeDateFormatting('ar')` قبل الاستخدام — وهذا الاستدعاء **غير موجود بالمشروع إطلاقًا**. أي شاشة تعرض تاريخ حركة (وعلى رأسها `TransactionTile` المستخدمة بكل صف بالسجل) تنهار بصمت أثناء البناء، وبوضع Release يظهر مربع رمادي فاضي بدل رسالة الخطأ.

**الإصلاح (طبّقه بالضبط):**
```dart
// lib/main.dart
import 'package:intl/date_symbol_data_local.dart';   // ⬅️ سطر جديد

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null);          // ⬅️ سطر جديد — أول شي بعد ensureInitialized

  final storageService = StorageService();
  await storageService.init();
  await NotificationService.init();

  runApp(
    MultiProvider(
      // ... باقي الكود بدون تغيير
    ),
  );
}
```

**معيار القبول:**
1. أضف حركة صرف أو دخل واحدة على الأقل.
2. افتح شاشة "السجل" → لازم تشوف الحركة فعليًا (كارت فيه التصنيف، المبلغ، والتاريخ) — مو مربع رمادي.
3. راجع أي شاشة ثانية فيها تاريخ (تفاصيل الدين، الإحصائيات، الحصالة) وتأكد ما فيها نفس الانهيار.

---

## P1 — تفعيل "اكتشاف العملة بالموقع" فعليًا (أو تحويلها زر يدوي آمن)

**الملف:** `pubspec.yaml`, `lib/providers/app_settings_provider.dart`, شاشة الإعدادات

**الوضع الحالي:** المفتاح يقلب Boolean ويحفظه بس — بدون طلب صلاحية فعلي، وبدون مكتبة `geolocator` أصلًا بالمشروع.

**التوصية:** حوّلها من "مفتاح تشغيل دائم بالخلفية" إلى **زر يدوي صريح** — أأمن لمراجعة المتجر وأوضح للمستخدم:

1. أضف بـ`pubspec.yaml`: `geolocator: ^11.0.0`
2. بدّل الـ`Switch` بشاشة الإعدادات إلى زر "اكتشف عملتي الآن" (`ElevatedButton` أو `ListTile` بسهم).
3. عند الضغط:
```dart
Future<void> detectCurrencyFromLocation(BuildContext context) async {
  final permission = await Permission.location.request();
  if (!permission.isGranted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('الصلاحية مرفوضة — تقدر تفعّلها من إعدادات الجهاز')),
    );
    return;
  }

  final position = await Geolocator.getCurrentPosition();
  // TODO: مرر position.latitude/longitude لخدمة Reverse Geocoding
  // (مثلاً geocoding package) لتحديد الدولة، ثم خريطة دولة→عملة ثابتة بالكود
}
```
4. النتيجة تُعرض كاقتراح ("عملتك المكتشفة: مصر — جنيه مصري، تبي تبدلها؟") — المستخدم يأكد يدويًا، ما يتبدل شي تلقائيًا بصمت.

**معيار القبول:** تضغط الزر، تنفتح نافذة نظام لطلب صلاحية الموقع فعليًا (هذا كان مفقود بالكامل قبل الإصلاح)، وبعد الموافقة يوصلك اقتراح عملة تأكده بنفسك.

---

## P1 — تفعيل "وضع الزجاج" فعليًا (أو حذفه مؤقتًا)

**الملف:** `lib/widgets/balance_card.dart` وأي كارت رئيسي ثاني

**الوضع الحالي:** `AppSettingsProvider.glassMode` يُحفظ بس ما يقرأه أي Widget.

**الإصلاح:** بكارت الرصيد الرئيسي تحديدًا (أهم عنصر بصري بالتطبيق):
```dart
@override
Widget build(BuildContext context) {
  final glass = context.watch<AppSettingsProvider>().glassMode;
  final cardContent = /* الكود الحالي لمحتوى الكارت */;

  if (!glass) return cardContent;

  return ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: cardContent,
      ),
    ),
  );
}
```
طبّقها بس على 1-2 كارت رئيسي (الرصيد، وربما كارت الديون بالرئيسية) — مو كل عنصر، عشان الأداء يبقى سلس بالأجهزة الأضعف.

**بديل أسرع لو الوقت ضيق:** لو مو أولوية الحين، اخفِ المفتاح مؤقتًا من شاشة الإعدادات (`if (false)` أو علّق السطر) بدل ما يبقى ظاهر وما يسوي شي — مفتاح معطّل بصمت يعطي انطباع إن التطبيق مكسور حتى لو باقي كل شي تمام.

---

## قائمة تحقق أخيرة (نفّذها بعد P0 مباشرة، بما إن السجل كان يحجب رؤية نتائج إصلاحات سابقة)

بما إن مربع السجل كان يخفي عليك التحقق الفعلي من عدة بنود سابقة، بعد ما تطبّق P0 راجع هذي بسرعة وأخبرني لو أي وحدة منها لسا ناقصة:

- [ ] إعطاء/استلام دين → ينقص/يزيد الرصيد فعليًا (كان بند P0-2 بخطة v4).
- [ ] تسديد دين → يأثر على الرصيد بعكس اتجاه الدين الأصلي.
- [ ] إضافة ادخار يومي → ينقص من الكاش/المصرف المختار.
- [ ] فلتر "ديون" و"ادخار" بشاشة السجل يعرض الحركات فعليًا (يعتمد على P0-2 + هذا الإصلاح مع بعض).
- [ ] شاشة الإحصائيات — تاريخ الشهر يعرض صح بدون انهيار (تستخدم `formatMonthYear` غالبًا، نفس فخ P0).

---

## الترتيب النهائي
1. **P0** (سطرين بـ`main.dart`) — نفّذه أول شي، وبعده افتح كل شاشة فيها تاريخ وتأكد ما فيه انهيار.
2. **قائمة التحقق** فوق — راجعها كلها الحين إن الحجاب انشال عن السجل.
3. **P1 الموقع** — حوّلها زر يدوي آمن.
4. **P1 الزجاج** — فعّلها فعليًا أو أخفها مؤقتًا.
