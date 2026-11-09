import Foundation

struct Strings {
    let tagline: String
    let scoringRow1: String
    let scoringRow2: String
    let scoringRow3: String
    let scoringRow4: String
    let highscore: String
    let start: String
    let settings: String
    let menu: String
    let resume: String
    let paused: String
    let pause: String
    let moveLeft: String
    let moveRight: String
    let softDrop: String
    let hardDrop: String
    let rotateCW: String
    let rotateCCW: String
    let score: String
    let level: String
    let lines: String
    let next: String
    let gameOver: String
    let newBest: String
    let playAgain: String
    let back: String
    let musicLabel: String
    let sfxLabel: String
    let hapticsLabel: String
    let dayLabel: String
    let nightLabel: String
    let languageLabel: String
    let turkishLabel: String
    let englishLabel: String
    let ghostLabel: String
    let volumeLabel: String
    let musicVolumeLabel: String
    let sfxVolumeLabel: String
    let playlistLabel: String
    let modeFastName: String
    let modeOgName: String
    let modeHardName: String
    let modeFastSubtitle: String
    let modeOgSubtitle: String
    let modeHardSubtitle: String
    let aboutLine1: String
    let aboutLine2: String
    let aboutLine3: String
    let ultimateRiss: String
    let appearanceLabel: String
    let themeStyleLabel: String
    let themeClassic: String
    let themeHokusai: String
    let greatWave: String
    let announceOneRowCleared: String
    let announceRowsCleared: String
    let announceLevel: String
    let announceGameOver: String
    // Onboarding
    let howToPlay: String
    let onboardingSkip: String
    let onboardingNext: String
    let onboardingDone: String
    let onboardingStepFormat: String
    let onboardingStepAccessibilityFormat: String
    let onboardingMoveTitle: String
    let onboardingMoveBody: String
    let onboardingTearTitle: String
    let onboardingTearBody: String
    let onboardingModesTitle: String
    let onboardingModesBody: String
    // Daily challenge
    let dailyButton: String
    let dailyTitle: String
    let dailySubtitle: String
    let dailyBestLabel: String
    let dailyBestFormat: String
    let streakLabel: String
    let streakOneDay: String
    let streakDaysFormat: String
    let dailyResets: String
    // Stats
    let statsTitle: String
    let statsGamesPlayed: String
    let statsRowsCleared: String
    let statsFourRowClears: String
    let statsBestScores: String
    let statsCurrentStreak: String
    let statsLongestStreak: String

    func modeName(_ mode: GameMode) -> String {
        switch mode {
        case .fast: return modeFastName
        case .og:   return modeOgName
        case .hard: return modeHardName
        }
    }

    func modeSubtitle(_ mode: GameMode) -> String {
        switch mode {
        case .fast: return modeFastSubtitle
        case .og:   return modeOgSubtitle
        case .hard: return modeHardSubtitle
        }
    }

    /// VoiceOver message after a line clear; `newLevel` is set when the clear raised the level.
    func clearAnnouncement(rows: Int, newLevel: Int?) -> String {
        let cleared = rows == 1 ? announceOneRowCleared : String(format: announceRowsCleared, rows)
        guard let newLevel else { return cleared }
        return cleared + ", " + String(format: announceLevel, newLevel)
    }

    /// VoiceOver message when the game ends.
    func gameOverAnnouncement(score: Int, isNewBest: Bool) -> String {
        let message = String(format: announceGameOver, score)
        return isNewBest ? message + " " + newBest : message
    }

    /// Visible step indicator, e.g. "1 of 3".
    func onboardingStep(_ step: Int, of total: Int) -> String {
        String(format: onboardingStepFormat, step, total)
    }

    /// VoiceOver text for the step indicator, e.g. "Step 1 of 3".
    func onboardingStepAccessibility(_ step: Int, of total: Int) -> String {
        String(format: onboardingStepAccessibilityFormat, step, total)
    }

    /// "Today's best: 4000". The caller formats the number: grouped on screen, plain for VoiceOver.
    func dailyBest(_ score: String) -> String {
        String(format: dailyBestFormat, score)
    }

    /// "1 day", "5 days": a streak length alone, e.g. as an accessibility value.
    func streakDays(_ days: Int) -> String {
        days == 1 ? streakOneDay : String(format: streakDaysFormat, days)
    }

