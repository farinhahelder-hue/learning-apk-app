-- ============================================================
-- Emilie App - Programme CE1 Complet (14 tables)
-- Création des tables + seed data pour le curriculum CE1
-- ============================================================

-- 1. Grammaire
CREATE TABLE IF NOT EXISTS emilie_grammaire (
  id SERIAL PRIMARY KEY,
  categorie TEXT NOT NULL,
  notion TEXT NOT NULL,
  explication TEXT NOT NULL,
  exemple TEXT,
  niveau INTEGER DEFAULT 1
);
ALTER TABLE emilie_grammaire ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_read_grammaire" ON emilie_grammaire FOR SELECT USING (true);

INSERT INTO emilie_grammaire (categorie, notion, explication, exemple, niveau) VALUES
('types_de_phrases', 'La phrase déclarative', 'Une phrase qui dit quelque chose, qui déclare un fait. Elle se termine par un point (.).', 'Le chat dort sur le canapé.', 1),
('types_de_phrases', 'La phrase interrogative', 'Une phrase qui pose une question. Elle se termine par un point d''interrogation (?).', 'Où vas-tu ?', 1),
('types_de_phrases', 'La phrase exclamative', 'Une phrase qui exprime une émotion forte : surprise, joie, colère. Elle se termine par un point d''exclamation (!).', 'Quel beau château !', 1),
('types_de_phrases', 'La phrase impérative', 'Une phrase qui donne un ordre ou un conseil. Elle se termine par un point (.) ou un point d''exclamation (!).', 'Ferme la porte.', 2),
('classes_de_mots', 'Le nom', 'Un mot qui désigne une personne, un animal, une chose ou une idée. Il peut être commun (chat) ou propre (Paris).', 'Le chat, la maison, Marie', 1),
('classes_de_mots', 'Le déterminant', 'Un mot placé devant le nom qui le précise. Exemples : le, la, un, une, mon, ton, ce, cette.', 'le chat, une fleur, mon livre', 1),
('classes_de_mots', 'L''adjectif qualificatif', 'Un mot qui donne une qualité, une caractéristique au nom. Il s''accorde en genre et en nombre.', 'un grand arbre, une jolie fleur', 1),
('classes_de_mots', 'Le verbe', 'Un mot qui exprime une action ou un état. Il change de forme selon le sujet et le temps.', 'manger, dormir, être, avoir', 1),
('classes_de_mots', 'Le pronom personnel', 'Un mot qui remplace un nom. Je, tu, il/elle, nous, vous, ils/elles.', 'Je mange. Il court. Nous chantons.', 1),
('classes_de_mots', 'La préposition', 'Un mot invariable qui introduit un complément. Exemples : à, de, dans, sur, sous, avec, pour.', 'Je vais à l''école. Le livre de Marie.', 2),
('classes_de_mots', 'L''adverbe', 'Un mot invariable qui modifie le sens d''un verbe, d''un adjectif ou d''un autre adverbe.', 'Il court vite. Elle est très gentille.', 2),
('accords', 'L''accord sujet-verbe', 'Le verbe s''accorde toujours avec son sujet. Si le sujet est singulier, le verbe est singulier. Si le sujet est pluriel, le verbe est pluriel.', 'Le chat mange. → Les chats mangent.', 1),
('accords', 'L''accord dans le groupe nominal', 'Le déterminant, le nom et l''adjectif s''accordent en genre (masculin/féminin) et en nombre (singulier/pluriel).', 'un grand chat → une grande chatte → de grands chats', 2),
('ponctuation', 'Le point (.)', 'Le point termine une phrase déclarative ou impérative.', 'Il fait beau aujourd''hui.', 1),
('ponctuation', 'La virgule (,)', 'La virgule sert à séparer des mots ou des groupes de mots dans une phrase.', 'J''ai acheté des pommes, des poires et des bananes.', 1),
('ponctuation', 'Les guillemets (« »)', 'Les guillemets encadrent les paroles rapportées dans un dialogue.', '« Bonjour ! » dit Marie.', 2),
('ponctuation', 'Le point d''interrogation (?)', 'Le point d''interrogation se place à la fin d''une phrase qui pose une question.', 'Quelle heure est-il ?', 1),
('ponctuation', 'Le point d''exclamation (!)', 'Le point d''exclamation se place à la fin d''une phrase qui exprime une émotion.', 'Comme c''est beau !', 1),
('negation', 'La phrase négative', 'Une phrase négative dit le contraire d''une phrase affirmative. On utilise "ne...pas", "ne...plus", "ne...jamais".', 'Je ne mange pas. Il n''a plus faim.', 2);

-- 2. Orthographe
CREATE TABLE IF NOT EXISTS emilie_orthographe (
  id SERIAL PRIMARY KEY,
  regle TEXT NOT NULL,
  explication TEXT NOT NULL,
  mots_exemples TEXT,
  niveau INTEGER DEFAULT 1
);
ALTER TABLE emilie_orthographe ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_read_orthographe" ON emilie_orthographe FOR SELECT USING (true);

