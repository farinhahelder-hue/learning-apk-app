// === STATE ===
let stars = 0;
let badges = [];
let screen = 'home';
let xp = 0;
let level = 1;
let streak = 1;
let combo = 0;
let muted = false;

// === HOMEWORK STATE (NOUVEAU) ===
let homeworkState = {
  date: '',
  mathHomework: '',
  frenchHomework: '',
  completed: [],
  focusTimer: 25 * 60, // 25 minutes pomodoro
  timerActive: false,
  timerInterval: null,
  aiGenerating: false,
  aiExercises: []
};

// === LESSONS STATE (LEÇONS TDAH/AUTISME) ===
let lessonsState = {
  currentLevel: 'ce2', // 'ce1' ou 'ce2'
  currentSubject: 'math',
  currentLesson: null,
  lessonProgress: {},
  stepsCompleted: [],
  visualMode: true // Mode visuel pour TDAH
};

// === CE1 & CE2 PROGRAMS DATA (Programme officiel 2025) ===
const CE1_PROGRAM = {
  math: {
    name: '🔢 Maths CE1',
    color: '#3b82f6',
    skills: {
      'Nombres et numération': {
        icon: '🔢',
        lessons: [
          {
            id: 'ce1_num100', title: 'Les nombres jusqu\'à 100', duration: '10 min', steps: [
              { id: 's1', text: 'Les nombres de 0 à 20', visual: '0️⃣ 1️⃣ 2️⃣ 3️⃣ 4️⃣ 5️⃣ 6️⃣ 7️⃣ 8️⃣ 9️⃣ 🔟 1️⃣1️⃣ 1️⃣2️⃣...', tip: 'Compte sur tes doigts !' },
              { id: 's2', text: 'La dizaine = 10', visual: '🔟 + 🔟 + 🔟 = 30', tip: '3 dizaines = 30' },
              { id: 's3', text: 'Compter de 10 en 10', visual: '10 → 20 → 30 → 40 → 50 → 60 → 70 → 80 → 90 → 100', tip: '+10 à chaque fois !' },
              { id: 's4', text: 'Compter de 5 en 5', visual: '5 → 10 → 15 → 20 → 25 → 30...', tip: '+5 à chaque fois !' },
              { id: 's5', text: 'Comparer deux nombres', visual: '45 < 54\n45 est PLUS PETIT que 54', tip: 'Le plus petit < le plus grand' }
            ], exercises: [
              { q: '🔢 30 + 10 = ?', a: '40', hint: '3 dizaines + 1 dizaine = 4 dizaines' },
              { q: '🔢 Quel est le plus grand : 67 ou 76 ?', a: '76', hint: 'Compare les dizaines !' },
              { q: '🔢 Compte de 5 en 5 : 5, 10, 15, ... ?', a: '20', hint: '+5 à chaque fois' }
            ]
          },
          {
            id: 'ce1_num1000', title: 'Les nombres jusqu\'à 1000', duration: '12 min', steps: [
              { id: 's1', text: 'La centaines = 100', visual: '🔟🔟🔟🔟🔟🔟🔟🔟🔟🔟 = 100\nC\'est 10 dizaines !', tip: 'Une centaines = 100' },
              { id: 's2', text: 'Compter de 100 en 100', visual: '100 → 200 → 300 → 400 → 500 → 600 → 700 → 800 → 900 → 1000', tip: '+100 à chaque fois !' },
              { id: 's3', text: 'Décomposer un nombre', visual: '3️⃣5️⃣7️⃣ = 300 + 50 + 7\n3 centaines, 5 dizaines, 7 unités', tip: 'Sépare chaque partie !' },
              { id: 's4', text: 'Les nombres ordinaux', visual: '1️⃣er, 2️⃣e, 3️⃣e, 4️⃣e, 5️⃣e...\nPremier, deuxième, troisième...', tip: 'Pour indiquer un rang !' }
            ], exercises: [
              { q: '🔢 500 + 30 + 7 = ?', a: '537', hint: '5 centaines, 3 dizaines, 7 unités' },
              { q: '🔢 Dans 482, quel est le chiffre des dizaines ?', a: '8', hint: '8 est en position des dizaines' },
              { q: '🔢 Je suis le 1er → Je suis ___', a: 'premier', hint: '1er = premier' }
            ]
          }
        ]
      },
      'Calcul et opérations': {
        icon: '➕',
        lessons: [
          {
            id: 'ce1_add', title: 'L\'addition', duration: '10 min', steps: [
              { id: 's1', text: 'Qu\'est-ce que l\'addition ?', visual: 'J\'ai 3 pommes 🍎 + J\'en ai 2 autres 🍎 = J\'en ai 5 en tout 🍎🍎🍎🍎🍎', tip: 'On AJOUTE des choses !' },
              { id: 's2', text: 'Additionner avec les doigts', visual: '5 + 3 = ?\nLève 5 doigts 🖐️, ajoute 3 doigts 🖐️🖐️🖐️ = 8 doigts ✋✋✋✋', tip: 'Compte tous les doigts !' },
              { id: 's3', text: 'La table d\'addition du 10', visual: '0+10=10 | 1+9=10 | 2+8=10 | 3+7=10 | 4+6=10 | 5+5=10', tip: 'Tout fait 10 avec le bon ami !' },
              { id: 's4', text: 'Pose l\'addition (sans retenue)', visual: '  2️⃣3️⃣\n+ 1️⃣4️⃣\n─────\n  3️⃣7️⃣', tip: 'On additionne d\'abord les unités !' }
            ], exercises: [
              { q: '➕ 7 + 5 = ?', a: '12', hint: '7 + 3 = 10, puis +2 = 12' },
              { q: '➕ 15 + 4 = ?', a: '19', hint: '15 + 4 = 19' },
              { q: '➕ 8 + 8 = ?', a: '16', hint: 'Deux fois 8 = 16' }
            ]
          },
          {
            id: 'ce1_sous', title: 'La soustraction', duration: '10 min', steps: [
              { id: 's1', text: 'Qu\'est-ce que la soustraction ?', visual: 'J\'ai 8 bonbons 🍬, j\'en mange 3 🍬🍬🍬 = il m\'en reste 5 🍬🍬🍬🍬🍬', tip: 'On ENLÈVE des choses !' },
              { id: 's2', text: 'Soustraire avec les doigts', visual: '8 - 3 = ?\nLève 8 doigts, baisse 3 = il en reste 5 !', tip: 'Compte les doigts levés restants !' },
              { id: 's3', text: 'Les amis de 10', visual: '10-0=10 | 10-1=9 | 10-2=8 | 10-3=7 | 10-4=6 | 10-5=5', tip: 'Soustraire de 10, c\'est facile !' },
              { id: 's4', text: 'Pose la soustraction (sans retenue)', visual: '  3️⃣7️⃣\n- 1️⃣2️⃣\n─────\n  2️⃣5️⃣', tip: 'On soustrait d\'abord les unités !' }
            ], exercises: [
              { q: '➖ 9 - 4 = ?', a: '5', hint: '9 moins 4 = 5' },
              { q: '➖ 10 - 7 = ?', a: '3', hint: '10 moins 7 = 3' },
              { q: '➖ 15 - 5 = ?', a: '10', hint: 'La moitié de 15 !' }
            ]
          }
        ]
      },
      'Calcul mental': {
        icon: '🧮',
        lessons: [
          {
            id: 'ce1_complement10', title: 'Complements à 10', duration: '8 min', steps: [
              { id: 's1', text: 'Les amis de 10', visual: '🔟 = 0+10 = 1+9 = 2+8 = 3+7 = 4+6 = 5+5', tip: 'Chaque paire fait 10 !' },
              { id: 's2', text: 'Mémoriser les compléments', visual: 'Pour faire 10 :\n0 + 10 = 10\n1 + 9 = 10\n2 + 8 = 10\n3 + 7 = 10\n4 + 6 = 10\n5 + 5 = 10', tip: 'Connaître par cœur !' }
            ], exercises: [
              { q: '🧮 7 + ? = 10', a: '3', hint: '7 + 3 = 10' },
              { q: '🧮 4 + ? = 10', a: '6', hint: '4 + 6 = 10' },
              { q: '🧮 8 + ? = 10', a: '2', hint: '8 + 2 = 10' }
            ]
          },
          {
            id: 'ce1_tables', title: 'Tables de multiplication', duration: '12 min', steps: [
              { id: 's1', text: 'La table de 2', visual: '2×1=2 | 2×2=4 | 2×3=6 | 2×4=8 | 2×5=10\n2×6=12 | 2×7=14 | 2×8=16 | 2×9=18 | 2×10=20', tip: 'Ça double !' },
              { id: 's2', text: 'La table de 3', visual: '3×1=3 | 3×2=6 | 3×3=9 | 3×4=12 | 3×5=15\n3×6=18 | 3×7=21 | 3×8=24 | 3×9=27 | 3×10=30', tip: '3 en plus à chaque fois !' },
              { id: 's3', text: 'La table de 4', visual: '4×1=4 | 4×2=8 | 4×3=12 | 4×4=16 | 4×5=20\n4×6=24 | 4×7=28 | 4×8=32 | 4×9=36 | 4×10=40', tip: 'C\'est le double de la table de 2 !' },
              { id: 's4', text: 'La table de 5', visual: '5×1=5 | 5×2=10 | 5×3=15 | 5×4=20 | 5×5=25\n5×6=30 | 5×7=35 | 5×8=40 | 5×9=45 | 5×10=50', tip: 'Ça finit toujours par 0 ou 5 !' }
            ], exercises: [
              { q: '✖️ 3 × 4 = ?', a: '12', hint: '3 × 4 = 12' },
              { q: '✖️ 5 × 5 = ?', a: '25', hint: '5 × 5 = 25' },
              { q: '✖️ 2 × 9 = ?', a: '18', hint: 'Le double de 9 = 18' }
            ]
          }
        ]
      },
      'Grandeurs et mesures': {
        icon: '📏',
        lessons: [
          {
            id: 'ce1_longueur', title: 'Les longueurs', duration: '10 min', steps: [
              { id: 's1', text: 'Le mètre (m)', visual: '📏 Le mètre = 100 centimètres\n\n1 m = 100 cm', tip: 'Pour mesurer des grandes choses' },
              { id: 's2', text: 'Le centimètre (cm)', visual: '✏️ Le centimètre\n\n1 cm = petit bout de doigt\n10 cm = 1 décimètre = paume', tip: 'Pour mesurer des petites choses' },
              { id: 's3', text: 'Le kilomètre (km)', visual: '🏃 1 km = 1000 mètres\n\nC\'est très loin !\nComme 10 terrains de foot !', tip: 'Pour les grandes distances' }
            ], exercises: [
              { q: '📏 1 m = ? cm', a: '100', hint: '1 mètre = 100 centimètres' },
              { q: '📏 2 m = ? cm', a: '200', hint: '2 mètres = 200 centimètres' },
              { q: '📏 1 km = ? m', a: '1000', hint: '1 kilomètre = 1000 mètres' }
            ]
          },
          {
            id: 'ce1_monnaie', title: 'La monnaie', duration: '10 min', steps: [
              { id: 's1', text: 'Les pièces', visual: '1 centime 🪙 | 2 centimes | 5 centimes | 10 centimes\n20 centimes | 50 centimes | 1 euro 💰 | 2 euros', tip: 'Il faut savoir compter les sous !' },
              { id: 's2', text: 'Les billets', visual: '5€ 💵 | 10€ | 20€ | 50€ | 100€ | 200€', tip: 'Les gros montants' },
              { id: 's3', text: 'Rendre la monnaie', visual: 'Je donne 10€ pour un jouet à 7€\nOn me rend : 10 - 7 = 3€\n💰 3 euros', tip: 'On soustrait !' }
            ], exercises: [
              { q: '💰 5 + 2 + 1 = ? euros', a: '8', hint: '5 + 2 + 1 = 8' },
              { q: '💰 J\'ai 10€, je dépense 6€. Il me reste ?', a: '4', hint: '10 - 6 = 4' },
              { q: '💰 20 centimes + 30 centimes = ? euros', a: '0.50', hint: '20 + 30 = 50 centimes = 0.50€' }
            ]
          }
        ]
      },
      'Espace et géométrie': {
        icon: '🔷',
        lessons: [
          {
            id: 'ce1_forme', title: 'Les formes', duration: '10 min', steps: [
              { id: 's1', text: 'Le carré', visual: '🔲 a 4 CÔTÉS égaux\n4 coins droits\nComme une boîte de Pizza 🍕', tip: '4 côtés = 4 !' },
              { id: 's2', text: 'Le triangle', visual: '🔺 a 3 CÔTÉS\n3 coins\nComme un chapeau de magicien 🎩', tip: '3 côtés = 3 !' },
              { id: 's3', text: 'Le cercle', visual: '⭕ n\'a pas de côté\nIl est ROND\nComme une roue 🚗', tip: 'Rond = cercle !' },
              { id: 's4', text: 'Le rectangle', visual: '▬ a 4 CÔTÉS\n2 longs, 2 courts\nComme une porte 🚪', tip: 'Comme le carré mais allongé !' }
            ], exercises: [
              { q: '🔷 Combien de côtés a un carré ?', a: '4', hint: '4 côtés égaux !' },
              { q: '🔷 Quel forme est ronde ?', a: 'cercle', hint: 'Sans côtés, tout rond !' },
              { q: '🔷 Le triangle a combien de côtés ?', a: '3', hint: '3 !' }
            ]
          },
          {
            id: 'ce1_quadrillage', title: 'Le quadrillage', duration: '8 min', steps: [
              { id: 's1', text: 'Se déplacer sur un quadrillage', visual: '⬆️ Haut | ⬇️ Bas | ⬅️ Gauche | ➡️ Droite\n\nCase (B,2) = colonne B, ligne 2', tip: 'On lit la colonne d\'abord !' },
              { id: 's2', text: 'Repérer un point', visual: '📊 Case C3 = colonne C, ligne 3\n\nLa case est entre les lignes !', tip: 'Colonne puis ligne !' }
            ], exercises: [
              { q: '📊 Quelle case est en colonne A, ligne 1 ?', a: 'A1', hint: 'Colonne A, Ligne 1' },
              { q: '📊 Case B2 : colonne ? ligne ?', a: 'B2', hint: 'Colonne B, Ligne 2' }
            ]
          }
        ]
      },
      'Fractions': {
        icon: '🍕',
        lessons: [
          {
            id: 'ce1_moitie', title: 'Les moitiés', duration: '8 min', steps: [
              { id: 's1', text: 'Qu\'est-ce qu\'une moitié ?', visual: '🍕 Je coupe en 2 parts égales\nChaque part = 1 moitié\n\n½ de 8 = 4', tip: 'Diviser par 2 !' },
              { id: 's2', text: 'Trouver la moitié', visual: '½ de 2 = 1\n½ de 4 = 2\n½ de 6 = 3\n½ de 8 = 4\n½ de 10 = 5', tip: '÷2 pour trouver la moitié !' }
            ], exercises: [
              { q: '🍕 La moitié de 6 = ?', a: '3', hint: '6 ÷ 2 = 3' },
              { q: '🍕 La moitié de 10 = ?', a: '5', hint: '10 ÷ 2 = 5' },
              { q: '🍕 La moitié de 8 = ?', a: '4', hint: '8 ÷ 2 = 4' }
            ]
          }
        ]
      }
    }
  },
  french: {
    name: '📖 Français CE1',
    color: '#ec4899',
    skills: {
      'Lecture': {
        icon: '📖',
        lessons: [
          {
            id: 'ce1_lire', title: 'Lire des mots', duration: '10 min', steps: [
              { id: 's1', text: 'Les mots simples', visual: '🔤 CHAT = C-H-A-T\n🐱 Animal qui fait "miaou"', tip: 'Chaque lettre fait un son !' },
              { id: 's2', text: 'Les syllabes', visual: 'MA → MI → NION\nMa-mion = MAMION ? Non ! MA-NI-ON = MANION', tip: 'Coupe en syllabes !' },
              { id: 's3', text: 'Compter les syllabes', visual: 'É-LE-PHANT = 3 syllabes 🐘\nSA-VON = 2 syllabes 🧼\nCHI-EN = 2 syllabes 🐕', tip: 'Compte les "bouches qui s\'ouvrent" !' }
            ], exercises: [
              { q: '📝 Combien de syllabes dans "CHIEN" ?', a: '1', hint: 'CHIEN = 1 seule syllabe' },
              { q: '📝 Combien dans "MAISON" ?', a: '2', hint: 'MAI-SON = 2 syllabes' },
              { q: '📝 Le mot "PAPILLON" a combien de syllabes ?', a: '3', hint: 'PA-PI-LLON = 3' }
            ]
          }
        ]
      },
      'Grammaire': {
        icon: '📚',
        lessons: [
          {
            id: 'ce1_phrase', title: 'La phrase', duration: '10 min', steps: [
              { id: 's1', text: 'Qu\'est-ce qu\'une phrase ?', visual: 'Une phrase = une idée complète\n\n🐱 Le chat dort.\n🦊 Le renard court.\n🌞 Le soleil brille.', tip: 'Ça commence par une majuscule et finit par un point !' },
              { id: 's2', text: 'Les types de phrases', visual: '📢 Phrase déclarative : "Il fait beau." (Le chat dort.)\n❓ Phrase interrogative : "As-tu faim ?" (?)\n❗ Phrase exclamative : "Quel beau chat !" (!)', tip: 'Le point final montre le type !' }
            ], exercises: [
              { q: '📚 "Le chien mange." Est-ce une phrase ?', a: 'oui', hint: 'Oui, elle a une majuscule et un point !' },
              { q: '📚 Quel signe pour "Viens ici" ?', a: '?', hint: 'Question = point d\'interrogation ?' }
            ]
          },
          {
            id: 'ce1_sujet_verbe', title: 'Sujet et verbe', duration: '12 min', steps: [
              { id: 's1', text: 'Le sujet', visual: '🐱 Le chat dort.\n   ↑\n   SUJET = Qui fait l\'action ?\n\n📝 Identifie le sujet : "Marie mange"\n   ↑\n   SUJET = Marie', tip: 'Qui est-ce qui...? La réponse = le sujet' },
              { id: 's2', text: 'Le verbe', visual: '🐱 Le chat dort.\n        ↑\n        VERBE = L\'action\n\n📝 Trouve le verbe : "Les enfants jouent"\n              ↑\n              VERBE = jouent', tip: 'C\'est ce que fait le sujet !' },
              { id: 's3', text: 'Ponctuation', visual: '. Point → phrase normale\n? Point d\'interrogation → question\n! Point d\'exclamation → surprise\n, Virgule → pause', tip: 'Chaque signe a un rôle !' }
            ], exercises: [
              { q: '📚 Dans "Le chien court", qui est le sujet ?', a: 'le chien', hint: 'Qui court ? Le chien !' },
              { q: '📚 Quel est le verbe : "Nous mangeons" ?', a: 'mangeons', hint: 'C\'est l\'action !' }
            ]
          }
        ]
      },
      'Conjugaison': {
        icon: '🔄',
        lessons: [
          {
            id: 'ce1_etre', title: 'Le verbe être', duration: '10 min', steps: [
              { id: 's1', text: 'Être au présent', visual: 'JE suis\nTU es\nIL/ELLE est\nNOUS sommes\nVOUS êtes\nILS/ELLES sont', tip: 'Suis, es, est, sommes, êtes, sont' },
              { id: 's2', text: 'Utiliser être', visual: 'Je suis content 😊\nTu es grand !\nIl est intelligent.\nNous sommes en classe.', tip: 'Être = avoir une qualité ou un état !' }
            ], exercises: [
              { q: '🔄 Je ___ (être)', a: 'suis', hint: 'JE SUIS' },
              { q: '🔄 Nous ___ (être)', a: 'sommes', hint: 'NOUS SOMMES' },
              { q: '🔄 Elles ___ gentilles (être)', a: 'sont', hint: 'ELLES SONT' }
            ]
          },
          {
            id: 'ce1_avoir', title: 'Le verbe avoir', duration: '10 min', steps: [
              { id: 's1', text: 'Avoir au présent', visual: 'J\'AI\nTU as\nIL/ELLE a\nNOUS avons\nVOUS avez\nILS/ELLES ont', tip: 'Ai, as, a, avons, avez, ont' },
              { id: 's2', text: 'Utiliser avoir', visual: 'J\'ai un chat 🐱\nTu as des livres 📚\nIl a faim 🍽️\nNous avons de la chance !', tip: 'Avoir = posséder quelque chose !' }
            ], exercises: [
              { q: '🔄 Tu ___ (avoir)', a: 'as', hint: 'TU AS' },
              { q: '🔄 Nous ___ (avoir)', a: 'avons', hint: 'NOUS AVONS' },
              { q: '🔄 Elle ___ un chien (avoir)', a: 'a', hint: 'ELLE A' }
            ]
          },
          {
            id: 'ce1_groupe', title: 'Verbes en -ER', duration: '12 min', steps: [
              { id: 's1', text: 'Les verbes en -ER', visual: 'PARLER → Je parl-E\nJOUER → Je jou-E\nMANGER → Je mang-E\n\nOn enlève -ER et on ajoute la terminaison !', tip: '-ER = 1er groupe' },
              { id: 's2', text: 'Conjuguer -ER au présent', visual: 'PARLER :\nJe parl-E\nTu parl-ES\nIL parl-E\nNOUS parl-ONS\nVOUS parl-EZ\nILS parl-ENT', tip: '-E, -ES, -E, -ONS, -EZ, -ENT' }
            ], exercises: [
              { q: '🔄 Je ___ (manger)', a: 'mange', hint: 'Je mang-E' },
              { q: '🔄 Nous ___ (jouer)', a: 'jouons', hint: 'Nous jou-ONS' },
              { q: '🔄 Ils ___ (chanter)', a: 'chantent', hint: 'Verbe en -ER : -ENT au pluriel' }
            ]
          }
        ]
      },
      'Orthographe': {
        icon: '✏️',
        lessons: [
          {
            id: 'ce1_accords', title: 'Les accords dans le GN', duration: '12 min', steps: [
              { id: 's1', text: 'Le groupe nominal (GN)', visual: '🐱 le petit chat\n↑déterminant nom\n   ↑     ↑\n  petit  chat = nom\n\nLe déterminant s\'accorde avec le nom !', tip: 'GN = qui ? quoi ?' },
              { id: 's2', text: 'Accord au singulier et pluriel', visual: 'le chat → les chats\nla fleur → les fleurs\nl\'arbre → les arbres', tip: 'Le → Les quand il y a plusieurs !' }
            ], exercises: [
              { q: '✏️ "les chat" → correct ?', a: 'non', hint: 'les chats (masculin pluriel)' },
              { q: '✏️ "la petite fille" au pluriel', a: 'les petites filles', hint: 'Le → Les, petite → petites' }
            ]
          },
          {
            id: 'ce1_homophones', title: 'Premiers homophones', duration: '10 min', steps: [
              { id: 's1', text: 'a / à', visual: '❓ a = le verbe avoir conjugué\n"Il a un chat." (= il possède)\n\n❓ à = préposition (vers, chez)\n"Je vais à l\'école."', tip: 'a = avoir, à = direction !' },
              { id: 's2', text: 'et / est', visual: '❓ et = pour ajouter (ET = +)\n"Le chat ET le chien jouent."\n\n❓ est = le verbe être conjugué\n"Il est gentil."', tip: 'ET pour ajouter, EST pour être !' }
            ], exercises: [
              { q: '✏️ "Il ___ un chat." (avoir)', a: 'a', hint: 'a = avoir' },
              { q: '✏️ "Je vais ___ l\'école."', a: 'à', hint: 'à = direction' },
              { q: '✏️ "Il ___ grand ET beau."', a: 'est', hint: 'est = verbe être' }
            ]
          }
        ]
      },
      'Vocabulaire': {
        icon: '📝',
        lessons: [
          {
            id: 'ce1_famille', title: 'Familles de mots', duration: '10 min', steps: [
              { id: 's1', text: 'Qu\'est-ce qu\'une famille de mots ?', visual: '🌳 ARBRE → arbres, boisé, forestier\n🌸 FLEUR → fleuri, fleurette, fleurir\n🐦 OISEAU → oiseaux, oisillon\n\nMême RACINE = même FAMILLE !', tip: 'Cherche le lien entre les mots !' },
              { id: 's2', text: 'Trouver la racine', visual: 'FORÊT 🌳 → FORESTIER 🌲 → DÉFORESTATION 🪓\n\nFORÊT = la racine commune !', tip: 'Le mot le plus simple est souvent la racine !' }
            ], exercises: [
              { q: '📝 "cheval, chevalier, chevaux" → racine ?', a: 'cheval', hint: 'Cheval est la base !' },
              { q: '📝 "maison, maisonnette, ménage" → racine ?', a: 'maison', hint: 'Maison est la base !' }
            ]
          },
          {
            id: 'ce1_synonyme', title: 'Synonymes et antonymes', duration: '10 min', steps: [
              { id: 's1', text: 'Les synonymes', visual: 'Synonyme = même sens 🔄\n\nGRAND ≠ BON ≠ PETIT ≠ MAUVAIS\n\n"grand" = "haut" = "énorme"\n"petit" = "minuscule" = "petit" ', tip: 'Des mots qui veulent dire la même chose !' },
              { id: 's2', text: 'Les antonymes', visual: 'Antonyme = sens inverse ↔️\n\nGRAND ↔️ PETIT\nBON ↔️ MAUVAIS\nCHAUD ↔️ FROID\nHAUT ↔️ BAS', tip: 'Des mots opposites !' }
            ], exercises: [
              { q: '📝 Synonyme de "malade"', a: 'malade', hint: 'Synonyme : souffrant, pas bien' },
              { q: '📝 Antonyme de "grand"', a: 'petit', hint: 'Grand ↔️ Petit' }
            ]
          }
        ]
      }
    }
  }
};

