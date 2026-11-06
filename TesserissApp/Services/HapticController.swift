import UIKit

final class HapticController {
    static let shared = HapticController()

    private let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let notify = UINotificationFeedbackGenerator()

    init() {
        softImpact.prepare()
        lightImpact.prepare()
        mediumImpact.prepare()
        notify.prepare()
    }

    /// Gentler than `light` — used for the wall-kick assist, so the help is felt
    /// as a nudge rather than mistaken for an ordinary rotation.
    func soft(enabled: Bool) {
        guard enabled else { return }
        softImpact.impactOccurred()
        softImpact.prepare()
    }

    func light(enabled: Bool) {
        guard enabled else { return }
        lightImpact.impactOccurred()
        lightImpact.prepare()
    }

    func medium(enabled: Bool) {
        guard enabled else { return }
        mediumImpact.impactOccurred()
        mediumImpact.prepare()
    }

    func success(enabled: Bool) {
        guard enabled else { return }
        notify.notificationOccurred(.success)
        notify.prepare()
    }

    func gameOver(enabled: Bool) {
        guard enabled else { return }
        notify.notificationOccurred(.error)
        notify.prepare()
    }
}
