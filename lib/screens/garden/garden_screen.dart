import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/garden_service.dart';
import '../../services/accessibility_settings_service.dart';
import '../../utils/app_theme.dart';

/// 🌱 Le jardin d'Emilie — espace de clôture et de plaisir.
/// Aucune pression : rien ne disparaît, rien n'expire, aucun classement.
class GardenScreen extends StatelessWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final garden = context.watch<GardenService>();
    final animations =
        context.watch<AccessibilitySettingsService>().animationsEnabled;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🌱 Mon jardin'),
        backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFE8F5E9),
              AppTheme.primaryGreen.withOpacity(0.25),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Mes ressources ──
            Row(
              children: [
                Expanded(
                    child: _ResourceChip(
                        emoji: '🌰', count: garden.seeds, label: 'graines à planter')),
                const SizedBox(width: 12),
                Expanded(
                    child: _ResourceChip(
                        emoji: '💧', count: garden.drops, label: 'gouttes à arroser')),
              ],
            ),
            const SizedBox(height: 20),

            // ── Le jardin ──
            Container(
              constraints: const BoxConstraints(minHeight: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.75),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.4), width: 2),
              ),
              child: garden.plants.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Text('🪴', style: TextStyle(fontSize: 54)),
                          SizedBox(height: 12),
                          Text(
                            'Ton jardin est encore vide.\nTermine une activité pour gagner ta première graine !',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: AppTheme.textGrey, height: 1.5),
                          ),
                        ],
                      ),
                    )
                  : Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      alignment: WrapAlignment.center,
                      children: List.generate(garden.plants.length, (i) {
                        final p = garden.plants[i];
                        return _PlantTile(
                          plant: p,
                          canWater: garden.canWater && p.growth < 3,
                          animate: animations,
                          onWater: () => garden.water(i),
                        );
                      }),
                    ),
            ),

            // ── Les habitants ──
            if (garden.unlockedCritters.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Les habitants de ton jardin',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    const Text('Ils viennent quand des fleurs s\'ouvrent 🌸',
                        style: TextStyle(fontSize: 11, color: AppTheme.textGrey)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 16,
                      children: garden.unlockedCritters
                          .map((c) => Column(
                                children: [
                                  Text(c['emoji'] as String, style: const TextStyle(fontSize: 30)),
                                  Text(c['name'] as String,
                                      style: const TextStyle(fontSize: 10, color: AppTheme.textGrey)),
                                ],
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // ── Planter ──
            const Text('Planter une graine 🌰',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
              garden.canPlant
                  ? 'Choisis ce que tu veux planter.'
                  : 'Termine une activité pour gagner une graine.',
              style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: GardenService.plantChoices.map((emoji) {
                return GestureDetector(
                  onTap: garden.canPlant ? () => garden.plant(emoji) : null,
                  child: Opacity(
                    opacity: garden.canPlant ? 1 : 0.35,
                    child: Container(
                      width: 62, height: 62,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppTheme.primaryGreen.withOpacity(0.4), width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(emoji, style: const TextStyle(fontSize: 30)),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                '💚 Ton jardin ne disparaît jamais. Il n\'y a rien à perdre, '
                'rien à finir avant demain. Il est là quand tu en as envie.',
                style: TextStyle(fontSize: 12, height: 1.5),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ResourceChip extends StatelessWidget {
  final String emoji, label;
  final int count;
  const _ResourceChip({required this.emoji, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 2),
          Text('$count',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textGrey)),
        ],
      ),
    );
  }
}

class _PlantTile extends StatelessWidget {
  final GardenPlant plant;
  final bool canWater;
  final bool animate;
  final VoidCallback onWater;

  const _PlantTile({
    required this.plant,
    required this.canWater,
    required this.animate,
    required this.onWater,
  });

  /// Étapes de croissance : graine → pousse → plante → floraison.
  String get _display {
    switch (plant.growth) {
      case 0: return '🌰';
      case 1: return '🌱';
      case 2: return '🌿';
      default: return plant.emoji;
    }
  }

  String get _stageLabel {
    switch (plant.growth) {
      case 0: return 'graine';
      case 1: return 'pousse';
      case 2: return 'plante';
      default: return 'en fleur !';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: canWater ? onWater : null,
      child: AnimatedContainer(
        duration: Duration(milliseconds: animate ? 350 : 0),
        width: 84,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: canWater ? AppTheme.primaryBlue : Colors.grey.shade200,
            width: canWater ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(_display, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 2),
            Text(_stageLabel,
                style: const TextStyle(fontSize: 10, color: AppTheme.textGrey)),
            if (canWater)
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Text('💧 arroser', style: TextStyle(fontSize: 9, color: AppTheme.primaryBlue)),
              ),
          ],
        ),
      ),
    );
  }
}
