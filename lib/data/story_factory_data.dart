/// Fabrique à histoires — produire un texte, pas répondre à un QCM.
///
/// Deux principes qui expliquent toute la structure :
///
/// - **Rien n'est corrigé.** Une production d'écrit ne se juge pas
///   automatiquement, et une application hors ligne encore moins. Il n'y a
///   donc ni score, ni faute signalée, ni bonne version. L'histoire
///   d'Emilie est le résultat, pas une tentative.
/// - **Écrire ne doit pas être un péage.** Chaque étape propose des
///   amorces à toucher. Emilie peut composer une histoire entière sans
///   taper une lettre, écrire librement, ou mélanger les deux. Taper au
///   clavier est laborieux pour beaucoup d'enfants : ça ne doit pas être
///   la condition pour raconter quelque chose.
library;

/// Un ingrédient à choisir au début : qui, où, avec quoi, quel souci.
class StoryIngredient {
  final String emoji;
  final String label;

  /// Le morceau de phrase inséré dans l'histoire.
  final String text;

  const StoryIngredient({
    required this.emoji,
    required this.label,
    required this.text,
  });
}

/// Une étape de l'histoire : une consigne, et des amorces à toucher.
class StoryStep {
  /// Ce qu'on demande, côté enfant.
  final String prompt;

  /// La formule qui ouvre le paragraphe, déjà écrite.
  final String opener;

  /// Suggestions à toucher. Les `{qui}`, `{ou}`, `{objet}` et `{souci}`
  /// sont remplacés par les ingrédients choisis.
  final List<String> suggestions;

  /// Ce qu'on souffle à Emilie si elle bloque, sans lui dire quoi écrire.
  final String nudge;

  const StoryStep({
    required this.prompt,
    required this.opener,
    required this.suggestions,
    required this.nudge,
  });
}

class StoryFactoryData {
  static List<StoryStep> stepsFor(String level) =>
      level == 'CE2' ? ce2Steps : ce1Steps;

  // ── Les ingrédients, communs aux deux niveaux ──
  static const List<StoryIngredient> characters = [
    StoryIngredient(emoji: '🦭', label: 'Bébé Phoque', text: 'Bébé Phoque'),
    StoryIngredient(emoji: '🐿️', label: 'Papa Écureuil', text: 'Papa Écureuil'),
    StoryIngredient(emoji: '🐬', label: 'Ninon la dauphine', text: 'Ninon la dauphine'),
    StoryIngredient(emoji: '🦀', label: 'Ainy le crabe', text: 'Ainy le crabe'),
    StoryIngredient(emoji: '🐈‍⬛', label: 'Barbe Noire le chat', text: 'Barbe Noire le chat'),
    StoryIngredient(emoji: '🐦', label: 'Billy l\'oiseau', text: 'Billy l\'oiseau'),
    StoryIngredient(emoji: '🐉', label: 'un petit dragon', text: 'un petit dragon'),
    StoryIngredient(emoji: '🦊', label: 'un renard curieux', text: 'un renard curieux'),
  ];

  static const List<StoryIngredient> places = [
    StoryIngredient(emoji: '🏝️', label: 'une île', text: 'sur une île déserte'),
    StoryIngredient(emoji: '🌲', label: 'la forêt', text: 'au milieu de la forêt'),
    StoryIngredient(emoji: '🏰', label: 'un château', text: 'dans un vieux château'),
    StoryIngredient(emoji: '🌊', label: 'le fond de la mer', text: 'tout au fond de la mer'),
    StoryIngredient(emoji: '🚀', label: 'l\'espace', text: 'très loin dans l\'espace'),
    StoryIngredient(emoji: '🏫', label: 'l\'école', text: 'dans une école endormie'),
    StoryIngredient(emoji: '🏔️', label: 'la montagne', text: 'en haut de la montagne'),
    StoryIngredient(emoji: '🏜️', label: 'le désert', text: 'au milieu du désert'),
  ];

  static const List<StoryIngredient> objects = [
    StoryIngredient(emoji: '🗝️', label: 'une clé', text: 'une petite clé rouillée'),
    StoryIngredient(emoji: '🪄', label: 'une baguette', text: 'une baguette magique'),
    StoryIngredient(emoji: '🗺️', label: 'une carte', text: 'une carte au trésor'),
    StoryIngredient(emoji: '🔦', label: 'une lampe', text: 'une lampe qui ne s\'éteint jamais'),
    StoryIngredient(emoji: '📕', label: 'un livre', text: 'un livre qui parle'),
    StoryIngredient(emoji: '🥾', label: 'des bottes', text: 'des bottes de sept lieues'),
    StoryIngredient(emoji: '🪶', label: 'une plume', text: 'une plume dorée'),
    StoryIngredient(emoji: '🧭', label: 'une boussole', text: 'une boussole cassée'),
  ];

