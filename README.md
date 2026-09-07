# Twela - تطبيق تتبع المصاريف

تطبيق موبايل لتتبع المصاريف بالدينار الليبي (LYD) مبني بـ Flutter.

![Version](https://img.shields.io/badge/version-1.0.2-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Flutter](https://img.shields.io/badge/Flutter-3.24-blue)

---

## المميزات

- **محفظتين**: كاش ومصرف - تتبع كل حركة بالمحفظة المناسبة
- **تصنيفات مصاريف**: واجهة بصرية أنيقة لتصنيف كل صرف
- **حدود الميزانية**: حد يومي/شهري مع تنبيهات عند التجاوز
- **الديون**: تتبع أشخاص تديهم فلوس ودفعاتهم
- **الإحصائيات**: رسوم بيانية تفاعلية لأنماط الصرف
- **تعلم الروتين**: اكتشاف التكرار واقتراح التسجيل التلقائي
- **وضع داكن/فاتح**: واجهة متوافقة مع كلا الوضعين مع تبديل سلس
- **تحديث تلقائي**: فحص إصدارات جديدة من GitHub Releases

---

## التقنيات

| الغرض | المكتبة |
|---|---|
| إدارة الحالة | `provider` |
| تخزين محلي | `shared_preferences` |
| إشعارات | `flutter_local_notifications` |
| رسوم بيانية | `fl_chart` |
| خطوط | `google_fonts` (Inter) |

---

## التشغيل

```bash
# تثبيت الاعتماديات
flutter pub get

# تشغيل على جهاز أو محاكي
flutter run

# بناء APK
flutter build apk --release --no-tree-shake-icons
```

---

## البناء التلقائي

 المشروع يستخدم GitHub Actions لبناء APK تلقائيًا عند إنشاء tag:

```bash
git tag -a v1.0.2 -m "Release version 1.0.2"
git push origin v1.0.2
```

سيتم بناء APK تلقائيًا ورفعه في [GitHub Releases](https://github.com/CODE-NAME-IN-B/Twela/releases).

---

## هيكل المشروع

```
lib/
  main.dart          # نقطة الدخول
  app.dart           # MaterialApp + التنقل
  models/            # نماذج البيانات
  services/          # خدمات التخزين والإشعارات
  providers/         # إدارة الحالة
  screens/           # الشاشات
  widgets/           # مكونات UI قابلة لإعادة الاستخدام
  theme/             # الألوان والثيم
  utils/             # دوال مساعدة
```

---

## المطور

[CODE-NAME-IN-B](https://github.com/CODE-NAME-IN-B)

---

## الرخصة

MIT License
