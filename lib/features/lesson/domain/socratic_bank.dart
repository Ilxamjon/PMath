import 'package:equatable/equatable.dart';

import '../../../models/lesson_model.dart';

/// Dars xonasidagi chizma turi (rasm o‘rniga chiziladi).
enum LessonVisualKind {
  none,
  angleAcute,
  angleRight,
  angleObtuse,
  triangle,
  square,
  rectangle,
  circle,
  shapesCompare,
  rectLabeled,
  squareLabeled,
  gridArea,
}

/// Bitta Sokratik qadam: matn + (ixtiyoriy) chizma.
class SocraticStep extends Equatable {
  const SocraticStep({
    required this.prompt,
    this.visual = LessonVisualKind.none,
    this.captionUz,
    this.labelA,
    this.labelB,
  });

  final String prompt;
  final LessonVisualKind visual;
  final String? captionUz;
  final String? labelA;
  final String? labelB;

  bool get hasVisual => visual != LessonVisualKind.none;

  @override
  List<Object?> get props => [prompt, visual, captionUz, labelA, labelB];
}

/// Har mavzu: 10 ta Sokratik qadam (kerak bo‘lsa chizma bilan).
abstract final class SocraticBank {
  static List<String> promptsFor(LessonModel lesson) =>
      stepsFor(lesson).map((s) => s.prompt).toList();

  static List<SocraticStep> stepsFor(LessonModel lesson) {
    final key = _key(lesson);
    return List<SocraticStep>.from(_steps[key] ?? _steps['default']!);
  }

  static String introFor(LessonModel lesson) {
    final key = _key(lesson);
    return _intros[key] ??
        'Salom! Bugun «${lesson.titleUz}» mavzusini o‘rganamiz. '
            'Men to‘g‘ridan-to‘g‘ri javob aytmayman — 10 ta yo‘naltiruvchi savol '
            'orqali o‘zingiz ochib borasiz. Chizma bo‘lsa, avval unga qarang.';
  }

  static String hintFor(LessonModel lesson) {
    final key = _key(lesson);
    return _hints[key] ??
        'Yaxshi! Avval chizmaga qarang, keyin fikringizni yozing yoki ayting.';
  }

  static String summaryFor(LessonModel lesson) {
    return '«${lesson.titleUz}» darsi tugadi. Siz 10 ta Sokratik savol orqali '
        'o‘zingiz fikrladingiz. Endi 15 ta mashq: 5 oson, 5 o‘rtacha, 5 qiyin. '
        'Keyin esa daftarga 15 ta uyga vazifa yozasiz.';
  }

  static String _key(LessonModel lesson) {
    final t = '${lesson.titleUz} ${lesson.topic}'.toLowerCase();
    if (t.contains('taqqos')) return 'taqqoslash';
    if (t.contains('imtihon')) return 'imtihon';
    if (t.contains('perimetr')) return 'perimetr';
    if (t.contains('yuza')) return 'yuza';
    // «Shakllarni tanish» — alohida (burchak emas).
    if (t.contains('shakl')) return 'shapes';
    if (t.contains('burchak')) return 'angles';
    if (t.contains('ketma') || t.contains('naqsh')) return 'sequences';
    if (t.contains('kasr') || t.contains('foiz')) return 'fractions';
    if (t.contains('ko‘pay') || t.contains('kopay') || t.contains('jadval')) {
      return 'multiply';
    }
    if (t.contains('bo‘lish') || t.contains('bolish')) return 'divide';
    if (t.contains('qo‘sh') || t.contains('ayir') || t.contains('natural')) {
      return 'arithmetic';
    }
    if (t.contains('geometr') || t.contains('kvadrat') || t.contains('simmetr')) {
      return 'shapes';
    }
    if (t.contains('mantiq') ||
        t.contains('topishmoq') ||
        t.contains('ortiqcha')) {
      return 'logic';
    }
    return 'default';
  }

