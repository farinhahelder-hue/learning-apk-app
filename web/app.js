// === STATE ===
let stars = 0;
let badges = [];
let screen = 'home';
let xp = 0;
let level = 1;
let streak = 1;
let combo = 0;
let muted = false;
let nightMode = localStorage.getItem('emilie_night_mode') === 'true';
let calmMode = localStorage.getItem('emilie_calm_mode') === 'true';
let routineActive = localStorage.getItem('emilie_routine_active') === 'true';
let autoAudio = true;
let dailyPlan = { activites: [], ordre: [], complete: [] };
let questionCount = 0; // for pause etoiles counter
let pauseDuration = 8000;
let pauseActive = false;
let buttonsEnabled = false;
// Timer state
let quizTimer = null;
let quizTimeLeft = 0;
let quizTimeTotal = 30;
// Challenge mode state
let challengeMode = null; // null, 'defi', 'rapide'
let challengeState = {};

// === SUPABASE SERVICE ===
const SUPABASE_URL = 'https://wgkcowgnzysuzclhzxxk.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_FrquHYqydyvPiuhG9mHh_g_6XISLPl6';
const supabase = window.supabase ? window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY) : null;

const supabaseService = {
  _cache: {},
  _cacheTime: 5 * 60 * 1000, // 5 min

  async _fetch(table, options = {}) {
    const cacheKey = table + JSON.stringify(options);
    const cached = this._cache[cacheKey];
    if (cached && Date.now() - cached.time < this._cacheTime) return cached.data;
    try {
      if (!supabase) return null;
      let query = supabase.from(table).select(options.select || '*');
      if (options.eq) for (const [k, v] of Object.entries(options.eq)) query = query.eq(k, v);
      if (options.order) query = query.order(options.order || 'id', { ascending: options.ascending !== false });
      if (options.limit) query = query.limit(options.limit);
      if (options.range) query = query.range(options.range[0], options.range[1]);
      const { data, error } = await query;
      if (error) { console.warn(`Supabase ${table}:`, error); return null; }
      this._cache[cacheKey] = { data, time: Date.now() };
      return data;
    } catch (e) { console.warn(`Supabase fetch ${table}:`, e); return null; }
  },

  // Grammaire
  async getGrammaire(categorie) {
    const opts = { order: 'niveau', ascending: true };
    if (categorie) opts.eq = { categorie };
    return this._fetch('emilie_grammaire', opts);
  },

  // Orthographe
  async getOrthographe(niveau) {
    const opts = { order: 'id' };
    if (niveau) opts.eq = { niveau };
    return this._fetch('emilie_orthographe', opts);
  },

  // Lecture
  async getLectures() {
    return this._fetch('emilie_lecture', { order: 'id' });
  },

  // Dictées
  async getDictees(niveau) {
    const opts = { order: 'nb_mots' };
    if (niveau) opts.eq = { niveau };
    return this._fetch('emilie_dictees', opts);
  },

  // Poésies
  async getPoesies() {
    return this._fetch('emilie_poesies', { order: 'id' });
  },

  // Calcul mental aléatoire
  async getCalculMental(niveau, operation, limit = 12) {
    let all = await this._fetch('emilie_calcul_mental', { eq: { niveau }, limit: 200 });
    if (!all) return [];
    if (operation) all = all.filter(e => e.operation === operation);
    all.sort(() => Math.random() - 0.5);
    return all.slice(0, limit);
  },

  // Problèmes
  async getProblemes(niveau) {
    const opts = { order: 'etapes', ascending: true };
    if (niveau) opts.eq = { niveau };
    return this._fetch('emilie_problemes', opts);
  },

  // Géométrie
  async getGeometrie(niveau) {
    const opts = { order: 'niveau' };
    if (niveau) opts.eq = { niveau };
    return this._fetch('emilie_geometrie', opts);
  },

  // Mesures
  async getMesures(niveau) {
    const opts = { order: 'niveau' };
    if (niveau) opts.eq = { niveau };
    return this._fetch('emilie_mesures', opts);
  },

  // Anglais
  async getAnglais(categorie) {
    const opts = { order: 'mot_fr' };
    if (categorie) opts.eq = { categorie };
    return this._fetch('emilie_anglais', opts);
  },

  // Questionner le monde
  async getQuestionnerMonde(domaine) {
    const opts = { order: 'niveau' };
    if (domaine) opts.eq = { domaine };
    return this._fetch('emilie_questionner_monde', opts);
  },

  // EMC
  async getEmc() {
    return this._fetch('emilie_emc', { order: 'id' });
  },

  // Arts
  async getArts(domaine) {
    const opts = { order: 'niveau' };
    if (domaine) opts.eq = { domaine };
    return this._fetch('emilie_arts', opts);
  },

  // Lecture questions
  async getLectureQuestions(lectureId) {
    return this._fetch('emilie_lecture_questions', {
      eq: { lecture_id: lectureId }, order: 'id'
    });
  },

  clearCache() { this._cache = {}; },

  // === GAMIFICATION ===
  async getUserProgress() {
    if (!supabase) return null;
    const { data, error } = await supabase.from('user_progress')
      .select('*').eq('user_id', 'emilie').single();
    if (error) { console.warn('getUserProgress:', error); return null; }
    return data;
  },

  async upsertProgress(updates) {
    if (!supabase) return null;
    const { data, error } = await supabase.from('user_progress')
      .upsert({ user_id: 'emilie', updated_at: new Date().toISOString(), ...updates },
        { onConflict: 'user_id' }).select().single();
    if (error) { console.warn('upsertProgress:', error); return null; }
    return data;
  },

  async saveSession(session) {
    if (!supabase) return null;
    const { data, error } = await supabase.from('user_sessions')
      .insert({ user_id: 'emilie', ...session }).select().single();
    if (error) { console.warn('saveSession:', error); return null; }
    return data;
  },

  async getRecentSessions(limit = 20) {
    if (!supabase) return [];
    const { data, error } = await supabase.from('user_sessions')
      .select('*').eq('user_id', 'emilie')
      .order('created_at', { ascending: false }).limit(limit);
    if (error) return [];
    return data;
  },

  async getBadges() {
    if (!supabase) return [];
    const { data, error } = await supabase.from('user_badges')
      .select('*').eq('user_id', 'emilie').order('earned_at');
    if (error) return [];
    return data;
  },

  async addBadge(badgeId, badgeName, badgeEmoji) {
    if (!supabase) return null;
    const { data, error } = await supabase.from('user_badges')
      .insert({ user_id: 'emilie', badge_id: badgeId, badge_name: badgeName, badge_emoji: badgeEmoji })
      .select().single();
    if (error) { if (!error.message?.includes('duplicate')) console.warn('addBadge:', error); return null; }
    return data;
  },

  async getWeeklyStats() {
    if (!supabase) return [];
    const weekAgo = new Date(Date.now() - 7 * 86400000).toISOString();
    const { data, error } = await supabase.from('user_sessions')
      .select('*').eq('user_id', 'emilie').gte('created_at', weekAgo)
      .order('created_at', { ascending: true });
    if (error) return [];
    return data;
  }
};

// === BADGES DÉFINITIONS ===
const ALL_BADGES = [
  { id: 'first_steps', name: 'Premiers Pas', emoji: '👣', desc: 'Complète ton premier exercice', check: (p) => p.total_exercises >= 1 },
  { id: 'math_star', name: 'Star des Maths', emoji: '🔢', desc: '50 points en maths', check: (p) => p.math_score >= 50 },
  { id: 'french_star', name: 'Star du Français', emoji: '📖', desc: '50 points en français', check: (p) => p.french_score >= 50 },
  { id: 'science_star', name: 'Star des Sciences', emoji: '🔬', desc: '50 points en sciences', check: (p) => p.science_score >= 50 },
  { id: 'explorer', name: 'Explorateur', emoji: '🌟', desc: 'Visite la section Découvertes', check: (p) => p.discovery_score >= 10 },
  { id: 'perfect10', name: 'Sans Faute !', emoji: '💯', desc: '10 bonnes réponses d\'affilée', check: (p) => p.correct_answers >= 10 },
  { id: 'level5', name: 'Niveau 5', emoji: '🏆', desc: 'Atteins le niveau 5', check: (p) => p.level >= 5 },
  { id: 'streak7', name: '7 Jours de Suite', emoji: '🔥', desc: 'Reviens 7 jours d\'affilée', check: (p) => p.streak_days >= 7 },
  { id: 'century', name: 'Centenaire', emoji: '💪', desc: '100 exercices complétés', check: (p) => p.total_exercises >= 100 },
  { id: 'all_rounder', name: 'Tout-en-un', emoji: '🎯', desc: '50 points dans chaque matière', check: (p) => p.math_score >= 50 && p.french_score >= 50 && p.science_score >= 50 },
  // Streak milestones
  { id: 'streak3', name: 'Régulière', emoji: '🌱', desc: '3 jours de suite', check: (p) => (p.streak_count || p.streak_days || 0) >= 3 },
  { id: 'streak14', name: 'Super Emilie', emoji: '🌟', desc: '14 jours de suite', check: (p) => (p.streak_count || p.streak_days || 0) >= 14 },
  { id: 'streak30', name: 'Légende', emoji: '👑', desc: '30 jours de suite', check: (p) => (p.streak_count || p.streak_days || 0) >= 30 }
];

// === GAMIFICATION ENGINE ===
let xpEngine = {
  progress: null,
  badges: [],
  loaded: false,

  async init() {
    if (!supabase) { this.loaded = true; return; }
    try {
      let p = await supabaseService.getUserProgress();
      if (!p) {
        await supabaseService.upsertProgress({});
        p = await supabaseService.getUserProgress();
      }
      this.progress = p;
      this.badges = await supabaseService.getBadges() || [];
      // Streak check on init
      if (p) {
        const today = new Date().toISOString().split('T')[0];
        if (p.streak_last_date !== today) {
          // Check if streak was yesterday or broken
          const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];
          if (p.streak_last_date && p.streak_last_date !== yesterday) {
            // Streak broken, but only reset if they actually missed a day
            // Don't reset yet - will update on next completeSession
          }
        }
      }
    } catch(e) { console.warn('xpEngine.init:', e); }
    this.loaded = true;
  },

  async addXp(amount, subject) {
    this.ensureProgress();
    this.progress.total_xp = (this.progress.total_xp || 0) + amount;
    this.progress.total_exercises = (this.progress.total_exercises || 0) + 1;
    if (subject === 'math') this.progress.math_score = (this.progress.math_score || 0) + amount;
    else if (subject === 'french') this.progress.french_score = (this.progress.french_score || 0) + amount;
    else if (subject === 'science') this.progress.science_score = (this.progress.science_score || 0) + amount;
    else this.progress.discovery_score = (this.progress.discovery_score || 0) + amount;

    // Level up check (100 XP per level)
    const newLevel = Math.floor(this.progress.total_xp / 100) + 1;
    if (newLevel > this.progress.level) {
      this.progress.level = newLevel;
      playLevelUp();
      showReward('🎉', `Niveau ${newLevel} !`, 'Tu es incroyable, continue comme ça ! ⭐');
      spawnConfetti(30);
      await this.syncToSupabase();
    }

    this.progress.stars = this.progress.level * 5 + Math.floor(this.progress.total_xp / 20);

    // Check badges
    this.checkBadges();

    // Sync to Supabase
    await this.syncToSupabase();

    // Update UI
    updateProgressUI();
  },

  async addCorrectAnswer(subject) {
    this.ensureProgress();
    this.progress.correct_answers = (this.progress.correct_answers || 0) + 1;
    await this.addXp(10, subject);
  },

  async addWrongAnswer() {
    this.progress.correct_answers = 0;
  },

  async completeSession(subject, category, score, total, duration) {
    this.ensureProgress();
    const xpEarned = score * 10;
    const starsEarned = score / total >= 1 ? 3 : score / total >= 0.7 ? 2 : 1;

    // Update streak
    await this.updateStreak();

    await supabaseService.saveSession({
      subject, category, score, total_questions: total,
      xp_earned: xpEarned, stars_earned: starsEarned,
      duration_seconds: duration, completed: true
    });

    if (score === total) {
      playPerfectScore();
    } else if (score / total >= 0.7) {
      playLevelUp();
    }

    return { xpEarned, starsEarned };
  },

  async checkBadges() {
    for (const badge of ALL_BADGES) {
      if (badge.check(this.progress)) {
        const already = this.badges.find(b => b.badge_id === badge.id);
        if (!already) {
          const result = await supabaseService.addBadge(badge.id, badge.name, badge.emoji);
          if (result) {
            this.badges.push(result);
            spawnConfetti(20);
            showReward(badge.emoji, `Badge débloqué : ${badge.name} !`, badge.desc);
            const el = document.getElementById('totalBadges');
            if (el) el.textContent = this.badges.length;
          }
        }
      }
    }
  },

  async syncToSupabase() {
    if (!supabase) return;
    try {
      await supabaseService.upsertProgress({
        total_xp: this.progress.total_xp,
        level: this.progress.level,
        stars: this.progress.stars,
        math_score: this.progress.math_score,
        french_score: this.progress.french_score,
        science_score: this.progress.science_score,
        discovery_score: this.progress.discovery_score,
        total_exercises: this.progress.total_exercises,
        correct_answers: this.progress.correct_answers,
        streak_days: this.progress.streak_days,
        streak_count: this.progress.streak_count,
        streak_last_date: this.progress.streak_last_date,
        last_play_date: new Date().toISOString().split('T')[0]
      });
    } catch(e) {}
  },

  ensureProgress() {
    if (!this.progress) {
      this.progress = {
        total_xp: 0, level: 1, stars: 0, streak_days: 0, streak_count: 0,
        math_score: 0, french_score: 0, science_score: 0, discovery_score: 0,
        total_exercises: 0, correct_answers: 0
      };
    }
  },

  async updateStreak() {
    this.ensureProgress();
    const today = new Date().toISOString().split('T')[0];
    const lastDate = this.progress.streak_last_date || this.progress.last_play_date;
    if (lastDate === today) return;
    const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];
    let newVal;
    if (lastDate === yesterday) {
      newVal = (this.progress.streak_count || this.progress.streak_days || 0) + 1;
    } else if (lastDate && lastDate !== today) {
      newVal = 1;
    } else {
      newVal = Math.max(this.progress.streak_count || this.progress.streak_days || 0, 1);
    }
    this.progress.streak_count = newVal;
    this.progress.streak_days = newVal;
    this.progress.streak_last_date = today;
    this.progress.last_play_date = today;

    const sd = newVal;
    const milestones = [
      { key: 'streak3', days: 3, emoji: '🌱', name: 'Régulière' },
      { key: 'streak7', days: 7, emoji: '🔥', name: '7 Jours de Suite' },
      { key: 'streak14', days: 14, emoji: '🌟', name: 'Super Emilie' },
      { key: 'streak30', days: 30, emoji: '👑', name: 'Légende' }
    ];
    for (const m of milestones) {
      if (sd >= m.days) {
        const already = this.badges.find(b => b.badge_id === m.key);
        if (!already) {
          const result = await supabaseService.addBadge(m.key, m.name, m.emoji);
          if (result) {
            this.badges.push(result);
            spawnConfetti(30);
            showReward(m.emoji, `${m.days} jours de suite ! 🎉`, `Badge "${m.name}" débloqué !`);
          }
        }
      }
    }

    await this.syncToSupabase();
  }
};

function updateProgressUI() {
  const p = xpEngine.progress;
  if (!p) return;
  const elStars = document.getElementById('totalStars');
  const elBadges = document.getElementById('totalBadges');
  const elLevel = document.getElementById('levelDisplay');
  const elXpBar = document.getElementById('xpBar');
  const elXpText = document.getElementById('xpText');

  if (elStars) elStars.textContent = p.stars || 0;
  if (elBadges) elBadges.textContent = xpEngine.badges.length;
  if (elLevel) elLevel.textContent = `Niv.${p.level}`;

  const xpInLevel = p.total_xp % 100;
  const pct = Math.min((xpInLevel / 100) * 100, 100);
  if (elXpBar) elXpBar.style.width = pct + '%';
  if (elXpText) elXpText.textContent = `${xpInLevel} / 100 XP`;
}

// === DÉCOUVERTES STATE ===
const decouverteSubjects = [
  { id: 'grammaire', name: 'Grammaire', emoji: '📚', desc: 'Types de phrases, classes de mots, accords, ponctuation', color: '#8b5cf6' },
  { id: 'orthographe', name: 'Orthographe', emoji: '✏️', desc: 'Sons, accents, homophones, féminin, pluriel', color: '#ec4899' },
  { id: 'lecture', name: 'Lecture', emoji: '📖', desc: 'Textes narratifs, documentaires, poésie', color: '#f59e0b' },
  { id: 'dictees', name: 'Dictées', emoji: '🎙️', desc: 'Dictées progressives avec mots-pièges', color: '#10b981' },
  { id: 'poesies', name: 'Poésies', emoji: '🎵', desc: 'Comptines et poèmes à réciter', color: '#06b6d4' },
  { id: 'calcul_mental', name: 'Calcul Mental', emoji: '🧮', desc: 'Additions, soustractions, tables de multiplication', color: '#3b82f6' },
  { id: 'problemes', name: 'Problèmes', emoji: '🧩', desc: 'Problèmes additifs, multiplicatifs, 2 étapes', color: '#2563eb' },
  { id: 'geometrie', name: 'Géométrie', emoji: '📐', desc: 'Figures, symétrie, angles, périmètre', color: '#7c3aed' },
  { id: 'mesures', name: 'Mesures', emoji: '📏', desc: 'Longueurs, masses, capacités, temps', color: '#0891b2' },
  { id: 'anglais', name: 'Anglais', emoji: '🇬🇧', desc: 'Vocabulaire, phrases, phonétique', color: '#db2777' },
  { id: 'questionner_monde', name: 'Questionner le Monde', emoji: '🌍', desc: 'Histoire, géographie, sciences', color: '#059669' },
  { id: 'emc', name: 'EMC', emoji: '🤝', desc: 'Respect, liberté, égalité, citoyenneté', color: '#d97706' },
  { id: 'arts', name: 'Arts & Musique', emoji: '🎨', desc: 'Arts plastiques, musique, EPS', color: '#ea580c' }
];

