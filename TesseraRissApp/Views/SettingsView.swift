import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var engine: GameEngine
    @EnvironmentObject var settings: SettingsStore

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Button(action: { engine.closeSettings() }) {
                    Text("BACK")
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(Color("PaletteInk").opacity(0.7))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color("PaletteGrid"))
                        .clipShape(Capsule())
                }
                Spacer()
            }
            .padding(.horizontal, 16)

            Text("SETTINGS")
                .font(.system(.title, design: .rounded).weight(.semibold))
                .foregroundStyle(Color("PaletteInk"))

            VStack(spacing: 16) {
                Toggle("Music", isOn: $settings.musicEnabled)
                    .toggleStyle(.switch)
                Toggle("Haptics", isOn: $settings.hapticsEnabled)
                    .toggleStyle(.switch)
            }
            .font(.system(.title3, design: .rounded))
            .foregroundStyle(Color("PaletteInk"))
            .padding(.horizontal, 32)

            Spacer()

            VStack(spacing: 6) {
                Text("Tessera — Latin, a four-sided tile.")
                Text("Riss — German, a tear.")
                Text("Tear the tiles, four rows at a time.")
            }
            .font(.system(.footnote, design: .rounded))
            .foregroundStyle(Color("PaletteInk").opacity(0.6))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
    }
}
