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
| Model nomi kodga qotirilgan edi | Keyinroq Edge Function muhitiga ko‘chirildi (`GEMINI_MODEL`, standart `gemini-2.0-flash`) |
| Haftalik XP kaliti ISO hafta emas edi (yil chegarasida adashardi) | `isoWeekKey()` (`lib/core/utils/iso_week.dart`). Eslatma: kalit formati o‘zgargani uchun yangilashdan keyin joriy hafta XP si bir marta 0 dan boshlanadi |
| Roadmapdagi ✅ lar stub holatni yashirardi | ROADMAP da ✅ / 🟡 / ⬜ belgilari |
| CI faqat `.example` fayl edi, testlar yo‘q | `.github/workflows/flutter_ci.yml`, `test/core/uz_text_test.dart` |
| README eskirgan | Yangilandi |

> Bu o‘zgarishlar `flutter analyze` / `flutter test` bilan lokal ishga tushirib tekshirilmagan.
> PR dagi CI natijasini ko‘ring.

## Ochiq ishlar (kod bilan emas, qaror/infratuzilma talab qiladi)

### P0 — xavfsizlik va asos
- [x] **Backend proksi** (Supabase Edge Function): `ai-coach`, `telegram-notify`, `vision-analyze`. `GEMINI_API_KEY` va `TELEGRAM_BOT_TOKEN` faqat secrets da. Ilovada `SUPABASE_URL` va `SUPABASE_ANON_KEY`. JWT — anonim sessiya (telefon OTP hali ochiq). Tezlik chegarasi `edge_rate_limits`. Sessiya yoki tarmoq xatosida lokal fallback.
- [x] **Haqiqiy Auth:** `SupabaseAuthService` telefon OTP. `StubAuthService` faqat debug va Supabase sozlanmaganda. Release da istalgan kod bilan kirib bo‘lmaydi.
- [x] **Obuna / trial holati serverda.** `profiles.subscription_expires_at` mijoz yozolmaydi. `MasteryHelper` server vaqti keshi bilan qaraydi; telefon soatini orqaga surish muddatni uzaytirmaydi.
- [ ] **Bolalar ma’lumoti:** ota-ona roziligi, yuz tahlilini faqat qurilmada bajarish, rasmlarni saqlash muddati, O‘zbekistonning shaxsiy ma’lumotlar to‘g‘risidagi qonuni talablarini tekshirish; Google Play "Families" / App Store "Kids" qoidalari.

### P1 — mahsulot
- [x] **Real Vision OCR.** `RemoteVisionAiService` rasmni siqib `vision-analyze` ga yuboradi. Yaroqsiz JSON bir marta qayta uriniladi, keyin xato. `confidence < 0.75` da qadamlar tasdiqlanadi, avtomatik baholanmaydi. Rasm saqlanmaydi. Stub faqat debug.
- [x] **Telegram ulash:** ota-ona panelidan bir martalik kod, `t.me/<bot>?start=<kod>`. `telegram-webhook` kodni tekshirib `profiles.telegram_chat_id` ga yozadi. Muddati o‘tgan yoki ishlatilgan kodga o‘zbekcha javob. Webhook `secret_token` bilan. Ulanmasa ogohlantirish lokal jurnalda. Bot tokeni ilovada yo‘q.
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