  static const _intros = <String, String>{
    'shapes':
        'Salom! Bugun shakllarni tanish. Har bir savolda chizma ko‘rsatiladi. '
        'Avval chizmaga qarang, keyin savolga javob bering. '
        'Men tayyor javob aytmayman — o‘zingiz ochasiz.',
    'angles':
        'Salom! Bugun burchaklar. Har savolda burchak chizmasi bor. '
        'Avval chizmaga qarang: o‘tkirmi, to‘g‘rimi, o‘tmasmi?',
    'taqqoslash':
        'Salom! Bugungi mavzu — Taqqoslash. '
        'Nimalar taqqoslanadi? Qaysi belgi? Xulosa nima?',
    'logic':
        'Salom! Bugun mantiqiy fikrlash. Shart → xulosa → tekshiruv.',
    'sequences':
        'Salom! Bugun ketma-ketliklar. Avval qoidani toping.',
    'arithmetic':
        'Salom! Bugun hisoblash. Avval nima so‘ralganini aniqlang.',
    'multiply':
        'Salom! Bugun ko‘paytirish — teng guruhlar.',
    'divide':
        'Salom! Bugun bo‘lish — teng ulash yoki necha marta sig‘ish.',
    'fractions':
        'Salom! Bugun kasrlar — butunning qismi.',
    'perimetr':
        'Salom! Bugun perimetr — shakl atrofi. Chizmadagi tomonlarga qarang.',
    'yuza':
        'Salom! Bugun yuza — ichki maydon. Chizmadagi katak/shaklga qarang.',
    'imtihon':
        'Mini-imtihon. Vaqtni taqsimlang, kameraga qarang.',
  };

  static const _hints = <String, String>{
    'shapes': 'Ishora: avval chizmani diqqat bilan ko‘ring, keyin tomon/burchak sanang.',
    'angles': 'Ishora: to‘g‘ri burchak 90°. Undan kichik — o‘tkir, kattaroq — o‘tmas.',
    'perimetr': 'Ishora: barcha tomonlarni qo‘shing.',
    'yuza': 'Ishora: perimetr — atrof, yuza — ichki qism.',
    'taqqoslash': 'Ishora: birliklarni tenglashtiring, keyin solishtiring.',
  };