// === PWA INSTALL PROMPT ===
let deferredPrompt = null;

// Register Service Worker
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js').then(reg => {
      console.log('SW registered:', reg.scope);
    }).catch(err => {
      console.warn('SW registration failed:', err);
    });
  });
}

// Listen for install prompt
window.addEventListener('beforeinstallprompt', (e) => {
  e.preventDefault();
  deferredPrompt = e;
  const banner = document.getElementById('installBanner');
  if (banner) banner.style.display = 'block';
});

window.addEventListener('appinstalled', () => {
  deferredPrompt = null;
  const banner = document.getElementById('installBanner');
  if (banner) banner.style.display = 'none';
});

function installApp() {
  if (!deferredPrompt) return;
  deferredPrompt.prompt();
  deferredPrompt.userChoice.then((choiceResult) => {
    if (choiceResult.outcome === 'accepted') {
      console.log('App installed');
    }
    deferredPrompt = null;
    document.getElementById('installBanner').style.display = 'none';
  });
}

function closeInstallBanner() {
  document.getElementById('installBanner').style.display = 'none';
}

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
  if (calmMode) volume *= 0.7;
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
  playBeep(260, 0.25, 'sine', 0.12);
  setTimeout(() => playBeep(220, 0.25, 'sine', 0.1), 200);
}

function playLevelUp() {
  [523, 659, 784, 1046].forEach((f, i) =>
    setTimeout(() => playBeep(f, 0.2, 'sine', 0.4), i * 150)
  );
}

function toggleMute() {
  muted = !muted;
  document.getElementById('muteBtn').textContent = muted ? '🔇' : '🔊';
  if (!muted) playBeep(500, 0.1, 'sine');
}

// === SYNTHÈSE VOCALE (SpeechSynthesis) ===
let lastReadText = '';
let slowSpeech = localStorage.getItem('emilie_slow_speech') === 'true';

function readAloud(text, rate = 0.85, pitch = 1.1) {
  if (muted || !getSetting('audio', true) || !window.speechSynthesis) return;
  lastReadText = text;
  window.speechSynthesis.cancel();
  const utterance = new SpeechSynthesisUtterance(text);
  utterance.lang = 'fr-FR';
  utterance.rate = getSetting('speechRate', 0.85) * (slowSpeech ? 0.8 : 1);
  utterance.pitch = pitch;
  // Voice priority: Google français > fr-FR > fr > any
  const voices = window.speechSynthesis.getVoices();
  const frVoice = voices.find(v => v.name && v.name.includes('Google') && v.lang.startsWith('fr'))
    || voices.find(v => v.lang === 'fr-FR')
    || voices.find(v => v.lang.startsWith('fr'));
  if (frVoice) utterance.voice = frVoice;
  if (voices.length === 0) {
    window.speechSynthesis.onvoiceschanged = () => {
      const v = window.speechSynthesis.getVoices().find(v => v.name && v.name.includes('Google') && v.lang.startsWith('fr'))
        || window.speechSynthesis.getVoices().find(v => v.lang.startsWith('fr'));
      if (v) utterance.voice = v;
      window.speechSynthesis.speak(utterance);
    };
    return;
  }
  setTimeout(() => window.speechSynthesis.speak(utterance), 500);
}

function replayLastRead() { if (lastReadText) readAloud(lastReadText); }

function sayMessage(text, rate = 0.9) { readAloud(text, rate); }

function sayBravo() {
  const msgs = [
    'Bravo Emilie, tu as réussi !',
    'Excellent travail, continue comme ça !',
    'Super, tu es la meilleure !',
    'Félicitations, quel talent !',
    'Magnifique, tu progresses chaque jour !'
  ];
  readAloud(msgs[Math.floor(Math.random() * msgs.length)], 0.9);
}

function sayTryAgain() {
  const msgs = [
    'Essaie encore, tu vas y arriver !',
    'Pas grave, recommence, je crois en toi !',
    'Tu peux le faire, un peu de concentration !',
    'Allez, un dernier effort !'
  ];
  readAloud(msgs[Math.floor(Math.random() * msgs.length)], 0.95);
}

function replayBtnHTML() {
  return `<button class="replay-btn" onclick="replayLastRead()" title="Réécouter la consigne">🔊</button>`;
}

function showReplayBtn(show = true) {
  const btn = document.getElementById('replayBtn');
  if (btn) btn.style.display = show ? 'flex' : 'none';
}

// === APPLAUDISSEMENT GÉNÉRÉ (bruit blanc filtré) ===
function playApplause(duration = 2) {
  if (muted) return;
  try {
    const ctx = getAudio();
    const bufferSize = ctx.sampleRate * duration;
    const buffer = ctx.createBuffer(1, bufferSize, ctx.sampleRate);
    const data = buffer.getChannelData(0);
    for (let i = 0; i < bufferSize; i++) {
      // Bruit blanc avec enveloppe
      const env = Math.max(0, 1 - Math.pow(i / bufferSize, 2));
      data[i] = (Math.random() * 2 - 1) * env * 0.4;
    }
    const source = ctx.createBufferSource();
    source.buffer = buffer;
    
    // Filtre passe-bande pour simuler des applaudissements
    const filter = ctx.createBiquadFilter();
    filter.type = 'bandpass';
    filter.frequency.value = 2000;
    filter.Q.value = 0.5;
    
    const gain = ctx.createGain();
    gain.gain.setValueAtTime(0.3, ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + duration);
    
    source.connect(filter);
    filter.connect(gain);
    gain.connect(ctx.destination);
    source.start(ctx.currentTime);
    source.stop(ctx.currentTime + duration);
  } catch(e) {}
}

function playPerfectScore() {
  playLevelUp();
  setTimeout(() => playApplause(1.5), 600);
  setTimeout(() => sayBravo(), 800);
}

// === PAUSE ÉTOILES (toutes les 5 questions) ===
function triggerPauseEtoiles() {
  if (pauseActive || calmMode || !getSetting('pauseEtoiles', true)) return;
  pauseActive = true;
  const msgs = [
    'Tu fais du super travail, Emilie ! 🌟',
    'Prends une grande inspiration... 🌬️',
    'Tes neurones travaillent bien ! 🧠✨',
    'Une petite pause bien méritée ! ⭐',
    'Respire et continue comme ça ! 🦋',
    'Tu progresses chaque jour, bravo ! 🌈'
  ];
  const msg = msgs[Math.floor(Math.random() * msgs.length)];
  const overlay = document.getElementById('pauseEtoilesOverlay');
  if (!overlay) return;
  overlay.classList.add('show');
  const starsHTML = Array.from({length: 15}, (_, i) =>
    `<div class="pause-star" style="left:${Math.random()*90}%;top:${Math.random()*90}%;animation-delay:${Math.random()*2}s;font-size:${1.5+Math.random()*2}rem">⭐</div>`
  ).join('');
  overlay.innerHTML = `
    <div class="pause-content">
      <div class="pause-stars">${starsHTML}</div>
      <p class="pause-message">${msg}</p>
      <div class="pause-countdown" id="pauseCountdown">8</div>
      <button class="pause-skip-btn" onclick="skipPause()">Je suis prête ! 💪</button>
    </div>
  `;
  let count = 8;
  const interval = setInterval(() => {
    count--;
    const el = document.getElementById('pauseCountdown');
    if (el) el.textContent = count;
    if (count <= 0) { clearInterval(interval); endPause(); }
  }, 1000);
  setTimeout(() => { clearInterval(interval); endPause(); }, pauseDuration);
}

function skipPause() { endPause(); }

function endPause() {
  pauseActive = false;
  const overlay = document.getElementById('pauseEtoilesOverlay');
  if (overlay) overlay.classList.remove('show');
}

// === DÉLAI ANTI-CLIC IMPULSIF ===
function delayEnableButtons(selector = '.choice-btn', delay = 1500) {
  if (!getSetting('antiClick', true)) delay = 0;
  buttonsEnabled = false;
  document.querySelectorAll(selector).forEach(b => {
    b.disabled = true;
    b.classList.add('btn-wait');
  });
  setTimeout(() => {
    buttonsEnabled = true;
    document.querySelectorAll(selector).forEach(b => {
      b.disabled = false;
      b.classList.remove('btn-wait');
      b.classList.add('btn-ready');
    });
    if (delay > 0) playBeep(600, 0.08, 'sine', 0.15);
  }, delay);
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
  'Presque ! Tu veux réessayer ? 💪','Ce n\'est pas grave, essaie encore ! 🌈',
  'Même les championnes font des erreurs ! Courage Emilie ! 🦋',
  'Pas grave, recommence, je crois en toi ! 🌟','Tu progresses déjà, continue ! 💛'
];

function showFeedback(correct, customMsg, customEmoji) {
  const overlay = document.getElementById('feedbackOverlay');
  overlay.className = 'feedback-overlay show ' + (correct ? 'correct-fb' : 'wrong-fb-soft');
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
  spawnRewardConfetti();
}

function closeReward() {
  document.getElementById('rewardModal').classList.remove('show');
}

function spawnRewardConfetti() {
  const container = document.getElementById('confettiBurst');
  if (!container) return;
  container.innerHTML = '';
  const colors = ['#FF6B9D', '#FFD700', '#4ECDC4', '#C3A6FF', '#FFA552', '#95E1D3'];
  for (let i = 0; i < 30; i++) {
    const piece = document.createElement('div');
    piece.className = 'confetti-piece';
    piece.style.left = (Math.random() * 90) + '%';
    piece.style.background = colors[Math.floor(Math.random() * colors.length)];
    piece.style.animationDuration = (1 + Math.random() * 0.8) + 's';
    piece.style.animationDelay = (Math.random() * 0.3) + 's';
    piece.style.borderRadius = Math.random() > 0.5 ? '50%' : '2px';
    container.appendChild(piece);
  }
  setTimeout(() => container.innerHTML = '', 2500);
}

function showVictory(emoji, title, score, xp) {
  document.getElementById('victoryEmoji').textContent = emoji || '🏆';
  document.getElementById('victoryTitle').textContent = title || 'Bravo Emilie !';
  document.getElementById('victoryScore').textContent = score || '10/10 bonnes réponses';
  document.getElementById('victoryXp').textContent = xp || '+100 XP gagnés';
  document.getElementById('victoryOverlay').classList.add('show');
  spawnConfetti(30);
  playPerfectScore();
}

function closeVictory() {
  document.getElementById('victoryOverlay').classList.remove('show');
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
  delayEnableButtons('#mathExerciseArea .choice-btn', 1500);
  // Lire la question
  if (ex) readAloud(ex.q.replace(/<[^>]*>/g,''), 0.85);
}

// Variable globale pour l'exercice actuel
let currentExercise = null;