INSERT INTO emilie_orthographe (regle, explication, mots_exemples, niveau) VALUES
('Le son [s]', 'Le son [s] s''écrit "s" entre deux consonnes ou en début de mot, "ss" entre deux voyelles, "c" devant e,i,y, ou "ç" devant a,o,u.', 'serpent, poisson, citron, leçon', 1),
('Le son [k]', 'Le son [k] s''écrit "c" devant a,o,u ou consonne, "qu" devant e,i,y, ou "k" dans les mots d''origine étrangère.', 'carte, quand, koala', 1),
('Le son [ʒ]', 'Le son [ʒ] s''écrit "j" devant toutes les voyelles ou "g" devant e et i.', 'jardin, rouge, gentil', 1),
('Le son [g]', 'Le son [g] s''écrit "g" devant a,o,u ou consonne, "gu" devant e et i.', 'gâteau, guerre, guitare', 1),
('Les accents', 'L''accent aigu (é) se met sur le e fermé. L''accent grave (è) sur le e ouvert. L''accent circonflexe (ê) sur le e long. Le tréma (ë) fait prononcer la lettre séparément.', 'école, mère, forêt, Noël', 1),
('Les homophones : a/à', '"a" est le verbe avoir conjugué (il a). "à" est une préposition (je vais à).', 'Il a un chat. Je vais à l''école.', 1),
('Les homophones : et/est', '"et" est une conjonction qui relie des mots (lui et moi). "est" est le verbe être conjugué (il est).', 'Lui et moi. Il est gentil.', 1),
('Les homophones : ont/on', '"ont" est le verbe avoir (ils ont). "on" est un pronom (on joue).', 'Ils ont faim. On joue dehors.', 2),
('Les homophones : son/sont', '"son" est un déterminant possessif (son livre). "sont" est le verbe être (ils sont).', 'Son sac. Ils sont partis.', 2),
('Le féminin des noms', 'Pour former le féminin d''un nom, on ajoute généralement un -e à la fin. Parfois le mot change complètement.', 'chat → chatte, lion → lionne, garçon → fille', 1),
('Le pluriel des noms', 'Pour former le pluriel d''un nom, on ajoute généralement un -s. Les mots en -eau prennent un -x. Les mots en -ou prennent un -s sauf 7 exceptions.', 'chat → chats, château → châteaux, bijou → bijoux', 1);

-- 3. Lecture
CREATE TABLE IF NOT EXISTS emilie_lecture (
  id SERIAL PRIMARY KEY,
  titre TEXT NOT NULL,
  texte TEXT NOT NULL,
  type TEXT NOT NULL,
  niveau INTEGER DEFAULT 1
);
ALTER TABLE emilie_lecture ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_read_lecture" ON emilie_lecture FOR SELECT USING (true);

INSERT INTO emilie_lecture (titre, texte, type, niveau) VALUES
('Le Petit Chat Perdu', 'Un petit chat noir et blanc s''est perdu dans le jardin. Il miaule doucement. Une petite fille nommée Lola l''entend. Elle s''approche tout doucement. "N''aie pas peur, petit chat", dit-elle. Elle prend le chat dans ses bras et le ramène chez elle. Sa maman lui donne du lait. Le petit chat est content et ronronne.', 'narratif', 1),
('La Forêt Enchantée', 'Dans la forêt enchantée, les arbres ont des feuilles argentées. Les écureuils y parlent aux oiseaux. Au centre de la forêt, il y a un lac magique. L''eau du lac change de couleur selon la saison : verte au printemps, dorée en été, orange en automne et bleue en hiver. Les animaux de la forêt se réunissent près du lac pour boire et jouer.', 'narratif', 1),
('Le Cycle de l''Eau', 'L''eau voyage tout le temps ! Le soleil chauffe l''eau des rivières, des lacs et des océans. L''eau se transforme en vapeur et monte dans le ciel. C''est l''évaporation. Dans le ciel, la vapeur refroidit et forme des nuages. C''est la condensation. Quand les nuages sont trop lourds, l''eau retombe sous forme de pluie ou de neige. C''est la précipitation. Et le cycle recommence !', 'documentaire', 1),
('Les Saisons', 'Il y a quatre saisons dans l''année. Le printemps : les fleurs poussent, les oiseaux chantent, il fait plus doux. L''été : il fait chaud, le soleil brille, on peut jouer dehors longtemps. L''automne : les feuilles tombent, il commence à faire frais, on ramasse les champignons. L''hiver : il fait froid, parfois il neige, on peut faire des bonhommes de neige.', 'documentaire', 1),
('Mon Cartable', 'Dans mon cartable, je mets mes livres et mes cahiers. Je vais à l''école tous les jours. La maîtresse nous apprend à lire et à écrire. J''aime quand on fait des mathématiques. Pendant la récréation, je joue avec mes amis. Nous courons dans la cour et nous rions ensemble.', 'narratif', 1),
('La Petite Chenille', 'Une petite chenille sort de son œuf. Elle a très faim. Elle mange une pomme, puis deux poires, puis trois prunes. Mais elle a encore faim ! Elle mange une fraise, une orange et une feuille verte. Maintenant, elle est grosse et ronde. Elle se construit un cocon. Après quelques semaines, elle devient un magnifique papillon.', 'narratif', 1);

-- 4. Dictées
CREATE TABLE IF NOT EXISTS emilie_dictees (
  id SERIAL PRIMARY KEY,
  titre TEXT NOT NULL,
  texte TEXT NOT NULL,
  mots_pieges JSONB DEFAULT '[]',
  niveau INTEGER DEFAULT 1,
  nb_mots INTEGER DEFAULT 0
);
ALTER TABLE emilie_dictees ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_read_dictees" ON emilie_dictees FOR SELECT USING (true);

INSERT INTO emilie_dictees (titre, texte, mots_pieges, niveau, nb_mots) VALUES
('Dictée facile - Le jardin', 'Mon jardin est plein de belles fleurs. Les roses sont rouges et les tulipes sont jaunes. Un joli papillon vole dans le ciel bleu.', '["fleurs", "sont", "papillon", "ciel"]'::jsonb, 1, 18),
('Dictée moyenne - La plage', 'Cet été, nous sommes allés à la plage avec maman et papa. Le sable était chaud. J''ai construit un grand château avec des coquillages. Les vagues venaient doucement.', '["été", "sommes", "sable", "construit", "coquillages", "vagues"]'::jsonb, 2, 28),
('Dictée difficile - La rentrée', 'C''est la rentrée des classes ! Les enfants arrivent avec leur nouveau cartable. Dans la cour, ils retrouvent leurs amis. La maîtresse les accueille avec un grand sourire. Cette année, ils vont apprendre beaucoup de choses passionnantes.', '["rentrée", "arrivent", "nouveau", "retrouvent", "accueille", "année", "passionnantes"]'::jsonb, 3, 34);

