import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/app_theme.dart';
import '../../utils/new_worlds_curriculum.dart';
import '../discovery_world_screen.dart';

/// Menu de sélection des mondes de découverte
/// (Animaux, Émotions, Géographie, Histoire, Univers, Faits incroyables)
class DiscoveryWorldMenuScreen extends StatelessWidget {
  const DiscoveryWorldMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final worlds = NewWorldsCurriculum.worlds;
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌍 Découvertes'),
        backgroundColor: AppTheme.primaryPurple.withOpacity(0.15),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choisis un monde à explorer !',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.95,
                ),
                itemCount: worlds.length,
                itemBuilder: (context, i) {
                  final world = worlds[i];
                  final color = Color(world['color'] as int);
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DiscoveryWorldScreen(world: world),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withOpacity(0.8), color],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: color.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 6)),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(world['emoji'] as String, style: const TextStyle(fontSize: 42)),
                          const Spacer(),
                          Text(world['title'] as String,
                              style: const TextStyle(
                                color: Colors.white, fontSize: 15,
                                fontWeight: FontWeight.w800,
                              )),
                          const SizedBox(height: 6),
                          Text(world['description'] as String,
                              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11),
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ).animate(delay: Duration(milliseconds: 80 * i)).fadeIn().scale(begin: const Offset(0.9, 0.9));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
