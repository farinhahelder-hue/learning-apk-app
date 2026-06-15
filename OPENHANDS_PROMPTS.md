# Prompts OpenHands pour la Gestion Scolaire

Ce document contient les prompts prêts à l'emploi pour OpenHands afin de gérer les tâches scolaires et la génération de matériel didactique.

---

## 📅 PROMPT 1 : Ajout à l'Agenda Scolaire

```
AGENT ROLE: Gestionnaire d'Agenda Familial

INPUT DATA:
- Événement: Semaine sportive
- Organisé par: Madame Marine Guillemain (enseignante)
- Lieu: Stade Jules Noël, Paris
- Date: Vendredi 19 juin 2026
- Horaires estimés: 8h30 (départ) - 12h30 (retour)
- Équipement requis: Tenue de sport, basket de running, gourde, casquette
- Document signé le: 13/06/2026
- Date limite autorisation: 18/06/2026

TASK: Génère une entrée de calendrier structurée au format iCalendar et une checklist de préparation.

OUTPUT FORMAT:
1. Format iCalendar (.ics) prêt à importer
2. Checklist avec cases à cocher pour la préparation
3. Liste des actions-required avec dates limites

SPECIAL NOTES:
- Prévoir un plan B en cas de mauvais temps
- L'autorisation doit être signée et renvoyée la veille
- Prévoir une gourde suffisamment grande (1L recommandé)
```

---

## 📚 PROMPT 2 : Génération Exercices Mathématiques (Num 13)

```
AGENT ROLE: Créateur de Matériel Pédagogique CE2

CONTEXT:
Tu génères des exercices de mathématiques pour Laura, élève de CE2 (8 ans).
Devoir à préparer: "Num 13" - Numération jusqu'à 9 999
Échéance: Pour le 16 juin 2026

THEME: Les nombres de 0 à 9 999
- Lecture et écriture des nombres
- Décomposition (milliers, centaines, dizaines, unités)
- Valeur des chiffres selon leur position
- Comparaison et ordre
- Encadrement

EXERCICE TYPES REQUIRED (6 minimum):
1. QCM Décomposition: "3 000 + 400 + 50 + 2 = ?" avec options
2. Écriture en chiffres: Convertir "deux mille quatre cent dix-sept"
3. Identification du rang: "Dans 5 738, quel est le chiffre des centaines?"
4. Comparaison: "4 502 ___ 4 520" (<, >, ou =)
5. Ordre croissant: Ranger une liste de 4 nombres
6. Encadrement: "Le nombre avant 4 000 est..."

OUTPUT FORMAT: Code Dart pour Exercise model
```dart
Exercise(
  id: 'num13_X', 
  subject: 'math', 
  type: 'qcm',
  question: '...',
  options: [...],
  correctAnswer: '...',
  difficulty: 2,
  points: 15,
  hint: '...'
)
```

VALIDATION RULES:
- Réponses mathématiquement correctes
- Distracteurs plausibles mais faux
- Indice pédagogique utile
- Dificulty adaptée au CE2 (niveau 2)
```

---

## ✏️ PROMPT 3 : Génération Exercices Français (Mots 24 Bleu)

```
AGENT ROLE: Créateur de Matériel Pédagogique CE2

CONTEXT:
Tu génères des exercices de français pour Laura, élève de CE2 (8 ans).
Devoir à préparer: "mots 24 bleu" - Liste de 24 mots pour dictée
Échéance: Pour le 16 juin 2026

THEME: Liste bleue CE2
- Mots courants avec accents (forêt, fenêtre, écureuil)
- Homophones grammaticaux
- Participes passés courants
- Mots du quotidien

EXERCICE TYPES REQUIRED (18 minimum):
1-4. QCM Orthographe: Choisir le bon mot parmi les variantes
5-8. Compléter: Remplir le blanc avec le mot correct
9-10. Phonétique: Identifier les sons [wa], [wɑ̃]
11-18. Dictée: Écrire les mots de la liste

MOTS À INCLURE:
- hiver, nuit, chat, doux, mur
- oiseau, soir, forêt, fenêtre
- hérisson, écureuil, morceau
- allé, noix, travail, village

OUTPUT FORMAT: Code Dart pour Exercise model
```dart
Exercise(
  id: 'mots24_X', 
  subject: 'french', 
  type: 'qcm' | 'writing',
  question: '...',
  options: [...],  // pour QCM
  correctAnswer: '...',
  difficulty: 1-3,
  points: 10-25,
  mascot: Mascot.seal,  // ou squirrel, jellyfish
  hint: '...'
)
```

VALIDATION RULES:
- Orthographe française correcte
- Accents et cédilles properly placed
- Indice mnémotechnique utile
- Dificulty progressive (1 à 3)
```

