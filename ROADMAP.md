# PMath — 15 bosqichli Roadmap Execution Plan

> Maqsad: 3–4-sinf o‘quvchilarini Prezident / ixtisoslashgan maktablarga tayyorlash.
> Arxitektura: Clean Architecture · State: `flutter_bloc` · Backend: Supabase · UI: o‘zbek tili.

**Status belgilari:** ✅ haqiqiy ishlaydi · 🟡 stub / demo (backend yoki real servis yo‘q) · ⬜ boshlanmagan.
Batafsil audit va ochiq xavflar: [docs/AUDIT.md](docs/AUDIT.md).

---

## Hozirgi holat (Foundation — ✅ tayyor)

| Qism | Holat |
|------|--------|
| Clean Architecture `lib/` tuzilmasi | ✅ |
| Modelllar (User, Question, StudyPlan, Lesson, Homework) | ✅ |
| `AppTheme` + brend ranglar | ✅ |
| Bottom Nav: Xarita / Skaner / Ota-ona | ✅ |
| Duolingo-uslubidagi Learning Map (demo) | ✅ |
| Mastery Lock 80% qoidasi (helper) | ✅ |
| Storage / Auth stub | 🟡 |

---

## Bosqichma-bosqich bajarish rejasi

### 1-bosqich — Onboarding & Profil ✅ (Auth: 🟡 stub)
**Maqsad:** Ism, sinf (3/4), maqsad maktab, ota-ona telefoni.
- [x] Onboarding UI (welcome → ism → sinf → maktab → telefon → OTP → done)
- [x] `UserModel` ni `StorageService` ga yozish
- [ ] 🟡 Auth abstraksiya + Stub OTP — hozir istalgan 4+ belgili kod o‘tadi; haqiqiy Supabase Phone OTP hali ulanmagan
- [x] 7 kunlik trial timer (`subscriptionExpiresAt` + `SubscriptionStatus.trial`) — ⚠️ lokal, server tekshiruvi yo‘q

**Qabul sharti:** Profil saqlanadi, keyingi ochilishda Dashboard ga o‘tadi. ✅

---

### 2-bosqich — Diagnostik test (10 savol) ✅
**Maqsad:** Mantiq, Geometriya, Arifmetika, Ketma-ketlik bazasi.
- [x] Savollar banki (LaTeX: `flutter_math_fork`)
- [x] Timer + progress bar
- [x] Natijani kategoriyalar bo‘yicha foizlash
- [x] `QuestionModel` + lokal repository + natija saqlash

**Qabul sharti:** 10 savol yakunlanadi, zaif/kuchli mavzular chiqadi. ✅

---

### 3-bosqich — AI shaxsiy 6 oylik roadmap ✅
**Maqsad:** Diagnostika asosida haftalik reja.
- [x] Lokal AI generator + LLM/Edge Function uchun abstraksiya (`StudyPlanGenerator`)
- [x] `StudyPlanModel` + `LessonModel` generatsiya va saqlash
- [x] Learning Map tugmalarini reja `lessonIds` bilan bog‘lash
- [x] Generatsiya UI (progress → ready)

**Qabul sharti:** Xaritada real `lessonIds` ko‘rinadi. ✅

---

### 4-bosqich — Interaktiv AI dars xonasi ✅
**Maqsad:** TTS + vizual + Sokratik savollar.
- [x] Lesson Room UI
- [x] TTS (o‘zbekcha audio — `flutter_tts`) — ⚠️ `uz-UZ` ovozi qurilmaga bog‘liq, real telefonlarda sinash kerak
- [x] Sokratik promptlar (`LessonModel.socraticPrompts`)
- [x] Proctoring hook (12-bosqich uchun stub)

**Qabul sharti:** Dars audio+matn bilan tugaydi, mashqqa o‘tadi. ✅

---

### 5-bosqich — Tushuncha mashqi (3–5 ta) ✅
**Maqsad:** Darsdan keyin gamified mini-mashqlar.
- [x] Quick quiz UI (tangalar, combo, feedback animatsiya)
- [x] Natijani mastery ga qo‘shish + 80% da keyingi darsni ochish

**Qabul sharti:** Mashq yakunida foiz yangilanadi. ✅

---

### 6-bosqich — Yozma uyga vazifa ✅
**Maqsad:** Daftarga yozish topshirig‘i.
- [x] `HomeworkModel` assign flow (mashqdan keyin)
- [x] Ota-ona / o‘quvchi eslatma (`ParentAlertService` stub)
- [x] Muddat (`dueAt`) va streak ogohlantirish hooki
- [x] Skaner tabida kutilayotgan vazifalar

**Qabul sharti:** Vazifa beriladi, skaner kutadi. ✅

---

### 7-bosqich — Vision AI skaner (OCR) 🟡
**Maqsad:** Daftar sahifasini kamera orqali tahlil.
- [x] `camera` package real preview (+ galereya / demo fallback)
- [ ] 🟡 Rasmni Vision AI servisga yuborish (`VisionAiService`) — hozir `StubVisionAiService`: rasmni o‘qimaydi, masala matnidan namuna qadamlar yasaydi
- [ ] 🟡 Qadamlar ekstraksiyasi (JSON) — format tayyor, real OCR/Vision model ulanmagan
- [ ] ⬜ Ishonch darajasi past bo‘lsa ota-ona qadamlarni tasdiqlaydigan ekran

**Qabul sharti:** Rasm yuboriladi, qadamlar JSON qaytadi. 🟡 (real modelsiz — demo)

---

