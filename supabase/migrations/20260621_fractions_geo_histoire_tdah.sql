-- Emilie App - Fractions, compléments géo/histoire, adapt. TDAH
-- Dépend des tables : geo_france, histoire_ce1

-- =====================================================
-- 1. FRACTIONS EXERCICES
-- =====================================================
CREATE TABLE IF NOT EXISTS fractions_exercices (
  id SERIAL PRIMARY KEY,
  niveau INTEGER NOT NULL DEFAULT 1,
  type TEXT NOT NULL CHECK (type IN ('pizza','partage')),
  numerateur INTEGER NOT NULL,
  denominateur INTEGER NOT NULL,
  consigne_fr TEXT NOT NULL,
  emoji_theme TEXT DEFAULT '🍕',
  reponse_correcte TEXT NOT NULL,
  nb_amis INTEGER DEFAULT 2,
  nb_objets INTEGER DEFAULT 6,
  created_at TIMESTAMP DEFAULT NOW()
);
ALTER TABLE fractions_exercices ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_read_fractions" ON fractions_exercices FOR SELECT USING (true);

INSERT INTO fractions_exercices (niveau, type, numerateur, denominateur, consigne_fr, emoji_theme, reponse_correcte, nb_amis, nb_objets) VALUES
-- Niveau 1 : reconnaître 1/2 (pizza coupée en 2)
(1, 'pizza', 1, 2, 'Colorie 1 part sur 2 de la pizza', '🍕', '1', NULL, NULL),
(1, 'pizza', 1, 2, 'Montre la moitié de la pizza', '🍕', '1', NULL, NULL),

-- Niveau 2 : 1/4 et 3/4 (pizza coupée en 4)
(2, 'pizza', 1, 4, 'Colorie 1 part sur 4 de la pizza', '🍕', '1', NULL, NULL),
(2, 'pizza', 3, 4, 'Colorie 3 parts sur 4 de la pizza', '🍕', '3', NULL, NULL),
(2, 'pizza', 2, 4, 'Colorie la moitié de la pizza (2 sur 4)', '🍕', '2', NULL, NULL),

-- Niveau 3 : 1/3 et 2/3 (pizza en 3)
(3, 'pizza', 1, 3, 'Colorie 1 part sur 3 de la pizza', '🍕', '1', NULL, NULL),
(3, 'pizza', 2, 3, 'Colorie 2 parts sur 3 de la pizza', '🍕', '2', NULL, NULL),

-- Niveau 4 : comparaison fractions
(4, 'pizza', 1, 2, 'Quelle est la plus grande part : 1/2 ou 1/4 ? (clique la pizza)', '🍕', '1_2', NULL, NULL),
(4, 'pizza', 1, 4, 'Quelle est la plus petite part : 1/2 ou 1/4 ? (clique la pizza)', '🍕', '1_4', NULL, NULL),
(4, 'pizza', 3, 4, 'Quelle est la plus grande : 3/4 ou 1/2 ?', '🍕', '3_4', NULL, NULL),

-- Partage équitable
(1, 'partage', 1, 2, '6 bonbons pour 2 amis. Combien chacun ?', '🍬', '3', 2, 6),
(1, 'partage', 1, 2, '4 bonbons pour 2 amis. Combien chacun ?', '🍬', '2', 2, 4),
(2, 'partage', 1, 3, '9 crayons pour 3 amis. Combien chacun ?', '🖍️', '3', 3, 9),
(2, 'partage', 1, 3, '6 crayons pour 3 amis. Combien chacun ?', '🖍️', '2', 3, 6),
(3, 'partage', 1, 2, '10 étoiles pour 2 amis. Combien chacune ?', '🌟', '5', 2, 10),
(3, 'partage', 1, 3, '12 étoiles pour 3 amis. Combien chacune ?', '🌟', '4', 3, 12),
(3, 'partage', 1, 4, '8 bonbons pour 4 amis. Combien chacun ?', '🍬', '2', 4, 8),
(4, 'partage', 1, 4, '12 crayons pour 4 amis. Combien chacun ?', '🖍️', '3', 4, 12),
(4, 'partage', 1, 3, '15 étoiles pour 3 amis. Combien chacune ?', '🌟', '5', 3, 15);

-- =====================================================
-- 2. GÉOGRAPHIE : complément fleuves + pays + capitales
-- =====================================================

