import 'package:flutter/material.dart';

/// État émotionnel d'une mascotte
enum MascotMood {
  idle,      // au repos, clignote des yeux
  happy,     // bonne réponse → saute
  wrong,     // mauvaise réponse → Monika fait "pipipipi"
  thinking,  // pendant le temps de réflexion
  celebrate, // score parfait
  encourage, // message d'encouragement
  sleepy,    // après longue session
}

/// Modèle d'une mascotte
class Mascot {
  final String id;
  final String name;
  final String emoji;          // fallback si pas d'image
  final String assetPath;      // assets/images/mascots/
  final String personality;    // description courte
  final String wrongSound;     // son quand mauvaise réponse
  final String correctSound;   // son quand bonne réponse
  final List<String> idlePhrases;    // phrases au repos
  final List<String> correctPhrases; // phrases bonne réponse
  final List<String> wrongPhrases;   // phrases mauvaise réponse
  final List<String> thinkPhrases;   // pendant réflexion
  final Color color;           // couleur principale

  const Mascot({
    required this.id,
    required this.name,
    required this.emoji,
    required this.assetPath,
    required this.personality,
    required this.wrongSound,
    required this.correctSound,
    required this.idlePhrases,
    required this.correctPhrases,
    required this.wrongPhrases,
    required this.thinkPhrases,
    required this.color,
  });
}

/// Toutes les mascottes de l'app
class Mascots {
  static const Mascot papaSeal = Mascot(
    id: 'papa_seal',
    name: 'Papa Phoque',
    emoji: '🦭',
    assetPath: 'assets/images/mascots/papa_seal.png',
    personality: 'Sage et bienveillant, toujours calme',
    wrongSound: 'sounds/mascot_hello_floflo.wav',
    correctSound: 'sounds/celebrate.wav',
    color: Color(0xFF5B8FB9),
    idlePhrases: [
      'Prêt à apprendre aujourd\'hui ? 🦭',
      'Tu peux le faire, je suis là ! 💙',
      'On explore ensemble ! 🌊',
    ],
    correctPhrases: [
      'Excellent ! Tu es brillante ! 🌟',
      'Je suis fier de toi Emilie ! 🦭💙',
      'Parfait ! Continue comme ça ! ⭐',
    ],
    wrongPhrases: [
      'Réfléchis bien... tu vas trouver 💙',
      'Pas grave ! On réessaie ensemble 🦭',
      'Presque ! Concentre-toi 🎯',
    ],
    thinkPhrases: [
      'Prends ton temps... 🤔',
      'Réfléchis bien... 💭',
      'Tu as le temps ! Pas de panique 🦭',
    ],
  );

  static const Mascot babySeal = Mascot(
    id: 'baby_seal',
    name: 'Bébé Phoque',
    emoji: '🐾',
    assetPath: 'assets/images/mascots/baby_seal.png',
    personality: 'Espiègle et adorable, apprend avec toi',
    wrongSound: 'sounds/wrong.wav',
    correctSound: 'sounds/correct.wav',
    color: Color(0xFF90CAF9),
    idlePhrases: [
      'Moi aussi j\'apprends avec toi ! 🐾',
      'On est les meilleurs copains ! 💕',
      'Joue avec moi ! 🎮',
    ],
    correctPhrases: [
      'Ouiii on a réussi ! 🎉🐾',
      'Tu es trop forte Emilie ! 💪',
      'Super duo ! 🐾⭐',
    ],
    wrongPhrases: [
      'Aïe... on réessaie ? 🐾',
      'Moi non plus je savais pas ! 😅',
      'Ensemble on va trouver ! 🤝',
    ],
    thinkPhrases: [
      'Hmmm je réfléchis aussi... 🤔',
      'Laisse-moi compter sur mes nageoires ! 🐾',
    ],
  );

  static const Mascot monikaJellyfish = Mascot(
    id: 'monika_jellyfish',
    name: 'Monika 🪼',
    emoji: '🪼',
    assetPath: 'assets/images/mascots/monika_jellyfish.png',
    personality: 'Dramaturge ! Fait des reproches avec "pipipipi" quand c\'est faux',
    wrongSound: 'sounds/wrong.wav',   // à remplacer par pipipipi
    correctSound: 'sounds/star.wav',
    color: Color(0xFFCE93D8),
    idlePhrases: [
      'Bonjour ! Monika surveille tout... 🪼👀',
      'J\'espère que tu vas bien répondre ! 🧐',
      'Je suis là... 🌊',
    ],
    correctPhrases: [
      'Bien... j\'attendais ça ! 😌🪼',
      'Enfin une bonne réponse ! (soupir de soulagement) ✨',
      'Pas mal du tout pour une fois ! 🪼💜',
    ],
    wrongPhrases: [
      'Pipipi ! 😤 C\'était pas ça du tout !',
      'Pipi pi pi pi ! 🪼 Recommence !',
      'Pipipipi ! Monika est déçue... 😔',
    ],
    thinkPhrases: [
      'Pipipi... je t\'observe 👀',
      'Réfléchis ou je fais pipipipi ! 🪼',
    ],
  );

