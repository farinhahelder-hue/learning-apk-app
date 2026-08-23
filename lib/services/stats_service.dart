import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ce qui est observé pour une compétence donnée, à un niveau donné.
///
/// Volontairement descriptif : on compte ce qui s'est passé, on
/// n'interprète pas pourquoi.
class CompetenceStat {
  int started;
  int completed;

  /// Terminées sans avoir demandé d'aide.
  int autonomous;

  /// Terminées après avoir demandé au moins une aide.
  int withHelp;

  /// Nombre total d'aides demandées sur cette compétence.
  int hints;

  CompetenceStat({
    this.started = 0,
    this.completed = 0,
    this.autonomous = 0,
    this.withHelp = 0,
    this.hints = 0,
  });

  Map<String, dynamic> toMap() => {
        's': started, 'c': completed, 'a': autonomous, 'w': withHelp, 'h': hints,
      };

  factory CompetenceStat.fromMap(Map<String, dynamic> m) => CompetenceStat(
        started: m['s'] as int? ?? 0,
        completed: m['c'] as int? ?? 0,
        autonomous: m['a'] as int? ?? 0,
        withHelp: m['w'] as int? ?? 0,
        hints: m['h'] as int? ?? 0,
      );
}

/// 📊 Suivi pédagogique pour l'espace parents.
///
/// Deux règles importantes :
/// - les statistiques CE1 et CE2 sont stockées SÉPARÉMENT ;
/// - ce service ne produit que des observations factuelles. Il ne conclut
///   jamais à une incapacité, une fatigue ou un manque d'attention :
///   l'application ne peut pas connaître la cause d'une erreur.
class StatsService extends ChangeNotifier {
  final SharedPreferences _prefs;

  /// Clé : "CE1|competence" → statistiques.
  final Map<String, CompetenceStat> _stats = {};

  /// Clé : niveau → nombre de demandes de pause.
  final Map<String, int> _pauses = {};

  StatsService(this._prefs) {
    final raw = _prefs.getString('stats_v1');
    if (raw != null) {
      try {
        final data = json.decode(raw) as Map<String, dynamic>;
        final s = data['stats'] as Map<String, dynamic>? ?? {};
        s.forEach((k, v) =>
            _stats[k] = CompetenceStat.fromMap(v as Map<String, dynamic>));
        final p = data['pauses'] as Map<String, dynamic>? ?? {};
        p.forEach((k, v) => _pauses[k] = v as int);
      } catch (_) {
        _stats.clear();
        _pauses.clear();
      }
    }
  }

  String _key(String level, String competence) => '$level|$competence';

  Future<void> _save() async {
    await _prefs.setString(
      'stats_v1',
      json.encode({
        'stats': _stats.map((k, v) => MapEntry(k, v.toMap())),
        'pauses': _pauses,
      }),
    );
    notifyListeners();
  }

  // ── Enregistrement ───────────────────────────────────────
  Future<void> recordStarted(String level, String competence) async {
    final k = _key(level, competence);
    final st = _stats.putIfAbsent(k, () => CompetenceStat());
    st.started++;
    await _save();
  }

  Future<void> recordCompleted(
    String level,
    String competence, {
    required int hintsUsed,
  }) async {
    final k = _key(level, competence);
    final st = _stats.putIfAbsent(k, () => CompetenceStat());
    st.completed++;
    st.hints += hintsUsed;
    if (hintsUsed > 0) {
      st.withHelp++;
    } else {
      st.autonomous++;
    }
    await _save();
  }

  Future<void> recordPauseRequested(String level) async {
    _pauses[level] = (_pauses[level] ?? 0) + 1;
    await _save();
  }

  // ── Lecture ──────────────────────────────────────────────
  /// Les compétences travaillées à ce niveau, les plus pratiquées d'abord.
  List<MapEntry<String, CompetenceStat>> competencesFor(String level) {
    final prefix = '$level|';
    final list = _stats.entries
        .where((e) => e.key.startsWith(prefix))
        .map((e) => MapEntry(e.key.substring(prefix.length), e.value))
        .toList();
    list.sort((a, b) => b.value.started.compareTo(a.value.started));
    return list;
  }

  int startedFor(String level) =>
      competencesFor(level).fold(0, (s, e) => s + e.value.started);

  int completedFor(String level) =>
      competencesFor(level).fold(0, (s, e) => s + e.value.completed);

  int autonomousFor(String level) =>
      competencesFor(level).fold(0, (s, e) => s + e.value.autonomous);

  int withHelpFor(String level) =>
      competencesFor(level).fold(0, (s, e) => s + e.value.withHelp);

  int hintsFor(String level) =>
      competencesFor(level).fold(0, (s, e) => s + e.value.hints);

  int pausesFor(String level) => _pauses[level] ?? 0;

  bool hasDataFor(String level) => startedFor(level) > 0;

  /// « Ce qui aide Emilie » — observations factuelles uniquement.
  ///
  /// Formulées comme des constats ("a demandé…", "a terminé…"), jamais
  /// comme un diagnostic. C'est à l'adulte d'interpréter.
  List<String> observationsFor(String level) {
    final obs = <String>[];
    final started = startedFor(level);
    if (started == 0) return obs;

    final completed = completedFor(level);
    final autonomous = autonomousFor(level);
    final withHelp = withHelpFor(level);
    final pauses = pausesFor(level);

    if (withHelp > autonomous && withHelp > 0) {
      obs.add('A terminé plus souvent en s\'appuyant sur les aides proposées.');
    } else if (autonomous > 0 && autonomous >= withHelp) {
      obs.add('A terminé plusieurs missions sans demander d\'aide.');
    }

    if (started > completed) {
      final abandoned = started - completed;
      obs.add('$abandoned mission(s) commencée(s) puis arrêtée(s) avant la fin.');
    }

    if (completed > 0) {
      obs.add('$completed mission(s) menée(s) jusqu\'au bout.');
    }

    if (pauses > 0) {
      obs.add('A vu $pauses proposition(s) de pause pendant les séances.');
    }

    final comps = competencesFor(level);
    if (comps.isNotEmpty) {
      final top = comps.first;
      obs.add('Compétence la plus travaillée : ${_readable(top.key)}.');
    }

    return obs;
  }

  /// Transforme un identifiant technique en libellé lisible.
  static String _readable(String competence) {
    var s = competence.replaceAll('_', ' ');
    s = s.replaceAll(' ce1', '').replaceAll(' ce2', '');
    return s.isEmpty ? competence : '${s[0].toUpperCase()}${s.substring(1)}';
  }

  static String readableCompetence(String competence) => _readable(competence);

  Future<void> resetAll() async {
    _stats.clear();
    _pauses.clear();
    await _save();
  }
}