// Fonction pour vérifier la réponse en mode math (mode standalone)
function handleMathAnswer(btn, chosen, answer) {
  if (sel !== null || !buttonsEnabled) return;
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
    xpEngine.addCorrectAnswer('math');
    if (combo >= 3) xpEngine.addXp(5, 'math');
  } else {
    updateCombo(false);
    playWrongSound();
    showFeedback(false);
    xpEngine.addWrongAnswer();
  }
  
  questionCount++;
  setTimeout(() => {
    loadMathExercice(currentMathCategory);
    if (questionCount > 0 && questionCount % 5 === 0) triggerPauseEtoiles();
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

// === DÉCOUVERTES SCREEN ===
let currentDecouverteSubject = null;
let decouverteData = [];

function decouvertesHTML() {
  return `<div class="module-header screen-transition">
    <button class="back-btn" data-action="home">🏠</button>
    <h2 class="module-title" style="color: #9333ea;">🌟 Découvertes CE1</h2>
    <span style="font-size: 1.2rem;">🐿️🪼🦭</span>
  </div>
  
  <div class="card" style="text-align: center; background: linear-gradient(135deg, #fef3c7, #fde68a);">
    <p style="font-size: 0.95rem; color: #92400e;">Choisis une matière pour explorer tout le programme CE1 ! 📚</p>
  </div>
  
  <div class="mini-games-grid screen-transition">
    ${decouverteSubjects.map(s => `
      <button class="subject-btn" onclick="loadDecouverteSubject('${s.id}')" style="background: ${s.color}22; border: 2px solid ${s.color};">
        <span class="emoji" style="font-size: 2rem;">${s.emoji}</span>
        <span style="font-size: 0.85rem; font-weight: 800; color: #1f2937;">${s.name}</span>
        <span style="font-size: 0.7rem; color: #6b7280; margin-top: 2px;">${s.desc}</span>
      </button>
    `).join('')}
  </div>`;
}

async function loadDecouverteSubject(subjectId) {
  const subject = decouverteSubjects.find(s => s.id === subjectId);
  if (!subject) return;
  currentDecouverteSubject = subject;
  
  try {
    let data = null;
    switch (subjectId) {
      case 'grammaire': data = await supabaseService.getGrammaire(); break;
      case 'orthographe': data = await supabaseService.getOrthographe(); break;
      case 'lecture': data = await supabaseService.getLectures(); break;
      case 'dictees': data = await supabaseService.getDictees(); break;
      case 'poesies': data = await supabaseService.getPoesies(); break;
      case 'calcul_mental': data = await supabaseService.getCalculMental(1); break;
      case 'problemes': data = await supabaseService.getProblemes(); break;
      case 'geometrie': data = await supabaseService.getGeometrie(); break;
      case 'mesures': data = await supabaseService.getMesures(); break;
      case 'anglais': data = await supabaseService.getAnglais(); break;
      case 'questionner_monde': data = await supabaseService.getQuestionnerMonde(); break;
      case 'emc': data = await supabaseService.getEmc(); break;
      case 'arts': data = await supabaseService.getArts(); break;
    }
    decouverteData = data || [];
  } catch (e) {
    decouverteData = [];
  }
  
  screen = 'decouverteDetail';
  render();
}

function decouverteDetailHTML() {
  const s = currentDecouverteSubject;
  if (!s) return decouvertesHTML();
  
  const items = decouverteData || [];
  
  return `<div class="module-header screen-transition">
    <button class="back-btn" data-action="decouvertes">←</button>
    <h2 class="module-title" style="color: ${s.color};">${s.emoji} ${s.name}</h2>
    <span class="badge-count" style="background: ${s.color}22; color: ${s.color};">${items.length} fiches</span>
  </div>
  
  ${items.length === 0 ? `<div class="card" style="text-align: center; padding: 40px 20px;">
    <div style="font-size: 3rem; margin-bottom: 15px;">🔍</div>
    <p style="color: #6b7280;">Chargement des données...</p>
    <p style="font-size: 0.85rem; color: #9ca3af; margin-top: 8px;">Connecte-toi à Supabase pour voir tout le programme CE1</p>
  </div>` : ''}
  
  <div class="lessons-container screen-transition">
    ${s.id === 'grammaire' ? grammaireHTML(items) : ''}
    ${s.id === 'orthographe' ? orthographeHTML(items) : ''}
    ${s.id === 'lecture' ? lectureHTML(items) : ''}
    ${s.id === 'dictees' ? dicteesHTML(items) : ''}
    ${s.id === 'poesies' ? poesiesHTML(items) : ''}
    ${s.id === 'calcul_mental' ? calculMentalHTML(items) : ''}
    ${s.id === 'problemes' ? problemesHTML(items) : ''}
    ${s.id === 'geometrie' ? geometrieHTML(items) : ''}
    ${s.id === 'mesures' ? mesuresHTML(items) : ''}
    ${s.id === 'anglais' ? anglaisHTML(items) : ''}
    ${s.id === 'questionner_monde' ? questionnerMondeHTML(items) : ''}
    ${s.id === 'emc' ? emcHTML(items) : ''}
    ${s.id === 'arts' ? artsHTML(items) : ''}
  </div>`;
}

function grammaireHTML(items) {
  const cats = [...new Set(items.map(i => i.categorie))];
  return cats.map(cat => `
    <div class="skill-section">
      <div class="skill-header" onclick="toggleSkill(this)">
        <span class="skill-icon">📚</span>
        <span class="skill-name">${cat.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase())}</span>
        <span class="skill-arrow">▼</span>
      </div>
      <div class="skill-lessons" style="display:none;">
        ${items.filter(i => i.categorie === cat).map(i => `
          <div class="lesson-card" onclick="showDecouverteItem('${i.notion}', '${i.explication.replace(/'/g, "\\'")}<br><br><em>Exemple : ${i.exemple || ''}</em>')">
            <div class="lesson-info">
              <h3 class="lesson-title">${i.notion}</h3>
              <p style="font-size: 0.85rem; color: #6b7280;">${i.explication.substring(0, 80)}...</p>
            </div>
            <div class="lesson-arrow">→</div>
          </div>
        `).join('')}
      </div>
    </div>
  `).join('');
}

function orthographeHTML(items) {
  return items.map(i => `
    <div class="lesson-card" onclick="showDecouverteItem('${i.regle.replace(/'/g, "\\'")}', '${i.explication.replace(/'/g, "\\'")}<br><br><strong>Exemples :</strong> ${i.mots_exemples || ''}')">
      <div class="lesson-icon">✏️</div>
      <div class="lesson-info">
        <h3 class="lesson-title">${i.regle}</h3>
        <p style="font-size: 0.85rem; color: #6b7280;">${i.explication.substring(0, 80)}...</p>
      </div>
      <div class="lesson-arrow">→</div>
    </div>
  `).join('');
}

function lectureHTML(items) {
  return items.map(i => `
    <div class="lesson-card" onclick="showDecouverteItem('${i.titre.replace(/'/g, "\\'")}', '<div style=\"white-space:pre-wrap;text-align:left;background:#f9fafb;padding:12px;border-radius:12px;\">${i.texte.replace(/'/g, "\\'")}</div><br><em>Type : ${i.type}</em>')">
      <div class="lesson-icon">📖</div>
      <div class="lesson-info">
        <h3 class="lesson-title">${i.titre}</h3>
        <p style="font-size: 0.85rem; color: #6b7280;">${i.texte.substring(0, 80)}...</p>
      </div>
      <div class="lesson-arrow">→</div>
    </div>
  `).join('');
}

function dicteesHTML(items) {
  return items.map(i => `
    <div class="lesson-card" onclick="startInteractiveDictee(${i.id}, '${i.titre.replace(/'/g, "\\'")}', '${i.texte.replace(/'/g, "\\'")}')">
      <div class="lesson-icon">🎙️</div>
      <div class="lesson-info">
        <h3 class="lesson-title">${i.titre}</h3>
        <p style="font-size: 0.85rem; color: #6b7280;">${i.nb_mots} mots • Niveau ${i.niveau}</p>
      </div>
      <div class="lesson-arrow">→</div>
    </div>
  `).join('');
}

// Interactive dictation state
let dictationState = null;

function startInteractiveDictee(id, title, text) {
  const words = text.split(/\s+/).filter(w => w.length > 0);
  dictationState = { id, title, text, words, index: 0, userWords: [], correct: 0 };
  showDicteeScreen();
}

function showDicteeScreen() {
  const d = dictationState;
  if (!d) return;
  const soFar = d.userWords.join(' ');
  const remaining = d.words.slice(d.index).join(' ');
  const progress = d.words.length > 0 ? Math.round((d.index / d.words.length) * 100) : 0;
  
  // Build feedback showing correct/incorrect words
  const feedbackHtml = d.userWords.map((w, i) => {
    const isCorrect = w.toLowerCase() === (d.words[i] || '').toLowerCase();
    return `<span style="color:${isCorrect ? '#16a34a' : '#dc2626'};font-weight:bold;">${w}</span>`;
  }).join(' ');

  document.getElementById('decouverteDetailOverlay').classList.add('show');
  document.getElementById('decouverteDetailBox').innerHTML = `
    <div style="font-size:2rem;margin-bottom:8px;">🎙️</div>
    <div style="font-size:1.2rem;font-weight:bold;color:#9333ea;margin-bottom:8px;">${d.title}</div>
    <div style="margin-bottom:12px;">
      <div style="display:flex;justify-content:space-between;font-size:0.8rem;color:#666;">
        <span>Mot ${d.index + 1}/${d.words.length}</span>
        <span>${d.correct} ✓</span>
      </div>
      <div class="progress-bar" style="margin-bottom:8px;"><div class="progress-fill" style="width:${progress}%;background:var(--rose);"></div></div>
    </div>
    <div style="background:#f9fafb;padding:12px;border-radius:12px;margin-bottom:12px;min-height:40px;line-height:1.8;">
      ${d.userWords.length > 0 ? feedbackHtml : '<span style="color:#999;">Écris les mots que tu entends...</span>'}
      ${remaining ? `<span style="color:#ccc;"> ${remaining}</span>` : ''}
    </div>
    ${d.index < d.words.length ? `
    <div style="display:flex;gap:8px;margin-bottom:12px;">
      <input type="text" id="dicteeInput" style="flex:1;padding:10px;border:2px solid #e5e7eb;border-radius:12px;font-size:1rem;font-family:inherit;" placeholder="Tape le mot..." autocomplete="off" onkeydown="if(event.key==='Enter')checkDicteeWord()">
      <button class="btn-reward" style="padding:10px 16px;font-size:0.9rem;" onclick="readDicteeWord()" title="Écouter">🔊</button>
    </div>
    <button class="btn-reward" onclick="checkDicteeWord()">✓ Vérifier</button>
    ` : `
    <div style="background:#f0fdf4;padding:12px;border-radius:12px;margin-bottom:12px;">
      <strong style="color:#16a34a;">🎉 Dictée terminée !</strong><br>
      <span style="color:#666;">${d.correct}/${d.words.length} mots corrects</span>
    </div>
    <button class="btn-reward" style="background:var(--violet);" onclick="closeDecouverteDetail();dictationState=null;">Fermer</button>
    `}
    ${d.index > 0 && d.index < d.words.length ? `<button class="parental-link" onclick="skipDicteeWord()">Passer ce mot →</button>` : ''}
  `;
  
  if (d.index < d.words.length) {
    setTimeout(() => {
      const input = document.getElementById('dicteeInput');
      if (input) input.focus();
    }, 300);
  }
}

function readDicteeWord() {
  const d = dictationState;
  if (!d || d.index >= d.words.length) return;
  const word = d.words[d.index];
  // Read the word twice
  sayMessage(word, 0.7);
  setTimeout(() => sayMessage(word, 0.7), 1200);
}

function checkDicteeWord() {
  const d = dictationState;
  if (!d || d.index >= d.words.length) return;
  const input = document.getElementById('dicteeInput');
  const word = (input ? input.value : '').trim();
  if (!word) return;
  
  const expected = d.words[d.index];
  d.userWords.push(word);
  if (word.toLowerCase() === expected.toLowerCase()) {
    d.correct++;
    playCorrectSound();
  } else {
    playWrongSound();
  }
  d.index++;
  if (input) input.value = '';
  showDicteeScreen();
}

function skipDicteeWord() {
  const d = dictationState;
  if (!d || d.index >= d.words.length) return;
  d.userWords.push('');
  d.index++;
  showDicteeScreen();
}

function poesiesHTML(items) {
  return items.map(i => `
    <div class="lesson-card" onclick="showDecouverteItem('${i.titre.replace(/'/g, "\\'")}', '<div style=\"white-space:pre-wrap;text-align:left;font-style:italic;background:#fef9c3;padding:12px;border-radius:12px;\">${i.texte.replace(/'/g, "\\'")}</div>${i.auteur ? '<br><em>— ' + i.auteur + '</em>' : ''}')">
      <div class="lesson-icon">🎵</div>
      <div class="lesson-info">
        <h3 class="lesson-title">${i.titre}</h3>
        ${i.auteur ? `<p style="font-size: 0.85rem; color: #6b7280;">Par ${i.auteur}</p>` : ''}
      </div>
      <div class="lesson-arrow">→</div>
    </div>
  `).join('');
}

function calculMentalHTML(items) {
  const nivs = [...new Set(items.map(i => i.niveau))].sort();
  return nivs.map(niv => `
    <div class="skill-section">
      <div class="skill-header" onclick="toggleSkill(this)">
        <span class="skill-icon">🧮</span>
        <span class="skill-name">Niveau ${niv}</span>
        <span class="skill-arrow">▼</span>
      </div>
      <div class="skill-lessons" style="display:none;">
        <div class="card" style="padding: 15px;">
          <div class="choices" id="calcMentalQuiz${niv}"></div>
          <button class="homework-btn math-btn" onclick="startCalcMentalQuiz(${niv})" style="margin-top:12px;">🎯 Démarrer le quiz</button>
          <div id="calcMentalResult${niv}" style="margin-top:12px;text-align:center;font-weight:bold;"></div>
        </div>
      </div>
    </div>
  `).join('');
}

let calcMentalState = { niveau: 1, questions: [], index: 0, score: 0, answers: {} };

function startCalcMentalQuiz(niveau) {
  const qs = (decouverteData || []).filter(i => i.niveau === niveau);
  if (qs.length === 0) return;
  qs.sort(() => Math.random() - 0.5);
  calcMentalState = { niveau, questions: qs.slice(0, 12), index: 0, score: 0, answers: {} };
  showCalcMentalQuestion(niveau);
}

function showCalcMentalQuestion(niveau) {
  const { questions, index, score } = calcMentalState;
  if (index >= questions.length) {
    document.getElementById(`calcMentalResult${niveau}`).innerHTML =
      `🎉 Score : ${score}/${questions.length} ⭐`;
    spawnConfetti(10);
    return;
  }
  const q = questions[index];
  const ops = { '+': '+', '-': '-', '×': '×' };
  const choices = generateChoices(q.reponse);
  const container = document.getElementById(`calcMentalQuiz${niveau}`);
  if (!container) return;
  container.innerHTML = `
    <div class="question-card" style="padding:20px;">
      <p style="font-size:1.5rem;">${q.operande1} ${ops[q.operation] || q.operation} ${q.operande2} = ?</p>
      <p style="font-size:0.85rem;color:#9ca3af;margin-top:8px;">Question ${index+1}/${questions.length}</p>
    </div>
    <div class="choices grid2">
      ${choices.map(c => `<button class="choice-btn" onclick="checkCalcMentalAnswer(${niveau}, this, ${c}, ${q.reponse})">${c}</button>`).join('')}
    </div>
  `;
}

function generateChoices(correct) {
  const choices = new Set([correct]);
  while (choices.size < 4) {
    const offset = Math.floor(Math.random() * 10) - 5;
    if (offset !== 0) choices.add(correct + offset);
  }
  return [...choices].sort(() => Math.random() - 0.5);
}

function checkCalcMentalAnswer(niveau, btn, chosen, answer) {
  // Prevent multiple clicks
  const container = document.getElementById(`calcMentalQuiz${niveau}`);
  if (!container || container.querySelectorAll('.choice-btn[disabled]').length > 0) return;
  
  const correct = chosen === answer;
  btn.classList.add(correct ? 'correct' : 'wrong');
  container.querySelectorAll('.choice-btn').forEach(b => { b.disabled = true; if (Number(b.textContent) === answer) b.classList.add('correct'); });
  
  if (correct) {
    calcMentalState.score++;
    addStars(1);
    playCorrectSound();
    updateCombo(true);
    xpEngine.addCorrectAnswer('math');
    if (combo >= 3) xpEngine.addXp(5, 'math');
  } else {
    playWrongSound();
    updateCombo(false);
    xpEngine.addWrongAnswer();
  }
  
  questionCount++;
  setTimeout(() => {
    calcMentalState.index++;
    showCalcMentalQuestion(niveau);
    if (questionCount > 0 && questionCount % 5 === 0) triggerPauseEtoiles();
  }, 800);
}

// =====================================================
// MINI-JEUX MATHS VISUELS
// =====================================================

// --- ÉTAT PARTAGÉ ---
let visualMath = {
  mode: null, // 'boulangerie','ferme','gateaux','chenille'
  questions: [],
  index: 0,
  score: 0,
  total: 0,
  completed: false,
  level: 1
};

function startVisualMath(mode) {
  visualMath = { mode, questions: [], index: 0, score: 0, total: 0, completed: false, level: 1 };
  let ops;
  if (mode === 'boulangerie') {
    ops = window._mathOps ? window._mathOps.filter(o => o.type_operation === 'addition') : [];
    if (ops.length === 0) {
      // Fallback questions
      for (let i = 1; i <= 5; i++) for (let j = 1; j <= 5; j++) { if (i + j <= 10) ops.push({ operande1: i, operande2: j, resultat: i + j, emoji_theme: '🥐' }); }
    }
  } else if (mode === 'ferme') {
    ops = window._mathOps ? window._mathOps.filter(o => o.type_operation === 'soustraction') : [];
    if (ops.length === 0) {
      for (let i = 2; i <= 8; i++) for (let j = 1; j < i; j++) ops.push({ operande1: i, operande2: j, resultat: i - j, emoji_theme: '🐔' });
    }
  } else if (mode === 'gateaux') {
    ops = window._mathOps ? window._mathOps.filter(o => o.type_operation === 'multiplication') : [];
    if (ops.length === 0) {
      [2,3,4,5,10].forEach(t => { for (let m = 1; m <= 5; m++) ops.push({ operande1: t, operande2: m, resultat: t * m, emoji_theme: '🎂' }); });
    }
  }
  ops = shuffle(ops);
  visualMath.questions = ops.slice(0, 12);
  visualMath.total = visualMath.questions.length;
  screen = 'visualMath';
  module = 'math';
  render();
}

function visualMathHTML() {
  const vm = visualMath;
  if (vm.completed) return visualMathResultHTML();
  
  const q = vm.questions[vm.index];
  if (!q) return visualMathResultHTML();
  
  const emoji = q.emoji_theme || '🥐';
  const opName = vm.mode === 'boulangerie' ? '➕' : vm.mode === 'ferme' ? '➖' : '✖️';
  const title = vm.mode === 'boulangerie' ? '🥐 Boulangerie d\'Émilie' : vm.mode === 'ferme' ? '🐔 La Ferme d\'Émilie' : '🎂 Les Gâteaux';
  const opSym = vm.mode === 'boulangerie' ? '+' : vm.mode === 'ferme' ? '-' : '×';
  
  // Generate visual objects
  let objects = '';
  const a = q.operande1, b = q.operande2;
  
  if (vm.mode === 'gateaux') {
    // Grid layout for multiplication
    objects = '<div class="gateaux-grille">';
    for (let r = 0; r < a; r++) {
      objects += '<div class="gateaux-rangee">';
      for (let c = 0; c < b; c++) objects += `<span class="gateau-item" style="animation-delay:${(r * b + c) * 0.05}s">${emoji}</span>`;
      objects += '</div>';
    }
    objects += '</div>';
    objects += `<div class="gateaux-legende">${a} rangées de ${b} ${emoji} = ${a} × ${b}</div>`;
  } else {
    // Line layout with animations
    const animType = vm.mode === 'ferme' ? 'exit' : 'slide';
    // Show first group
    for (let i = 0; i < a; i++) objects += `<span class="visuel-objet ${animType}" style="animation-delay:${i * 0.08}s">${emoji}</span>`;
    if (vm.mode === 'boulangerie') {
      objects += `<span class="visuel-plus">${opSym}</span>`;
      for (let i = 0; i < b; i++) objects += `<span class="visuel-objet slide" style="animation-delay:${(a + i) * 0.08}s">${emoji}</span>`;
    }
  }
  
  const total = a + b;
  const choices = generateMathChoices(total, vm.mode === 'boulangerie' ? a + b : vm.mode === 'ferme' ? a - b : a * b);
  const correct = vm.mode === 'boulangerie' ? a + b : vm.mode === 'ferme' ? a - b : a * b;
  
  return `<div class="module-header screen-transition">
    <button class="back-btn" onclick="screen='home';render()">⬅️</button>
    <h2 class="module-title math">${title}</h2>
    <span class="badge-count badge-math">${vm.score}/${vm.total}</span>
  </div>
  <div class="progress-bar"><div class="progress-fill progress-math" style="width:${(vm.index / vm.total) * 100}%"></div></div>
  <div class="card visuel-math-card">
    <p class="visuel-consigne">${vm.mode === 'boulangerie' ? `${a} ${emoji} + ${b} ${emoji} = ?` : vm.mode === 'ferme' ? `${a} ${emoji} − ${b} ${emoji} = ?` : `${a} × ${b} = ?`}</p>
    <div class="visuel-objects">${objects}</div>
    <div class="choices grid2">
      ${choices.map(c => `<button class="choice-btn choice-big" onclick="handleVisualMathAnswer(this, ${c}, ${correct})">${c}</button>`).join('')}
    </div>
    <div class="mascot-tip"><em>${vm.mode === 'boulangerie' ? '🥐 Compte les croissants tous ensemble !' : vm.mode === 'ferme' ? '🐔 Regarde les animaux qui restent !' : '🎂 Compte les gâteaux rangée par rangée !'}</em></div>
  </div>`;
}

function generateMathChoices(correct, maxVal) {
  const choices = new Set([correct]);
  while (choices.size < 4) {
    const offset = Math.floor(Math.random() * 5) - 2;
    const v = correct + offset;
    if (v >= 0 && v !== correct && v <= maxVal + 3) choices.add(v);
  }
  return [...choices].sort(() => Math.random() - 0.5);
}

function handleVisualMathAnswer(btn, chosen, correct) {
  if (visualMath.completed) return;
  const ok = chosen === correct;
  btn.classList.add(ok ? 'correct' : 'wrong');
  document.querySelectorAll('.choice-btn').forEach(b => b.disabled = true);
  document.querySelectorAll('.choice-btn').forEach(b => { if (Number(b.textContent) === correct) b.classList.add('correct'); });
  
  if (ok) {
    visualMath.score++;
    playCorrectSound();
    xpEngine.addCorrectAnswer('math');
  } else {
    playWrongSound();
    xpEngine.addWrongAnswer();
    // Show the correct answer visually
    setTimeout(() => {
      const feedback = document.createElement('div');
      feedback.className = 'visuel-feedback';
      feedback.textContent = `La réponse était ${correct} !`;
      btn.parentElement.parentElement.appendChild(feedback);
    }, 300);
  }
  
  questionCount++;
  setTimeout(() => {
    visualMath.index++;
    if (visualMath.index >= visualMath.total) {
      visualMath.completed = true;
      xpEngine.completeSession('math', visualMath.mode, visualMath.score, visualMath.total, 15);
    }
    render();
    if (questionCount > 0 && questionCount % 5 === 0) triggerPauseEtoiles();
  }, ok ? 800 : 1500);
}

function visualMathResultHTML() {
  const vm = visualMath;
  const pct = vm.score / vm.total;
  const emoji = pct >= 1 ? '🏆' : pct >= 0.7 ? '🌟' : '💪';
  const msg = pct >= 1 ? 'Parfait ! Quelle championne !' : pct >= 0.7 ? 'Bravo, continue comme ça !' : 'Bien essayé !';
  return `<div class="card result-screen screen-transition">
    <span class="result-emoji">${emoji}</span>
    <div style="font-size:2rem;margin-bottom:10px;">🐿️🪼🦭</div>
    <h2 class="result-title">${msg}</h2>
    <p class="result-score">${vm.score}/${vm.total} bonnes réponses</p>
    <p class="result-stars">+${vm.score * 2} ⭐ étoiles</p>
    <button class="primary-btn btn-blue" onclick="screen='home';render()">🏠 Retour</button>
  </div>`;
}

// --- CHENILLE DES TABLES ---
let chenilleState = null;

function startChenille(table) {
  const seq = [];
  for (let i = 1; i <= 10; i++) seq.push(table * i);
  // Hide 3 random values
  const hidden = shuffle([1,2,3,4,5,6,7,8,9,10]).slice(0, 3);
  chenilleState = { table, seq, hidden, index: 0, score: 0, total: hidden.length };
  screen = 'chenille';
  module = 'math';
  render();
}

function chenilleHTML() {
  const c = chenilleState;
  if (!c) return '';
  const currentPos = c.hidden[c.index];
  const currentVal = c.seq[currentPos - 1];
  
  const segments = c.seq.map((v, i) => {
    const pos = i + 1;
    const isHidden = c.hidden.includes(pos) && c.hidden.indexOf(pos) >= c.index;
    const isDone = c.hidden.includes(pos) && c.hidden.indexOf(pos) < c.index;
    const isCurrent = pos === currentPos;
    return `<div class="chenille-segment ${isCurrent ? 'current' : ''} ${isDone ? 'done' : ''}">
      ${isDone ? v : isCurrent ? '?' : v}
    </div>`;
  }).join('');
  
  const choices = generateMathChoices(currentVal, c.seq[c.seq.length - 1] + 10);
  
  return `<div class="module-header screen-transition">
    <button class="back-btn" onclick="screen='home';render()">⬅️</button>
    <h2 class="module-title math">🐛 Table des ${c.table}</h2>
    <span class="badge-count badge-math">${c.score}/${c.total}</span>
  </div>
  <div class="card" style="text-align:center;">
    <p class="visuel-consigne">Trouve le nombre qui manque !</p>
    <div class="chenille-container">
      <div class="chenille-tete">🐛</div>
      ${segments}
      <div class="chenille-queue">🦋</div>
    </div>
    <div class="choices grid2" style="margin-top:20px;">
      ${choices.map(ch => `<button class="choice-btn choice-big" onclick="handleChenilleAnswer(this, ${ch}, ${currentVal})">${ch}</button>`).join('')}
    </div>
  </div>`;
}

function handleChenilleAnswer(btn, chosen, correct) {
  if (!chenilleState) return;
  const ok = chosen === correct;
  btn.classList.add(ok ? 'correct' : 'wrong');
  document.querySelectorAll('.choice-btn').forEach(b => b.disabled = true);
  if (ok) {
    chenilleState.score++;
    playCorrectSound();
    xpEngine.addCorrectAnswer('math');
  } else {
    playWrongSound();
    xpEngine.addWrongAnswer();
  }
  questionCount++;
  setTimeout(() => {
    chenilleState.index++;
    if (chenilleState.index >= chenilleState.total) {
      const finScore = chenilleState.score;
      const finTotal = chenilleState.total;
      xpEngine.completeSession('math', 'chenille', finScore, finTotal, 10);
      chenilleState = null;
      screen = 'home';
      showVictory('🐛', 'Chenille complétée !', `${finScore}/${finTotal}`);
    }
    render();
    if (questionCount > 0 && questionCount % 5 === 0) triggerPauseEtoiles();
  }, ok ? 600 : 1000);
}

function problemesHTML(items) {
  return items.map(i => `
    <div class="lesson-card" onclick="showDecouverteItem('Problème n°${i.id}', '<div style=\"text-align:left;\"><p style=\"font-size:1.1rem;background:#f0fdf4;padding:12px;border-radius:12px;\">${i.enonce}</p><br><strong>Opération :</strong> ${i.operation}<br><strong>Réponse :</strong> ${i.reponse}<br><strong>Niveau :</strong> ${i.niveau}</div>')">
      <div class="lesson-icon">🧩</div>
      <div class="lesson-info">
        <h3 class="lesson-title">Problème n°${i.id}</h3>
        <p style="font-size: 0.85rem; color: #6b7280;">${i.enonce.substring(0, 80)}...</p>
      </div>
      <div class="lesson-arrow">→</div>
    </div>
  `).join('');
}

function geometrieHTML(items) {
  return items.map(i => `
    <div class="lesson-card" onclick="showDecouverteItem('${i.notion.replace(/'/g, "\\'")}', '<div style=\"text-align:left;\"><p style=\"font-size:1rem;\">${i.description}</p></div>')">
      <div class="lesson-icon">📐</div>
      <div class="lesson-info">
        <h3 class="lesson-title">${i.notion}</h3>
        <p style="font-size: 0.85rem; color: #6b7280;">${i.description.substring(0, 80)}...</p>
      </div>
      <div class="lesson-arrow">→</div>
    </div>
  `).join('');
}

function mesuresHTML(items) {
  return items.map(i => `
    <div class="lesson-card" onclick="showDecouverteItem('${i.unite} (${i.symbole})', '<div style=\"text-align:left;\"><p>${i.explication}</p>${i.conversion ? '<br><strong>Conversion :</strong> ' + i.conversion : ''}</div>')">
      <div class="lesson-icon">📏</div>
      <div class="lesson-info">
        <h3 class="lesson-title">${i.unite} (${i.symbole})</h3>
        <p style="font-size: 0.85rem; color: #6b7280;">${i.explication.substring(0, 80)}...</p>
      </div>
      <div class="lesson-arrow">→</div>
    </div>
  `).join('');
}

function anglaisHTML(items) {
  const cats = [...new Set(items.map(i => i.categorie))];
  return cats.map(cat => `
    <div class="skill-section">
      <div class="skill-header" onclick="toggleSkill(this)">
        <span class="skill-icon">🇬🇧</span>
        <span class="skill-name">${cat.charAt(0).toUpperCase() + cat.slice(1)}</span>
        <span class="skill-arrow">▼</span>
      </div>
      <div class="skill-lessons" style="display:none;">
        ${items.filter(i => i.categorie === cat).map(i => `
          <div class="lesson-card" onclick="showDecouverteItem('${i.mot_fr} ↔ ${i.mot_en}', '<div style=\"text-align:left;\"><p><strong>FR :</strong> ${i.mot_fr}<br><strong>EN :</strong> ${i.mot_en}${i.phonetique ? '<br><strong>Phonétique :</strong> ' + i.phonetique : ''}<br><br><em>${i.phrase_fr}</em><br><em>${i.phrase_en}</em></p></div>')">
            <div class="lesson-info">
              <h3 class="lesson-title">${i.mot_fr} ↔ ${i.mot_en}</h3>
              ${i.phonetique ? `<p style="font-size: 0.8rem; color: #9ca3af;">${i.phonetique}</p>` : ''}
            </div>
            <div class="lesson-arrow">→</div>
          </div>
        `).join('')}
      </div>
    </div>
  `).join('');
}

function questionnerMondeHTML(items) {
  const domaines = [...new Set(items.map(i => i.domaine))];
  return domaines.map(dom => `
    <div class="skill-section">
      <div class="skill-header" onclick="toggleSkill(this)">
        <span class="skill-icon">🌍</span>
        <span class="skill-name">${dom.charAt(0).toUpperCase() + dom.slice(1)}</span>
        <span class="skill-arrow">▼</span>
      </div>
      <div class="skill-lessons" style="display:none;">
        ${items.filter(i => i.domaine === dom).map(i => `
          <div class="lesson-card" onclick="showDecouverteItem('${i.titre.replace(/'/g, "\\'")}', '<div style=\"text-align:left;\">${i.contenu}</div>')">
            <div class="lesson-info">
              <h3 class="lesson-title">${i.titre}</h3>
              <p style="font-size: 0.85rem; color: #6b7280;">${i.contenu.substring(0, 80)}...</p>
            </div>
            <div class="lesson-arrow">→</div>
          </div>
        `).join('')}
      </div>
    </div>
  `).join('');
}

