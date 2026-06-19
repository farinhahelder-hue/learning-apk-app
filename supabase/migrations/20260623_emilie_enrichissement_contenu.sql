-- Emilie App - Enrichissement contenu pédagogique (base_de_donnees_emilie)
-- Ajoute listes de mots, fiches sons, grammaire, lectures, poésies, problèmes, géométrie

-- =====================================================
-- 1. FICHES SONS → emilie_orthographe
-- =====================================================
INSERT INTO emilie_orthographe (regle, explication, mots_exemples, niveau)
SELECT * FROM (VALUES
  ('Le son [t]', 'Le son [t] peut s''écrire "t", "tt" ou "th" selon les mots. Il se trouve au début, au milieu ou à la fin des mots.', 'la tête, une table, la terre, le travail, une tartine, le tableau, un train, le téléphone, le maître, un stylo, la montagne, un manteau, l''hôpital, un château, une histoire, une dictée', 1),
  ('Le son [d]', 'Le son [d] s''écrit toujours "d". Il ne se confond pas avec le [t] qui est plus sec.', 'une dent, une dame, un dessin, le directeur, une dictée, le dos, lundi, mardi, mercredi, jeudi, vendredi, samedi, dimanche, droit, timide, froid, danser, donner, dire, demander', 1),
  ('Le son [p]', 'Le son [p] s''écrit "p" ou "pp". Attention à ne pas le confondre avec le [b].', 'une poule, mes parents, mon père, du papier, un pied, la pluie, la peau, un lapin, une pomme, mon grand-père, l''après-midi, un chapeau, un hôpital, une poupée', 1),
  ('Le son [f]', 'Le son [f] s''écrit "f", "ff" ou "ph". "ph" vient du grec ancien.', 'j''ai faim, ma famille, la farine, une fée, une femme, une ferme, le fermier, la fête, du feu, une feuille, un fils, des fleurs, mon frère, du fromage', 1),
  ('Le son [ɔ̃] (on/om)', 'Le son [ɔ̃] s''écrit "on" devant une consonne ou à la fin, "om" devant "p" ou "b".', 'mon oncle, bonjour, la confiture, le monde, un pont, un ballon, un garçon, une maison, un camion, une chanson, un nombre, un nom', 1),
  ('Le son [wa] (oi/oy)', 'Le son [wa] s''écrit "oi" la plupart du temps, ou "oy" devant une voyelle.', 'un oiseau, une voiture, une étoile, le soir, j''ai soif, le bois, le roi, j''ai froid, une fois, une histoire, un voyage, joyeux', 1),
  ('Le son [ɛ] (è/ê/ai/ei)', 'Le son [ɛ] peut s''écrire de plusieurs façons : "è" avec accent grave, "ê" avec accent circonflexe, "ai" ou "ei".', 'ma mère, l''après-midi, la tête, la fête, une maison, vrai, la neige, le soleil, treize', 1),
  ('Le son [z] (s/z/x)', 'Le son [z] s''écrit "s" entre deux voyelles, "z" au début des mots, ou "x" dans six/dix/deuxième.', 'la maison, mon cousin, un oiseau, une cerise, le lézard, le zoo, zéro, onze, deuxième, sixième', 1),
  ('Le son [s] (s/ss/c/ç/x/sc/t)', 'Le son [s] a de nombreuses orthographes : "s" en début ou fin, "ss" entre voyelles, "c" devant e,i,y, "ç" devant a,o,u.', 'une salade, le sport, ma sœur, la classe, la maîtresse, une cerise, cinq, un garçon, six, la piscine, la récréation', 1),
  ('Le son [k] (c/qu/ch/cc/k/q)', 'Le son [k] s''écrit "c" devant a,o,u, "qu" devant e,i,y, "ch" dans certains mots, "k" dans les mots étrangers.', 'le calcul, du café, un canard, quatre, qui, quoi, Christine, un accent, un koala, cinq, un coq', 1),
  ('Le son [i] (i/y)', 'Le son [i] s''écrit "i" la plupart du temps, ou "y" dans certains mots (souvent à la fin ou au milieu).', 'lundi, six, dix, un animal, un pyjama, le cycle', 1),
  ('Le son [ʒ] (j/ge/gi/gy)', 'Le son [ʒ] s''écrit "j" devant toutes les voyelles, ou "g" devant e et i. "ge" devant a/o/u donne le son [ʒ].', 'jouer, un jour, jeudi, manger, rouge, une cage, un plongeoir, de la magie, la gymnastique', 1)
) AS t
WHERE NOT EXISTS (SELECT 1 FROM emilie_orthographe WHERE regle LIKE 'Le son [%]' LIMIT 1);

