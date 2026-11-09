# App Store listing — Tesseriss

Live metadata for **1.2.0**, mirrored from App Store Connect (ASO pass 2026-11-09). Seven locales.
Limits: name and subtitle ≤30 characters, keywords ≤100 **bytes** (ç ğ ı ö ş ü é = 2, Japanese = 3), promo ≤170.

> ⚠️ **Trademark note:** never use the word "Tetris" anywhere in the name, subtitle, keywords, or
> description. It's a registered trademark of The Tetris Company, which actively polices the store.

## ASO strategy (2026-11-09)

- Popularity: Apple Search Ads, per storefront (5 = no searches). Competition: median ratings of the top 10.
- **Head terms are out of reach.** "block puzzle" US 56 has a top-10 median of 396k ratings, and block blast/tetris are brands. We index them through name and subtitle but don't chase them.
- **Winnable terms go in the name:**
  - US `falling blocks` 26: top-10 median 194
  - JP `落ちものパズル` 25: top-10 median 22
  - US `block stack` 30: top-10 median ~0
- en-GB takes `block puzzle` (68 in GB) because `falling blocks` is dead there (5).
- **es-MX** also gets indexed by the US store, so its keyword field carries extra English words (brick, stack, cube, tile, wave).
- The game's UI is English/Turkish only. The fr/es/ja descriptions say so. There's very little text in the game.
- Apple combines words across name, subtitle and keywords. So keywords are single tokens with no repeats from name or subtitle, and no spaces.
- Raw popularity data: `docs/aso/popularity_2026-11-09.json`.

---

## English (US, primary) (en-US)

**Name** (25) — `Tesseriss: Falling Blocks`

**Subtitle** (30) — `Calm Offline Block Puzzle Game`

**Keywords** (100 bytes) — `games,brick,stack,retro,arcade,zen,brain,relaxing,wifi,no,ads,cozy,classic,tetra,mino,drop,tiles,row`

**Promotional text** (134)
> New in 1.2: a short guide, your stats in Settings, a color-blind mode and better VoiceOver. Still no ads, no accounts, fully offline.

**What's New**
```
Fixed: when the stack reaches the top, the game now ends and a new best score is saved. In 1.1 new pieces disappeared above the board instead, so a game never ended.

A short guide on first launch shows the controls, how rows clear and the three modes. You can open it again from Settings → How to play.

Settings now shows your stats: games played, rows cleared, four-row clears and best score per mode.

Colorblind mode, in Settings, switches to piece colors that stay apart with red-green color blindness, draws an outline around every piece and makes the landing preview easier to see.

Sound effects have their own switch and volume in Settings, separate from the music.

Your best score is saved even if you quit to the menu mid-game, and NEW BEST appears only when you beat your previous best.

VoiceOver reads every button and announces cleared rows, level changes and the end of a game. Menus and Settings adapt to larger text sizes.
```

**Description**
```
Tesseriss is a calm falling-blocks puzzle: a minimalist block game for focused, offline play. No ads, no accounts, no Wi-Fi needed.

The name says what you do: tesseris (Greek, "four") + Riss (German, "tear"). Tear the rows, four at a time.

Three modes, one tap apart:
– Crack (fast): a smaller board and a quicker fall, for short, sharp sessions.
– Tear (classic): the standard board at the standard pace.
– Shatter (hard): the same board, but five-square pieces sneak into the mix.

Classic-arcade feel: a 7-bag piece randomizer, fixed rotation tables, wall kicks, a ghost piece showing where the block will land, and a four-line clear worth 4000 points, with a satisfying flash and chime.

Made to be looked at: a soft, comforting palette with Day and Night appearances, plus an optional Hokusai "Great Wave" theme that colors the whole app.

A quiet soundtrack of Satie and Debussy, mostly solo piano. Music and sound effects each have their own switch and volume.

For everyone: a short guide on first launch, a color-blind mode with outlined pieces, full VoiceOver support and larger text sizes.

Yours, privately: high scores and stats are stored only on your device. No ads, no accounts, no tracking, and it works completely offline.

English and Turkish, switchable in Settings.
```

---

## English (UK) (en-GB)

**Name** (23) — `Tesseriss: Block Puzzle`

**Subtitle** (23) — `Calm Offline Brick Game`

