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
                .accessibilityIdentifier("back-button")
                Spacer()
            }
            .padding(.horizontal, 16)

            Text(s.settings)
                .font(.system(.title, design: .rounded).weight(.semibold))
                .foregroundStyle(Color("PaletteInk"))

            VStack(spacing: 16) {
                Toggle(s.musicLabel, isOn: $settings.musicEnabled)
                    .toggleStyle(.switch)
                HStack(spacing: 12) {
                    Text(s.volumeLabel)
                    Slider(value: $settings.musicVolume, in: 0...1)
                        .tint(Color("PaletteInk"))
                        .onChange(of: settings.musicVolume) { _, _ in
                            engine.audio.applyVolume()
                        }
                }
                .disabled(!settings.musicEnabled)
                .opacity(settings.musicEnabled ? 1.0 : 0.4)
                HStack {
                    Text(s.playlistLabel)
                    Spacer()
                    Picker(s.playlistLabel, selection: $settings.playlistID) {
                        ForEach(MusicPlaylist.all) { playlist in
                            Text(playlist.displayName(settings.language)).tag(playlist.id)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(Color("PaletteInk"))
                }
                Toggle(s.hapticsLabel, isOn: $settings.hapticsEnabled)
                    .toggleStyle(.switch)
                Toggle(s.ghostLabel, isOn: $settings.ghostEnabled)
                    .toggleStyle(.switch)
                HStack {
                    Text(s.appearanceLabel)
                    Spacer()
                    Picker(s.appearanceLabel, selection: $settings.appearance) {
                        Text(s.dayLabel).tag(AppearanceMode.day)
                        Text(s.nightLabel).tag(AppearanceMode.night)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 200)
                    .accessibilityIdentifier("appearance-picker")
                }
                HStack {
                    Text(s.themeStyleLabel)
                    Spacer()
                    Picker(s.themeStyleLabel, selection: $settings.themeKind) {
                        Text(s.themeClassic).tag(ThemeKind.classic)
                        Text(s.themeHokusai).tag(ThemeKind.kanagawa)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 220)
                    .accessibilityIdentifier("theme-picker")
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