function emcHTML(items) {
  return items.map(i => `
    <div class="lesson-card" onclick="showDecouverteItem('${i.valeur.replace(/'/g, "\\'")}', '<div style=\"text-align:left;\"><p>${i.explication}</p>${i.question_reflexion ? '<br><div style=\"background:#fef9c3;padding:12px;border-radius:12px;\"><strong>🤔 Réflexion :</strong><br>${i.question_reflexion}</div>' : ''}</div>')">
      <div class="lesson-icon">🤝</div>
      <div class="lesson-info">
        <h3 class="lesson-title">${i.valeur}</h3>
        <p style="font-size: 0.85rem; color: #6b7280;">${i.explication.substring(0, 80)}...</p>
      </div>
      <div class="lesson-arrow">→</div>
    </div>
  `).join('');
}

function artsHTML(items) {
  const domaines = [...new Set(items.map(i => i.domaine))];
  return domaines.map(dom => {
    const labels = { arts: '🎨 Arts', musique: '🎵 Musique', eps: '🏃 EPS' };
    return `<div class="skill-section">
      <div class="skill-header" onclick="toggleSkill(this)">
        <span class="skill-icon">${dom === 'arts' ? '🎨' : dom === 'musique' ? '🎵' : '🏃'}</span>
        <span class="skill-name">${labels[dom] || dom}</span>
        <span class="skill-arrow">▼</span>
      </div>
      <div class="skill-lessons" style="display:none;">
        ${items.filter(i => i.domaine === dom).map(i => `
          <div class="lesson-card" onclick="showDecouverteItem('${i.activite.replace(/'/g, "\\'")}', '<div style=\"text-align:left;\">${i.description}</div>')">
            <div class="lesson-info">
              <h3 class="lesson-title">${i.activite}</h3>
              <p style="font-size: 0.85rem; color: #6b7280;">${i.description.substring(0, 80)}...</p>
            </div>
            <div class="lesson-arrow">→</div>
          </div>
        `).join('')}
      </div>
    </div>`;
  }).join('');
}

function showDecouverteItem(title, content) {
  document.getElementById('decouverteDetailEmoji').textContent = currentDecouverteSubject?.emoji || '📚';
  document.getElementById('decouverteDetailTitle').textContent = title;
  document.getElementById('decouverteDetailContent').innerHTML = content;
  document.getElementById('decouverteDetailOverlay').classList.add('show');
  playBeep(600, 0.1, 'sine');
}

function closeDecouverteDetail() {
  document.getElementById('decouverteDetailOverlay').classList.remove('show');
}

// === FRACTIONS VISUELLES ===
let fractionsState = {
  mode: null, // 'pizza' or 'partage'
  niveau: 1,
  exercices: [],
  index: 0,
  score: 0,
  total: 0,
  selectedSlices: [],
  completed: false
};

function startFractions() {
  screen = 'fractions';
  fractionsState = { mode: null, niveau: 1, exercices: [], index: 0, score: 0, total: 0, selectedSlices: [], completed: false };
  render();
}

function startPizzaGame() {
  fractionsState.mode = 'pizza';
  fractionsState.index = 0;
  fractionsState.score = 0;
  fractionsState.completed = false;
  fractionsState.selectedSlices = [];
  // Load exercises from Supabase or use defaults
  loadFractionsData('pizza', fractionsState.niveau);
}

function startPartageGame() {
  fractionsState.mode = 'partage';
  fractionsState.index = 0;
  fractionsState.score = 0;
  fractionsState.completed = false;
  loadFractionsData('partage', fractionsState.niveau);
}

async function loadFractionsData(type, niveau) {
  let data = null;
  if (supabase) {
    data = await supabaseService._fetch('fractions_exercices', { eq: { type, niveau }, order: 'id', ascending: true });
  }
  if (!data || data.length === 0) {
    // Fallback data
    data = getFallbackFractions(type, niveau);
  }
  fractionsState.exercices = data;
  fractionsState.total = data.length;
  render();
  showReplayBtn(true);
  setTimeout(() => readAloud(data[0]?.consigne_fr || 'Colorie les parts!', 0.85), 600);
}

function getFallbackFractions(type, niveau) {
  if (type === 'pizza') {
    const fallback = {
      1: [{ consigne_fr:'Colorie 1 part sur 2 de la pizza 🍕', numerateur:1, denominateur:2, reponse_correcte:'1' }],
      2: [{ consigne_fr:'Colorie 1 part sur 4 de la pizza 🍕', numerateur:1, denominateur:4, reponse_correcte:'1' },
          { consigne_fr:'Colorie 3 parts sur 4 de la pizza 🍕', numerateur:3, denominateur:4, reponse_correcte:'3' }],
      3: [{ consigne_fr:'Colorie 1 part sur 3 de la pizza 🍕', numerateur:1, denominateur:3, reponse_correcte:'1' },
          { consigne_fr:'Colorie 2 parts sur 3 de la pizza 🍕', numerateur:2, denominateur:3, reponse_correcte:'2' }],
      4: [{ consigne_fr:'Quelle est la plus grande : 1/2 ou 1/4 ?', numerateur:1, denominateur:2, reponse_correcte:'1_2' },
          { consigne_fr:'Quelle est la plus petite : 1/2 ou 1/4 ?', numerateur:1, denominateur:4, reponse_correcte:'1_4' }]
    };
    const items = fallback[niveau] || fallback[1];
    return items.map((item, i) => ({ id: i, ...item, type: 'pizza', emoji_theme:'🍕' }));
  } else {
    const fallback = {
      1: [{ consigne_fr:'6 bonbons pour 2 amis. Combien chacun ?', nb_objets:6, nb_amis:2, reponse_correcte:'3' }],
      2: [{ consigne_fr:'9 crayons pour 3 amis. Combien chacun ?', nb_objets:9, nb_amis:3, reponse_correcte:'3' }],
      3: [{ consigne_fr:'10 étoiles pour 2 amis. Combien chacune ?', nb_objets:10, nb_amis:2, reponse_correcte:'5' }],
      4: [{ consigne_fr:'12 crayons pour 4 amis. Combien chacun ?', nb_objets:12, nb_amis:4, reponse_correcte:'3' }]
    };
    const items = fallback[niveau] || fallback[1];
    return items.map((item, i) => ({ id: i, ...item, type: 'partage', emoji_theme:'🍬' }));
  }
}

function fractionsHTML() {
  if (fractionsState.mode === null) {
    return `<div class="module-header screen-transition">
      <button class="back-btn" onclick="screen='home';render()">⬅️</button>
      <h2 class="module-title math">🍕 Les Fractions</h2>
    </div>
    <div class="card" style="text-align:center;padding:30px 20px;">
      <p style="font-size:2rem;margin-bottom:20px;">🍕🎁</p>
      <p style="font-size:1.1rem;color:#666;margin-bottom:24px;">Choisis un jeu pour apprendre les fractions !</p>
      <button class="primary-btn btn-blue" style="margin-bottom:12px;width:100%;font-size:1.2rem;" onclick="startPizzaGame()">🍕 La pizza d'Émilie</button>
      <button class="primary-btn btn-green" style="width:100%;font-size:1.2rem;" onclick="startPartageGame()">🎁 Partage équitable</button>
    </div>`;
  }
  if (fractionsState.completed) return fractionsResultHTML();
  if (fractionsState.mode === 'pizza') return pizzaGameHTML();
  return partageGameHTML();
}

function pizzaGameHTML() {
  const ex = fractionsState.exercices[fractionsState.index];
  if (!ex) return fractionsResultHTML();
  const totalParts = ex.denominateur;
  const numerateur = ex.numerateur;
  const angle = 360 / totalParts;
  const slices = fractionsState.selectedSlices;
  
  // Build SVG pizza
  let svgParts = '';
  for (let i = 0; i < totalParts; i++) {
    const sel = slices.includes(i);
    const startAngle = i * angle - 90;
    const endAngle = (i + 1) * angle - 90;
    const x1 = 50 + 45 * Math.cos(startAngle * Math.PI / 180);
    const y1 = 50 + 45 * Math.sin(startAngle * Math.PI / 180);
    const x2 = 50 + 45 * Math.cos(endAngle * Math.PI / 180);
    const y2 = 50 + 45 * Math.sin(endAngle * Math.PI / 180);
    const large = angle > 180 ? 1 : 0;
    svgParts += `<path d="M50,50 L${x1.toFixed(1)},${y1.toFixed(1)} A45,45 0 ${large},1 ${x2.toFixed(1)},${y2.toFixed(1)} Z"
      fill="${sel ? '#FFD700' : '#F5DEB3'}" stroke="#D2691E" stroke-width="2"
      class="pizza-slice${sel ? ' selected' : ''}"
      onclick="togglePizzaSlice(${i})"
      style="cursor:pointer;transition:fill 0.3s, transform 0.2s;${sel ? 'filter: drop-shadow(0 2px 4px rgba(0,0,0,0.3));' : ''}" />`;
  }
  
  // Small pizza topping emojis
  const toppings = ['🍕','🧀','🍅','🌿','🍄','🫒'];
  
  return `<div class="module-header screen-transition">
    <button class="back-btn" onclick="screen='fractions';render()">⬅️</button>
    <h2 class="module-title math">🍕 La pizza d'Émilie</h2>
    <span class="badge-count badge-math">${fractionsState.score}/${fractionsState.total}</span>
  </div>
  <div class="progress-bar"><div class="progress-fill progress-math" style="width:${(fractionsState.index / fractionsState.total) * 100}%"></div></div>
  <div class="card" style="text-align:center;">
    <p class="pizza-consigne">${ex.consigne_fr}</p>
    <div class="pizza-container">
      <svg viewBox="0 0 100 100" width="200" height="200" style="max-width:220px;">
        <circle cx="50" cy="50" r="47" fill="#D2691E" />
        <circle cx="50" cy="50" r="45" fill="#FDF5E6" />
        ${svgParts}
        <circle cx="50" cy="50" r="6" fill="#D2691E" />
        <!-- toppings -->
        ${Array.from({length:totalParts}, (_,i) => {
          const a = (i + 0.5) * angle - 90;
          const r = 25;
          const tx = 50 + r * Math.cos(a * Math.PI / 180);
          const ty = 50 + r * Math.sin(a * Math.PI / 180);
          return `<text x="${tx}" y="${ty}" text-anchor="middle" dominant-baseline="central" font-size="8">${toppings[i % toppings.length]}</text>`;
        }).join('')}
      </svg>
    </div>
    <p style="font-size:0.9rem;color:#D2691E;margin:8px 0;">Clique sur les parts à colorier 🖱️</p>
    <p style="font-size:1.2rem;font-weight:bold;margin:8px 0;">${slices.length}/${numerateur} parts sélectionnées</p>
    <button class="primary-btn ${slices.length === numerateur ? 'btn-green' : 'btn-gray'}"
      onclick="validatePizzaAnswer()" ${slices.length === numerateur ? '' : 'disabled'}>
      ✅ Valider
    </button>
    <button class="btn-reward" style="background:#6b7280;margin-left:8px;" onclick="fractionsState.selectedSlices=[];render();">🔄 Effacer</button>
  </div>`;
}

function togglePizzaSlice(index) {
  const slices = fractionsState.selectedSlices;
  const idx = slices.indexOf(index);
  if (idx >= 0) slices.splice(idx, 1);
  else if (slices.length < fractionsState.exercices[fractionsState.index].numerateur) slices.push(index);
  render();
}

