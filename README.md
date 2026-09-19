# PMath

**PMath** — Prezident va ixtisoslashgan maktablarga tayyorlanuvchi 3–4-sinf o‘quvchilari uchun gamified virtual maktab.

## Ishga tushirish

```bash
flutter pub get
flutter run
```

## Arxitektura

```
lib/
  core/          # ranglar, tema, utils, umumiy widgetlar
  models/        # User, Question, StudyPlan, Lesson, Homework
  services/      # storage, auth stub, gamification
  features/      # feature-first Clean Architecture
    home/
    learning_map/
    homework_scanner/
    parent_dashboard/
    onboarding/ … (keyingi bosqichlar)
```

## Brend

- Primary: `#1E293B`
- Accent: `#F59E0B`
- Success: `#10B981`

Interfeys tili: **o‘zbekcha**.

Batafsil reja: [ROADMAP.md](ROADMAP.md)

## GitHub

- Remote: `origin` — GitHub repoga ulangan.
- **Avtomatik push:** `git config core.hooksPath .githooks` (loyihada bir marta). Keyin har `git commit` dan so‘ng `origin` ga push qilinadi.
- **Cursor:** agent vazifa tugagach `.cursor/hooks.json` orqali `scripts/sync-to-github.ps1` ishlaydi (o‘zgarish bo‘lsa commit + push).
- Qo‘lda: `powershell -File scripts/sync-to-github.ps1`
- CI (ixtiyoriy): `scripts/flutter_ci.yml.example` ni `.github/workflows/` ga ko‘chiring. GitHub CLI uchun `gh auth refresh -s workflow` kerak bo‘lishi mumkin.

Maxfiy kalitlar (`GEMINI_API_KEY`, `TELEGRAM_BOT_TOKEN`) faqat `--dart-define` orqali build vaqtida — repoga kiritilmaydi.
