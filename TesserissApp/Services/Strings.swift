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
    let score: String
    let level: String
    let lines: String
    let next: String
    let gameOver: String
    let newBest: String
    let playAgain: String
    let back: String
    let musicLabel: String
    let hapticsLabel: String
    let dayLabel: String
    let nightLabel: String
    let languageLabel: String
    let turkishLabel: String
    let englishLabel: String
    let ghostLabel: String
    let volumeLabel: String
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

    static let tr = Strings(
        tagline: "Dizileri yırt.",
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
        score: "SKOR",
        level: "SEVİYE",
        lines: "SATIR",
        next: "SONRAKİ",
        gameOver: "OYUN BİTTİ",
        newBest: "YENİ REKOR",
        playAgain: "TEKRAR OYNA",
        back: "GERİ",
        musicLabel: "🎵 Müzik",
        hapticsLabel: "📳 Titreşim",
        dayLabel: "☀️ Gündüz",
        nightLabel: "🌙 Gece",
        languageLabel: "🌐 Dil",
        turkishLabel: "Türkçe",
        englishLabel: "English",
        ghostLabel: "📍 İniş",
        volumeLabel: "🔊 Ses",
        playlistLabel: "🎼 Çalma listesi",
        modeFastName: "Çatlak",
        modeOgName: "Yırtık",
        modeHardName: "Parçalanma",
        modeFastSubtitle: "hızlı",
        modeOgSubtitle: "klasik",
        modeHardSubtitle: "zor",
        aboutLine1: "Tesseris — Yunanca, dört.",
        aboutLine2: "Riss — Almanca, bir yırtık.",
        aboutLine3: "Dizileri yırt — dört sıra birden.\nMüzik: Satie, Debussy, Ravel — kamu malı kayıtlar.",
        ultimateRiss: "ULTIMATE RISS",
        appearanceLabel: "☀️ Görünüm",
        themeStyleLabel: "🌊 Tema",
        themeClassic: "Klasik",
        themeHokusai: "Hokusai",
        greatWave: "MUHTEŞEM DALGA"
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
        score: "SCORE",
        level: "LEVEL",
        lines: "LINES",
        next: "NEXT",
        gameOver: "GAME OVER",
        newBest: "NEW BEST",
        playAgain: "PLAY AGAIN",
        back: "BACK",
        musicLabel: "🎵 Music",
        hapticsLabel: "📳 Haptics",
        dayLabel: "☀️ Day",
        nightLabel: "🌙 Night",
        languageLabel: "🌐 Language",
        turkishLabel: "Türkçe",
        englishLabel: "English",
        ghostLabel: "📍 Landing",
        volumeLabel: "🔊 Volume",
        playlistLabel: "🎼 Playlist",
        modeFastName: "Crack",
        modeOgName: "Tear",
        modeHardName: "Shatter",
        modeFastSubtitle: "fast",
        modeOgSubtitle: "og",
        modeHardSubtitle: "hard",
        aboutLine1: "Tesseris — Greek, four.",
        aboutLine2: "Riss — German, a tear.",
        aboutLine3: "Tear the rows — four at once.\nMusic: Satie, Debussy, Ravel — public-domain recordings.",
        ultimateRiss: "ULTIMATE RISS",
        appearanceLabel: "☀️ Appearance",
        themeStyleLabel: "🌊 Theme",
        themeClassic: "Classic",
        themeHokusai: "Hokusai",
        greatWave: "A GREAT WAVE"
    )

    static func current(for lang: Language) -> Strings {
        lang == .tr ? .tr : .en
    }
}