-- 5. Poésies
CREATE TABLE IF NOT EXISTS emilie_poesies (
  id SERIAL PRIMARY KEY,
  titre TEXT NOT NULL,
  auteur TEXT,
  texte TEXT NOT NULL,
  niveau INTEGER DEFAULT 1
);
ALTER TABLE emilie_poesies ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_read_poesies" ON emilie_poesies FOR SELECT USING (true);

INSERT INTO emilie_poesies (titre, auteur, texte, niveau) VALUES
('Le Printemps', 'Maurice Carême', 'Printemps, printemps, me voici !\nLes arbres sont en fleurs.\nLes oiseaux sont de retour\nEt chantent dans mon cœur.', 1),
('La Nuit', 'Victor Hugo', 'La nuit, tous les chats sont gris.\nLa lune brille dans le ciel.\nLes étoiles sont allumées\nComme des petits soleils.', 1),
('L''École', 'Jacques Prévert', ' Dans la cour de l''école\nOn apprend et on s''amuse.\nLes livres sont nos amis\nPour toute notre vie.', 1),
('L''Arc-en-Ciel', 'Émile Nelligan', 'Après la pluie, le beau temps,\nL''arc-en-ciel est apparu.\nSept couleurs dans le ciel\nComme un ruban tissé.', 1);

-- 6. Calcul mental
CREATE TABLE IF NOT EXISTS emilie_calcul_mental (
  id SERIAL PRIMARY KEY,
  operation TEXT NOT NULL,
  operande1 INTEGER NOT NULL,
  operande2 INTEGER NOT NULL,
  reponse INTEGER NOT NULL,
  niveau INTEGER DEFAULT 1
);
ALTER TABLE emilie_calcul_mental ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_read_calcul_mental" ON emilie_calcul_mental FOR SELECT USING (true);

INSERT INTO emilie_calcul_mental (operation, operande1, operande2, reponse, niveau) VALUES
-- Niveau 1 : additions jusqu''à 20
('+', 3, 5, 8, 1), ('+', 7, 2, 9, 1), ('+', 4, 6, 10, 1), ('+', 8, 3, 11, 1),
('+', 5, 7, 12, 1), ('+', 2, 9, 11, 1), ('+', 6, 4, 10, 1), ('+', 9, 1, 10, 1),
('+', 4, 8, 12, 1), ('+', 7, 5, 12, 1), ('+', 3, 9, 12, 1), ('+', 6, 6, 12, 1),
('+', 8, 4, 12, 1), ('+', 5, 8, 13, 1), ('+', 9, 4, 13, 1), ('+', 7, 6, 13, 1),
('+', 8, 5, 13, 1), ('+', 6, 7, 13, 1), ('+', 9, 5, 14, 1), ('+', 7, 7, 14, 1),
('+', 8, 6, 14, 1), ('+', 5, 9, 14, 1), ('+', 9, 6, 15, 1), ('+', 8, 7, 15, 1),
-- Niveau 1 : soustractions jusqu''à 20
('-', 8, 3, 5, 1), ('-', 10, 4, 6, 1), ('-', 12, 5, 7, 1), ('-', 9, 2, 7, 1),
('-', 15, 6, 9, 1), ('-', 11, 3, 8, 1), ('-', 14, 7, 7, 1), ('-', 13, 6, 7, 1),
('-', 16, 8, 8, 1), ('-', 17, 9, 8, 1), ('-', 12, 4, 8, 1), ('-', 18, 9, 9, 1),
-- Niveau 2 : additions jusqu''à 100
('+', 25, 14, 39, 2), ('+', 32, 27, 59, 2), ('+', 45, 23, 68, 2), ('+', 51, 38, 89, 2),
('+', 63, 24, 87, 2), ('+', 44, 35, 79, 2), ('+', 72, 19, 91, 2), ('+', 56, 37, 93, 2),
('+', 48, 26, 74, 2), ('+', 67, 28, 95, 2), ('+', 34, 47, 81, 2), ('+', 53, 39, 92, 2),
('-', 45, 13, 32, 2), ('-', 68, 24, 44, 2), ('-', 87, 35, 52, 2), ('-', 93, 41, 52, 2),
('-', 76, 28, 48, 2), ('-', 55, 37, 18, 2), ('-', 82, 46, 36, 2), ('-', 71, 33, 38, 2),
('-', 94, 57, 37, 2), ('-', 63, 29, 34, 2), ('-', 88, 49, 39, 2), ('-', 77, 28, 49, 2),
-- Niveau 2 : tables x2 à x5
('×', 2, 3, 6, 2), ('×', 2, 5, 10, 2), ('×', 2, 7, 14, 2), ('×', 2, 9, 18, 2),
('×', 3, 4, 12, 2), ('×', 3, 6, 18, 2), ('×', 3, 8, 24, 2), ('×', 4, 5, 20, 2),
('×', 4, 7, 28, 2), ('×', 4, 9, 36, 2), ('×', 5, 6, 30, 2), ('×', 5, 8, 40, 2),
-- Niveau 3 : tables x6 à x10
('×', 6, 4, 24, 3), ('×', 6, 7, 42, 3), ('×', 6, 9, 54, 3), ('×', 7, 5, 35, 3),
('×', 7, 8, 56, 3), ('×', 7, 9, 63, 3), ('×', 8, 4, 32, 3), ('×', 8, 7, 56, 3),
('×', 8, 9, 72, 3), ('×', 9, 6, 54, 3), ('×', 9, 8, 72, 3), ('×', 9, 9, 81, 3),
('×', 10, 5, 50, 3), ('×', 10, 8, 80, 3), ('×', 10, 10, 100, 3),
-- Niveau 3 : additions jusqu''à 1000
('+', 350, 240, 590, 3), ('+', 425, 375, 800, 3), ('+', 560, 280, 840, 3),
('+', 710, 190, 900, 3), ('+', 635, 255, 890, 3), ('+', 482, 348, 830, 3),
('-', 500, 230, 270, 3), ('-', 780, 450, 330, 3), ('-', 650, 380, 270, 3),
('-', 900, 560, 340, 3), ('-', 835, 470, 365, 3), ('-', 720, 290, 430, 3);