**Keywords** (100 bytes) — `games,wifi,no,ads,falling,blocks,stack,retro,arcade,zen,brain,relaxing,cozy,classic,tiles,line,clear`

**Promotional text** (134)
> New in 1.2: a short guide, your stats in Settings, a colour-blind mode and better VoiceOver. Still no ads, no accounts, fully offline.

**What's New**
```
Fixed: when the stack reaches the top, the game now ends and a new best score is saved. In 1.1 new pieces disappeared above the board instead, so a game never ended.

A short guide on first launch shows the controls, how rows clear and the three modes. You can open it again from Settings → How to play.

Settings now shows your stats: games played, rows cleared, four-row clears and best score per mode.

Colorblind mode, in Settings, switches to piece colours that stay apart with red-green colour blindness, draws an outline around every piece and makes the landing preview easier to see.

Sound effects have their own switch and volume in Settings, separate from the music.

Your best score is saved even if you quit to the menu mid-game, and NEW BEST appears only when you beat your previous best.

VoiceOver reads every button and announces cleared rows, level changes and the end of a game. Menus and Settings adapt to larger text sizes.
```

**Description**
```
Tesseriss is a calm falling-blocks puzzle: a minimalist block game for focused, offline play. No ads, no accounts, no Wi-Fi needed.

The name says what you do: tesseris (Greek, "four") + Riss (German, "tear"). Tear the rows, four at a time.

Three modes, one tap apart:
– Crack (fast): a smaller board and a quicker fall, for short, sharp sessions.
– Tear (classic): the standard board at the standard pace.
– Shatter (hard): the same board, but five-square pieces sneak into the mix.

Classic-arcade feel: a 7-bag piece randomizer, fixed rotation tables, wall kicks, a ghost piece showing where the block will land, and a four-line clear worth 4000 points, with a satisfying flash and chime.

Made to be looked at: a soft, comforting palette with Day and Night appearances, plus an optional Hokusai "Great Wave" theme that colours the whole app.

A quiet soundtrack of Satie and Debussy, mostly solo piano. Music and sound effects each have their own switch and volume.

For everyone: a short guide on first launch, a colour-blind mode with outlined pieces, full VoiceOver support and larger text sizes.

Yours, privately: high scores and stats are stored only on your device. No ads, no accounts, no tracking, and it works completely offline.

English and Turkish, switchable in Settings.
```

---

## Turkish (tr)

**Name** (25) — `Tesseriss: Zen Blok Oyunu`

**Subtitle** (30) — `İnternetsiz Bulmaca, Reklamsız`

**Keywords** (98 bytes) — `oyunlar,block,puzzle,eğlenceli,arcade,retro,offline,zeka,kare,stres,klasik,oyun,tuğla,sakin,oyna`

**Promotional text** (137)
> 1.2'de yeni: kısa bir rehber, Ayarlar'da istatistikler, renk körlüğü modu ve daha iyi VoiceOver. Reklamsız, hesapsız, tamamen çevrimdışı.

**What's New**
```
Düzeltme: yığın tepeye ulaştığında oyun artık bitiyor ve yeni rekorun kaydediliyor. 1.1'de yeni parçalar tahtanın üstünde kayboluyordu, bu yüzden oyun hiç bitmiyordu.

İlk açılışta kısa bir rehber kontrolleri, sıraların nasıl yırtıldığını ve üç modu gösteriyor. Ayarlar'daki "Nasıl oynanır" ile tekrar açabilirsin.

Ayarlar'da artık istatistiklerin var: oynanan oyun, temizlenen sıra, dörtlü yırtma ve her modun rekoru.

Ayarlar'daki renk körlüğü modu, kırmızı-yeşil renk körlüğünde de birbirinden ayrılan parça renklerine geçiyor, her parçanın çevresine bir çizgi çiziyor ve parçanın ineceği yeri gösteren çerçeveyi belirginleştiriyor.

Ses efektlerinin Ayarlar'da müzikten ayrı, kendi aç/kapa düğmesi ve ses düzeyi var.

Oyunu yarıda bırakıp menüye dönsen bile kırdığın rekor kaydediliyor. YENİ REKOR yazısı da artık yalnızca önceki rekorunu geçtiğinde çıkıyor.

VoiceOver her düğmenin adını okuyor; temizlenen sıraları, seviye atlamayı ve oyunun bitişini bildiriyor. Menüler ve Ayarlar büyük yazı boyutlarına uyum sağlıyor.
```