const CE2_PROGRAM = {
  math: {
    name: '🔢 Maths CE2',
    color: '#8b5cf6',
    skills: {
      'Nombres et numération': {
        icon: '🔢',
        lessons: [
          {
            id: 'ce2_num10000', title: 'Les nombres jusqu\'à 10 000', duration: '12 min', steps: [
              { id: 's1', text: 'Les milliers', visual: '1️⃣0️⃣0️⃣0️⃣ = UN MILLIER\nC\'est comme 10 centaines !\n\n1 millier = 1000', tip: 'Mille = 1000' },
              { id: 's2', text: 'Décomposer un nombre', visual: '3️⃣2️⃣5️⃣4️⃣\n= 3 milliers + 2 centaines + 5 dizaines + 4 unités\n= 3000 + 200 + 50 + 4', tip: 'Sépare chaque partie !' },
              { id: 's3', text: 'Le tableau de numération', visual: ' Milliers | C | D | U\n    3    | 2 | 5 | 4\n\nC = Centaines, D = Dizaines, U = Unités', tip: 'Chaque colonne a sa valeur !' },
              { id: 's4', text: 'Comparer les nombres', visual: '4️⃣5️⃣2️⃣ < 4️⃣5️⃣3️⃣\n↑       ↑\nMême    2 < 3\nmilliers et    donc PLUS PETIT\ncentaines', tip: 'Compare de gauche à droite !' },
              { id: 's5', text: 'Encadrer un nombre', visual: '2️⃣5️⃣0️⃣0️⃣ < 2️⃣5️⃣8️⃣0️⃣ < 2️⃣6️⃣0️⃣0️⃣\n   ↓            ↓\n   2500        2600\nEntre 2 centaines !', tip: 'Trouve les voisins !' }
            ], exercises: [
              { q: '🔢 2 000 + 300 + 40 + 5 = ?', a: '2345', hint: '2 milliers, 3 centaines, 4 dizaines, 5 unités' },
              { q: '🔢 Dans 4 738, quel est le chiffre des centaines ?', a: '7', hint: '7 est en position des centaines' },
              { q: '🔢 Compare : 3 456 ___ 3 465', a: '<', hint: '56 < 65' }
            ]
          }
        ]
      },
      'Calcul et opérations': {
        icon: '➕',
        lessons: [
          {
            id: 'ce2_add', title: 'Addition posée', duration: '10 min', steps: [
              { id: 's1', text: 'Addition avec retenue', visual: '    4️⃣7️⃣\n+ 2️⃣8️⃣\n─────\n  1️⃣7️⃣5️⃣\n\n7+8=15, on écrit 5 et on retient 1 !', tip: 'Les retenues sont importantes !' },
              { id: 's2', text: 'Addition de nombres plus grands', visual: '  3️⃣4️⃣7️⃣\n+ 1️⃣2️⃣8️⃣\n───────\n  4️⃣7️⃣5️⃣', tip: 'On additionne de droite à gauche !' }
            ], exercises: [
              { q: '➕ 47 + 28 = ?', a: '75', hint: '47 + 28 = 75' },
              { q: '➕ 156 + 78 = ?', a: '234', hint: '156 + 78 = 234' }
            ]
          },
          {
            id: 'ce2_mult', title: 'La multiplication', duration: '12 min', steps: [
              { id: 's1', text: 'Qu\'est-ce que la multiplication ?', visual: '3️⃣ × 4️⃣ = 3 groupes de 4\n🍎🍎🍎🍎 + 🍎🍎🍎🍎 + 🍎🍎🍎🍎 = 12 🍎', tip: 'C\'est une addition répétée !' },
              { id: 's2', text: 'La table de 6', visual: '6×1=6 | 6×2=12 | 6×3=18 | 6×4=24 | 6×5=30\n6×6=36 | 6×7=42 | 6×8=48 | 6×9=54 | 6×10=60', tip: '6 en plus à chaque fois !' },
              { id: 's3', text: 'La table de 7', visual: '7×1=7 | 7×2=14 | 7×3=21 | 7×4=28 | 7×5=35\n7×6=42 | 7×7=49 | 7×8=56 | 7×9=63 | 7×10=70', tip: 'C\'est la plus difficile !' },
              { id: 's4', text: 'Multiplication en colonnes', visual: '    3️⃣2️⃣\n  ×     4️⃣\n  ──────\n  1️⃣2️⃣8️⃣\n(2×4=8, 3×4=12)', tip: 'On multiplie chaque chiffre !' }
            ], exercises: [
              { q: '✖️ 7 × 3 = ?', a: '21', hint: '7+7+7 = 21' },
              { q: '✖️ 6 × 4 = ?', a: '24', hint: '6+6+6+6 = 24' },
              { q: '✖️ 9 × 5 = ?', a: '45', hint: '9+9+9+9+9 = 45' }
            ]
          },
          {
            id: 'ce2_div', title: 'La division (partager)', duration: '12 min', steps: [
              { id: 's1', text: 'Qu\'est-ce que la division ?', visual: '🔴🔴🔴🔴 | 2 = On partage 4 billes en 2 parts égales\n= 2 billes par part\n🔴🔴 | 🔴🔴', tip: 'Partager en parts égales !' },
              { id: 's2', text: 'Le vocabulaire', visual: '1️⃣2️⃣ ÷ 3️⃣ = 4️⃣\nDividende | Diviseur | Quotient', tip: 'Dividende ÷ Diviseur = Quotient' },
              { id: 's3', text: 'Trouver la moitié', visual: 'La moitié de 10 = 10 ÷ 2 = 5\n½ de 10 = 5 ✅', tip: 'Diviser par 2 = trouver la moitié !' },
              { id: 's4', text: 'Division en ligne', visual: '24 ÷ 4 = 6\n\n4 × 6 = 24\ndonc 24 ÷ 4 = 6', tip: 'Trouve quelle multiplication donne le dividende !' }
            ], exercises: [
              { q: '➗ 8 ÷ 2 = ?', a: '4', hint: 'La moitié de 8' },
              { q: '➗ 15 ÷ 3 = ?', a: '5', hint: '3 × 5 = 15' },
              { q: '➗ 20 ÷ 4 = ?', a: '5', hint: '4 × 5 = 20' }
            ]
          }
        ]
      },
      'Calcul mental': {
        icon: '🧮',
        lessons: [
          {
            id: 'ce2_tables', title: 'Toutes les tables', duration: '15 min', steps: [
              { id: 's1', text: 'Rappels : tables de 2 à 5', visual: 'Table de 2 : 2, 4, 6, 8, 10, 12, 14, 16, 18, 20\nTable de 3 : 3, 6, 9, 12, 15, 18, 21, 24, 27, 30\nTable de 4 : 4, 8, 12, 16, 20, 24, 28, 32, 36, 40\nTable de 5 : 5, 10, 15, 20, 25, 30, 35, 40, 45, 50', tip: 'Révise les bases !' },
              { id: 's2', text: 'Tables de 6, 7, 8, 9', visual: 'Table de 6 : 6, 12, 18, 24, 30, 36, 42, 48, 54, 60\nTable de 7 : 7, 14, 21, 28, 35, 42, 49, 56, 63, 70\nTable de 8 : 8, 16, 24, 32, 40, 48, 56, 64, 72, 80\nTable de 9 : 9, 18, 27, 36, 45, 54, 63, 72, 81, 90', tip: '9 × un chiffre = 10× - le chiffre !' }
            ], exercises: [
              { q: '🧮 6 × 7 = ?', a: '42', hint: '6 × 7 = 42' },
              { q: '🧮 8 × 9 = ?', a: '72', hint: '8 × 9 = 72' },
              { q: '🧮 7 × 8 = ?', a: '56', hint: '7 × 8 = 56' }
            ]
          }
        ]
      },
      'Grandeurs et mesures': {
        icon: '📏',
        lessons: [
          {
            id: 'ce2_perimetre', title: 'Le périmètre', duration: '10 min', steps: [
              { id: 's1', text: 'Qu\'est-ce que le périmètre ?', visual: 'Périmètre = MESURER TOUT LE TOUR\n\n🔲 Carré : côté + côté + côté + côté\nP = 4 × côté', tip: 'On fait le tour de la figure !' },
              { id: 's2', text: 'Périmètre du carré', visual: '🔲 Carré de 3 cm de côté\n\nP = 3 + 3 + 3 + 3 = 12 cm\nou P = 4 × 3 = 12 cm', tip: '4 × côté = périmètre du carré !' },
              { id: 's3', text: 'Périmètre du rectangle', visual: '▬ Rectangle : L + l + L + l\nP = 2 × (L + l)\n\n▬ Rectangle 6 cm × 4 cm\nP = 2 × (6 + 4) = 20 cm', tip: '2 × (Longueur + Largeur) !' }
            ], exercises: [
              { q: '📏 Périmètre d\'un carré de 5 cm : ?', a: '20', hint: '4 × 5 = 20 cm' },
              { q: '📏 Périmètre d\'un carré de 8 cm : ?', a: '32', hint: '4 × 8 = 32 cm' }
            ]
          },
          {
            id: 'ce2_mesures', title: 'Unités de mesure', duration: '12 min', steps: [
              { id: 's1', text: 'Les longueurs', visual: 'km → hm → dam → m → dm → cm → mm\n\n1 km = 1000 m\n1 m = 100 cm\n1 cm = 10 mm', tip: 'Chaque étape = ÷10 ou ×10 !' },
              { id: 's2', text: 'Les masses', visual: 't → q → kg → hg → dag → g\n\n1 tonne = 1000 kg\n1 kg = 1000 g', tip: '1 kg = 2 packets de sucre !' },
              { id: 's3', text: 'Les contenances', visual: 'L → dL → cL → mL\n\n1 L = 100 cL\n1 L = 1000 mL', tip: 'Litre = pour les liquides !' }
            ], exercises: [
              { q: '📏 1 m = ? cm', a: '100', hint: '1 m = 100 cm' },
              { q: '📏 1 kg = ? g', a: '1000', hint: '1 kg = 1000 g' },
              { q: '📏 1 L = ? cL', a: '100', hint: '1 L = 100 cL' }
            ]
          }
        ]
      },
      'Espace et géométrie': {
        icon: '🔷',
        lessons: [
          {
            id: 'ce2_angle', title: 'Les angles', duration: '12 min', steps: [
              { id: 's1', text: 'L\'angle droit', visual: '📐 Angle droit = comme une équerre\n\nLes côtés sont PERPENDICULAIRES\n↗️ ↘️\n   ↘️ ↙️\n(Forme en L)', tip: 'Utilise une équerre pour vérifier !' },
              { id: 's2', text: 'Angle aigu et obtus', visual: '🔺 Angle AIGU < 90° (plus petit que droit)\n🔻 Angle OBTUS > 90° (plus grand que droit)', tip: 'Compare à l\'angle droit !' }
            ], exercises: [
              { q: '🔷 Un angle de 45° est : aigu ou obtus ?', a: 'aigu', hint: '45° < 90° = angle aigu' },
              { q: '🔷 Un angle de 120° est : aigu ou obtus ?', a: 'obtus', hint: '120° > 90° = angle obtus' }
            ]
          },
          {
            id: 'ce2_losange', title: 'Le losange', duration: '10 min', steps: [
              { id: 's1', text: 'Propriétés du losange', visual: '💎 Losange = 4 côtés ÉGAUX\n\n⚠️ Mais PAS d\'angles droits !\n\nComme un carré penché / un diamant 💎', tip: '4 côtés égaux = losange !' },
              { id: 's2', text: 'Losange vs Carré', visual: '🔲 Carré : 4 côtés égaux + 4 angles droits\n💎 Losange : 4 côtés égaux + PAS d\'angles droits', tip: 'Le carré est un losange spécial !' }
            ], exercises: [
              { q: '🔷 Le losange a combien de côtés égaux ?', a: '4', hint: '4 côtés égaux !' },
              { q: '🔷 Le losange a-t-il des angles droits ?', a: 'non', hint: 'Non, c\'est la différence avec le carré !' }
            ]
          }
        ]
      },
      'Fractions': {
        icon: '🍕',
        lessons: [
          {
            id: 'ce2_fractions', title: 'Les fractions', duration: '12 min', steps: [
              { id: 's1', text: 'Qu\'est-ce qu\'une fraction ?', visual: '🍕 Fraction = part d\'un tout\n\n1/2 = une moitié = 2 parts égales, j\'en prends 1\n1/4 = un quart = 4 parts égales, j\'en prends 1', tip: 'Le BAS = en combien on divise\nLe HAUT = combien on prend !' },
              { id: 's2', text: 'Fractions courantes', visual: '1/2 = une moitié\n1/4 = un quart\n3/4 = trois quarts\n1/3 = un tiers\n2/3 = deux tiers', tip: 'Mémorise ces fractions !' }
            ], exercises: [
              { q: '🍕 1/2 de 8 = ?', a: '4', hint: '8 ÷ 2 = 4' },
              { q: '🍕 1/4 de 12 = ?', a: '3', hint: '12 ÷ 4 = 3' },
              { q: '🍕 3/4 de 8 = ?', a: '6', hint: '8 ÷ 4 = 2, puis × 3 = 6' }
            ]
          }
        ]
      }
    }
  },
  french: {
    name: '📖 Français CE2',
    color: '#f43f5e',
    skills: {
      'Lecture et compréhension': {
        icon: '📖',
        lessons: [
          {
            id: 'ce2_comprendre', title: 'Comprendre un texte', duration: '15 min', steps: [
              { id: 's1', text: 'Lire et comprendre', visual: '📖 Pour bien comprendre un texte :\n\n1. Lis une première fois\n2. Cherche les mots difficiles\n3. Relis pour comprendre\n4. Raconte avec tes mots', tip: 'Comprendre = savoir expliquer !' },
              { id: 's2', text: 'Les questions de compréhension', visual: '❓ QUI ? → la personne\n❓ QUOI ? → l\'action\n❓ OÙ ? → le lieu\n❓ QUAND ? → le moment\n❓ COMMENT ? → la manière', tip: 'Ces mots t\'aident à trouver les réponses !' }
            ], exercises: [
              { q: '📖 "Qui" Demande quoi ?', a: 'une personne', hint: 'Qui = quelle personne ?' },
              { q: '📖 "Où" Demande quoi ?', a: 'un lieu', hint: 'Où = quel endroit ?' }
            ]
          }
        ]
      },
      'Grammaire': {
        icon: '📚',
        lessons: [
          {
            id: 'ce2_nature', title: 'Nature des mots', duration: '15 min', steps: [
              { id: 's1', text: 'Les natures de mots', visual: '📝 Nom = chose, animal, personne\n🐱 chat, 🏠 maison, 👧 Marie\n\n📝 Verbe = action ou état\nmanger, être, courir\n\n📝 Déterminant = devant le nom\nle, la, un, une, les, des', tip: 'Chaque mot a une nature !' },
              { id: 's2', text: 'L\'adjectif', visual: '✨ Adjectif = décrire le nom\n\nle chat NOIR → noir décrit le chat\nune fleur BELLE → belle décrit la fleur', tip: 'L\'adjectif QUALIFIE le nom !' }
            ], exercises: [
              { q: '📚 "grand" dans "un grand château" est un...', a: 'adjectif', hint: 'Il décrit le nom château !' },
              { q: '📚 "manger" est un...', a: 'verbe', hint: 'C\'est une action !' }
            ]
          },
          {
            id: 'ce2_gram_sujet_verbe', title: 'Sujet et verbe', duration: '12 min', steps: [
              { id: 's1', text: 'Accord sujet-verbe', visual: '👧 Marie mange → mange (singulier)\n👧👧 Marie et Léa mangent → mangent (pluriel)\n\nLe verbe s\'accorde avec le SUJET !', tip: 'Singulier → -e/-s, Pluriel → -ons/-ent !' }
            ], exercises: [
              { q: '📚 "Les enfants mangent" → mangent est correct ?', a: 'oui', hint: 'Les enfants = pluriel, donc -ent !' }
            ]
          }
        ]
      },
      'Conjugaison': {
        icon: '🔄',
        lessons: [
          {
            id: 'ce2_futur', title: 'Le futur', duration: '12 min', steps: [
              { id: 's1', text: 'Être et Avoir au futur', visual: 'ÊTRE : je SERAI, tu SERAS, il SERA,\nnous SERONS, vous SEREZ, ils SERONT\n\nAVOIR : j\'AURAI, tu AURAS, il AURA,\nnous AURONS, vous AUREZ, ils AURONT', tip: '-AI, -AS, -A, -ONS, -EZ, -ONT !' },
              { id: 's2', text: 'Verbes en -ER au futur', visual: 'PARLER → je parler-AI\nJOUER → je jouer-AI\nMANGER → je manger-AI\n\nOn ajoute -AI, -AS, -A, -ONS, -EZ, -ONT !', tip: 'Le radical + terminaisons du futur !' }
            ], exercises: [
              { q: '🔄 Je ___ demain (être)', a: 'serai', hint: 'Je SERAI' },
              { q: '🔄 Nous ___ au cinéma (aller au futur)', a: 'irons', hint: 'Nous IRONS (aller → ir-)' }
            ]
          },
          {
            id: 'ce2_passe', title: 'Le passé composé', duration: '15 min', steps: [
              { id: 's1', text: 'Passé composé avec avoir', visual: 'PASSÉ COMPOSÉ = quelque chose de TERMINÉ\n\nAVOIR au présent + participe passé\n\nJ\'AI mangé 🍽️\nTu AS joué 🎮\nIl A couru 🏃\n\nLe participe passé de avoir = eu\naiment = eu', tip: 'C\'est "avoir" + ce qu\'on a fait !' },
              { id: 's2', text: 'Participe passé des verbes en -ER', visual: '-ER → -É\n\nmanger → mangÉ\njouer → jouÉ\nchanter → chantÉ', tip: '-ER devient -É au passé composé !' }
            ], exercises: [
              { q: '🔄 J\'ai ___ (manger)', a: 'mangé', hint: 'manger → mangé' },
              { q: '🔄 Elle a ___ (jouer)', a: 'joué', hint: 'jouer → joué' }
            ]
          }
        ]
      },
      'Orthographe': {
        icon: '✏️',
        lessons: [
          {
            id: 'ce2_homo', title: 'Homophones grammaticaux', duration: '15 min', steps: [
              { id: 's1', text: 'son / sont', visual: '❓ son = déterminant (mon, ton, son = à lui)\n"il prend son livre" (le livre à lui)\n\n❓ sont = verbe être\n"ils sont contents"', tip: 'SON = à lui, SONT = sont des êtres !' },
              { id: 's2', text: 'on / ont', visual: '❓ on = pronom (quelqu\'un)\n"on joue" = nous jouons\n\n❓ ont = verbe avoir\n"ils ont faim"', tip: 'ON = pronom, ONT = ont des choses !' },
              { id: 's3', text: 'ces / ses', visual: '❓ ces = déterminant pluriel\n"ces livres" (plusieurs livres)\n\n❓ ses = déterminant (à lui)\n"il ouvre ses livres"', tip: 'CES = pluriel, SES = ses propres choses !' }
            ], exercises: [
              { q: '✏️ "Il prend ___ affaires." (à lui)', a: 'ses', hint: 'SES = à lui' },
              { q: '✏️ "Ils ___ contents." (être)', a: 'sont', hint: 'SONT = verbe être' },
              { q: '✏️ "___ enfants jouent." (plusieurs)', a: 'ces', hint: 'CES = pluriel' }
            ]
          },
          {
            id: 'ce2_accords', title: 'Accords complexes', duration: '12 min', steps: [
              { id: 's1', text: 'Accord de l\'adjectif', visual: 'le chat noir → les chats noirS\nla fleur belle → les fleurs belleS\n\nL\'adjectif s\'accorde avec le nom !\nMasculin = pas de marque\nFéminin = -e', tip: 'Le nom est féminin → adjectif en -e !' }
            ], exercises: [
              { q: '✏️ "une robe rouge" au pluriel', a: 'des robes rouges', hint: 'rouge → rouges (féminin pluriel)' }
            ]
          }
        ]
      },
      'Vocabulaire': {
        icon: '📝',
        lessons: [
          {
            id: 'ce2_famille', title: 'Familles de mots', duration: '10 min', steps: [
              { id: 's1', text: 'Familles de mots', visual: 'FORÊT 🌳 → FORESTIER 🌲 → DÉFORESTATION 🪓\n\nFORÊT = la racine commune !\n\n Même RACINE = même FAMILLE !', tip: 'Cherche le lien !' }
            ], exercises: [
              { q: '📝 "cheval, chevalier, chevaux" → racine ?', a: 'cheval', hint: 'Cheval est la base !' }
            ]
          }
        ]
      },
      'Écriture': {
        icon: '✍️',
        lessons: [
          {
            id: 'ce2_rediger', title: 'Rédiger un texte', duration: '15 min', steps: [
              { id: 's1', text: 'Organiser son texte', visual: '📝 Un bon texte a :\n\n🏠 DÉBUT : On présente\n   Qui ? Où ? Quand ?\n\n📖 MILIEU : Ce qui se passe\n   Les actions\n\n🎬 FIN : La fin\n   Le résultat', tip: 'Début / Milieu / Fin !' },
              { id: 's2', text: 'Les connecteurs', visual: '🔗 Pour lier les idées :\n\nPUIS → ensuite\nMAIS → opposition\nPARCE QUE → explication\nALORS → résultat\n\n"Puis il mangea, mais il n\'aima pas,\nparce que c\'était mauvais."', tip: 'Les connecteurs changent le texte !' }
            ], exercises: [
              { q: '✍️ "___ il est tombé, il s\'est fait mal." (opposition)', a: 'Mais', hint: 'MAIS = opposition' },
              { q: '✍️ "Il est parti ___ il avait faim." (explication)', a: 'parce que', hint: 'PARCE QUE = explication' }
            ]
          }
        ]
      }
    }
  }
};

