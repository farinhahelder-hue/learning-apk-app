# 📦 Guide d'installation - Emilie App

## Prérequis

| Outil | Version minimale |
|-------|------------------|
| Flutter SDK | 3.0.0 |
| Dart SDK | 3.0.0 |
| Android Studio | Hedgehog+ |
| Java JDK | 11+ |

## Étapes d'installation

### 1. Cloner le projet
```bash
git clone https://github.com/farinhahelder-hue/learning-apk-app.git
cd learning-apk-app
```

### 2. Installer les dépendances
```bash
flutter pub get
```

### 3. Vérifier l'environnement
```bash
flutter doctor
```

### 4. Lancer en mode développement
```bash
# Sur émulateur Android ou appareil physique
flutter run
```

### 5. Générer l'APK de production
```bash
flutter build apk --release
# APK disponible dans : build/app/outputs/flutter-apk/app-release.apk
```

### 6. Générer un App Bundle (Google Play)
```bash
flutter build appbundle --release
```

## 🔧 Configuration Firebase (optionnel)

1. Créer un projet sur [console.firebase.google.com](https://console.firebase.google.com)
2. Ajouter une app Android avec le package `com.emilieapp.education`
3. Télécharger `google-services.json` et le placer dans `android/app/`
4. Dans `lib/main.dart`, ajouter avant `runApp()` :
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

## 👤 Code parental par défaut
**Code : 1234**  
Modifiable dans `lib/utils/constants.dart` → `parentalCode`

## 📁 Ajouter des sons (optionnel)
Placer les fichiers MP3 dans `assets/sounds/` :
- `success.mp3` - son correct
- `error.mp3` - son incorrect  
- `click.mp3` - son clic
- `level_up.mp3` - monter de niveau

## ⚠️ Dépannage fréquent

| Problème | Solution |
|---------|----------|
| `flutter pub get` échoue | Vérifier la version Dart SDK |
| Build APK échoue | Exécuter `flutter clean && flutter pub get` |
| Erreur Gradle | Vérifier Java 11+ installé |
| App ne démarre pas | Vérifier `flutter doctor -v` |
