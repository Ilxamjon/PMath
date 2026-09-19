/// Ilova bo‘ylab o‘zbek tilidagi matnlar (i18n asosi).
abstract final class AppStrings {
  static const String appName = 'PMath';
  static const String appTagline = 'Prezident maktabi uchun matematik tayyorgarlik';

  // —— Pastki navigatsiya ——
  static const String tabMap = 'Xarita';
  static const String tabScanner = 'Skaner';
  static const String tabParent = 'Ota-ona';

  // —— O‘quv xaritasi ——
  static const String learningMapTitle = 'O‘quv yo‘li';
  static const String streakLabel = 'Ketma-ketlik';
  static const String coinsLabel = 'Tangalar';
  static const String levelLabel = 'Daraja';
  static const String lessonLocked = 'Qulflangan';
  static const String lessonActive = 'Davom eting';
  static const String lessonCompleted = 'Yakunlangan';
  static const String masteryRequired = 'Keyingi dars uchun 80%+ kerak';
  static const String masteryLockTitle = 'Mastery Lock';
  static const String masteryLockBody =
      '«{title}» darsi hozircha {pct}%. Keyingi dars uchun kamida {need}% kerak.';
  static const String masteryLockRemaining =
      'Yana {left}% o‘zlashtirish kerak';
  static const String masteryLockHint =
      'Oldingi darsni qayta mashq qiling yoki uyga vazifani yaxshilang.';
  static const String subscriptionGateTitle = 'Obuna kerak';
  static const String subscriptionGateBody =
      '{days} kunlik bepul sinov tugadi. Keyingi darslarni ochish uchun obuna bo‘ling.';
  static const String subscriptionGatePrices =
      'Oyiga {m} · 6 oy {s}';
  static const String subscriptionGateCta = 'Obuna tanlash';
  static const String subscriptionExpiredBanner =
      'Sinov tugadi — obuna qiling, darslar davom etsin';
  static const String trialDaysLeftBanner =
      'Sinovdan {n} kun qoldi';
  static const String paywallTitle = 'PMath obuna';
  static const String paywallHero = 'O‘qishni to‘xtatmang';
  static const String paywallHeroBody =
      'Mastery Lock, AI dars va skaner — to‘liq ochiq qoladi.';
  static const String paywallMonthly = '1 oy';
  static const String paywallMonthlyHint = 'Har oy yangilanadi';
  static const String paywallSixMonth = '6 oy';
  static const String paywallSixMonthHint = 'Tejalgan tarif';
  static const String paywallStubNote =
      'Demo: to‘lov Click/Payme keyinroq. Hozir «faollashtirish» stub.';
  static const String paywallActivated = 'Obuna faollashtirildi!';
  static const String practiceBlockedSubscription =
      '80%+ bor, lekin obuna kerak — keyingi dars yopiq.';
  static const String weekPrefix = 'Hafta';

  // —— Uyga vazifa skaneri ——
  static const String scannerTitle = 'Uyga vazifa skaneri';
  static const String scannerHint =
      'Daftaringizdagi yechimni kameraga tuting. AI qadamma-qadam tekshiradi.';
  static const String openCamera = 'Kamerani ochish';
  static const String capturePhoto = 'Rasmga olish';
  static const String visionAiPlaceholder = 'Vision AI tez orada ulanadi';
  static const String scanResultSoon = 'Natija tahlili keyingi bosqichda';