-- 7. Problèmes
CREATE TABLE IF NOT EXISTS emilie_problemes (
  id SERIAL PRIMARY KEY,
  enonce TEXT NOT NULL,
  operation TEXT NOT NULL,
  reponse TEXT NOT NULL,
  etapes INTEGER DEFAULT 1,
  niveau INTEGER DEFAULT 1
);
ALTER TABLE emilie_problemes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_read_problemes" ON emilie_problemes FOR SELECT USING (true);

INSERT INTO emilie_problemes (enonce, operation, reponse, etapes, niveau) VALUES
('Léo a 8 billes. Il en gagne 5. Combien de billes a-t-il maintenant ?', 'addition', '13', 1, 1),
('Dans la classe, il y a 15 élèves. 6 élèves sont des garçons. Combien y a-t-il de filles ?', 'soustraction', '9', 1, 1),
('Maman a acheté 3 paquets de gâteaux. Dans chaque paquet, il y a 4 gâteaux. Combien de gâteaux a-t-elle achetés en tout ?', 'multiplication', '12', 1, 1),
('Noisette l''écureuil a 12 noisettes. Il en mange 3. Combien lui en reste-t-il ?', 'soustraction', '9', 1, 1),
('Pour son anniversaire, Émilie reçoit 7 ballons rouges et 8 ballons bleus. Combien de ballons a-t-elle en tout ?', 'addition', '15', 1, 1),
('Un fermier a 24 poules. Il les vend par groupes de 4. Combien de groupes peut-il faire ?', 'division', '6', 2, 2),
('Marie a 45 €. Elle achète un jeu à 22 € et un livre à 8 €. Combien d''argent lui reste-t-il ?', 'soustraction', '15', 2, 2),
('Dans la bibliothèque, il y a 6 étagères. Sur chaque étagère, il y a 8 livres. Combien y a-t-il de livres en tout ?', 'multiplication', '48', 1, 2),
('Thomas collectionne les timbres. Il en a 128. Sa sœur lui en donne 35 de plus. Combien de timbres a-t-il maintenant ?', 'addition', '163', 2, 3),
('Une pâtissière a fait 96 biscuits. Elle les range dans des boîtes de 8 biscuits. Combien de boîtes peut-elle remplir ?', 'division', '12', 2, 3),
('Un train transporte 275 passagers. Au premier arrêt, 48 passagers descendent et 37 montent. Combien y a-t-il de passagers maintenant ?', 'soustraction_et_addition', '264', 2, 3),
('Émilie doit lire un livre de 150 pages. Elle a déjà lu 65 pages le premier jour et 42 pages le deuxième jour. Combien de pages lui reste-t-il à lire ?', 'soustraction', '43', 2, 3);

-- 8. Géométrie
CREATE TABLE IF NOT EXISTS emilie_geometrie (
  id SERIAL PRIMARY KEY,
  notion TEXT NOT NULL,
  description TEXT NOT NULL,
  niveau INTEGER DEFAULT 1
);
ALTER TABLE emilie_geometrie ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_read_geometrie" ON emilie_geometrie FOR SELECT USING (true);

INSERT INTO emilie_geometrie (notion, description, niveau) VALUES
('Le carré', 'Un carré a 4 côtés de la même longueur et 4 angles droits.', 1),
('Le rectangle', 'Un rectangle a 4 côtés : 2 grands et 2 petits. Il a 4 angles droits.', 1),
('Le triangle', 'Un triangle a 3 côtés et 3 sommets. Il peut être rectangle, isocèle ou équilatéral.', 1),
('Le cercle', 'Un cercle est une forme ronde. Tous les points sont à égale distance du centre.', 1),
('Le losange', 'Un losange a 4 côtés égaux mais ses angles ne sont pas droits. Il ressemble à un carré penché.', 2),
('L''axe de symétrie', 'Une figure a un axe de symétrie quand on peut la plier en deux pour que les deux parties se superposent.', 1),
('La symétrie', 'Un objet symétrique a deux parties identiques de chaque côté de l''axe.', 1),
('Le pavé droit', 'Un pavé droit (ou parallélépipède) est un solide qui a 6 faces rectangulaires.', 2),
('Le cube', 'Un cube a 6 faces carrées identiques, 8 sommets et 12 arêtes.', 1),
('La pyramide', 'Une pyramide a une base polygonale (souvent un carré) et des faces triangulaires qui se rejoignent au sommet.', 2),
('Le périmètre', 'Le périmètre est la longueur du contour d''une figure. Pour un carré : P = 4 × côté. Pour un rectangle : P = 2 × (L + l).', 2),
('L''angle droit', 'Un angle droit mesure 90 degrés. On le trouve dans les carrés et les rectangles. Il a la forme d''un L.', 1);

-- 9. Mesures
CREATE TABLE IF NOT EXISTS emilie_mesures (
  id SERIAL PRIMARY KEY,
  unite TEXT NOT NULL,
  symbole TEXT NOT NULL,
  conversion TEXT,
  explication TEXT NOT NULL,
  niveau INTEGER DEFAULT 1
);
ALTER TABLE emilie_mesures ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_read_mesures" ON emilie_mesures FOR SELECT USING (true);

