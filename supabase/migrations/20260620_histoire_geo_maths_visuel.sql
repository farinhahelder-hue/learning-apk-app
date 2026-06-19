-- Emilie App - Histoire, Géographie & Maths visuels
-- Nouvelles tables + seed data

-- =====================================================
-- 1. GÉOGRAPHIE FRANCE
-- =====================================================
CREATE TABLE IF NOT EXISTS geo_france (
  id SERIAL PRIMARY KEY,
  type TEXT NOT NULL CHECK (type IN ('region','fleuve','relief','pays_voisin','capitale','ocean_mer')),
  nom TEXT NOT NULL,
  capitale TEXT,
  description TEXT,
  emoji TEXT,
  anecdote TEXT,
  niveau INTEGER DEFAULT 1
);
ALTER TABLE geo_france ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_read_geo" ON geo_france FOR SELECT USING (true);

INSERT INTO geo_france (type, nom, capitale, description, emoji, anecdote, niveau) VALUES
-- 13 régions
('region', 'Auvergne-Rhône-Alpes', 'Lyon', 'La plus grande région de France avec ses volcans endormis.', '🌋', 'Le Puy de Dôme est un volcan célèbre !', 1),
('region', 'Bourgogne-Franche-Comté', 'Dijon', 'Connue pour sa moutarde et ses vins.', '🍯', 'La moutarde de Dijon est connue dans le monde entier.', 1),
('region', 'Bretagne', 'Rennes', 'Région au bord de la mer avec des menhirs mystérieux.', '⛵', 'Les menhirs de Carnac ont 6000 ans !', 1),
('region', 'Centre-Val de Loire', 'Orléans', 'Région des châteaux de la Loire.', '🏰', 'Il y a plus de 300 châteaux dans la région !', 1),
('region', 'Corse', 'Ajaccio', 'Une île magnifique dans la Méditerranée, née de Napoléon.', '🏝️', 'Napoléon Bonaparte est né à Ajaccio en 1769.', 1),
('region', 'Grand Est', 'Strasbourg', 'Région de l''est avec le Parlement Européen.', '🏛️', 'Strasbourg accueille le Parlement Européen.', 1),
('region', 'Hauts-de-France', 'Lille', 'Région du nord avec ses maisons en briques.', '🧱', 'Le beffroi de Lille est classé à l''UNESCO.', 1),
('region', 'Île-de-France', 'Paris', 'La région qui entoure Paris, la capitale de la France !', '🗼', 'Paris est surnommée "la Ville Lumière".', 1),
('region', 'Normandie', 'Rouen', 'Région du nord-ouest avec ses plages du débarquement.', '🏖️', 'Le Mont-Saint-Michel est un lieu magique entouré d''eau !', 1),
('region', 'Nouvelle-Aquitaine', 'Bordeaux', 'La plus grande région de France !', '🍷', 'La dune du Pilat est la plus haute dune d''Europe.', 1),
('region', 'Occitanie', 'Toulouse', 'Région du sud avec la Cité de l''Espace.', '🚀', 'Toulouse est la capitale européenne de l''aérospatiale.', 1),
('region', 'Pays de la Loire', 'Nantes', 'Région de l''ouest avec un château de la Duchesse Anne.', '🏯', 'Le château de Nantes était la résidence des Ducs de Bretagne.', 1),
('region', 'Provence-Alpes-Côte d''Azur', 'Marseille', 'Région ensoleillée du sud avec la mer Méditerranée.', '☀️', 'Marseille est la plus ancienne ville de France (fondée en 600 av. J.-C.).', 1),

-- 5 grands fleuves
('fleuve', 'Loire', NULL, 'Le plus long fleuve de France (1006 km).', '🌊', 'La Loire traverse 12 départements !', 1),
('fleuve', 'Seine', NULL, 'Fleuve qui traverse Paris (777 km).', '🏙️', 'La Seine prend sa source en Bourgogne.', 1),
('fleuve', 'Rhône', NULL, 'Fleuve puissant des Alpes à la Méditerranée (812 km).', '⛰️', 'Le Rhône prend sa source dans un glacier en Suisse !', 1),
('fleuve', 'Garonne', NULL, 'Fleuve du sud-ouest (647 km).', '🌿', 'La Garonne donne son nom au département de la Haute-Garonne.', 1),
('fleuve', 'Rhin', NULL, 'Fleuve qui fait frontière avec l''Allemagne (1233 km).', '🇪🇺', 'Le Rhin est une voie navigable très importante en Europe.', 1),