**Description**
```
Tesseriss, sakin ve odaklanmış oyun için tasarlanmış minimalist bir düşen-blok bulmacası.

İsmi ne yapacağını söylüyor: tesseris (Yunanca "dört") + Riss (Almanca "yırtık") — sıraları dörder dörder yırt.

Üç mod, tek dokunuş uzakta:
– Çatlak (hızlı) — daha küçük tahta, daha hızlı düşüş; kısa ve keskin oyunlar için.
– Yırtık (klasik) — bildiğin tahta, bildiğin tempo.
– Parçalanma (zor) — klasik tahtaya beş kareli parçalar karışıyor.

Klasik arcade hissi: 7'li torba sistemi, sabit dönüş tabloları, parçanın nereye oturacağını gösteren gölge parça ve tek seferde dört sıra silmenin 4000 puanlık ödülü — parlamasıyla, çınlamasıyla.

Bakması da keyifli: Gündüz ve Gece görünümleriyle yumuşak, göz yormayan bir palet; dileyene Hokusai'nin "Büyük Dalga" teması.

Sessiz bir fon müziği: Satie ve Debussy, çoğunlukla piyanoda — dilediğinde aç, dilediğinde kapat.

Senin, sana özel: rekorlar ve istatistikler yalnızca cihazında saklanır. Reklam yok, hesap yok, takip yok; tamamen çevrimdışı çalışır.

Türkçe ve İngilizce — Ayarlar'dan tek dokunuşla.
```

---

## French (fr-FR)

**Name** (28) — `Tesseriss : Block Puzzle Zen`

**Subtitle** (26) — `Jeux sans wifi, hors ligne`

**Keywords** (99 bytes) — `jeu,bloc,blocks,logique,classique,arcade,rétro,cerveau,brique,grille,offline,pub,anti,stress,brain`

**Promotional text** (144)
> Nouveau en 1.2 : un petit guide, vos statistiques, un mode daltonien et un meilleur VoiceOver. Toujours sans pub, sans compte, 100 % hors ligne.

**What's New**
```
Corrigé : quand la pile atteint le haut, la partie se termine et votre meilleur score est enregistré.

Un petit guide au premier lancement montre les commandes, comment les lignes s'effacent et les trois modes. À retrouver dans Réglages.

Vos statistiques dans Réglages : parties jouées, lignes effacées, quadruples et meilleur score par mode.

Mode daltonien : des couleurs qui restent distinctes, un contour sur chaque pièce et une pièce fantôme plus visible.

Effets sonores avec interrupteur et volume séparés de la musique.

VoiceOver lit chaque bouton et annonce les lignes, les niveaux et la fin de partie. Les menus s'adaptent aux grandes tailles de texte.
```

**Description**
```
Tesseriss est un puzzle de blocs qui tombent, calme et minimaliste. Un jeu de blocs zen qui se joue hors ligne, sans wifi, sans pub et sans compte.

Complétez les lignes pour les effacer, idéalement quatre d'un coup : c'est ce que dit le nom, tesseris (« quatre » en grec) + Riss (« déchirure » en allemand).

Trois modes, à une touche d'écart :
– Crack (rapide) : un plateau plus petit et une chute plus rapide, pour des parties courtes.
– Tear (classique) : le plateau standard au rythme standard.
– Shatter (difficile) : le même plateau, mais des pièces de cinq carrés s'invitent.

L'esprit arcade classique : tirage des pièces par sac de 7, rotations fixes avec wall kicks, pièce fantôme qui montre où le bloc va tomber, et 4000 points pour quatre lignes d'un coup, avec éclat et carillon.

Une palette douce en version Jour et Nuit, et un thème « La Grande Vague » d'Hokusai qui habille toute l'app.

Une bande-son paisible de Satie et Debussy, surtout au piano. Musique et effets sonores réglables séparément.

Pour tous : un petit guide au premier lancement, un mode daltonien avec pièces contourées, VoiceOver et grandes tailles de texte.

Vos scores et statistiques restent sur votre appareil. Pas de pub, pas de compte, pas de suivi, et tout fonctionne hors ligne.

Langue du jeu : anglais (ou turc). Il y a très peu de texte : les règles se comprennent en jouant.
```

