import Foundation

struct MusicPlaylist: Identifiable, Equatable {
    let id: String
    let nameEN: String
    let nameTR: String
    let tracks: [String]

    func displayName(_ language: Language) -> String {
        language == .tr ? nameTR : nameEN
    }
}

extension MusicPlaylist {
    static let impressionists = MusicPlaylist(
        id: "impressionists",
        nameEN: "Impressionists",
        nameTR: "İzlenimciler",
        // All tracks are Public Domain / CC0 (zero attribution). Timbres alternate
        // (piano / harp / brass) and the two Gymnopédie 1s + two Clair de Lunes are
        // spread out. See README "Audio" for sources; files are not committed.
        tracks: [
            "01_satie_gymnopedie_1",        // Gymnopédie No. 1, piano (Robin Alciatore, PD)
            "02_satie_gnossienne_3",        // Gnossienne No. 3, piano (GregorQuendel, Pixabay)
            "03_debussy_clair_de_lune",     // Clair de Lune, piano (1905 solo, PD Mark)
            "04_satie_gymnopedie_1_harp",   // Gymnopédie No. 1, harp (Anonymous, PD Mark)
            "05_debussy_reverie",           // Rêverie, piano (Anonymous, PD Mark)
            "06_satie_gymnopedie_3",        // Gymnopédie No. 3, piano (Teknopazzo, CC0)
            "07_debussy_clair_de_lune_brass", // Clair de Lune, brass (USAF Band of Flight, PD)
        ]
    )

    static let all: [MusicPlaylist] = [.impressionists]

    static func playlist(forID id: String) -> MusicPlaylist {
        all.first(where: { $0.id == id }) ?? impressionists
    }
}