  static final _steps = <String, List<SocraticStep>>{
    'shapes': [
      SocraticStep(
        prompt: 'Chizmadagi shakl nima? Nechta tomoni bor?',
        visual: LessonVisualKind.triangle,
        captionUz: 'Chizma: uchburchak',
      ),
      SocraticStep(
        prompt: 'Bu shaklning barcha tomonlari tengmi? Nima uchun?',
        visual: LessonVisualKind.square,
        captionUz: 'Chizma: kvadrat',
      ),
      SocraticStep(
        prompt: 'Bu shaklni qanday ataysiz? Doiradan qanday farq qiladi?',
        visual: LessonVisualKind.circle,
        captionUz: 'Chizma: doira',
      ),
      SocraticStep(
        prompt: 'Qaysi shaklning 4 ta tomoni bor, lekin hammasi teng emas?',
        visual: LessonVisualKind.shapesCompare,
        captionUz: 'Chizma: uchta shakl',
      ),
      SocraticStep(
        prompt: 'To‘g‘ri to‘rtburchakda qanday burchaklar bor?',
        visual: LessonVisualKind.rectangle,
        captionUz: 'Chizma: to‘g‘ri to‘rtburchak',
      ),
      SocraticStep(
        prompt: 'Kvadratni to‘g‘ri to‘rtburchakdan qanday ajratasiz?',
        visual: LessonVisualKind.shapesCompare,
        captionUz: 'Chizma: solishtirish',
      ),
      SocraticStep(
        prompt: 'Uchburchakda nechta burchak bor? Sanab ko‘ring.',
        visual: LessonVisualKind.triangle,
        captionUz: 'Chizma: uchburchak',
      ),
      SocraticStep(
        prompt: 'Chizmadagi shaklda simmetriya o‘qi bormi?',
        visual: LessonVisualKind.square,
        captionUz: 'Chizma: kvadrat',
      ),
      SocraticStep(
        prompt: 'Bu burchak o‘tkir, to‘g‘ri yoki o‘tmas?',
        visual: LessonVisualKind.angleRight,
        captionUz: 'Chizma: burchak',
      ),
      SocraticStep(
        prompt: 'O‘zingizga tanish bir narsani shaklga o‘xshating. Qaysi shakl?',
        visual: LessonVisualKind.shapesCompare,
        captionUz: 'Chizma: shakllar',
      ),
    ],
    'angles': [
      SocraticStep(
        prompt: 'Chizmadagi burchak o‘tkir, to‘g‘ri yoki o‘tmas?',
        visual: LessonVisualKind.angleAcute,
        captionUz: 'Chizma: burchak A',
      ),
      SocraticStep(
        prompt: 'Bu burchak nechta gradusga o‘xshaydi — 90° dan kichikmi?',
        visual: LessonVisualKind.angleAcute,
        captionUz: 'Chizma: o‘tkir burchak',
      ),
      SocraticStep(
        prompt: 'Bu burchak qanday? Nima uchun shunday dedingiz?',
        visual: LessonVisualKind.angleRight,
        captionUz: 'Chizma: to‘g‘ri burchak',
      ),
      SocraticStep(
        prompt: 'Bu burchak 90° dan katta ko‘rinadimi?',
        visual: LessonVisualKind.angleObtuse,
        captionUz: 'Chizma: o‘tmas burchak',
      ),
      SocraticStep(
        prompt: 'To‘g‘ri burchakni chizmadagi boshqalaridan qanday ajratasiz?',
        visual: LessonVisualKind.angleRight,
        captionUz: 'Chizma: to‘g‘ri burchak',
      ),
      SocraticStep(
        prompt: 'Agar burchak yanada ochilsa, u o‘tkirmi yoki o‘tmasmi bo‘ladi?',
        visual: LessonVisualKind.angleAcute,
        captionUz: 'Chizma: kichik burchak',
      ),
      SocraticStep(
        prompt: 'Chizmadagi ikki tomon bir-biriga tikmi?',
        visual: LessonVisualKind.angleRight,
        captionUz: 'Chizma',
      ),
      SocraticStep(
        prompt: 'Bu burchakni hayotda qayerda ko‘rgan bo‘lishingiz mumkin?',
        visual: LessonVisualKind.angleRight,
        captionUz: 'Chizma: burchak',
      ),
      SocraticStep(
        prompt: 'Uchala burchak turini (o‘tkir, to‘g‘ri, o‘tmas) farqlaysizmi?',
        visual: LessonVisualKind.angleObtuse,
        captionUz: 'Chizma',
      ),
      SocraticStep(
        prompt: 'Yangi burchak chizing (daftarda) va turini ayting.',
        visual: LessonVisualKind.angleAcute,
        captionUz: 'Namuna chizma',
      ),
    ],
    'perimetr': [
      SocraticStep(
        prompt: 'Perimetr — atrofmi yoki ichki maydonmi?',
        visual: LessonVisualKind.rectLabeled,
        captionUz: 'Chizma: to‘g‘ri to‘rtburchak',
        labelA: '5',
        labelB: '3',
      ),
      SocraticStep(
        prompt: 'Kvadratning barcha tomonlari tengmi? Perimetrni qanday topasiz?',
        visual: LessonVisualKind.squareLabeled,
        captionUz: 'Chizma: kvadrat',
        labelA: '6',
      ),
      SocraticStep(
        prompt: 'Chizmadagi tomonlarni qo‘shsangiz nima chiqadi (perimetr)?',
        visual: LessonVisualKind.rectLabeled,
        captionUz: 'a=4, b=2',
        labelA: '4',
        labelB: '2',
      ),
      SocraticStep(
        prompt: 'Birlik (sm) javobda qanday yoziladi?',
        visual: LessonVisualKind.squareLabeled,
        captionUz: 'Tomoni 5 sm',
        labelA: '5 sm',
      ),
      SocraticStep(
        prompt: 'Agar bitta tomon noma’lum bo‘lsa, nima qilasiz?',
        visual: LessonVisualKind.rectLabeled,
        captionUz: 'Chizma',
        labelA: '?',
        labelB: '3',
      ),
      SocraticStep(
        prompt: 'Perimetrni tekshirish uchun nima qilasiz?',
        visual: LessonVisualKind.squareLabeled,
        captionUz: 'Kvadrat',
        labelA: '7',
      ),
      SocraticStep(
        prompt: 'a va b qanday ishtirok etadi?',
        visual: LessonVisualKind.rectLabeled,
        captionUz: 'To‘g‘ri to‘rtburchak',
        labelA: 'a',
        labelB: 'b',
      ),
      SocraticStep(
        prompt: 'Perimetr o‘zgarsa, yuza ham o‘zgaradimi?',
        visual: LessonVisualKind.rectLabeled,
        captionUz: 'Chizma',
        labelA: '8',
        labelB: '3',
      ),
      SocraticStep(
        prompt: 'Chizmadagi shakl atrofini barmog‘ingiz bilan aylantiring — bu perimetrmi?',
        visual: LessonVisualKind.square,
        captionUz: 'Kvadrat',
      ),
      SocraticStep(
        prompt: 'Uy atrofidagi maydonchaga o‘xshatib misol ayting.',
        visual: LessonVisualKind.rectLabeled,
        captionUz: 'Namuna',
        labelA: '10',
        labelB: '6',
      ),
    ],
    'yuza': [
      SocraticStep(
        prompt: 'Yuza — maydonmi yoki atrof uzunligimi? Chizmadagi bo‘yalgan qism qaysi?',
        visual: LessonVisualKind.gridArea,
        captionUz: 'Chizma: kataklar',
      ),
      SocraticStep(
        prompt: 'Perimetr bilan yuzani chalkashtirmaslik uchun nima demaysiz?',
        visual: LessonVisualKind.rectLabeled,
        captionUz: 'a=5, b=3',
        labelA: '5',
        labelB: '3',
      ),
      SocraticStep(
        prompt: 'To‘g‘ri to‘rtburchak yuzasini qanday topasiz?',
        visual: LessonVisualKind.rectLabeled,
        captionUz: 'Chizma',
        labelA: '5',
        labelB: '3',
      ),
      SocraticStep(
        prompt: 'Javob birligi qanday (sm²)?',
        visual: LessonVisualKind.squareLabeled,
        captionUz: 'Kvadrat',
        labelA: '4',
      ),
      SocraticStep(
        prompt: 'Kataklarni sanab yuzani taxmin qiling.',
        visual: LessonVisualKind.gridArea,
        captionUz: 'Kataklar',
      ),
      SocraticStep(
        prompt: 'Tomon 2 marta oshsa, yuza necha marta oshadi?',
        visual: LessonVisualKind.squareLabeled,
        captionUz: 'Kvadrat',
        labelA: '2',
      ),
      SocraticStep(
        prompt: 'Yuzani tekshirish uchun boshqa usul bormi?',
        visual: LessonVisualKind.rectLabeled,
        captionUz: 'Chizma',
        labelA: '6',
        labelB: '4',
      ),
      SocraticStep(
        prompt: 'Chizmadagi ichki qism — yuza. Atrof chizig‘i nima?',
        visual: LessonVisualKind.gridArea,
        captionUz: 'Maydon',
      ),
      SocraticStep(
        prompt: 'Masalada keraksiz ma’lumot bormi?',
        visual: LessonVisualKind.rectLabeled,
        captionUz: 'a=8, b=2',
        labelA: '8',
        labelB: '2',
      ),
      SocraticStep(
        prompt: 'Stol yuzasini o‘lchab hisoblang (taxminan).',
        visual: LessonVisualKind.rectLabeled,
        captionUz: 'Namuna',
        labelA: 'a',
        labelB: 'b',
      ),
    ],
    'taqqoslash': _textOnly([
      'Stolda 3 ta olma va 5 ta nok. Qaysi meva ko‘proq? Nima uchun?',
      'Bir bola 120 sm, ikkinchisi 1 metr 15 sm. Kim balandroq?',
      '2 kg un va 1500 g shakar. Qaysi og‘irroq?',
      '8 sm va 1 dm. Qaysi uzunroq?',
      '«Kattaroq» deganda nimaning kattaligini nazarda tutamiz?',
      'Agar A > B va B > C bo‘lsa, A va C haqida nima deyish mumkin?',
      'Ikki sumka: 4 kitob va 4 daftar. Og‘irlikni qanday taqqoslaysiz?',
      '14:00 va tushdan keyin 2:00 — bir xilmi?',
      'Jadvalda 3 ball: eng yuqorisini qanday topasiz?',
      'O‘zingiz 2 narsani 1 belgi bo‘yicha taqqoslang.',
    ]),
    'logic': _textOnly([
      'Masalada qaysi ma’lumotlar muhim?',
      'Agar shart rost bo‘lsa, qanday xulosa chiqadi?',
      'Ortiqcha narsani topishda qanday belgini qidirasiz?',
      'Qoida o‘zgarsa, javob qanday o‘zgaradi?',
      'Jadvaldagi qator va ustunni qanday o‘qiysiz?',
      'Yolg‘on bo‘lishi mumkin javobni qanday rad etasiz?',
      'Masalani soddaroq sonlar bilan qayta yozing.',
      'Qarama-qarshi misol o‘ylab toping.',
      'Yechimni 1 daqiqada qanday tushuntirardingiz?',
      'Eng ishonchli tekshiruv usulingiz qaysi?',
    ]),
    'sequences': _textOnly([
      'Ketma-ketlikda birinchi 3 ta had nima deydi?',
      'Qo‘shni hadlar orasidagi farq bir xilmi?',
      'Qoida qo‘shishmi, ko‘paytirishmi?',
      'Keyingi haddan oldin qoidani bir gapda yozing.',
      'Qoidani oldingi hadga qo‘llab tekshiring.',
      'Bitta had xato bo‘lsa, qanday sezasiz?',
      'Juft-toq naqsh bormi?',
      'Shakl ketma-ketligida nima o‘zgaradi?',
      '2 ta oldinga o‘tib, orqaga qaytib tekshiring.',
      'O‘zingiz 5 hadli ketma-ketlik tuzing.',
    ]),
    'arithmetic': _textOnly([
      'Masalada nima berilgan va nima so‘ralgan?',
      'Qaysi amal bilan boshlaysiz?',
      'Hisobni qismlarga bo‘ling.',
      'Taxminiy javob qancha?',
      'Birliklar mos keladimi?',
      'Teskari amal bilan qanday tekshirasiz?',
      'Xato chiqsa, qaysi qadamni qayta ko‘rasiz?',
      'Ustun usuli qulaymi?',
      'Javob mantiqqa to‘g‘ri keladimi?',
      'Javobni gap bilan qanday aytasiz?',
    ]),
    'multiply': _textOnly([
      'Ko‘paytirishni teng guruhlar sifatida tushuntiring.',
      '3 × 4 ni chizib ko‘rsatsangiz, nechta nuqta?',
      'Ko‘paytuvchi va ko‘paytiruvchini ajrating.',
      'Jadvaldan qaysi qator kerak?',
      'Ustun usulida birinchi qadam nima?',
      '0 ga ko‘paytirishda javob nima?',
      '10 ga ko‘paytirishni qanday osonlashtirasiz?',
      'Tekshiruv: bo‘lish bilan qanday tekshirasiz?',
      'Og‘zaki hisobda qanday yo‘l?',
      'O‘zingizga 1 ta misol tuzing.',
    ]),
    'divide': _textOnly([
      'Bo‘lish — teng ulashmi yoki necha marta sig‘ishmi?',
      'Bo‘linuvchi va bo‘luvchini ajrating.',
      'Qoldiq bo‘lishi mumkinmi?',
      'Tekshiruv: ko‘paytirib qaytish.',
      '0 ga bo‘lish mumkinmi?',
      'Bo‘lishni ayirishning takrorlanishi sifatida tushuntiring.',
      'Javob butun son bo‘lishi shartmi?',
      'Masalani rasmda qanday ko‘rsatasiz?',
      'Xato bo‘lsa, qaysi qadamni tekshirasiz?',
      'Yangi misol o‘ylab, taxminiy javob ayting.',
    ]),
    'fractions': _textOnly([
      'Kasrda sur’at nima, maxraj nima?',
      '1/2 va 1/4 ni pizza bilan tushuntiring.',
      'Bir xil maxrajli kasrlarni qanday qo‘shasiz?',
      'Kasrni soddalashtirish nima demak?',
      'Butun sonni kasr ko‘rinishida yozing.',
      '2/3 va 3/5 — qaysi kattaroq?',
      'Foiz kasr bilan qanday bog‘liq?',
      'Chizmada kasrni qanday bo‘yasiz?',
      'Javob 1 dan katta bo‘lishi mumkinmi?',
      'Hayotdan 1 ta kasr misoli keltiring.',
    ]),
    'imtihon': _textOnly([
      'Vaqtingizni qanday taqsimlaysiz?',
      'Avval oson savollardan boshlaysizmi?',
      'Qiyin savolda nima qilasiz?',
      'Javobdan oldin nima tekshirasiz?',
      'Chalg‘ituvchi variantlarni qanday aniqlaysiz?',
      'Hisobni qog‘ozda yuritish kerakmi?',
      'Kameraga qarab o‘tirish nima uchun muhim?',
      'Xato topilsa, qanday tuzatasiz?',
      'Oxirgi 2 daqiqada nima qilasiz?',
      'Imtihondan keyin qaysi mavzuni takrorlaysiz?',
    ]),
    'default': _textOnly([
      'Bu masalada nima berilgan?',
      'Nima so‘ralganini bir gapda ayting.',
      'Qanday qadam bilan boshlaysiz?',
      'Qaysi ma’lumotlar muhim?',
      'Taxminiy javob qancha?',
      'Yechimni kichik qismlarga bo‘ling.',
      'Boshqa usul bilan qanday tekshirasiz?',
      'Xato chiqsa, qayerdan qidirasiz?',
      'Do‘stingizga qanday tushuntirardingiz?',
      'Bugungi eng muhim xulosa nima?',
    ]),
  };

  static List<SocraticStep> _textOnly(List<String> prompts) => [
        for (final p in prompts) SocraticStep(prompt: p),
      ];
}