  // —— Ota-ona paneli ——
  static const String parentTitle = 'Ota-ona paneli';
  static const String progressOverview = 'Umumiy progress';
  static const String weakTopics = 'Zaif mavzular';
  static const String hoursSpent = 'Sarflangan vaqt';
  static const String cheatingAttempts = 'Nazorat ogohlantirishlari';
  static const String masteryPercent = 'O‘zlashtirish';
  static const String telegramAlerts = 'Telegram ogohlantirishlar';
  static const String telegramStatusOn = 'Bot ulangan';
  static const String telegramStatusOff =
      'Chat ID kiriting yoki TELEGRAM_BOT_TOKEN bering';
  static const String telegramChatIdHint = 'Telegram chat_id';
  static const String telegramSave = 'Saqlash';
  static const String telegramTest = 'Test xabar yuborish';
  static const String telegramRecent = 'So‘nggi xabarlar';
  static const String telegramEmptyLog = 'Hali xabar yo‘q';
  static const String telegramSaved = 'Chat ID saqlandi';
  static const String telegramTestSent = 'Test xabar yuborildi / jurnalga yozildi';
  static const String telegramHowTo =
      'Botga /start yozing, chat_id ni @userinfobot dan oling.';
  static const String parentLessonsProgress = 'Darslar progressi';
  static const String parentOverdueAlerted =
      '{n} ta kechikkan vazifa uchun ota-onaga xabar yuborildi';
  static const String parentStreakAlerted =
      'Streak xavfi — ota-onaga Telegram/SMS eslatma';
  static const String parentStreakLabel = 'Streak';
  static const String trialDaysLeft = 'Sinov kunlari qoldi';
  static const String subscriptionNeeded = 'Obuna kerak';

  // —— Onboarding ——
  static const String welcomeTitle = 'Xush kelibsiz!';
  static const String welcomeSubtitle =
      'PMath — Prezident maktabi uchun qattiq intizomli virtual maktab.';
  static const String welcomeTrial =
      'Ro‘yxatdan o‘tgach 7 kun bepul sinov ochiladi.';
  static const String startBtn = 'Boshlash';

  static const String nameTitle = 'O‘quvchi ismi';
  static const String nameHint = 'Masalan: Ali';
  static const String nameError = 'Ismni kiriting (kamida 2 harf)';

  static const String gradeTitle = 'Qaysi sinfda o‘qiysiz?';
  static const String gradeSubtitle = '3-yoki 4-sinfni tanlang';

  static const String schoolTitle = 'Maqsad maktab';
  static const String schoolHint = 'Masalan: Prezident maktabi';
  static const String schoolError = 'Maktab nomini kiriting';
  static const String schoolPresidential = 'Prezident maktabi';
  static const String schoolSpecialized = 'Ixtisoslashgan maktab';
  static const String schoolOther = 'Boshqa';

  static const String phoneTitle = 'Ota-ona telefoni';
  static const String phoneSubtitle =
      'SMS orqali tasdiqlash kodi yuboriladi. Progress va ogohlantirishlar shu raqamga bog‘lanadi.';
  static const String phoneHint = '90 123 45 67';
  static const String phonePrefix = '+998';
  static const String phoneError = 'To‘g‘ri O‘zbekiston raqamini kiriting';
  static const String sendOtp = 'Kod yuborish';

  static const String otpTitle = 'Tasdiqlash kodi';
  static const String otpSubtitle = 'SMS dagi 6 xonali kodni kiriting';
  static const String otpHint = '------';
  static const String otpError = 'Kod noto‘g‘ri. Qayta urinib ko‘ring';
  static const String otpResend = 'Qayta yuborish';
  static const String verifyOtp = 'Tasdiqlash';
  static const String otpDevHint = 'Sinov: istalgan 4+ xonali kod (masalan 1234)';

  static const String finishTitle = 'Tayyor!';
  static const String finishSubtitle =
      '7 kunlik bepul sinov boshlandi. Endi diagnostikaga tayyorlanamiz.';
  static const String goToApp = 'Diagnostikaga o‘tish';

  static const String stepOf = 'qadam';
  static const String back = 'Orqaga';