INSERT INTO emilie_mesures (unite, symbole, conversion, explication, niveau) VALUES
('Mètre', 'm', '1 m = 100 cm', 'Le mètre est l''unité principale pour mesurer les longueurs. Un mètre, c''est à peu près la hauteur d''une chaise.', 1),
('Centimètre', 'cm', '1 cm = 10 mm', 'Le centimètre sert à mesurer des petites longueurs. La largeur d''un doigt, c''est environ 1 cm.', 1),
('Kilomètre', 'km', '1 km = 1000 m', 'Le kilomètre sert à mesurer de grandes distances. La distance entre deux villes se mesure en km.', 1),
('Millimètre', 'mm', '1 mm = 0,1 cm', 'Le millimètre sert à mesurer de très petites choses, comme l''épaisseur d''une pièce.', 2),
('Gramme', 'g', '1 g = 1000 mg', 'Le gramme est l''unité principale pour mesurer la masse. Une petite cuillère de sucre pèse environ 5 g.', 1),
('Kilogramme', 'kg', '1 kg = 1000 g', 'Le kilogramme sert à peser des objets lourds. Un paquet de farine pèse 1 kg.', 1),
('Tonne', 't', '1 t = 1000 kg', 'La tonne sert à peser des objets très lourds comme une voiture.', 2),
('Litre', 'L', '1 L = 100 cL', 'Le litre sert à mesurer les liquides. Une bouteille de lait contient 1 L.', 1),
('Centilitre', 'cL', '1 cL = 10 mL', 'Le centilitre est une petite mesure de liquide. Une canette contient 33 cL.', 1),
('Millilitre', 'mL', '1 mL = 0,1 cL', 'Le millilitre sert à mesurer de très petites quantités de liquide.', 2),
('Heure', 'h', '1 h = 60 min', 'L''heure sert à mesurer le temps. Une émission de télé dure environ 1 heure.', 1),
('Minute', 'min', '1 min = 60 s', 'La minute sert à mesurer des durées plus courtes. Une chanson dure environ 3 minutes.', 1),
('Seconde', 's', '', 'La seconde est la plus petite unité de temps courante. Elle dite "un Mississippi".', 1),
('Jour', 'j', '1 j = 24 h', 'Le jour est le temps que met la Terre pour tourner sur elle-même.', 1),
('Semaine', 'sem', '1 sem = 7 j', 'La semaine dure 7 jours : lundi, mardi, mercredi, jeudi, vendredi, samedi, dimanche.', 1),
('Mois', 'mois', '1 mois = 28 à 31 j', 'Un mois dure entre 28 et 31 jours. Il y a 12 mois dans une année.', 1),
('Année', 'an', '1 an = 12 mois = 365 j', 'L''année est le temps que met la Terre pour tourner autour du Soleil.', 1);

-- 10. Anglais
CREATE TABLE IF NOT EXISTS emilie_anglais (
  id SERIAL PRIMARY KEY,
  mot_fr TEXT NOT NULL,
  mot_en TEXT NOT NULL,
  phonetique TEXT,
  phrase_fr TEXT,
  phrase_en TEXT,
  categorie TEXT NOT NULL
);
ALTER TABLE emilie_anglais ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_read_anglais" ON emilie_anglais FOR SELECT USING (true);