### 8-bosqich — AI baholash & Mastery %
**Maqsad:** Qadamma-qadam tekshiruv + foiz.
- [x] Grading prompt / model (`LocalAiGradingService`)
- [x] `masteryPercent` yangilash (homework + lesson)
- [x] Natija ekrani (foiz, tanga, qadamlar)

**Qabul sharti:** Foiz saqlanadi, Map va Ota-ona panelida ko‘rinadi. ✅

---

### 9-bosqich — Interaktiv xato tahlili
**Maqsad:** Noto‘g‘ri qadamlarni sodda o‘zbekcha tushuntirish.
- [x] `HomeworkErrorStep` UI (`ErrorAnalysisPage`)
- [x] Sokratik qayta yo‘naltirish (`ErrorAnalysisCoach`)

**Qabul sharti:** Har bir xato uchun tushuntirish chiqadi. ✅

---

### 10-bosqich — Mastery Lock (80%+)
**Maqsad:** N+1 dars N 80%+ bo‘lmaguncha yopiq.
- [x] Lock logikasi (`MasteryHelper` + Map + storage unlock)
- [x] Blok modal (o‘zbekcha)
- [x] Obuna gate (7 kundan keyin) + stub paywall — 🟡 lokal, server tomonida tekshirilmaydi

**Qabul sharti:** 79% da keyingi dars ochilmaydi. ✅

---

### 11-bosqich — Haftalik / oylik imtihonlar
**Maqsad:** Prezident maktabi uslubidagi simulyatsiya.
- [x] Timer, savollar to‘plami (`ExamPage` + `ExamQuestionBank`)
- [x] Natija + ranking (liga) — 🟡 faqat lokal XP, haqiqiy reyting uchun backend kerak
- [x] `isExamWeek` bilan bog‘lash

**Qabul sharti:** Imtihon tugagach hisobot chiqadi. ✅

---

### 12-bosqich — Strict Proctoring Guard
**Maqsad:** Yuz yo‘q / ko‘p yuz / qarash ogohlantirishi.
- [x] Front camera + face detection hook (`LocalProctoringGuard`)
- [x] Warning modal, test pauza
- [x] `cheatingWarnings` ota-ona paneliga

**Qabul sharti:** Yuz yo‘qolsa test pauzalanadi. ✅

---

### 13-bosqich — Ota-ona paneli & Telegram
**Maqsad:** Progress, zaif mavzu, soat, cheating.
- [x] Real data (darslar mastery, streak, soat, imtihon)
- [x] Telegram Bot API alertlar (`TelegramParentAlertService`) — ⚠️ bot token hozir ilova ichida; backend orqali yuborish kerak
- [x] Streak yo‘qolishi → Telegram/lokal alert (`StreakMonitor`)
- [ ] ⬜ Chat ID ni `t.me/<bot>?start=<kod>` deep link bilan avtomatik bog‘lash

**Qabul sharti:** Missed homework → ota-ona xabar oladi. ✅

---

### 14-bosqich — Gamification Engine
**Maqsad:** 🔥 Streak, 🪙 tanga, daraja, avatar, liga.
- [x] `GamificationService` — streak, XP/level, kunlik bonus, avatar unlock
- [x] Avatar katalog + hub UI (`GamificationHubPage`)
- [x] Weekly league leaderboard — 🟡 lokal
- [x] Kunlik ochilish streak persist (`recordDailyOpen`)
- [x] Header: avatar emoji + XP progress

**Qabul sharti:** Kunlik faollik streak ni saqlaydi. ✅

---

### 15-bosqich — Ovozli AI yordamchi
**Maqsad:** STT + TTS o‘zbekcha.
- [x] Speech-to-Text (`SttService` / `speech_to_text`)
- [x] Text-to-Speech (`TtsService` / `flutter_tts`)
- [x] Dars xonasiga integratsiya (mik + VoiceAiCoach)
- [x] Android/iOS mikrofon va nutq ruxsatlari

**Qabul sharti:** Ovozli savol → javob audio. ✅

---

## Monetizatsiya (parallel track)

| Element | Qiymat |
|---------|--------|
| Sinov | 7 kun |
| Oylik | 30 000 UZS |
| 6 oylik | 120 000 UZS |
| To‘lov | Click / Payme / RevenueCat |

- [ ] Subscription feature + paywall UI
- [ ] Day 7+ darslarni qulflash
- [ ] Payment provider integratsiya
- [ ] ⚠️ Do‘kon (App Store / Google Play) to‘lov qoidalarini oldindan tekshirish

---

## Tavsiya etilgan sprintdlar

| Sprint | Bosqichlar | Taxminiy muddat |
|--------|------------|------------------|
| Sprint 0 | Foundation (shu commit) | ✅ |
| Sprint 1 | 1 + 2 + Auth | 1–1.5 hafta |
| Sprint 2 | 3 + 4 + 5 | 2 hafta |
| Sprint 3 | 6 + 7 + 8 + 9 | 2 hafta |
| Sprint 4 | 10 + 11 + 12 | 1.5 hafta |
| Sprint 5 | 13 + 14 + 15 + Pay | 2 hafta |

---

## Keyingi qadam (darhol)

1. **Backend + haqiqiy Auth** (Supabase, Edge Function proksi) — [docs/AUDIT.md](docs/AUDIT.md) dagi P0 bandlar.
2. **Real Vision OCR** va ota-ona tasdiqlash ekrani.
3. **Monetizatsiya** (Click/Payme/RevenueCat) yoki polish/sprint yakuni.

Buyruq: *«Paywall ni to‘liq qil»* yoki *«Sprint 5 ni yakunla»*.
