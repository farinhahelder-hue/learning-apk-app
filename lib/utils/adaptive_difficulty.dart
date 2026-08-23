import '../services/stats_service.dart';

/// Les trois moments d'une compétence, tels qu'Emilie les voit.
///
/// Les noms sont volontairement identiques pour toutes les compétences :
/// rien dans l'interface ne dit « niveau faible », « rattrapage » ou
/// « retard ». Revenir sur une base et découvrir une notion neuve portent
/// le même genre de nom, parce que ce sont deux façons normales de
/// travailler — mais l'étape reste visible, elle n'est pas masquée.
enum MissionStage { decouvre, consolide, reussis }

extension MissionStageInfo on MissionStage {
  /// Le libellé utilisé dans les données des missions. Il doit
  /// correspondre exactement au champ `missionType`.
  String get label => switch (this) {
        MissionStage.decouvre => 'Je découvre',
        MissionStage.consolide => 'Je consolide',
        MissionStage.reussis => 'Je réussis',
      };

  String get emoji => switch (this) {
        MissionStage.decouvre => '🌱',
        MissionStage.consolide => '🔁',
        MissionStage.reussis => '⭐',
      };

  /// Ce qu'on dit à Emilie. Aucune de ces phrases ne porte de jugement.
  String get childHint => switch (this) {
        MissionStage.decouvre => 'Quelque chose de nouveau à essayer.',
        MissionStage.consolide => 'On refait pour que ça rentre bien.',
        MissionStage.reussis => 'Tu connais : à toi de jouer seule.',
      };

  /// Ce qu'on dit à l'adulte : un constat, jamais un diagnostic.
  String get adultHint => switch (this) {
        MissionStage.decouvre => 'Pas encore travaillée.',
        MissionStage.consolide => 'Travaillée, encore souvent avec les aides.',
        MissionStage.reussis => 'Menée au bout plusieurs fois sans aide.',
      };
}

/// Choisit quoi proposer d'abord sur une compétence donnée.
///
/// Deux principes, tirés du cahier des charges :
///
/// - **Rien ne se verrouille.** L'étape conseillée passe en tête de liste,
///   mais aucune mission n'est retirée : Emilie peut toujours aller voir
///   les autres. C'est une suggestion d'ordre, pas un filtre.
/// - **La règle est explicite et vérifiable.** Elle ne repose que sur ce
///   qui a été observé (missions terminées, aides demandées) et jamais sur
///   une supposition d'état — l'application ne peut pas savoir si Emilie
///   est fatiguée, distraite ou en difficulté.
class AdaptiveDifficulty {
  const AdaptiveDifficulty._();

  /// Nombre de réussites au-delà duquel on considère la compétence comme
  /// installée — à condition qu'elles n'aient pas toutes eu besoin d'aide.
  static const int solidCompletions = 3;

  static MissionStage stageFor(CompetenceStat? stat) {
    if (stat == null || stat.completed == 0) return MissionStage.decouvre;
    if (stat.completed >= solidCompletions && stat.autonomous >= stat.withHelp) {
      return MissionStage.reussis;
    }
    return MissionStage.consolide;
  }

  /// L'étape conseillée pour une compétence, d'après le suivi enregistré.
  static MissionStage stageOf(
    StatsService stats,
    String level,
    String competence,
  ) {
    final match = stats
        .competencesFor(level)
        .where((e) => e.key == competence)
        .toList();
    return stageFor(match.isEmpty ? null : match.first.value);
  }

  /// Retrouve l'étape correspondant à un libellé de mission.
  static MissionStage? _stageFromLabel(String label) {
    for (final s in MissionStage.values) {
      if (s.label == label) return s;
    }
    return null;
  }

  /// Remet en tête les missions les plus proches de l'étape conseillée de
  /// leur propre compétence, en gardant toutes les autres à la suite.
  ///
  /// Toutes les compétences n'ont pas encore des missions dans les trois
  /// étapes. Plutôt que de ne rien faire quand l'étape exacte manque, on
  /// classe par écart : si « Je réussis » est conseillé mais n'existe pas,
  /// « Je consolide » passe devant « Je découvre ». À écart égal on
  /// privilégie l'étape la plus accessible.
  ///
  /// La répartition en paquets préserve l'ordre d'entrée (donc le mélange
  /// aléatoire déjà appliqué par les jeux) — contrairement à un tri, dont
  /// la stabilité n'est pas garantie en Dart.
  static List<T> ordered<T>(
    List<T> missions, {
    required StatsService stats,
    required String level,
    required String Function(T) competenceOf,
    required String Function(T) missionTypeOf,
  }) {
    // Clé de tri : écart à l'étape conseillée, puis facilité.
    final buckets = <int, List<T>>{};
    for (final m in missions) {
      final wanted = stageOf(stats, level, competenceOf(m)).index;
      final actual = _stageFromLabel(missionTypeOf(m))?.index;
      // Une mission sans étape reconnue part en dernier plutôt que de
      // passer pour un choix délibéré.
      final key = actual == null ? 99 : (actual - wanted).abs() * 2 +
          (actual > wanted ? 1 : 0);
      buckets.putIfAbsent(key, () => <T>[]).add(m);
    }
    final keys = buckets.keys.toList()..sort();
    return [for (final k in keys) ...buckets[k]!];
  }
}
