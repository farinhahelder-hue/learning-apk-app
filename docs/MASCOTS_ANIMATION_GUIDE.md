# 🎭 Guide : Animer les mascottes avec Rive

## Pourquoi Rive ?

| Critère | Lottie | Rive |
|---|---|---|  
| Animations interactives | ❌ | ✅ |
| State machine (idle/happy/wrong...) | ❌ | ✅ |
| Taille fichier (mascotte complète) | ~500KB | ~50-100KB |
| Contrôle depuis Flutter | Limité | Total |
| Éditeur gratuit | Non | Oui (rive.app) |
| Export APK Android | ✅ | ✅ |

**Conclusion : Rive est la solution idéale** pour des mascottes qui réagissent aux réponses.

---

## 🛠 Étape 1 : Créer les animations sur Rive.app

1. Va sur **[rive.app](https://rive.app)** (gratuit)
2. Crée un nouveau fichier
3. Dessine ta mascotte (ou importe un SVG/PNG)
4. Crée les animations suivantes :

### Animations à créer pour chaque mascotte :

| Nom dans Rive | Déclencheur | Description |
|---|---|---|
| `idle` | Par défaut | Respiration douce, clignement des yeux |
| `success` | Trigger | Saute de joie, étoiles autour |
| `error` | Trigger | Secousse, expression dépite (Monika = rouge + tremblement) |
| `celebrate` | Trigger | Danse, confettis, explosion |
| `thinking` | Bool ON/OFF | Balancement, tête penchée |
| `sleepy` | Bool ON/OFF | Yeux qui se ferment, bâillement |

### State Machine à créer :
- **Nom obligatoire** : `MascotMachine`
- Inputs exposés :
  - `success` (Trigger)
  - `error` (Trigger)
  - `celebrate` (Trigger)
  - `thinking` (Bool)
  - `sleepy` (Bool)

---

## 💾 Étape 2 : Exporter les fichiers .riv

1. Dans Rive : **File → Export → For Runtime**
2. Nommer les fichiers selon l'ID des mascottes :

```
assets/
  rive/
    papa_seal.riv
    baby_seal.riv
    monika_jellyfish.riv
    night_squirrel.riv
    ainy_crab.riv
    barbenoire_cat.riv
    ninon_dolphin.riv
    billy_bird.riv      🐦 nouveau !
```

---

## 📦 Étape 3 : Ajouter dans pubspec.yaml

```yaml
flutter:
  assets:
    - assets/rive/papa_seal.riv
    - assets/rive/baby_seal.riv
    - assets/rive/monika_jellyfish.riv
    - assets/rive/night_squirrel.riv
    - assets/rive/ainy_crab.riv
    - assets/rive/barbenoire_cat.riv
    - assets/rive/ninon_dolphin.riv
    - assets/rive/billy_bird.riv
```

---

## 🐦 Animation spéciale Billy (tête qui penche)

Dans Rive, pour Billy :
- Animation `idle` : rotation de la tête de -15° à +15° en boucle (2s)
- Animation `thinking` : tête penchée à gauche, yeux qui cherchent
- Animation `success` : Billy sautille + ailes qui battent

---

## 😴 Animation spéciale Monika (pipipipi)

Dans Rive, pour Monika :
- Animation `error` : corps qui tremble rapidement (8Hz)
- Couleur du corps : teinte rouge progressive
- Expression du visage : sourcils frondés, bouche "O"
- Son associé : déclencher `sounds/pipipipi.wav` depuis Flutter au moment du trigger

---

## 📱 Utilisation dans le code Flutter

```dart
// Remplacer MascotWidget par RiveMascotWidget
// Le widget bascule automatiquement en fallback émoji si .riv absent

RiveMascotWidget(
  mascot: Mascots.monikaJellyfish,
  mood: MascotMood.wrong,     // déclenche le trigger 'error' dans Rive
  size: 120,
  showSpeechBubble: true,
  speechText: 'Pipipipi ! 🪼',
)
```

---

## 🌐 Ressources utiles

- Éditeur Rive : https://rive.app
- Package Flutter : https://pub.dev/packages/rive
- Tutoriel mascottes Duolingo-style : https://dev.to/uianimation/building-high-performance-interactive-mascots-in-flutter-with-rive-production-guide-for-2026-17c6
- Exemples de state machines : https://rive.app/community

---

## 💡 Conseil : Rive Community

Sur **[rive.app/community](https://rive.app/community)** tu peux trouver des mascottes animées gratuites à adapter (oiseaux, animaux marins, personnages) pour gagner du temps !