-- =====================================================
-- 2. LISTES DE MOTS À SAVOIR → emilie_dictees
-- =====================================================
INSERT INTO emilie_dictees (titre, texte, niveau, nb_mots)
SELECT * FROM (VALUES
  ('Liste 1 - Les chiffres', 'zéro un deux trois quatre cinq six sept huit neuf', 1, 10),
  ('Liste 2 - Nombres 10-19', 'dix onze douze treize quatorze quinze seize dix-sept dix-huit dix-neuf', 1, 10),
  ('Liste 3 - Nombres 20-100', 'vingt trente quarante cinquante soixante soixante-dix quatre-vingt quatre-vingt-dix cent', 1, 10),
  ('Liste 4 - Mots courants (tête-travail)', 'la tête un train la terre un manteau des manteaux toujours une histoire très attraper le travail il travaille elles travaillent', 1, 12),
  ('Liste 5 - Mots courants (aujourd''hui-demander)', 'aujourd''hui une dent demain le dos devant donner nous donnons derrière dire elle dit vous dites dehors demander vous demandez', 2, 14),
  ('Liste 6 - Mots courants (pied-pendant)', 'un pied des pieds mes parents petit petits petite petites la pluie après l''après-midi parce que près de appeler Je m''appelle pendant', 2, 15),
  ('Liste 7 - Mots courants (blanc-habiller)', 'blanc blancs blanche blanches un bras bleu bleus bleue bleues de l''herbe bonjour une botte beaucoup une jambe bien s''habiller', 2, 16),
  ('Liste 8 - Mots courants (faim-froide)', 'j''ai faim la fête une femme un fruit une feuille des feuilles un enfant des enfants une fille un fils fort forte faire il fait froid froide', 2, 16),
  ('Liste 9 - Mots courants (vendredi-vont)', 'vendredi vieux une ville vieille vieilles un cheval des chevaux je vais avec il va avant elles vont', 2, 12),
  ('Liste 10 - Mots courants (dimanche-chacune)', 'dimanche un chapeau chanter elles chantent un cheveu chaud chaude à gauche un chien chercher nous cherchons un chat chacun chacune', 2, 14)
) AS t
WHERE NOT EXISTS (SELECT 1 FROM emilie_dictees WHERE titre LIKE 'Liste %' LIMIT 1);

-- =====================================================
-- 3. GRAMMAIRE : RÈGLES SUPPLÉMENTAIRES
-- =====================================================
INSERT INTO emilie_grammaire (categorie, notion, explication, exemple, niveau)
SELECT * FROM (VALUES
  ('types_de_phrases', 'La phrase', 'Une phrase commence par une majuscule et se termine par un point (. / ? / ! / ...). Le point d''exclamation (!) donne un ordre ou exprime une émotion.', 'Bonjour ! Comment vas-tu ?', 1),
  ('classes_de_mots', 'Le nom commun et le nom propre', 'Le nom commun désigne une personne, un animal, un objet, un lieu ou une chose en général. Le nom propre désigne un être ou un lieu unique et prend une majuscule.', 'un chat (commun), Garfield (propre)', 1),
  ('classes_de_mots', 'L''adjectif qualificatif (accord)', 'L''adjectif donne des informations sur le nom. Il s''accorde en genre et en nombre avec le nom qu''il qualifie.', 'une jolie robe, des jolis chats', 1),
  ('classes_de_mots', 'Le verbe et le sujet', 'Le verbe désigne une action ou un état. Le sujet fait l''action. L''infinitif est le nom de famille du verbe.', 'Le chat (sujet) mange (verbe) une souris.', 1)
) AS t
WHERE NOT EXISTS (SELECT 1 FROM emilie_grammaire WHERE notion = 'La phrase' AND categorie = 'types_de_phrases' LIMIT 1);

