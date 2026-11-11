// O‘zbek lotin matnini taqqoslash va AI promptiga xavfsiz uzatish yordamchilari.

/// Apostrof variantlari: ʻ ʼ ‘ ’ ` ´ ′ — hammasi oddiy `'` ga keltiriladi.
final RegExp _apostrophes = RegExp('[\u02BB\u02BC\u2018\u2019\u0060\u00B4\u2032]');

/// Kichik harf, bitta apostrof turi va bitta bo‘shliqqa normallashtirish.
///
/// Kalit so‘zlarni ham, foydalanuvchi matnini ham shu funksiyadan o‘tkazing,
/// shunda `to‘g‘ri`, `toʻgʻri`, `to'g'ri` bir xil taqqoslanadi.
String normalizeUz(String input) {
  return input
      .toLowerCase()
      .replaceAll(_apostrophes, "'")
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// O‘quvchi matnini LLM promptiga qo‘yishdan oldin tozalash:
/// boshqaruv belgilari, qator uzilishlari va qo‘shtirnoqlar olib tashlanadi,
/// uzunlik cheklanadi.
String sanitizeForPrompt(String input, {int maxLength = 300}) {
  final cleaned = input
      .replaceAll(RegExp(r'[\u0000-\u001F\u007F]'), ' ')
      .replaceAll('"', "'")
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (cleaned.length <= maxLength) return cleaned;
  return cleaned.substring(0, maxLength);
}