-- 5 reliefs
('relief', 'Alpes', NULL, 'La plus haute montagne d''Europe : le Mont Blanc (4809 m).', '🏔️', 'Le Mont Blanc est la plus haute montagne d''Europe !', 1),
('relief', 'Pyrénées', NULL, 'Montagnes qui séparent la France de l''Espagne.', '🏔️', 'Les Pyrénées s''étendent sur 430 km.', 1),
('relief', 'Massif Central', NULL, 'Région de volcans endormis au centre de la France.', '🌋', 'Le Massif Central a plus de 80 volcans !', 1),
('relief', 'Vosges', NULL, 'Montagnes de l''est de la France, recouvertes de forêts.', '🌲', 'Le Ballon d''Alsace est le plus haut sommet des Vosges.', 1),
('relief', 'Jura', NULL, 'Montagnes du nord-est à la frontière suisse.', '🏔️', 'Le Jura est connu pour ses lacs et ses forêts.', 1),

-- Pays voisins
('pays_voisin', 'Espagne', 'Madrid', 'Pays au sud des Pyrénées.', '🇪🇸', 'L''Espagne a inventé la sieste et la paella !', 1),
('pays_voisin', 'Italie', 'Rome', 'Pays en forme de botte au sud-est.', '🇮🇹', 'L''Italie ressemble à une botte sur la carte !', 1),
('pays_voisin', 'Allemagne', 'Berlin', 'Grand pays à l''est.', '🇩🇪', 'L''Allemagne a plus de 1000 sortes de saucisses !', 1),
('pays_voisin', 'Belgique', 'Bruxelles', 'Petit pays au nord.', '🇧🇪', 'La Belgique a trois langues officielles.', 1),
('pays_voisin', 'Suisse', 'Berne', 'Pays des montagnes et du chocolat.', '🇨🇭', 'La Suisse a 4 langues officielles !', 1),
('pays_voisin', 'Luxembourg', 'Luxembourg', 'Tout petit pays entre France, Belgique et Allemagne.', '🇱🇺', 'Le Luxembourg est l''un des plus petits pays d''Europe.', 1),
('pays_voisin', 'Andorre', 'Andorre-la-Vieille', 'Tout petit pays dans les Pyrénées.', '🇦🇩', 'Andorre est le 6e plus petit pays d''Europe.', 1),

-- Capitales européennes
('capitale', 'Paris', NULL, 'Capitale de la France, ville de l''amour et de la Tour Eiffel.', '🇫🇷', 'La Tour Eiffel mesure 330 mètres !', 1),
('capitale', 'Madrid', NULL, 'Capitale de l''Espagne, ville du soleil et de la danse.', '🇪🇸', 'Le musée du Prado à Madrid est l''un des plus célèbres du monde.', 1),
('capitale', 'Rome', NULL, 'Capitale de l''Italie, la "Ville Éternelle" aux 2000 ans d''histoire.', '🇮🇹', 'Rome a été construite sur 7 collines.', 1),
('capitale', 'Berlin', NULL, 'Capitale de l''Allemagne, ville de l''histoire et de la culture.', '🇩🇪', 'Le mur de Berlin séparait la ville en deux de 1961 à 1989.', 1),
('capitale', 'Londres', NULL, 'Capitale du Royaume-Uni, ville du Big Ben.', '🇬🇧', 'Le métro de Londres est le plus vieux du monde (1863).', 1),
('capitale', 'Bruxelles', NULL, 'Capitale de la Belgique et de l''Union Européenne.', '🇧🇪', 'Bruxelles est connue pour ses chocolats et sa grand-place.', 1),

