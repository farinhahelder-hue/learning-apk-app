#!/bin/bash

# Script de build pour Emilie App
# Usage: ./build_apk.sh

set -e

echo "🔨 Build Emilie App"
echo "=================="

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Vérifier Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${YELLOW}⚠️ Flutter non trouvé!${NC}"
    echo "Installation requise : https://docs.flutter.dev/get-started/install"
    echo ""
    echo "Commandes à exécuter :"
    echo "  1. Clonez le dépôt"
    echo "  2. flutter pub get"
    echo "  3. flutter run (dev) ou flutter build apk --release (production)"
    exit 1
fi

echo -e "${GREEN}✓ Flutter trouvé${NC}"

# Nettoyer
echo ""
echo "🧹 Nettoyage..."
flutter clean

# Obtenir les dépendances
echo ""
echo "📦 Installation des dépendances..."
flutter pub get

# Build debug APK
echo ""
echo "🔨 Build APK Debug..."
flutter build apk --debug

# Vérifier le fichier généré
APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
if [ -f "$APK_PATH" ]; then
    echo ""
    echo -e "${GREEN}✅ APK Debug généré avec succès!${NC}"
    echo "   📍 $APK_PATH"
    ls -lh "$APK_PATH"
else
    echo ""
    echo -e "${YELLOW}⚠️ APK non trouvé à l'emplacement attendu${NC}"
fi

echo ""
echo "🎯 Prochaines étapes :"
echo "   - Testez l'APK sur un appareil Android ou émulateur"
echo "   - Pour l'APK release: flutter build apk --release"
echo "   - Pour l'App Bundle: flutter build appbundle --release"