// === MINI-GAMES STATE ===
let rocketGame = {
  active: false,
  questions: [],
  currentQ: 0,
  score: 0,
  emilieProgress: 0,
  bulleProgress: 0,
  timeLeft: 60,
  timerInterval: null
};

let wordHuntGame = {
  active: false,
  theme: '',
  words: [],
  foundWords: [],
  grid: [],
  selectedCells: [],
  themeIndex: 0
};

let stickerAlbum = {
  stickers: [], // array of sticker objects
  unlockedCount: 0,
  gamesCompleted: { rocket: false, wordHunt: false }
};

let dailyChallenge = {
  completed: false,
  date: '',
  title: '',
  description: '',
  reward: '⭐'
};

// === WORD HUNT THEMES ===
const wordHuntThemes = [
  {
    name: 'Animaux',
    words: ['CHAT', 'CHIEN', 'OISEAU', 'POISSON', 'Lapin'.toUpperCase()],
    hint: '🐾 Trouve les animaux cachés !'
  },
  {
    name: 'École',
    words: ['CRAYON', 'GOMME', 'CARTABLE', 'Cahier'.toUpperCase(), 'Stylo'.toUpperCase()],
    hint: '📚 Trouve les objets de l\'école !'
  },
  {
    name: 'Famille',
    words: ['MAMAN', 'PAPY', 'SOEUR', 'FRÈRE', 'Bébé'.toUpperCase()],
    hint: '👨‍👩‍👧 Trouve les mots de la famille !'
  }
];

// === STICKER DEFINITIONS ===
const stickerDefinitions = [
  { id: 1, emoji: '🐿️', name: 'Noisette Joyeuse', desc: 'Noisette fait la fête !' },
  { id: 2, emoji: '🐿️', name: 'Noisette淑', desc: 'Noisette mange des noisettes' },
  { id: 3, emoji: '🐿️', name: 'Noisette Endormie', desc: 'Noisette fait la sieste' },
  { id: 4, emoji: '🐿️', name: 'Noisette Danse', desc: 'Noisette groove !' },
  { id: 5, emoji: '🐿️', name: 'Noisette Champion', desc: 'Noisette gagne !' },
  { id: 6, emoji: '🪼', name: 'Bulle Heureuse', desc: 'Bulle sourit' },
  { id: 7, emoji: '🪼', name: 'Bulle Nage', desc: 'Bulle fait la brasse' },
  { id: 8, emoji: '🪼', name: 'Bulle Scintille', desc: 'Bulle brille !' },
  { id: 9, emoji: '🪼', name: 'Bulle Tranquille', desc: 'Bulle se repose' },
  { id: 10, emoji: '🪼', name: 'Bulle Fleur', desc: 'Bulle a une fleur' },
  { id: 11, emoji: '🦭', name: 'Câlin Câlin', desc: 'Câlin donne un câlin' },
  { id: 12, emoji: '🦭', name: 'Câlin Joyeux', desc: 'Câlin rit' },
  { id: 13, emoji: '🦭', name: 'Câlin Nageur', desc: 'Câlin plonge' },
  { id: 14, emoji: '🦭', name: 'Câlin Dodo', desc: 'Câlin baille' },
  { id: 15, emoji: '🦭', name: 'Câlin Star', desc: 'Câlin fait la star' },
  { id: 16, emoji: '⭐', name: 'Étoile Dorée', desc: 'Une étoile brillante' },
  { id: 17, emoji: '🏆', name: 'Trophée', desc: 'Tu as gagné !' },
  { id: 18, emoji: '🌈', name: 'Arc-en-ciel', desc: 'Un arc-en-ciel coloré' },
  { id: 19, emoji: '🎈', name: 'Ballon', desc: 'Un ballon gonflé' },
  { id: 20, emoji: '🎁', name: 'Cadeau', desc: 'Un cadeau sorpresa' }
];

// === DAILY CHALLENGES ===
const dailyChallengesList = [
  { title: 'Course de Fusées', desc: 'Gagne la course de fusées !', reward: '⭐ + Sticker' },
  { title: 'Chasse aux Mots', desc: 'Trouve tous les mots !', reward: '⭐ + Sticker' },
  { title: 'Quiz Maths', desc: 'Réponds à 10 questions', reward: '⭐ + Sticker' },
  { title: 'Quiz Français', desc: 'Réponds à 10 questions', reward: '⭐ + Sticker' }
];