-- Océans et mers
('ocean_mer', 'Océan Atlantique', NULL, 'Grand océan à l''ouest de la France.', '🌊', 'L''Atlantique est le deuxième plus grand océan du monde.', 1),
('ocean_mer', 'Mer Méditerranée', NULL, 'Mer chaude au sud de la France.', '🏖️', 'La Méditerranée baigne 22 pays !', 1),
('ocean_mer', 'Manche', NULL, 'Mer qui sépare la France de l''Angleterre.', '⛴️', 'Le tunnel sous la Manche mesure 50 km.', 1);

-- =====================================================
-- 2. HISTOIRE CE1
-- =====================================================
CREATE TABLE IF NOT EXISTS histoire_ce1 (
  id SERIAL PRIMARY KEY,
  periode TEXT NOT NULL CHECK (periode IN ('prehistoire','antiquite','moyen_age','renaissance','temps_modernes','epoque_contemporaine')),
  personnage TEXT,
  evenement TEXT NOT NULL,
  annee_approx TEXT,
  description_simple TEXT NOT NULL,
  emoji TEXT,
  type_contenu TEXT DEFAULT 'evenement' CHECK (type_contenu IN ('evenement','personnage','vie_quotidienne')),
  niveau INTEGER DEFAULT 1
);
ALTER TABLE histoire_ce1 ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_read_histoire" ON histoire_ce1 FOR SELECT USING (true);

INSERT INTO histoire_ce1 (periode, personnage, evenement, annee_approx, description_simple, emoji, type_contenu, niveau) VALUES
-- Préhistoire
('prehistoire', 'Homo sapiens', 'Apparition de l''Homme', '-300000', 'Les premiers humains apparaissent sur Terre. Ils vivent dans des grottes et chassent pour se nourrir.', '🦴', 'evenement', 1),
('prehistoire', NULL, 'Les grottes de Lascaux', '-15000', 'Les hommes préhistoriques peignent des animaux sur les murs des grottes. Les grottes de Lascaux sont les plus célèbres !', '🎨', 'evenement', 1),
('prehistoire', NULL, 'La découverte du feu', '-400000', 'Les hommes préhistoriques apprennent à faire du feu. Le feu les réchauffe, les protège et leur permet de cuire les aliments.', '🔥', 'evenement', 1),
('prehistoire', NULL, 'Les outils en pierre', '-100000', 'Les hommes fabriquent des outils en pierre : haches, couteaux et pointes de flèche pour chasser et se défendre.', '🪨', 'vie_quotidienne', 1),
('prehistoire', NULL, 'L''agriculture et l''élevage', '-8000', 'Les humains arrêtent de se déplacer tout le temps. Ils cultivent la terre et élèvent des animaux.', '🌾', 'vie_quotidienne', 1),

-- Antiquité
('antiquite', 'Vercingétorix', 'La guerre des Gaules', '-52', 'Vercingétorix, chef gaulois, lutte contre les Romains menés par Jules César. Il est vaincu à Alésia.', '⚔️', 'personnage', 1),
('antiquite', 'Jules César', 'La conquête romaine', '-50', 'Les Romains, venus d''Italie, conquièrent la Gaule (la France d''aujourd''hui).', '🏛️', 'personnage', 1),
('antiquite', NULL, 'La vie quotidienne romaine', '50', 'Les Romains construisent des routes, des aqueducs et des arènes. Ils parlent latin et portent des toges.', '🏗️', 'vie_quotidienne', 1),
('antiquite', NULL, 'Les Gallo-Romains', '100', 'Les Gaulois et les Romains vivent ensemble. Ils mélangent leurs cultures et leurs traditions.', '🤝', 'vie_quotidienne', 1),

-- Moyen Âge
('moyen_age', 'Charlemagne', 'Charlemagne, empereur', '800', 'Charlemagne devient empereur. Il agrandit son royaume et fait construire des écoles.', '👑', 'personnage', 1),
('moyen_age', 'Jeanne d''Arc', 'Jeanne d''Arc', '1429', 'Jeanne d''Arc, une jeune fille de 17 ans, mène l''armée française pour reprendre la ville d''Orléans.', '⚜️', 'personnage', 1),
('moyen_age', NULL, 'Les châteaux forts', '1100', 'Les seigneurs construisent des châteaux forts pour se protéger. Ils ont des murs épais et des douves.', '🏰', 'vie_quotidienne', 1),
('moyen_age', NULL, 'Les chevaliers', '1200', 'Les chevaliers portent une armure et combattent à cheval. Ils suivent un code d''honneur.', '🛡️', 'vie_quotidienne', 1),
('moyen_age', NULL, 'Les cathédrales', '1300', 'De magnifiques cathédrales sont construites dans toute la France. Celle de Notre-Dame de Paris est célèbre.', '⛪', 'vie_quotidienne', 1),