  // —— Diagnostik test ——
  static const String diagnosticTitle = 'Diagnostik test';
  static const String diagnosticIntroTitle = 'Bilim darajangizni bilib olaylik';
  static const String diagnosticIntroBody =
      '10 ta savol: Mantiq, Geometriya, Arifmetika va Ketma-ketlik. Natija asosida 6 oylik shaxsiy reja tuziladi.';
  static const String diagnosticRules =
      '• Vaqt: 10 daqiqa\n• Har bir savolga diqqat bilan javob bering\n• Keyingi savolga o‘tgach orqaga qaytib bo‘lmaydi';
  static const String diagnosticStart = 'Testni boshlash';
  static const String diagnosticQuestion = 'Savol';
  static const String diagnosticNext = 'Keyingi';
  static const String diagnosticFinish = 'Yakunlash';
  static const String diagnosticTimeUp = 'Vaqt tugadi!';
  static const String diagnosticSelectAnswer = 'Javobni tanlang';
  static const String diagnosticResultsTitle = 'Diagnostika natijasi';
  static const String diagnosticOverall = 'Umumiy natija';
  static const String diagnosticCorrect = 'To‘g‘ri';
  static const String diagnosticOf = 'ta dan';
  static const String diagnosticStrong = 'Kuchli tomonlar';
  static const String diagnosticWeak = 'Zaif tomonlar';
  static const String diagnosticContinueRoadmap = 'Shaxsiy reja yaratish';
  static const String diagnosticCategoryScore = 'Kategoriya bo‘yicha';
  static const String diagnosticNoWeak = 'Zaif mavzu topilmadi — ajoyib!';
  static const String diagnosticNoStrong = 'Hali kuchli mavzu yo‘q — mashq qilamiz!';
  static const String diagnosticTimeLeft = 'Qolgan vaqt';

  // —— AI Roadmap (3-bosqich) ——
  static const String roadmapGeneratingTitle = 'AI shaxsiy reja tuzmoqda...';
  static const String roadmapGeneratingBody =
      'Diagnostika natijangiz asosida 6 oylik haftalik yo‘l chizilmoqda.';
  static const String roadmapReadyTitle = 'Sizning 6 oylik rejangiz tayyor!';
  static const String roadmapReadyBody =
      'Zaif mavzular birinchi navbatda mustahkamlanadi. Har hafta 2 dars + oy yakunida mini-imtihon.';
  static const String roadmapWeeks = 'hafta';
  static const String roadmapLessons = 'dars';
  static const String roadmapMonths = 'oy';
  static const String roadmapFocus = 'Asosiy e’tibor';
  static const String roadmapOpenMap = 'O‘quv xaritasini ochish';
  static const String roadmapStepAnalyze = 'Natijalar tahlil qilinmoqda';
  static const String roadmapStepWeak = 'Zaif mavzular tartiblanmoqda';
  static const String roadmapStepWeeks = '24 haftalik reja tuzilmoqda';
  static const String roadmapStepLessons = 'Darslar va Mastery Lock qo‘yilmoqda';
  static const String roadmapEmpty =
      'Reja topilmadi. Diagnostikadan keyin qayta yarating.';
  static const String roadmapWeekHeader = 'Hafta';