-- Ajouter colonnes supplémentaires si pas déjà présentes
ALTER TABLE geo_france ADD COLUMN IF NOT EXISTS longueur_km INTEGER;
ALTER TABLE geo_france ADD COLUMN IF NOT EXISTS ville_traversee TEXT;
ALTER TABLE geo_france ADD COLUMN IF NOT EXISTS ocean_destination TEXT;
ALTER TABLE geo_france ADD COLUMN IF NOT EXISTS anecdote_fun TEXT;
ALTER TABLE geo_france ADD COLUMN IF NOT EXISTS drapeau_emoji TEXT;
ALTER TABLE geo_france ADD COLUMN IF NOT EXISTS direction TEXT;
ALTER TABLE geo_france ADD COLUMN IF NOT EXISTS monument_emoji TEXT;
ALTER TABLE geo_france ADD COLUMN IF NOT EXISTS couleur_hex TEXT;

-- Mise à jour des données existantes et ajout des colonnes
UPDATE geo_france SET
  longueur_km = CASE nom
    WHEN 'Loire' THEN 1006 WHEN 'Seine' THEN 777 WHEN 'Rhône' THEN 812
    WHEN 'Garonne' THEN 647 WHEN 'Rhin' THEN 1233 END,
  ville_traversee = CASE nom
    WHEN 'Loire' THEN 'Orléans, Tours, Nantes'
    WHEN 'Seine' THEN 'Paris, Rouen'
    WHEN 'Rhône' THEN 'Lyon, Avignon'
    WHEN 'Garonne' THEN 'Toulouse, Bordeaux'
    WHEN 'Rhin' THEN 'Strasbourg' END,
  ocean_destination = CASE nom
    WHEN 'Loire' THEN 'Atlantique' WHEN 'Seine' THEN 'Manche'
    WHEN 'Rhône' THEN 'Méditerranée' WHEN 'Garonne' THEN 'Atlantique'
    WHEN 'Rhin' THEN 'Mer du Nord' END,
  anecdote_fun = CASE nom
    WHEN 'Loire' THEN 'La Loire est si longue qu''elle traverserait la France de Paris à Marseille ! 🚗'
    WHEN 'Seine' THEN 'La Seine accueille les Jeux Olympiques de Paris 2024 ! 🏊'
    WHEN 'Rhône' THEN 'Le Rhône prend sa source dans un glacier en Suisse, c''est pour ça qu''il est si froid ! 🧊'
    WHEN 'Garonne' THEN 'La Garonne est la seule à avoir un fleuve jumeau : la Dordogne ! 🤝'
    WHEN 'Rhin' THEN 'Le Rhin a inspiré une célèbre légende : la Lorelei ! 🧜‍♀️' END,
  drapeau_emoji = CASE nom
    WHEN 'Espagne' THEN '🇪🇸' WHEN 'Italie' THEN '🇮🇹'
    WHEN 'Allemagne' THEN '🇩🇪' WHEN 'Belgique' THEN '🇧🇪'
    WHEN 'Suisse' THEN '🇨🇭' WHEN 'Luxembourg' THEN '🇱🇺'
    WHEN 'Andorre' THEN '🇦🇩' END,
  direction = CASE nom
    WHEN 'Espagne' THEN 'sud-ouest' WHEN 'Italie' THEN 'sud-est'
    WHEN 'Allemagne' THEN 'est' WHEN 'Belgique' THEN 'nord'
    WHEN 'Suisse' THEN 'est' WHEN 'Luxembourg' THEN 'nord-est'
    WHEN 'Andorre' THEN 'sud-ouest' END
WHERE type IN ('fleuve', 'pays_voisin');

UPDATE geo_france SET
  monument_emoji = CASE nom
    WHEN 'Paris' THEN '🗼' WHEN 'Madrid' THEN '🏛️'
    WHEN 'Rome' THEN '🏟️' WHEN 'Berlin' THEN '🚧'
    WHEN 'Londres' THEN '⏰' WHEN 'Bruxelles' THEN '🍫' END,
  drapeau_emoji = CASE nom
    WHEN 'Paris' THEN '🇫🇷' WHEN 'Madrid' THEN '🇪🇸'
    WHEN 'Rome' THEN '🇮🇹' WHEN 'Berlin' THEN '🇩🇪'
    WHEN 'Londres' THEN '🇬🇧' WHEN 'Bruxelles' THEN '🇧🇪' END
