# -*- coding: utf-8 -*-
"""Garde-fous du contenu de l'application d'Emilie.

    python tool/check_content.py

Ces contrôles existent parce qu'une classe entière de bugs ne se voit
NULLE PART sans eux : pas d'erreur de compilation, pas de crash, pas de
message. L'application se lance et fait simplement la mauvaise chose.

Chacun a été écrit après en avoir trouvé un pour de vrai :

- une opération dont le résultat annoncé est faux (6 + 6 = 18) ;
- une cible du Marché impossible à composer avec les jetons proposés ;
- une compétence dont il manque une étape, ce qui rend la difficulté
  adaptative inerte sans rien signaler ;
- un lieu de départ absent du plan, qui fait planter la mission au
  lancement ;
- un marqueur {qui} que personne ne remplace et qui reste affiché en
  toutes lettres ;
- un membre de thème inexistant, qui lui casse bien la compilation, mais
  seulement si le fichier est atteignable.

Sortie 0 si tout va bien, 1 sinon.
"""
import io
import os
import re
import sys
import glob

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(ROOT)

BS = chr(92)
LABELS = ['Je découvre', 'Je consolide', 'Je réussis']
problems = []
notes = []


def read(path):
    return io.open(path, encoding='utf-8').read()


def dart_files():
    return sorted(glob.glob('lib/**/*.dart', recursive=True))


# ══════════════════════════════════════════════════════════════
def check_braces():
    """Équilibre des délimiteurs, hors chaînes et commentaires."""

    def strip(src):
        out, i, n = [], 0, len(src)
        while i < n:
            c = src[i]
            if c == '/' and i + 1 < n and src[i + 1] == '/':
                while i < n and src[i] != '\n':
                    i += 1
            elif c == '/' and i + 1 < n and src[i + 1] == '*':
                i += 2
                while i + 1 < n and not (src[i] == '*' and src[i + 1] == '/'):
                    i += 1
                i += 2
            elif c in "'\"":
                q = c
                if src[i:i + 3] == q * 3:
                    i += 3
                    while i + 2 < n and src[i:i + 3] != q * 3:
                        if src[i] == BS:
                            i += 1
                        i += 1
                    i += 3
                else:
                    i += 1
                    while i < n and src[i] != q:
                        if src[i] == BS:
                            i += 1
                        i += 1
                    i += 1
            else:
                out.append(c)
                i += 1
        return ''.join(out)

    for f in dart_files():
        s = strip(read(f))
        for o, c in [('{', '}'), ('(', ')'), ('[', ']')]:
            if s.count(o) != s.count(c):
                problems.append('%s : %s%s déséquilibré (%d vs %d)'
                                % (f, o, c, s.count(o), s.count(c)))


# Fichiers tolérés malgré des imports cassés, en attendant une décision.
# Cette liste doit rester vide : chaque entrée est une dette assumée.
IMPORT_EXCEPTIONS = set()


def check_imports():
    """Un import relatif qui ne résout pas ne casse le build que si le
    fichier est atteignable — donc un écran orphelin peut cacher une
    erreur pendant des mois."""
    for f in dart_files():
        if f.replace(os.sep, '/') in IMPORT_EXCEPTIONS:
            notes.append('toléré : %s (imports cassés, décision en attente)'
                         % os.path.basename(f))
            continue
        for m in re.finditer(r"import\s+'([^']+)'", read(f)):
            p = m.group(1)
            if p.startswith('package:') or p.startswith('dart:'):
                continue
            if not os.path.exists(
                    os.path.normpath(os.path.join(os.path.dirname(f), p))):
                problems.append('%s : import introuvable -> %s' % (f, p))


def check_routes():
    main = read('lib/main.dart')
    routes = set(re.findall(r"'(/[a-z0-9\-]*)':", main))
    used = set()
    for f in dart_files():
        s = read(f)
        used |= set(re.findall(r"pushNamed\(\s*context\s*,\s*'([^']+)'", s))
    for u in sorted(used - routes):
        problems.append('route utilisée mais non déclarée : %s' % u)