  static const Mascot nightSquirrel = Mascot(
    id: 'night_squirrel',
    name: 'Papa Écureuil 🌙',
    emoji: '🐿️',
    assetPath: 'assets/images/mascots/night_squirrel.png',
    personality: 'Savant nocturne, spécialiste sciences et univers',
    wrongSound: 'sounds/wrong.wav',
    correctSound: 'sounds/combo.wav',
    color: Color(0xFF37474F),
    idlePhrases: [
      'Les étoiles m\'ont tout appris... 🌙⭐',
      'La nuit, on découvre des secrets ! 🔭',
      'Chut ! J\'observe le cosmos... 🪐',
    ],
    correctPhrases: [
      'Magnifique ! Une vraie scientifique ! 🔭',
      'Les étoiles brillent pour toi ! ✨🌙',
      'Bravo ! Tu mérites une constellation ! ⭐🐿️',
    ],
    wrongPhrases: [
      'Même les étoiles se trompent ! Réessaie 🌙',
      'L\'univers est vaste, reprends courage ! 🪐',
      'Dans ma forêt nocturne, on persévère ! 🐿️',
    ],
    thinkPhrases: [
      'Comme les étoiles, prends le temps... 🔭',
      'L\'univers attend ta réponse 🌙',
    ],
  );

  static const Mascot ainyCrab = Mascot(
    id: 'ainy_crab',
    name: 'Ainy 🦀',
    emoji: '🦀',
    assetPath: 'assets/images/mascots/ainy_crab.png',
    personality: 'Pince rigolote, spécialiste géographie et nature',
    wrongSound: 'sounds/wrong.wav',
    correctSound: 'sounds/correct.wav',
    color: Color(0xFFFF7043),
    idlePhrases: [
      'Clac clac ! Prêt à voyager ? 🦀🌍',
      'Je connais tous les coins du monde ! 🗺️',
      'Clac ! On part à l\'aventure ? 🦀',
    ],
    correctPhrases: [
      'Clac clac CLAC ! Magnifique ! 🦀🎉',
      'Tu connais le monde mieux que moi ! 🌍',
      'Super géographe ! 🗺️⭐',
    ],
    wrongPhrases: [
      'Clac... Pas tout à fait ! 🦀',
      'Même moi j\'ai cherché longtemps ! Réessaie 🗺️',
      'Clac clac... On cherche ensemble ! 🦀',
    ],
    thinkPhrases: [
      'Clac... je réfléchis aussi 🦀💭',
      'Cherche dans ta tête comme une carte ! 🗺️',
    ],
  );

  static const Mascot barbeNoire = Mascot(
    id: 'barbenoire_cat',
    name: 'Barbe Noire 😼',
    emoji: '🏴‍☠️',
    assetPath: 'assets/images/mascots/barbenoire_cat.png',
    personality: 'Chat pirate musclé, donne des défis et motive à fond',
    wrongSound: 'sounds/wrong.wav',
    correctSound: 'sounds/level_up.wav',
    color: Color(0xFF263238),
    idlePhrases: [
      'Moussaillon ! On attaque ? ⚔️🏴‍☠️',
      'Les pirates apprennent aussi ! 😼',
      'Prêt pour le défi du jour ? 💪🏴‍☠️',
    ],
    correctPhrases: [
      'Ahoy ! Tu es une vraie pirate ! 🏴‍☠️💪',
      'Sacrebleu ! Quelle réponse ! ⭐😼',
      'Tu rejoins mon équipage d\'élite ! 🚢',
    ],
    wrongPhrases: [
      'Tonnerre de Brest ! Réessaie moussaillon ! 🏴‍☠️',
      'Même les pirates se trompent ! Courage ! 😼',
      'Bateau en vue ! Concentre-toi ! ⚔️',
    ],
    thinkPhrases: [
      'Un pirate réfléchit avant d\'agir ! 🏴‍☠️',
      'Prends la barre... et réfléchis ! 🚢',
    ],
  );

  static const Mascot ninonDolphin = Mascot(
    id: 'ninon_dolphin',
    name: 'Ninon 🐬',
    emoji: '🐬',
    assetPath: 'assets/images/mascots/ninon_dolphin.png',
    personality: 'Dauphine chanteuse, spécialiste français et musique',
    wrongSound: 'sounds/wrong.wav',
    correctSound: 'sounds/mascot_hello_bubulle.wav',
    color: Color(0xFF26C6DA),
    idlePhrases: [
      'La la la... bonjour Emilie ! 🐬🎵',
      'Je chante donc j\'apprends ! 🎶',
      'Ninon est là pour toi ! 🐬💙',
    ],
    correctPhrases: [
      'Bravo ! Ça mérite une chanson ! 🎵🐬',
      'Tu chantes aussi bien que tu réponds ! 🎶⭐',
      'La la la BRAVO ! 🐬🎉',
    ],
    wrongPhrases: [
      'Fausse note ! Réessaie 🎵',
      'Même les chanteuses se trompent ! 🐬',
      'On reprend depuis le début ! 🎶',
    ],
    thinkPhrases: [
      'Hmm hm hm... je cherche la mélodie 🎵',
      'Écoute bien... la réponse est là ! 🐬',
    ],
  );

  /// Toutes les mascottes disponibles
  static const List<Mascot> all = [
    papaSeal,
    babySeal,
    monikaJellyfish,
    nightSquirrel,
    ainyCrab,
    barbeNoire,
    ninonDolphin,
  ];

  /// Mascotte par défaut selon la matière
  static Mascot forSubject(String subject) {
    switch (subject) {
      case 'math':    return barbeNoire;   // défi !
      case 'french':  return ninonDolphin; // chanteuse = linguiste
      case 'science': return nightSquirrel;
      case 'geo':     return ainyCrab;
      case 'animals': return babySeal;
      case 'emotions':return papaSeal;
      case 'history': return barbeNoire;
      case 'universe':return nightSquirrel;
      case 'amazing': return monikaJellyfish;
      default:        return papaSeal;
    }
  }
}