-- =====================================================
-- 4. CONJUGAISONS (présent des verbes du 1er groupe)
-- =====================================================
INSERT INTO conjugaison_exercices (verbe, pronom, bonne_reponse, mauvaise1, mauvaise2, groupe)
SELECT * FROM (VALUES
  ('parler', 'je', 'parle', 'parles', 'parlent', 1),
  ('parler', 'tu', 'parles', 'parle', 'parlent', 1),
  ('parler', 'il/elle', 'parle', 'parles', 'parlent', 1),
  ('parler', 'nous', 'parlons', 'parlez', 'parlent', 1),
  ('parler', 'vous', 'parlez', 'parlons', 'parlent', 1),
  ('parler', 'ils/elles', 'parlent', 'parle', 'parlons', 1),
  ('danser', 'je', 'danse', 'danses', 'dansent', 1),
  ('danser', 'tu', 'danses', 'danse', 'dansent', 1),
  ('danser', 'il/elle', 'danse', 'danses', 'dansent', 1),
  ('danser', 'nous', 'dansons', 'dansez', 'dansent', 1),
  ('danser', 'vous', 'dansez', 'dansons', 'dansent', 1),
  ('danser', 'ils/elles', 'dansent', 'danse', 'dansons', 1),
  ('chanter', 'je', 'chante', 'chantes', 'chantent', 1),
  ('chanter', 'tu', 'chantes', 'chante', 'chantent', 1),
  ('chanter', 'il/elle', 'chante', 'chantes', 'chantent', 1),
  ('chanter', 'nous', 'chantons', 'chantez', 'chantent', 1),
  ('chanter', 'vous', 'chantez', 'chantons', 'chantent', 1),
  ('chanter', 'ils/elles', 'chantent', 'chante', 'chantons', 1),
  ('jouer', 'je', 'joue', 'joues', 'jouent', 1),
  ('jouer', 'tu', 'joues', 'joue', 'jouent', 1),
  ('jouer', 'il/elle', 'joue', 'joues', 'jouent', 1),
  ('jouer', 'nous', 'jouons', 'jouez', 'jouent', 1),
  ('jouer', 'vous', 'jouez', 'jouons', 'jouent', 1),
  ('jouer', 'ils/elles', 'jouent', 'joue', 'jouons', 1)
) AS t
WHERE NOT EXISTS (SELECT 1 FROM conjugaison_exercices WHERE verbe = 'parler' LIMIT 1);

