-- Emilie App CE1 - Phase 4 : Conjugaison, Streaks, Contenu enrichi
-- Dépend : tables existantes

-- =====================================================
-- 1. TABLE CONJUGAISON
-- =====================================================
CREATE TABLE IF NOT EXISTS conjugaison_exercices (
  id SERIAL PRIMARY KEY,
  verbe TEXT NOT NULL,
  pronom TEXT NOT NULL,
  temps TEXT DEFAULT 'présent',
  bonne_reponse TEXT NOT NULL,
  mauvaise1 TEXT NOT NULL,
  mauvaise2 TEXT NOT NULL,
  groupe INTEGER DEFAULT 1,
  created_at TIMESTAMP DEFAULT NOW()
);
ALTER TABLE conjugaison_exercices ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_read_conjugaison" ON conjugaison_exercices FOR SELECT USING (true);

INSERT INTO conjugaison_exercices (verbe, pronom, bonne_reponse, mauvaise1, mauvaise2, groupe) VALUES
('être', 'je', 'suis', 'es', 'est', 3),
('être', 'tu', 'es', 'suis', 'est', 3),
('être', 'il/elle', 'est', 'es', 'suis', 3),
('être', 'nous', 'sommes', 'sont', 'êtes', 3),
('être', 'vous', 'êtes', 'sommes', 'sont', 3),
('être', 'ils/elles', 'sont', 'sommes', 'êtes', 3),
('avoir', 'j''', 'ai', 'as', 'a', 3),
('avoir', 'tu', 'as', 'ai', 'a', 3),
('avoir', 'il/elle', 'a', 'as', 'ont', 3),
('avoir', 'nous', 'avons', 'ont', 'avez', 3),
('avoir', 'vous', 'avez', 'avons', 'ont', 3),
('avoir', 'ils/elles', 'ont', 'avons', 'avez', 3),
('manger', 'je', 'mange', 'manges', 'mangent', 1),
('manger', 'tu', 'manges', 'mange', 'mangent', 1),
('manger', 'il/elle', 'mange', 'manges', 'mangent', 1),
('manger', 'nous', 'mangeons', 'mangez', 'mangent', 1),
('manger', 'vous', 'mangez', 'mangeons', 'mangent', 1),
('manger', 'ils/elles', 'mangent', 'mange', 'mangeons', 1),
('jouer', 'je', 'joue', 'joues', 'jouent', 1),
('jouer', 'tu', 'joues', 'joue', 'jouent', 1),
('jouer', 'il/elle', 'joue', 'joues', 'jouent', 1),
('jouer', 'nous', 'jouons', 'jouez', 'jouent', 1),
('jouer', 'vous', 'jouez', 'jouons', 'jouent', 1),
('jouer', 'ils/elles', 'jouent', 'joue', 'jouons', 1),
('danser', 'je', 'danse', 'danses', 'dansent', 1),
('danser', 'nous', 'dansons', 'dansez', 'dansent', 1),
('chanter', 'tu', 'chantes', 'chante', 'chantent', 1),
('chanter', 'vous', 'chantez', 'chantons', 'chantent', 1),
('parler', 'je', 'parle', 'parles', 'parlent', 1),
('parler', 'ils/elles', 'parlent', 'parle', 'parlons', 1);

-- =====================================================
-- 2. COLONNES STREAK
-- =====================================================
ALTER TABLE user_progress ADD COLUMN IF NOT EXISTS streak_count INTEGER DEFAULT 0;
ALTER TABLE user_progress ADD COLUMN IF NOT EXISTS derniere_session TIMESTAMP;
ALTER TABLE user_progress ADD COLUMN IF NOT EXISTS streak_last_date DATE;
ALTER TABLE user_progress ADD COLUMN IF NOT EXISTS sessions_par_jour INTEGER DEFAULT 0;

