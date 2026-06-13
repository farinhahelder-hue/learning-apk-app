// === STATE ===
let stars = 0;
let badges = [];
let screen = 'home';
let xp = 0;
let level = 1;
let streak = 1;
let combo = 0;
let muted = false;

// === LOCALSTORAGE PERSISTENCE (Fix BUG #8) ===
const STORAGE_KEY = 'emilieAppProgress';

function saveProgress() {
  try {
    const data = {
      stars,
      badges,
      xp,
      level,
      streak,
      dailyChallengeCompleted: dailyChallenge.completed,
      stickerAlbum: stickerAlbum,
      lastPlayed: new Date().toISOString()
    };
    localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
  } catch (e) {
    console.log('Could not save progress:', e);
  }
}

function loadProgress() {
  try {
    const saved = localStorage.getItem(STORAGE_KEY);
    if (saved) {
      const data = JSON.parse(saved);
      stars = data.stars || 0;
      badges = data.badges || [];
      xp = data.xp || 0;
      level = data.level || 1;
      streak = data.streak || 1;
      
      // Load sticker album
      if (data.stickerAlbum) {
        stickerAlbum = data.stickerAlbum;
        // Restore timer interval if needed
        if (rocketGame.timerInterval) {
          clearInterval(rocketGame.timerInterval);
          rocketGame.timerInterval = null;
        }
      }
      
      // Check if it's a new day for daily challenge
      const lastPlayed = data.lastPlayed ? new Date(data.lastPlayed) : null;
      const today = new Date();
      if (!lastPlayed || lastPlayed.toDateString() !== today.toDateString()) {
        dailyChallenge.completed = false;
      } else {
        dailyChallenge.completed = data.dailyChallengeCompleted || false;
      }
    }
  } catch (e) {
    console.log('Could not load progress:', e);
  }
}

