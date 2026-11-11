# PMath

**PMath** — Prezident va ixtisoslashgan maktablarga tayyorlanuvchi 3–4-sinf o‘quvchilari uchun gamified virtual maktab.

## Ishga tushirish

```bash
flutter pub get
flutter run
```

Ixtiyoriy konfiguratsiya (`--dart-define`):

| Kalit | Vazifasi |
|-------|----------|
| `GEMINI_API_KEY` | Bulutdagi AI tutor (bo‘lmasa lokal Sokratik qoidalar ishlaydi) |
| `GEMINI_MODEL` | Gemini model nomi (standart: `gemini-2.0-flash`) |
| `TELEGRAM_BOT_TOKEN` | Ota-onaga Telegram ogohlantirishlari |
| `TELEGRAM_CHAT_ID` | Standart chat ID (ixtiyoriy) |

> ⚠️ **Xavfsizlik:** `--dart-define` qiymatlari APK ichiga yoziladi va chiqarib olinishi mumkin.
> Faqat development uchun ishlating. Production da Gemini/Telegram/Vision chaqiruvlari backend
> (Supabase Edge Function) orqali o‘tishi kerak. Batafsil: [docs/AUDIT.md](docs/AUDIT.md).

## Arxitektura

```
lib/
  core/          # ranglar, tema, konstantalar, utils (uz_text, iso_week, mastery_helper), umumiy widgetlar
  models/        # User, Question, StudyPlan, Lesson, Homework, ...
  services/      # storage, auth (stub), gamification, ai_tutor, vision_ai (stub), parent_alert, tts/stt
  features/      # feature-first Clean Architecture
    onboarding/  diagnostic/  study_plan/  learning_map/  lesson/  practice/
    homework/  homework_scanner/  grading/  error_analysis/  mastery_lock/
    exam/  proctoring/  gamification/  parent_dashboard/  subscription/
    voice_ai/  voice_assistant/   # ← birlashtirish kerak (docs/AUDIT.md)
    home/
```

## Brend

- Primary: `#1E293B`
- Accent: `#F59E0B`
- Success: `#10B981`

Interfeys tili: **o‘zbekcha**.

Reja va haqiqiy holat (✅ / 🟡 stub / ⬜): [ROADMAP.md](ROADMAP.md) · Audit: [docs/AUDIT.md](docs/AUDIT.md)

## Testlar

```bash
flutter analyze
flutter test
```

CI: `.github/workflows/flutter_ci.yml` (push va pull request da `analyze` + `test`).

## GitHub

- Remote: `origin` — GitHub repoga ulangan.
- **Tavsiya:** `main` ga to‘g‘ridan-to‘g‘ri emas, feature branch + Pull Request orqali ishlang
  (va GitHub da `main` uchun branch protection yoqing).
- **Avtomatik push (ixtiyoriy):** `git config core.hooksPath .githooks` — har `git commit` dan so‘ng `origin` ga push.
  Ko‘rib chiqilmagan o‘zgarishlar ham ketishini unutmang: avtomatik push ni faqat shaxsiy feature branchda ishlating.
- **Cursor:** agent vazifa tugagach `.cursor/hooks.json` orqali `scripts/sync-to-github.ps1` ishlaydi (o‘zgarish bo‘lsa commit + push).
- Qo‘lda: `powershell -File scripts/sync-to-github.ps1`

Maxfiy kalitlar (`GEMINI_API_KEY`, `TELEGRAM_BOT_TOKEN`) repoga kiritilmaydi.