-- Renaissance / Grandes découvertes
('renaissance', 'Christophe Colomb', 'La découverte de l''Amérique', '1492', 'Christophe Colomb traverse l''océan pour trouver une route vers les Indes. Il découvre un nouveau continent : l''Amérique !', '⛵', 'personnage', 1),
('renaissance', NULL, 'L''imprimerie', '1450', 'Gutenberg invente l''imprimerie. Maintenant, on peut imprimer des livres en grand nombre !', '📚', 'evenement', 1),
('renaissance', NULL, 'Les explorateurs', '1500', 'Des navigateurs explorent le monde : Magellan fait le premier tour du monde, Cartier découvre le Canada.', '🌍', 'evenement', 1),

-- Temps modernes
('temps_modernes', 'Louis XIV', 'Louis XIV, le Roi Soleil', '1661', 'Louis XIV construit le magnifique château de Versailles. Il est le roi le plus puissant d''Europe.', '👑', 'personnage', 1),
('temps_modernes', NULL, 'La Révolution française', '1789', 'Le peuple se révolte. La devise Liberté, Égalité, Fraternité devient celle de la France. La Bastille est prise.', '🇫🇷', 'evenement', 1),
('temps_modernes', 'Napoléon', 'Napoléon Bonaparte', '1804', 'Napoléon devient empereur. Il conquiert une grande partie de l''Europe et crée le Code Civil.', '🎖️', 'personnage', 1),

-- Époque contemporaine
('epoque_contemporaine', 'Marie Curie', 'Marie Curie et la radioactivité', '1903', 'Marie Curie découvre deux nouveaux éléments chimiques. Elle est la première femme à recevoir le Prix Nobel.', '🔬', 'personnage', 1),
('epoque_contemporaine', NULL, 'La Première Guerre mondiale', '1914-1918', 'Une grande guerre oppose la France à l''Allemagne. Les soldats vivent dans les tranchées.', '🎖️', 'evenement', 1),
('epoque_contemporaine', 'De Gaulle', 'Charles de Gaulle', '1940', 'Le Général de Gaulle appelle les Français à résister pendant la Seconde Guerre mondiale.', '🎙️', 'personnage', 1),
('epoque_contemporaine', NULL, 'La construction européenne', '1957', 'La France et ses voisins fondent l''Union Européenne pour vivre en paix et coopérer.', '🇪🇺', 'evenement', 1),
('epoque_contemporaine', NULL, 'Le droit de vote des femmes', '1944', 'Les femmes obtiennent le droit de voter en France grâce à leur combat pour l''égalité.', '🗳️', 'evenement', 1);

-- =====================================================
-- 3. MATHÉMATIQUES VISUELLES (table des opérations)
-- =====================================================
CREATE TABLE IF NOT EXISTS math_operations (
  id SERIAL PRIMARY KEY,
  type_operation TEXT NOT NULL CHECK (type_operation IN ('addition','soustraction','multiplication','fraction','comparaison')),
  operande1 INTEGER NOT NULL,
  operande2 INTEGER NOT NULL,
  resultat INTEGER,
  emoji_theme TEXT DEFAULT '🥐',
  visual_config JSONB DEFAULT '{"objects":true,"animation":"slide","grille":false}',
  difficulte INTEGER DEFAULT 1,
  niveau_min INTEGER DEFAULT 1
);
ALTER TABLE math_operations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_read_math_ops" ON math_operations FOR SELECT USING (true);