WHERE type = 'capitale';

UPDATE geo_france SET
  couleur_hex = CASE nom
    WHEN 'Auvergne-Rhône-Alpes' THEN '#E8D5F5'
    WHEN 'Bourgogne-Franche-Comté' THEN '#FDE8D5'
    WHEN 'Bretagne' THEN '#D5F5E8'
    WHEN 'Centre-Val de Loire' THEN '#F5ECD5'
    WHEN 'Corse' THEN '#D5E8F5'
    WHEN 'Grand Est' THEN '#F5D5E8'
    WHEN 'Hauts-de-France' THEN '#E8F5D5'
    WHEN 'Île-de-France' THEN '#F8D5D5'
    WHEN 'Normandie' THEN '#D5F5F5'
    WHEN 'Nouvelle-Aquitaine' THEN '#F0E8D5'
    WHEN 'Occitanie' THEN '#D8E8F0'
    WHEN 'Pays de la Loire' THEN '#E8F0D8'
    WHEN 'Provence-Alpes-Côte d''Azur' THEN '#F5E0D5' END
WHERE type = 'region';

-- =====================================================
-- 3. HISTOIRE : complément personnages + séquences + vrai/faux
-- =====================================================

-- Étendre le check constraint pour autoriser 'vrai_faux' et 'sequence'
ALTER TABLE histoire_ce1 DROP CONSTRAINT IF EXISTS histoire_ce1_type_contenu_check;
ALTER TABLE histoire_ce1 ADD CONSTRAINT histoire_ce1_type_contenu_check
  CHECK (type_contenu IN ('evenement','personnage','vie_quotidienne','vrai_faux','sequence','indices'));

-- Ajouter colonnes
ALTER TABLE histoire_ce1 ADD COLUMN IF NOT EXISTS indices TEXT[];
ALTER TABLE histoire_ce1 ADD COLUMN IF NOT EXISTS sequence_evenements TEXT[];
ALTER TABLE histoire_ce1 ADD COLUMN IF NOT EXISTS affirmation TEXT;
ALTER TABLE histoire_ce1 ADD COLUMN IF NOT EXISTS affirmation_vrai BOOLEAN;
ALTER TABLE histoire_ce1 ADD COLUMN IF NOT EXISTS explication_courte TEXT;

-- Personnages historiques avec indices (type_contenu = 'personnage' et type='devine')
-- On utilise la colonne indices (TEXT[]) pour stocker les 3 indices
UPDATE histoire_ce1 SET
  indices = CASE id
    WHEN (SELECT id FROM histoire_ce1 WHERE personnage = 'Jeanne d''Arc') THEN ARRAY['Je suis née en 1412', 'J''ai porté une armure', 'J''ai libéré Orléans']
    WHEN (SELECT id FROM histoire_ce1 WHERE personnage = 'Marie Curie') THEN ARRAY['Je suis une scientifique', 'J''ai découvert deux éléments', 'J''ai eu deux Prix Nobel']
    WHEN (SELECT id FROM histoire_ce1 WHERE personnage = 'Napoléon') THEN ARRAY['Je suis né en Corse', 'J''ai été empereur', 'J''ai créé le Code Civil']
    WHEN (SELECT id FROM histoire_ce1 WHERE personnage = 'Louis XIV') THEN ARRAY['On m''appelle le Roi Soleil', 'J''ai régné 72 ans', 'J''ai construit Versailles']
    WHEN (SELECT id FROM histoire_ce1 WHERE personnage = 'De Gaulle') THEN ARRAY['J''étais général', 'J''ai dit Non à l''Allemagne', 'J''ai fondé la 5e République']
    WHEN (SELECT id FROM histoire_ce1 WHERE personnage = 'Vercingétorix') THEN ARRAY['J''étais un chef gaulois', 'J''ai combattu César', 'Je me suis rendu à Alésia']
  END
WHERE personnage IS NOT NULL;