-- =====================================================
-- 5. HISTOIRES SUPPLÉMENTAIRES → emilie_lecture
-- =====================================================
INSERT INTO emilie_lecture (titre, texte, type, niveau)
SELECT * FROM (VALUES
  ('La Petite Poule Rousse', 'La petite poule rousse cherche des grains de blé. "Qui veut m''aider à planter ce blé ?" demande-t-elle. "Pas moi !" dit le chat. "Pas moi !" dit le chien. "Pas moi !" dit le canard. Alors la petite poule rousse plante le blé toute seule. Elle le coupe, le bat et le moud toute seule. Elle fait du pain toute seule. Et quand le pain est cuit, elle le mange toute seule. Miaaam !', 'narratif', 1),
  ('Petit Gaston', 'Petit Gaston le hérisson se promène dans le jardin. Il cherche des escargots pour son dîner. Soudain, il voit une belle feuille rouge qui bouge. C''est une chenille qui se promène. "Bonjour !" dit Gaston. "Bonjour !" dit la chenille. Ils deviennent amis et jouent à cache-cache sous les feuilles.', 'narratif', 1),
  ('Pilotin le petit poisson', 'Pilotin est un petit poisson rouge qui vit dans l''océan. Il est tout petit et ses amis sont gros. "Je voudrais être grand !" dit Pilotin. Un jour, un gros poisson veut manger Pilotin. Mais Pilotin est trop petit et se cache dans un trou du récif. "Ouf ! C''est pratique d''être petit !" dit-il en riant.', 'narratif', 1),
  ('Le Lapin et le Renard', 'Un lapin se promène dans la forêt. Un renard arrive et dit : "Je vais te manger !" Le lapin répond : "Attends ! J''ai un frère plus gros que toi !" Le renard a peur et s''enfuit. Le lapin rit : "Je n''ai même pas de frère ! Mais j''ai de la ruse !"', 'narratif', 2),
  ('Le Renard Glouton', 'Un renard voit une grappe de raisin tout en haut d''une vigne. Il saute, il saute, mais il n''arrive pas à l''atteindre. "Tant pis ! dit-il, le raisin est trop vert, il n''est pas bon !" La morale : on critique souvent ce qu''on ne peut pas avoir.', 'narratif', 2),
  ('Le loup qui ne voulait plus marcher', 'Loup en a assez de marcher. Il essaie le vélo, mais ça cahote. Il essaie la voiture, mais ça va trop vite. Il essaie le cheval, mais ça secoue. Finalement, il reprend la marche et découvre que c''est le meilleur moyen de profiter du paysage !', 'narratif', 1)
) AS t
WHERE NOT EXISTS (SELECT 1 FROM emilie_lecture WHERE titre = 'La Petite Poule Rousse' LIMIT 1);

-- Questions pour les nouvelles lectures
INSERT INTO emilie_lecture_questions (lecture_id, question, options, reponse_correcte, type)
SELECT l.id, 'Que cherche la petite poule rousse ?', '["Des grains de blé", "Des vers de terre", "Des graines de tournesol", "Des insectes"]'::jsonb, 'Des grains de blé', 'qcm'
FROM emilie_lecture l WHERE l.titre = 'La Petite Poule Rousse' AND NOT EXISTS (SELECT 1 FROM emilie_lecture_questions WHERE lecture_id = l.id);

INSERT INTO emilie_lecture_questions (lecture_id, question, options, reponse_correcte, type)
SELECT l.id, 'Quand le pain est cuit, que fait la poule ?', '["Elle le mange toute seule", "Elle le partage avec le chat", "Elle le donne au chien", "Elle le vend"]'::jsonb, 'Elle le mange toute seule', 'qcm'
FROM emilie_lecture l WHERE l.titre = 'La Petite Poule Rousse' AND NOT EXISTS (SELECT 1 FROM emilie_lecture_questions WHERE lecture_id = l.id);

INSERT INTO emilie_lecture_questions (lecture_id, question, options, reponse_correcte, type)
SELECT l.id, 'Qui est Petit Gaston ?', '["Un hérisson", "Un lapin", "Un écureuil", "Une souris"]'::jsonb, 'Un hérisson', 'qcm'
FROM emilie_lecture l WHERE l.titre = 'Petit Gaston' AND NOT EXISTS (SELECT 1 FROM emilie_lecture_questions WHERE lecture_id = l.id);

INSERT INTO emilie_lecture_questions (lecture_id, question, options, reponse_correcte, type)
SELECT l.id, 'Quelle est la morale du "Renard Glouton" ?', '["On critique ce qu''on ne peut pas avoir", "Il faut toujours persévérer", "Partager c''est important", "La gourmandise est un défaut"]'::jsonb, 'On critique ce qu''on ne peut pas avoir', 'qcm'
FROM emilie_lecture l WHERE l.titre = 'Le Renard Glouton' AND NOT EXISTS (SELECT 1 FROM emilie_lecture_questions WHERE lecture_id = l.id);