// === ROCKET GAME QUESTIONS ===
const rocketQuestions = [
  { q: '🪼 3 × 4 = ?', c: [10, 12, 14, 8], a: 12 },
  { q: '🐿️ 5 × 5 = ?', c: [20, 25, 30, 15], a: 25 },
  { q: '🦭 7 × 2 = ?', c: [12, 14, 16, 18], a: 14 },
  { q: '🪼 6 × 4 = ?', c: [24, 20, 28, 22], a: 24 },
  { q: '🐿️ 8 × 3 = ?', c: [21, 24, 27, 30], a: 24 },
  { q: '🦭 9 × 2 = ?', c: [16, 18, 20, 22], a: 18 },
  { q: '🪼 4 × 7 = ?', c: [26, 28, 30, 32], a: 28 },
  { q: '🐿️ 6 × 6 = ?', c: [30, 36, 42, 24], a: 36 },
  { q: '🦭 3 × 8 = ?', c: [21, 24, 27, 30], a: 24 },
  { q: '🪼 5 × 7 = ?', c: [30, 35, 40, 25], a: 35 }
];

// Initialize sticker album
function initStickerAlbum() {
  stickerAlbum.stickers = new Array(20).fill(null);
  checkDailyChallenge();
}

// Check and set daily challenge
function checkDailyChallenge() {
  const today = new Date().toDateString();
  if (dailyChallenge.date !== today) {
    dailyChallenge.date = today;
    dailyChallenge.completed = false;
    const challenge = dailyChallengesList[Math.floor(Math.random() * dailyChallengesList.length)];
    dailyChallenge.title = challenge.title;
    dailyChallenge.description = challenge.desc;
    dailyChallenge.reward = challenge.reward;
  }
}

// === ROCKET RACE GAME ===
function startRocketRace() {
  rocketGame.active = true;
  rocketGame.questions = shuffle([...rocketQuestions]);
  rocketGame.currentQ = 0;
  rocketGame.score = 0;
  rocketGame.emilieProgress = 0;
  rocketGame.bulleProgress = 0;
  rocketGame.timeLeft = 60;
  
  screen = 'rocketRace';
  playBeep(800, 0.2, 'sine');
  render();
  
  // Start timer
  rocketGame.timerInterval = setInterval(() => {
    rocketGame.timeLeft--;
    updateRocketTimer();
    if (rocketGame.timeLeft <= 0) {
      endRocketRace();
    }
  }, 1000);
}

function updateRocketTimer() {
  const timerEl = document.getElementById('rocketTimer');
  if (timerEl) {
    timerEl.textContent = `${rocketGame.timeLeft}s`;
    if (rocketGame.timeLeft <= 10) {
      timerEl.classList.add('warning');
    }
  }
}

function handleRocketChoice(answer) {
  const correct = answer === rocketGame.questions[rocketGame.currentQ].a;
  
  if (correct) {
    rocketGame.score++;
    rocketGame.emilieProgress = Math.min(100, rocketGame.emilieProgress + 10);
    playCorrectSound();
  } else {
    rocketGame.bulleProgress = Math.min(100, rocketGame.bulleProgress + 10);
    playWrongSound();
  }
  
  render();
  
  setTimeout(() => {
    rocketGame.currentQ++;
    if (rocketGame.currentQ >= rocketGame.questions.length) {
      endRocketRace();
    } else {
      render();
    }
  }, 800);
}

function endRocketRace() {
  clearInterval(rocketGame.timerInterval);
  rocketGame.active = false;
  
  const emilieWon = rocketGame.emilieProgress > rocketGame.bulleProgress;
  const emoji = emilieWon ? '🏆' : (rocketGame.emilieProgress === rocketGame.bulleProgress ? '🤝' : '😢');
  const title = emilieWon ? 'Victoire ! 🚀' : 'Course terminée !';
  const stats = `Score: ${rocketGame.score}/${rocketGame.questions.length}\nFusée Emilie: ${rocketGame.emilieProgress}% | Fusée Bulle: ${rocketGame.bulleProgress}%`;
  
  document.getElementById('rocketResultEmoji').textContent = emoji;
  document.getElementById('rocketResultTitle').textContent = title;
  document.getElementById('rocketResultStats').textContent = stats;
  document.getElementById('rocketResultOverlay').classList.add('show');
  
  if (emilieWon) {
    spawnConfetti(25);
    playLevelUp();
    addStars(5);
    
    // Unlock sticker for Emilie
    if (!stickerAlbum.gamesCompleted.rocket) {
      stickerAlbum.gamesCompleted.rocket = true;
      unlockRandomSticker();
    }
    
    // Complete daily challenge if applicable
    if (dailyChallenge.title === 'Course de Fusées' && !dailyChallenge.completed) {
      dailyChallenge.completed = true;
      addStars(3);
      spawnConfetti(15);
    }
  }
}

function closeRocketResult() {
  document.getElementById('rocketResultOverlay').classList.remove('show');
  screen = 'home';
  render();
}

// === WORD HUNT GAME ===
function startWordHunt() {
  wordHuntGame.active = true;
  wordHuntGame.themeIndex = Math.floor(Math.random() * wordHuntThemes.length);
  const theme = wordHuntThemes[wordHuntGame.themeIndex];
  wordHuntGame.theme = theme.name;
  wordHuntGame.words = [...theme.words];
  wordHuntGame.foundWords = [];
  wordHuntGame.selectedCells = [];
  
  generateWordHuntGrid();
  
  screen = 'wordHunt';
  playBeep(700, 0.2, 'sine');
  render();
}

function generateWordHuntGrid() {
  const theme = wordHuntThemes[wordHuntGame.themeIndex];
  const grid = [];
  const words = theme.words;
  
  // Create empty 6x6 grid
  for (let i = 0; i < 36; i++) {
    grid.push({ letter: '', isPartOfWord: false, wordIndex: -1, found: false });
  }
  
  // Place words in grid
  const directions = [
    { dr: 0, dc: 1 },  // horizontal
    { dr: 1, dc: 0 },  // vertical
    { dr: 1, dc: 1 }   // diagonal
  ];
  
  words.forEach((word, wordIndex) => {
    let placed = false;
    let attempts = 0;
    
    while (!placed && attempts < 50) {
      const dir = directions[Math.floor(Math.random() * directions.length)];
      const maxRow = dir.dr === 0 ? 6 : 6 - word.length;
      const maxCol = dir.dc === 0 ? 6 : 6 - word.length;
      const startRow = Math.floor(Math.random() * maxRow);
      const startCol = Math.floor(Math.random() * maxCol);
      
      let canPlace = true;
      const cells = [];
      
      for (let i = 0; i < word.length; i++) {
        const r = startRow + i * dir.dr;
        const c = startCol + i * dir.dc;
        const idx = r * 6 + c;
        
        if (grid[idx].letter !== '' && grid[idx].letter !== word[i]) {
          canPlace = false;
          break;
        }
        cells.push(idx);
      }
      
      if (canPlace) {
        cells.forEach(idx => {
          grid[idx].letter = word[i];
          grid[idx].isPartOfWord = true;
          grid[idx].wordIndex = wordIndex;
        });
        placed = true;
      }
      attempts++;
    }
  });
  
  // Fill remaining cells with random letters
  const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  for (let i = 0; i < 36; i++) {
    if (grid[i].letter === '') {
      grid[i].letter = letters[Math.floor(Math.random() * letters.length)];
    }
  }
  
  wordHuntGame.grid = grid;
}

function toggleWordHuntCell(index) {
  const cell = wordHuntGame.grid[index];
  if (cell.found) return;
  
  const selectedIdx = wordHuntGame.selectedCells.indexOf(index);
  if (selectedIdx > -1) {
    wordHuntGame.selectedCells.splice(selectedIdx, 1);
  } else {
    wordHuntGame.selectedCells.push(index);
  }
  
  render();
}

function clearWordHuntSelection() {
  wordHuntGame.selectedCells = [];
  render();
}

function submitWordHunt() {
  if (wordHuntGame.selectedCells.length === 0) return;
  
  const selectedWord = wordHuntGame.selectedCells
    .map(idx => wordHuntGame.grid[idx].letter)
    .join('');
  
  const reversedWord = selectedWord.split('').reverse().join('');
  
  const matchedWordIndex = wordHuntGame.words.findIndex(w => 
    w === selectedWord || w === reversedWord
  );
  
  if (matchedWordIndex > -1 && !wordHuntGame.foundWords.includes(matchedWordIndex)) {
    wordHuntGame.foundWords.push(matchedWordIndex);
    wordHuntGame.selectedCells.forEach(idx => {
      wordHuntGame.grid[idx].found = true;
    });
    playCorrectSound();
    
    // Check if all words found
    if (wordHuntGame.foundWords.length === wordHuntGame.words.length) {
      setTimeout(() => {
        completeWordHunt();
      }, 500);
    }
  } else {
    playWrongSound();
  }
  
  wordHuntGame.selectedCells = [];
  render();
}

function completeWordHunt() {
  addStars(5);
  spawnConfetti(20);
  playLevelUp();
  
  // Unlock sticker
  if (!stickerAlbum.gamesCompleted.wordHunt) {
    stickerAlbum.gamesCompleted.wordHunt = true;
    unlockRandomSticker();
  }
  
  // Complete daily challenge
  if (dailyChallenge.title === 'Chasse aux Mots' && !dailyChallenge.completed) {
    dailyChallenge.completed = true;
    addStars(3);
    spawnConfetti(15);
  }
  
  showReward('🪼🦭', 'Mots trouvés !', 'Tu as trouvé tous les mots, quel champion ! 🎉');
}

// === STICKER SYSTEM ===
function unlockRandomSticker() {
  const emptySlots = [];
  stickerAlbum.stickers.forEach((s, i) => {
    if (s === null) emptySlots.push(i);
  });
  
  if (emptySlots.length > 0) {
    const slotIndex = emptySlots[Math.floor(Math.random() * emptySlots.length)];
    const sticker = stickerDefinitions[slotIndex];
    stickerAlbum.stickers[slotIndex] = sticker;
    stickerAlbum.unlockedCount++;
    
    setTimeout(() => {
      showReward(sticker.emoji, 'Nouveau Sticker !', `${sticker.name}: ${sticker.desc}`);
    }, 500);
  }
}

function showStickerDetail(index) {
  const sticker = stickerAlbum.stickers[index];
  if (!sticker) return;
  
  document.getElementById('stickerDetailEmoji').textContent = sticker.emoji;
  document.getElementById('stickerDetailName').textContent = sticker.name;
  document.getElementById('stickerDetailDesc').textContent = sticker.desc;
  document.getElementById('stickerDetailOverlay').classList.add('show');
}

function closeStickerDetail() {
  document.getElementById('stickerDetailOverlay').classList.remove('show');
}

function playWordFoundSound() {
  playBeep(880, 0.15, 'sine');
  setTimeout(() => playBeep(1100, 0.15, 'sine'), 100);
  setTimeout(() => playBeep(1320, 0.2, 'sine'), 200);
}

// === SONS (Web Audio API) ===
const AudioCtx = window.AudioContext || window.webkitAudioContext;
let audioCtx;

function getAudio() {
  if (!audioCtx) audioCtx = new AudioCtx();
  return audioCtx;
}

function playBeep(freq=440, duration=0.15, type='sine', volume=0.3) {
  if (muted) return;
  try {
    const ctx = getAudio();
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.connect(gain);
    gain.connect(ctx.destination);
    osc.frequency.value = freq;
    osc.type = type;
    gain.gain.setValueAtTime(volume, ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + duration);
    osc.start(ctx.currentTime);
    osc.stop(ctx.currentTime + duration);
  } catch(e) {}
}

function playCorrectSound() {
  playBeep(523, 0.12, 'sine');
  setTimeout(() => playBeep(659, 0.12, 'sine'), 120);
  setTimeout(() => playBeep(784, 0.2, 'sine'), 240);
}

function playWrongSound() {
  playBeep(220, 0.2, 'sawtooth', 0.2);
  setTimeout(() => playBeep(180, 0.25, 'sawtooth', 0.2), 200);
}

function playLevelUp() {
  [523, 659, 784, 1046].forEach((f, i) =>
    setTimeout(() => playBeep(f, 0.2, 'sine', 0.4), i * 150)
  );
}

function toggleMute() {
  muted = !muted;
  document.getElementById('muteBtn').textContent = muted ? '🔇' : '🔊';
  playBeep(500, 0.1, 'sine');
}

// === PARTICULES ANIMAUX ===
const animalEmojis = ['🐿️','🪼','🦭','⭐','✨','🌟','💫','🎈'];

function createFloatingAnimals() {
  const container = document.getElementById('floatingAnimals');
  if (container.children.length > 0) return;
  for (let i = 0; i < 18; i++) {
    const el = document.createElement('div');
    el.className = 'animal-float';
    el.textContent = animalEmojis[Math.floor(Math.random() * animalEmojis.length)];
    el.style.left = Math.random() * 100 + '%';
    el.style.animationDuration = (8 + Math.random() * 15) + 's';
    el.style.animationDelay = (Math.random() * 15) + 's';
    el.style.fontSize = (1 + Math.random() * 2) + 'rem';
    container.appendChild(el);
  }
}

// === CONFETTIS ===
function spawnConfetti(count=12) {
  const emojis = ['🐿️','🪼','🦭','⭐','🌟','✨','🎉','💛','💖'];
  for (let i = 0; i < count; i++) {
    setTimeout(() => {
      const el = document.createElement('div');
      el.className = 'confetti-animal';
      el.textContent = emojis[Math.floor(Math.random() * emojis.length)];
      el.style.left = (10 + Math.random() * 80) + '%';
      el.style.top = '-50px';
      el.style.animationDuration = (1.5 + Math.random()) + 's';
      el.style.fontSize = (1.5 + Math.random() * 1.5) + 'rem';
      document.body.appendChild(el);
      setTimeout(() => el.remove(), 3000);
    }, i * 120);
  }
}

// === MASCOTTES INTERACTIONS ===
const mascotSays = {
  squirrel: ['Noisette dit : Tu es la meilleure ! 🌰','Continue, les noisettes t\'attendent ! 🐿️','Noisette est ton ami pour toujours ! 💛'],
  jelly:    ['Bulle flotte de joie pour toi ! 🪼','Les méduses adorent les bonnes réponses ! 💙','Bulle scintille quand tu apprends ! ✨'],
  seal:     ['Câlin t\'envoie un gros câlin ! 🦭','Tu es trop forte, Emilie ! 💖','Câlin est fier de toi ! 🥰']
};

function talkMascot(type) {
  const msgs = mascotSays[type];
  const msg = msgs[Math.floor(Math.random() * msgs.length)];
  showFeedback(true, msg, type === 'squirrel' ? '🐿️' : type === 'jelly' ? '🪼' : '🦭');
  playBeep(600, 0.1, 'sine');
}

// === LESSONS PAGE (LEÇONS TDAH/AUTISME) ===
function lessonsHTML() {
  const program = lessonsState.currentLevel === 'ce1' ? CE1_PROGRAM : CE2_PROGRAM;
  const levelLabel = lessonsState.currentLevel.toUpperCase();
  const subjectData = program[lessonsState.currentSubject];
  
  return `<div class="module-header screen-transition">
    <button class="back-btn" data-action="home">🏠</button>
    <h2 class="module-title" style="color: #9333ea;">📚 Leçons ${levelLabel}</h2>
    <button class="btn-icon" onclick="toggleVisualMode()" title="Mode">${lessonsState.visualMode ? '👁️' : '📝'}</button>
  </div>
  
  <div class="card level-selector-card">
    <div class="level-tabs">
      <button class="level-tab ${lessonsState.currentLevel === 'ce1' ? 'active' : ''}" onclick="switchLevel('ce1')">
        📘 CE1
      </button>
      <button class="level-tab ${lessonsState.currentLevel === 'ce2' ? 'active' : ''}" onclick="switchLevel('ce2')">
        📗 CE2
      </button>
    </div>
    <p class="level-description">${lessonsState.currentLevel === 'ce1' ? 'Cours pour les petits ! 🌟' : 'Cours pour les plus grands ! 🚀'}</p>
  </div>
  
  <div class="card subject-selector-card">
    <div class="subject-tabs">
      <button class="subject-tab math ${lessonsState.currentSubject === 'math' ? 'active' : ''}" onclick="switchSubject('math')">
        🔢 Maths
      </button>
      <button class="subject-tab french ${lessonsState.currentSubject === 'french' ? 'active' : ''}" onclick="switchSubject('french')">
        📖 Français
      </button>
    </div>
  </div>
  
  <div class="lessons-container">
    ${Object.entries(subjectData.skills).map(([skillName, skillData]) => `
      <div class="skill-section">
        <div class="skill-header" onclick="toggleSkill('${skillName}')">
          <span class="skill-icon">${skillData.icon}</span>
          <span class="skill-name">${skillName}</span>
          <span class="skill-arrow" id="arrow-${skillName.replace(/\s/g, '-')}">▼</span>
        </div>
        <div class="skill-lessons" id="lessons-${skillName.replace(/\s/g, '-')}" style="display: none;">
          ${skillData.lessons.map(lesson => `
            <div class="lesson-card" onclick="openLesson('${lesson.id}')">
              <div class="lesson-icon">${skillData.icon}</div>
              <div class="lesson-info">
                <h3 class="lesson-title">${lesson.title}</h3>
                <div class="lesson-meta">
                  <span class="lesson-duration">⏱️ ${lesson.duration}</span>
                </div>
                <div class="lesson-steps-preview">
                  ${lesson.steps.slice(0, 3).map(s => `<span class="step-dot" title="${s.text}">●</span>`).join('')}
                  ${lesson.steps.length > 3 ? `<span class="more-dots">+${lesson.steps.length - 3}</span>` : ''}
                </div>
              </div>
              <div class="lesson-arrow">→</div>
            </div>
          `).join('')}
        </div>
      </div>
    `).join('')}
  </div>
  
  <div class="card mascot-lessons-card">
    <div class="mascot-lessons-anim">
      <span class="mascot-anim squirrel">🐿️</span>
      <span class="mascot-anim jelly">🪼</span>
      <span class="mascot-anim seal">🦭</span>
    </div>
    <p class="mascot-lessons-tip">"Apprends avec nous ! Chaque leçon est un adventure !" 🌟</p>
    <p class="mascot-lessons-name">- Noisette, Bulle et Câlin</p>
  </div>`;
}