-- =====================================================
-- 3. ENRICHISSEMENT CALCUL MENTAL (niveau 3)
-- =====================================================
INSERT INTO emilie_calcul_mental (operation, operande1, operande2, reponse, niveau)
SELECT * FROM (VALUES
  ('addition', 45, 37, 82, 3),
  ('addition', 68, 24, 92, 3),
  ('addition', 53, 39, 92, 3),
  ('addition', 71, 28, 99, 3),
  ('addition', 34, 57, 91, 3),
  ('addition', 62, 29, 91, 3),
  ('addition', 47, 44, 91, 3),
  ('addition', 55, 38, 93, 3),
  ('addition', 39, 46, 85, 3),
  ('addition', 72, 19, 91, 3),
  ('soustraction', 82, 37, 45, 3),
  ('soustraction', 91, 54, 37, 3),
  ('soustraction', 75, 38, 37, 3),
  ('soustraction', 63, 27, 36, 3),
  ('soustraction', 84, 46, 38, 3),
  ('soustraction', 70, 35, 35, 3),
  ('soustraction', 93, 57, 36, 3),
  ('soustraction', 66, 29, 37, 3),
  ('soustraction', 80, 44, 36, 3),
  ('soustraction', 55, 18, 37, 3),
  ('multiplication', 6, 7, 42, 3),
  ('multiplication', 8, 6, 48, 3),
  ('multiplication', 7, 9, 63, 3),
  ('multiplication', 5, 8, 40, 3),
  ('multiplication', 9, 4, 36, 3),
  ('multiplication', 6, 6, 36, 3),
  ('multiplication', 7, 7, 49, 3),
  ('multiplication', 8, 8, 64, 3),
  ('multiplication', 9, 9, 81, 3)
) AS t
WHERE NOT EXISTS (SELECT 1 FROM emilie_calcul_mental WHERE niveau = 3 LIMIT 1);

-- =====================================================
-- 4. PROBLÈMES À 2 ÉTAPES
-- =====================================================
INSERT INTO emilie_problemes (enonce, operation, reponse, etapes, niveau)
SELECT * FROM (VALUES
  ('Emilie a 24 🍬. Elle en donne 8 à sa sœur puis sa mamie lui en donne 15. Combien en a-t-elle ?', '24 - 8 + 15 = 31', '31', 2, 2),
  ('Noisette 🐿️ a 18 noisettes. Elle en mange 5 le matin et 7 l''après-midi. Combien reste-t-il ?', '18 - 5 - 7 = 6', '6', 2, 2),
  ('Bulle 🪼 voit 35 étoiles. 12 partent puis 20 arrivent. Combien d''étoiles maintenant ?', '35 - 12 + 20 = 43', '43', 2, 2),
  ('Câlin 🦭 a 45 poissons. Il en attrape 18 de plus puis en mange 10. Combien en a-t-il ?', '45 + 18 - 10 = 53', '53', 2, 2),
  ('Dans la classe il y a 12 🚹 et 14 🚺. 3 enfants sont absents. Combien présents ?', '12 + 14 - 3 = 23', '23', 2, 2)
) AS t
WHERE NOT EXISTS (SELECT 1 FROM emilie_problemes WHERE niveau = 2 AND etapes = 2 LIMIT 1);

-- =====================================================
-- 5. GÉOMÉTRIE : PÉRIMÈTRE
-- =====================================================
INSERT INTO emilie_geometrie (notion, description, niveau)
SELECT * FROM (VALUES
  ('Périmètre du carré', 'Le périmètre d''un carré = côté × 4. Si le côté mesure 3 cm, le périmètre = 3 × 4 = 12 cm.', 2),
  ('Périmètre du rectangle', 'Le périmètre d''un rectangle = (longueur + largeur) × 2. Ex : (5 + 3) × 2 = 16 cm.', 2),
  ('Calcul de périmètre', 'Un carré de côté 5 cm a quel périmètre ? Réponse : 20 cm (5 × 4).', 2)
) AS t
WHERE NOT EXISTS (SELECT 1 FROM emilie_geometrie WHERE notion = 'Périmètre du carré' LIMIT 1);