INSERT INTO math_operations (type_operation, operande1, operande2, resultat, emoji_theme, visual_config, difficulte) VALUES
-- Additions visuelles (boulangerie 🥐)
('addition', 1, 1, 2, '🥐', '{"objects":true,"animation":"slide","emoji":"🥐"}', 1),
('addition', 2, 1, 3, '🥐', '{"objects":true,"animation":"slide","emoji":"🥐"}', 1),
('addition', 2, 2, 4, '🥐', '{"objects":true,"animation":"slide","emoji":"🥐"}', 1),
('addition', 3, 2, 5, '🥐', '{"objects":true,"animation":"slide","emoji":"🥐"}', 1),
('addition', 3, 3, 6, '🥐', '{"objects":true,"animation":"slide","emoji":"🥐"}', 1),
('addition', 4, 3, 7, '🥐', '{"objects":true,"animation":"slide","emoji":"🥐"}', 1),
('addition', 4, 4, 8, '🥐', '{"objects":true,"animation":"slide","emoji":"🥐"}', 1),
('addition', 5, 4, 9, '🥐', '{"objects":true,"animation":"slide","emoji":"🥐"}', 1),
('addition', 5, 5, 10, '🥐', '{"objects":true,"animation":"slide","emoji":"🥐"}', 1),
('addition', 6, 4, 10, '🥐', '{"objects":true,"animation":"slide","emoji":"🥐"}', 1),
('addition', 7, 3, 10, '🥐', '{"objects":true,"animation":"slide","emoji":"🥐"}', 1),
('addition', 8, 2, 10, '🥐', '{"objects":true,"animation":"slide","emoji":"🥐"}', 1),
('addition', 9, 1, 10, '🥐', '{"objects":true,"animation":"slide","emoji":"🥐"}', 1),
('addition', 10, 5, 15, '🥐', '{"objects":true,"animation":"slide","emoji":"🥐"}', 2),
('addition', 12, 8, 20, '🥐', '{"objects":true,"animation":"slide","emoji":"🥐"}', 2),
('addition', 15, 5, 20, '🥐', '{"objects":true,"animation":"slide","emoji":"🥐"}', 2),
('addition', 20, 10, 30, '🥐', '{"objects":true,"animation":"slide","emoji":"🥐"}', 3),
('addition', 25, 15, 40, '🥐', '{"objects":true,"animation":"slide","emoji":"🥐"}', 3),

-- Soustractions visuelles (ferme 🐔)
('soustraction', 2, 1, 1, '🐔', '{"objects":true,"animation":"exit","emoji":"🐔"}', 1),
('soustraction', 3, 1, 2, '🐔', '{"objects":true,"animation":"exit","emoji":"🐔"}', 1),
('soustraction', 3, 2, 1, '🐔', '{"objects":true,"animation":"exit","emoji":"🐔"}', 1),
('soustraction', 4, 1, 3, '🐔', '{"objects":true,"animation":"exit","emoji":"🐔"}', 1),
('soustraction', 4, 2, 2, '🐔', '{"objects":true,"animation":"exit","emoji":"🐔"}', 1),
('soustraction', 5, 2, 3, '🐔', '{"objects":true,"animation":"exit","emoji":"🐔"}', 1),
('soustraction', 5, 3, 2, '🐔', '{"objects":true,"animation":"exit","emoji":"🐔"}', 1),
('soustraction', 6, 3, 3, '🐔', '{"objects":true,"animation":"exit","emoji":"🐔"}', 1),
('soustraction', 7, 4, 3, '🐔', '{"objects":true,"animation":"exit","emoji":"🐔"}', 2),
('soustraction', 8, 3, 5, '🐔', '{"objects":true,"animation":"exit","emoji":"🐔"}', 2),
('soustraction', 9, 4, 5, '🐔', '{"objects":true,"animation":"exit","emoji":"🐔"}', 2),
('soustraction', 10, 4, 6, '🐔', '{"objects":true,"animation":"exit","emoji":"🐔"}', 2),
('soustraction', 12, 5, 7, '🐔', '{"objects":true,"animation":"exit","emoji":"🐔"}', 3),
('soustraction', 15, 6, 9, '🐔', '{"objects":true,"animation":"exit","emoji":"🐔"}', 3),

