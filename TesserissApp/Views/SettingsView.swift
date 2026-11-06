import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var engine: GameEngine
    @EnvironmentObject var settings: SettingsStore

    private var s: Strings { settings.strings }
    private var theme: Theme { settings.activeTheme }
    private var appearance: AppearanceMode { settings.appearance }
    private var ink: Color { theme.inkColor(appearance: appearance) }
    private var card: Color { theme.cardColor(appearance: appearance) }

    var body: some View {
        VStack(spacing: 0) {
            // Pinned outside the ScrollView: on a small screen the settings list is
            // taller than the viewport, and a Back button that scrolls away strands
            // the player.
            HStack {
                Button(action: { engine.closeSettings() }) {
                    Text(s.back)
                        .font(.system(.body, design: .rounded).weight(.semibold))
                        .foregroundStyle(ink.opacity(0.8))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 18)
                        .background(card)
                        .clipShape(Capsule())
                }
                .accessibilityIdentifier("back-button")
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            ScrollView {
            VStack(spacing: 24) {
                // Push the title + controls block toward the middle of the screen
                // (the content doesn't fill the height, so this reads less top-heavy).
                Spacer(minLength: 16)

                Text(s.settings)
                    .font(.system(.title, design: .rounded).weight(.semibold))
                    .foregroundStyle(ink)

                VStack(spacing: 16) {
                    // The emoji are decoration: VoiceOver reads the plain label.
                    Toggle("🎵 " + s.musicLabel, isOn: $settings.musicEnabled)
                        .toggleStyle(.switch)
                        .accessibilityLabel(s.musicLabel)
                        .onChange(of: settings.musicEnabled) { _, enabled in
                            // Take effect immediately — don't wait for the next game.
                            if enabled {
                                engine.audio.ensureMusicPlaying()
                            } else {
                                engine.audio.pauseMusic()
                            }
                        }
                    Toggle("🔔 " + s.sfxLabel, isOn: $settings.sfxEnabled)
                        .toggleStyle(.switch)
                        .accessibilityLabel(s.sfxLabel)
                    HStack(spacing: 12) {
                        Text("🔊 " + s.volumeLabel)
                            .accessibilityLabel(s.volumeLabel)
                        Slider(value: $settings.musicVolume, in: 0...1)
                            .tint(ink)
                            .onChange(of: settings.musicVolume) { _, _ in
                                engine.audio.applyVolume()
                            }
                    }
                    // One slider sets the volume of both music and sound effects.
                    .disabled(!settings.musicEnabled && !settings.sfxEnabled)
                    .opacity(settings.musicEnabled || settings.sfxEnabled ? 1.0 : 0.4)
                    // A one-option picker is dead UI — only show it once there's a choice.
                    if MusicPlaylist.all.count > 1 {
                        HStack {
                            Text("🎼 " + s.playlistLabel)
                                .accessibilityLabel(s.playlistLabel)
                            Spacer()
                            Picker(s.playlistLabel, selection: $settings.playlistID) {
                                ForEach(MusicPlaylist.all) { playlist in
                                    Text(playlist.displayName(settings.language)).tag(playlist.id)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(ink)
                        }
                    }
                    Toggle("📳 " + s.hapticsLabel, isOn: $settings.hapticsEnabled)
                        .toggleStyle(.switch)
                        .accessibilityLabel(s.hapticsLabel)
                    Toggle("📍 " + s.ghostLabel, isOn: $settings.ghostEnabled)
                        .toggleStyle(.switch)
                        .accessibilityLabel(s.ghostLabel)
                    HStack {
                        Text("☀️ " + s.appearanceLabel)
                            .accessibilityLabel(s.appearanceLabel)
                        Spacer()
                        Picker(s.appearanceLabel, selection: $settings.appearance) {
                            Text("☀️ " + s.dayLabel).accessibilityLabel(s.dayLabel).tag(AppearanceMode.day)
                            Text("🌙 " + s.nightLabel).accessibilityLabel(s.nightLabel).tag(AppearanceMode.night)
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: 200)
                        .accessibilityIdentifier("appearance-picker")
                    }
                    HStack {
                        Text("🌊 " + s.themeStyleLabel)
                            .accessibilityLabel(s.themeStyleLabel)
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
                        Text("🌐 " + s.languageLabel)
                            .accessibilityLabel(s.languageLabel)
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
                .foregroundStyle(ink)
                .tint(ink)
                .padding(.horizontal, 32)

                Spacer(minLength: 16)

                VStack(spacing: 6) {
                    Text(s.aboutLine1)
                    Text(s.aboutLine2)
                    Text(s.aboutLine3)
                }
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(ink.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .frame(maxWidth: .infinity, minHeight: 0)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
    }
}
