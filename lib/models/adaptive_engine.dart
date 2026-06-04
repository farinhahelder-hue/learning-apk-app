// 🧠 Moteur adaptatif ZPD - Zone Proximale de Développement
// Cible : taux de réussite de 75-85% (ni trop facile, ni trop dur)
import '../models/exercise.dart';

class AdaptiveEngine {
  // Historique des sessions par compétence : skillId -> [% réussite]
  final Map<String, List<double>> _history = {};

  static const double _targetMin = 0.75;
  static const double _targetMax = 0.85;

  void recordSession(String skillId, double successRate) {
    _history.putIfAbsent(skillId, () => []);
    final list = _history[skillId]!;
    list.add(successRate);
    if (list.length > 5) list.removeAt(0); // garder les 5 dernières
  }

  // Calcule le niveau de difficulté recommandé : 1=facile, 2=moyen, 3=difficile
  int recommendedDifficulty(String skillId) {
    final history = _history[skillId];
    if (history == null || history.isEmpty) return 1;
    final avg = history.reduce((a, b) => a + b) / history.length;
    if (avg > _targetMax) return 3;  // trop facile -> monter
    if (avg < _targetMin) return 1;  // trop dur -> baisser
    return 2;                         // dans la ZPD -> maintenir
  }

  // Filtre les exercices selon la difficulté recommandée
  List<Exercise> filterExercises(String skillId, List<Exercise> exercises) {
    final diff = recommendedDifficulty(skillId);
    final filtered = exercises.where((e) => e.difficulty <= diff + 1 && e.difficulty >= diff - 1).toList();
    return filtered.isEmpty ? exercises : filtered;
  }

  // Message coach adapté selon le taux de réussite
  String coachMessage(double successRate) {
    if (successRate >= 0.9) return '🤩 Incroyable Emilie ! Tu es une vraie championne ! Je vais rendre les exercices un peu plus challengeants pour toi !';
    if (successRate >= 0.75) return '🌟 Super ! Tu es exactement dans la bonne zone ! Continue comme ça !';
    if (successRate >= 0.5) return '💪 Bien essayé ! On va reprendre depuis le début pour que tu te sentes plus à l’aise. Tu vas y arriver !';
    return '🤗 Pas de souci ! Chaque erreur est une leçon. Je vais t’aider avec des exercices plus simples d’abord !';
  }

  // Déterminer le message d’erreur bienveillant (jamais punitif)
  static String gentleErrorMessage(int attemptNumber) {
    final messages = [
      '🤔 Hmm, pas tout à fait ! Réessaie !',
      '🔍 Regarde bien la question...',
      '🌈 Tu es près du but ! Encore un essai !',
      '💡 Conseil : lis la question très lentement !',
      '❤️ C’est difficile, mais tu es capable !',
    ];
    return messages[attemptNumber.clamp(0, messages.length - 1)];
  }
}