INSERT INTO emilie_anglais (mot_fr, mot_en, phonetique, phrase_fr, phrase_en, categorie) VALUES
('bonjour', 'hello', '/hə.ˈloʊ/', 'Bonjour, comment vas-tu ?', 'Hello, how are you?', 'salutations'),
('au revoir', 'goodbye', '/ɡʊd.ˈbaɪ/', 'Au revoir, à demain !', 'Goodbye, see you tomorrow!', 'salutations'),
('merci', 'thank you', '/ˈθæŋk juː/', 'Merci pour le cadeau.', 'Thank you for the gift.', 'salutations'),
('s''il vous plaît', 'please', '/pliːz/', 'Un verre d''eau, s''il vous plaît.', 'A glass of water, please.', 'salutations'),
('oui', 'yes', '/jɛs/', 'Oui, je veux bien.', 'Yes, I would like to.', 'salutations'),
('non', 'no', '/noʊ/', 'Non, merci.', 'No, thank you.', 'salutations'),
('maman', 'mom', '/mɑm/', 'Ma maman est gentille.', 'My mom is kind.', 'famille'),
('papa', 'dad', '/dæd/', 'Mon papa est grand.', 'My dad is tall.', 'famille'),
('frère', 'brother', '/ˈbrʌð.ɚ/', 'J''ai un frère.', 'I have a brother.', 'famille'),
('sœur', 'sister', '/ˈsɪs.tɚ/', 'Ma sœur est petite.', 'My sister is small.', 'famille'),
('l''école', 'school', '/skuːl/', 'Je vais à l''école.', 'I go to school.', 'école'),
('le livre', 'book', '/bʊk/', 'J''aime lire un livre.', 'I like to read a book.', 'école'),
('le crayon', 'pencil', '/ˈpɛn.səl/', 'Le crayon est sur la table.', 'The pencil is on the table.', 'école'),
('le cahier', 'notebook', '/ˈnoʊt.bʊk/', 'Mon cahier est bleu.', 'My notebook is blue.', 'école'),
('la maîtresse', 'teacher', '/ˈtiː.tʃɚ/', 'La maîtresse explique la leçon.', 'The teacher explains the lesson.', 'école'),
('rouge', 'red', '/rɛd/', 'La pomme est rouge.', 'The apple is red.', 'couleurs'),
('bleu', 'blue', '/bluː/', 'Le ciel est bleu.', 'The sky is blue.', 'couleurs'),
('vert', 'green', '/ɡriːn/', 'L''herbe est verte.', 'The grass is green.', 'couleurs'),
('jaune', 'yellow', '/ˈjɛl.oʊ/', 'Le soleil est jaune.', 'The sun is yellow.', 'couleurs'),
('noir', 'black', '/blæk/', 'Le chat est noir.', 'The cat is black.', 'couleurs'),
('blanc', 'white', '/waɪt/', 'La neige est blanche.', 'The snow is white.', 'couleurs'),
('la tête', 'head', '/hɛd/', 'J''ai mal à la tête.', 'I have a headache.', 'corps'),
('la main', 'hand', '/hænd/', 'Lave-toi les mains.', 'Wash your hands.', 'corps'),
('le pied', 'foot', '/fʊt/', 'Mon pied est dans la chaussure.', 'My foot is in the shoe.', 'corps'),
('les yeux', 'eyes', '/aɪz/', 'J''ai les yeux marron.', 'I have brown eyes.', 'corps'),
('le nez', 'nose', '/noʊz/', 'Le chat a un petit nez.', 'The cat has a small nose.', 'corps'),
('la bouche', 'mouth', '/maʊθ/', 'Ouvre la bouche.', 'Open your mouth.', 'corps'),
('un', 'one', '/wʌn/', 'J''ai un chat.', 'I have one cat.', 'chiffres'),
('deux', 'two', '/tuː/', 'J''ai deux mains.', 'I have two hands.', 'chiffres'),
('trois', 'three', '/θriː/', 'Il y a trois livres.', 'There are three books.', 'chiffres'),
('quatre', 'four', '/fɔːr/', 'La table a quatre pieds.', 'The table has four legs.', 'chiffres'),
('cinq', 'five', '/faɪv/', 'J''ai cinq doigts.', 'I have five fingers.', 'chiffres'),
('le chat', 'cat', '/kæt/', 'Le chat dort sur le canapé.', 'The cat sleeps on the sofa.', 'animaux'),
('le chien', 'dog', '/dɑːɡ/', 'Le chien court vite.', 'The dog runs fast.', 'animaux'),
('l''oiseau', 'bird', '/bɜːrd/', 'L''oiseau chante le matin.', 'The bird sings in the morning.', 'animaux'),
('le poisson', 'fish', '/fɪʃ/', 'Le poisson nage dans l''eau.', 'The fish swims in the water.', 'animaux'),
('le cheval', 'horse', '/hɔːrs/', 'Le cheval galope dans le pré.', 'The horse gallops in the field.', 'animaux'),
('le lapin', 'rabbit', '/ˈræb.ɪt/', 'Le lapin mange une carotte.', 'The rabbit eats a carrot.', 'animaux');

-- 11. Questionner le monde
CREATE TABLE IF NOT EXISTS emilie_questionner_monde (
  id SERIAL PRIMARY KEY,
  titre TEXT NOT NULL,
  contenu TEXT NOT NULL,
  domaine TEXT NOT NULL,
  niveau INTEGER DEFAULT 1
);
ALTER TABLE emilie_questionner_monde ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_read_questionner_monde" ON emilie_questionner_monde FOR SELECT USING (true);

INSERT INTO emilie_questionner_monde (titre, contenu, domaine, niveau) VALUES
('Les Gaulois', 'Les Gaulois étaient les habitants de la France avant les Romains. Ils vivaient dans des villages appelés "oppidums". Ils étaient agriculteurs, artisans et guerriers. Leur druide était le sage du village.', 'histoire', 1),
('Charlemagne', 'Charlemagne était un grand roi qui a régné il y a plus de 1200 ans. Il a unifié une grande partie de l''Europe. Il a créé des écoles pour que les enfants apprennent à lire et à écrire.', 'histoire', 1),
('Jeanne d''Arc', 'Jeanne d''Arc était une jeune fille qui a aidé le roi de France il y a environ 600 ans. Elle a écouté des voix qui lui disaient de libérer la France. Elle est devenue une héroïne nationale.', 'histoire', 1),
('Louis XIV', 'Louis XIV était un roi de France qui a construit le magnifique château de Versailles. On l''appelait le "Roi Soleil" parce qu''il était très puissant.', 'histoire', 2),
('La Révolution française', 'En 1789, le peuple français s''est révolté contre le roi. Ils ont écrit la Déclaration des Droits de l''Homme. La devise "Liberté, Égalité, Fraternité" est née.', 'histoire', 2),
('La France et ses frontières', 'La France est un pays d''Europe. Elle a des frontières avec l''Espagne, l''Italie, la Suisse, l''Allemagne, le Luxembourg et la Belgique. Elle est entourée par la mer Méditerranée, l''océan Atlantique et la Manche.', 'geographie', 1),
('Les continents', 'Il y a 7 continents sur Terre : l''Europe, l''Afrique, l''Asie, l''Amérique du Nord, l''Amérique du Sud, l''Océanie et l''Antarctique.', 'geographie', 1),
('Les océans', 'Il y a 5 océans : l''océan Pacifique (le plus grand), l''océan Atlantique, l''océan Indien, l''océan Austral et l''océan Arctique (le plus petit).', 'geographie', 1),
('Les jours de la semaine', 'La semaine a 7 jours : lundi, mardi, mercredi, jeudi, vendredi, samedi, dimanche. Le week-end est samedi et dimanche.', 'geographie', 1),
('Les 12 mois de l''année', 'Janvier, février, mars, avril, mai, juin, juillet, août, septembre, octobre, novembre, décembre. Une année a 365 jours (ou 366 les années bissextiles).', 'geographie', 1),
('Le corps humain', 'Le corps humain est composé de plusieurs parties : la tête, le tronc, les bras et les jambes. À l''intérieur, nous avons le cœur (qui bat), les poumons (pour respirer), l''estomac (pour digérer) et le cerveau (pour réfléchir).', 'sciences', 1),
('Les 5 sens', 'Nous avons 5 sens : la vue (les yeux), l''ouïe (les oreilles), l''odorat (le nez), le goût (la langue), et le toucher (la peau).', 'sciences', 1),
('Le cycle des saisons', 'Les saisons changent parce que la Terre tourne autour du Soleil. Quand l''hémisphère nord est incliné vers le Soleil, c''est l''été. Quand il est incliné à l''opposé, c''est l''hiver.', 'sciences', 1);

