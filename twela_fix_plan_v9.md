# Twela — خطة إصلاح v9

## P0: أيقونة "الديون" مخفية تحت زر "+" العائم

**الملف:** `lib/app.dart` — كلاس `_MainScreenState.build()`

**السبب المؤكد:** الـ`Row` فيها 5 عناصر بـ`MainAxisAlignment.spaceAround`، فالعنصر الأوسط رياضيًا (index 2 = "الديون") يقع بالضبط بمنتصف عرض الشريط. وزر "+" العائم مموضع بـ`Positioned(left: 0, right: 0, child: Center(...))` — يعني يتمركز بنفس نقطة المنتصف بالضبط. النتيجة: الزر يغطي أيقونة "الديون" حرفيًا (النص يبين تحته بس الأيقونة مخفية).

**الإصلاح: أضف فراغ فارغ (Placeholder) بمنتصف الـRow خصيصًا للزر العائم، بحيث ولا عنصر حقيقي يقع بنفس نقطة المنتصف:**

```dart
child: SizedBox(
  height: 64,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      _buildItem(context, 0, Icons.home_outlined, Icons.home, 'الرئيسية', primaryColor, isDark),
      _buildItem(context, 1, Icons.receipt_long_outlined, Icons.receipt_long, 'السجل', primaryColor, isDark),
      const SizedBox(width: 56),   // ⬅️ فراغ بعرض الزر العائم بالضبط — يمتص المنتصف الهندسي
      _buildItem(context, 2, Icons.people_outline, Icons.people, 'الديون', primaryColor, isDark),
      _buildItem(context, 3, Icons.bar_chart_outlined, Icons.bar_chart, 'الإحصائيات', primaryColor, isDark),
      _buildItem(context, 4, Icons.settings_outlined, Icons.settings, 'الإعدادات', primaryColor, isDark),
    ],
  ),
),
```

**ملاحظة مهمة:** بعد هذا التغيير، "الديون" ما تصير بالمنتصف الهندسي بعد — بتنزاح شوي لليمين (لأن السطر صار 6 عناصر: 5 أزرار + فراغ وحد، مو 5 بالظبط). هذا مقبول ومتوقع، المهم إن ولا أيقونة تتغطى. لو حبيت توزيع أدق (كل الأزرار الخمسة بمسافات متساوية بالضبط بعيدًا عن الفراغ)، بديل أدق:

```dart
Row(
  children: [
    Expanded(child: _buildItem(context, 0, ..., 'الرئيسية', ...)),
    Expanded(child: _buildItem(context, 1, ..., 'السجل', ...)),
    const SizedBox(width: 56),
    Expanded(child: _buildItem(context, 2, ..., 'الديون', ...)),
    Expanded(child: _buildItem(context, 3, ..., 'الإحصائيات', ...)),
    Expanded(child: _buildItem(context, 4, ..., 'الإعدادات', ...)),
  ],
)
```
هذا يوزع المساحة المتبقية (بعد طرح 56 بكسل) بالتساوي على الخمس أزرار، فتصير متناسقة الحجم مهما كان عرض الشاشة.

**معيار القبول:** افتح أي شاشة، شوف شريط التنقل — لازم تشوف 5 أيقونات واضحة كاملة بدون أي تراكب مع زر "+"، و"الديون" تحديدًا تبين أيقونتها (شخصين 👥) فوق النص مباشرة.