  // —— AI dars xonasi (4-bosqich) ——
  static const String lessonRoomTitle = 'AI dars xonasi';
  static const String lessonIntro = 'Kirish';
  static const String lessonSocratic = 'Sokratik savol';
  static const String lessonSummary = 'Xulosa';
  static const String lessonDone = 'Dars tugadi!';
  static const String lessonListen = 'Tinglash';
  static const String lessonStopAudio = 'To‘xtatish';
  static const String lessonReplay = 'Qayta tinglash';
  static const String lessonThoughtHint = 'O‘y-fikringizni yozing (ixtiyoriy)...';
  static const String lessonIThought = 'O‘ylab ko‘rdim';
  static const String lessonNextPrompt = 'Keyingi savol';
  static const String lessonFinishLesson = 'Darsni yakunlash';
  static const String lessonGoPractice = 'Mashqqa o‘tish';
  static const String lessonPracticeSoon =
      'Endi 3–5 ta qisqa mashq bilan bilimni mustahkamlaymiz!';
  static const String lessonSocraticHint =
      'To‘g‘ridan-to‘g‘ri javob berilmaydi. O‘zingiz o‘ylab toping!';
  static const String lessonCoachName = 'Ustoz AI';
  static const String lessonProctoringOn = 'Nazorat faol';
  static const String proctoringPaused = 'Pauza';
  static const String proctoringLive = 'LIVE';
  static const String proctoringWarningCount = 'Ogohlantirish';
  static const String proctoringParentNotified =
      'Ota-onaga xabar yuborildi (Telegram/SMS hook).';
  static const String proctoringResume = 'Kameraga qaradim — davom etish';
  static const String proctoringSimulateHint =
      'PIP ni bosib turing: demo ogohlantirish';
  static const String lessonCoinsEarned = 'tangalar';
  static const String lessonExitConfirm = 'Darsdan chiqasizmi?';
  static const String lessonExitYes = 'Chiqish';
  static const String lessonExitNo = 'Davom etish';
  static const String lessonStepOf = 'qadam';

  // —— Ovozli AI (15-bosqich) ——
  static const String voiceAskHint = 'Savolingizni ayting…';
  static const String voiceListening = 'Tinglayapman…';
  static const String voiceYouSaid = 'Siz';
  static const String voiceCoachReply = 'Ustoz AI';
  static const String voiceMicTooltip = 'Ovozli savol';
  static const String voiceMicStop = 'Tinglashni to‘xtatish';
  static const String voiceUnavailable =
      'Nutq tanish ishlamadi — matn yozing yoki qayta urinib ko‘ring';
  static const String voicePanelTitle = 'Ovozli yordamchi';
  static const String aiRoleBanner =
      'AI vazifasi: ovozli savol-javob (Gemini) + Sokratik yo‘naltirish. '
      'Chizma dars ichida avtomatik chiqadi.';
  static const String visualLookHint = 'Chizmaga qarang';

  // —— Tushuncha mashqi (5-bosqich) ——
  static const String practiceTitle = 'Tushuncha mashqi';
  static const String practiceSubtitle = 'Tez va qiziqarli!';
  static const String practiceQuestion = 'Mashq';
  static const String practiceCorrect = 'To‘g‘ri! 🎉';
  static const String practiceWrong = 'Xato — qayta urinib ko‘ring!';
  static const String practiceNext = 'Keyingi';
  static const String practiceFinish = 'Natijani ko‘rish';
  static const String practiceResults = 'Mashq natijasi';
  static const String practiceMastery = 'O‘zlashtirish';
  static const String practiceUnlocked = 'Keyingi dars ochildi!';
  static const String practiceLockedStill =
      'Keyingi dars uchun kamida 80% kerak. Qayta mashq qiling!';
  static const String practiceBackToMap = 'Xaritaga qaytish';
  static const String practiceRetry = 'Qayta mashq';
  static const String practiceStreakBonus = 'Ketma-ket to‘g‘ri';
  static const String practiceCoins = 'Tangalar';
  static const String practiceSelect = 'Javobni tanlang';

  // —— Yozma uyga vazifa (6-bosqich) ——
  static const String homeworkTitle = 'Yozma uyga vazifa';
  static const String homeworkAssigned = 'Uyga vazifa berildi!';
  static const String homeworkAssignedBody =
      'Masalani daftaringizga bosqichma-bosqich yozing. Keyin skaner orqali topshirasiz.';
  static const String homeworkDue = 'Muddat';
  static const String homeworkOverdue = 'Muddati o‘tgan';
  static const String homeworkPending = 'Kutilayotgan vazifalar';
  static const String homeworkEmpty = 'Hozircha uyga vazifa yo‘q';
  static const String homeworkWriteInNotebook = 'Daftarga yozing';
  static const String homeworkStepsHint =
      '1) Masalani o‘qing\n2) Yechimni qadamma-qadam yozing\n3) Skaner orqali rasmga oling';
  static const String homeworkGoScan = 'Skanerga o‘tish';
  static const String homeworkView = 'Vazifani ko‘rish';
  static const String homeworkStatus = 'Holat';
  static const String homeworkParentAlert =
      'Ota-onaga eslatma yuborildi (Telegram/SMS hook).';
  static const String homeworkMissedStreak =
      'Vazifa o‘tkazib yuborilsa streak yo‘qolishi mumkin.';
  static const String homeworkMarkReady = 'Yozib bo‘ldim — skanerlash';
  static const String homeworkSubmittedWait =
      'Qabul qilindi. Vision AI qadamlarni ajratdi.';
  static const String homeworkSelectToScan = 'Skanerlash uchun vazifani tanlang';
  static const String homeworkToday = 'Bugun';
  static const String homeworkTomorrow = 'Ertaga';

