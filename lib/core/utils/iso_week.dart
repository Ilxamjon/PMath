/// ISO-8601 hafta kaliti, masalan `2026-W46`.
///
/// Hafta payshanba kuniga qarab aniqlanadi, shuning uchun yil chegarasida
/// (28-dekabr – 4-yanvar) to‘g‘ri ishlaydi.
String isoWeekKey(DateTime date) {
  final day = DateTime.utc(date.year, date.month, date.day);
  final thursday = day.add(Duration(days: DateTime.thursday - day.weekday));
  final firstDay = DateTime.utc(thursday.year, 1, 1);
  final week = (thursday.difference(firstDay).inDays / 7).floor() + 1;
  return '${thursday.year}-W${week.toString().padLeft(2, '0')}';
}
