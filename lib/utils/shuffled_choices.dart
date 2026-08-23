import 'dart:math';

/// Mélange les propositions d'une question.
///
/// **Pourquoi cet utilitaire existe.** Les données de l'application ont
/// été écrites avec la bonne réponse en premier dans la liste — c'est
/// pratique à rédiger et à relire. Mesuré sur 143 questions, la bonne
/// réponse se trouvait en première position dans 85 % des cas, et dans
/// 100 % des cas pour les histoires, le chantier des phrases et le
/// théâtre. Emilie aurait découvert « toucher le premier bouton » en
/// quelques séances, et le suivi parental aurait affiché « terminée sans
/// aide » sans qu'elle ait rien travaillé.
///
/// Le mélange se fait à l'affichage, pas dans les données : les fichiers
/// restent lisibles, et le contenu écrit plus tard héritera de la
/// correction sans qu'on ait à y penser.
///
/// **L'ordre ne bouge pas pendant qu'une question est affichée.** Le tirage
/// est déterministe pour un couple (sel, index) donné, donc reconstruire
/// l'écran redonne exactement le même ordre. Des boutons qui se
/// réarrangent sous les doigts seraient pénibles pour n'importe qui, et
/// particulièrement ici.
class Shuffled {
  const Shuffled._();

  /// Sel tiré une fois par écran, dans `initState`. Il fait varier l'ordre
  /// d'une séance à l'autre.
  static int newSalt() => Random().nextInt(1 << 30);

  /// Les propositions dans un ordre tiré au sort, stable pour un même
  /// [index] tant que [salt] ne change pas.
  static List<T> of<T>(
    List<T> choices, {
    required int salt,
    required int index,
  }) {
    final out = List<T>.of(choices);
    // Le décalage évite que deux questions voisines partagent un tirage.
    out.shuffle(Random(salt ^ (index * 2654435761)));
    return out;
  }
}