---

## 📊 PROMPT 4 : Rapport de Progression Hebdomadaire

```
AGENT ROLE: Analyste Pédagogique

CONTEXT:
Génère un rapport de progression hebdomadaire pour Laura Diaz, CE2.
Période: Semaine du 13 au 19 juin 2026

DATA AVAILABLE:
- Exercices complétés: Num 13 (6), Mots 24 bleu (18)
- Points gagnés: À calculer selon les exercices
- Badges obtenus: Si 80%+ de réussite
- Temps de révision: À estimer (10-15 min par matière)

OUTPUT FORMAT:
1. Tableau de bord visuel avec:
   - Exercices complétés / total
   - Taux de réussite (%)
   - Points accumulés
   - Badges débloqués

2. Analyse qualitative:
   - Points forts identifiés
   - Difficultés rencontrées
   - Recommandations pour la semaine suivante

3. Message de motivation pour Laura:
   - Positif et encourageant
   - Adapté à son âge (8-9 ans)
   - Mise en avant des progrès
```

---

## 🎯 PROMPT 5 : Personnalisation selon Niveau

```
AGENT ROLE: Adaptateur Pédagogique

CONTEXT:
Personnalise les exercices selon le niveau de l'élève.

INPUT:
- Nom: Laura Diaz
- Âge: 8-9 ans
- Niveau actuel: CE2 (确认)
- Difficultés rapportées: Aucune spécifique
- Points forts: Lecture fluide, logique mathématique

TASK:
1. Analyse le niveau de Laura basé sur les informations données
2. Suggère des exercices adaptés:
   - Niveau actuel: CE2 standard
   - Révision: CE1 si besoin de consolidation
   - Défi: CM1 si trop facile

3. Propose un plan de révision personnalisé:
   - Jour 1: Num 13 (numération)
   - Jour 2: Mots 24 bleu (dictée)
   - Jour 3: Révision générale
   - Jour 4: Quiz évaluation

4. Génère des exercices bonus si l'élève complète rapidement:
   - Défis de logique
   - Mots de vocabulaire avancé
   - Problèmes de math narratifs

OUTPUT: Plan de révision hebdomadaire structuré
```

---

## 🏃 PROMPT 6 : Gestion Événement Spécial (Sortie Sportive)

```
AGENT ROLE: Coordinateur d'Événements Scolaires

INPUT DATA:
- Type: Sortie scolaire sportive
- Titre: Semaine sportive au Stade Jules Noël
- Date: Vendredi 19 juin 2026
- Horaires: 8h30 - 12h30
- Lieu: Stade Jules Noël, Paris
- Encadrant: Mme Marine Guillemain
- Responsable légal: Mme Emilie Diaz Faninha
- Élève: Laura Diaz

TASK:
1. Créer une checklist complète pour l'événement:
   - Documents à préparer (autorisation signée)
   - Équipement à emporter
   - Préparations la veille
   - Vérifications le matin

2. Générer un rappel calendrier:
   - 7 jours avant: Signer et renvoyer autorisation
   - La veille (18/06): Préparer le sac
   - Le matin (19/06): Vérifications finales

3. Plan B si intempéries:
   - Contacter l'école pour confirmation
   - Alternative indoor si pluie

4. Message d'information pour Laura:
   - Explication de l'événement
   - Ce qu'elle va faire (courses, jeux sportifs)
   - Pourquoi c'est bien de participer

OUTPUT: Document structuré prêt à imprimer ou envoyer
```

---

## 🔄 Instructions d'Utilisation

### Pour OpenHands Cloud:

1. **Copier le prompt** correspondant à votre besoin
2. **Coller dans la conversation** OpenHands
3. **Ajouter les données spécifiques** de votre enfant/élève
4. **Demander le code Dart** si vous voulez intégrer dans l'app
5. **Valider et adapter** les résultats avant utilisation

### Pour Intégration Directe:

Les prompts peuvent être utilisés pour générer:
- Du code Dart pour l'application Flutter
- Des fichiers iCal pour agendas numériques
- Des checklists imprimables
- Des rapports de progression

### Bonnes Pratiques:

✅ Toujours vérifier les exercices générés
✅ Adapter le niveau si nécessaire
✅ Tester avec l'enfant avant validation
✅ Conserver une trace des prompts utilisés
❌ Ne pas partager d'informations personnelles sensibles
❌ Ne pas utiliser sans supervision adulte

---

*Document créé avec OpenHands - Version 1.0 - Juin 2026*