-- Multiplications visuelles (gâteaux 🎂)
('multiplication', 2, 1, 2, '🎂', '{"objects":true,"animation":"grille","grille":"2x1","emoji":"🎂"}', 1),
('multiplication', 2, 2, 4, '🎂', '{"objects":true,"animation":"grille","grille":"2x2","emoji":"🎂"}', 1),
('multiplication', 2, 3, 6, '🎂', '{"objects":true,"animation":"grille","grille":"2x3","emoji":"🎂"}', 1),
('multiplication', 2, 4, 8, '🎂', '{"objects":true,"animation":"grille","grille":"2x4","emoji":"🎂"}', 1),
('multiplication', 2, 5, 10, '🎂', '{"objects":true,"animation":"grille","grille":"2x5","emoji":"🎂"}', 1),
('multiplication', 2, 10, 20, '🎂', '{"objects":true,"animation":"grille","grille":"2x10","emoji":"🎂"}', 1),
('multiplication', 3, 2, 6, '🎂', '{"objects":true,"animation":"grille","grille":"3x2","emoji":"🎂"}', 1),
('multiplication', 3, 3, 9, '🎂', '{"objects":true,"animation":"grille","grille":"3x3","emoji":"🎂"}', 2),
('multiplication', 3, 4, 12, '🎂', '{"objects":true,"animation":"grille","grille":"3x4","emoji":"🎂"}', 2),
('multiplication', 3, 5, 15, '🎂', '{"objects":true,"animation":"grille","grille":"3x5","emoji":"🎂"}', 2),
('multiplication', 4, 2, 8, '🎂', '{"objects":true,"animation":"grille","grille":"4x2","emoji":"🎂"}', 2),
('multiplication', 4, 3, 12, '🎂', '{"objects":true,"animation":"grille","grille":"4x3","emoji":"🎂"}', 2),
('multiplication', 4, 4, 16, '🎂', '{"objects":true,"animation":"grille","grille":"4x4","emoji":"🎂"}', 2),
('multiplication', 4, 5, 20, '🎂', '{"objects":true,"animation":"grille","grille":"4x5","emoji":"🎂"}', 2),
('multiplication', 5, 2, 10, '🎂', '{"objects":true,"animation":"grille","grille":"5x2","emoji":"🎂"}', 1),
('multiplication', 5, 3, 15, '🎂', '{"objects":true,"animation":"grille","grille":"5x3","emoji":"🎂"}', 2),
('multiplication', 5, 4, 20, '🎂', '{"objects":true,"animation":"grille","grille":"5x4","emoji":"🎂"}', 2),
('multiplication', 5, 5, 25, '🎂', '{"objects":true,"animation":"grille","grille":"5x5","emoji":"🎂"}', 2),
('multiplication', 10, 2, 20, '🎂', '{"objects":true,"animation":"grille","grille":"10x2","emoji":"🎂"}', 1),
('multiplication', 10, 3, 30, '🎂', '{"objects":true,"animation":"grille","grille":"10x3","emoji":"🎂"}', 2),
('multiplication', 10, 4, 40, '🎂', '{"objects":true,"animation":"grille","grille":"10x4","emoji":"🎂"}', 2),
('multiplication', 10, 5, 50, '🎂', '{"objects":true,"animation":"grille","grille":"10x5","emoji":"🎂"}', 2);

-- =====================================================
-- 4. MINI-GAMES CONFIG
-- =====================================================
CREATE TABLE IF NOT EXISTS mini_games (
  id SERIAL PRIMARY KEY,
  matiere TEXT NOT NULL,
  nom TEXT NOT NULL,
  type TEXT NOT NULL,
  config_json JSONB DEFAULT '{}',
  niveau_min INTEGER DEFAULT 1,
  niveau_max INTEGER DEFAULT 5
);
ALTER TABLE mini_games ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_read_minigames" ON mini_games FOR SELECT USING (true);

