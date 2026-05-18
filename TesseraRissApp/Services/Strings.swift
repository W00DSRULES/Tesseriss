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
    let themeLabel: String
    let dayLabel: String
    let nightLabel: String
    let languageLabel: String
    let turkishLabel: String
    let englishLabel: String
    let ghostLabel: String
    let volumeLabel: String
    let playlistLabel: String
    let aboutLine1: String
    let aboutLine2: String
    let aboutLine3: String

    static let tr = Strings(
        tagline: "Düşür, doldur, kır.",
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
        themeLabel: "🎨 Tema",
        dayLabel: "☀️ Gündüz",
        nightLabel: "🌙 Gece",
        languageLabel: "🌐 Dil",
        turkishLabel: "Türkçe",
        englishLabel: "English",
        ghostLabel: "👻 Gölge",
        volumeLabel: "🔊 Ses",
        playlistLabel: "🎼 Çalma listesi",
        aboutLine1: "Tessera — Latince, mozaik taşı.",
        aboutLine2: "Riss — Almanca, bir çatlak.",
        aboutLine3: "Düşür, doldur, kır — dört sıra birden.\nMüzik: Satie, Debussy, Ravel — kamu malı kayıtlar."
    )

    static let en = Strings(
        tagline: "drop. fill. break.",
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
        themeLabel: "🎨 Theme",
        dayLabel: "☀️ Day",
        nightLabel: "🌙 Night",
        languageLabel: "🌐 Language",
        turkishLabel: "Türkçe",
        englishLabel: "English",
        ghostLabel: "👻 Shadow",
        volumeLabel: "🔊 Volume",
        playlistLabel: "🎼 Playlist",
        aboutLine1: "Tessera — Latin, a tile from a mosaic.",
        aboutLine2: "Riss — German, a crack.",
        aboutLine3: "Drop. Fill. Break — four rows at once.\nMusic: Satie, Debussy, Ravel — public-domain recordings."
    )

    static func current(for lang: Language) -> Strings {
        lang == .tr ? .tr : .en
    }
}
