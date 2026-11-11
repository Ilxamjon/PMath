/// pubspec dagi ishga tushirish kutubxonalari.
///
/// Bolalar do‘koni qoidasi (Google Play Families / App Store Kids) bo‘yicha
/// dastlabki belgi. Yuridik xulosa emas.
enum KidsStoreRisk {
  /// Analytics yoki reklama emas, bolalar ma’lumotini tashqariga yubormaydi.
  none,

  /// Sezgir ruxsat yoki shaxsiy ma’lumot o‘z serverga ketadi. Qoidaga zid emas,
  /// lekin oshkor qilish kerak.
  review,

  /// Uchinchi tomonga so‘rov ketishi mumkin. Families / Kids ga zid bo‘lishi mumkin.
  conflict,
}

class ThirdPartySdk {
  const ThirdPartySdk({
    required this.package,
    required this.roleUz,
    required this.risk,
  });

  final String package;
  final String roleUz;
  final KidsStoreRisk risk;
}

/// `pubspec.yaml` dependencies. Dev-kutubxonalar kiritilmagan.
const thirdPartySdks = <ThirdPartySdk>[
  ThirdPartySdk(
    package: 'google_fonts',
    roleUz: 'Shriftni Google serveridan yuklaydi. IP manzil Googlega ketishi mumkin.',
    risk: KidsStoreRisk.conflict,
  ),
  ThirdPartySdk(
    package: 'speech_to_text',
    roleUz:
        'Ovozni matnga aylantiradi. Androidda nutq Google xizmatiga ketishi mumkin.',
    risk: KidsStoreRisk.conflict,
  ),
  ThirdPartySdk(
    package: 'supabase_flutter',
    roleUz: 'Kirish, profil va Telegram. Analytics emas, lekin ism va telefon serverda.',
    risk: KidsStoreRisk.review,
  ),
  ThirdPartySdk(
    package: 'camera',
    roleUz: 'Daftar va yuz tekshiruvi kamerasi. Kadr o‘zi yuborilmaydi.',
    risk: KidsStoreRisk.review,
  ),
  ThirdPartySdk(
    package: 'image_picker',
    roleUz: 'Galereyadan daftar rasmi tanlash.',
    risk: KidsStoreRisk.review,
  ),
  ThirdPartySdk(
    package: 'http',
    roleUz: 'O‘z serveriga so‘rov. Alohida analytics emas.',
    risk: KidsStoreRisk.none,
  ),
  ThirdPartySdk(
    package: 'flutter_tts',
    roleUz: 'Telefondagi ovozli o‘qish.',
    risk: KidsStoreRisk.none,
  ),
  ThirdPartySdk(
    package: 'image',
    roleUz: 'Rasmni telefonda siqish.',
    risk: KidsStoreRisk.none,
  ),
  ThirdPartySdk(
    package: 'url_launcher',
    roleUz: 'Telegram havolasini ochish.',
    risk: KidsStoreRisk.none,
  ),
  ThirdPartySdk(
    package: 'drift',
    roleUz: 'Telefondagi ma’lumotlar bazasi.',
    risk: KidsStoreRisk.none,
  ),
  ThirdPartySdk(
    package: 'sqlite3',
    roleUz: 'Telefondagi ma’lumotlar bazasi.',
    risk: KidsStoreRisk.none,
  ),
  ThirdPartySdk(
    package: 'sqlite3_flutter_libs',
    roleUz: 'Telefondagi ma’lumotlar bazasi.',
    risk: KidsStoreRisk.none,
  ),
  ThirdPartySdk(
    package: 'shared_preferences',
    roleUz: 'Telefondagi kichik sozlamalar.',
    risk: KidsStoreRisk.none,
  ),
  ThirdPartySdk(
    package: 'path_provider',
    roleUz: 'Telefondagi papka yo‘li.',
    risk: KidsStoreRisk.none,
  ),
  ThirdPartySdk(
    package: 'path',
    roleUz: 'Fayl yo‘li.',
    risk: KidsStoreRisk.none,
  ),
  ThirdPartySdk(
    package: 'flutter_bloc',
    roleUz: 'Ekran holati.',
    risk: KidsStoreRisk.none,
  ),
  ThirdPartySdk(
    package: 'equatable',
    roleUz: 'Model taqqoslash.',
    risk: KidsStoreRisk.none,
  ),
  ThirdPartySdk(
    package: 'intl',
    roleUz: 'Sana formati.',
    risk: KidsStoreRisk.none,
  ),
  ThirdPartySdk(
    package: 'uuid',
    roleUz: 'Lokal identifikator.',
    risk: KidsStoreRisk.none,
  ),
  ThirdPartySdk(
    package: 'flutter_math_fork',
    roleUz: 'Formula chizish.',
    risk: KidsStoreRisk.none,
  ),
  ThirdPartySdk(
    package: 'percent_indicator',
    roleUz: 'Foiz halqasi.',
    risk: KidsStoreRisk.none,
  ),
  ThirdPartySdk(
    package: 'cupertino_icons',
    roleUz: 'Ikonkalar.',
    risk: KidsStoreRisk.none,
  ),
];