function toggleSkill(skillName) {
  const id = 'lessons-' + skillName.replace(/\s/g, '-');
  const arrowId = 'arrow-' + skillName.replace(/\s/g, '-');
  const lessonsDiv = document.getElementById(id);
  const arrow = document.getElementById(arrowId);
  if (lessonsDiv.style.display === 'none') {
    lessonsDiv.style.display = 'block';
    arrow.textContent = '▲';
  } else {
    lessonsDiv.style.display = 'none';
    arrow.textContent = '▼';
  }
}

// Lesson Detail Page
function openLesson(lessonId) {
  const program = lessonsState.currentLevel === 'ce1' ? CE1_PROGRAM : CE2_PROGRAM;
  let lesson = null;
  
  for (const subject of Object.values(program)) {
    for (const skill of Object.values(subject.skills)) {
      lesson = skill.lessons.find(l => l.id === lessonId);
      if (lesson) break;
    }
    if (lesson) break;
  }
  
  if (!lesson) return;
  
  lessonsState.currentLesson = lesson;
  lessonsState.stepsCompleted = [];
  screen = 'lessonDetail';
  render();
}

function lessonDetailHTML() {
  const lesson = lessonsState.currentLesson;
  if (!lesson) return '<p>Erreur : leçon non trouvée</p>';
  
  const program = lessonsState.currentLevel === 'ce1' ? CE1_PROGRAM : CE2_PROGRAM;
  let subjectData = null;
  for (const subject of Object.values(program)) {
    for (const skill of Object.values(subject.skills)) {
      if (skill.lessons.some(l => l.id === lesson.id)) {
        subjectData = subject;
        break;
      }
    }
    if (subjectData) break;
  }
  
  return `<div class="module-header screen-transition">
    <button class="back-btn" onclick="closeLesson()">←</button>
    <h2 class="module-title" style="color: ${subjectData.color};">${lesson.title}</h2>
    <span class="lesson-progress-badge">${lessonsState.stepsCompleted.length}/${lesson.steps.length}</span>
  </div>
  
  <div class="lesson-progress-bar-container">
    <div class="lesson-progress-bar" style="width: ${(lessonsState.stepsCompleted.length / lesson.steps.length) * 100}%"></div>
  </div>
  
  <div class="lesson-steps-container">
    ${lesson.steps.map((step, index) => {
      const isCompleted = lessonsState.stepsCompleted.includes(step.id);
      const isCurrent = index === lessonsState.stepsCompleted.length;
      
      return `<div class="lesson-step ${isCompleted ? 'completed' : ''} ${isCurrent ? 'current' : ''}" onclick="toggleStep('${step.id}')">
        <div class="step-number ${isCompleted ? 'done' : ''}">${isCompleted ? '✓' : index + 1}</div>
        <div class="step-content">
          <h4 class="step-title">${step.text}</h4>
          <div class="step-visual ${lessonsState.visualMode ? 'show' : ''}">${step.visual}</div>
          <div class="step-tip">💡 ${step.tip}</div>
        </div>
      </div>`;
    }).join('')}
  </div>
  
  ${lessonsState.stepsCompleted.length === lesson.steps.length ? `
    <div class="card lesson-exercises-card">
      <h3 style="color: ${subjectData.color}; margin-bottom: 15px;">🎯 Entraîne-toi !</h3>
      ${lesson.exercises.map((ex, i) => `
        <div class="lesson-exercise">
          <p class="exercise-q">${ex.q}</p>
          <div class="exercise-input-area">
            <input type="text" class="lesson-answer-input" id="lessonAns${i}" placeholder="Ta réponse...">
            <button class="lesson-check-btn" onclick="checkLessonAnswer(${i}, '${ex.a}')">✓</button>
          </div>
          <div class="exercise-hint" id="hint${i}" style="display: none;">💡 ${ex.hint}</div>
        </div>
      `).join('')}
    </div>
  ` : `
    <div class="card lesson-continue-card">
      <div class="continue-message">
        <span class="continue-emoji">${lessonsState.stepsCompleted.length === 0 ? '👋' : '🔥'}</span>
        <p>${lessonsState.stepsCompleted.length === 0 ? 'Clique sur chaque étape pour apprendre !' : `Continue ! Tu as ${lesson.steps.length - lessonsState.stepsCompleted.length} étapes restantes !`}</p>
      </div>
      <div class="continue-mascot">${subjectData.color === '#3b82f6' || subjectData.color === '#8b5cf6' ? '🪼' : '🦭'}</div>
    </div>
  `}
  
  <button class="btn-finish-lesson" onclick="finishLesson()">
    ✅ J'ai terminé cette leçon !
  </button>`;
}

function toggleStep(stepId) {
  if (lessonsState.stepsCompleted.includes(stepId)) {
    // Allow unchecking only for current step
    const lesson = lessonsState.currentLesson;
    const currentIndex = lesson.steps.findIndex(s => s.id === stepId);
    if (currentIndex === lessonsState.stepsCompleted.length - 1) {
      lessonsState.stepsCompleted.pop();
    }
  } else {
    // Check if previous steps are completed
    const lesson = lessonsState.currentLesson;
    const stepIndex = lesson.steps.findIndex(s => s.id === stepId);
    if (stepIndex === 0 || lessonsState.stepsCompleted.includes(lesson.steps[stepIndex - 1].id)) {
      lessonsState.stepsCompleted.push(stepId);
      playBeep(800, 0.2, 'sine');
      if (lessonsState.stepsCompleted.length === lesson.steps.length) {
        addStars(5);
        spawnConfetti(15);
        showFeedback(true, '🎉 Bravo ! Tu peux maintenant faire les exercices !', '⭐');
      }
    }
  }
  render();
}

function checkLessonAnswer(index, correctAnswer) {
  const input = document.getElementById(`lessonAns${index}`);
  const hint = document.getElementById(`hint${index}`);
  const userAnswer = input.value.trim().toLowerCase();
  const correct = userAnswer === correctAnswer.toLowerCase();
  
  if (correct) {
    input.style.borderColor = '#22c55e';
    input.style.background = '#bbf7d0';
    input.disabled = true;
    addStars(3);
    spawnConfetti(8);
    showFeedback(true, '⭐ Bravo ! +3 étoiles !', '🎉');
  } else {
    input.style.borderColor = '#ef4444';
    hint.style.display = 'block';
    showFeedback(false, 'Pas grave, regarde l\'indice ! 💪', '💡');
  }
}

function finishLesson() {
  addStars(10);
  spawnConfetti(20);
  showReward(lessonsState.currentLesson.icon, 'Leçon terminée !', 'Tu es amazing ! Continue comme ça !');
  lessonsState.currentLesson = null;
  lessonsState.stepsCompleted = [];
  screen = 'lessons';
  setTimeout(() => render(), 2000);
}

function closeLesson() {
  lessonsState.currentLesson = null;
  lessonsState.stepsCompleted = [];
  screen = 'lessons';
  render();
}

function switchLevel(level) {
  lessonsState.currentLevel = level;
  lessonsState.currentLesson = null;
  lessonsState.stepsCompleted = [];
  render();
}

function switchSubject(subject) {
  lessonsState.currentSubject = subject;
  lessonsState.currentLesson = null;
  lessonsState.stepsCompleted = [];
  render();
}

function toggleVisualMode() {
  lessonsState.visualMode = !lessonsState.visualMode;
  render();
}

// === HOMEWORK PAGE (PAGE DEVOIRS DU JOUR) ===
function homeworkHTML() {
  const today = new Date().toLocaleDateString('fr-FR', { weekday: 'long', day: 'numeric', month: 'long' });
  const hasMath = homeworkState.mathHomework.trim() !== '';
  const hasFrench = homeworkState.frenchHomework.trim() !== '';
  
  return `<div class="module-header screen-transition">
    <button class="back-btn" data-action="home">🏠</button>
    <h2 class="module-title" style="color: #9333ea;">📚 Devoirs du Jour</h2>
    <button class="btn-icon" onclick="downloadHomework()" title="Télécharger">📥</button>
  </div>
  
  <div class="card homework-date-card">
    <div style="font-size: 2rem; margin-bottom: 5px;">📅</div>
    <h3 style="color: #9333ea;">${today}</h3>
    <p style="color: #666; font-size: 0.9rem;">Remplis tes devoirs avec l'aide de Noisette ! 🐿️</p>
  </div>
  
  <div class="card homework-section">
    <div class="homework-header" onclick="toggleHomeworkSection('math')">
      <span style="font-size: 1.8rem;">🔢</span>
      <div>
        <h3 style="color: #2563eb;">Mathématiques</h3>
        <p style="font-size: 0.85rem; color: #666;">${hasMath ? 'Exercices ajoutés' : 'Clique pour ajouter'}</p>
      </div>
      <span class="homework-toggle" id="mathToggle">▼</span>
    </div>
    <div class="homework-content" id="mathContent">
      ${hasMath ? `<div class="homework-text">${homeworkState.mathHomework}</div>` : ''}
      <textarea class="homework-input" id="mathInput" placeholder="Ex: Num 13 - Exercices 1 à 6"></textarea>
      <button class="homework-btn math-btn" onclick="saveHomework('math')">💾 Sauvegarder</button>
      ${hasMath ? `<button class="homework-btn ai-btn" onclick="generateAIExercises('math')">🤖 Créer exercices IA</button>` : ''}
    </div>
  </div>
  
  <div class="card homework-section">
    <div class="homework-header" onclick="toggleHomeworkSection('french')">
      <span style="font-size: 1.8rem;">📖</span>
      <div>
        <h3 style="color: #db2777;">Français</h3>
        <p style="font-size: 0.85rem; color: #666;">${hasFrench ? 'Mots de dictée ajoutés' : 'Clique pour ajouter'}</p>
      </div>
      <span class="homework-toggle" id="frenchToggle">▼</span>
    </div>
    <div class="homework-content" id="frenchContent">
      ${hasFrench ? `<div class="homework-text">${homeworkState.frenchHomework}</div>` : ''}
      <textarea class="homework-input" id="frenchInput" placeholder="Ex: mots 24 bleu - Liste de dictée"></textarea>
      <button class="homework-btn french-btn" onclick="saveHomework('french')">💾 Sauvegarder</button>
      ${hasFrench ? `<button class="homework-btn ai-btn" onclick="generateAIExercises('french')">🤖 Créer exercices IA</button>` : ''}
    </div>
  </div>
  
  <div class="card focus-timer-card">
    <div class="focus-timer-header">
      <span style="font-size: 2rem;">🍅</span>
      <div>
        <h3 style="color: #16a34a;">Minuteur Focus</h3>
        <p style="font-size: 0.85rem; color: #666;">25 min de concentration !</p>
      </div>
    </div>
    <div class="focus-timer-display" id="focusTimerDisplay">25:00</div>
    <div class="focus-timer-buttons">
      <button class="focus-btn start" onclick="startFocusTimer()">▶️ Démarrer</button>
      <button class="focus-btn pause" onclick="pauseFocusTimer()">⏸️ Pause</button>
      <button class="focus-btn reset" onclick="resetFocusTimer()">🔄 Reset</button>
    </div>
  </div>
  
  ${homeworkState.aiExercises.length > 0 ? `<div class="card ai-exercises-card">
    <h3 style="color: #9333ea; margin-bottom: 15px;">🤖 Exercices IA Générés</h3>
    ${homeworkState.aiExercises.map((ex, i) => `
      <div class="ai-exercise-item">
        <div class="ai-exercise-q">${ex.question}</div>
        <div class="ai-exercise-hint">💡 ${ex.hint || 'Réfléchis bien !'}</div>
        <button class="ai-exercise-check" onclick="checkAIExercise(${i})">✓ J'ai trouvé !</button>
      </div>
    `).join('')}
  </div>` : ''}
  
  <div class="card motivation-card">
    <div style="font-size: 2.5rem; margin-bottom: 10px;">🐿️</div>
    <p style="font-style: italic; color: #666;">"Une noisette à la fois, on arrive loin !" 🌰</p>
    <p style="color: #9333ea; font-weight: bold; margin-top: 8px;">- Noisette</p>
  </div>`;
}

// Toggle homework section
let homeworkSectionsOpen = { math: false, french: false };

function toggleHomeworkSection(subject) {
  homeworkSectionsOpen[subject] = !homeworkSectionsOpen[subject];
  const content = document.getElementById(`${subject}Content`);
  const toggle = document.getElementById(`${subject}Toggle`);
  content.style.display = homeworkSectionsOpen[subject] ? 'block' : 'none';
  toggle.textContent = homeworkSectionsOpen[subject] ? '▲' : '▼';
}

// Save homework
function saveHomework(subject) {
  const input = document.getElementById(`${subject}Input`);
  if (subject === 'math') {
    homeworkState.mathHomework = input.value;
  } else {
    homeworkState.frenchHomework = input.value;
  }
  playBeep(800, 0.2, 'sine');
  showFeedback(true, 'Devoirs sauvegardés ! 💾', '📚');
  setTimeout(() => render(), 1000);
}

