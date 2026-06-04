# Emilie App 🏠

Application éducative gamifiée pour Emilie (CE1/CE2) - Mathematics, Français et Sciences.

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.x-orange)
![Dart](https://img.shields.io/badge/Dart-3.x-blue)

## 🎯 Fonctionnalités

### 📚 Contenu Pédagogique CE1/CE2
- **Mathématiques** : Additions, soustractions, multiplications, divisions, géométrie, fractions, périmètre
- **Français** : Lecture, orthographe, grammaire, conjugaison, vocabulaire
- **Sciences** : Animaux, corps humain, nature, météo, plantes, cycle de l'eau

### 🎮 Système de Gamification
- 🗺️ **Carte des Mondes** - 7 univers à explorer
- ⭐ **Système d'étoiles** - Gagnez 1 à 3 étoiles par compétence
- 🔥 **Combo System** - Bonus pour les séries de bonnes réponses
- 🏆 **Achievements** - 14 achievements à débloquer
- 🤖 **Coach Stella** - Coach virtuel bienveillant
- 👤 **5 Avatars** - Personnalisez votre personnage

### ⏰ Bien-être
- Limitation du temps d'écran
- Pause active avec exercices physiques
- Feedback bienveillant sur les erreurs

## 🚀 Installation

### Prérequis
- Flutter SDK 3.0+ ([Installer Flutter](https://docs.flutter.dev/get-started/install))
- Android Studio (pour Android)
- Xcode (pour iOS, macOS uniquement)

### Étapes

```bash
# 1. Clonez le dépôt
git clone https://github.com/farinhahelder-hue/learning-apk-app.git
cd learning-apk-app

# 2. Installez les dépendances
flutter pub get

# 3. Lancez en mode développement
flutter run

# 4. Générez l'APK
flutter build apk --release
```

### Structure des assets

Pour que l'app fonctionne pleinement, ajoutez les fichiers suivants :

```
assets/
├── images/           # Images des matières (optionnel)
├── animations/       # Animations Lottie (optionnel)
├── sounds/           # Sons (correct.mp3, error.mp3, etc.)
│   └── music/        # Musiques de fond
└── fonts/            # Police Nunito (optionnel)
```

### Sources audio gratuites
- [Freesound.org](https://freesound.org) - Effets sonores CC0
- [Pixabay Music](https://pixabay.com/music/) - Musiques CC0
- [Mixkit](https://mixkit.co/free-sound-effects/) - Effets gratuits

## 📁 Structure du Projet

```
lib/
├── main.dart                  # Point d'entrée
├── models/
│   ├── exercise.dart          # Modèle d'exercice
│   ├── game_models.dart       # GameSession, WorldProgress
│   └── achievement.dart      # Définitions des achievements
├── services/
│   ├── progress_service.dart # Sauvegarde progression
│   ├── game_service.dart     # Moteur de jeu (XP, niveaux, avatars)
│   └── audio_service.dart    # Sons et musiques
├── screens/
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── math/
│   ├── french/
│   ├── science/
│   ├── parental/
│   ├── game/                  # WorldMapScreen
│   └── achievement/           # AchievementsScreen
├── widgets/
│   ├── subject_card.dart
│   ├── progress_banner.dart
│   └── exercise_card.dart
├── data/
│   ├── math_exercises.dart    # 50+ exercices maths
│   ├── french_exercises.dart   # 40+ exercices français
│   └── science_exercises.dart # 25+ exercices sciences
└── utils/
    ├── app_theme.dart         # Thèmes et couleurs
    └── constants.dart         # Constantes (nom, code parental)
```

## 🎯 Programme Scolaire Couvert

### CE1
| Matière | Notions |
|---------|---------|
| Maths | Additions/soustractions jusqu'à 100, tables ×2/3/4/5, formes 2D |
| Français | Lecture-compréhension, orthographe, présent, sujet/verbe |
| Sciences | Animaux, corps humain, saisons, croissance des plantes |

### CE2
| Matière | Notions |
|---------|---------|
| Maths | Nombres jusqu'à 1000, ×6/7/8/9, ÷2/3/4/5/6, fractions, périmètre |
| Français | Passé composé, futur, imparfait, GN, adjectifs, homophones |
| Sciences | Digestion, pollinisation, cycle de l'eau, états de la matière |

## 🔧 Configuration

### Code Parental
Par défaut : `1234`

Pour le modifier, changez dans `lib/utils/constants.dart`:
```dart
static const String parentalCode = 'TON_CODE';
```

### Personnalisation
Le nom de l'enfant peut être changé dans `lib/utils/constants.dart`:
```dart
static const String childName = 'Émilie';
```

## 📱 Génération APK

### Android
```bash
flutter build apk --release
# APK : build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contribution

Les contributions sont les bienvenues ! 

1. Fork le projet
2. Créez une branche feature (`git checkout -b feature/Amelioration`)
3. Commit (`git commit -m 'Ajout nouvelle fonctionnalité'`)
4. Push (`git push origin feature/Amelioration`)
5. Ouvrez une Pull Request

## 📄 Licence

Ce projet est à usage éducatif. 

## 👩‍💻 Auteur

Créé avec ❤️ pour Émilie

---

*Cette application est un projet éducatif et ne remplace pas l'enseignement scolaire traditionnel.*