function validatePizzaAnswer() {
  const slices = fractionsState.selectedSlices;
  const ex = fractionsState.exercices[fractionsState.index];
  const correct = fractionsState.exercices[fractionsState.index].reponse_correcte;
  const selectedCount = slices.length;
  
  // For comparison level (niveau 4)
  if (fractionsState.niveau === 4) {
    // correct is like "1_2" meaning "the pizza with 1/2 is larger"
    // We show two pizzas in comparison mode
  }
  
  const isCorrect = String(selectedCount) === String(correct);
  
  if (isCorrect) {
    fractionsState.score++;
    playCorrectSound();
    spawnConfetti(8);
    showFeedback(true, 'Bravo ! Tu as bien colorié la fraction ! 🍕', '🌟');
    readAloud('Bravo, quelle fraction !', 0.9);
  } else {
    playWrongSound();
    showFeedback(false, 'Presque ! Regarde bien combien de parts colorier ! 🍕', '💪');
    readAloud('Essaie encore, tu vas y arriver !', 0.9);
  }
  
  fractionsState.selectedSlices = [];
  questionCount++;
  
  setTimeout(() => {
    fractionsState.index++;
    if (fractionsState.index >= fractionsState.total) {
      fractionsState.completed = true;
      xpEngine.completeSession('math', 'fractions_pizza', fractionsState.score, fractionsState.total, 15);
    }
    render();
    if (questionCount > 0 && questionCount % 5 === 0) triggerPauseEtoiles();
  }, 1200);
}

function partageGameHTML() {
  const ex = fractionsState.exercices[fractionsState.index];
  if (!ex) return fractionsResultHTML();
  const nbAmis = ex.nb_amis || 2;
  const nbObjets = ex.nb_objets || 6;
  const emoji = ex.emoji_theme || '🍬';
  const reponse = parseInt(ex.reponse_correcte);
  
  // Simple version: counte visuel avec répartition automatique
  const amisColors = ['#FF6B9D','#4ECDC4','#C3A6FF','#FFA552','#95E1D3','#FFE66D'];
  const parts = Math.floor(nbObjets / nbAmis);
  const reste = nbObjets % nbAmis;
  
  let amisHTML = '';
  for (let a = 0; a < nbAmis; a++) {
    const count = parts + (a < reste ? 1 : 0);
    amisHTML += `<div class="ami-box">
      <div class="ami-avatar" style="background:${amisColors[a % amisColors.length]}">${String.fromCharCode(65 + a)}</div>
      <div class="ami-objets">${Array.from({length: count}, () => emoji).join('')}</div>
      <div class="ami-count">${count} ${emoji}</div>
    </div>`;
  }
  
  const equalityText = `${nbObjets} ÷ ${nbAmis} = ${parts}${reste > 0 ? ` reste ${reste}` : ''}`;
  
  return `<div class="module-header screen-transition">
    <button class="back-btn" onclick="screen='fractions';render()">⬅️</button>
    <h2 class="module-title math">🎁 Partage équitable</h2>
    <span class="badge-count badge-math">${fractionsState.score}/${fractionsState.total}</span>
  </div>
  <div class="progress-bar"><div class="progress-fill progress-math" style="width:${(fractionsState.index / fractionsState.total) * 100}%"></div></div>
  <div class="card" style="text-align:center;">
    <p class="pizza-consigne">${ex.consigne_fr}</p>
    <div class="partage-container">
      <div class="partage-objets-row">
        ${Array.from({length: nbObjets}, (_, i) => `<span class="partage-objet" style="animation-delay:${i * 0.05}s">${emoji}</span>`).join('')}
      </div>
      <div class="partage-egalite">= ${nbObjets} ${emoji}</div>
      <div class="partage-amis">${amisHTML}</div>
      <div class="partage-equality" style="font-size:1.2rem;font-weight:bold;color:var(--rose);margin:12px 0;">
        ${equalityText}
      </div>
    </div>
    
    <div class="choices" style="justify-content:center;gap:10px;">
      ${Array.from({length: 6}, (_, i) => {
        const val = i + 1;
        return `<button class="choice-btn choice-big" onclick="validatePartageAnswer(${val})" style="min-width:50px;">${val}</button>`;
      }).join('')}
    </div>
  </div>`;
}

function validatePartageAnswer(chosen) {
  const ex = fractionsState.exercices[fractionsState.index];
  const correct = parseInt(ex.reponse_correcte);
  const isCorrect = chosen === correct;
  
  if (isCorrect) {
    fractionsState.score++;
    playCorrectSound();
    spawnConfetti(8);
    showFeedback(true, `Bravo ! ${ex.nb_objets} ÷ ${ex.nb_amis} = ${correct} ! 🎁`, '🌟');
    readAloud(`Bravo ! ${ex.nb_objets} divisé par ${ex.nb_amis} est égal à ${correct} !`, 0.85);
  } else {
    playWrongSound();
    showFeedback(false, 'Presque ! Recompte les objets par ami ! 🎁', '💪');
  }
  
  questionCount++;
  setTimeout(() => {
    fractionsState.index++;
    if (fractionsState.index >= fractionsState.total) {
      fractionsState.completed = true;
      xpEngine.completeSession('math', 'fractions_partage', fractionsState.score, fractionsState.total, 15);
    }
    render();
    if (questionCount > 0 && questionCount % 5 === 0) triggerPauseEtoiles();
  }, 1200);
}

function fractionsResultHTML() {
  const pct = fractionsState.score / fractionsState.total;
  const emoji = pct >= 1 ? '🏆' : pct >= 0.7 ? '🌟' : '💪';
  const msg = pct >= 1 ? 'Parfait ! Championne des fractions !' : pct >= 0.7 ? 'Bravo, continue !' : 'Bien essayé !';
  showReplayBtn(false);
  return `<div class="card result-screen screen-transition">
    <span class="result-emoji">${emoji}</span>
    <div style="font-size:2rem;margin-bottom:10px;">🍕🎁</div>
    <h2 class="result-title">${msg}</h2>
    <p class="result-score">${fractionsState.score}/${fractionsState.total} bonnes réponses</p>
    <p class="result-stars">+${fractionsState.score * 2} ⭐ étoiles</p>
    <button class="primary-btn btn-blue" onclick="screen='fractions';render()">🍕 Rejouer</button>
    <button class="primary-btn btn-green" style="margin-top:8px;" onclick="screen='home';render()">🏠 Accueil</button>
  </div>`;
}

// === GÉOGRAPHIE FRANCE ===
let geoState = {
  mode: null, // 'fleuves','pays','capitales'
  questions: [],
  index: 0, score: 0, total: 0, completed: false
};

function startGeo() { screen = 'geo'; geoState = { mode: null, questions: [], index: 0, score: 0, total: 0, completed: false }; render(); }

async function startGeoGame(mode) {
  geoState.mode = mode; geoState.index = 0; geoState.score = 0; geoState.completed = false;
  let data = null;
  if (supabase) {
    data = await supabaseService._fetch('geo_france', { eq: { type: mode === 'fleuves' ? 'fleuve' : mode === 'pays' ? 'pays_voisin' : 'capitale' }, order: 'id' });
  }
  if (!data || data.length === 0) {
    data = [
      { nom: 'Loire', description: 'Plus long fleuve de France (1006 km)', emoji: '🌊', anecdote: 'La Loire traverse 12 départements !' },
      { nom: 'Seine', description: 'Fleuve qui traverse Paris', emoji: '🏙️', anecdote: 'La Seine accueille les JO !' },
      { nom: 'Rhône', description: 'Fleuve des Alpes à la Méditerranée', emoji: '⛰️', anecdote: 'Prend sa source dans un glacier !' },
      { nom: 'Garonne', description: 'Fleuve du sud-ouest (647 km)', emoji: '🌿', anecdote: 'Donne son nom à la Haute-Garonne.' }
    ].filter(() => mode === 'fleuves');
  }
  geoState.questions = shuffle(data).slice(0, 6);
  geoState.total = geoState.questions.length;
  render();
  setTimeout(() => { showReplayBtn(true); const firstQ = document.querySelector('.question-card p'); if (firstQ) readAloud(firstQ.textContent, 0.85); }, 600);
}

function geoHTML() {
  if (geoState.mode === null) {
    return `<div class="module-header screen-transition"><button class="back-btn" onclick="screen='home';render()">⬅️</button><h2 class="module-title math">🗺️ La France</h2></div>
    <div class="card" style="text-align:center;padding:30px 20px;">
      <p style="font-size:2rem;margin-bottom:16px;">🗺️🌊🇪🇺</p>
      <p style="font-size:1.1rem;color:#666;margin-bottom:20px;">Choisis un quiz géographie !</p>
      <button class="primary-btn btn-blue" style="margin-bottom:10px;width:100%;font-size:1.1rem;" onclick="startGeoGame('fleuves')">🌊 Les fleuves de France</button>
      <button class="primary-btn btn-green" style="margin-bottom:10px;width:100%;font-size:1.1rem;" onclick="startGeoGame('pays')">🌍 Les pays voisins</button>
      <button class="primary-btn" style="background:var(--violet);width:100%;font-size:1.1rem;" onclick="startGeoGame('capitales')">🏛️ Les capitales</button>
    </div>`;
  }
  if (geoState.completed) return geoResultHTML();
  const q = geoState.questions[geoState.index];
  if (!q) return geoResultHTML();
  const choices = generateGeoChoices(q, geoState.questions);
  return `<div class="module-header screen-transition"><button class="back-btn" onclick="screen='geo';render()">⬅️</button>
    <h2 class="module-title math">${geoState.mode === 'fleuves' ? '🌊 Fleuves' : geoState.mode === 'pays' ? '🌍 Pays voisins' : '🏛️ Capitales'}</h2>
    <span class="badge-count badge-math">${geoState.score}/${geoState.total}</span></div>
  <div class="progress-bar"><div class="progress-fill progress-math" style="width:${(geoState.index/geoState.total)*100}%"></div></div>
  <div class="question-card"><p>${geoState.mode === 'capitales' ? `🇪🇺 ${q.nom} est la capitale de quel pays ?` : `Que sais-tu sur ${q.nom} ?`}</p></div>
  <div class="choices grid2">${choices.map(c => `<button class="choice-btn" onclick="handleGeoAnswer('${c}')">${c}</button>`).join('')}</div>
  ${q.anecdote ? `<div class="mascot-tip"><em>💡 ${q.anecdote}</em></div>` : ''}`;
}

function generateGeoChoices(q, allQ) {
  const correct = q.nom || q.capitale || q.description;
  const others = allQ.filter(x => x.nom !== q.nom).map(x => x.nom || x.capitale || x.description);
  const choices = new Set([correct]);
  while (choices.size < 4 && others.length > 0) {
    choices.add(others[Math.floor(Math.random() * others.length)]);
  }
  while (choices.size < 4) choices.add(['France','Espagne','Allemagne','Italie'][choices.size - 1]);
  return [...choices].sort(() => Math.random() - 0.5);
}

function handleGeoAnswer(chosen) {
  const q = geoState.questions[geoState.index];
  const correct = q.nom || q.capitale || q.description;
  const isCorrect = chosen === correct;
  if (isCorrect) { geoState.score++; playCorrectSound(); spawnConfetti(5); showFeedback(true); xpEngine.addCorrectAnswer('science'); }
  else { playWrongSound(); showFeedback(false); xpEngine.addWrongAnswer(); }
  questionCount++;
  setTimeout(() => {
    geoState.index++;
    if (geoState.index >= geoState.total) { geoState.completed = true; xpEngine.completeSession('geo', geoState.mode, geoState.score, geoState.total, 10); }
    render();
    if (questionCount % 5 === 0) triggerPauseEtoiles();
  }, 1000);
}

function geoResultHTML() {
  const pct = geoState.score / geoState.total;
  showReplayBtn(false);
  return `<div class="card result-screen"><span class="result-emoji">${pct>=1?'🏆':pct>=0.7?'🌟':'💪'}</span>
    <div style="font-size:2rem;margin-bottom:10px;">🗺️🌊</div>
    <h2 class="result-title">${pct>=1?'Parfait !':pct>=0.7?'Bravo !':'Bien essayé !'}</h2>
    <p class="result-score">${geoState.score}/${geoState.total} bonnes réponses</p>
    <button class="primary-btn btn-blue" onclick="screen='geo';render()">🗺️ Rejouer</button>
    <button class="primary-btn btn-green" style="margin-top:8px;" onclick="screen='home';render()">🏠 Accueil</button></div>`;
}

// === CONJUGAISON MINI-JEU ===
let conjugState = { questions: [], index: 0, score: 0, total: 0, completed: false };

async function startConjugaison() {
  screen = 'conjugaison';
  conjugState = { questions: [], index: 0, score: 0, total: 0, completed: false };
  let data = null;
  if (supabase) {
    const { data: db, error } = await supabase.from('conjugaison_exercices').select('*').order('id');
    if (!error) data = db;
  }
  if (!data || data.length === 0) {
    // Fallback
    data = [
      { verbe: 'être', pronom: 'je', bonne_reponse: 'suis', mauvaise1: 'es', mauvaise2: 'est' },
      { verbe: 'être', pronom: 'tu', bonne_reponse: 'es', mauvaise1: 'suis', mauvaise2: 'est' },
      { verbe: 'être', pronom: 'il/elle', bonne_reponse: 'est', mauvaise1: 'es', mauvaise2: 'suis' },
      { verbe: 'avoir', pronom: 'j\'', bonne_reponse: 'ai', mauvaise1: 'as', mauvaise2: 'a' },
      { verbe: 'avoir', pronom: 'tu', bonne_reponse: 'as', mauvaise1: 'ai', mauvaise2: 'a' },
    ];
  }
  conjugState.questions = data.map(d => {
    const ops = [d.bonne_reponse, d.mauvaise1, d.mauvaise2].sort(() => Math.random() - 0.5);
    return { verbe: d.verbe, pronom: d.pronom, correct: d.bonne_reponse, choices: ops };
  });
  conjugState.total = conjugState.questions.length;
  render();
  readAloud(`Conjugaison ! Choisis la bonne forme du verbe.`);
}

function answerConjugaison(chosen, correct) {
  if (conjugState.completed) return;
  const isCorrect = chosen === correct;
  if (isCorrect) { conjugState.score++; playCorrectSound(); spawnConfetti(5); showFeedback(true); xpEngine.addCorrectAnswer('french'); }
  else { playWrongSound(); showFeedback(false); xpEngine.addWrongAnswer(); }
  questionCount++;
  setTimeout(() => {
    conjugState.index++;
    if (conjugState.index >= conjugState.total) { conjugState.completed = true; xpEngine.completeSession('french', 'conjugaison', conjugState.score, conjugState.total, 10); }
    render();
    if (questionCount % 5 === 0) triggerPauseEtoiles();
  }, 1000);
}