    /// "Streak: 5 days".
    func dailyStreak(_ days: Int) -> String {
        streakLabel + ": " + streakDays(days)
    }

    static let tr = Strings(
        tagline: "sıraları yırt.",
        scoringRow1: "1 sıra · 100",
        scoringRow2: "2 sıra · 300",
        scoringRow3: "3 sıra · 1000",
        scoringRow4: "4 sıra · 4000 ★",
        highscore: "REKOR",
        start: "BAŞLA",
        settings: "AYARLAR",
        menu: "MENÜ",
        resume: "DEVAM",
        paused: "DURAKLATILDI",
        pause: "Duraklat",
        moveLeft: "Sola kaydır",
        moveRight: "Sağa kaydır",
        softDrop: "Aşağı indir",
        hardDrop: "En alta düşür",
        rotateCW: "Saat yönünde döndür",
        rotateCCW: "Saat yönünün tersine döndür",
        score: "SKOR",
        level: "SEVİYE",
        lines: "SATIR",
        next: "SONRAKİ",
        gameOver: "OYUN BİTTİ",
        newBest: "YENİ REKOR",
        playAgain: "TEKRAR OYNA",
        back: "GERİ",
        musicLabel: "Müzik",
        sfxLabel: "Ses efektleri",
        hapticsLabel: "Titreşim",
        dayLabel: "Gündüz",
        nightLabel: "Gece",
        languageLabel: "Dil",
        turkishLabel: "Türkçe",
        englishLabel: "English",
        ghostLabel: "İniş",
        volumeLabel: "Ses düzeyi",
        musicVolumeLabel: "Müzik sesi",
        sfxVolumeLabel: "Efekt sesi",
        playlistLabel: "Çalma listesi",
        modeFastName: "Çatlak",
        modeOgName: "Yırtık",
        modeHardName: "Parçalanma",
        modeFastSubtitle: "hızlı",
        modeOgSubtitle: "klasik",
        modeHardSubtitle: "zor",
        aboutLine1: "Tesseris — Yunanca, dört.",
        aboutLine2: "Riss — Almanca, bir yırtık.",
        aboutLine3: "Sıraları yırt — dördünü birden.",
        ultimateRiss: "ULTIMATE RISS",
        appearanceLabel: "Görünüm",
        themeStyleLabel: "Tema",
        themeClassic: "Klasik",
        themeHokusai: "Hokusai",
        greatWave: "MUHTEŞEM DALGA",
        announceOneRowCleared: "1 sıra temizlendi",
        announceRowsCleared: "%d sıra temizlendi",
        announceLevel: "Seviye %d",
        announceGameOver: "Oyun bitti. Skor %d.",
        howToPlay: "Nasıl oynanır",
        onboardingSkip: "ATLA",
        onboardingNext: "İLERİ",
        onboardingDone: "TAMAM",
        onboardingStepFormat: "%d / %d",
        onboardingStepAccessibilityFormat: "Adım %d, toplam %d",
        onboardingMoveTitle: "Kaydır ve döndür",
        onboardingMoveBody: "Parçayı sol ve sağ oklarla kaydır, kıvrık oklarla döndür. Aşağı indirmek için aşağı oka basılı tut. Çift ok parçayı en alta düşürür.",
        onboardingTearTitle: "Sıraları yırt",
        onboardingTearBody: "Bir sırayı uçtan uca doldurursan sıra yırtılır. Dört sırayı birden yırtmak 4000 puan kazandırır.",
        onboardingModesTitle: "Üç mod ve günlük meydan okuma",
        onboardingModesBody: "Çatlak küçük bir tahtada hızlı oynanır. Yırtık klasiktir. Parçalanma beş kareli parçalar da ekler. Günlük meydan okumada herkes o gün aynı parçaları alır.",
        dailyButton: "GÜNLÜK",
        dailyTitle: "Günlük meydan okuma",
        dailySubtitle: "Bugün herkese aynı parçalar.",
        dailyBestLabel: "BUGÜNÜN REKORU",
        dailyBestFormat: "Bugünün rekoru: %@",
        streakLabel: "Seri",
        streakOneDay: "1 gün",
        streakDaysFormat: "%d gün",
        dailyResets: "00:00 UTC'de sıfırlanır",
        statsTitle: "İstatistikler",
        statsGamesPlayed: "Oynanan oyun",
        statsRowsCleared: "Temizlenen sıra",
        statsFourRowClears: "Dörtlü yırtma",
        statsBestScores: "Rekorlar",
        statsCurrentStreak: "Güncel seri",
        statsLongestStreak: "En uzun seri"
    )