-- =====================================================
-- 6. POÉSIES SUPPLÉMENTAIRES
-- =====================================================
INSERT INTO emilie_poesies (titre, auteur, texte, niveau)
SELECT * FROM (VALUES
  ('Où es-tu ?', 'Maurice Carême', 'Petite abeille,\nOù es-tu cachée ?\nDans les fleurs, dans le pré,\nOu sur le rosier ?\n\nJe te cherche partout,\nSous les feuilles, sur les cailloux.\nAh ! Te voilà,\nSur un beau lilas !', 1),
  ('La bise', 'Anonyme', 'Quand la bise se lève,\nTous les arbres frissonnent.\nLes feuilles s''envolent\nDans une grande farandole.\n\nCache bien ton nez,\nMets ton bonnet,\nCar la bise espiègle\nVeut pincer tes joues rondes !', 1),
  ('La lune', 'Victor Hugo', 'La lune est un petit jardin\nTout en haut du ciel.\nElle éclaire les chemins\nD''une lumière si belle.\n\nLes étoiles sont ses fleurs,\nLe vent est sa chanson.\nElle veille sur nos cœurs\nJusqu''au petit matin.', 1),
  ('Trois escargots', 'Jacques Charpentreau', 'Moi, j''ai trois escargots,\nUn devant, deux derrière.\nIls habitent un pot\nDe la cuisine, par terre.\n\nLe premier est petit,\nLe second est moyen,\nEt le troisième, c''est le roi,\nIl marche trop bien !', 1),
  ('Dis-moi capitaine', 'Anonyme', 'Dis-moi, capitaine,\nOù vas-tu sur l''océan ?\nJe pars vers les îles lointaines,\nOù dansent les enfants.\n\nMon bateau a des ailes\nComme un grand oiseau.\nJe traverse les tempêtes\nPour chercher des trésors nouveaux !', 1),
  ('Anniversaire', 'Jacques Prévert', 'Un gâteau tout rond,\nDes bougies qui brillent,\nUne chanson, des ballons,\nEt des amis qui babillent.\n\nSouffle, souffle bien fort,\nFais un vœu sans dire un mot.\nLes étoiles t''entendent\nEt t''offrent leur plus beau cadeau !', 1),
  ('Chanson pour les enfants l''hiver', 'Jacques Prévert', 'Il neige, il neige,\nLes flocons tourbillonnent.\nLes enfants se réjouissent,\nLes bonhommes de neige grandissent.\n\nMets ton écharpe et ton bonnet,\nVa jouer dans le jardin.\nL''hiver est un magicien\nQui habille tout de blanc.', 1),
  ('Conseils donnés par une sorcière', 'Anonyme', 'Pour faire une potion,\nPrends trois gouttes de lune,\nDes paillettes d''étoiles\nEt un peu de bonheur.\n\nAjoute une plume de hibou,\nUn sourire de velours,\nRemue avec une baguette\nEt dis : "ABRACADABRA !"', 1)
) AS t
WHERE NOT EXISTS (SELECT 1 FROM emilie_poesies WHERE titre = 'Où es-tu ?' LIMIT 1);

-- =====================================================
-- 7. PROBLÈMES SUPPLÉMENTAIRES
-- =====================================================
INSERT INTO emilie_problemes (enonce, operation, reponse, etapes, niveau)
SELECT * FROM (VALUES
  ('Une ferme a 147 vaches et 48 veaux. Combien d''animaux y a-t-il en tout ?', 'addition', '195', 1, 2),
  ('Émilie a 6 pages de stickers. Sur chaque page, il y a 5 stickers. Combien de stickers a-t-elle ?', 'multiplication', '30', 1, 2),
  ('Émilie a 45 euros dans sa tirelire. Elle dépense 13 euros pour un livre. Combien lui reste-t-il ?', 'soustraction', '32', 1, 1),
  ('Dans le métro, il y a 56 passagers. 31 descendent et 14 montent. Combien de passagers y a-t-il maintenant ?', 'soustraction_et_addition', '39', 2, 2),
  ('Thomas avait des billes. Il en gagne 8 et en a maintenant 35. Combien en avait-il avant ?', 'addition', '27', 1, 2),
  ('Achats : 59 euros pour un jeu, un livre à 13 euros et un ballon. Total = 59 euros. Combien coûte le ballon ?', 'soustraction', '11', 2, 3),
  ('À la cantine, il y a 86 tables. 34 sont occupées. Combien de tables vides reste-t-il ?', 'soustraction', '52', 1, 1),
  ('Émilie a 4 paquets de bonbons. Chaque paquet contient 8 bonbons. Combien de bonbons a-t-elle en tout ?', 'multiplication', '32', 1, 2)
) AS t
WHERE NOT EXISTS (SELECT 1 FROM emilie_problemes WHERE enonce LIKE 'Une ferme a 147 vaches%' LIMIT 1);