-- 12. EMC (Enseignement Moral et Civique)
CREATE TABLE IF NOT EXISTS emilie_emc (
  id SERIAL PRIMARY KEY,
  valeur TEXT NOT NULL,
  explication TEXT NOT NULL,
  question_reflexion TEXT
);
ALTER TABLE emilie_emc ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_read_emc" ON emilie_emc FOR SELECT USING (true);

INSERT INTO emilie_emc (valeur, explication, question_reflexion) VALUES
('Le respect', 'Le respect, c''est traiter les autres comme on aimerait être traité. On respecte les personnes, les différences, les règles et l''environnement.', 'Comment montres-tu du respect à tes camarades de classe ?'),
('La liberté', 'La liberté, c''est le droit de penser, de parler et d''agir sans faire de mal aux autres. Chaque personne a le droit d''être libre.', 'Qu''est-ce que la liberté signifie pour toi ?'),
('L''égalité', 'L''égalité, c''est quand tout le monde a les mêmes droits, peu importe son genre, sa couleur de peau, sa religion ou son origine.', 'Imagine un monde où tout le monde serait traité de la même façon. À quoi ressemblerait-il ?'),
('La solidarité', 'La solidarité, c''est aider les autres quand ils en ont besoin. C''est penser à ceux qui sont moins chanceux et leur tendre la main.', 'Comment peux-tu aider quelqu''un de ta classe qui a des difficultés ?'),
('La laïcité', 'La laïcité, c''est le respect de toutes les croyances. Chacun peut pratiquer sa religion librement, tant que cela ne gêne pas les autres.', 'Pourquoi est-il important que tout le monde puisse croire en ce qu''il veut ?'),
('La justice', 'La justice, c''est donner à chacun ce qui lui revient. C''est être juste et ne pas faire de différences injustes entre les personnes.', 'Que ferais-tu si tu voyais quelqu''un se faire traiter injustement ?'),
('La démocratie', 'La démocratie, c''est le pouvoir du peuple. On vote pour choisir nos représentants et prendre des décisions ensemble.', 'Pourquoi est-il important de voter dans une démocratie ?'),
('La fraternité', 'La fraternité, c''est le lien qui unit les humains. C''est se considérer comme des frères et sœurs, même si on ne se connaît pas.', 'Comment pourrais-tu être un meilleur "frère" ou "sœur" pour les autres ?'),
('La paix', 'La paix, c''est vivre sans violence ni conflit. C''est résoudre les problèmes en discutant plutôt qu''en se battant.', 'Comment peux-tu aider à garder la paix dans la cour de récréation ?'),
('L''honnêteté', 'L''honnêteté, c''est dire la vérité et ne pas tromper les autres. Une personne honnête est digne de confiance.', 'Pourquoi est-il important de dire la vérité, même quand c''est difficile ?'),
('La responsabilité', 'La responsabilité, c''est répondre de ses actes. Quand on fait quelque chose, on en assume les conséquences.', 'Quelles sont tes responsabilités à la maison et à l''école ?'),
('Le courage', 'Le courage, ce n''est pas l''absence de peur, mais la force de faire ce qui est juste même quand on a peur.', 'Dans quelle situation as-tu dû être courageux(se) récemment ?');

-- 13. Arts / EPS / Musique
CREATE TABLE IF NOT EXISTS emilie_arts (
  id SERIAL PRIMARY KEY,
  activite TEXT NOT NULL,
  description TEXT NOT NULL,
  domaine TEXT NOT NULL,
  niveau INTEGER DEFAULT 1
);
ALTER TABLE emilie_arts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_read_arts" ON emilie_arts FOR SELECT USING (true);

INSERT INTO emilie_arts (activite, description, domaine, niveau) VALUES
('Les couleurs primaires', 'Le rouge, le bleu et le jaune sont les couleurs primaires. En les mélangeant, on obtient d''autres couleurs : rouge + bleu = violet, bleu + jaune = vert, rouge + jaune = orange.', 'arts', 1),
('La peinture à l''eau', 'Avec de la peinture à l''eau (aquarelle), on peut créer des dégradés et des fondus. On utilise un pinceau et de l''eau pour diluer la peinture.', 'arts', 1),
('Le dessin au crayon', 'Le crayon permet de faire des traits fins ou épais selon la pression. On peut faire des ombres en frottant doucement.', 'arts', 1),
('Le modelage (argile)', 'Avec de l''argile, on peut créer des formes en volume : des animaux, des vases, des personnages. On utilise ses mains et des outils spéciaux.', 'arts', 2),
('Les collages', 'Le collage consiste à assembler différents matériaux (papier, tissu, laine) sur une feuille pour créer une image.', 'arts', 1),
('Le rythme musical', 'Le rythme, c''est la pulsation de la musique. On peut taper dans ses mains ou sur un tambour pour marquer le rythme. La noire dure 1 temps, la blanche dure 2 temps.', 'musique', 1),
('Les notes de musique', 'Il y a 7 notes : Do, Ré, Mi, Fa, Sol, La, Si. Chaque note correspond à un son différent. Le piano a des touches blanches et noires.', 'musique', 1),
('Le chant choral', 'Chanter en groupe, c''est chanter ensemble en écoutant les autres. On peut chanter à l''unisson (tous la même mélodie) ou en canon (décalé).', 'musique', 1),
('La flûte à bec', 'La flûte à bec est un instrument à vent. On souffle dedans et on bouche les trous avec les doigts pour changer les notes.', 'musique', 2),
('Les jeux collectifs', 'Les jeux collectifs comme le ballon prisonnier, la thèque ou le béret apprennent à jouer en équipe, à respecter les règles et à coopérer.', 'eps', 1),
('La gymnastique', 'La gymnastique comprend des roulades avant, la chandelle, la roue et les sauts. Cela développe la souplesse et l''équilibre.', 'eps', 1),
('La natation', 'Nager, c''est se déplacer dans l''eau. Les styles principaux sont : la brasse, le crawl et le dos crawlé. La flottaison est la première chose à apprendre.', 'eps', 1),
('L''expression corporelle', 'L''expression corporelle, c''est raconter une histoire ou exprimer une émotion avec son corps, sans parler, comme en danse ou en mime.', 'eps', 2);

