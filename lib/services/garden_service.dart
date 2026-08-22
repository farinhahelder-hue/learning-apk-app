import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Une plante installée dans le jardin d'Emilie.
class GardenPlant {
  final String emoji;
  /// 0 = graine plantée, 1 = pousse, 2 = plante, 3 = en fleur
  int growth;

  GardenPlant({required this.emoji, this.growth = 0});

  Map<String, dynamic> toMap() => {'emoji': emoji, 'growth': growth};
  factory GardenPlant.fromMap(Map<String, dynamic> m) =>
      GardenPlant(emoji: m['emoji'] as String, growth: m['growth'] as int? ?? 0);
}

/// 🌱 Le jardin d'Emilie — une récompense calme, sans pression.
///
/// Règles volontaires :
/// - on gagne une ressource pour avoir COMMENCÉ et TERMINÉ une activité,
///   pas pour avoir tout réussi (un indice utilisé récompense quand même) ;
/// - aucune ressource ne disparaît jamais ;
/// - pas de série quotidienne, pas de classement, pas de compte à rebours,
///   aucun message qui pousse à revenir.
///
/// Volontairement limité à DEUX ressources : la graine (pour planter) et
/// l'eau (pour faire pousser). Multiplier les monnaies virtuelles
/// complexifierait le jardin sans rien apporter à Emilie.
class GardenService extends ChangeNotifier {
  final SharedPreferences _prefs;

  int _seeds = 0;
  int _drops = 0;
  List<GardenPlant> _plants = [];

  GardenService(this._prefs) {
    _seeds = _prefs.getInt('garden_seeds') ?? 0;
    _drops = _prefs.getInt('garden_drops') ?? 0;
    final raw = _prefs.getString('garden_plants');
    if (raw != null) {
      try {
        final list = json.decode(raw) as List<dynamic>;
        _plants = list
            .map((e) => GardenPlant.fromMap(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _plants = [];
      }
    }
  }

  int get seeds => _seeds;
  int get drops => _drops;
  List<GardenPlant> get plants => List.unmodifiable(_plants);

  /// Nombre de plantes arrivées à floraison.
  int get bloomedCount => _plants.where((p) => p.growth >= 3).length;

  /// Les plantes disponibles à planter.
  static const List<String> plantChoices = ['🌻', '🌷', '🌹', '🌼', '🪻', '🌵'];

  /// Petits habitants calmes, qui viennent s'installer quand des plantes
  /// arrivent à floraison. Rien à collectionner, rien à perdre.
  static const List<Map<String, dynamic>> critters = [
    {'emoji': '🐌', 'name': 'l\'escargot', 'blooms': 1},
    {'emoji': '🦋', 'name': 'le papillon', 'blooms': 2},
    {'emoji': '🐞', 'name': 'la coccinelle', 'blooms': 3},
    {'emoji': '🐝', 'name': 'l\'abeille', 'blooms': 5},
    {'emoji': '🦔', 'name': 'le hérisson', 'blooms': 7},
  ];

  List<Map<String, dynamic>> get unlockedCritters =>
      critters.where((c) => bloomedCount >= (c['blooms'] as int)).toList();

  Future<void> _save() async {
    await _prefs.setInt('garden_seeds', _seeds);
    await _prefs.setInt('garden_drops', _drops);
    await _prefs.setString(
      'garden_plants',
      json.encode(_plants.map((p) => p.toMap()).toList()),
    );
    notifyListeners();
  }

  Future<void> earnSeed([int count = 1]) async {
    _seeds += count;
    await _save();
  }

  Future<void> earnDrop([int count = 1]) async {
    _drops += count;
    await _save();
  }

  /// Récompense au DÉMARRAGE d'une mission : commencer compte déjà.
  Future<void> rewardMissionStarted() async {
    _seeds += 1;
    await _save();
  }

  /// Récompense de fin d'activité : toujours accordée, même si l'enfant
  /// s'est trompée ou a utilisé des indices.
  /// Donne une graine ET une goutte d'eau, pour que la boucle
  /// planter → arroser → faire fleurir fonctionne dès la première activité.
  Future<void> rewardActivityCompleted() async {
    _seeds += 1;
    _drops += 1;
    await _save();
  }

  bool get canPlant => _seeds > 0;
  bool get canWater => _drops > 0;

  Future<void> plant(String emoji) async {
    if (_seeds <= 0) return;
    _seeds -= 1;
    _plants.add(GardenPlant(emoji: emoji));
    await _save();
  }

  /// Arrose une plante : elle grandit d'un cran (jusqu'à la floraison).
  Future<void> water(int index) async {
    if (_drops <= 0) return;
    if (index < 0 || index >= _plants.length) return;
    if (_plants[index].growth >= 3) return;
    _drops -= 1;
    _plants[index].growth += 1;
    await _save();
  }

  /// Remet le jardin à zéro (espace parents uniquement).
  Future<void> resetGarden() async {
    _seeds = 0;
    _drops = 0;
    _plants = [];
    await _save();
  }
}
