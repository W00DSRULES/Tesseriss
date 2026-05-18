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
        tracks: [
            "01_satie_gymnopedie_1",
            "02_satie_gymnopedie_3",
            "03_satie_gnossienne_1",
            "04_satie_gnossienne_3",
            "05_debussy_clair_de_lune",
            "06_debussy_reverie",
            "07_debussy_arabesque_1",
            "08_ravel_pavane",
        ]
    )

    static let all: [MusicPlaylist] = [.impressionists]

    static func playlist(forID id: String) -> MusicPlaylist {
        all.first(where: { $0.id == id }) ?? impressionists
    }
}