  static const List<StoryIngredient> troubles = [
    StoryIngredient(emoji: '🌧️', label: 'une tempête', text: 'une tempête arrive'),
    StoryIngredient(emoji: '🚪', label: 'une porte fermée', text: 'une porte refuse de s\'ouvrir'),
    StoryIngredient(emoji: '😴', label: 'tout le monde dort', text: 'tout le monde s\'est endormi'),
    StoryIngredient(emoji: '🧩', label: 'une énigme', text: 'une énigme bloque le chemin'),
    StoryIngredient(emoji: '👣', label: 'des traces', text: 'des traces bizarres apparaissent'),
    StoryIngredient(emoji: '🔇', label: 'plus de son', text: 'tous les sons ont disparu'),
    StoryIngredient(emoji: '🕳️', label: 'un trou', text: 'un grand trou barre la route'),
    StoryIngredient(emoji: '🎈', label: 'ça s\'envole', text: 'quelque chose s\'envole trop haut'),
  ];

  // ══════════════════════════════════════════════════════════
  // CE1 — trois étapes, amorces courtes
  // ══════════════════════════════════════════════════════════
  static const List<StoryStep> ce1Steps = [
    StoryStep(
      prompt: 'Comment commence ton histoire ?',
      opener: 'Il était une fois {qui}, {ou}.',
      suggestions: [
        'Ce jour-là, le soleil brillait très fort.',
        'C\'était le matin, et tout était calme.',
        'Personne ne savait ce qui allait arriver.',
        'Il faisait froid et un peu sombre.',
      ],
      nudge: 'Tu peux dire le temps qu\'il faisait, ou ce qu\'on entendait.',
    ),
    StoryStep(
      prompt: 'Qu\'est-ce qui se passe ?',
      opener: 'Un jour, {souci}.',
      suggestions: [
        'Heureusement, il y avait {objet}.',
        'Personne ne savait quoi faire.',
        'Tout le monde se mit à chercher une idée.',
        'C\'était vraiment un gros problème.',
      ],
      nudge: 'Raconte ce que ton personnage ressent à ce moment-là.',
    ),
    StoryStep(
      prompt: 'Comment ça se termine ?',
      opener: 'À la fin,',
      suggestions: [
        'tout le monde était content.',
        'le problème était réglé, mais autrement que prévu.',
        'ils décidèrent de recommencer demain.',
        'plus personne ne parla de cette journée.',
      ],
      nudge: 'Une fin peut être joyeuse, calme, ou même un peu bizarre.',
    ),
  ];

  // ══════════════════════════════════════════════════════════
  // CE2 — quatre étapes, on demande plus de détails
  // ══════════════════════════════════════════════════════════
  static const List<StoryStep> ce2Steps = [
    StoryStep(
      prompt: 'Plante le décor',
      opener: 'Il était une fois {qui}, {ou}.',
      suggestions: [
        'L\'endroit était silencieux, presque trop silencieux.',
        'Le vent soufflait depuis trois jours sans s\'arrêter.',
        'Tout paraissait normal, et pourtant quelque chose clochait.',
        'C\'était le dernier jour avant les vacances.',
      ],
      nudge: 'Ajoute un détail qu\'on peut voir, entendre ou sentir.',
    ),
    StoryStep(
      prompt: 'Fais arriver le problème',
      opener: 'Un jour, {souci}.',
      suggestions: [
        'Au début, personne ne s\'en inquiéta.',
        'Il fallut se rendre à l\'évidence : c\'était sérieux.',
        'C\'est là que {objet} devint très utile.',
        'La situation empira d\'heure en heure.',
      ],
      nudge: 'Dis ce que ton personnage pense ou ressent en découvrant ça.',
    ),
    StoryStep(
      prompt: 'Raconte ce qu\'il fait',
      opener: 'Alors,',
      suggestions: [
        'il décida de demander de l\'aide.',
        'il réfléchit longtemps avant d\'agir.',
        'il essaya une idée, puis une autre.',
        'il se souvint de {objet} et s\'en servit.',
      ],
      nudge: 'Une bonne idée ne marche pas toujours du premier coup.',
    ),
    StoryStep(
      prompt: 'Trouve ta fin',
      opener: 'À la fin,',
      suggestions: [
        'tout rentra dans l\'ordre, mais rien n\'était vraiment pareil.',
        'il comprit quelque chose d\'important.',
        'il rentra chez lui, fatigué et content.',
        'il garda cette histoire pour lui.',
      ],
      nudge: 'Tu peux dire ce que ton personnage a appris.',
    ),
  ];
}