    static let en = Strings(
        tagline: "tear the rows.",
        scoringRow1: "1 row · 100",
        scoringRow2: "2 rows · 300",
        scoringRow3: "3 rows · 1000",
        scoringRow4: "4 rows · 4000 ★",
        highscore: "HIGHSCORE",
        start: "START",
        settings: "SETTINGS",
        menu: "MENU",
        resume: "RESUME",
        paused: "PAUSED",
        pause: "Pause",
        moveLeft: "Move left",
        moveRight: "Move right",
        softDrop: "Move down",
        hardDrop: "Drop to bottom",
        rotateCW: "Rotate clockwise",
        rotateCCW: "Rotate counterclockwise",
        score: "SCORE",
        level: "LEVEL",
        lines: "LINES",
        next: "NEXT",
        gameOver: "GAME OVER",
        newBest: "NEW BEST",
        playAgain: "PLAY AGAIN",
        back: "BACK",
        musicLabel: "Music",
        sfxLabel: "Sound effects",
        hapticsLabel: "Haptics",
        dayLabel: "Day",
        nightLabel: "Night",
        languageLabel: "Language",
        turkishLabel: "Türkçe",
        englishLabel: "English",
        ghostLabel: "Landing",
        volumeLabel: "Volume",
        musicVolumeLabel: "Music volume",
        sfxVolumeLabel: "Sound effects volume",
        playlistLabel: "Playlist",
        modeFastName: "Crack",
        modeOgName: "Tear",
        modeHardName: "Shatter",
        modeFastSubtitle: "fast",
        modeOgSubtitle: "classic",
        modeHardSubtitle: "hard",
        aboutLine1: "Tesseris — Greek, four.",
        aboutLine2: "Riss — German, a tear.",
        aboutLine3: "Tear the rows — four at once.",
        ultimateRiss: "ULTIMATE RISS",
        appearanceLabel: "Appearance",
        themeStyleLabel: "Theme",
        themeClassic: "Classic",
        themeHokusai: "Hokusai",
        greatWave: "A GREAT WAVE",
        announceOneRowCleared: "1 row cleared",
        announceRowsCleared: "%d rows cleared",
        announceLevel: "Level %d",
        announceGameOver: "Game over. Score %d.",
        howToPlay: "How to play",
        onboardingSkip: "SKIP",
        onboardingNext: "NEXT",
        onboardingDone: "DONE",
        onboardingStepFormat: "%d of %d",
        onboardingStepAccessibilityFormat: "Step %d of %d",
        onboardingMoveTitle: "Move and rotate",
        onboardingMoveBody: "Move the piece with the left and right arrows, and rotate it with the curved arrows. Hold the down arrow to move it down. The double arrow drops it to the bottom.",
        onboardingTearTitle: "Tear the rows",
        onboardingTearBody: "Fill a row from edge to edge to tear it. Four rows at once score 4000.",
        onboardingModesTitle: "Three modes and a daily challenge",
        onboardingModesBody: "Crack is fast, on a small board. Tear is classic. Shatter adds five-square pieces. In the daily challenge, everyone gets the same pieces that day.",
        dailyButton: "DAILY",
        dailyTitle: "Daily challenge",
        dailySubtitle: "Same pieces for everyone today.",
        dailyBestLabel: "TODAY'S BEST",
        dailyBestFormat: "Today's best: %@",
        streakLabel: "Streak",
        streakOneDay: "1 day",
        streakDaysFormat: "%d days",
        dailyResets: "Resets 00:00 UTC",
        statsTitle: "Stats",
        statsGamesPlayed: "Games played",
        statsRowsCleared: "Rows cleared",
        statsFourRowClears: "Four-row clears",
        statsBestScores: "Best scores",
        statsCurrentStreak: "Current streak",
        statsLongestStreak: "Longest streak"
    )

    static func current(for lang: Language) -> Strings {
        lang == .tr ? .tr : .en
    }
}