  // —— Vision AI skaner (7-bosqich) ——
  static const String visionAnalyzing = 'Vision AI tahlil qilmoqda...';
  static const String visionStepsTitle = 'Ajratilgan qadamlar';
  static const String visionConfidence = 'Ishonch';
  static const String visionRawOcr = 'OCR matn';
  static const String visionOpenCamera = 'Kamerani ochish';
  static const String visionPickGallery = 'Galereyadan';
  static const String visionDemoScan = 'Demo skan (kamera yo‘q)';
  static const String visionCameraError =
      'Kamera ochilmadi. Galereya yoki demo skanni ishlating.';
  static const String visionCapture = 'Rasmga olish';
  static const String visionRetake = 'Qayta olish';
  static const String visionAnalyze = 'AI tahlil';
  static const String visionResultTitle = 'Skaner natijasi';
  static const String visionJsonPreview = 'JSON qadamlar';
  static const String visionReadyForGrade =
      'Qadamlar tayyor — AI baholashga o‘ting.';
  static const String visionGoGrade = 'Baholashga o‘tish';
  static const String visionBackScanner = 'Skanerga qaytish';
  static const String visionNoCamera = 'Kamera mavjud emas';

  // —— AI baholash (8-bosqich) ——
  static const String gradingTitle = 'AI baholash';
  static const String gradingAnalyzing = 'Qadamlar tekshirilmoqda...';
  static const String gradingAnalyzingHint =
      'Har bir qadam to‘g‘ri yechim bilan solishtiriladi';
  static const String gradingRetry = 'Qayta urinish';
  static const String gradingPassed = 'Mastery Lock ochildi!';
  static const String gradingNeedsRevision = 'Qayta ishlash kerak';
  static const String gradingCoins = 'tanga';
  static const String gradingStepsOk = 'to‘g‘ri';
  static const String gradingStepsTitle = 'Qadamma-qadam tekshiruv';
  static const String gradingHint = 'To‘g‘ri yo‘l';
  static const String gradingDone = 'Tayyor';
  static const String gradingBackRevise = 'Qayta yozish uchun';
  static const String gradingToMap = 'Xaritaga qaytish';
  static const String gradingNextUnlocked = 'Keyingi dars ochildi!';
  static const String gradingRecent = 'Baholangan vazifalar';
  static const String gradingOpenErrors = 'Xatolarni tahlil qilish';