---

## Spanish (Spain) (es-ES)

**Name** (27) — `Tesseriss: Juego de Bloques`

**Subtitle** (28) — `Puzzle zen sin wifi, offline`

**Keywords** (100 bytes) — `juegos,rompecabezas,retro,arcade,gratis,internet,relajantes,anuncios,brick,piezas,mente,cerebro,mind`

**Promotional text** (137)
> Novedades 1.2: una guía corta, tus estadísticas, modo para daltónicos y mejor VoiceOver. Sigue sin anuncios, sin cuentas y 100 % offline.

**What's New**
```
Corregido: cuando la pila llega arriba, la partida termina y se guarda tu récord.

Una guía corta al empezar muestra los controles, cómo se borran las líneas y los tres modos. Puedes volver a verla en Ajustes.

Tus estadísticas en Ajustes: partidas, líneas borradas, cuádruples y récord por modo.

Modo para daltónicos: colores que se distinguen, contorno en cada pieza y una pieza fantasma más visible.

Efectos de sonido con interruptor y volumen propios, separados de la música.

VoiceOver lee cada botón y anuncia líneas, niveles y el final de la partida. Los menús se adaptan a textos grandes.
```

**Description**
```
Tesseriss es un juego de bloques que caen: un puzzle zen, minimalista y relajante para jugar sin internet. Sin wifi, sin anuncios y sin cuentas.

Completa líneas para borrarlas, mejor si son cuatro a la vez: eso dice el nombre, tesseris («cuatro» en griego) + Riss («desgarro» en alemán).

Tres modos, a un toque:
– Crack (rápido): un tablero más pequeño y una caída más rápida, para partidas cortas.
– Tear (clásico): el tablero estándar al ritmo estándar.
– Shatter (difícil): el mismo tablero, pero se cuelan piezas de cinco cuadros.

Sensación arcade clásica: piezas en bolsa de 7, rotaciones fijas con wall kicks, pieza fantasma que muestra dónde caerá el bloque y 4000 puntos por cuatro líneas a la vez, con destello y campanada.

Una paleta suave en modo Día y Noche, y un tema de «La gran ola» de Hokusai que viste toda la app.

Banda sonora tranquila de Satie y Debussy, casi todo piano. Música y efectos de sonido con volumen por separado.

Para todos: una guía corta al empezar, modo para daltónicos con piezas contorneadas, VoiceOver y textos grandes.

Tus récords y estadísticas se quedan en tu dispositivo. Sin anuncios, sin cuentas, sin rastreo y totalmente offline.

Idioma del juego: inglés (o turco). Tiene muy poco texto: las reglas se entienden jugando.
```

---

## Spanish (Mexico) (es-MX)

**Name** (27) — `Tesseriss: Juego de Bloques`

**Subtitle** (30) — `Puzzle sin internet, relajante`

**Keywords** (97 bytes) — `juegos,gratis,rompecabezas,cubos,cerebro,retro,arcade,wifi,zen,offline,brick,stack,cube,tile,wave`

**Promotional text** (137)
> Novedades 1.2: una guía corta, tus estadísticas, modo para daltónicos y mejor VoiceOver. Sigue sin anuncios, sin cuentas y 100 % offline.

**What's New**
```
Corregido: cuando la pila llega arriba, la partida termina y se guarda tu récord.

Una guía corta al empezar muestra los controles, cómo se borran las líneas y los tres modos. Puedes volver a verla en Ajustes.

Tus estadísticas en Ajustes: partidas, líneas borradas, cuádruples y récord por modo.

Modo para daltónicos: colores que se distinguen, contorno en cada pieza y una pieza fantasma más visible.

Efectos de sonido con interruptor y volumen propios, separados de la música.

VoiceOver lee cada botón y anuncia líneas, niveles y el final de la partida. Los menús se adaptan a textos grandes.
```

