import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var engine: GameEngine
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var s: Strings { settings.strings }
    private var theme: Theme { settings.activeTheme }
    private var appearance: AppearanceMode { settings.appearance }
    private var ink: Color { theme.inkColor(appearance: appearance) }
    private var card: Color { theme.cardColor(appearance: appearance) }
    private var stroke: Color { theme.strokeColor(appearance: appearance) }

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
                        // Keep the capsule look, but meet the 44pt touch minimum.
                        .frame(minHeight: 44)
                        .contentShape(Rectangle())
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

                VStack(spacing: 24) {
                Text(s.settings)
                    .font(.system(.title, design: .rounded).weight(.semibold))
                    .foregroundStyle(ink)

                VStack(spacing: 16) {
                    withEmoji("🎵") { Toggle(s.musicLabel, isOn: $settings.musicEnabled) }
                        .toggleStyle(.switch)
                        .onChange(of: settings.musicEnabled) { _, enabled in
                            // Take effect immediately — don't wait for the next game.
                            if enabled {
                                engine.audio.ensureMusicPlaying()
                            } else {
                                engine.audio.pauseMusic()
                            }
                        }
                    row(spacing: 12) {
                        // Both rows show "Volume"; the slider carries the spoken label.
                        Text("🔊 " + s.volumeLabel)
                            .accessibilityHidden(true)
                        Slider(value: $settings.musicVolume, in: 0...1)
                            .tint(ink)
                            .accessibilityLabel(s.musicVolumeLabel)
                            .accessibilityIdentifier("music-volume-slider")
                            .onChange(of: settings.musicVolume) { _, _ in
                                engine.audio.applyVolume()
                            }
                    }
                    .disabled(!settings.musicEnabled)
                    .opacity(settings.musicEnabled ? 1.0 : 0.4)
                    withEmoji("🔔") { Toggle(s.sfxLabel, isOn: $settings.sfxEnabled) }
                        .toggleStyle(.switch)
                    row(spacing: 12) {
                        Text("🔊 " + s.volumeLabel)
                            .accessibilityHidden(true)
                        Slider(value: $settings.sfxVolume, in: 0...1, onEditingChanged: { editing in
                            // Play a line clear on release so the player hears the new level.
                            if !editing { engine.audio.playLineClear(enabled: settings.sfxEnabled) }
                        })
                        .tint(ink)
                        .accessibilityLabel(s.sfxVolumeLabel)
                        .accessibilityIdentifier("sfx-volume-slider")
                        .onChange(of: settings.sfxVolume) { _, _ in
                            engine.audio.applyVolume()
                        }
                    }
                    .disabled(!settings.sfxEnabled)
                    .opacity(settings.sfxEnabled ? 1.0 : 0.4)
                    // A one-option picker is dead UI — only show it once there's a choice.
                    if MusicPlaylist.all.count > 1 {
                        row {
                            withEmoji("🎼") { Text(s.playlistLabel) }
                            if !stacked { Spacer() }
                            Picker(s.playlistLabel, selection: $settings.playlistID) {
                                ForEach(MusicPlaylist.all) { playlist in
                                    Text(playlist.displayName(settings.language)).tag(playlist.id)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(ink)
                        }
                    }
                    withEmoji("📳") { Toggle(s.hapticsLabel, isOn: $settings.hapticsEnabled) }
                        .toggleStyle(.switch)
                    withEmoji("📍") { Toggle(s.ghostLabel, isOn: $settings.ghostEnabled) }
                        .toggleStyle(.switch)
                    row {
                        withEmoji("☀️") { Text(s.appearanceLabel) }
                        if !stacked { Spacer() }
                        Picker(s.appearanceLabel, selection: $settings.appearance) {
                            Text("☀️ " + s.dayLabel).accessibilityLabel(s.dayLabel).tag(AppearanceMode.day)
                            Text("🌙 " + s.nightLabel).accessibilityLabel(s.nightLabel).tag(AppearanceMode.night)
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: stacked ? .infinity : 200)
                        .accessibilityIdentifier("appearance-picker")
                    }
                    row {
                        withEmoji("🌊") { Text(s.themeStyleLabel) }
                        if !stacked { Spacer() }
                        Picker(s.themeStyleLabel, selection: $settings.themeKind) {
                            Text(s.themeClassic).tag(ThemeKind.classic)
                            Text(s.themeHokusai).tag(ThemeKind.kanagawa)
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: stacked ? .infinity : 220)
                        .accessibilityIdentifier("theme-picker")
                    }
                    row {
                        withEmoji("🌐") { Text(s.languageLabel) }
                        if !stacked { Spacer() }
                        Picker(s.languageLabel, selection: $settings.language) {
                            Text(s.turkishLabel).tag(Language.tr)
                            Text(s.englishLabel).tag(Language.en)
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: stacked ? .infinity : 200)
                    }
                }
                .font(.system(.title3, design: .rounded))
                .foregroundStyle(ink)
                .tint(ink)
                }
                // Over the Hokusai art, title and controls share one panel. The
                // smaller outer inset plus the panel's own padding keeps the controls
                // as wide as in Classic.
                .legibilityPanel(theme.backgroundIsArtwork, stroke: stroke, fill: card)
                .padding(.horizontal, theme.backgroundIsArtwork ? 16 : 32)

                Spacer(minLength: 16)

                VStack(spacing: 6) {
                    Text(s.aboutLine1)
                    Text(s.aboutLine2)
                    Text(s.aboutLine3)
                }
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(ink.opacity(0.75))
                .multilineTextAlignment(.center)
                .legibilityPanel(theme.backgroundIsArtwork, stroke: stroke, fill: card)
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .frame(maxWidth: .infinity, minHeight: 0)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }

    /// The emoji is decoration, in its own hidden text beside the label or
    /// control: VoiceOver reads the plain label, and the text-clipping audit
    /// doesn't measure the emoji glyph, which overhangs its text frame. It sits
    /// outside the Toggle because a Toggle exposes hidden texts in its label.
    /// At accessibility sizes it goes on its own line, so a long word
    /// ("Appearance") keeps the full width instead of breaking mid-word.
    private func withEmoji<Content: View>(_ emoji: String,
                                          @ViewBuilder _ content: () -> Content) -> some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 0))
            : AnyLayout(HStackLayout(spacing: 0))
        return layout {
            Text(emoji + " ").accessibilityHidden(true)
            content()
        }
    }

    /// From xLarge up a label and its picker don't fit on one line ("Appearance"
    /// would truncate), so the label goes above a full-width control.
    private var stacked: Bool { dynamicTypeSize >= .xLarge }

    private func row<Content: View>(spacing: CGFloat? = nil,
                                    @ViewBuilder _ content: () -> Content) -> some View {
        let layout = stacked
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(spacing: spacing))
        return layout(content)
    }
}