  // —— Xato tahlili (9-bosqich) ——
  static const String errorAnalysisTitle = 'Xato tahlili';
  static const String errorAnalysisListen = 'Tinglash';
  static const String errorAnalysisNoErrors = 'Xato yo‘q — zo‘r ish!';
  static const String errorAnalysisDoneTitle = 'Tahlil tugadi';
  static const String errorAnalysisDoneBody =
      '{n} ta xatoni ko‘rib chiqdingiz. Endi daftarga qayta yozib, skanerlang.';
  static const String errorAnalysisRewrite = 'Qayta yozishga tayyorman';
  static const String errorAnalysisProgress = 'Xato';
  static const String errorAnalysisYourStep = 'Sizning qadamingiz';
  static const String errorAnalysisWhy = 'Nima bo‘ldi?';
  static const String errorAnalysisThink = 'O‘ylab ko‘ring';
  static const String errorAnalysisQuestions = 'Sokratik savollar';
  static const String errorAnalysisSoftHint = 'Yumshoq ishora';
  static const String errorAnalysisSoftHintFallback =
      'Oldingi to‘g‘ri qadamdan davom eting.';
  static const String errorAnalysisFullHint = 'To‘g‘ri yo‘l (namuna)';
  static const String errorAnalysisRewriteHint =
      'Namunani ko‘rib, o‘zingizning so‘zlaringiz bilan daftarga yozing.';
  static const String errorAnalysisGoThink = 'Savollarga o‘tish';
  static const String errorAnalysisShowHint = 'Ishorani ko‘rsat';
  static const String errorAnalysisShowAnswer = 'Namunani ko‘rsat';
  static const String errorAnalysisNextError = 'Keyingi xato';
  static const String errorAnalysisFinish = 'Tugallash';

  // —— Mini-imtihon (11-bosqich) ——
  static const String examBadge = 'Mini-imtihon';
  static const String examIntroBody =
      '{n} ta savol · {m} daqiqa. Prezident maktabi uslubida vaqtni taqsimlang.';
  static const String examRule1 = 'Har bir savolga bitta javob tanlang';
  static const String examRule2 = 'Vaqt tugasa test avtomatik yakunlanadi';
  static const String examRule3 = '80%+ — Mastery Lock ochiladi va liga yangilanadi';
  static const String examStart = 'Imtihonni boshlash';
  static const String examQuestion = 'Savol';
  static const String examFinish = 'Yakunlash';
  static const String examSelectAnswer = 'Javobni tanlang';
  static const String examTimeUp = 'Vaqt tugadi! Natija hisoblandi.';
  static const String examReportTitle = 'Imtihon hisoboti';
  static const String examScore = 'Ball';
  static const String examCorrect = 'To‘g‘ri javoblar';
  static const String examTimeSpent = 'Sarflangan vaqt';
  static const String examCoins = 'Tangalar';
  static const String examLeagueTitle = 'Liga o‘rni';
  static const String examRank = 'Taxminiy o‘rin: {rank} / {pool}';
  static const String examByCategory = 'Kategoriya bo‘yicha';
  static const String examUnlocked = 'Keyingi dars ochildi!';
  static const String examNeedMastery =
      '80% yetmadi — keyingi dars yopiq. Qayta tayyorlaning.';
  static const String examBackToMap = 'Xaritaga qaytish';
  static const String examDoneSnack = 'Imtihon yakunlandi';
  static const String examRecent = 'So‘nggi imtihon';

  // —— Gamification ——
  static const String gamificationTitle = 'Mukofotlar va liga';
  static const String gamificationAvatars = 'Avatarlar';
  static const String gamificationLeague = 'Liga';
  static const String gamificationPickAvatar = 'Avatar tanlang';
  static const String gamificationWeeklyXp = 'Haftalik XP';
  static const String gamificationRank = 'O‘rin';
  static const String gamificationLeaderboard = 'Haftalik jadval';
  static const String gamificationYou = 'siz';
  static const String gamificationDailyBonus =
      '+{coins} tanga · +{xp} XP kunlik bonus!';
  static const String gamificationStreakUp = 'Streak: {n} kun 🔥';
  static const String gamificationAvatarUnlocked =
      'Yangi avatar: {name}';

  // —— Umumiy ——
  static const String hours = 'soat';
  static const String minutes = 'daq';
  static const String percent = '%';
  static const String continueBtn = 'Davom etish';
  static const String cancel = 'Bekor qilish';
  static const String ok = 'OK';
  static const String loading = 'Yuklanmoqda...';
  static const String somethingWrong = 'Xatolik yuz berdi. Qayta urinib ko‘ring';
}