**Description**
```
Tesseriss es un juego de bloques que caen: un puzzle zen, minimalista y relajante para jugar sin internet. Sin wifi, sin anuncios y sin cuentas.

Completa líneas para borrarlas, mejor si son cuatro a la vez: eso dice el nombre, tesseris («cuatro» en griego) + Riss («desgarro» en alemán).

Tres modos, a un toque:
– Crack (rápido): un tablero más pequeño y una caída más rápida, para partidas cortas.
– Tear (clásico): el tablero estándar al ritmo estándar.
– Shatter (difícil): el mismo tablero, pero se cuelan piezas de cinco cuadros.

Sensación arcade clásica: piezas en bolsa de 7, rotaciones fijas con wall kicks, pieza fantasma que muestra dónde caerá el bloque y 4000 puntos por cuatro líneas a la vez, con destello y campanada.

Una paleta suave en modo Día y Noche, y un tema de «La gran ola» de Hokusai que viste toda la app.

Banda sonora tranquila de Satie y Debussy, casi todo piano. Música y efectos de sonido con volumen por separado.

Para todos: una guía corta al empezar, modo para daltónicos con piezas contorneadas, VoiceOver y textos grandes.

Tus récords y estadísticas se quedan en tu dispositivo. Sin anuncios, sin cuentas, sin rastreo y totalmente offline.

Idioma del juego: inglés (o turco). Tiene muy poco texto: las reglas se entienden jugando.
```

---

## Japanese (ja)

**Name** (18) — `Tesseriss: 落ちものパズル`

**Subtitle** (14) — `和風の癒しゲーム・オフライン`

**Keywords** (100 bytes) — `ブロックパズル,脳トレ,暇つぶし,落ちゲー,広告なし,シンプル,レトロ,集中`

**Promotional text** (64)
> バージョン1.2：初回ガイド、記録画面、色覚サポートモード、VoiceOverの改善。広告なし・アカウント不要・完全オフライン。

**What's New**
```
修正：ブロックが上まで積み上がるとゲームが終了し、ベストスコアが保存されるようになりました。

初回ガイドで操作、ラインの消し方、3つのモードを紹介。設定からいつでも見直せます。

設定で記録を確認：プレイ回数、消したライン数、4列消しの回数、モードごとのベストスコア。

色覚サポートモード：見分けやすい色、ピースの輪郭、見やすいゴースト。

効果音は音楽とは別にオン/オフと音量を調整できます。

VoiceOverがボタンを読み上げ、ライン消し・レベルアップ・ゲーム終了をお知らせ。大きな文字にも対応。
```

**Description**
```
Tesseriss（テセリス）は、静かに遊べるミニマルな落ちものパズルです。オフラインで遊べて、広告なし・アカウント不要。

ブロックを並べて横一列をそろえると消えます。4列同時に消すのが目標。名前の由来はギリシャ語の tesseris（4）とドイツ語の Riss（裂け目）です。

3つのモード：
– Crack（速い）：小さめの盤面と速い落下で、短く集中して。
– Tear（クラシック）：標準の盤面と標準のスピード。
– Shatter（難しい）：同じ盤面に5マスのピースが混ざります。

クラシックなアーケードの手触り：7種バッグ方式、固定回転と壁蹴り、着地点を示すゴースト、4列消しで4000点。光とチャイムで気持ちよく。

やさしい色合いの昼・夜テーマに加え、葛飾北斎「神奈川沖浪裏」をモチーフにした和風テーマでアプリ全体を彩れます。

BGMはサティとドビュッシーのピアノ曲。音楽と効果音はそれぞれ音量を調整できます。

初回ガイド、色覚サポートモード（輪郭付きピース）、VoiceOver、大きな文字にも対応。

スコアと記録は端末内だけに保存。広告なし、アカウントなし、トラッキングなし、完全オフライン。

ゲーム内の言語は英語（またはトルコ語）です。文字はほとんどなく、遊べばすぐわかります。
```

---

**Support URL** — `https://w00dsrules.github.io/Tesseriss/support.html`
**Marketing URL** — `https://w00dsrules.github.io/Tesseriss/`
**Privacy Policy URL** — `https://w00dsrules.github.io/Tesseriss/privacy.html`
**Copyright** — `2026 Vibalyze OÜ`
**Category** — Games → Puzzle, Casual

## App Privacy (nutrition label) answers
- **Data collection:** select **"Data Not Collected."** (Highscore lives in local `UserDefaults`; no
  analytics, no network calls. Matches `PrivacyInfo.xcprivacy`.)

## Age rating
- Expected **4+** — no objectionable content, no web, no user-generated content, no gambling.

## Export compliance
- Already declared in-binary: `ITSAppUsesNonExemptEncryption = false` → no per-build prompt.
