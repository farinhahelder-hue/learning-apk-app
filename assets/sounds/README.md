# 🎵 Fichiers Audio – Emilie App

## Effets sonores requis (`assets/sounds/`)

| Fichier | Déclencheur | Description |
|---|---|---|
| `correct.mp3` | Bonne réponse | Son court et joyeux (~0.5s) – ex: "ding" lumineux |
| `wrong.mp3` | Mauvaise réponse | Son doux et non-punitif (~0.5s) – ex: "boing" |
| `combo.mp3` | Combo x3+ | Son puissant et entraînant (~1s) – ex: fanfare courte |
| `level_up.mp3` | Montée de niveau | Jingle festif (~2s) |
| `star.mp3` | Étoile gagnée | Son de clochette/magie (~1s) |
| `tap.mp3` | Clic bouton | Son très court (~0.2s) – tap discret |
| `challenge_done.mp3` | Défi du jour fini | Fanfare courte (~2s) |
| `unlock.mp3` | Avatar débloqué | Son mystérieux/magique (~1.5s) |
| `countdown.mp3` | Dernières 10s | Bip discret (~0.3s) |
| `perfect.mp3` | Score 100% | Jingle triomphal (~3s) |

## Musiques de fond requises (`assets/sounds/music/`)

| Fichier | Écran | Style | Durée recommandée |
|---|---|---|---|
| `music_home.mp3` | Accueil | Douce, joyeuse, calme | 1-2 min (loop) |
| `music_math.mp3` | Maths | Rythmée, dynamique | 1-2 min (loop) |
| `music_french.mp3` | Français | Mélodique, apaisante | 1-2 min (loop) |
| `music_science.mp3` | Sciences | Curieuse, aventureuse | 1-2 min (loop) |
| `music_results.mp3` | Résultats | Festive, victoire | 30s (loop) |
| `music_challenge.mp3` | Défi du jour | Épique, motivante | 1 min (loop) |

## Sources gratuites recommandées

### 🔊 Effets sonores libres de droits
- **Freesound.org** – https://freesound.org (CC0 / CC-BY)
- **Mixkit** – https://mixkit.co/free-sound-effects/ (licence gratuite)
- **Pixabay Sounds** – https://pixabay.com/sound-effects/ (CC0)
- **ZapSplat** – https://www.zapsplat.com (gratuit avec compte)

### 🎶 Musiques libres de droits
- **Uppbeat** – https://uppbeat.io (gratuit avec attribution)
- **Pixabay Music** – https://pixabay.com/music/ (CC0)
- **Free Music Archive** – https://freemusicarchive.org
- **OpenGameArt** – https://opengameart.org (spécialisé jeux)

### 🤖 Générateur IA gratuit
- **Suno AI** – https://suno.com – génère des musiques courtes sur description
  - Prompt suggéré : *"happy cheerful children educational background music loop, no lyrics, 90 BPM"*
- **Udio** – https://www.udio.com – pareil

## Installation

```
assets/
  sounds/
    correct.mp3
    wrong.mp3
    combo.mp3
    level_up.mp3
    star.mp3
    tap.mp3
    challenge_done.mp3
    unlock.mp3
    countdown.mp3
    perfect.mp3
    music/
      music_home.mp3
      music_math.mp3
      music_french.mp3
      music_science.mp3
      music_results.mp3
      music_challenge.mp3
```

Puis dans `pubspec.yaml`, assure-toi d'avoir :
```yaml
flutter:
  assets:
    - assets/sounds/
    - assets/sounds/music/
```