// Download homework as text file
function downloadHomework() {
  const today = new Date().toLocaleDateString('fr-FR');
  let text = `═══════════════════════════════════════\n`;
  text += `📚 DEVOIRS DU JOUR - ${today}\n`;
  text += `═══════════════════════════════════════\n\n`;
  
  if (homeworkState.mathHomework.trim()) {
    text += `🔢 MATHÉMATIQUES\n`;
    text += `───────────────────────────────────────\n`;
    text += homeworkState.mathHomework + "\n\n";
  }
  
  if (homeworkState.frenchHomework.trim()) {
    text += `📖 FRANÇAIS\n`;
    text += `───────────────────────────────────────\n`;
    text += homeworkState.frenchHomework + "\n\n";
  }
  
  if (!homeworkState.mathHomework.trim() && !homeworkState.frenchHomework.trim()) {
    text += `Aucun devoir ajouté aujourd'hui.\n`;
  }
  
  text += `\n═══════════════════════════════════════\n`;
  text += `🐿️🪼🦭 Bon courage Emilie !\n`;
  text += `═══════════════════════════════════════\n`;
  
  // Create and download file
  const blob = new Blob([text], { type: 'text/plain;charset=utf-8' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `devoirs_${today.replace(/\//g, '-')}.txt`;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
  
  playBeep(600, 0.2, 'sine');
  showFeedback(true, 'Fichier téléchargé ! 📥', '⬇️');
}

// Focus Timer (Pomodoro)
function startFocusTimer() {
  if (homeworkState.timerActive) return;
  homeworkState.timerActive = true;
  
  homeworkState.timerInterval = setInterval(() => {
    homeworkState.focusTimer--;
    updateFocusTimerDisplay();
    
    if (homeworkState.focusTimer <= 0) {
      pauseFocusTimer();
      homeworkState.focusTimer = 25 * 60;
      addStars(5);
      spawnConfetti(20);
      showFeedback(true, '🎉 Pause méritée ! 5 étoiles gagnées !', '🍅');
    }
  }, 1000);
  
  playBeep(500, 0.1, 'sine');
}

function pauseFocusTimer() {
  homeworkState.timerActive = false;
  clearInterval(homeworkState.timerInterval);
}

function resetFocusTimer() {
  pauseFocusTimer();
  homeworkState.focusTimer = 25 * 60;
  updateFocusTimerDisplay();
  playBeep(400, 0.1, 'sine');
}

function updateFocusTimerDisplay() {
  const mins = Math.floor(homeworkState.focusTimer / 60);
  const secs = homeworkState.focusTimer % 60;
  const display = document.getElementById('focusTimerDisplay');
  if (display) {
    display.textContent = `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
    if (homeworkState.focusTimer <= 60) {
      display.style.color = '#ef4444';
    } else {
      display.style.color = '#16a34a';
    }
  }
}

// Generate AI Exercises (using free API or fallback)
async function generateAIExercises(subject) {
  if (homeworkState.aiGenerating) return;
  
  homeworkState.aiGenerating = true;
  playBeep(400, 0.3, 'sine');
  
  const homeworkText = subject === 'math' ? homeworkState.mathHomework : homeworkState.frenchHomework;
  
  // Use a free AI API (simulated with predefined exercises based on homework)
  // In production, you could use: Ollama, LM Studio, or other local/free APIs
  const exercises = generateExercisesFromHomework(subject, homeworkText);
  
  homeworkState.aiExercises = exercises;
  homeworkState.aiGenerating = false;
  
  playBeep(800, 0.2, 'sine');
  showFeedback(true, `🤖 ${exercises.length} exercices créés pour toi !`, '✨');
  render();
}

function generateExercisesFromHomework(subject, homeworkText) {
  // Parse homework text and generate exercises
  // This uses predefined templates - in production, call a real AI API
  const exercises = [];
  
  if (subject === 'math') {
    if (homeworkText.toLowerCase().includes('num')) {
      exercises.push(
        { question: '🔢 Trouve le nombre : 3 000 + 400 + 50 + 2 = ?', hint: 'Additionne chaque partie !' },
        { question: '🔢 Écris en chiffres : "deux mille quatre cent dix-sept"', hint: '2 000 + 400 + 10 + 7' },
        { question: '🔢 Compare : 4 502 ___ 4 520 (<, >, ou =)', hint: 'Compare les dizaines !' },
        { question: '🔢 Quel est le chiffre des centaines dans 5 738 ?', hint: 'Le 2ème chiffre en partant de la droite' },
        { question: '🔢 Range du plus petit au plus grand : 2345, 2543, 2435', hint: 'Compare les centaines d\'abord !' }
      );
    } else {
      exercises.push(
        { question: '🔢 5 + 7 = ?', hint: 'Compte sur tes doigts !' },
        { question: '🔢 12 - 4 = ?', hint: 'Retire 4 de 12 !' },
        { question: '🔢 3 × 4 = ?', hint: '3 groupes de 4 !' },
        { question: '🔢 La moitié de 10 = ?', hint: 'Divise par 2 !' }
      );
    }
  } else {
    if (homeworkText.toLowerCase().includes('bleu')) {
      exercises.push(
        { question: '📖 Écris : oiseau', hint: 'O-I-S-E-A-U' },
        { question: '📖 Écris : fenêtre', hint: 'F-E-N-Ê-T-R-E' },
        { question: '📖 Écris : forêt', hint: 'F-O-R-Ê-T' },
        { question: '📖 Le contraire de nuit = ?', hint: 'Le contraire de nuit, c\'est...' },
        { question: '📖 Quel son dans "loin" ? [wan]', hint: 'LOIN' }
      );
    } else {
      exercises.push(
        { question: '📖 Écris : chat', hint: 'C-H-A-T' },
        { question: '📖 Écris : maison', hint: 'M-A-I-S-O-N' },
        { question: '📖 Le contraire de grand = ?', hint: 'Petit !' },
        { question: '📖 Complète : la g _ _ _ _ (animal)', hint: 'GIRAFE' }
      );
    }
  }
  
  return exercises;
}

function checkAIExercise(index) {
  homeworkState.aiExercises.splice(index, 1);
  addStars(3);
  spawnConfetti(10);
  showFeedback(true, '⭐ Bien joué ! +3 étoiles !', '🎉');
  
  if (homeworkState.aiExercises.length === 0) {
    addStars(10);
    spawnConfetti(25);
    showReward('🤖', 'Exercices IA Terminés !', 'Tu as complété tous les exercices générés par l\'IA ! +10 étoiles bonus !');
  }
  
  setTimeout(() => render(), 1500);
}

// === FEEDBACK ===
const correctMsgs = [
  'Bravo Emilie ! 🌟','Super ! 🎉','Excellent ! 🐿️','Génial ! 🪼','Parfait ! 🦭',
  'Tu es brillante ! ✨','Incroyable ! 💖','Continue comme ça ! 🔥'
];

const wrongMsgs = [
  'Presque ! Essaie encore 🐿️','Courage Emilie ! 🪼','Tu peux le faire ! 🦭',
  'Pas grave, réessaie ! ⭐','Câlin croit en toi ! 💛'
];

function showFeedback(correct, customMsg, customEmoji) {
  const overlay = document.getElementById('feedbackOverlay');
  overlay.className = 'feedback-overlay show ' + (correct ? 'correct-fb' : 'wrong-fb');
  document.getElementById('feedbackEmoji').textContent = customEmoji || (correct ? '⭐' : '💙');
  document.getElementById('feedbackAnimals').textContent = correct ? '🐿️🪼🦭' : '🐿️💪🦭';
  document.getElementById('feedbackText').textContent = customMsg ||
    (correct ? correctMsgs[Math.floor(Math.random()*correctMsgs.length)]
             : wrongMsgs[Math.floor(Math.random()*wrongMsgs.length)]);
  if (correct) spawnConfetti(8);
  setTimeout(() => {
    overlay.classList.remove('show');
    overlay.className = 'feedback-overlay';
  }, correct ? 1600 : 1200);
}

// === SYSTÈME DE POINTS ===
function addStars(n) {
  stars += n;
  xp += n * 10;

  // Update UI - null-safe
  const elStars = document.getElementById('totalStars');
  const elBadges = document.getElementById('totalBadges');
  const elLevel = document.getElementById('levelDisplay');
  const elXpBar = document.getElementById('xpBar');
  const elXpText = document.getElementById('xpText');

  if (elStars) elStars.textContent = stars;

  // Level up check
  if (xp >= level * 100) {
    level++;
    if (!badges.includes('🏆 Niveau ' + level + ' !')) badges.push('🏆 Niveau ' + level + ' !');
    if (elBadges) elBadges.textContent = badges.length;
    if (elLevel) elLevel.textContent = 'Niv.' + level;
    playLevelUp();
    showReward('🐿️🪼🦦', 'Niveau ' + level + ' !',
      'Tu as gagné un nouveau badge ! Les animaux sont fous de joie ! 🎉');
    spawnConfetti(20);
  }

  // XP bar
  const pct = Math.min(((xp % 100) / 100) * 100, 100);
  if (elXpBar) elXpBar.style.width = pct + '%';
  if (elXpText) elXpText.textContent = (xp % 100) + ' / 100 XP';
}
function updateCombo(correct) {
  if (correct) {
    combo++;
    if (combo >= 2) {
      const el = document.getElementById('comboDisplay');
      document.getElementById('comboCount').textContent = combo;
      el.classList.add('show');
      setTimeout(() => el.classList.remove('show'), 2000);
    }
  } else {
    combo = 0;
  }
}

// === REWARD MODAL ===
function showReward(mascots, title, desc) {
  document.getElementById('rewardMascots').textContent = mascots;
  document.getElementById('rewardTitle').textContent = title;
  document.getElementById('rewardDesc').textContent = desc;
  document.getElementById('rewardModal').classList.add('show');
}

function closeReward() {
  document.getElementById('rewardModal').classList.remove('show');
}

// === DATA WITH MASCOT THEMES ===
// === MATH DATA (organisé par catégorie CE1/CE2) ===
const mathData = {
  // ── Addition ──
  addition: [
    {q:'🐿️ Noisette a 14 noisettes, elle en trouve 8 de plus. Combien en a-t-elle ?',c:[19,22,20,24],a:22,mascot:'bounce'},
    {q:'🪼 Bulle voit 25 étoiles, puis 13 de plus. Combien au total ?',c:[36,38,40,35],a:38,mascot:'swim'},
    {q:'🦭 Câlin nage 17 km, puis 9 km. Distance totale ?',c:[24,27,26,28],a:26,mascot:'wiggle'},
    {q:'🐿️ 32 + 15 = ?',c:[45,47,46,48],a:47,mascot:'bounce'},
    {q:'🪼 48 + 27 = ?',c:[73,74,75,76],a:75,mascot:'swim'},
    {q:'🐿️ 56 + 19 = ?',c:[74,75,76,73],a:75,mascot:'bounce'},
    {q:'🦭 63 + 28 = ?',c:[89,91,93,90],a:91,mascot:'wiggle'},
    {q:'🪼 37 + 46 = ?',c:[81,83,82,84],a:83,mascot:'swim'},
    {q:'🐿️ 24 + 59 = ?',c:[81,83,82,80],a:83,mascot:'bounce'},
    {q:'🦭 45 + 38 = ?',c:[81,83,82,84],a:83,mascot:'wiggle'},
  ],
  
  // ── Soustraction ──
  soustraction: [
    {q:'🦭 Câlin avait 45 poissons, il en mange 18. Combien reste-t-il ?',c:[25,27,29,26],a:27,mascot:'wiggle'},
    {q:'🐿️ 63 - 28 = ?',c:[33,35,37,34],a:35,mascot:'bounce'},
    {q:'🪼 72 - 34 = ?',c:[36,38,40,37],a:38,mascot:'swim'},
    {q:'🦭 85 - 37 = ?',c:[46,48,47,49],a:48,mascot:'wiggle'},
    {q:'🐿️ 94 - 58 = ?',c:[34,36,35,37],a:36,mascot:'bounce'},
    {q:'🪼 61 - 25 = ?',c:[34,36,35,37],a:36,mascot:'swim'},
    {q:'🦭 78 - 39 = ?',c:[37,39,38,40],a:39,mascot:'wiggle'},
    {q:'🐿️ 53 - 27 = ?',c:[24,26,25,27],a:26,mascot:'bounce'},
  ],
  
  // ── Tables CE1 (×2, ×3, ×4, ×5, ×10) — Programme CE1 ──
  tables_ce1: [
    // Table de 2
    {q:'🪼 Table de 2 : 2 × 1 = ?',c:[1,2,3,4],a:2,mascot:'swim'},
    {q:'🐿️ Table de 2 : 2 × 2 = ?',c:[2,4,6,8],a:4,mascot:'bounce'},
    {q:'🦭 Table de 2 : 2 × 3 = ?',c:[4,6,8,10],a:6,mascot:'wiggle'},
    {q:'🪼 Table de 2 : 2 × 4 = ?',c:[6,8,10,12],a:8,mascot:'swim'},
    {q:'🐿️ Table de 2 : 2 × 5 = ?',c:[8,10,12,14],a:10,mascot:'bounce'},
    // Table de 3
    {q:'🦭 Table de 3 : 3 × 1 = ?',c:[2,3,4,5],a:3,mascot:'wiggle'},
    {q:'🪼 Table de 3 : 3 × 2 = ?',c:[4,6,8,9],a:6,mascot:'swim'},
    {q:'🐿️ Table de 3 : 3 × 3 = ?',c:[6,9,12,15],a:9,mascot:'bounce'},
    {q:'🦭 Table de 3 : 3 × 4 = ?',c:[9,12,15,18],a:12,mascot:'wiggle'},
    {q:'🪼 Table de 3 : 3 × 5 = ?',c:[12,15,18,21],a:15,mascot:'swim'},
    // Table de 4
    {q:'🐿️ Table de 4 : 4 × 1 = ?',c:[3,4,5,6],a:4,mascot:'bounce'},
    {q:'🦭 Table de 4 : 4 × 2 = ?',c:[6,8,10,12],a:8,mascot:'wiggle'},
    {q:'🪼 Table de 4 : 4 × 3 = ?',c:[8,12,16,20],a:12,mascot:'swim'},
    {q:'🐿️ Table de 4 : 4 × 4 = ?',c:[12,16,20,24],a:16,mascot:'bounce'},
    {q:'🦭 Table de 4 : 4 × 5 = ?',c:[16,20,24,28],a:20,mascot:'wiggle'},
    // Table de 5
    {q:'🪼 Table de 5 : 5 × 1 = ?',c:[4,5,6,7],a:5,mascot:'swim'},
    {q:'🐿️ Table de 5 : 5 × 2 = ?',c:[8,10,12,15],a:10,mascot:'bounce'},
    {q:'🦭 Table de 5 : 5 × 3 = ?',c:[10,15,20,25],a:15,mascot:'wiggle'},
    {q:'🪼 Table de 5 : 5 × 4 = ?',c:[15,20,25,30],a:20,mascot:'swim'},
    {q:'🐿️ Table de 5 : 5 × 5 = ?',c:[20,25,30,35],a:25,mascot:'bounce'},
    // Table de 10
    {q:'🦭 Table de 10 : 10 × 1 = ?',c:[5,10,15,20],a:10,mascot:'wiggle'},
    {q:'🪼 Table de 10 : 10 × 2 = ?',c:[10,20,30,40],a:20,mascot:'swim'},
    {q:'🐿️ Table de 10 : 10 × 3 = ?',c:[20,30,40,50],a:30,mascot:'bounce'},
    {q:'🦭 Table de 10 : 10 × 4 = ?',c:[30,40,50,60],a:40,mascot:'wiggle'},
    {q:'🪼 Table de 10 : 10 × 5 = ?',c:[40,50,60,70],a:50,mascot:'swim'},
    // Questions avec contexte mascotte (CE1)
    {q:'🐿️ Noisette a 3 sacs de 4 noisettes. Combien en tout ?',c:[10,12,14,8],a:12,mascot:'bounce'},
    {q:'🪼 Bulle voit 5 groupes de 2 étoiles. Combien au total ?',c:[8,10,12,6],a:10,mascot:'swim'},
    {q:'🦭 Câlin range 4 rangées de 5 poissons. Combien en tout ?',c:[15,20,25,18],a:20,mascot:'wiggle'},
    {q:'🐿️ 3 écureuils ont chacun 3 noisettes. Combien en tout ?',c:[6,9,12,15],a:9,mascot:'bounce'},
    {q:'🪼 10 méduses ont chacune 2 tentacules. Combien en tout ?',c:[15,20,25,18],a:20,mascot:'swim'},
  ],
  
  // ── Tables CE2 (×6, ×7, ×8, ×9) — Programme CE2 ──
  tables_ce2: [
    // Table de 6
    {q:'🪼 Table de 6 : 6 × 1 = ?',c:[5,6,7,8],a:6,mascot:'swim'},
    {q:'🐿️ Table de 6 : 6 × 2 = ?',c:[10,12,14,16],a:12,mascot:'bounce'},
    {q:'🦭 Table de 6 : 6 × 3 = ?',c:[15,18,21,24],a:18,mascot:'wiggle'},
    {q:'🪼 Table de 6 : 6 × 4 = ?',c:[20,24,28,32],a:24,mascot:'swim'},
    {q:'🐿️ Table de 6 : 6 × 5 = ?',c:[25,30,35,40],a:30,mascot:'bounce'},
    {q:'🦭 Table de 6 : 6 × 6 = ?',c:[30,36,42,48],a:36,mascot:'wiggle'},
    {q:'🪼 Table de 6 : 6 × 7 = ?',c:[36,42,48,54],a:42,mascot:'swim'},
    {q:'🐿️ Table de 6 : 6 × 8 = ?',c:[42,48,54,60],a:48,mascot:'bounce'},
    {q:'🦭 Table de 6 : 6 × 9 = ?',c:[48,54,60,66],a:54,mascot:'wiggle'},
    {q:'🪼 Table de 6 : 6 × 10 = ?',c:[50,60,70,80],a:60,mascot:'swim'},
    // Table de 7
    {q:'🐿️ Table de 7 : 7 × 1 = ?',c:[6,7,8,9],a:7,mascot:'bounce'},
    {q:'🦭 Table de 7 : 7 × 2 = ?',c:[12,14,16,18],a:14,mascot:'wiggle'},
    {q:'🪼 Table de 7 : 7 × 3 = ?',c:[18,21,24,27],a:21,mascot:'swim'},
    {q:'🐿️ Table de 7 : 7 × 4 = ?',c:[24,28,32,36],a:28,mascot:'bounce'},
    {q:'🦭 Table de 7 : 7 × 5 = ?',c:[30,35,40,45],a:35,mascot:'wiggle'},
    {q:'🪼 Table de 7 : 7 × 6 = ?',c:[36,42,48,54],a:42,mascot:'swim'},
    {q:'🐿️ Table de 7 : 7 × 7 = ?',c:[42,49,56,63],a:49,mascot:'bounce'},
    {q:'🦭 Table de 7 : 7 × 8 = ?',c:[48,56,64,72],a:56,mascot:'wiggle'},
    {q:'🪼 Table de 7 : 7 × 9 = ?',c:[54,63,72,81],a:63,mascot:'swim'},
    {q:'🐿️ Table de 7 : 7 × 10 = ?',c:[60,70,80,90],a:70,mascot:'bounce'},
    // Table de 8
    {q:'🦭 Table de 8 : 8 × 1 = ?',c:[7,8,9,10],a:8,mascot:'wiggle'},
    {q:'🪼 Table de 8 : 8 × 2 = ?',c:[14,16,18,20],a:16,mascot:'swim'},
    {q:'🐿️ Table de 8 : 8 × 3 = ?',c:[21,24,27,30],a:24,mascot:'bounce'},
    {q:'🦭 Table de 8 : 8 × 4 = ?',c:[28,32,36,40],a:32,mascot:'wiggle'},
    {q:'🪼 Table de 8 : 8 × 5 = ?',c:[35,40,45,50],a:40,mascot:'swim'},
    {q:'🐿️ Table de 8 : 8 × 6 = ?',c:[42,48,54,60],a:48,mascot:'bounce'},
    {q:'🦭 Table de 8 : 8 × 7 = ?',c:[49,56,63,70],a:56,mascot:'wiggle'},
    {q:'🪼 Table de 8 : 8 × 8 = ?',c:[56,64,72,80],a:64,mascot:'swim'},
    {q:'🐿️ Table de 8 : 8 × 9 = ?',c:[63,72,81,90],a:72,mascot:'bounce'},
    {q:'🦭 Table de 8 : 8 × 10 = ?',c:[70,80,90,100],a:80,mascot:'wiggle'},
    // Table de 9
    {q:'🪼 Table de 9 : 9 × 1 = ?',c:[8,9,10,11],a:9,mascot:'swim'},
    {q:'🐿️ Table de 9 : 9 × 2 = ?',c:[16,18,20,22],a:18,mascot:'bounce'},
    {q:'🦭 Table de 9 : 9 × 3 = ?',c:[24,27,30,33],a:27,mascot:'wiggle'},
    {q:'🪼 Table de 9 : 9 × 4 = ?',c:[32,36,40,44],a:36,mascot:'swim'},
    {q:'🐿️ Table de 9 : 9 × 5 = ?',c:[40,45,50,55],a:45,mascot:'bounce'},
    {q:'🦭 Table de 9 : 9 × 6 = ?',c:[48,54,60,66],a:54,mascot:'wiggle'},
    {q:'🪼 Table de 9 : 9 × 7 = ?',c:[56,63,70,77],a:63,mascot:'swim'},
    {q:'🐿️ Table de 9 : 9 × 8 = ?',c:[64,72,80,88],a:72,mascot:'bounce'},
    {q:'🦭 Table de 9 : 9 × 9 = ?',c:[72,81,90,99],a:81,mascot:'wiggle'},
    {q:'🪼 Table de 9 : 9 × 10 = ?',c:[80,90,100,110],a:90,mascot:'swim'},
    // Questions contexte mascotte (CE2)
    {q:'🦭 Câlin a 7 amis, chacun a 8 poissons. Combien en tout ?',c:[48,56,64,72],a:56,mascot:'wiggle'},
    {q:'🐿️ 9 écureuils ont chacun 6 noisettes. Combien en tout ?',c:[48,54,60,66],a:54,mascot:'bounce'},
    {q:'🪼 8 méduses ont chacune 8 tentacules. Combien en tout ?',c:[56,64,72,80],a:64,mascot:'swim'},
  ],
  
  // ── Géométrie ──
  géométrie: [
    {q:'🐿️ Combien de côtés a un carré ?',c:[3,4,5,6],a:4,mascot:'bounce'},
    {q:'🪼 Combien de côtés a un triangle ?',c:[2,3,4,5],a:3,mascot:'swim'},
    {q:'🦭 Un cercle a combien de côtés ?',c:[0,1,2,4],a:0,mascot:'wiggle'},
    {q:'🐿️ Combien de côtés a un rectangle ?',c:[3,4,5,6],a:4,mascot:'bounce'},
    {q:'🪼 Comment s\'appelle une forme avec 5 côtés ?',c:['carré','pentagone','hexagone','octogone'],a:'pentagone',mascot:'swim'},
    {q:'🦭 Comment s\'appelle une forme avec 6 côtés ?',c:['carré','pentagone','hexagone','octogone'],a:'hexagone',mascot:'wiggle'},
    {q:'🐿️ Un triangle a combien d\'angles ?',c:[2,3,4,5],a:3,mascot:'bounce'},
    {q:'🪼 Un carré a combien d\'angles droits ?',c:[2,3,4,5],a:4,mascot:'swim'},
  ]
};

// Variable pour suivre la catégorie math actuelle
let currentMathCategory = 'addition';

// Fonction pour charger un exercice de math par catégorie
function loadMathExercice(category) {
  if (!mathData[category]) category = 'addition';
  currentMathCategory = category;
  
  // Sélectionner et afficher l'exercice
  const data = mathData[category];
  const ex = data[Math.floor(Math.random() * data.length)];
  currentExercise = ex;
  
  const area = document.getElementById('mathExerciseArea');
  if (area) {
    const mascotClass = ex.mascot || 'swim';
    const mascotEmoji = '🪼';
    
    // Construire les onglets de catégorie
    const tabsHTML = `
    <div class="category-tabs" style="margin-bottom: 15px;">
      <button class="category-tab ${currentMathCategory === 'addition' ? 'active' : ''}" data-category="addition" onclick="loadMathExercice('addition')">➕ Addition</button>
      <button class="category-tab ${currentMathCategory === 'soustraction' ? 'active' : ''}" data-category="soustraction" onclick="loadMathExercice('soustraction')">➖ Soustraction</button>
      <button class="category-tab ${currentMathCategory === 'tables_ce1' ? 'active' : ''}" data-category="tables_ce1" onclick="loadMathExercice('tables_ce1')">✖️ Tables CE1</button>
      <button class="category-tab ${currentMathCategory === 'tables_ce2' ? 'active' : ''}" data-category="tables_ce2" onclick="loadMathExercice('tables_ce2')">✖️ Tables CE2</button>
      <button class="category-tab ${currentMathCategory === 'géométrie' ? 'active' : ''}" data-category="géométrie" onclick="loadMathExercice('géométrie')">📐 Géométrie</button>
    </div>`;
    
    area.innerHTML = `
      ${tabsHTML}
      <div class="question-card" style="position: relative;">
        <span class="quiz-mascot ${mascotClass}">${mascotEmoji}</span>
        <span class="exercise-mascot ${mascotClass}" style="margin-bottom: 15px;">${mascotEmoji}</span>
        <p>${ex.q}</p>
      </div>
      <div class="choices grid2">
        ${ex.c.map(c => `<button class="choice-btn" onclick="handleMathAnswer(this, ${JSON.stringify(c)}, ${JSON.stringify(ex.a)})">${c}</button>`).join('')}
      </div>
      <div class="mascot-tip"><em>🪼 Bulle : "Les maths c'est comme nager, tu vas progresser !"</em></div>
    `;
  }
  
  // Réinitialiser la sélection
  sel = null;
}

// Variable globale pour l'exercice actuel
let currentExercise = null;

// Fonction pour vérifier la réponse en mode math (mode standalone)
function handleMathAnswer(btn, chosen, answer) {
  if (sel !== null) return;
  sel = chosen;
  
  const correct = String(chosen) === String(answer);
  btn.classList.add(correct ? 'correct' : 'wrong');
  
  // Désactiver tous les boutons
  document.querySelectorAll('#mathExerciseArea .choice-btn').forEach(b => {
    b.disabled = true;
    if (String(b.textContent) === String(answer)) b.classList.add('correct');
  });
  
  if (correct) {
    score++;
    stars += 2;
    addStars(2);
    updateCombo(true);
    playCorrectSound();
    spawnConfetti(5);
    showFeedback(true);
  } else {
    updateCombo(false);
    playWrongSound();
    showFeedback(false);
  }
  
  setTimeout(() => {
    loadMathExercice(currentMathCategory);
  }, correct ? 1500 : 2000);
}

// Backward compatibility : MATH reste disponible pour les autres modules
const MATH = mathData.addition.concat(mathData.soustraction).concat(mathData.tables_ce1.slice(0, 5));

const FRENCH = [
  {q:'🦭 Câlin pense à un animal de la mer qui a des pinces. C\'est un...',c:['requin','crabe','dauphin','méduse'],a:'crabe',mascot:'wiggle'},
  {q:'🐿️ Comment s\'appelle la maison d\'un écureuil dans un arbre ?',c:['tanière','nid','terrier','grotte'],a:'nid',mascot:'bounce'},
  {q:'🪼 Quel mot signifie le contraire de "chaud" ?',c:['tiède','doux','froid','chaud'],a:'froid',mascot:'swim'},
  {q:'🦭 Lequel est un animal de la mer ?',c:['renard','phoque','lapin','écureuil'],a:'phoque',mascot:'wiggle'},
  {q:'🐿️ Qu\'est-ce qu\'une forêt ?',c:['une petite fleur','un grand nombre d\'arbres','une montagne','une rivière'],a:'un grand nombre d\'arbres',mascot:'bounce'},
  {q:'🦭 Je (manger) → Je...',c:['manges','mange','mangent','mangez'],a:'mange',mascot:'wiggle'},
  {q:'🐿️ Tu (courir) → Tu...',c:['courez','coures','cours','courent'],a:'cours',mascot:'bounce'},
  {q:'🪼 Elle (nager) → Elle...',c:['nagent','nage','nages','nagez'],a:'nage',mascot:'swim'},
  {q:'🦭 Nous (jouer) → Nous...',c:['jouons','jouez','jouent','joues'],a:'jouons',mascot:'wiggle'},
  {q:'🐿️ Ils (chanter) → Ils...',c:['chante','chantons','chantez','chantent'],a:'chantent',mascot:'bounce'},
  {q:'🦭 Comment s\'écrit le cri de la grenouille ?',c:['croasse','quoasse','coasse','koasse'],a:'coasse',mascot:'wiggle'},
  {q:'🐿️ "Le chat (et/est) mignon."',c:['et','est'],a:'est',mascot:'bounce'},
  {q:'🪼 "Emilie (a/à) une belle robe."',c:['a','à'],a:'a',mascot:'swim'},
];

const SCIENCE = [
  {q:'🐿️ Noisette est un écureuil. Que mange-t-il principalement ?',c:['de la viande','des noisettes','du poisson','des insectes'],a:'des noisettes',mascot:'bounce'},
  {q:'🪼 Comment s\'appelle le bébé du lion ?',c:['lionceau','ourson','chaton','veau'],a:'lionceau',mascot:'swim'},
  {q:'🦭 Les phoques vivent...',c:['dans la forêt','dans la mer et sur la glace','dans le désert','dans les arbres'],a:'dans la mer et sur la glace',mascot:'wiggle'},
  {q:'🐿️ Quel animal fait "coâ coâ" ?',c:['canard','grenouille','cochon','vache'],a:'grenouille',mascot:'bounce'},
  {q:'🦭 Câlin dit : combien de doigts a une main ?',c:[4,5,6,7],a:5,mascot:'wiggle'},
  {q:'🐿️ Quel organe fait battre notre sang ?',c:['le foie','le cerveau','le cœur','le poumon'],a:'le cœur',mascot:'bounce'},
  {q:'🪼 Combien d\'os a le squelette humain ?',c:['100','150','206','250'],a:'206',mascot:'swim'},
  {q:'🐿️ En quelle saison les feuilles tombent-elles ?',c:['printemps','été','automne','hiver'],a:'automne',mascot:'bounce'},
  {q:'🪼 Quelle saison vient après l\'hiver ?',c:['été','printemps','automne','hiver'],a:'printemps',mascot:'swim'},
  {q:'🦭 En quelle saison peut-on construire un bonhomme de neige ?',c:['été','printemps','automne','hiver'],a:'hiver',mascot:'wiggle'},
  {q:'🐿️ Combien y a-t-il de saisons ?',c:[2,3,4,5],a:4,mascot:'bounce'},
  {q:'🪼 Les plantes ont besoin de...',c:['soleil et eau','sable','glace','sel'],a:'soleil et eau',mascot:'swim'},
];

// === MODULE STATE ===
let module = null;
let qIdx = 0;
let sel = null;
let score = 0;
let done = false;
let exercises = [];

// === MASCOT TIPS ===
const mascotTips = {
  math: ['🐿️ Noisette : "Réfléchis bien, tu vas y arriver !"', '🪼 Bulle : "Les maths c\'est comme nager, tu vas progresser !"', '🦭 Câlin : "Chaque problème a une solution !"'],
  french: ['🦭 Câlin : "La lecture c\'est la clé de tout !"', '🐿️ Noisette : "Les mots sont des trésors à découvrir !"', '🪼 Bulle : "Écris avec le cœur !"'],
  science: ['🐿️ Noisette : "La nature c\'est magique !"', '🪼 Bulle : "Le monde est plein de surprises !"', '🦭 Câlin : "Observe bien autour de toi !"']
};

function getMascotTip(moduleName) {
  const tips = mascotTips[moduleName] || mascotTips.math;
  return tips[Math.floor(Math.random() * tips.length)];
}

// === RENDER ===
function render() {
  const app = document.getElementById('app');
  if (screen === 'home') app.innerHTML = homeHTML();
  else if (screen === 'rocketRace') app.innerHTML = rocketRaceHTML();
  else if (screen === 'wordHunt') app.innerHTML = wordHuntHTML();
  else if (screen === 'stickers') app.innerHTML = stickerAlbumHTML();
  else if (screen === 'homework') app.innerHTML = homeworkHTML();
  else if (screen === 'lessons') app.innerHTML = lessonsHTML();
  else if (screen === 'lessonDetail') app.innerHTML = lessonDetailHTML();
  else if (screen === 'math' || screen === 'french' || screen === 'science') {
    if (done) app.innerHTML = resultHTML();
    else app.innerHTML = quizHTML();
  } else if (screen === 'trophy') app.innerHTML = trophyHTML();
  else if (screen === 'parental') app.innerHTML = parentalHTML();
  attachListeners();
  initStickerAlbum();
}

function homeHTML() {
  const xpPct = Math.min(((xp % 100) / 100) * 100, 100);
  return `<div class="header screen-transition">
    <span class="star">🌟</span>
    <h1>Bonjour Emilie !</h1>
    <p>Qu'est-ce qu'on apprend aujourd'hui ?</p>
    <div class="header-mascots">
      <div class="mascot-header squirrel" onclick="talkMascot('squirrel')" title="Noisette dit bonjour !">🐿️</div>
      <div class="mascot-header jelly" onclick="talkMascot('jelly')" title="Bulle flotte !">🪼</div>
      <div class="mascot-header seal" onclick="talkMascot('seal')" title="Câlin t'encourage !">🦭</div>
    </div>
  </div>
  
  <div class="stats-bar">
    <div class="stat-item"><span>⭐</span><span id="totalStars">${stars}</span> étoiles</div>
    <div class="stat-item"><span>🏅</span><span id="totalBadges">${badges.length}</span> badges</div>
    <div class="stat-item"><span>🔥</span><span>${streak}</span> jours</div>
    <div class="stat-item"><span>🎯</span><span id="levelDisplay">Niv.${level}</span></div>
  </div>
  
  <div class="level-section">
    <div class="level-title">
      <span>🐣 Début</span>
      <span id="xpText">${xp % 100} / 100 XP</span>
      <span>🦋 Expert</span>
    </div>
    <div class="progress-bar">
      <div class="progress-fill" id="xpBar" style="width: ${xpPct}%"></div>
    </div>
    <div class="progress-animals">
      <span class="progress-animal" title="Noisette">🐿️</span>
      <span class="progress-animal" title="Bulle">🪼</span>
      <span class="progress-animal" title="Câlin">🦭</span>
      <span class="progress-animal" title="Étoile">⭐</span>
      <span class="progress-animal" title="Trophée">🏆</span>
    </div>
  </div>
  
  <div class="streak-banner">
    <div class="streak-icon">🦭</div>
    <div class="streak-text">
      <strong>Série de ${streak} jour${streak > 1 ? 's' : ''} !</strong><br>
      <small>Continue comme ça, Câlin est fier de toi !</small>
    </div>
    <div class="streak-animals">🐿️🪼🦭</div>
  </div>
  
  <div class="daily-challenge-detail ${dailyChallenge.completed ? 'completed' : ''}" onclick="handleDailyChallenge()">
    <div class="challenge-header">
      <span class="challenge-badge">⚡ DÉFI DU JOUR</span>
      ${dailyChallenge.completed ? '<span class="challenge-badge" style="background: rgba(255,255,255,0.5)">✓ Complété</span>' : ''}
    </div>
    <div class="challenge-title">${dailyChallenge.title}</div>
    <div class="challenge-desc">${dailyChallenge.description}</div>
    <div class="challenge-reward">
      <span class="challenge-reward-icon">${dailyChallenge.completed ? '✅' : '🎁'}</span>
      <span>${dailyChallenge.completed ? 'Récompense collectée !' : dailyChallenge.reward}</span>
    </div>
    <div class="challenge-animals-large">🐿️🪼🦭</div>
  </div>
  
  <button class="homework-main-btn screen-transition" onclick="screen='homework';render()">
    <div class="homework-btn-content">
      <span style="font-size: 2rem;">📚</span>
      <div class="homework-btn-text">
        <span class="homework-btn-title">Devoirs du Jour</span>
        <span class="homework-btn-subtitle">Clique pour commencer !</span>
      </div>
    </div>
    <span class="homework-btn-arrow">→</span>
  </button>
  
  <button class="lessons-main-btn screen-transition" onclick="screen='lessons';render()">
    <div class="lessons-btn-content">
      <span style="font-size: 2rem;">📖</span>
      <div class="lessons-btn-text">
        <span class="lessons-btn-title">Leçons CE1 & CE2</span>
        <span class="lessons-btn-subtitle">Apprends avec Noisette !</span>
      </div>
    </div>
    <span class="lessons-btn-arrow">→</span>
  </button>
  
  <div class="mini-games-section screen-transition">
    <div class="mini-games-title">🎮 Mini-Jeux Ludiques</div>
    <div class="mini-games-grid">
      <button class="mini-game-btn rocket" onclick="startRocketRace()">
        <span class="emoji">🚀</span>
        <span>Course de Fusées</span>
      </button>
      <button class="mini-game-btn word-hunt" onclick="startWordHunt()">
        <span class="emoji">🔤</span>
        <span>Chasse aux Mots</span>
      </button>
      <button class="mini-game-btn stickers" onclick="screen='stickers';render()">
        <span class="emoji">🏷️</span>
        <span>Mes Stickers</span>
      </button>
      <button class="mini-game-btn stickers" onclick="screen='stickers';render()">
        <span class="emoji">${stickerAlbum.unlockedCount}/20</span>
        <span>Album</span>
      </button>
    </div>
  </div>
  
  <div class="grid">
    <button class="subject-btn btn-math" data-subject="math">
      <span class="emoji">🔢</span><span>Maths</span>
      <span class="card-mascot jelly">🪼</span>
    </button>
    <button class="subject-btn btn-french" data-subject="french">
      <span class="emoji">📖</span><span>Français</span>
      <span class="card-mascot seal">🦭</span>
    </button>
    <button class="subject-btn btn-science" data-subject="science">
      <span class="emoji">🔬</span><span>Sciences</span>
      <span class="card-mascot">🐿️</span>
    </button>
    <button class="subject-btn btn-trophy" data-subject="trophy">
      <span class="emoji">🏆</span><span>Trophées</span>
    </button>
  </div>
  
  <button class="parental-link" data-action="parental">👨‍👩‍👧 Espace parents</button>`;
}

function quizHTML() {
  // Pour le module Maths, utiliser le système d'onglets avec #mathExerciseArea
  if (module === 'math') {
    return `<div class="module-header screen-transition">
      <button class="back-btn" data-action="back">⬅️</button>
      <h2 class="module-title math">🔢 Maths avec 🪼 Bulle</h2>
                  <span class='badge-count badge-math' id='mathProgress'>${score}/10</span>
    </div>
    
    <div id="mathExerciseArea"></div>`;
  }
  
  // Pour les autres modules (français, sciences), utiliser le système existant
  const ex = exercises[qIdx];
  const prog = ((qIdx) / exercises.length) * 100;
  const cls = module === 'math' ? 'math' : module === 'french' ? 'french' : 'science';
  const mascotClass = ex.mascot || 'bounce';
  const mascotEmoji = module === 'math' ? '🪼' : module === 'french' ? '🦭' : '🐿️';
  const gridClass = typeof ex.a === 'number' && ex.c.length === 4 ? 'grid2' : '';
  
  return `<div class="module-header screen-transition">
    <button class="back-btn" data-action="back">⬅️</button>
    <h2 class="module-title ${cls}">${module === 'math' ? '🔢 Maths avec 🪼 Bulle' : module === 'french' ? '📖 Français avec 🦭 Câlin' : '🔬 Sciences avec 🐿️ Noisette'}</h2>
    <span class="badge-count badge-${cls}">${qIdx + 1}/${exercises.length}</span>
  </div>
  
  <div class="progress-bar"><div class="progress-fill progress-${cls}" style="width:${prog}%"></div></div>
  
  <div class="question-card" style="position: relative;">
    <span class="quiz-mascot ${mascotClass}">${mascotEmoji}</span>
    <span class="exercise-mascot ${mascotClass}" style="margin-bottom: 15px;">${mascotEmoji}</span>
    <p>${ex.q}</p>
  </div>
  
  <div class="choices ${gridClass}">
    ${ex.c.map(c => `<button class="choice-btn ${getBtnClass(c)}" data-choice='${JSON.stringify(c)}'>${c}</button>`).join('')}
  </div>
  
  <div class="mascot-tip"><em>${getMascotTip(module)}</em></div>`;
}

function resultHTML() {
  const emoji = score >= 8 ? '🏆' : score >= 5 ? '😊' : '💪';
  const cls = module === 'math' ? 'blue' : module === 'french' ? 'pink' : 'green';
  const mascots = score >= 8 ? '🐿️🪼🦭' : '🐿️🦭';
  return `<div class="card result-screen screen-transition">
    <span class="result-emoji">${emoji}</span>
    <div style="font-size: 2rem; margin-bottom: 10px;">${mascots}</div>
    <h2 class="result-title">Bravo Emilie !</h2>
    <p class="result-score">Tu as eu <strong>${score}/${exercises.length}</strong> bonnes réponses !</p>
    <p class="result-stars">+${score * 2} ⭐ étoiles gagnées</p>
    <button class="primary-btn btn-${cls}" data-action="home">🏠 Retour à l'accueil</button>
  </div>`;
}

function trophyHTML() {
  return `<div class="module-header screen-transition">
    <button class="back-btn" data-action="back">⬅️</button>
    <h2 class="module-title trophy">🏆 Mes Trophées 🐿️🪼🦭</h2>
  </div>
  <div class="trophies-grid">
    <div class="trophy-card"><span class="trophy-icon">⭐</span><div class="trophy-value">${stars}</div><div class="trophy-label">étoiles</div></div>
    <div class="trophy-card"><span class="trophy-icon">🏅</span><div class="trophy-value">${badges.length}</div><div class="trophy-label">badges</div></div>
    <div class="trophy-card"><span class="trophy-icon">🎯</span><div class="trophy-value">Niv.${level}</div><div class="trophy-label">niveau</div></div>
    <div class="trophy-card"><span class="trophy-icon">🔥</span><div class="trophy-value">${streak}</div><div class="trophy-label">jours</div></div>
  </div>
  <div class="card">
    <h3 style="font-weight:900;margin-bottom:12px">🏅 Mes Badges</h3>
    ${badges.length ? `<div class="badges-list">${badges.map(b => `<div class="badge-item">${b}</div>`).join('')}</div>` : `<p class="empty-msg">Continue les exercices pour gagner des badges ! 💪🐿️🪼🦭</p>`}
  </div>
  <div style="text-align:center;padding:20px;font-size:1.5rem;">🐿️🪼🦭</div>`;
}

// === ROCKET RACE HTML ===
function rocketRaceHTML() {
  const q = rocketGame.questions[rocketGame.currentQ];
  const progressPct = Math.round((rocketGame.currentQ / rocketGame.questions.length) * 100);
  
  return `<div class="module-header screen-transition">
    <button class="back-btn" onclick="endRocketRace();screen='home';render();">✕</button>
    <h2 class="module-title" style="color: #667eea;">🚀 Course de Fusées</h2>
    <span class="badge-count badge-math">${rocketGame.currentQ + 1}/${rocketGame.questions.length}</span>
  </div>
  
  <div class="rocket-race-container">
    <div class="rocket-race-header">
      <div style="font-weight: bold;">👩 Emilie vs 🪼 Bulle</div>
      <div class="rocket-race-timer ${rocketGame.timeLeft <= 10 ? 'warning' : ''}" id="rocketTimer">${rocketGame.timeLeft}s</div>
    </div>
    
    <div class="rocket-track">
      <div class="rocket-lane emilie">
        <div class="rocket-label">👩 Emilie</div>
        <div class="rocket-bar-container">
          <div class="rocket-bar emilie" style="width: ${rocketGame.emilieProgress}%">
            <span class="rocket-emoji">🚀</span>
          </div>
        </div>
      </div>
      <div class="rocket-lane bulle">
        <div class="rocket-label">🪼 Bulle</div>
        <div class="rocket-bar-container">
          <div class="rocket-bar bulle" style="width: ${rocketGame.bulleProgress}%">
            <span class="rocket-emoji">🪁</span>
          </div>
        </div>
      </div>
    </div>
    
    <div class="progress-bar">
      <div class="progress-fill" style="width: ${progressPct}%"></div>
    </div>
    
    <div class="rocket-question">
      <p>${q.q}</p>
      <div class="rocket-choices">
        ${q.c.map(ans => `<button class="rocket-choice" onclick="handleRocketChoice(${ans})">${ans}</button>`).join('')}
      </div>
    </div>
    
    <div class="rocket-score">
      Score: ${rocketGame.score} bonnes réponses | Progrès: ${rocketGame.emilieProgress}%
    </div>
  </div>
  
  <div class="mascot-tip" style="text-align: center;">
    <em>🪼 Bulle essaie de gagner aussi ! Réponds vite !</em>
  </div>`;
}

// === WORD HUNT HTML ===
function wordHuntHTML() {
  const theme = wordHuntThemes[wordHuntGame.themeIndex];
  
  return `<div class="module-header screen-transition">
    <button class="back-btn" onclick="screen='home';render();">✕</button>
    <h2 class="module-title" style="color: #db2777;">🔤 Chasse aux Mots</h2>
    <span class="badge-count badge-french">${wordHuntGame.foundWords.length}/${wordHuntGame.words.length}</span>
  </div>
  
  <div class="word-hunt-container">
    <div class="word-hunt-header">
      <div class="word-hunt-theme">📚 Thème: ${wordHuntGame.theme}</div>
      <div class="word-hunt-progress">${wordHuntGame.foundWords.length}/${wordHuntGame.words.length} mots</div>
    </div>
    
    <div class="word-hunt-words">
      ${wordHuntGame.words.map((w, i) => `<span class="word-to-find ${wordHuntGame.foundWords.includes(i) ? 'found' : ''}">${w}</span>`).join('')}
    </div>
    
    <div class="word-hunt-grid">
      ${wordHuntGame.grid.map((cell, i) => `
        <div class="word-hunt-cell ${wordHuntGame.selectedCells.includes(i) ? 'selected' : ''} ${cell.found ? 'found' : ''}" 
             onclick="toggleWordHuntCell(${i})">${cell.letter}</div>
      `).join('')}
    </div>
    
    <div class="word-hunt-actions">
      <button class="word-hunt-btn clear" onclick="clearWordHuntSelection()">🗑️ Effacer</button>
      <button class="word-hunt-btn submit" onclick="submitWordHunt()">✓ Valider</button>
    </div>
  </div>
  
  <div class="mascot-tip" style="text-align: center;">
    <em>🦭 Câlin dit : Clique sur les lettres pour former un mot, puis valide !</em>
  </div>`;
}

// === STICKER ALBUM HTML ===
function stickerAlbumHTML() {
  const progress = (stickerAlbum.unlockedCount / 20) * 100;
  
  return `<div class="module-header screen-transition">
    <button class="back-btn" data-action="back">⬅️</button>
    <h2 class="module-title" style="color: #ca8a04;">🏷️ Mon Album de Stickers</h2>
    <span class="badge-count" style="background: #fef9c3; color: #ca8a04;">${stickerAlbum.unlockedCount}/20</span>
  </div>
  
  <div class="sticker-album-container">
    <div class="sticker-album-header">
      <h2>🐿️🪼🦭 Mes Mascottes</h2>
      <p class="sticker-count">${stickerAlbum.unlockedCount} stickers collectés sur 20</p>
    </div>
    
    <div class="sticker-grid">
      ${stickerAlbum.stickers.map((sticker, i) => {
        if (sticker) {
          return `<div class="sticker-slot filled" onclick="showStickerDetail(${i})">${sticker.emoji}</div>`;
        } else {
          return `<div class="sticker-slot empty locked">❓</div>`;
        }
      }).join('')}
    </div>
    
    <div class="sticker-progress-bar">
      <div class="sticker-progress-fill" style="width: ${progress}%"></div>
    </div>
    
    <div class="sticker-unlock-hint">
      ${stickerAlbum.unlockedCount < 2 ? '🎮 Complète des mini-jeux pour débloquer des stickers !' : '⭐ Continue à jouer pour compléter ton album !'}
    </div>
  </div>
  
  <div class="card" style="text-align: center;">
    <h3 style="margin-bottom: 10px;">Comment gagner des stickers ?</h3>
    <p style="color: #666;">
      🏆 Gagne la Course de Fusées → 1 sticker !<br>
      🔤 Termine la Chasse aux Mots → 1 sticker !<br>
      ⭐ Complète un Défi quotidien → Étoiles bonus !
    </p>
    <div style="font-size: 2rem; margin-top: 15px;">🐿️🪼🦭</div>
  </div>`;
}

// === DAILY CHALLENGE HANDLER ===
function handleDailyChallenge() {
  if (dailyChallenge.completed) {
    showFeedback(true, 'Tu as déjà complété ce défi aujourd\'hui ! 🎉', '✅');
    return;
  }
  
  if (dailyChallenge.title === 'Course de Fusées') {
    startRocketRace();
  } else if (dailyChallenge.title === 'Chasse aux Mots') {
    startWordHunt();
  } else if (dailyChallenge.title === 'Quiz Maths') {
    startModule('math');
  } else if (dailyChallenge.title === 'Quiz Français') {
    startModule('french');
  }
}

function parentalHTML() {
  return `<div class="card parental-lock screen-transition">
    <div style="font-size:40px;margin-bottom:16px">👨‍👩‍👧</div>
    <h2 style="font-size:22px;font-weight:900;margin-bottom:8px">Espace Parents</h2>
    <input type="password" maxlength="4" class="pin-input" id="pin" placeholder="••••">
    <p class="error-msg" id="error" style="display:none">Code incorrect !</p>
    <button class="primary-btn btn-purple" data-action="unlock">Entrer</button>
    <button class="parental-link" data-action="back">Retour</button>
    ${badges.length ? `<div class="parent-info">
      <strong>📊 Statistiques d'Emilie</strong><br>
      ⭐ ${stars} étoiles | 🏅 ${badges.length} badges<br>
      🎯 Niveau ${level} | 🔥 ${streak} jours de suite<br><br>
      <strong>🐿️🪼🦭 Les mascottes</strong><br>
      Noisette, Bulle et Câlin accompagnent Emilie dans son apprentissage !<br><br>
      <strong>Badges:</strong> ${badges.join(', ')}
    </div>` : ''}
  </div>`;
}

function getBtnClass(c) {
  if (sel === null) return '';
  const ex = exercises[qIdx];
  if (JSON.stringify(c) === JSON.stringify(ex.a)) return 'correct';
  if (JSON.stringify(c) === JSON.stringify(sel)) return 'wrong';
  return '';
}

// === ACTIONS ===
function attachListeners() {
  document.querySelectorAll('[data-subject]').forEach(btn => {
    btn.onclick = () => startModule(btn.dataset.subject);
  });
    document.querySelectorAll('[data-category]').forEach(btn => {
    btn.onclick = () => loadMathExercice(btn.dataset.category);
  });
  document.querySelectorAll('[data-choice]').forEach(btn => {
    btn.onclick = () => handleChoice(JSON.parse(btn.dataset.choice));
  });
  document.querySelectorAll('[data-action]').forEach(btn => {
    btn.onclick = () => {
      if (btn.dataset.action === 'back') { screen = 'home'; render(); }
      else if (btn.dataset.action === 'home') { screen = 'home'; render(); }
      else if (btn.dataset.action === 'parental') { screen = 'parental'; render(); }
      else if (btn.dataset.action === 'unlock') { unlockParental(); }
    };
  });
}

function startModule(sub) {
  module = sub;
  if (sub === 'trophy') { screen = 'trophy'; render(); return; }
  qIdx = 0; sel = null; score = 0; done = false; combo = 0;
  
  if (sub === 'math') {
    // Mode Maths avec onglets par catégorie
    screen = 'math';
    playBeep(500, 0.1, 'sine');
    currentMathCategory = 'addition';
    render();
    // Charger le premier exercice
    loadMathExercice('addition');
  } else {
    // Autres modules (français, sciences) utilisent le système de quiz existant
    let data;
    if (sub === 'math') data = MATH;
    else if (sub === 'french') data = FRENCH;
    else data = SCIENCE;
    
    exercises = shuffle(data.slice()).slice(0, 10);
    screen = sub;
    playBeep(500, 0.1, 'sine');
    render();
  }
}

function handleChoice(choice) {
    if (sel !== null) return;
  sel = choice;
  const ex = exercises[qIdx];
  const correct = JSON.stringify(choice) === JSON.stringify(ex.a);
  
  if (correct) {
    score++;
    stars += 2;
    addStars(2);
    updateCombo(true);
    playCorrectSound();
    spawnConfetti(5);
        showFeedback(correct);
  } else {
    updateCombo(false);
    playWrongSound();
        showFeedback(correct);
  }
  
  render();
  
  setTimeout(() => {
    if (qIdx + 1 >= exercises.length) {
      done = true;
      
      // Award badges
      if (module === 'math' && score >= 8 && !badges.includes('🏆 Super Mathématicien·ne !')) {
        badges.push('🏆 Super Mathématicien·ne !');
        showReward('🪼', 'Badge Mathématiques !', 'Tu es une vraie mathématicienne avec Bulle !');
      }
      if (module === 'french' && score >= 8 && !badges.includes('📚 Championne de Français !')) {
        badges.push('📚 Championne de Français !');
        showReward('🦭', 'Badge Français !', 'Câlin est impressionné par ta maîtrise du français !');
      }
      if (module === 'science' && score >= 6 && !badges.includes('🔬 Petite Scientifique !')) {
        badges.push('🔬 Petite Scientifique !');
        showReward('🐿️', 'Badge Sciences !', 'Noisette découvre le monde avec toi !');
      }
      
      // Level up celebration
      if (score >= 8) {
        spawnConfetti(15);
      }
    } else {
      qIdx++;
      sel = null;
    }
    render();
  }, correct ? 1200 : 1500);
}

function unlockParental() {
  const pin = document.getElementById('pin').value;
  const err = document.getElementById('error');
  if (pin === '1234') { 
    playBeep(600, 0.1, 'sine');
        screen = 'parental';
    render(); 
  }
  else { 
    playBeep(200, 0.2, 'sawtooth', 0.2);
    err.style.display = 'block'; 
    document.getElementById('pin').classList.add('error'); 
    setTimeout(() => { 
      err.style.display = 'none'; 
      document.getElementById('pin').classList.remove('error'); 
    }, 2000); 
  }
}

function shuffle(arr) {
  return arr.sort(() => Math.random() - 0.5);
}

// === INIT ===
document.addEventListener('DOMContentLoaded', () => {
  createFloatingAnimals();
  
  // Welcome message
  setTimeout(() => {
    showFeedback(true, 'Bienvenue Emilie ! 🐿️🪼🦭 Noisette, Bulle et Câlin sont là pour t\'aider !', '🌟');
  }, 800);
});

render();