-- Vrai/Faux histoire : utiliser type_contenu = 'vrai_faux'
INSERT INTO histoire_ce1 (periode, evenement, description_simple, type_contenu, affirmation, affirmation_vrai, explication_courte, niveau) VALUES
('prehistoire', 'Le feu a été découvert par les hommes préhistoriques', 'Savoir si le feu a été découvert par les humains préhistoriques.', 'vrai_faux', 'Le feu a été découvert par les hommes préhistoriques', true, 'Ils ont appris à faire du feu en frottant des pierres ou du bois ! 🔥', 1),
('prehistoire', 'Les dinosaures vivaient avec les hommes préhistoriques', 'Savoir si dinosaures et humains ont cohabité.', 'vrai_faux', 'Les dinosaures vivaient avec les hommes préhistoriques', false, 'Les dinosaures ont disparu bien avant l''apparition des humains. 🦕', 1),
('antiquite', 'Les Romains ont construit des routes en France', 'Savoir si les Romains ont construit des routes en Gaule.', 'vrai_faux', 'Les Romains ont construit des routes en France', true, 'Les Romains ont construit plus de 100 000 km de routes ! 🛣️', 1),
('antiquite', 'Les Gaulois parlaient latin', 'Savoir quelle langue parlaient les Gaulois.', 'vrai_faux', 'Les Gaulois parlaient latin', false, 'Les Gaulois parlaient le gaulois, une langue celtique. Ils ont appris le latin après la conquête romaine. 🗣️', 1),
('moyen_age', 'Jeanne d''Arc était un roi', 'Savoir si Jeanne d''Arc était un homme.', 'vrai_faux', 'Jeanne d''Arc était un roi', false, 'Jeanne d''Arc était une jeune fille de 17 ans qui a mené l''armée française. ⚔️', 1),
('moyen_age', 'Les chevaliers portaient une armure en métal', 'Savoir comment étaient les chevaliers.', 'vrai_faux', 'Les chevaliers portaient une armure en métal', true, 'L''armure pesait environ 25 kilos, comme un sac de courses très lourd ! 🛡️', 1),
('renaissance', 'Christophe Colomb a découvert l''Amérique en 1492', 'Savoir qui a découvert l''Amérique.', 'vrai_faux', 'Christophe Colomb a découvert l''Amérique en 1492', true, 'Il pensait arriver en Inde mais il a découvert un nouveau continent ! ⛵', 1),
('renaissance', 'La tour Eiffel date du Moyen Âge', 'Savoir à quelle époque a été construite la tour Eiffel.', 'vrai_faux', 'La tour Eiffel date du Moyen Âge', false, 'La tour Eiffel a été construite en 1889, bien après le Moyen Âge ! 🗼', 1),
('temps_modernes', 'Louis XIV s''appelait le Roi Soleil', 'Savoir le surnom de Louis XIV.', 'vrai_faux', 'Louis XIV s''appelait le Roi Soleil', true, 'Il a choisi ce surnom car il dansait souvent le rôle du Soleil dans les ballets. ☀️', 1),
('temps_modernes', 'La Révolution française a eu lieu en 1789', 'Savoir en quelle année a eu lieu la Révolution.', 'vrai_faux', 'La Révolution française a eu lieu en 1789', true, 'Le 14 juillet 1789, le peuple prend la prison de la Bastille. 🎆', 1),
('epoque_contemporaine', 'Marie Curie était un homme', 'Savoir qui était Marie Curie.', 'vrai_faux', 'Marie Curie était un homme', false, 'Marie Curie était une femme, la première à recevoir le Prix Nobel ! 👩‍🔬', 1),
('epoque_contemporaine', 'Le droit de vote des femmes date de 1944', 'Savoir quand les femmes ont eu le droit de voter.', 'vrai_faux', 'Le droit de vote des femmes date de 1944', true, 'Avant 1944, seuls les hommes pouvaient voter en France. 🗳️', 1),
('epoque_contemporaine', 'La France a gagné la Première Guerre mondiale en 1918', 'Savoir quand s''est terminée la Première Guerre mondiale.', 'vrai_faux', 'La France et ses alliés ont gagné la Première Guerre mondiale en 1918', true, 'La guerre a duré 4 ans, de 1914 à 1918. 🕊️', 2),
('moyen_age', 'Les cathédrales ont été construites en un an', 'Savoir combien de temps prenait la construction des cathédrales.', 'vrai_faux', 'Les cathédrales ont été construites en un an', false, 'Une cathédrale pouvait mettre plus de 100 ans à être construite ! ⛪', 2);

-- =====================================================
-- 4. INDEXES
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_fractions_niveau ON fractions_exercices(niveau);
CREATE INDEX IF NOT EXISTS idx_fractions_type ON fractions_exercices(type);