-- =====================================================
-- 6. HISTOIRE : COMPLÉMENTS PERSONNAGES
-- =====================================================
INSERT INTO histoire_ce1 (periode, personnage, evenement, description_simple, emoji, type_contenu, indices)
SELECT * FROM (VALUES
  ('moyen_age', 'Jeanne d''Arc', 'Jeanne d''Arc libère Orléans', 'Jeanne d''Arc, une jeune fille de 17 ans, a mené l''armée française à la victoire.', '⚜️', 'personnage', ARRAY['Je suis née en 1412','J''ai porté une armure','J''ai mené une armée française à 17 ans']),
  ('epoque_contemporaine', 'Charles de Gaulle', 'Le général de Gaulle', 'Charles de Gaulle a organisé la Résistance pendant la guerre et fondé la 5e République.', '🎖️', 'personnage', ARRAY['J''étais général pendant la guerre','J''ai dit Non à l''Allemagne à la radio','J''ai fondé la 5e République en 1958'])
) AS t
WHERE NOT EXISTS (SELECT 1 FROM histoire_ce1 WHERE personnage = 'Jeanne d''Arc' AND type_contenu = 'personnage' LIMIT 1);

-- Vrai/Faux supplémentaires
INSERT INTO histoire_ce1 (periode, evenement, description_simple, type_contenu, affirmation, affirmation_vrai, explication_courte, niveau)
SELECT * FROM (VALUES
  ('antiquite', 'Jules César a conquis la Gaule', 'Savoir qui a conquis la Gaule.', 'vrai_faux', 'Jules César a conquis la Gaule', true, 'Jules César, un général romain, a soumis la Gaule après la bataille d''Alésia en -52. ⚔️', 1),
  ('epoque_contemporaine', 'La Première Guerre mondiale a duré 10 ans', 'Savoir la durée de la Première Guerre mondiale.', 'vrai_faux', 'La Première Guerre mondiale a duré 10 ans', false, 'Elle a duré 4 ans, de 1914 à 1918. 🕊️', 1),
  ('moyen_age', 'Les châteaux forts avaient des douves remplies d''eau', 'Savoir à quoi servaient les douves.', 'vrai_faux', 'Les châteaux forts avaient des douves remplies d''eau', true, 'Les douves empêchaient les ennemis d''approcher des murs. 🏰', 1),
  ('temps_modernes', 'La Marseillaise a été écrite pendant la Révolution', 'Savoir l''origine de l''hymne national.', 'vrai_faux', 'La Marseillaise a été écrite pendant la Révolution française', true, 'Elle a été composée en 1792 pour l''armée révolutionnaire. 🎵', 2),
  ('epoque_contemporaine', 'L''homme a marché sur la Lune en 1969', 'Savoir quand l''homme a marché sur la Lune.', 'vrai_faux', 'L''homme a marché sur la Lune en 1969', true, 'Neil Armstrong a été le premier homme sur la Lune le 21 juillet 1969. 🌙', 2)
) AS t
WHERE NOT EXISTS (SELECT 1 FROM histoire_ce1 WHERE affirmation = 'Jules César a conquis la Gaule' LIMIT 1);

-- =====================================================
-- 7. GÉOGRAPHIE : MERS ET OCÉANS
-- =====================================================
INSERT INTO geo_france (type, nom, description, emoji, anecdote, niveau)
SELECT * FROM (VALUES
  ('ocean_mer', 'Océan Atlantique', 'Grand océan à l''ouest de la France.', '🌊', 'L''Atlantique est le 2e plus grand océan du monde. Il borde la côte ouest de la France.', 1),
  ('ocean_mer', 'Mer Méditerranée', 'Mer chaude au sud de la France.', '🏖️', 'La Méditerranée baigne les plages du sud de la France comme Nice et Marseille.', 1),
  ('ocean_mer', 'Manche', 'Mer qui sépare la France de l''Angleterre.', '⛴️', 'Le tunnel sous la Manche mesure 50 km et relie la France à l''Angleterre en train !', 1),
  ('ocean_mer', 'Mer du Nord', 'Mer au nord de la France près de Dunkerque.', '🌅', 'La Mer du Nord est connue pour ses plages de sable et ses ports de pêche.', 1)
) AS t
WHERE NOT EXISTS (SELECT 1 FROM geo_france WHERE type = 'ocean_mer' AND nom = 'Océan Atlantique' LIMIT 1);

-- =====================================================
-- 8. INDEXES
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_conjugaison_verbe ON conjugaison_exercices(verbe);
CREATE INDEX IF NOT EXISTS idx_user_progress_streak ON user_progress(streak_count);