// === MINI-GAMES STATE ===
let rocketGame = {
  active: false,
  questions: [],
  currentQ: 0,
  score: 0,
  emilieProgress: 0,
  bulleProgress: 0,
  timeLeft: 60,
  timerInterval: null,
  transitioning: false // Fix BUG #1: prevent premature game end during transitions
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
  rocketGame.transitioning = false; // Reset transition flag
  
  screen = 'rocketRace';
  playBeep(800, 0.2, 'sine');
  render();
  
  // Start timer
  rocketGame.timerInterval = setInterval(() => {
    // Fix BUG #1: Don't end game during question transition
    if (rocketGame.transitioning) return;
    
    rocketGame.timeLeft--;
    updateRocketTimer();
    if (rocketGame.timeLeft <= 0 && !rocketGame.transitioning) {
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
  
  // Fix BUG #1: Set transitioning flag to prevent timer from ending game
  rocketGame.transitioning = true;
  
  setTimeout(() => {
    rocketGame.currentQ++;
    rocketGame.transitioning = false; // Clear transition flag
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
      // Fix BUG #8: Save progress after sticker unlock
      saveProgress();
    }
    
    // Complete daily challenge if applicable
    if (dailyChallenge.title === 'Course de Fusées' && !dailyChallenge.completed) {
      dailyChallenge.completed = true;
      addStars(3);
      spawnConfetti(15);
      // Fix BUG #8: Save progress after daily challenge completion
      saveProgress();
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
  
  // Update UI
  document.getElementById('totalStars').textContent = stars;
  
  // Level up check
  if (xp >= level * 100) {
    level++;
    if (!badges.includes('🏆 Niveau ' + level + ' !')) badges.push('🏆 Niveau ' + level + ' !');
    document.getElementById('totalBadges').textContent = badges.length;
    document.getElementById('levelDisplay').textContent = 'Niv.' + level;
    playLevelUp();
    showReward('🐿️🪼🦭', 'Niveau ' + level + ' !',
      'Tu as gagné un nouveau badge ! Les animaux sont fous de joie ! 🎉');
    spawnConfetti(20);
  }
  
  // XP bar
  const pct = Math.min(((xp % 100) / 100) * 100, 100);
  document.getElementById('xpBar').style.width = pct + '%';
  document.getElementById('xpText').textContent = (xp % 100) + ' / 100 XP';
  
  // Fix BUG #8: Save progress after state change
  saveProgress();
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
  else if (screen === 'math' || screen === 'french' || screen === 'science') {
    if (done) app.innerHTML = resultHTML();
    else app.innerHTML = quizHTML();
  } else if (screen === 'trophy') app.innerHTML = trophyHTML();
  else if (screen === 'parental') app.innerHTML = parentalHTML();
  // Fix BUG #7: Add parentalDashboard screen
  else if (screen === 'parentalDashboard') app.innerHTML = parentalDashboardHTML();
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
      <span class="badge-count badge-math" id="mathProgress">0/10</span>
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
  // Fix BUG #6: Remove PIN display from UI - security issue
  return `<div class="card parental-lock screen-transition">
    <div style="font-size:40px;margin-bottom:16px">👨‍👩‍👧</div>
    <h2 style="font-size:22px;font-weight:900;margin-bottom:8px">Espace Parents</h2>
    <p style="color:#9ca3af;font-size:14px;margin-bottom:16px">Entre le code parental pour accéder aux statistiques</p>
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

// Fix BUG #7: Add parentalDashboardHTML function
function parentalDashboardHTML() {
  return `<div class="module-header screen-transition">
    <button class="back-btn" data-action="back">⬅️</button>
    <h2 class="module-title" style="color: #8b5cf6;">👨‍👩‍👧 Espace Parents</h2>
  </div>
  
  <div class="card" style="background: linear-gradient(135deg, #8b5cf6, #7c3aed); color: white; text-align: center; margin-bottom: 16px;">
    <div style="font-size: 3rem; margin-bottom: 10px;">👨‍👩‍👧</div>
    <h3 style="margin-bottom: 5px;">Bienvenue dans l'Espace Parents</h3>
    <p style="opacity: 0.9; font-size: 0.9rem;">Gérez la progression d'Emilie en toute simplicité</p>
  </div>
  
  <div class="trophies-grid">
    <div class="trophy-card"><span class="trophy-icon">⭐</span><div class="trophy-value">${stars}</div><div class="trophy-label">étoiles</div></div>
    <div class="trophy-card"><span class="trophy-icon">🏅</span><div class="trophy-value">${badges.length}</div><div class="trophy-label">badges</div></div>
    <div class="trophy-card"><span class="trophy-icon">🎯</span><div class="trophy-value">Niv.${level}</div><div class="trophy-label">niveau</div></div>
    <div class="trophy-card"><span class="trophy-icon">🔥</span><div class="trophy-value">${streak}</div><div class="trophy-label">jours</div></div>
  </div>
  
  <div class="card">
    <h3 style="font-weight:900;margin-bottom:12px">📊 Progression par matière</h3>
    <div style="margin-bottom: 12px;">
      <div style="display: flex; justify-content: space-between; margin-bottom: 4px;">
        <span>🔢 Maths</span><span>${Math.round(stars * 0.4)} pts</span>
      </div>
      <div class="progress-bar"><div class="progress-fill progress-math" style="width: ${Math.min(stars * 0.4, 100)}%"></div></div>
    </div>
    <div style="margin-bottom: 12px;">
      <div style="display: flex; justify-content: space-between; margin-bottom: 4px;">
        <span>📖 Français</span><span>${Math.round(stars * 0.35)} pts</span>
      </div>
      <div class="progress-bar"><div class="progress-fill progress-french" style="width: ${Math.min(stars * 0.35, 100)}%"></div></div>
    </div>
    <div>
      <div style="display: flex; justify-content: space-between; margin-bottom: 4px;">
        <span>🔬 Sciences</span><span>${Math.round(stars * 0.25)} pts</span>
      </div>
      <div class="progress-bar"><div class="progress-fill progress-science" style="width: ${Math.min(stars * 0.25, 100)}%"></div></div>
    </div>
  </div>
  
  <div class="card">
    <h3 style="font-weight:900;margin-bottom:12px">🏅 Badges obtenus</h3>
    ${badges.length ? `<div class="badges-list">${badges.map(b => `<div class="badge-item">${b}</div>`).join('')}</div>` : `<p class="empty-msg">Aucun badge pour l'instant. Encourage Emilie !</p>`}
  </div>
  
  <div class="card" style="background: #f3f4f6;">
    <h3 style="font-weight:900;margin-bottom:12px">💡 Conseils pour les parents</h3>
    <p style="color: #666; font-size: 0.9rem; line-height: 1.6;">
      • Sessions recommandées : 10-15 minutes par jour<br>
      • Célébrez chaque badge obtenu — la motivation positive est clé<br>
      • Alterner les matières évite la monotonie<br>
      • En cas de difficulté, répéter les exercices de niveau 1
    </p>
  </div>
  
  <div style="text-align:center;padding:20px;font-size:1.5rem;">🐿️🪼🦭</div>`;
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
  if (sel) return;
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
  } else {
    updateCombo(false);
    playWrongSound();
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
      
      // Fix BUG #8: Save progress after badges are awarded
      saveProgress();
      
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
    // Fix BUG #7: Navigate to parentalDashboard instead of trophy
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

function shuffle(arr) {
  return arr.sort(() => Math.random() - 0.5);
}

// === INIT ===
document.addEventListener('DOMContentLoaded', () => {
  createFloatingAnimals();
  
  // Fix BUG #8: Load saved progress from localStorage
  loadProgress();
  
  // Welcome message
  setTimeout(() => {
    showFeedback(true, 'Bienvenue Emilie ! 🐿️🪼🦭 Noisette, Bulle et Câlin sont là pour t\'aider !', '🌟');
  }, 800);
});

render();