def check_symbols():
    """Membres statiques et valeurs d'enum réellement déclarés."""
    for path, cls in [('lib/utils/app_theme.dart', 'AppTheme'),
                      ('lib/models/mascot.dart', 'Mascots')]:
        src = read(path)
        m = re.search(r'class\s+%s\b' % cls, src)
        if not m:
            continue
        body = src[m.end():]
        declared = set(re.findall(
            r'static\s+(?:const|final)\s+[\w<>,\s?]+\s+(\w+)\s*=', body))
        declared |= set(re.findall(r'static\s+[\w<>,\s?]+\s+get\s+(\w+)', body))
        declared |= set(re.findall(r'static\s+[\w<>,\s?]+\s+(\w+)\s*\(', body))
        for f in dart_files():
            s = read(f)
            for mm in re.finditer(r'\b%s\.(\w+)' % cls, s):
                if mm.group(1) in declared or mm.group(1) in ('values', 'name', 'index'):
                    continue
                line = s[:mm.start()].count('\n') + 1
                problems.append('%s:%d  %s.%s n\'existe pas'
                                % (f, line, cls, mm.group(1)))

    for path, enum in [('lib/services/audio_service.dart', 'SoundEffect'),
                       ('lib/services/audio_service.dart', 'BackgroundMusic'),
                       ('lib/data/official_curriculum.dart', 'LearningActivity'),
                       ('lib/models/mascot.dart', 'MascotMood')]:
        m = re.search(r'enum\s+%s\s*{([^}]*)}' % enum, read(path), re.S)
        if not m:
            continue
        vals = set(re.findall(r'\b(\w+)\b', m.group(1)))
        for f in dart_files():
            s = read(f)
            for mm in re.finditer(r'\b%s\.(\w+)' % enum, s):
                if mm.group(1) in vals or mm.group(1) in ('values', 'name', 'index'):
                    continue
                line = s[:mm.start()].count('\n') + 1
                problems.append('%s:%d  %s.%s n\'existe pas'
                                % (f, line, enum, mm.group(1)))


