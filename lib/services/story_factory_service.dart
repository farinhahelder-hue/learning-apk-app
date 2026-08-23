import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Une histoire écrite par Emilie.
///
/// Elle est gardée telle quelle : ni corrigée, ni notée, ni comparée à
/// une version attendue. Ce qu'elle a écrit est le résultat.
class WrittenStory {
  final String id;
  final String level;
  final String title;
  final List<String> paragraphs;

  /// Date d'écriture, pour ranger les histoires de la plus récente à la
  /// plus ancienne. Aucune notion de série ni de régularité : sauter
  /// trois semaines ne coûte rien.
  final DateTime writtenAt;

  const WrittenStory({
    required this.id,
    required this.level,
    required this.title,
    required this.paragraphs,
    required this.writtenAt,
  });

  String get fullText => paragraphs.join('\n\n');

  Map<String, dynamic> toMap() => {
        'id': id,
        'level': level,
        'title': title,
        'paragraphs': paragraphs,
        'at': writtenAt.millisecondsSinceEpoch,
      };

  factory WrittenStory.fromMap(Map<String, dynamic> m) => WrittenStory(
        id: m['id'] as String? ?? '',
        level: m['level'] as String? ?? 'CE1',
        title: m['title'] as String? ?? 'Mon histoire',
        paragraphs:
            (m['paragraphs'] as List?)?.map((e) => e.toString()).toList() ?? [],
        writtenAt: DateTime.fromMillisecondsSinceEpoch(
            m['at'] as int? ?? DateTime.now().millisecondsSinceEpoch),
      );
}

/// 📚 Les histoires écrites par Emilie, gardées sur le téléphone.
class StoryFactoryService extends ChangeNotifier {
  final SharedPreferences _prefs;
  final List<WrittenStory> _stories = [];

  StoryFactoryService(this._prefs) {
    final raw = _prefs.getString('written_stories_v1');
    if (raw != null) {
      try {
        final list = json.decode(raw) as List;
        for (final e in list) {
          _stories.add(WrittenStory.fromMap(e as Map<String, dynamic>));
        }
      } catch (_) {
        // Un stockage illisible ne doit pas empêcher d'écrire de
        // nouvelles histoires : on repart d'une liste vide.
        _stories.clear();
      }
    }
    _stories.sort((a, b) => b.writtenAt.compareTo(a.writtenAt));
  }

  List<WrittenStory> get stories => List.unmodifiable(_stories);

  List<WrittenStory> forLevel(String level) =>
      _stories.where((s) => s.level == level).toList();

  int get count => _stories.length;

  Future<void> _save() async {
    await _prefs.setString(
      'written_stories_v1',
      json.encode(_stories.map((s) => s.toMap()).toList()),
    );
    notifyListeners();
  }

  Future<void> add(WrittenStory story) async {
    _stories.insert(0, story);
    await _save();
  }

  /// Supprimer reste possible, mais c'est un geste d'adulte : l'écran ne
  /// propose jamais de jeter une histoire au milieu d'une séance.
  Future<void> remove(String id) async {
    _stories.removeWhere((s) => s.id == id);
    await _save();
  }
}