-- =====================================================
-- 8. DOCUMENTAIRES SUPPLÉMENTAIRES
-- =====================================================
INSERT INTO emilie_lecture (titre, texte, type, niveau)
SELECT * FROM (VALUES
  ('Le Paresseux', 'Le paresseux est un animal qui vit dans les forêts d''Amérique centrale et du Sud. Il dort environ 20 heures par jour, suspendu par ses griffes aux branches des arbres. Il se déplace très lentement et ne descend au sol qu''une fois par semaine pour faire ses besoins. Il est végétarien : il mange des feuilles, des fruits et des pousses d''arbres. Le paresseux est en danger à cause de la destruction de son habitat.', 'documentaire', 2),
  ('Le Zèbre', 'Le zèbre est un mammifère qui vit dans les plaines d''Afrique. Il se nourrit d''herbe et vit en troupeau. Ses rayures noires et blanches sont uniques comme les empreintes digitales chez l''humain. Elles lui servent à se camoufler et à reconnaître les autres zèbres. Quand un prédateur arrive, le zèbre se défend avec ses sabots. Il hennit pour communiquer avec son troupeau. Il est peureux et n''a jamais été domestiqué.', 'documentaire', 2)
) AS t
WHERE NOT EXISTS (SELECT 1 FROM emilie_lecture WHERE titre = 'Le Paresseux' LIMIT 1);

-- Questions pour les documentaires
INSERT INTO emilie_lecture_questions (lecture_id, question, options, reponse_correcte, type)
SELECT l.id, 'Combien d''heures par jour dort le paresseux ?', '["20 heures", "8 heures", "12 heures", "15 heures"]'::jsonb, '20 heures', 'qcm'
FROM emilie_lecture l WHERE l.titre = 'Le Paresseux' AND NOT EXISTS (SELECT 1 FROM emilie_lecture_questions WHERE lecture_id = l.id);

INSERT INTO emilie_lecture_questions (lecture_id, question, options, reponse_correcte, type)
SELECT l.id, 'À quoi servent les rayures du zèbre ?', '["À se camoufler et se reconnaître", "À nager", "À voler", "À attirer les prédateurs"]'::jsonb, 'À se camoufler et se reconnaître', 'qcm'
FROM emilie_lecture l WHERE l.titre = 'Le Zèbre' AND NOT EXISTS (SELECT 1 FROM emilie_lecture_questions WHERE lecture_id = l.id);

-- =====================================================
-- 9. ENRICHISSEMENT GÉOMÉTRIE
-- =====================================================
INSERT INTO emilie_geometrie (notion, description, niveau)
SELECT * FROM (VALUES
  ('Les polygones', 'Un polygone est une figure fermée tracée à la règle, avec des côtés et des sommets. Le triangle (3 côtés), le carré (4 côtés), le rectangle (4 côtés) et le pentagone (5 côtés) sont des polygones.', 1),
  ('Le carré', 'Un carré a 4 côtés de même longueur et 4 angles droits. On vérifie les angles droits avec une équerre.', 1)
) AS t
WHERE NOT EXISTS (SELECT 1 FROM emilie_geometrie WHERE notion = 'Les polygones' LIMIT 1);
