import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/daily_challenge.dart';
import '../services/game_service.dart';
import '../utils/app_theme.dart';
import 'arcade_game_screen.dart';
import '../utils/curriculum.dart';

class DailyChallengeScreen extends StatelessWidget {
  const DailyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameService>();
    final challenge = DailyChallenge.generate(DateTime.now());
    final done = gs.isDailyChallengeCompleted(challenge.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('💫 Défi du Jour'),
        backgroundColor: AppTheme.primaryYellow.withOpacity(0.2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(color: Colors.orange.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                children: [
                  Text(challenge.emoji, style: const TextStyle(fontSize: 64))
                      .animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 12),
                  Text(challenge.title,
                      style: const TextStyle(
                        color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(challenge.description,
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('+${challenge.bonusPoints} XP bonus 💫',
                        style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16,
                        )),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1),
            const SizedBox(height: 32),
            if (done)
              Column(
                children: [
                  const Text('✅', style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 12),
                  const Text('Défi du jour complété !',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const Text('Reviens demain pour un nouveau défi !',
                      style: TextStyle(color: AppTheme.textGrey)),
                ],
              )
            else
              ElevatedButton(
                onPressed: () {
                  // Déterminer le bon world pour le challenge
                  final worldId = challenge.subject == 'math' ? 'math_numbers'
                      : challenge.subject == 'french' ? 'french_spelling'
                      : 'math_measures';
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ArcadeGameScreen(
                        worldId: worldId,
                        skillId: 'sk_add100',
                        skillLabel: challenge.title,
                        subject: challenge.subject,
                        color: Colors.orange,
                      ),
                    ),
                  ).then((_) => gs.completeDailyChallenge(challenge.id));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('🚀 Relever le défi !',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }
}