def check_problems_arithmetic():
    """Chaque étape de mission-problème doit tomber juste."""
    src = read('lib/data/problem_missions_data.dart')
    steps = re.findall(
        r'operation:\s*ProblemOp\.(\w+),\s*\n\s*a:\s*(\d+),\s*b:\s*(\d+),'
        r'\s*result:\s*(\d+),\s*\n\s*choices:\s*\[([^\]]*)\]', src)
    notes.append('%d étapes de problème vérifiées' % len(steps))
    for op, a, b, res, choices in steps:
        a, b, res = int(a), int(b), int(res)
        expected = {'ajouter': a + b, 'retirer': a - b,
                    'partager': a // b if b else None, 'comparer': a - b}[op]
        if op == 'partager' and b and a % b:
            problems.append('problème : %d ÷ %d ne tombe pas juste' % (a, b))
        if expected != res:
            problems.append('problème : %d %s %d donne %d, pas %d'
                            % (a, op, b, expected, res))
        opts = [int(x) for x in re.findall(r'\d+', choices)]
        if res not in opts:
            problems.append('problème : résultat %d absent des choix %s' % (res, opts))
        if len(set(opts)) != len(opts):
            problems.append('problème : doublon dans les choix %s' % opts)


def check_dictee():
    """La concaténation des blocs doit redonner le mot."""
    words = re.findall(r"word:\s*'([^']+)',\s*\n\s*blocks:\s*\[([^\]]*)\]",
                       read('lib/data/dictee_image_data.dart'))
    notes.append('%d mots de dictée vérifiés' % len(words))
    for word, blocks in words:
        joined = ''.join(re.findall(r"'([^']*)'", blocks))
        if joined != word:
            problems.append("dictée : « %s » se recompose en « %s »" % (word, joined))


def check_market():
    """Une cible du Marché doit être une somme exacte des jetons."""
    src = read('lib/data/market_missions.dart')
    sets = {n: [int(x) for x in re.findall(r'\d+', b)]
            for n, b in re.findall(
                r'static const List<int> (_\w+) = \[([^\]]*)\];', src)}

    def reachable(target, tokens):
        ok = [False] * (target + 1)
        ok[0] = True
        for v in range(1, target + 1):
            ok[v] = any(t <= v and ok[v - t] for t in tokens)
        return ok[target]

    blocks = re.split(r'\n    MarketMission\(', src)[1:]
    notes.append('%d missions du Marché vérifiées' % len(blocks))
    for b in blocks:
        mid = re.search(r"id:\s*'([^']+)'", b)
        mid = mid.group(1) if mid else '?'
        target = re.search(r'target:\s*(\d+)', b)
        toks = re.search(r'tokens:\s*(\w+)', b)
        if not target or not toks or toks.group(1) not in sets:
            problems.append('%s : cible ou jetons manquants' % mid)
            continue
        if not reachable(int(target.group(1)), sets[toks.group(1)]):
            problems.append('%s : cible %s IMPOSSIBLE avec %s'
                            % (mid, target.group(1), sets[toks.group(1)]))


def check_map():
    """Les lieux de départ et d'arrivée doivent exister sur le plan."""
    src = read('lib/data/map_missions.dart')
    plans = {}
    for name, body in re.findall(
            r'static const List<MapPlace> (_\w+) = \[(.*?)\n  \];', src, re.S):
        plans[name] = re.findall(
            r"col:\s*(\d+),\s*row:\s*(\d+),\s*emoji:\s*'[^']*',"
            r"\s*label:\s*'((?:[^'\\]|\\.)*)'", body)

    for name, places in plans.items():
        cells = [(c, r) for c, r, _ in places]
        if len(set(cells)) != len(cells):
            problems.append('%s : deux lieux sur la même case' % name)

    missions = re.split(r'\n    MapMission\(', src)[1:]
    notes.append('%d missions de Carte vérifiées' % len(missions))
    for m in missions:
        mid = re.search(r"id:\s*'([^']+)'", m)
        mid = mid.group(1) if mid else '?'
        plan = re.search(r'places:\s*(_\w+)', m)
        if not plan or plan.group(1) not in plans:
            problems.append('%s : plan inconnu' % mid)
            continue
        labels = [l for _, _, l in plans[plan.group(1)]]
        cols = int(re.search(r'cols:\s*(\d+)', m).group(1))
        rows = int(re.search(r'rows:\s*(\d+)', m).group(1))
        for key in ['startLabel', 'targetLabel']:
            v = re.search(r"%s:\s*'((?:[^'\\]|\\.)*)'" % key, m)
            if v and v.group(1) not in labels:
                problems.append("%s : %s « %s » absent du plan"
                                % (mid, key, v.group(1)))
        for c, r, l in plans[plan.group(1)]:
            if not (0 <= int(c) < cols and 0 <= int(r) < rows):
                problems.append('%s : « %s » hors du quadrillage' % (mid, l))


def check_stages():
    """Chaque compétence doit exister dans les trois étapes, sinon la
    difficulté adaptative n'a rien à proposer."""
    stage_src = read('lib/utils/adaptive_difficulty.dart')
    declared = re.findall(r"MissionStage\.\w+ => '([^']+)'", stage_src)[:3]
    if sorted(declared) != sorted(LABELS):
        problems.append('les libellés de MissionStage ont changé : %s' % declared)

    per = {}
    for f in glob.glob('lib/data/*.dart'):
        for comp, mtype in re.findall(
                r"competence:\s*'([^']+)',\s*\n\s*missionType:\s*'([^']+)'", read(f)):
            per.setdefault(comp, set()).add(mtype)
    notes.append('%d compétences avec missions étagées' % len(per))
    for comp, have in sorted(per.items()):
        missing = [l for l in LABELS if l not in have]
        if missing:
            problems.append('%s : étape(s) manquante(s) -> %s'
                            % (comp, ', '.join(missing)))


def check_curriculum():
    """Chaque étape du parcours doit avoir du contenu, et inversement."""
    data = {}
    for act, path in [('numberBars', 'number_bars_missions'),
                      ('dictee', 'dictee_image_data'),
                      ('sentence', 'sentence_workshop_data'),
                      ('problem', 'problem_missions_data'),
                      ('tale', 'tales_data'),
                      ('market', 'market_missions'),
                      ('treasureMap', 'map_missions')]:
        data[act] = set(re.findall(r"competence:\s*'([^']+)'",
                                   read('lib/data/%s.dart' % path)))

    src = read('lib/data/official_curriculum.dart')
    entries = re.findall(
        r"Competence\(\s*id:\s*'([^']+)',.*?activity:\s*LearningActivity\.(\w+),",
        src, re.S)
    notes.append('%d étapes déclarées dans le parcours' % len(entries))

    ids = [c for c, _ in entries]
    for d in sorted(set(i for i in ids if ids.count(i) > 1)):
        problems.append('parcours : compétence dupliquée -> %s' % d)

    for cid, act in entries:
        if act in data and cid not in data[act]:
            problems.append('parcours : « %s » n\'a aucun contenu %s '
                            '(repli silencieux sur tout le niveau)' % (cid, act))

    used = set(ids)
    for act, comps in sorted(data.items()):
        orphan = sorted(c for c in comps if c not in used)
        if orphan:
            problems.append('%s : contenu inatteignable depuis le parcours -> %s'
                            % (act, ', '.join(orphan)))

    n = src.count('LearningActivity.comingSoon,')
    notes.append('%d étape(s) encore « Bientôt disponible »' % n)


def check_placeholders():
    """Un marqueur non remplacé resterait affiché tel quel."""
    handled = set(re.findall(
        r"replaceAll\('\{(\w+)\}'",
        read('lib/screens/story/story_factory_screen.dart')))
    used = set(re.findall(r'\{(\w+)\}', read('lib/data/story_factory_data.dart')))
    for m in sorted(used - handled):
        problems.append('Fabrique : le marqueur {%s} n\'est jamais remplacé' % m)


def check_theatre():
    """La dernière question de chaque scène doit rester ouverte."""
    src = read('lib/data/theatre_scenes.dart')
    scenes = re.split(r'\n    TheatreScene\(', src)[1:]
    notes.append('%d scènes de Théâtre vérifiées' % len(scenes))
    for sc in scenes:
        sid = re.search(r"id:\s*'([^']+)'", sc)
        sid = sid.group(1) if sid else '?'
        questions = re.split(r'\n        TheatreQuestion\(', sc)[1:]
        for i, q in enumerate(questions):
            labels = re.findall(r"label:\s*'((?:[^'\\]|\\.)*)'", q)
            best = re.search(r"bestAnswer:\s*'((?:[^'\\]|\\.)*)'", q)
            responses = len(re.findall(r'response:', q))
            if responses != len(labels):
                problems.append('%s q%d : %d réponses pour %d choix'
                                % (sid, i + 1, responses, len(labels)))
            if i == len(questions) - 1:
                if best:
                    problems.append('%s : la question finale doit rester ouverte'
                                    % sid)
            elif not best:
                problems.append('%s q%d : pas de bestAnswer' % (sid, i + 1))
            elif best.group(1) not in labels:
                problems.append("%s q%d : bestAnswer absente des choix"
                                % (sid, i + 1))


def check_shuffled_choices():
    """Les écrans à choix doivent mélanger les propositions à l'affichage.

    Les données sont rédigées avec la bonne réponse en premier — c'est
    plus simple à écrire et à relire. Mesuré une fois : 143 questions,
    bonne réponse en position 1 dans 85 % des cas, 100 % pour trois jeux
    de données. Sans mélange, il suffit de toucher le premier bouton, et
    le suivi parental affiche « terminée sans aide » pour rien.

    On vérifie donc que chaque écran affichant des propositions passe par
    Shuffled, plutôt que de vérifier l'ordre dans les données.
    """
    ecrans = [
        'lib/widgets/exercise_card.dart',
        'lib/screens/arcade_game_screen.dart',
        'lib/screens/discovery_world_screen.dart',
        'lib/screens/french/phonetique_screen.dart',
        'lib/screens/games/flash_quiz_screen.dart',
        'lib/screens/games/problem_mission_screen.dart',
        'lib/screens/games/question_rain_screen.dart',
        'lib/screens/games/sentence_workshop_screen.dart',
        'lib/screens/games/weather_express_screen.dart',
        'lib/screens/story/tale_reader_screen.dart',
        'lib/screens/theatre/theatre_screen.dart',
    ]
    for f in ecrans:
        if not os.path.exists(f):
            problems.append('%s : écran à choix introuvable' % f)
            continue
        s = read(f)
        if 'Shuffled.of(' not in s:
            problems.append('%s : les propositions ne sont pas mélangées' % f)
        elif '_salt' not in s:
            problems.append('%s : Shuffled utilisé sans sel stable' % f)
    notes.append('%d écrans à choix vérifiés' % len(ecrans))

    # La phonétique vérifiait par indice : la comparaison doit passer par
    # la valeur, sinon le mélange rend toutes les réponses fausses.
    ph = read('lib/screens/french/phonetique_screen.dart')
    if 'index == exercise.correctIndex' in ph:
        problems.append('phonétique : réponse encore vérifiée par indice '
                        'alors que les options sont mélangées')

    # Mélanger une liste `const` lève une exception à l'exécution.
    for f in dart_files():
        s = read(f)
        for m in re.finditer(r'(\w+(?:Data)?\.\w+)\s*\)?\.\.shuffle\(\)', s):
            expr = m.group(1)
            ctx = s[max(0, m.start() - 120):m.start()]
            if 'List.of' in ctx or 'List.from' in ctx or 'toList()' in ctx:
                continue
            line = s[:m.start()].count('\n') + 1
            problems.append('%s:%d  shuffle() sur %s sans copie préalable '
                            '(liste const ?)' % (f, line, expr))


def check_sounds():
    """Les sons doivent rester courts, doux et non saturés.

    Les fichiers livrés au départ étaient des placeholders : tap.wav
    durait 1,75 s alors qu'il se déclenche à chaque appui, correct.wav
    saturait à 100 % de crête, countdown.wav sifflait à 5 100 Hz. Rien
    dans le dépôt ne le signalait — on ne peut pas écouter un WAV depuis
    un script de vérification, mais on peut le mesurer.

    Les limites ci-dessous sont celles que produit tool/make_sounds.py.
    """
    import wave
    import array as _array
    import math as _math

    # nom -> duree max en secondes
    limites = {
        'tap.wav': 0.12,           # à chaque appui : doit être un clic
        'countdown.wav': 0.20,
        'correct.wav': 0.60,
        'wrong.wav': 0.60,
        'star.wav': 0.60,
        'combo.wav': 0.70,
        'unlock.wav': 0.80,
        'level_up.wav': 0.90,
        'celebrate.wav': 1.20,
        'perfect.wav': 1.30,
    }
    CRETE_MAX = 0.70          # au-delà, on entre dans la saturation
    MUSIQUE_MIN = 20.0        # une boucle plus courte s'entend tourner

    d = 'assets/sounds'
    if not os.path.isdir(d):
        problems.append('assets/sounds introuvable')
        return

    verifies = 0
    for nom, dmax in sorted(limites.items()):
        p = os.path.join(d, nom)
        if not os.path.exists(p):
            problems.append('son manquant : %s' % nom)
            continue
        try:
            w = wave.open(p, 'rb')
            n, sr, sw = w.getnframes(), w.getframerate(), w.getsampwidth()
            raw = w.readframes(n)
            w.close()
        except Exception as e:
            problems.append('%s illisible (%s)' % (nom, e))
            continue
        dur = n / float(sr) if sr else 0
        if dur > dmax:
            problems.append('%s dure %.2fs (max %.2fs) — trop long'
                            % (nom, dur, dmax))
        if sw == 2 and raw:
            a = _array.array('h')
            a.frombytes(raw[:len(raw) // 2 * 2])
            if len(a):
                crete = max(abs(min(a)), abs(max(a))) / 32768.0
                if crete > CRETE_MAX:
                    problems.append('%s : crête à %.0f%% — saturation'
                                    % (nom, crete * 100))
        verifies += 1

    md = os.path.join(d, 'music')
    if os.path.isdir(md):
        for nom in sorted(os.listdir(md)):
            if not nom.endswith('.wav'):
                continue
            p = os.path.join(md, nom)
            try:
                w = wave.open(p, 'rb')
                dur = w.getnframes() / float(w.getframerate())
                w.close()
            except Exception as e:
                problems.append('%s illisible (%s)' % (nom, e))
                continue
            if dur < MUSIQUE_MIN:
                problems.append('musique %s : boucle de %.1fs (min %.0fs) — '
                                'la répétition s\'entend' % (nom, dur, MUSIQUE_MIN))
            verifies += 1

    notes.append('%d fichiers son vérifiés' % verifies)

    # Un son déclaré dans le code mais absent du dossier ne se voit qu'à
    # l'exécution, et le service échoue en silence.
    src = read('lib/services/audio_service.dart')
    for m in re.finditer(r"'(sounds/[^']+\.wav)'", src):
        rel = m.group(1)
        if not os.path.exists(os.path.join('assets', rel)):
            problems.append('audio_service référence %s, absent du dossier'
                            % rel)


CHECKS = [
    ('délimiteurs', check_braces),
    ('imports', check_imports),
    ('routes', check_routes),
    ('symboles', check_symbols),
    ('arithmétique des problèmes', check_problems_arithmetic),
    ('découpage des dictées', check_dictee),
    ('cibles du Marché', check_market),
    ('plans de la Carte', check_map),
    ('étapes par compétence', check_stages),
    ('couverture du parcours', check_curriculum),
    ('marqueurs de la Fabrique', check_placeholders),
    ('questions du Théâtre', check_theatre),
    ('mélange des propositions', check_shuffled_choices),
    ('sons', check_sounds),
]

if __name__ == '__main__':
    for name, fn in CHECKS:
        before = len(problems)
        try:
            fn()
        except Exception as e:
            problems.append('%s : le contrôle a échoué (%s)' % (name, e))
        mark = 'ok ' if len(problems) == before else 'KO '
        print('%s %s' % (mark, name))

    print()
    for n in notes:
        print('   %s' % n)

    print()
    if problems:
        print('%d PROBLÈME(S) :' % len(problems))
        for p in problems:
            print(' - %s' % p)
        sys.exit(1)
    print('Tout est cohérent.')
    sys.exit(0)
