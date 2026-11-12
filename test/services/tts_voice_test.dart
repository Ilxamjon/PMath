import 'package:flutter_test/flutter_test.dart';
import 'package:pmath/services/tts_service.dart';

void main() {
  test('lotin o‘zbek tili rus va kirilldan oldin turadi', () {
    final locale = pickSpeechLocale([
      'ru-RU',
      'tr-TR',
      'uz-Cyrl-UZ',
      'en-US',
      'uz-UZ',
    ]);

    expect(locale, 'uz-UZ');
  });

  test('o‘zbek tili umuman yo‘q bo‘lsa ruscha tanlanmaydi', () {
    expect(pickSpeechLocale(['ru-RU', 'en-US']), 'uz-UZ');
  });

  test('erkak o‘zbek ovoz ayol ovozdan ustun', () {
    final chosen = pickMaleUzbekVoice([
      {
        'name': 'uz-uz-x-sfg-local',
        'locale': 'uz-UZ',
        'features': 'female',
      },
      {
        'name': 'ru-ru-x-ruf-local',
        'locale': 'ru-RU',
        'features': 'male',
      },
      {
        'name': 'uz-uz-x-uzm-local',
        'locale': 'uz-UZ',
        'features': 'male',
      },
    ]);

    expect(chosen?['name'], 'uz-uz-x-uzm-local');
    expect(pitchForVoice(chosen), 1);
  });

  test('faqat ayol ovoz bo‘lsa ham o‘zbek qoladi va pastroq gapiradi', () {
    final chosen = pickMaleUzbekVoice([
      {
        'name': 'uz-uz-x-sfg-local',
        'locale': 'uz-UZ',
        'features': 'female',
      },
    ]);

    expect(chosen?['name'], 'uz-uz-x-sfg-local');
    expect(pitchForVoice(chosen), 0.82);
  });
}