-- 14. Questions de lecture (liées aux textes de emilie_lecture)
CREATE TABLE IF NOT EXISTS emilie_lecture_questions (
  id SERIAL PRIMARY KEY,
  lecture_id INTEGER REFERENCES emilie_lecture(id),
  question TEXT NOT NULL,
  options JSONB NOT NULL DEFAULT '[]',
  reponse_correcte TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'qcm'
);
ALTER TABLE emilie_lecture_questions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_read_lecture_questions" ON emilie_lecture_questions FOR SELECT USING (true);

INSERT INTO emilie_lecture_questions (lecture_id, question, options, reponse_correcte, type) VALUES
(1, 'Qui a entendu le petit chat miauler ?', '["Lola", "La maman", "Le chien", "Le voisin"]'::jsonb, 'Lola', 'qcm'),
(1, 'De quelle couleur est le petit chat ?', '["Noir et blanc", "Roux", "Gris", "Tigré"]'::jsonb, 'Noir et blanc', 'qcm'),
(1, 'Que donne la maman au petit chat ?', '["Du lait", "Du poisson", "Des croquettes", "De l''eau"]'::jsonb, 'Du lait', 'qcm'),
(2, 'Au centre de la forêt enchantée, qu''y a-t-il ?', '["Un lac magique", "Un château", "Une rivière", "Une montagne"]'::jsonb, 'Un lac magique', 'qcm'),
(2, 'De quelle couleur est l''eau du lac au printemps ?', '["Verte", "Dorée", "Orange", "Bleue"]'::jsonb, 'Verte', 'qcm'),
(3, 'Comment s''appelle le moment où l''eau se transforme en vapeur ?', '["L''évaporation", "La condensation", "La précipitation", "La vaporisation"]'::jsonb, 'L''évaporation', 'qcm'),
(3, 'Quand les nuages sont trop lourds, que se passe-t-il ?', '["Il pleut ou il neige", "Il fait beau", "Le vent se lève", "Les nuages disparaissent"]'::jsonb, 'Il pleut ou il neige', 'qcm'),
(4, 'Combien y a-t-il de saisons ?', '["4", "3", "5", "2"]'::jsonb, '4', 'qcm'),
(4, 'Quelle saison vient après l''automne ?', '["L''hiver", "Le printemps", "L''été", "L''automne"]'::jsonb, 'L''hiver', 'qcm'),
(5, 'Où va la petite fille tous les jours ?', '["À l''école", "Au parc", "Au marché", "Chez sa grand-mère"]'::jsonb, 'À l''école', 'qcm'),
(5, 'Que fait la petite fille pendant la récréation ?', '["Elle joue avec ses amis", "Elle lit", "Elle mange", "Elle dort"]'::jsonb, 'Elle joue avec ses amis', 'qcm'),
(6, 'Que mange la petite chenille après être sortie de son œuf ?', '["Une pomme", "Une feuille", "Une poire", "Une fraise"]'::jsonb, 'Une pomme', 'qcm'),
(6, 'En quoi la chenille se transforme-t-elle ?', '["En papillon", "En oiseau", "En coccinelle", "En abeille"]'::jsonb, 'En papillon', 'qcm');

-- Index pour performances
CREATE INDEX IF NOT EXISTS idx_emilie_grammaire_categorie ON emilie_grammaire(categorie);
CREATE INDEX IF NOT EXISTS idx_emilie_grammaire_niveau ON emilie_grammaire(niveau);
CREATE INDEX IF NOT EXISTS idx_emilie_orthographe_niveau ON emilie_orthographe(niveau);
CREATE INDEX IF NOT EXISTS idx_emilie_lecture_type ON emilie_lecture(type);
CREATE INDEX IF NOT EXISTS idx_emilie_calcul_mental_niveau ON emilie_calcul_mental(niveau);
CREATE INDEX IF NOT EXISTS idx_emilie_calcul_mental_operation ON emilie_calcul_mental(operation);
CREATE INDEX IF NOT EXISTS idx_emilie_problemes_niveau ON emilie_problemes(niveau);
CREATE INDEX IF NOT EXISTS idx_emilie_geometrie_niveau ON emilie_geometrie(niveau);
CREATE INDEX IF NOT EXISTS idx_emilie_mesures_niveau ON emilie_mesures(niveau);
CREATE INDEX IF NOT EXISTS idx_emilie_anglais_categorie ON emilie_anglais(categorie);
CREATE INDEX IF NOT EXISTS idx_emilie_questionner_monde_domaine ON emilie_questionner_monde(domaine);
CREATE INDEX IF NOT EXISTS idx_emilie_arts_domaine ON emilie_arts(domaine);
CREATE INDEX IF NOT EXISTS idx_emilie_lecture_questions_lecture_id ON emilie_lecture_questions(lecture_id);
