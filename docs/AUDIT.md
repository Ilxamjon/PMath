# PMath — audit va ochiq ishlar

Sana: 2026-11-11. Ko‘rib chiqilgan: README, ROADMAP, `pubspec.yaml`, `lib/services/*` (asosiy fayllar), `telegram_config.dart`.
`features/` UI kodi, modellar va testlar mazmuni hali to‘liq ko‘rib chiqilmagan.

## Shu PR da tuzatilganlar

| Muammo | Tuzatish |
|--------|----------|
| Apostrof variantlari (`‘ ʻ ’ '`) lokal Sokratik qoidalarda mos kelmasdi | `normalizeUz()` — matn ham, kalit so‘zlar ham normallashtiriladi (`lib/core/utils/uz_text.dart`) |
| Gemini kaliti URL query da edi (loglarga tushishi mumkin) | `x-goog-api-key` sarlavhasiga ko‘chirildi |
| O‘quvchi matni qoidalar bilan bir promptda aralashgan edi | `systemInstruction` (qoidalar) va `contents` (o‘quvchi matni) ajratildi, matn `sanitizeForPrompt()` dan o‘tadi |
| Bulut javobi yakuniy javobni oshkor qilishi mumkin edi | Javob tekshiriladi (uzunlik, "javob: 42" shabloni); mos kelmasa lokal Sokratik javobga o‘tadi |
| Model nomi kodga qotirilgan edi | `--dart-define=GEMINI_MODEL=...` |
| Haftalik XP kaliti ISO hafta emas edi (yil chegarasida adashardi) | `isoWeekKey()` (`lib/core/utils/iso_week.dart`). Eslatma: kalit formati o‘zgargani uchun yangilashdan keyin joriy hafta XP si bir marta 0 dan boshlanadi |
| Roadmapdagi ✅ lar stub holatni yashirardi | ROADMAP da ✅ / 🟡 / ⬜ belgilari |
| CI faqat `.example` fayl edi, testlar yo‘q | `.github/workflows/flutter_ci.yml`, `test/core/uz_text_test.dart` |
| README eskirgan | Yangilandi |

> Bu o‘zgarishlar `flutter analyze` / `flutter test` bilan lokal ishga tushirib tekshirilmagan.
> PR dagi CI natijasini ko‘ring.

## Ochiq ishlar (kod bilan emas, qaror/infratuzilma talab qiladi)

### P0 — xavfsizlik va asos
- [ ] **Backend proksi** (Supabase Edge Function): Gemini, Vision, Telegram chaqiruvlari. Ilovada kalit va bot token bo‘lmasin.
- [ ] **Haqiqiy Auth:** Supabase Phone OTP (hozirgi `StubAuthService` istalgan 4+ belgili kodni qabul qiladi).
- [ ] **Obuna / trial holati serverda** (hozir lokal `subscriptionExpiresAt` — soat yoki ma’lumotni tozalash bilan aylanib o‘tiladi).
- [ ] **Bolalar ma’lumoti:** ota-ona roziligi, yuz tahlilini faqat qurilmada bajarish, rasmlarni saqlash muddati, O‘zbekistonning shaxsiy ma’lumotlar to‘g‘risidagi qonuni talablarini tekshirish; Google Play "Families" / App Store "Kids" qoidalari.

### P1 — mahsulot
- [ ] **Real Vision OCR** (Gemini Vision / Document AI) + ishonch darajasi past bo‘lsa ota-ona tasdiqlash ekrani. Hozir `StubVisionAiService` rasmni o‘qimaydi.
- [ ] **Telegram ulash:** chat ID ni qo‘lda kiritish o‘rniga `t.me/<bot>?start=<kod>` deep link.
- [ ] **Haqiqiy liga:** reyting uchun backend (hozir faqat lokal XP).
- [ ] **TTS/STT:** `uz-UZ` ovozi qurilmaga bog‘liq — real telefonlarda sinab, matn rejimiga fallback.
- [ ] **Mastery < 80% holati:** `applyPracticeResult` darsni har doim `completed` qiladi; qayta urinish oqimi (retry) aniq bo‘lishi kerak.

### P2 — kod sifati
- [ ] `StorageService` ni repository qatlamiga bo‘lish (user / lessons / homework / gamification). Domen logikasi (`applyPracticeResult`) storage dan tashqariga.
- [ ] `SharedPreferences` JSON bloblaridan SQLite/Drift yoki Isar ga o‘tish (har chaqiruvda butun ro‘yxat decode qilinadi).
- [ ] State management: `flutter_bloc` va `provider` dan bittasini qoldirish; ishlatilmayotgan dependency larni (`hive`, `hive_flutter` va h.k.) `grep` bilan tekshirib olib tashlash.
- [ ] Dublikat feature papkalar: `voice_ai` / `voice_assistant`, `homework` / `homework_scanner` / `grading` — birlashtirish.
- [ ] Ishlatilmaydigan platforma papkalari (`linux`, `macos`, `windows`, `web`) — kerak bo‘lmasa olib tashlash.
- [ ] `test/widget_test.dart` (~21 KB) ni servis/domen bo‘yicha alohida fayllarga bo‘lish; `MasteryHelper`, `GamificationService`, grading uchun unit testlar.

### P3 — jarayon va monetizatsiya
- [ ] GitHub da `main` uchun branch protection (PR + CI majburiy). Avtomatik push hooklarini faqat shaxsiy branchda ishlatish.
- [ ] Click/Payme raqamli obuna uchun do‘kon qoidalariga zid bo‘lishi mumkin — oldindan tekshirish.
- [ ] **Kontent sifati:** savollar bankini o‘qituvchi/mutaxassis bilan tekshirish va qiyinlik darajasini sozlash.