INSERT INTO mini_games (matiere, nom, type, config_json, niveau_min, niveau_max) VALUES
('geo', 'Où est-ce ?', 'carte', '{"carte":"france","mode":"placer","elements":["region","fleuve","relief"]}', 1, 3),
('geo', 'Le drapeau mystère', 'qcm', '{"nb_choix":4,"questions":15}', 1, 3),
('geo', 'Relie le fleuve à sa ville', 'association', '{"paires":5}', 2, 4),
('geo', 'Vrai ou Faux géo', 'vrai_faux', '{"questions":15}', 1, 3),
('geo', 'Voyage express', 'quiz', '{"nb_questions":10,"timeout":30}', 2, 5),
('histoire', 'La frise du temps', 'chronologie', '{"evenements":12}', 1, 5),
('histoire', 'Qui suis-je ?', 'devine_personnage', '{"indices":3,"personnages":10}', 2, 5),
('histoire', 'Vrai ou Faux histoire', 'vrai_faux', '{"questions":15}', 1, 3),
('histoire', 'Reconstitue l''histoire', 'ordre_images', '{"images":4}', 2, 4),
('math', 'Boulangerie d''Émilie', 'addition_visuelle', '{"emoji":"🥐","max":20,"niveaux":3}', 1, 5),
('math', 'La ferme d''Émilie', 'soustraction_visuelle', '{"emoji":"🐔","max":15,"niveaux":3}', 1, 5),
('math', 'Les rangées de gâteaux', 'multiplication_visuelle', '{"emoji":"🎂","tables":[2,3,4,5,10]}', 1, 5),
('math', 'La chenille des tables', 'chenille', '{"tables":[2,3,4,5,10]}', 2, 5),
('math', 'Bataille de tables', 'bataille', '{"tables":[2,3,4,5,10],"adversaire":"dragon"}', 2, 5),
('math', 'La pizza d''Émilie', 'fractions', '{"fractions":["1/2","1/3","1/4","2/4","3/4"]}', 3, 5),
('math', 'Partage équitable', 'partage', '{"max_amis":4,"max_cadeaux":10}', 3, 5),
('math', 'La balance magique', 'balance', '{"max":20}', 2, 5),
('math', 'L''architecte', 'geometrie', '{"formes":["carre","rectangle","triangle","cercle","losange","hexagone"]}', 2, 5),
('math', 'Miroir magique', 'symetrie', '{"grille":"6x6"}', 3, 5);

-- =====================================================
-- 5. DAILY PLAN (routine visuelle)
-- =====================================================
CREATE TABLE IF NOT EXISTS daily_plan (
  id SERIAL PRIMARY KEY,
  user_id TEXT NOT NULL DEFAULT 'emilie',
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  activites JSONB NOT NULL DEFAULT '[]',
  ordre JSONB NOT NULL DEFAULT '[]',
  complete JSONB DEFAULT '[]',
  mode_calme BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW()
);
ALTER TABLE daily_plan ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_read_plan" ON daily_plan FOR SELECT USING (true);
CREATE POLICY "anon_upsert_plan" ON daily_plan FOR INSERT WITH CHECK (true);
CREATE POLICY "anon_update_plan" ON daily_plan FOR UPDATE USING (true);

-- Insert a default plan for today
INSERT INTO daily_plan (user_id, date, activites, ordre, complete, mode_calme)
SELECT 'emilie', CURRENT_DATE,
  '["🔢 Boulangerie (additions)","📖 Lecture","🎙️ Dictée","🌟 Découvertes"]',
  '["🔢","📖","🎙️","🌟"]',
  '[]',
  false
WHERE NOT EXISTS (SELECT 1 FROM daily_plan WHERE user_id = 'emilie' AND date = CURRENT_DATE);

-- =====================================================
-- 6. TDAH SETTINGS (extensions user_progress)
-- =====================================================
ALTER TABLE IF EXISTS user_progress
  ADD COLUMN IF NOT EXISTS mode_calme BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS routine_active BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS auto_audio BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS pause_etoiles BOOLEAN DEFAULT true;

-- =====================================================
-- INDEXES
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_geo_type ON geo_france(type);
CREATE INDEX IF NOT EXISTS idx_histoire_periode ON histoire_ce1(periode);
CREATE INDEX IF NOT EXISTS idx_math_ops_type ON math_operations(type_operation);
CREATE INDEX IF NOT EXISTS idx_math_ops_difficulte ON math_operations(difficulte);
CREATE INDEX IF NOT EXISTS idx_minigames_matiere ON mini_games(matiere);
CREATE INDEX IF NOT EXISTS idx_daily_plan_user_date ON daily_plan(user_id, date);