function conjugaisonMenuHTML() {
  if (conjugState.completed) return conjugaisonResultHTML();
  const q = conjugState.questions[conjugState.index];
  if (!q) return `<div class="card"><p class="empty-msg">Aucune question</p></div>`;
  const prog = conjugState.total > 0 ? (conjugState.index / conjugState.total * 100) : 0;
  setTimeout(() => {
    readAloud(`${q.pronom} ${q.verbe} au présent.`);
    document.querySelectorAll('.choice-btn').forEach((b,i) => { if (i===0) b.focus(); });
  }, 300);
  return `<div class="card quiz-card">
    <div class="progress-bar" style="margin-bottom:10px;"><div class="progress-fill" style="width:${prog}%;background:linear-gradient(90deg,#f472b6,#8b5cf6);"></div></div>
    <div style="text-align:center;">
      <div style="font-size:3rem;">🔄</div>
      <h2 style="font-size:1.3rem;margin:8px 0;">Conjugue le verbe "${q.verbe}"</h2>
      <p style="font-size:2rem;font-weight:900;margin:12px 0;color:#6366f1;">${q.pronom} ___</p>
    </div>
    <div class="choices-container">
      ${q.choices.map(c => `<button class="choice-btn" onclick="answerConjugaison('${c.replace(/'/g,"\\'")}','${q.correct.replace(/'/g,"\\'")}')">${c}</button>`).join('')}
    </div>
    <div style="text-align:center;margin-top:8px;font-size:0.85rem;color:#999;">
      Question ${conjugState.index+1}/${conjugState.total}
    </div>
  </div>`;
}

function conjugaisonResultHTML() {
  showReplayBtn(false);
  const pct = conjugState.score / conjugState.total;
  return `<div class="card result-screen"><span class="result-emoji">${pct>=1?'🏆':pct>=0.7?'🌟':'💪'}</span>
    <div style="font-size:2rem;margin-bottom:10px;">🔄📚</div>
    <h2 class="result-title">${pct>=1?'Parfait !':pct>=0.7?'Bravo !':'Bien essayé !'}</h2>
    <p class="result-score">${conjugState.score}/${conjugState.total} bonnes réponses</p>
    <button class="primary-btn btn-blue" onclick="startConjugaison()">🔄 Rejouer</button>
    <button class="primary-btn btn-green" style="margin-top:8px;" onclick="screen='home';render()">🏠 Accueil</button></div>`;
}

// === HISTOIRE CE1 ===
let histoireState = {
  mode: null, // 'quissuisje','vraifaux'
  questions: [], index: 0, score: 0, total: 0, completed: false, hintLevel: 0
};

function startHistoire() { screen = 'histoire'; histoireState = { mode: null, questions: [], index: 0, score: 0, total: 0, completed: false, hintLevel: 0 }; render(); }

async function startHistoireGame(mode) {
  histoireState.mode = mode; histoireState.index = 0; histoireState.score = 0; histoireState.completed = false; histoireState.hintLevel = 0;
  let data = null;
  if (supabase) {
    data = await supabaseService._fetch('histoire_ce1', { eq: mode === 'quissuisje' ? { type_contenu: 'personnage' } : { type_contenu: 'vrai_faux' }, order: 'id' });
  }
  if (!data || data.length === 0) {
    if (mode === 'quissuisje') {
      data = [
        { personnage: 'Jeanne d\'Arc', emoji: '⚜️', indices: ['Je suis née en 1412','J\'ai porté une armure','J\'ai libéré Orléans'], description_simple: 'Jeanne d\'Arc' },
        { personnage: 'Marie Curie', emoji: '🔬', indices: ['Je suis scientifique','J\'ai découvert la radioactivité','J\'ai eu deux Prix Nobel'], description_simple: 'Marie Curie' }
      ];
    } else {
      data = [
        { affirmation: 'Les Romains ont construit des routes en France', affirmation_vrai: true, explication_courte: 'Les Romains ont construit plus de 100 000 km de routes !', emoji: '🏛️' },
        { affirmation: 'Jeanne d\'Arc était un roi', affirmation_vrai: false, explication_courte: 'Jeanne d\'Arc était une jeune fille de 17 ans.', emoji: '⚔️' }
      ];
    }
  }
  histoireState.questions = shuffle(data).slice(0, 6);
  histoireState.total = histoireState.questions.length;
  screen = 'histoire';
  render();
  setTimeout(() => { showReplayBtn(true); const p = document.querySelector('.question-card p'); if (p) readAloud(p.textContent, 0.85); }, 600);
}

function histoireHTML() {
  if (histoireState.mode === null) {
    return `<div class="module-header screen-transition"><button class="back-btn" onclick="screen='home';render()">⬅️</button><h2 class="module-title math">🏰 Histoire</h2></div>
    <div class="card" style="text-align:center;padding:30px 20px;">
      <p style="font-size:2rem;margin-bottom:16px;">🏰⚜️🔬</p>
      <p style="font-size:1.1rem;color:#666;margin-bottom:20px;">Choisis un quiz histoire !</p>
      <button class="primary-btn btn-blue" style="margin-bottom:10px;width:100%;font-size:1.1rem;" onclick="startHistoireGame('quissuisje')">🎭 Qui suis-je ? (Personnages)</button>
      <button class="primary-btn btn-green" style="width:100%;font-size:1.1rem;" onclick="startHistoireGame('vraifaux')">✅❌ Vrai ou Faux ?</button>
    </div>`;
  }
  if (histoireState.completed) return histoireResultHTML();
  const q = histoireState.questions[histoireState.index];
  if (!q) return histoireResultHTML();

  if (histoireState.mode === 'quissuisje') {
    const maxHints = (q.indices && q.indices.length) || 3;
    const showHints = q.indices ? q.indices.slice(0, histoireState.hintLevel + 1) : [`Indice ${histoireState.hintLevel + 1}`];
    const points = 3 - histoireState.hintLevel;
    return `<div class="module-header screen-transition"><button class="back-btn" onclick="screen='histoire';render()">⬅️</button>
      <h2 class="module-title math">🎭 Qui suis-je ?</h2>
      <span class="badge-count badge-math">${histoireState.score}/${histoireState.total}</span></div>
    <div class="progress-bar"><div class="progress-fill progress-math" style="width:${(histoireState.index/histoireState.total)*100}%"></div></div>
    <div class="card" style="text-align:center;">
      <div style="font-size:4rem;margin-bottom:10px;">${q.emoji || '🎭'}</div>
      <p style="font-size:1rem;font-weight:bold;color:var(--rose);margin-bottom:12px;">Devine qui je suis ! (${points} pts si bonne réponse)</p>
      ${showHints.map((h,i) => `<div class="hint-bubble">📌 ${h}</div>`).join('')}
      ${histoireState.hintLevel < maxHints - 1 ? `<button class="btn-reward" style="background:var(--orange);margin:8px;" onclick="nextHint()">🔍 Plus d'indices (${points-1} pts)</button>` : ''}
      <div class="choices grid2" style="margin-top:12px;">
        ${['Jeanne d\'Arc','Marie Curie','Napoléon','Louis XIV','Vercingétorix','De Gaulle']
          .sort(() => Math.random() - 0.5).slice(0,4)
          .map(n => `<button class="choice-btn" onclick="handleHistoireAnswer('${n}')">${n}</button>`).join('')}
      </div>
    </div>`;
  } else {
    return `<div class="module-header screen-transition"><button class="back-btn" onclick="screen='histoire';render()">⬅️</button>
      <h2 class="module-title math">✅❌ Vrai ou Faux ?</h2>
      <span class="badge-count badge-math">${histoireState.score}/${histoireState.total}</span></div>
    <div class="progress-bar"><div class="progress-fill progress-math" style="width:${(histoireState.index/histoireState.total)*100}%"></div></div>
    <div class="card question-card"><p>${q.affirmation || q.evenement}</p></div>
    <div class="choices" style="justify-content:center;gap:16px;">
      <button class="choice-btn" style="font-size:1.5rem;padding:20px 40px;background:#16a34a;color:white;" onclick="handleVFAnswer(true)">✅ VRAI</button>
      <button class="choice-btn" style="font-size:1.5rem;padding:20px 40px;background:#dc2626;color:white;" onclick="handleVFAnswer(false)">❌ FAUX</button>
    </div>
    ${q.emoji ? `<div class="mascot-tip"><em>${q.emoji}</em></div>` : ''}`;
  }
}

function nextHint() { histoireState.hintLevel++; render(); }

function handleHistoireAnswer(chosen) {
  const q = histoireState.questions[histoireState.index];
  const correct = q.personnage || q.description_simple || '';
  const isCorrect = chosen === correct || chosen === q.personnage;
  if (isCorrect) { histoireState.score++; playCorrectSound(); spawnConfetti(8); showFeedback(true); xpEngine.addCorrectAnswer('science'); }
  else { playWrongSound(); showFeedback(false); xpEngine.addWrongAnswer(); }
  questionCount++;
  setTimeout(() => { histoireState.index++; histoireState.hintLevel = 0; if (histoireState.index >= histoireState.total) { histoireState.completed = true; xpEngine.completeSession('histoire', histoireState.mode, histoireState.score, histoireState.total, 10); } render(); if (questionCount % 5 === 0) triggerPauseEtoiles(); }, 1200);
}

function handleVFAnswer(chosen) {
  const q = histoireState.questions[histoireState.index];
  const correct = q.affirmation_vrai === true;
  const isCorrect = chosen === correct;
  if (isCorrect) { histoireState.score++; playCorrectSound(); spawnConfetti(5); showFeedback(true); readAloud(q.explication_courte || 'Bravo !', 0.85); }
  else { playWrongSound(); showFeedback(false); setTimeout(() => { if (q.explication_courte) showFeedback(true, q.explication_courte, '💡'); }, 300); }
  questionCount++;
  setTimeout(() => { histoireState.index++; if (histoireState.index >= histoireState.total) { histoireState.completed = true; xpEngine.completeSession('histoire', 'vraifaux', histoireState.score, histoireState.total, 10); } render(); if (questionCount % 5 === 0) triggerPauseEtoiles(); }, 2000);
}

function histoireResultHTML() {
  const pct = histoireState.score / histoireState.total;
  showReplayBtn(false);
  return `<div class="card result-screen"><span class="result-emoji">${pct>=1?'🏆':pct>=0.7?'🌟':'💪'}</span>
    <div style="font-size:2rem;margin-bottom:10px;">🏰⚜️</div>
    <h2 class="result-title">${pct>=1?'Parfait !':pct>=0.7?'Bravo !':'Bien essayé !'}</h2>
    <p class="result-score">${histoireState.score}/${histoireState.total} bonnes réponses</p>
    <button class="primary-btn btn-blue" onclick="screen='histoire';render()">🏰 Rejouer</button>
    <button class="primary-btn btn-green" style="margin-top:8px;" onclick="screen='home';render()">🏠 Accueil</button></div>`;
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
  else if (screen === 'decouvertes') app.innerHTML = decouvertesHTML();
  else if (screen === 'decouverteDetail') app.innerHTML = decouverteDetailHTML();
  else if (screen === 'math' || screen === 'french' || screen === 'science') {
    if (done) app.innerHTML = resultHTML();
    else app.innerHTML = quizHTML();
  } else if (screen === 'trophy') app.innerHTML = trophyHTML();
  else if (screen === 'challenge') app.innerHTML = challengeHTML();
  else if (screen === 'visualMath') app.innerHTML = visualMathHTML();
  else if (screen === 'chenille') app.innerHTML = chenilleHTML();
  else if (screen === 'fractions') app.innerHTML = fractionsHTML();
  else if (screen === 'geo') app.innerHTML = geoHTML();
  else if (screen === 'histoire') app.innerHTML = histoireHTML();
  else if (screen === 'conjugaison') app.innerHTML = conjugaisonMenuHTML();
  else if (screen === 'parental') app.innerHTML = parentalHTML();
  else if (screen === 'parentalDashboard') app.innerHTML = parentalDashboardHTML();
  attachListeners();
  initStickerAlbum();
  // Draw charts after dashboard renders
  if (screen === 'parentalDashboard') { drawParentalCharts(); }
  // Lecture automatique des questions
  if (screen === 'visualMath' || screen === 'chenille') {
    showReplayBtn(true);
    setTimeout(() => {
      const consigne = document.querySelector('.visuel-consigne');
      if (consigne) readAloud(consigne.textContent.replace(/<[^>]*>/g,''), 0.85);
    }, 800);
  }
  // Cacher le bouton réécoute sur les écrans non-exercice
  if (screen === 'home' || screen === 'parental' || screen === 'parentalDashboard' || done) showReplayBtn(false);
}

function homeHTML() {
  const p = xpEngine.progress || { total_xp: 0, level: 1, stars: 0 };
  const xpVal = p.total_xp || 0;
  const levelVal = p.level || 1;
  const starsVal = p.stars || 0;
  const badgeCount = xpEngine.badges ? xpEngine.badges.length : 0;
  const xpPct = Math.min(((xpVal % 100) / 100) * 100, 100);
  const streakVal = p.streak_count || p.streak_days || 0;
  return `<div class="header screen-transition">
    <div class="mascot-star-container">
      <img src="icons/emilie-star.svg" class="mascot-star-img" alt="Émilie l'étoile" onclick="sayMessage('Bonjour Emilie, c\'est parti pour apprendre !')">
      <div class="sparkle-ring"></div>
    </div>
    <h1>Bonjour Emilie !</h1>
    ${routineActive ? '' : '<p>Qu\'est-ce qu\'on apprend aujourd\'hui ?</p>'}
    <div class="header-mascots">
      <div class="mascot-header squirrel" onclick="talkMascot('squirrel')" title="Noisette dit bonjour !">🐿️</div>
      <div class="mascot-header jelly" onclick="talkMascot('jelly')" title="Bulle flotte !">🪼</div>
      <div class="mascot-header seal" onclick="talkMascot('seal')" title="Câlin t'encourage !">🦭</div>
    </div>
  </div>
  
  ${planHTML()}
  
  <div class="stats-bar">
    <div class="stat-item"><span>⭐</span><span id="totalStars">${starsVal}</span> étoiles</div>
    <div class="stat-item"><span>🏅</span><span id="totalBadges">${badgeCount}</span> badges</div>
    <div class="stat-item"><span>🔥</span><span>${streakVal}</span> jours</div>
    <div class="stat-item"><span>🎯</span><span id="levelDisplay">Niv.${levelVal}</span></div>
  </div>
  
  <div class="level-section">
    <div class="level-title">
      <span>🐣 Début</span>
      <span id="xpText">${xpVal % 100} / 100 XP</span>
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
      <strong>Série de ${streakVal} jour${streakVal > 1 ? 's' : ''} !</strong><br>
      <small>${streakVal >= 30 ? '👑 Légende ! Incroyable Emilie !' : streakVal >= 14 ? '🌟 Super Emilie, tu es une championne !' : streakVal >= 7 ? '🔥 7 jours de suite, quel talent !' : streakVal >= 3 ? '🌱 3 jours déjà, bravo !' : 'Continue comme ça, Câlin est fier de toi !'}</small>
    </div>
    <div class="streak-animals">🐿️🪼🦭</div>
  </div>

  ${streakVal > 0 ? `<div class="streak-milestones" style="display:flex;gap:6px;justify-content:center;margin-top:-6px;font-size:1.2rem">
    ${[3,7,14,30].map(m => `<span style="opacity:${streakVal >= m ? 1 : 0.2}">${m}j${streakVal >= m ? '✅' : ''}</span>`).join(' ')}
  </div>` : ''}
  
  ${p.streak_last_date && p.streak_last_date !== new Date().toISOString().split('T')[0] ? `<div class="mascot-reminder" onclick="talkMascot('squirrel')" style="background:linear-gradient(135deg,#fef3c7,#fde68a);border-radius:16px;padding:10px 16px;margin:4px auto;max-width:300px;text-align:center;cursor:pointer;font-weight:600">
    🐿️ Noisette te cherche ! Tu n'as pas joué aujourd'hui. Clique pour un message !
  </div>` : ''}
  
  <div class="subject-progress-section">
    <div class="subject-progress-row">
      <span class="subj-icon">🔢</span>
      <div class="subj-bar-wrap"><div class="subj-bar"><div class="subj-fill math-fill" style="width:${Math.min((p.math_score||0)/2, 100)}%"></div></div></div>
      <span class="subj-score">${p.math_score||0} pts</span>
    </div>
    <div class="subject-progress-row">
      <span class="subj-icon">📖</span>
      <div class="subj-bar-wrap"><div class="subj-bar"><div class="subj-fill french-fill" style="width:${Math.min((p.french_score||0)/2, 100)}%"></div></div></div>
      <span class="subj-score">${p.french_score||0} pts</span>
    </div>
    <div class="subject-progress-row">
      <span class="subj-icon">🔬</span>
      <div class="subj-bar-wrap"><div class="subj-bar"><div class="subj-fill science-fill" style="width:${Math.min((p.science_score||0)/2, 100)}%"></div></div></div>
      <span class="subj-score">${p.science_score||0} pts</span>
    </div>
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
      <button class="mini-game-btn rocket" onclick="startChallenge('defi')" style="background: linear-gradient(135deg, #f59e0b, #d97706);">
        <span class="emoji">⚡</span>
        <span>Défi Maths</span>
      </button>
      <button class="mini-game-btn word-hunt" onclick="startVisualMath('boulangerie')" style="background: linear-gradient(135deg, #f59e0b, #b45309);">
        <span class="emoji">🥐</span>
        <span>Boulangerie</span>
      </button>
      <button class="mini-game-btn rocket" onclick="startVisualMath('ferme')" style="background: linear-gradient(135deg, #16a34a, #15803d);">
        <span class="emoji">🐔</span>
        <span>Ferme</span>
      </button>
      <button class="mini-game-btn rocket" onclick="startVisualMath('gateaux')" style="background: linear-gradient(135deg, #ec4899, #db2777);">
        <span class="emoji">🎂</span>
        <span>Gâteaux</span>
      </button>
      <button class="mini-game-btn word-hunt" onclick="startChenille(2)" style="background: linear-gradient(135deg, #8b5cf6, #7c3aed);">
        <span class="emoji">🐛</span>
        <span>Chenille</span>
      </button>
      <button class="mini-game-btn rocket" onclick="startFractions()" style="background: linear-gradient(135deg, #FF6B9D, #e85a8a);">
        <span class="emoji">🍕</span>
        <span>Fractions</span>
      </button>
      <button class="mini-game-btn word-hunt" onclick="startGeo()" style="background: linear-gradient(135deg, #3b82f6, #1d4ed8);">
        <span class="emoji">🗺️</span>
        <span>Géographie</span>
      </button>
      <button class="mini-game-btn rocket" onclick="startHistoire()" style="background: linear-gradient(135deg, #7c3aed, #5b21b6);">
        <span class="emoji">🏰</span>
        <span>Histoire</span>
      </button>
      <button class="mini-game-btn word-hunt" onclick="startConjugaison()" style="background: linear-gradient(135deg, #06b6d4, #0891b2);">
        <span class="emoji">🔄</span>
        <span>Conjugaison</span>
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
      <span class="card-mascot squirrel">🐿️</span>
    </button>
    <button class="subject-btn btn-discovery" onclick="screen='decouvertes';render()" style="background: #fef3c7;">
      <span class="emoji">🌟</span><span>Découvertes</span>
      <span class="card-mascot jelly">🪼</span>
    </button>
    <button class="subject-btn btn-science" data-subject="science">
      <span class="emoji">🔬</span><span>Sciences</span>
      <span class="card-mascot">🐿️</span>
    </button>
    <button class="subject-btn btn-trophy" data-subject="trophy">
      <span class="emoji">🏆</span><span>Trophées</span>
    </button>
  </div>
  
  <div style="text-align:center;padding:12px;display:flex;justify-content:center;gap:16px;">
    <button class="parental-link" data-action="parental">👨‍👩‍👧 Espace parents</button>
    <button class="parental-link" onclick="toggleNightMode()">${nightMode ? '☀️' : '🌙'} ${nightMode ? 'Jour' : 'Nuit'}</button>
  </div>`;
}

function quizHTML() {
  // Pour le module Maths, utiliser le système d'onglets avec #mathExerciseArea
  if (module === 'math') {
    const qProg = Math.min(((questionCount % 5) / 5) * 100, 100);
    const barColor = qProg < 33 ? '#FF6B9D' : qProg < 66 ? '#FFA552' : '#4ECDC4';
    return `<div class="module-header screen-transition">
      <button class="back-btn" data-action="back">⬅️</button>
      <h2 class="module-title math">🔢 Maths avec 🪼 Bulle</h2>
      <span class='badge-count badge-math' id='mathProgress'>${score}/10</span>
    </div>
    
    <div class="progress-bar" style="margin:0 16px 8px"><div class="progress-fill" style="width:${qProg}%;background:${barColor}"></div></div>
    <div style="text-align:center;font-size:0.9rem;color:#888;margin-bottom:4px">${questionCount > 0 ? `Question ${(questionCount % 5) + 1} sur 5 ${questionCount % 5 === 4 ? '🎯' : ''}` : ''}</div>
    
    <div id="mathExerciseArea"></div>
    <div class="mascot-tip" style="text-align:center;">
      <em>🪼 Bulle : "Les maths c'est comme nager, tu vas progresser !"</em>
    </div>`;
  }
  
  // Pour les autres modules (français, sciences), utiliser le système existant
  const ex = exercises[qIdx];
  const prog = ((qIdx) / exercises.length) * 100;
  const cls = module === 'math' ? 'math' : module === 'french' ? 'french' : 'science';
  const mascotClass = ex.mascot || 'bounce';
  const mascotEmoji = module === 'math' ? '🪼' : module === 'french' ? '🦭' : '🐿️';
  const gridClass = typeof ex.a === 'number' && ex.c.length === 4 ? 'grid2' : '';
  
  // Start timer for this question
  setTimeout(() => startQuizTimer(30, handleTimeout), 100);
  
  return `<div class="module-header screen-transition">
    <button class="back-btn" data-action="back">⬅️</button>
    <h2 class="module-title ${cls}">${module === 'math' ? '🔢 Maths avec 🪼 Bulle' : module === 'french' ? '📖 Français avec 🦭 Câlin' : '🔬 Sciences avec 🐿️ Noisette'}</h2>
    <span class="badge-count badge-${cls}">${qIdx + 1}/${exercises.length}</span>
  </div>
  
  <div class="progress-bar"><div class="progress-fill" style="width:${prog}%;background:${prog < 33 ? '#FF6B9D' : prog < 66 ? '#FFA552' : '#4ECDC4'}"></div></div>
  ${exercises.length - qIdx <= 2 ? `<div style="text-align:center;font-size:0.9rem;color:#FF6B9D;font-weight:bold">Plus que ${exercises.length - qIdx} question${exercises.length - qIdx > 1 ? 's' : ''} ! 🎯</div>` : ''}
  
  <div class="question-card" style="position: relative;">
    <span class="quiz-mascot ${mascotClass}">${mascotEmoji}</span>
    <span class="exercise-mascot ${mascotClass}" style="margin-bottom: 15px;">${mascotEmoji}</span>
    <div id="quizTimerDisplay" style="position:absolute;top:5px;left:10px;">${timerSVG(30, 30, 50)}</div>
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
  clearQuizTimer();
  // Show victory overlay for perfect score
  if (score === exercises.length && exercises.length >= 5) {
    setTimeout(() => {
      showVictory('🌟', 'Score Parfait !', `${score}/${exercises.length} bonnes réponses`, `+${score * 10} XP`);
    }, 500);
  }
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
  const p = xpEngine.progress || { stars: 0, level: 1, streak_days: 1 };
  const allBadges = xpEngine.badges || [];
  const oldBadgeList = badges.map(b => `<div class="badge-item">${b}</div>`).join('');
  const newBadgeList = allBadges.map(b => `<div class="badge-item" title="${b.badge_name}">${b.badge_emoji} ${b.badge_name}</div>`).join('');
  const badgeHtml = oldBadgeList || newBadgeList || `<p class="empty-msg">Continue les exercices pour gagner des badges ! 💪🐿️🪼🦭</p>`;
  return `<div class="module-header screen-transition">
    <button class="back-btn" data-action="back">⬅️</button>
    <h2 class="module-title trophy">🏆 Mes Trophées 🐿️🪼🦭</h2>
  </div>
  <div class="trophies-grid">
    <div class="trophy-card"><span class="trophy-icon">⭐</span><div class="trophy-value">${p.stars || 0}</div><div class="trophy-label">étoiles</div></div>
    <div class="trophy-card"><span class="trophy-icon">🏅</span><div class="trophy-value">${allBadges.length}</div><div class="trophy-label">badges</div></div>
    <div class="trophy-card"><span class="trophy-icon">🎯</span><div class="trophy-value">Niv.${p.level || 1}</div><div class="trophy-label">niveau</div></div>
    <div class="trophy-card"><span class="trophy-icon">🔥</span><div class="trophy-value">${p.streak_days || 1}</div><div class="trophy-label">jours</div></div>
  </div>
  <div class="card">
    <h3 style="font-weight:900;margin-bottom:12px">🏅 Mes Badges</h3>
    ${badgeHtml}
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
  // Show PIN lock screen first, dashboard after unlock
  return `<div class="card parental-lock screen-transition">
    <div style="font-size:40px;margin-bottom:16px">👨‍👩‍👧</div>
    <h2 style="font-size:22px;font-weight:900;margin-bottom:8px">Espace Parents</h2>
    <p style="color: #666; margin-bottom:16px;">Entre le code PIN pour accéder au tableau de bord</p>
    <input type="password" maxlength="4" class="pin-input" id="pin" placeholder="••••" autocomplete="off">
    <p class="error-msg" id="error" style="display:none">Code incorrect !</p>
    <button class="primary-btn btn-purple" onclick="unlockParental()">🔓 Déverrouiller</button>
    <button class="parental-link" onclick="screen='home';render();">Retour</button>
  </div>`;
}

let currentSettings = JSON.parse(localStorage.getItem('emilie_settings') || '{}');

function getSetting(key, defaultValue = true) {
  if (currentSettings[key] !== undefined) return currentSettings[key];
  return defaultValue;
}

function toggleSetting(key) {
  currentSettings[key] = !getSetting(key);
  localStorage.setItem('emilie_settings', JSON.stringify(currentSettings));
  render();
}

function setSetting(key, value) {
  currentSettings[key] = value;
  localStorage.setItem('emilie_settings', JSON.stringify(currentSettings));
}

function parentalDashboardHTML() {
  const p = xpEngine.progress || {};
  const sessions = window._parentalSessions || [];
  const totalXp = p.total_xp || 0;
  const lvl = p.level || 1;
  const starCount = p.stars || 0;
  const badgeCount = xpEngine.badges ? xpEngine.badges.length : 0;
  const streakDays = p.streak_days || 1;
  const totalEx = p.total_exercises || 0;
  const mathSc = p.math_score || 0;
  const frenchSc = p.french_score || 0;
  const scienceSc = p.science_score || 0;
  const geoScore = p.discovery_score || 0;
  const histoireScore = p.history_score || 0;

  // Stats per subject (success rate)
  const subjectScores = { 'Maths': mathSc, 'Français': frenchSc, 'Sciences': scienceSc, 'Géo': geoScore, 'Histoire': histoireScore };
  const subjectMax = Math.max(...Object.values(subjectScores), 1);
  
  // Favorite mini-game
  const gameCounts = {};
  sessions.forEach(s => { const cat = s.category || s.subject; gameCounts[cat] = (gameCounts[cat] || 0) + 1; });
  const favGame = Object.entries(gameCounts).sort((a,b) => b[1]-a[1])[0];
  
  // Weekly report text
  const reportLines = [];
  if (totalEx > 0) {
    reportLines.push(`Cette semaine, Emilie a complété ${totalEx} exercices.`);
    for (const [subject, score] of Object.entries(subjectScores)) {
      if (score > 0) {
        const pct = Math.min(Math.round(score / 50 * 100), 100);
        if (pct >= 80) reportLines.push(`Elle excelle en ${subject} (${pct}% de réussite) 🎉`);
        else if (pct >= 50) reportLines.push(`Elle progresse bien en ${subject} (${pct}%)`);
        else if (pct > 0) reportLines.push(`Elle découvre ${subject} (${pct}%)`);
      }
    }
    if (favGame) reportLines.push(`Mini-jeu préféré : ${favGame[0]} (${favGame[1]} parties)`);
    reportLines.push(`Streak actuel : ${streakDays} jours 🔥`);
  } else { reportLines.push('Aucune session cette semaine. Lance des exercices ! 🚀'); }
  const weeklyReport = reportLines.join('\n');

  // Daily XP for week chart
  const dayNames = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  const dayXP = [0,0,0,0,0,0,0];
  const sessionCounts = { 'math':0, 'french':0, 'science':0, 'histoire':0, 'geo':0 };
  sessions.forEach(s => {
    const d = new Date(s.created_at);
    const dayIdx = (d.getDay() + 6) % 7;
    dayXP[dayIdx] += s.xp_earned || 0;
    if (s.subject === 'math') sessionCounts.math++;
    else if (s.subject === 'french') sessionCounts.french++;
    else if (s.subject === 'science') sessionCounts.science++;
    else sessionCounts.geo++;
  });

  const sessionRows = sessions.slice(0, 10).map(s => {
    const date = new Date(s.created_at);
    return `<tr>
      <td>${date.toLocaleDateString('fr-FR', {day:'numeric',month:'short'})}</td>
      <td>${s.subject}${s.category ? ' ('+s.category+')' : ''}</td>
      <td>${s.score}/${s.total_questions}</td>
      <td>+${s.xp_earned || 0} XP</td>
    </tr>`;
  }).join('');

  // Build chart data as JSON for Chart.js init
  const chartData = JSON.stringify({
    subjectLabels: Object.keys(subjectScores).filter(k => subjectScores[k] > 0),
    subjectValues: Object.values(subjectScores).filter(v => v > 0),
    weekLabels: dayNames,
    weekXP: dayXP,
    sessionCounts: Object.values(sessionCounts)
  });

  return `<div class="module-header screen-transition">
    <button class="back-btn" onclick="screen='home';render();" style="font-size:1rem;">⬅️</button>
    <h2 class="module-title" style="color:#7c3aed;">📊 Tableau de Bord</h2>
    <span style="font-size:1.2rem;">👨‍👩‍👧</span>
  </div>

  <div class="card">
    <h3 style="font-weight:900;margin-bottom:15px;">👧 Résumé d'Émilie</h3>
    <div class="trophies-grid" style="grid-template-columns: repeat(4,1fr);">
      <div class="trophy-card"><div class="trophy-value">${totalXp}</div><div class="trophy-label">XP Total</div></div>
      <div class="trophy-card"><div class="trophy-value">Niv.${lvl}</div><div class="trophy-label">Niveau</div></div>
      <div class="trophy-card"><div class="trophy-value">${starCount}</div><div class="trophy-label">⭐ Étoiles</div></div>
      <div class="trophy-card"><div class="trophy-value">${badgeCount}</div><div class="trophy-label">🏅 Badges</div></div>
    </div>
    <div style="display:flex;justify-content:space-around;margin-top:12px;font-size:0.9rem;flex-wrap:wrap;gap:4px;">
      <span>🔥 ${streakDays} jours de suite</span>
      <span>📝 ${totalEx} exercices</span>
      ${favGame ? `<span>🎮 Préféré : ${favGame[0]}</span>` : ''}
    </div>
  </div>

  <div class="card" style="padding:15px;">
    <h3 style="font-weight:900;margin-bottom:8px;">📈 Score par matière</h3>
    <canvas id="subjectChart" height="180"></canvas>
  </div>

  <div class="card" style="padding:15px;">
    <h3 style="font-weight:900;margin-bottom:8px;">📊 Activité hebdomadaire (XP)</h3>
    <canvas id="weekChart" height="150"></canvas>
  </div>

  <div class="card" style="padding:15px;">
    <h3 style="font-weight:900;margin-bottom:8px;">🕒 Répartition des sessions</h3>
    <canvas id="pieChart" height="150"></canvas>
  </div>

  <div class="card">
    <h3 style="font-weight:900;margin-bottom:12px;">📋 Rapport hebdomadaire</h3>
    <div style="background:#f8f9fa;border-radius:12px;padding:14px;font-size:0.9rem;line-height:1.6;white-space:pre-wrap;text-align:left;">${weeklyReport}</div>
    <button class="btn-reward" style="margin-top:10px;font-size:0.85rem;background:#6b7280;" onclick="copyReport()">📋 Copier le rapport</button>
  </div>

  <div class="card" style="overflow-x:auto;">
    <h3 style="font-weight:900;margin-bottom:12px;">🕐 Dernières sessions</h3>
    ${sessions.length ? `<table style="width:100%;border-collapse:collapse;font-size:0.85rem;">
      <thead><tr style="border-bottom:2px solid #eee;"><th style="text-align:left;padding:6px;">Date</th><th style="text-align:left;">Matière</th><th style="text-align:left;">Score</th><th style="text-align:left;">XP</th></tr></thead>
      <tbody>${sessionRows}</tbody>
    </table>` : `<p class="empty-msg">Aucune session pour l'instant</p>`}
  </div>

  <div class="card">
    <h3 style="font-weight:900;margin-bottom:12px;">📋 Plan du jour</h3>
    <div style="display:flex;flex-direction:column;gap:8px;">
      <p style="font-size:0.85rem;color:#666;">Choisis les activités du plan du jour :</p>
      <div style="display:flex;flex-wrap:wrap;gap:6px;" id="planConfigItems">
        ${['🔢 Calcul', '📖 Lecture', '✏️ Dictée', '🔣 Conjugaison', '🧩 Problèmes', '📐 Géométrie', '🌍 Géo', '🏰 Histoire', '🎮 Mini-jeu', '🎵 Poésie'].map(a => {
          const checked = dailyPlan.activites.includes(a) || dailyPlan.ordre.includes(a.split(' ')[1] || a);
          return `<label style="background:${checked ? '#dbeafe' : '#f3f4f6'};padding:6px 12px;border-radius:20px;font-size:0.85rem;cursor:pointer;display:flex;align-items:center;gap:4px;">
            <input type="checkbox" ${checked ? 'checked' : ''} onchange="togglePlanActivity('${a}')" style="accent-color:#3b82f6;">
            ${a}
          </label>`;
        }).join('')}
      </div>
      <button class="btn-reward" style="background:#3b82f6;font-size:0.85rem;margin-top:6px;" onclick="saveDailyPlan()">💾 Sauvegarder le plan</button>
      ${dailyPlan.activites.length > 0 ? `<div style="font-size:0.85rem;margin-top:4px;">✅ Plan actif (${dailyPlan.activites.length} activités, ${dailyPlan.complete.length} faites)</div>` : ''}
    </div>
  </div>

  <div class="card">
    <h3 style="font-weight:900;margin-bottom:12px;">⚙️ Paramètres enfant</h3>
    <div style="display:flex;flex-direction:column;gap:12px;">
      ${makeToggle('Délai anti-clic', 'antiClick', getSetting('antiClick', true))}
      ${makeToggle('Pause étoiles', 'pauseEtoiles', getSetting('pauseEtoiles', true))}
      ${makeToggle('Audio', 'audio', getSetting('audio', true))}
      ${makeToggle('Mode calme', 'calm', calmMode)}
      ${makeToggle('Timer quiz', 'quizTimer', getSetting('quizTimer', true))}
      <div style="display:flex;align-items:center;gap:12px;">
        <span style="flex:1;font-weight:700;">🗣️ Vitesse lecture : ${getSetting('speechRate', 0.85)}</span>
        <input type="range" min="0.5" max="1.2" step="0.05" value="${getSetting('speechRate', 0.85)}"
          onchange="setSetting('speechRate', parseFloat(this.value));slowSpeech=parseFloat(this.value)<0.7;render();"
          style="flex:1;">
      </div>
    </div>
  </div>

  <div class="card" style="text-align:center;">
    <button class="btn-reward" style="background:#7c3aed;" onclick="resetProgress()">
      🔄 Réinitialiser la progression
    </button>
    <p style="font-size:0.75rem;color:#999;margin-top:8px;">Cette action est irréversible.</p>
  </div>

  <div style="text-align:center;padding:16px;color:#999;">
    🐿️🪼🦭 Émilie CE1 • Données synchronisées Supabase
  </div>
  <div id="chartDataContainer" style="display:none;" data-chart='${chartData}'></div>`;
}

function makeToggle(label, key, active) {
  return `<div style="display:flex;align-items:center;gap:10px;">
    <span style="flex:1;font-weight:700;">${label}</span>
    <button class="btn-reward" style="background:${active ? '#16a34a' : '#6b7280'};font-size:0.8rem;padding:6px 18px;border:none;" onclick="toggleParentSetting('${key}')">
      ${active ? '✅ ON' : '⭕ OFF'}
    </button>
  </div>`;
}

function toggleParentSetting(key) {
  if (key === 'calm') { toggleCalmMode(); return; }
  if (key === 'audio') { muted = !muted; document.getElementById('muteBtn').textContent = muted ? '🔇' : '🔊'; }
  if (key === 'pauseEtoiles') pauseDuration = getSetting('pauseEtoiles', true) ? 8000 : 999999;
  if (key === 'antiClick') { /* handled via getSetting check */ }
  toggleSetting(key);
  render();
}

function copyReport() {
  const reportEl = document.querySelector('.card:nth-child(5) div:first-of-type');
  if (reportEl) {
    navigator.clipboard.writeText(reportEl.textContent).then(() => {
      showFeedback(true, 'Rapport copié dans le presse-papier ! 📋', '📋');
    });
  }
}

function drawParentalCharts() {
  if (typeof Chart === 'undefined') return;
  const container = document.getElementById('chartDataContainer');
  if (!container) return;
  const data = JSON.parse(container.dataset.chart);
  
  // Destroy existing charts if any
  if (window._subjectChart) { window._subjectChart.destroy(); }
  if (window._weekChart) { window._weekChart.destroy(); }
  if (window._pieChart) { window._pieChart.destroy(); }

  const colors = ['#4ECDC4', '#FF6B9D', '#C3A6FF', '#FFA552', '#95E1D3', '#FFE66D'];

  // Subject bar chart
  const ctx1 = document.getElementById('subjectChart');
  if (ctx1 && data.subjectLabels.length > 0) {
    window._subjectChart = new Chart(ctx1, {
      type: 'bar',
      data: {
        labels: data.subjectLabels,
        datasets: [{
          label: 'Score',
          data: data.subjectValues,
          backgroundColor: colors.slice(0, data.subjectLabels.length),
          borderRadius: 8,
        }]
      },
      options: {
        responsive: true, maintainAspectRatio: false,
        plugins: { legend: { display: false } },
        scales: { y: { beginAtZero: true, grid: { color: '#f0f0f0' } }, x: { grid: { display: false } } }
      }
    });
  }

  // Week line chart
  const ctx2 = document.getElementById('weekChart');
  if (ctx2) {
    window._weekChart = new Chart(ctx2, {
      type: 'line',
      data: {
        labels: data.weekLabels,
        datasets: [{
          label: 'XP',
          data: data.weekXP,
          borderColor: '#7c3aed',
          backgroundColor: 'rgba(124,58,237,0.1)',
          fill: true, tension: 0.3,
          pointBackgroundColor: '#7c3aed',
          pointRadius: 4,
        }]
      },
      options: {
        responsive: true, maintainAspectRatio: false,
        plugins: { legend: { display: false } },
        scales: { y: { beginAtZero: true, grid: { color: '#f0f0f0' } }, x: { grid: { display: false } } }
      }
    });
  }

  // Pie chart
  const ctx3 = document.getElementById('pieChart');
  if (ctx3 && data.sessionCounts.some(v => v > 0)) {
    const pieLabels = ['Maths', 'Français', 'Sciences', 'Géo/Histoire'];
    const pieData = data.sessionCounts;
    window._pieChart = new Chart(ctx3, {
      type: 'doughnut',
      data: {
        labels: pieLabels,
        datasets: [{
          data: pieData,
          backgroundColor: colors,
          borderWidth: 0,
        }]
      },
      options: {
        responsive: true, maintainAspectRatio: false,
        plugins: { legend: { position: 'bottom', labels: { font: { family: 'Nunito' } } } }
      }
    });
  }
}

function getBtnClass(c) {
  if (sel === null) return '';
  const ex = exercises[qIdx];
  if (JSON.stringify(c) === JSON.stringify(ex.a)) return 'correct';
  if (JSON.stringify(c) === JSON.stringify(sel)) return 'wrong';
  return '';
}

// === SKILL TOGGLE ===
function toggleSkill(el) {
  const section = el.parentElement;
  const lessons = section.querySelector('.skill-lessons');
  const arrow = el.querySelector('.skill-arrow');
  if (!lessons) return;
  const isHidden = lessons.style.display === 'none';
  lessons.style.display = isHidden ? 'block' : 'none';
  if (arrow) arrow.textContent = isHidden ? '▲' : '▼';
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
      else if (btn.dataset.action === 'decouvertes') { screen = 'decouvertes'; render(); }
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
    // Lire la première question
    setTimeout(() => {
      showReplayBtn(true);
      const firstEx = exercises[0];
      if (firstEx) readAloud(firstEx.q.replace(/<[^>]*>/g,''), 0.85);
    }, 600);
  }
}

function handleChoice(choice) {
    if (sel !== null || !buttonsEnabled) return;
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
    // XP Engine
    xpEngine.addCorrectAnswer(module === 'math' ? 'math' : module === 'french' ? 'french' : 'science');
    if (combo >= 3) xpEngine.addXp(5, module);
  } else {
    updateCombo(false);
    playWrongSound();
        showFeedback(correct);
    xpEngine.addWrongAnswer();
  }
  
  render();
  questionCount++;
  
  setTimeout(() => {
    if (qIdx + 1 >= exercises.length) {
      done = true;
      
      // XP Engine : session complete
      xpEngine.completeSession(module, 'quiz', score, exercises.length, 30);
      
      // Award badges (old system + xpEngine)
      if (module === 'math' && score >= 8 && !badges.includes('🏆 Super Mathématicien·ne !')) {
        badges.push('🏆 Super Mathématicien·ne !');
        showReward('🪼', 'Badge Mathématiques !', 'Tu es une vraie mathématicienne avec Bulle !');
        xpEngine.addBadge('math_master', 'Super Mathématicienne', '🪼');
      }
      if (module === 'french' && score >= 8 && !badges.includes('📚 Championne de Français !')) {
        badges.push('📚 Championne de Français !');
        showReward('🦭', 'Badge Français !', 'Câlin est impressionné par ta maîtrise du français !');
        xpEngine.addBadge('french_master', 'Championne de Français', '🦭');
      }
      if (module === 'science' && score >= 6 && !badges.includes('🔬 Petite Scientifique !')) {
        badges.push('🔬 Petite Scientifique !');
        showReward('🐿️', 'Badge Sciences !', 'Noisette découvre le monde avec toi !');
        xpEngine.addBadge('science_master', 'Petite Scientifique', '🐿️');
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
    if (questionCount > 0 && questionCount % 5 === 0) triggerPauseEtoiles();
    if (!done) { 
      delayEnableButtons('.choice-btn', 1500);
      showReplayBtn(true);
      // Lire la question suivante
      const nextEx = exercises[qIdx];
      if (nextEx) readAloud(nextEx.q.replace(/<[^>]*>/g,''), 0.85);
    }
  }, correct ? 1200 : 1500);
}

async function unlockParental() {
  const pin = document.getElementById('pin').value;
  const err = document.getElementById('error');
  if (pin === '1234') { 
    playBeep(600, 0.1, 'sine');
    // Load session data for dashboard
    try {
      window._parentalSessions = await supabaseService.getRecentSessions(50);
    } catch(e) {
      window._parentalSessions = [];
    }
    screen = 'parentalDashboard';
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

function drawWeeklyChart() {
  const canvas = document.getElementById('weeklyChart');
  if (!canvas) return;
  const p = xpEngine.progress || {};
  const ctx = canvas.getContext('2d');
  const w = canvas.width, h = canvas.height;
  const pad = { top: 20, bottom: 30, left: 30, right: 15 };
  const chartW = w - pad.left - pad.right;
  const chartH = h - pad.top - pad.bottom;

  ctx.clearRect(0, 0, w, h);

  const sessions = window._parentalSessions || [];
  const dayNames = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  const dayTotals = [0,0,0,0,0,0,0];
  sessions.forEach(s => {
    const d = new Date(s.created_at);
    const dayIdx = (d.getDay() + 6) % 7;
    dayTotals[dayIdx] += s.xp_earned || 0;
  });

  const maxVal = Math.max(...dayTotals, 1);
  const barW = Math.min(chartW / 7 - 8, 40);

  // Background grid
  ctx.strokeStyle = '#f0f0f0';
  ctx.lineWidth = 1;
  for (let i = 0; i <= 4; i++) {
    const y = pad.top + (chartH / 4) * i;
    ctx.beginPath();
    ctx.moveTo(pad.left, y);
    ctx.lineTo(w - pad.right, y);
    ctx.stroke();
  }

  // Bars
  dayTotals.forEach((v, i) => {
    const barH = (v / maxVal) * chartH;
    const x = pad.left + (chartW / 7) * i + (chartW / 7 - barW) / 2;
    const y = pad.top + chartH - barH;

    const gradient = ctx.createLinearGradient(x, y, x, pad.top + chartH);
    gradient.addColorStop(0, '#C3A6FF');
    gradient.addColorStop(1, '#7c3aed');
    ctx.fillStyle = gradient;
    ctx.beginPath();
    ctx.roundRect(x, y, barW, barH, [4, 4, 0, 0]);
    ctx.fill();

    // Label
    ctx.fillStyle = '#999';
    ctx.font = '10px Nunito';
    ctx.textAlign = 'center';
    ctx.fillText(dayNames[i] + ' ' + v + 'XP', pad.left + (chartW / 7) * i + (chartW / 7) / 2, h - 5);
  });
}

async function resetProgress() {
  if (!confirm('⚠️ Es-tu sûr de vouloir réinitialiser toute la progression d\'Émilie ? Cette action est irréversible.')) return;
  if (!confirm('⚠️ Confirme : toutes les étoiles, badges et XP seront perdus.')) return;
  playBeep(400, 0.3, 'sawtooth');
  try {
    await supabaseService.upsertProgress({
      total_xp: 0, level: 1, stars: 0, streak_days: 0,
      math_score: 0, french_score: 0, science_score: 0, discovery_score: 0,
      total_exercises: 0, correct_answers: 0
    });
    xpEngine.progress = null;
    xpEngine.badges = [];
    await xpEngine.init();
    updateProgressUI();
    showReward('🔄', 'Progression réinitialisée', 'Les données d\'Émilie ont été effacées.');
  } catch(e) {
    alert('Erreur lors de la réinitialisation. Vérifie la connexion Supabase.');
  }
}

function shuffle(arr) {
  return arr.sort(() => Math.random() - 0.5);
}

// === MODE NUIT ===
function toggleNightMode() {
  nightMode = !nightMode;
  localStorage.setItem('emilie_night_mode', nightMode ? 'true' : 'false');
  document.body.classList.toggle('night-mode', nightMode);
  playBeep(nightMode ? 400 : 600, 0.1, 'sine');
}

function toggleCalmMode() {
  calmMode = !calmMode;
  localStorage.setItem('emilie_calm_mode', calmMode ? 'true' : 'false');
  document.body.classList.toggle('calm-mode', calmMode);
  playBeep(calmMode ? 500 : 600, 0.1, 'sine');
  if (calmMode) {
    // Hide score/timer elements
    document.querySelectorAll('.badge-count, #mathProgress, .rocket-race-timer').forEach(el => {
      if (el) el.style.display = 'none';
    });
  }
}

function initCalmMode() {
  if (calmMode) document.body.classList.add('calm-mode');
}

// === ROUTINE VISUELLE ===
async function loadDailyPlan() {
  if (!supabase) return;
  try {
    const today = new Date().toISOString().split('T')[0];
    const { data } = await supabase.from('daily_plan')
      .select('*').eq('user_id', 'emilie').eq('date', today).single();
    if (data) {
      dailyPlan = {
        activites: data.activites || [],
        ordre: data.ordre || [],
        complete: data.complete || [],
        modeCalme: data.mode_calme || false
      };
      if (data.mode_calme && !calmMode) toggleCalmMode();
      routineActive = dailyPlan.ordre.length > 0;
    }
  } catch(e) {}
}

function completeActivity(index) {
  if (!dailyPlan.complete.includes(index)) {
    dailyPlan.complete.push(index);
    playCorrectSound();
    if (supabase) {
      supabase.from('daily_plan').update({ complete: dailyPlan.complete })
        .eq('user_id', 'emilie').eq('date', new Date().toISOString().split('T')[0]);
    }
    // Victory if all done
    if (dailyPlan.complete.length >= dailyPlan.activites.length) {
      setTimeout(() => {
        spawnConfetti(40);
        showReward('🎉', 'Bravo Emilie !', 'Tu as fini tout ton plan du jour ! Tu es une championne ! 🌟');
        playPerfectScore();
      }, 300);
    }
    updateProgressUI();
  }
}

// Plan du jour configuration (parental dashboard)
function togglePlanActivity(name) {
  const idx = dailyPlan.activites.indexOf(name);
  if (idx >= 0) {
    dailyPlan.activites.splice(idx, 1);
    dailyPlan.ordre = dailyPlan.ordre.filter(o => o !== name.split(' ')[1]);
  } else {
    dailyPlan.activites.push(name);
    dailyPlan.ordre.push(name);
  }
}

async function saveDailyPlan() {
  if (!supabase) return;
  const today = new Date().toISOString().split('T')[0];
  await supabase.from('daily_plan').upsert({
    user_id: 'emilie', date: today,
    activites: dailyPlan.activites,
    ordre: dailyPlan.ordre,
    complete: dailyPlan.complete,
    mode_calme: calmMode
  }, { onConflict: 'user_id,date' });
  routineActive = dailyPlan.activites.length > 0;
  localStorage.setItem('emilie_routine_active', routineActive);
  screen = 'home'; render();
}

function planHTML() {
  if (!routineActive || dailyPlan.activites.length === 0) return '';
  return `<div class="daily-plan">
    <div class="plan-header">📋 Mon Plan du Jour</div>
    ${dailyPlan.activites.map((act, i) => {
      const done = dailyPlan.complete.includes(i);
      const locked = routineActive && i > 0 && !dailyPlan.complete.includes(i - 1) && dailyPlan.complete.length < i;
      return `<div class="plan-item ${done ? 'done' : ''} ${locked ? 'locked' : ''}"
        onclick="${done || locked ? '' : "completeActivity(" + i + ")"}">
        <span class="plan-check">${done ? '✅' : (locked ? '🔒' : '⬜')}</span>
        <span class="plan-act">${act}</span>
        <span class="plan-time">5 min</span>
      </div>`;
    }).join('')}
  </div>`;
}

function initNightMode() {
  if (nightMode) document.body.classList.add('night-mode');
}

// === TIMER SVG GÉNÉRATEUR ===
function timerSVG(remaining, total, size = 56, stroke = 4) {
  const r = (size / 2) - stroke;
  const circ = 2 * Math.PI * r;
  const offset = circ * (1 - remaining / total);
  return `<div class="timer-ring-container" style="width:${size}px;height:${size}px;">
    <svg class="timer-ring" width="${size}" height="${size}">
      <circle class="timer-ring-bg" cx="${size/2}" cy="${size/2}" r="${r}"/>
      <circle class="timer-ring-fill" cx="${size/2}" cy="${size/2}" r="${r}"
        stroke-dasharray="${circ}" stroke-dashoffset="${offset}"
        style="${remaining/total < 0.25 ? 'stroke:#ef4444;' : remaining/total < 0.5 ? 'stroke:#f59e0b;' : ''}"/>
    </svg>
    <span class="timer-ring-text">${Math.ceil(remaining)}</span>
  </div>`;
}

// === QUIZ TIMER ===
function startQuizTimer(timeoutSeconds, onTimeout) {
  if (!getSetting('quizTimer', true)) return; // timer disabled
  clearQuizTimer();
  quizTimeTotal = timeoutSeconds;
  quizTimeLeft = timeoutSeconds;
  const timerEl = document.getElementById('quizTimerDisplay');
  if (timerEl) updateTimerDisplay();
  quizTimer = setInterval(() => {
    quizTimeLeft--;
    if (timerEl) updateTimerDisplay();
    if (quizTimeLeft <= 0) {
      clearQuizTimer();
      if (onTimeout) onTimeout();
    }
  }, 1000);
}

function clearQuizTimer() {
  if (quizTimer) { clearInterval(quizTimer); quizTimer = null; }
}

function updateTimerDisplay() {
  const el = document.getElementById('quizTimerDisplay');
  if (el) {
    el.innerHTML = timerSVG(quizTimeLeft, quizTimeTotal);
  }
}

function handleTimeout() {
  playWrongSound();
  showFeedback(false, 'Temps écoulé !', '⏰');
  // Auto-advance to next question
  if (screen === 'math' || screen === 'french' || screen === 'science') {
    if (qIdx + 1 >= exercises.length) {
      done = true;
      render();
    } else {
      qIdx++;
      sel = null;
      render();
    }
  } else if (challengeMode) {
    challengeState.answers.push({ correct: false, time: challengeState.timeTotal - quizTimeLeft });
    advanceChallenge();
  }
}

// === MODE DÉFI (rapide 20 calculs) ===
function startChallenge(mode = 'defi') {
  challengeMode = mode;
  module = 'math';
  const data = mathData.addition.concat(mathData.soustraction).concat(mathData.tables_ce1);
  const qs = shuffle(data).slice(0, 20);
  challengeState = {
    questions: qs,
    index: 0,
    answers: [],
    timeTotal: mode === 'rapide' ? 5 : 10,
    score: 0
  };
  screen = 'challenge';
  render();
}

function challengeHTML() {
  const c = challengeState;
  const q = c.questions[c.index];
  if (!q) return '';
  const timerHtml = timerSVG(c.timeTotal, c.timeTotal);
  const cls = module === 'math' ? 'math' : 'french';
  return `<div class="module-header screen-transition">
    <button class="back-btn" onclick="endChallenge()">✕</button>
    <h2 class="module-title math">⚡ Défi ${c.index+1}/${c.questions.length}</h2>
    <span class="badge-count badge-math">${c.score}/${c.index}</span>
  </div>
  <div class="card" style="text-align:center;padding:15px;">
    <div class="question-card" style="position:relative;">
      <span class="quiz-mascot swim">🪼</span>
      <span class="exercise-mascot swim" style="margin-bottom:15px;">🪼</span>
      <div id="quizTimerDisplay">${timerHtml}</div>
      <p style="font-size:1.5rem;margin:15px 0;">${q.q}</p>
    </div>
    <div class="choices grid2">
      ${q.c.map(c => `<button class="choice-btn" onclick="handleChallengeAnswer(this, '${c}', '${q.a}')">${c}</button>`).join('')}
    </div>
    <div class="mascot-tip"><em>🪼 Bulle : "Vite, réponds avant la fin du chrono !"</em></div>
  </div>`;
}

function handleChallengeAnswer(btn, chosen, answer) {
  const correct = String(chosen) === String(answer);
  if (correct) challengeState.score++;
  btn.classList.add(correct ? 'correct' : 'wrong');
  document.querySelectorAll('.choice-btn').forEach(b => b.disabled = true);
  if (correct) { playCorrectSound(); xpEngine.addCorrectAnswer('math'); }
  else { playWrongSound(); xpEngine.addWrongAnswer(); }
  challengeState.answers.push({ correct, time: challengeState.timeTotal - quizTimeLeft });
  setTimeout(advanceChallenge, correct ? 400 : 600);
}

function advanceChallenge() {
  challengeState.index++;
  clearQuizTimer();
  if (challengeState.index >= challengeState.questions.length) {
    endChallenge();
  } else {
    render();
    startQuizTimer(challengeState.timeTotal, handleTimeout);
  }
}

function endChallenge() {
  clearQuizTimer();
  const c = challengeState;
  const score = c.score;
  const total = c.questions.length;
  challengeMode = null;
  screen = 'trophy';
  const pct = score / total;
  if (pct >= 1) showVictory('🌟', 'Défi Réussi !', `${score}/${total} bonnes réponses`, `+${score * 10} XP`);
  else if (pct >= 0.7) showReward('🪼', `Score: ${score}/${total}`, 'Continue à t\'entraîner, tu progresses !');
  xpEngine.completeSession('math', 'challenge', score, total, c.timeTotal * total);
  render();
}

// === INIT ===
document.addEventListener('DOMContentLoaded', async () => {
  createFloatingAnimals();
  
  // Init XP Engine
  await xpEngine.init();
  updateProgressUI();
  
  // Init night mode
  initNightMode();
  
  // Init calm mode
  initCalmMode();
  
  // Load daily plan
  await loadDailyPlan();
  
  // Preload speech synthesis voices
  if (window.speechSynthesis) window.speechSynthesis.getVoices();
  
  // Welcome message
  setTimeout(() => {
    showFeedback(true, 'Bienvenue Emilie ! 🐿️🪼🦭 Noisette, Bulle et Câlin sont là pour t\'aider !', '🌟');
  }, 800);
});

render();
