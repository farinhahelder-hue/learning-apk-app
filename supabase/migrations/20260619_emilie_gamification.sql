-- Emilie App - Gamification : user_progress + badges + sessions
-- Dépend des 14 tables existantes (emilie_grammaire, etc.)

-- 1. Profil utilisateur avec progression
CREATE TABLE IF NOT EXISTS user_progress (
  id SERIAL PRIMARY KEY,
  user_id TEXT NOT NULL DEFAULT 'emilie',
  total_xp INTEGER DEFAULT 0,
  level INTEGER DEFAULT 1,
  stars INTEGER DEFAULT 0,
  streak_days INTEGER DEFAULT 0,
  last_play_date DATE DEFAULT CURRENT_DATE,
  badges TEXT[] DEFAULT '{}',
  math_score INTEGER DEFAULT 0,
  french_score INTEGER DEFAULT 0,
  science_score INTEGER DEFAULT 0,
  discovery_score INTEGER DEFAULT 0,
  total_exercises INTEGER DEFAULT 0,
  correct_answers INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_read_progress" ON user_progress FOR SELECT USING (true);
CREATE POLICY "anon_upsert_progress" ON user_progress FOR INSERT WITH CHECK (true);
CREATE POLICY "anon_update_progress" ON user_progress FOR UPDATE USING (true);

-- 2. Sessions d'entraînement
CREATE TABLE IF NOT EXISTS user_sessions (
  id SERIAL PRIMARY KEY,
  user_id TEXT NOT NULL DEFAULT 'emilie',
  subject TEXT NOT NULL,
  category TEXT,
  score INTEGER DEFAULT 0,
  total_questions INTEGER DEFAULT 0,
  xp_earned INTEGER DEFAULT 0,
  stars_earned INTEGER DEFAULT 0,
  duration_seconds INTEGER DEFAULT 0,
  completed BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW()
);
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_read_sessions" ON user_sessions FOR SELECT USING (true);
CREATE POLICY "anon_insert_sessions" ON user_sessions FOR INSERT WITH CHECK (true);

-- 3. Badges débloqués
CREATE TABLE IF NOT EXISTS user_badges (
  id SERIAL PRIMARY KEY,
  user_id TEXT NOT NULL DEFAULT 'emilie',
  badge_id TEXT NOT NULL,
  badge_name TEXT NOT NULL,
  badge_emoji TEXT NOT NULL,
  earned_at TIMESTAMP DEFAULT NOW()
);
ALTER TABLE user_badges ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon_read_badges" ON user_badges FOR SELECT USING (true);
CREATE POLICY "anon_insert_badges" ON user_badges FOR INSERT WITH CHECK (true);

-- Seed : créer le profil Emilie si vide
INSERT INTO user_progress (user_id, total_xp, level, stars)
SELECT 'emilie', 0, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM user_progress WHERE user_id = 'emilie');

-- Index
CREATE INDEX IF NOT EXISTS idx_sessions_user ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_subject ON user_sessions(subject);
CREATE INDEX IF NOT EXISTS idx_sessions_created ON user_sessions(created_at);
CREATE INDEX IF NOT EXISTS idx_badges_user ON user_badges(user_id);

-- RLS: enable update policy if not exists
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'user_progress' AND policyname = 'anon_upsert_progress'
  ) THEN
    CREATE POLICY "anon_upsert_progress" ON user_progress FOR INSERT WITH CHECK (true);
  END IF;
END $$;
