import 'dart:math';

const List<String> motivationalMessages = [
  'كل خطوة صغيرة بالتسجيل تقربك لصورة أوضح عن فلوسك',
  'ما فيه حكم هنا، بس فهم أفضل ليومك المالي',
  'تتبعك اليوم هو أساس راحة بالك بكرة',
  'خطوة بخطوة، أنت أقرب لأهدافك المالية',
  'كل دينار تسجّله يقربك لصورة أوضح',
  'الوعي المالي خطوة أولى نحو الاستقرار',
  'مش لازم تكون مثالي، بس لازم تفهم',
  'اليوم أحسن من أمس، وأنت تتعلم',
  'صوّر فلوسك، وبكرة بتعرف وين تقدر تطّلع',
  'الأرقام ما تكذب، بس لازم تسمعها',
];

String getRandomMotivationalMessage() {
  final random = Random();
  return motivationalMessages[random.nextInt(motivationalMessages.length)];
}
