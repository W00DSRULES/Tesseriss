import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var engine: GameEngine
    @EnvironmentObject var settings: SettingsStore

    private var s: Strings { settings.strings }

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Button(action: { engine.closeSettings() }) {
                    Text(s.back)
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(Color("PaletteInk").opacity(0.7))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color("PaletteCard"))
                        .clipShape(Capsule())
                }
                Spacer()
            }
            .padding(.horizontal, 16)

            Text(s.settings)
                .font(.system(.title, design: .rounded).weight(.semibold))
                .foregroundStyle(Color("PaletteInk"))

            VStack(spacing: 16) {
                Toggle(s.musicLabel, isOn: $settings.musicEnabled)
                    .toggleStyle(.switch)
                Toggle(s.hapticsLabel, isOn: $settings.hapticsEnabled)
                    .toggleStyle(.switch)
                HStack {
                    Text(s.themeLabel)
                    Spacer()
                    Picker(s.themeLabel, selection: $settings.appearance) {
                        Text(s.dayLabel).tag(AppearanceMode.day)
                        Text(s.nightLabel).tag(AppearanceMode.night)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 200)
                }
                HStack {
                    Text(s.languageLabel)
                    Spacer()
                    Picker(s.languageLabel, selection: $settings.language) {
                        Text(s.turkishLabel).tag(Language.tr)
                        Text(s.englishLabel).tag(Language.en)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 200)
                }
            }
            .font(.system(.title3, design: .rounded))
            .foregroundStyle(Color("PaletteInk"))
            .padding(.horizontal, 32)

            Spacer()

            VStack(spacing: 6) {
                Text(s.aboutLine1)
                Text(s.aboutLine2)
                Text(s.aboutLine3)
            }
            .font(.system(.footnote, design: .rounded))
            .foregroundStyle(Color("PaletteInk").opacity(0.6))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
    }
}
