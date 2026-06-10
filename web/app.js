// === STATE ===
let stars = 0;
let badges = [];
let screen = 'home';
let xp = 0;
let level = 1;
let streak = 1;
let combo = 0;
let muted = false;

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
// === SVG ICONS LIBRARY ===
const svgIcons = {
  // Math tables icons
  star: `<svg width="60" height="60" viewBox="0 0 60 60"><polygon points="30,5 37,22 55,22 41,35 47,52 30,42 13,52 19,35 5,22 23,22" fill="#FFEAA7" stroke="#F1C40F" stroke-width="2"/></svg>`,
  socks: `<svg width="60" height="60" viewBox="0 0 60 60"><path d="M15 10 Q15 5 20 5 L25 5 Q30 5 30 10 L30 35 Q30 45 40 50 L40 55 Q40 58 35 58 L20 58 Q15 58 15 55 L15 35 Z" fill="#FF6B6B" stroke="#C0392B" stroke-width="2"/><path d="M15 10 Q15 5 20 5 L25 5 Q30 5 30 10 L30 35 Q30 45 40 50 L40 55 Q40 58 35 58 L20 58 Q15 58 15 55 L15 35 Z" fill="#4ECDC4" stroke="#1ABC9C" stroke-width="2" transform="translate(8,0)"/></svg>`,
  clover: `<svg width="60" height="60" viewBox="0 0 60 60"><circle cx="30" cy="18" r="12" fill="#27AE60"/><circle cx="18" cy="28" r="12" fill="#27AE60"/><circle cx="42" cy="28" r="12" fill="#27AE60"/><circle cx="30" cy="40" r="12" fill="#27AE60"/><rect x="27" y="38" width="6" height="20" fill="#8B4513"/></svg>`,
  square: `<svg width="60" height="60" viewBox="0 0 60 60"><rect x="10" y="10" width="40" height="40" fill="#9B59B6" stroke="#8E44AD" stroke-width="3"/></svg>`,
  hand: `<svg width="60" height="60" viewBox="0 0 60 60"><path d="M30 55 Q20 55 15 45 L15 30 L20 30 L20 25 L25 25 L25 20 L30 20 L30 15 L35 15 L35 20 L40 20 L40 25 L45 25 L45 30 L50 30 L50 45 Q45 55 30 55" fill="#F39C12" stroke="#E67E22" stroke-width="2"/></svg>`,
  ten: `<svg width="60" height="60" viewBox="0 0 60 60"><rect x="5" y="20" width="10" height="10" fill="#3498DB" rx="2"/><rect x="18" y="20" width="10" height="10" fill="#3498DB" rx="2"/><rect x="31" y="20" width="10" height="10" fill="#3498DB" rx="2"/><rect x="44" y="20" width="10" height="10" fill="#3498DB" rx="2"/><rect x="5" y="33" width="10" height="10" fill="#3498DB" rx="2"/><rect x="18" y="33" width="10" height="10" fill="#3498DB" rx="2"/><rect x="31" y="33" width="10" height="10" fill="#3498DB" rx="2"/><rect x="44" y="33" width="10" height="10" fill="#3498DB" rx="2"/><text x="30" y="58" text-anchor="middle" fill="#2C3E50" font-size="14" font-weight="bold">×10</text></svg>`,
  // French icons
  book: `<svg width="60" height="60" viewBox="0 0 60 60"><rect x="10" y="10" width="40" height="40" fill="#E74C3C" rx="3"/><rect x="12" y="12" width="18" height="36" fill="#FADBD8"/><line x1="30" y1="12" x2="30" y2="48" stroke="#C0392B" stroke-width="2"/></svg>`,
  pencil: `<svg width="60" height="60" viewBox="0 0 60 60"><path d="M10 50 L45 15 L50 20 L15 55 Z" fill="#F1C40F" stroke="#F39C12" stroke-width="2"/><path d="M45 15 L50 20 L47 23 L42 18 Z" fill="#E74C3C"/></svg>`,
  letter: `<svg width="60" height="60" viewBox="0 0 60 60"><rect x="10" y="15" width="40" height="30" fill="#3498DB" rx="3"/><polygon points="10,15 30,35 50,15" fill="#2980B9"/></svg>`,
  // Science icons
  heart: `<svg width="60" height="60" viewBox="0 0 60 60"><path d="M30 55 C10 35 5 20 15 12 C25 5 30 15 30 20 C30 15 35 5 45 12 C55 20 50 35 30 55" fill="#E74C3C"/></svg>`,
  brain: `<svg width="60" height="60" viewBox="0 0 60 60"><ellipse cx="30" cy="30" rx="22" ry="18" fill="#F5B7B1" stroke="#E74C3C" stroke-width="2"/><path d="M20 25 Q25 20 30 25 Q35 20 40 25" fill="none" stroke="#C0392B" stroke-width="2"/><path d="M18 35 Q25 30 30 35 Q35 30 42 35" fill="none" stroke="#C0392B" stroke-width="2"/></svg>`,
  eye: `<svg width="60" height="60" viewBox="0 0 60 60"><ellipse cx="30" cy="30" rx="25" ry="15" fill="#FFF" stroke="#3498DB" stroke-width="3"/><circle cx="30" cy="30" r="10" fill="#2C3E50"/><circle cx="32" cy="28" r="3" fill="#FFF"/></svg>`,
  // World icons
  globe: `<svg width="60" height="60" viewBox="0 0 60 60"><circle cx="30" cy="30" r="25" fill="#3498DB" stroke="#2980B9" stroke-width="2"/><ellipse cx="30" cy="30" rx="10" ry="25" fill="none" stroke="#27AE60" stroke-width="2"/><ellipse cx="30" cy="30" rx="25" ry="8" fill="none" stroke="#27AE60" stroke-width="2"/></svg>`,
  rocket: `<svg width="60" height="60" viewBox="0 0 60 60"><path d="M30 5 Q45 15 45 35 L40 45 L30 40 L20 45 L15 35 Q15 15 30 5" fill="#BDC3C7" stroke="#7F8C8D" stroke-width="2"/><circle cx="30" cy="25" r="5" fill="#3498DB"/><path d="M20 45 L15 55 L25 50 Z" fill="#E74C3C"/><path d="M40 45 L45 55 L35 50 Z" fill="#E74C3C"/><path d="M25 40 L20 50 L30 45 Z" fill="#F1C40F"/></svg>`,
  pyramid: `<svg width="60" height="60" viewBox="0 0 60 60"><polygon points="30,10 50,50 10,50" fill="#F39C12" stroke="#E67E22" stroke-width="2"/><polygon points="30,10 35,30 25,30" fill="#F1C40F"/></svg>`,
  castle: `<svg width="60" height="60" viewBox="0 0 60 60"><rect x="15" y="30" width="30" height="25" fill="#95A5A6" stroke="#7F8C8D" stroke-width="2"/><rect x="10" y="20" width="8" height="35" fill="#7F8C8D"/><rect x="42" y="20" width="8" height="35" fill="#7F8C8D"/><rect x="25" y="40" width="10" height="15" fill="#8B4513"/><rect x="8" y="15" width="4" height="5" fill="#7F8C8D"/><rect x="14" y="15" width="4" height="5" fill="#7F8C8D"/><rect x="42" y="15" width="4" height="5" fill="#7F8C8D"/><rect x="48" y="15" width="4" height="5" fill="#7F8C8D"/></svg>`,
  sun: `<svg width="60" height="60" viewBox="0 0 60 60"><circle cx="30" cy="30" r="15" fill="#F1C40F"/><line x1="30" y1="5" x2="30" y2="12" stroke="#F39C12" stroke-width="3"/><line x1="30" y1="48" x2="30" y2="55" stroke="#F39C12" stroke-width="3"/><line x1="5" y1="30" x2="12" y2="30" stroke="#F39C12" stroke-width="3"/><line x1="48" y1="30" x2="55" y2="30" stroke="#F39C12" stroke-width="3"/><line x1="12" y1="12" x2="17" y2="17" stroke="#F39C12" stroke-width="3"/><line x1="43" y1="43" x2="48" y2="48" stroke="#F39C12" stroke-width="3"/><line x1="48" y1="12" x2="43" y2="17" stroke="#F39C12" stroke-width="3"/><line x1="17" y1="43" x2="12" y2="48" stroke="#F39C12" stroke-width="3"/></svg>`,
  planet: `<svg width="60" height="60" viewBox="0 0 60 60"><circle cx="30" cy="30" r="18" fill="#8E44AD"/><ellipse cx="30" cy="30" rx="28" ry="8" fill="none" stroke="#F39C12" stroke-width="3" transform="rotate(-20,30,30)"/></svg>`,
  tree: `<svg width="60" height="60" viewBox="0 0 60 60"><polygon points="30,5 45,35 15,35" fill="#27AE60"/><polygon points="30,15 42,40 18,40" fill="#2ECC71"/><rect x="25" y="40" width="10" height="15" fill="#8B4513"/></svg>`,
  flower: `<svg width="60" height="60" viewBox="0 0 60 60"><circle cx="30" cy="25" r="8" fill="#E74C3C"/><circle cx="22" cy="30" r="8" fill="#E74C3C"/><circle cx="38" cy="30" r="8" fill="#E74C3C"/><circle cx="25" cy="38" r="8" fill="#E74C3C"/><circle cx="35" cy="38" r="8" fill="#E74C3C"/><circle cx="30" cy="32" r="6" fill="#F1C40F"/><line x1="30" y1="40" x2="30" y2="55" stroke="#27AE60" stroke-width="3"/><ellipse cx="25" cy="50" rx="8" ry="4" fill="#2ECC71"/></svg>`,
  cat: `<svg width="60" height="60" viewBox="0 0 60 60"><ellipse cx="30" cy="38" rx="18" ry="15" fill="#F39C12"/><circle cx="30" cy="25" r="15" fill="#F39C12"/><polygon points="18,18 22,28 14,28" fill="#F39C12"/><polygon points="42,18 38,28 46,28" fill="#F39C12"/><circle cx="24" cy="24" r="3" fill="#2C3E50"/><circle cx="36" cy="24" r="3" fill="#2C3E50"/><ellipse cx="30" cy="30" rx="4" ry="3" fill="#E74C3C"/><path d="M26 34 Q30 38 34 34" fill="none" stroke="#2C3E50" stroke-width="2"/><path d="M10 35 Q5 30 8 25" fill="none" stroke="#F39C12" stroke-width="4"/><path d="M50 35 Q55 30 52 25" fill="none" stroke="#F39C12" stroke-width="4"/></svg>`,
  dog: `<svg width="60" height="60" viewBox="0 0 60 60"><ellipse cx="30" cy="40" rx="20" ry="15" fill="#D68910"/><circle cx="30" cy="25" r="15" fill="#D68910"/><ellipse cx="15" cy="20" rx="8" ry="12" fill="#A04000"/><ellipse cx="45" cy="20" rx="8" ry="12" fill="#A04000"/><circle cx="24" cy="24" r="3" fill="#2C3E50"/><circle cx="36" cy="24" r="3" fill="#2C3E50"/><ellipse cx="30" cy="32" rx="5" ry="4" fill="#2C3E50"/><ellipse cx="30" cy="55" rx="8" ry="5" fill="#D68910"/></svg>`,
  bird: `<svg width="60" height="60" viewBox="0 0 60 60"><ellipse cx="30" cy="35" rx="15" ry="12" fill="#3498DB"/><circle cx="35" cy="28" r="10" fill="#3498DB"/><circle cx="38" cy="26" r="2" fill="#2C3E50"/><polygon points="45,28 55,26 45,30" fill="#E74C3C"/><ellipse cx="20" cy="30" rx="10" ry="5" fill="#2980B9" transform="rotate(-30,20,30)"/><ellipse cx="40" cy="30" rx="10" ry="5" fill="#2980B9" transform="rotate(30,40,30)"/><path d="M25 47 L25 55 L28 55 L28 47" fill="#E74C3C"/><path d="M35 47 L35 55 L38 55 L38 47" fill="#E74C3C"/></svg>`,
  fish: `<svg width="60" height="60" viewBox="0 0 60 60"><ellipse cx="28" cy="30" rx="20" ry="12" fill="#E74C3C"/><polygon points="48,30 58,20 58,40" fill="#E74C3C"/><circle cx="18" cy="28" r="3" fill="#FFF"/><circle cx="18" cy="28" r="2" fill="#2C3E50"/><path d="M25 35 Q30 38 35 35" fill="none" stroke="#C0392B" stroke-width="2"/><ellipse cx="28" cy="22" rx="8" ry="4" fill="#EC7063" transform="rotate(-20,28,22)"/></svg>`,
  butterfly: `<svg width="60" height="60" viewBox="0 0 60 60"><ellipse cx="20" cy="25" rx="12" ry="15" fill="#9B59B6"/><ellipse cx="40" cy="25" rx="12" ry="15" fill="#9B59B6"/><ellipse cx="20" cy="42" rx="8" ry="10" fill="#8E44AD"/><ellipse cx="40" cy="42" rx="8" ry="10" fill="#8E44AD"/><ellipse cx="30" cy="32" rx="4" ry="18" fill="#2C3E50"/><circle cx="18" cy="22" r="4" fill="#F1C40F"/><circle cx="42" cy="22" r="4" fill="#F1C40F"/><path d="M28 14 Q25 8 22 5" fill="none" stroke="#2C3E50" stroke-width="2"/><path d="M32 14 Q35 8 38 5" fill="none" stroke="#2C3E50" stroke-width="2"/></svg>`,
  // Shapes for geometry
  triangle: `<svg width="60" height="60" viewBox="0 0 60 60"><polygon points="30,10 55,50 5,50" fill="#FF6B6B" stroke="#E74C3C" stroke-width="2"/></svg>`,
  circle: `<svg width="60" height="60" viewBox="0 0 60 60"><circle cx="30" cy="30" r="25" fill="#4ECDC4" stroke="#26A69A" stroke-width="2"/></svg>`,
  rectangle: `<svg width="60" height="60" viewBox="0 0 60 60"><rect x="8" y="18" width="44" height="24" fill="#45B7D1" stroke="#2980B9" stroke-width="2"/></svg>`,
  diamond: `<svg width="60" height="60" viewBox="0 0 60 60"><polygon points="30,5 55,30 30,55 5,30" fill="#DDA0DD" stroke="#9B59B6" stroke-width="2"/></svg>`,
  cube3d: `<svg width="60" height="60" viewBox="0 0 60 60"><polygon points="30,10 50,20 50,45 30,55 10,45 10,20" fill="#3498DB" stroke="#2980B9" stroke-width="2"/><polygon points="30,10 50,20 30,30 10,20" fill="#5DADE2"/><line x1="30" y1="30" x2="30" y2="55" stroke="#2471A3" stroke-width="2"/><line x1="10" y1="20" x2="30" y2="30" stroke="#2471A3" stroke-width="2"/><line x1="50" y1="20" x2="30" y2="30" stroke="#2471A3" stroke-width="2"/></svg>`,
  sphere3d: `<svg width="60" height="60" viewBox="0 0 60 60"><circle cx="30" cy="30" r="25" fill="#F39C12"/><ellipse cx="30" cy="30" rx="25" ry="8" fill="none" stroke="#E67E22" stroke-width="2"/><ellipse cx="30" cy="30" rx="8" ry="25" fill="none" stroke="#E67E22" stroke-width="2"/><ellipse cx="22" cy="22" rx="8" ry="5" fill="#F5B041" transform="rotate(-30,22,22)"/></svg>`,
  clock: `<svg width="60" height="60" viewBox="0 0 60 60"><circle cx="30" cy="30" r="26" fill="#FFF" stroke="#2C3E50" stroke-width="3"/><line x1="30" y1="30" x2="30" y2="14" stroke="#E74C3C" stroke-width="3"/><line x1="30" y1="30" x2="42" y2="30" stroke="#2C3E50" stroke-width="2"/><circle cx="30" cy="30" r="3" fill="#2C3E50"/><text x="28" y="10" font-size="6" fill="#2C3E50">12</text><text x="50" y="32" font-size="6" fill="#2C3E50">3</text><text x="28" y="54" font-size="6" fill="#2C3E50">6</text><text x="8" y="32" font-size="6" fill="#2C3E50">9</text></svg>`,
  thermometer: `<svg width="60" height="60" viewBox="0 0 60 60"><rect x="25" y="10" width="10" height="35" rx="5" fill="#ECF0F1" stroke="#BDC3C7" stroke-width="2"/><circle cx="30" cy="50" r="10" fill="#E74C3C"/><rect x="27" y="30" width="6" height="15" fill="#E74C3C"/><line x1="35" y1="15" x2="40" y2="15" stroke="#2C3E50" stroke-width="2"/><line x1="35" y1="25" x2="40" y2="25" stroke="#2C3E50" stroke-width="2"/><line x1="35" y1="35" x2="40" y2="35" stroke="#2C3E50" stroke-width="2"/><line x1="35" y1="45" x2="40" y2="45" stroke="#2C3E50" stroke-width="2"/></svg>`,
  balance: `<svg width="60" height="60" viewBox="0 0 60 60"><line x1="30" y1="15" x2="30" y2="55" stroke="#7F8C8D" stroke-width="3"/><line x1="10" y1="25" x2="50" y2="25" stroke="#7F8C8D" stroke-width="3"/><path d="M10 25 L5 35 L15 35 Z" fill="#95A5A6"/><path d="M50 25 L45 35 L55 35 Z" fill="#95A5A6"/><circle cx="30" cy="12" r="4" fill="#E74C3C"/></svg>`,
  // Human body
  body: `<svg width="60" height="60" viewBox="0 0 60 60"><circle cx="30" cy="12" r="8" fill="#FDEBD0"/><rect x="22" y="20" width="16" height="25" fill="#3498DB" rx="3"/><rect x="15" y="22" width="7" height="20" rx="3" fill="#FDEBD0"/><rect x="38" y="22" width="7" height="20" rx="3" fill="#FDEBD0"/><rect x="24" y="45" width="5" height="12" rx="2" fill="#2C3E50"/><rect x="31" y="45" width="5" height="12" rx="2" fill="#2C3E50"/><circle cx="26" cy="10" r="1" fill="#2C3E50"/><circle cx="34" cy="10" r="1" fill="#2C3E50"/><path d="M28 14 Q30 16 32 14" fill="none" stroke="#2C3E50" stroke-width="1"/></svg>`,
  lungs: `<svg width="60" height="60" viewBox="0 0 60 60"><ellipse cx="20" cy="35" rx="12" ry="18" fill="#F5B7B1" stroke="#E74C3C" stroke-width="2"/><ellipse cx="40" cy="35" rx="12" ry="18" fill="#F5B7B1" stroke="#E74C3C" stroke-width="2"/><path d="M20 25 Q20 15 25 15" fill="none" stroke="#C0392B" stroke-width="3"/><path d="M40 25 Q40 15 35 15" fill="none" stroke="#C0392B" stroke-width="3"/></svg>`,
  // Plant
  plant: `<svg width="60" height="60" viewBox="0 0 60 60"><rect x="27" y="35" width="6" height="20" fill="#8B4513"/><ellipse cx="30" cy="50" rx="15" ry="5" fill="#D4AC0D"/><ellipse cx="20" cy="28" rx="10" ry="15" fill="#27AE60" transform="rotate(-30,20,28)"/><ellipse cx="40" cy="28" rx="10" ry="15" fill="#2ECC71" transform="rotate(30,40,28)"/><ellipse cx="30" cy="20" rx="12" ry="15" fill="#27AE60"/><circle cx="30" cy="15" r="8" fill="#E74C3C"/><circle cx="28" cy="13" r="2" fill="#F1C40F"/></svg>`,
  seed: `<svg width="60" height="60" viewBox="0 0 60 60"><ellipse cx="30" cy="35" rx="8" ry="12" fill="#8B4513"/><path d="M30 23 Q32 18 30 15" fill="none" stroke="#27AE60" stroke-width="2"/><ellipse cx="30" cy="12" rx="5" ry="4" fill="#2ECC71"/></svg>`,
  // Weather
  cloud: `<svg width="60" height="60" viewBox="0 0 60 60"><ellipse cx="25" cy="35" rx="15" ry="12" fill="#BDC3C7"/><ellipse cx="40" cy="38" rx="12" ry="10" fill="#BDC3C7"/><ellipse cx="32" cy="28" rx="10" ry="8" fill="#ECF0F1"/><ellipse cx="22" cy="42" rx="8" ry="5" fill="#95A5A6"/></svg>`,
  rain: `<svg width="60" height="60" viewBox="0 0 60 60"><ellipse cx="30" cy="20" rx="18" ry="12" fill="#3498DB"/><ellipse cx="20" cy="25" rx="10" ry="8" fill="#5DADE2"/><line x1="20" y1="35" x2="18" y2="45" stroke="#3498DB" stroke-width="3" stroke-linecap="round"/><line x1="30" y1="35" x2="28" y2="48" stroke="#3498DB" stroke-width="3" stroke-linecap="round"/><line x1="40" y1="35" x2="38" y2="45" stroke="#3498DB" stroke-width="3" stroke-linecap="round"/></svg>`,
  snow: `<svg width="60" height="60" viewBox="0 0 60 60"><ellipse cx="30" cy="18" rx="15" ry="10" fill="#ECF0F1"/><line x1="30" y1="30" x2="30" y2="55" stroke="#BDC3C7" stroke-width="2"/><line x1="15" y1="45" x2="45" y2="45" stroke="#BDC3C7" stroke-width="2"/><line x1="30" y1="35" x2="20" y2="42" stroke="#BDC3C7" stroke-width="2"/><line x1="30" y1="35" x2="40" y2="42" stroke="#BDC3C7" stroke-width="2"/><circle cx="22" cy="50" r="4" fill="#FFF"/><circle cx="38" cy="52" r="3" fill="#FFF"/><circle cx="30" cy="48" r="3" fill="#FFF"/></svg>`,
  // Seasons
  spring: `<svg width="60" height="60" viewBox="0 0 60 60"><circle cx="30" cy="15" r="12" fill="#F1C40F"/><line x1="30" y1="3" x2="30" y2="0" stroke="#F39C12" stroke-width="3"/><line x1="42" y1="15" x2="48" y2="15" stroke="#F39C12" stroke-width="3"/><line x1="18" y1="15" x2="12" y2="15" stroke="#F39C12" stroke-width="3"/><path d="M30 30 Q25 35 30 40 Q35 35 30 30" fill="#E74C3C"/><path d="M25 32 Q22 35 25 38" fill="none" stroke="#27AE60" stroke-width="2"/><path d="M35 32 Q38 35 35 38" fill="none" stroke="#27AE60" stroke-width="2"/><ellipse cx="30" cy="55" rx="20" ry="5" fill="#2ECC71"/></svg>`,
  summer: `<svg width="60" height="60" viewBox="0 0 60 60"><circle cx="30" cy="30" r="20" fill="#F1C40F"/><line x1="30" y1="5" x2="30" y2="12" stroke="#F39C12" stroke-width="4"/><line x1="30" y1="48" x2="30" y2="55" stroke="#F39C12" stroke-width="4"/><line x1="5" y1="30" x2="12" y2="30" stroke="#F39C12" stroke-width="4"/><line x1="48" y1="30" x2="55" y2="30" stroke="#F39C12" stroke-width="4"/><line x1="12" y1="12" x2="17" y2="17" stroke="#F39C12" stroke-width="4"/><line x1="43" y1="43" x2="48" y2="48" stroke="#F39C12" stroke-width="4"/><line x1="48" y1="12" x2="43" y2="17" stroke="#F39C12" stroke-width="4"/><line x1="17" y1="43" x2="12" y2="48" stroke="#F39C12" stroke-width="4"/><path d="M15 55 Q30 50 45 55" fill="#3498DB"/></svg>`,
  autumn: `<svg width="60" height="60" viewBox="0 0 60 60"><path d="M30 10 Q35 20 30 30 Q25 20 30 10" fill="#E74C3C"/><path d="M25 15 Q30 25 25 35" fill="none" stroke="#C0392B" stroke-width="2"/><line x1="30" y1="30" x2="30" y2="55" stroke="#8B4513" stroke-width="3"/><ellipse cx="22" cy="50" rx="5" ry="3" fill="#F39C12"/><ellipse cx="38" cy="48" rx="6" ry="4" fill="#E67E22"/><ellipse cx="30" cy="52" rx="4" ry="3" fill="#D35400"/></svg>`,
  winter: `<svg width="60" height="60" viewBox="0 0 60 60"><circle cx="30" cy="15" r="10" fill="#BDC3C7"/><line x1="30" y1="25" x2="30" y2="55" stroke="#95A5A6" stroke-width="4"/><line x1="15" y1="35" x2="45" y2="35" stroke="#95A5A6" stroke-width="4"/><path d="M30 5 L30 0 M30 5 L25 2 M30 5 L35 2" stroke="#7F8C8D" stroke-width="2"/><path d="M50 15 L55 15 M50 15 L53 12 M50 15 L53 18" stroke="#7F8C8D" stroke-width="2"/><path d="M10 15 L5 15 M10 15 L7 12 M10 15 L7 18" stroke="#7F8C8D" stroke-width="2"/><path d="M30 65 L30 60 M30 65 L25 62 M30 65 L35 62" stroke="#7F8C8D" stroke-width="2"/><ellipse cx="25" cy="50" rx="4" ry="3" fill="#ECF0F1"/><ellipse cx="38" cy="48" rx="5" ry="3" fill="#ECF0F1"/></svg>`,
  // Water cycle
  watercycle: `<svg width="60" height="60" viewBox="0 0 60 60"><ellipse cx="30" cy="15" rx="20" ry="10" fill="#BDC3C7"/><path d="M15 15 Q10 20 15 25" fill="none" stroke="#3498DB" stroke-width="2" stroke-dasharray="3,2"/><path d="M45 15 Q50 20 45 25" fill="none" stroke="#3498DB" stroke-width="2" stroke-dasharray="3,2"/><path d="M30 30 L25 45" stroke="#3498DB" stroke-width="2"/><ellipse cx="22" cy="50" rx="12" ry="5" fill="#3498DB"/><path d="M10 50 Q30 45 50 50" fill="#5DADE2" opacity="0.5"/><line x1="30" y1="30" x2="30" y2="20" stroke="#3498DB" stroke-width="2" stroke-dasharray="3,2"/></svg>`,
  // Solar system
  solarsystem: `<svg width="60" height="60" viewBox="0 0 60 60"><circle cx="30" cy="30" r="8" fill="#F1C40F"/><circle cx="30" cy="30" r="6" fill="#E67E22"/><ellipse cx="30" cy="30" rx="15" ry="5" fill="none" stroke="#BDC3C7" stroke-width="1"/><circle cx="42" cy="30" r="3" fill="#3498DB"/><ellipse cx="30" cy="30" rx="22" ry="8" fill="none" stroke="#95A5A6" stroke-width="1"/><circle cx="52" cy="25" r="2" fill="#E74C3C"/><ellipse cx="30" cy="30" rx="30" ry="10" fill="none" stroke="#7F8C8D" stroke-width="1"/><circle cx="55" cy="35" r="4" fill="#9B59B6"/><circle cx="8" cy="20" r="2" fill="#E74C3C"/><circle cx="15" cy="45" r="1.5" fill="#F39C12"/></svg>`,
  // Volcano
  volcano: `<svg width="60" height="60" viewBox="0 0 60 60"><polygon points="30,15 55,55 5,55" fill="#7F8C8D"/><polygon points="30,15 40,25 20,25" fill="#5D6D7E"/><ellipse cx="30" cy="17" rx="6" ry="3" fill="#E74C3C"/><path d="M27 12 Q25 5 28 0" stroke="#E74C3C" stroke-width="3" fill="none"/><path d="M30 10 Q30 3 32 -2" stroke="#F39C12" stroke-width="2" fill="none"/><path d="M33 12 Q35 6 38 2" stroke="#E74C3C" stroke-width="2" fill="none"/><ellipse cx="20" cy="50" rx="4" ry="2" fill="#566573"/><ellipse cx="40" cy="48" rx="5" ry="2" fill="#566573"/></svg>`,
  // France map
  franmap: `<svg width="60" height="60" viewBox="0 0 60 60"><path d="M15 10 Q20 8 25 12 Q30 8 35 15 Q40 10 45 15 Q50 20 48 30 Q52 40 45 50 Q35 55 25 52 Q15 55 10 45 Q5 35 10 25 Q8 15 15 10" fill="#3498DB" stroke="#2980B9" stroke-width="2"/><text x="25" y="32" font-size="12" fill="#FFF" font-weight="bold">FR</text></svg>`,
  // Chronology
  timeline: `<svg width="60" height="60" viewBox="0 0 60 60"><line x1="5" y1="30" x2="55" y2="30" stroke="#2C3E50" stroke-width="3"/><circle cx="15" cy="30" r="5" fill="#E74C3C"/><circle cx="30" cy="30" r="5" fill="#F39C12"/><circle cx="45" cy="30" r="5" fill="#27AE60"/><text x="12" y="45" font-size="6" fill="#2C3E50">Préhistoire</text><text x="25" y="45" font-size="6" fill="#2C3E50">Antiquité</text><text x="40" y="45" font-size="6" fill="#2C3E50">Moyen-Âge</text></svg>`,
  // Fossil
  fossil: `<svg width="60" height="60" viewBox="0 0 60 60"><ellipse cx="30" cy="35" rx="25" ry="18" fill="#D5DBDB" stroke="#BDC3C7" stroke-width="2"/><path d="M15 30 Q20 25 25 30 Q30 35 35 30 Q40 25 45 30" fill="none" stroke="#7F8C8D" stroke-width="2"/><circle cx="22" cy="38" r="3" fill="#7F8C8D"/><circle cx="35" cy="40" r="4" fill="#7F8C8D"/><path d="M18 42 L25 42" stroke="#95A5A6" stroke-width="2"/><path d="M32 44 L42 44" stroke="#95A5A6" stroke-width="2"/></svg>`
};

// === MATH DATA ENRICHIE ===
const mathData = {
  // ── Addition ──
  addition: [
    {q:'🐿️ Noisette a 14 noisettes, elle en trouve 8 de plus. Combien en a-t-elle ?',c:[19,22,20,24],a:22,mascot:'bounce',svg:'star'},
    {q:'🪼 Bulle voit 25 étoiles, puis 13 de plus. Combien au total ?',c:[36,38,40,35],a:38,mascot:'swim',svg:'star'},
    {q:'🦭 Câlin nage 17 km, puis 9 km. Distance totale ?',c:[24,27,26,28],a:26,mascot:'wiggle',svg:'star'},
    {q:'🐿️ 32 + 15 = ?',c:[45,47,46,48],a:47,mascot:'bounce',svg:'star'},
    {q:'🪼 48 + 27 = ?',c:[73,74,75,76],a:75,mascot:'swim',svg:'star'},
    {q:'🐿️ 56 + 19 = ?',c:[74,75,76,73],a:75,mascot:'bounce',svg:'star'},
    {q:'🦭 63 + 28 = ?',c:[89,91,93,90],a:91,mascot:'wiggle',svg:'star'},
    {q:'🪼 37 + 46 = ?',c:[81,83,82,84],a:83,mascot:'swim',svg:'star'},
    {q:'🐿️ 24 + 59 = ?',c:[81,83,82,80],a:83,mascot:'bounce',svg:'star'},
    {q:'🦭 45 + 38 = ?',c:[81,83,82,84],a:83,mascot:'wiggle',svg:'star'},
    {q:'🐿️ 18 + 25 = ?',c:[41,43,44,42],a:43,mascot:'bounce',svg:'star'},
    {q:'🪼 33 + 47 = ?',c:[78,80,79,81],a:80,mascot:'swim',svg:'star'},
  ],
  
  // ── Soustraction ──
  soustraction: [
    {q:'🦭 Câlin avait 45 poissons, il en mange 18. Combien reste-t-il ?',c:[25,27,29,26],a:27,mascot:'wiggle',svg:'fish'},
    {q:'🐿️ 63 - 28 = ?',c:[33,35,37,34],a:35,mascot:'bounce',svg:'socks'},
    {q:'🪼 72 - 34 = ?',c:[36,38,40,37],a:38,mascot:'swim',svg:'socks'},
    {q:'🦭 85 - 37 = ?',c:[46,48,47,49],a:48,mascot:'wiggle',svg:'socks'},
    {q:'🐿️ 94 - 58 = ?',c:[34,36,35,37],a:36,mascot:'bounce',svg:'socks'},
    {q:'🪼 61 - 25 = ?',c:[34,36,35,37],a:36,mascot:'swim',svg:'socks'},
    {q:'🦭 78 - 39 = ?',c:[37,39,38,40],a:39,mascot:'wiggle',svg:'socks'},
    {q:'🐿️ 53 - 27 = ?',c:[24,26,25,27],a:26,mascot:'bounce',svg:'socks'},
    {q:'🐿️ Noisette a 42 noisettes, elle donne 15 à son ami. Combien lui en reste-t-il ?',c:[25,27,26,28],a:27,mascot:'bounce',svg:'socks'},
    {q:'🪼 Bulle voit 56 étoiles, 23 s\'éteignent. Combien restent-allumées ?',c:[31,33,34,32],a:33,mascot:'swim',svg:'socks'},
  ],
  
  // ── Table ×1 ──
  table_1: [
    {q:'🐿️ 1 × 1 = ? (l\'identité)',c:[1,2,0,3],a:1,mascot:'bounce',svg:'star'},
    {q:'🪼 Noisette a 1 sac avec 1 noisette. Combien en tout ?',c:[1,2,0,3],a:1,mascot:'swim',svg:'star'},
    {q:'🦭 Câlin mange 1 poisson par jour. En 1 jour, combien ?',c:[1,2,0,3],a:1,mascot:'wiggle',svg:'star'},
    {q:'🐿️ 1 × 2 = ?',c:[1,2,3,4],a:2,mascot:'bounce',svg:'star'},
    {q:'🪼 1 écureuil a 1 queue. Combien de queues en tout ?',c:[1,2,3,4],a:2,mascot:'swim',svg:'star'},
    {q:'🦭 1 phoque a 2 nageoires. Combien en tout ?',c:[1,2,3,4],a:2,mascot:'wiggle',svg:'star'},
    {q:'🐿️ 1 × 3 = ?',c:[2,3,4,5],a:3,mascot:'bounce',svg:'star'},
    {q:'🪼 Bulle voit 1 méduse avec 3 tentacules. Total ?',c:[2,3,4,5],a:3,mascot:'swim',svg:'star'},
    {q:'🦭 Câlin a 1 ami avec 3 poissons. Total ?',c:[2,3,4,5],a:3,mascot:'wiggle',svg:'star'},
    {q:'🐿️ 1 × 10 = ?',c:[5,10,15,20],a:10,mascot:'bounce',svg:'star'},
  ],
  
  // ── Table ×2 ──
  table_2: [
    {q:'🪼 Table de 2 : 2 × 1 = ?',c:[1,2,3,4],a:2,mascot:'swim',svg:'socks'},
    {q:'🐿️ Table de 2 : 2 × 2 = ?',c:[2,4,6,8],a:4,mascot:'bounce',svg:'socks'},
    {q:'🦭 Table de 2 : 2 × 3 = ?',c:[4,6,8,10],a:6,mascot:'wiggle',svg:'socks'},
    {q:'🪼 Table de 2 : 2 × 4 = ?',c:[6,8,10,12],a:8,mascot:'swim',svg:'socks'},
    {q:'🐿️ Table de 2 : 2 × 5 = ?',c:[8,10,12,14],a:10,mascot:'bounce',svg:'socks'},
    {q:'🦭 Table de 2 : 2 × 6 = ?',c:[10,12,14,16],a:12,mascot:'wiggle',svg:'socks'},
    {q:'🪼 Table de 2 : 2 × 7 = ?',c:[12,14,16,18],a:14,mascot:'swim',svg:'socks'},
    {q:'🐿️ Table de 2 : 2 × 8 = ?',c:[14,16,18,20],a:16,mascot:'bounce',svg:'socks'},
    {q:'🦭 Table de 2 : 2 × 9 = ?',c:[16,18,20,22],a:18,mascot:'wiggle',svg:'socks'},
    {q:'🪼 Table de 2 : 2 × 10 = ?',c:[18,20,22,24],a:20,mascot:'swim',svg:'socks'},
  ],
  
  // ── Table ×3 ──
  table_3: [
    {q:'🦭 Table de 3 : 3 × 1 = ?',c:[2,3,4,5],a:3,mascot:'wiggle',svg:'clover'},
    {q:'🪼 Table de 3 : 3 × 2 = ?',c:[4,6,8,9],a:6,mascot:'swim',svg:'clover'},
    {q:'🐿️ Table de 3 : 3 × 3 = ?',c:[6,9,12,15],a:9,mascot:'bounce',svg:'clover'},
    {q:'🦭 Table de 3 : 3 × 4 = ?',c:[9,12,15,18],a:12,mascot:'wiggle',svg:'clover'},
    {q:'🪼 Table de 3 : 3 × 5 = ?',c:[12,15,18,21],a:15,mascot:'swim',svg:'clover'},
    {q:'🐿️ Table de 3 : 3 × 6 = ?',c:[15,18,21,24],a:18,mascot:'bounce',svg:'clover'},
    {q:'🦭 Table de 3 : 3 × 7 = ?',c:[18,21,24,27],a:21,mascot:'wiggle',svg:'clover'},
    {q:'🪼 Table de 3 : 3 × 8 = ?',c:[21,24,27,30],a:24,mascot:'swim',svg:'clover'},
    {q:'🐿️ Table de 3 : 3 × 9 = ?',c:[24,27,30,33],a:27,mascot:'bounce',svg:'clover'},
    {q:'🦭 Table de 3 : 3 × 10 = ?',c:[27,30,33,36],a:30,mascot:'wiggle',svg:'clover'},
  ],
  
  // ── Table ×4 ──
  table_4: [
    {q:'🐿️ Table de 4 : 4 × 1 = ?',c:[3,4,5,6],a:4,mascot:'bounce',svg:'square'},
    {q:'🦭 Table de 4 : 4 × 2 = ?',c:[6,8,10,12],a:8,mascot:'wiggle',svg:'square'},
    {q:'🪼 Table de 4 : 4 × 3 = ?',c:[8,12,16,20],a:12,mascot:'swim',svg:'square'},
    {q:'🐿️ Table de 4 : 4 × 4 = ?',c:[12,16,20,24],a:16,mascot:'bounce',svg:'square'},
    {q:'🦭 Table de 4 : 4 × 5 = ?',c:[16,20,24,28],a:20,mascot:'wiggle',svg:'square'},
    {q:'🪼 Table de 4 : 4 × 6 = ?',c:[20,24,28,32],a:24,mascot:'swim',svg:'square'},
    {q:'🐿️ Table de 4 : 4 × 7 = ?',c:[24,28,32,36],a:28,mascot:'bounce',svg:'square'},
    {q:'🦭 Table de 4 : 4 × 8 = ?',c:[28,32,36,40],a:32,mascot:'wiggle',svg:'square'},
    {q:'🪼 Table de 4 : 4 × 9 = ?',c:[32,36,40,44],a:36,mascot:'swim',svg:'square'},
    {q:'🐿️ Table de 4 : 4 × 10 = ?',c:[36,40,44,48],a:40,mascot:'bounce',svg:'square'},
  ],
  
  // ── Table ×5 ──
  table_5: [
    {q:'🪼 Table de 5 : 5 × 1 = ?',c:[4,5,6,7],a:5,mascot:'swim',svg:'hand'},
    {q:'🐿️ Table de 5 : 5 × 2 = ?',c:[8,10,12,15],a:10,mascot:'bounce',svg:'hand'},
    {q:'🦭 Table de 5 : 5 × 3 = ?',c:[10,15,20,25],a:15,mascot:'wiggle',svg:'hand'},
    {q:'🪼 Table de 5 : 5 × 4 = ?',c:[15,20,25,30],a:20,mascot:'swim',svg:'hand'},
    {q:'🐿️ Table de 5 : 5 × 5 = ?',c:[20,25,30,35],a:25,mascot:'bounce',svg:'hand'},
    {q:'🦭 Table de 5 : 5 × 6 = ?',c:[25,30,35,40],a:30,mascot:'wiggle',svg:'hand'},
    {q:'🪼 Table de 5 : 5 × 7 = ?',c:[30,35,40,45],a:35,mascot:'swim',svg:'hand'},
    {q:'🐿️ Table de 5 : 5 × 8 = ?',c:[35,40,45,50],a:40,mascot:'bounce',svg:'hand'},
    {q:'🦭 Table de 5 : 5 × 9 = ?',c:[40,45,50,55],a:45,mascot:'wiggle',svg:'hand'},
    {q:'🪼 Table de 5 : 5 × 10 = ?',c:[45,50,55,60],a:50,mascot:'swim',svg:'hand'},
  ],
  
  // ── Table ×10 ──
  table_10: [
    {q:'🦭 Table de 10 : 10 × 1 = ?',c:[5,10,15,20],a:10,mascot:'wiggle',svg:'ten'},
    {q:'🪼 Table de 10 : 10 × 2 = ?',c:[10,20,30,40],a:20,mascot:'swim',svg:'ten'},
    {q:'🐿️ Table de 10 : 10 × 3 = ?',c:[20,30,40,50],a:30,mascot:'bounce',svg:'ten'},
    {q:'🦭 Table de 10 : 10 × 4 = ?',c:[30,40,50,60],a:40,mascot:'wiggle',svg:'ten'},
    {q:'🪼 Table de 10 : 10 × 5 = ?',c:[40,50,60,70],a:50,mascot:'swim',svg:'ten'},
    {q:'🐿️ Table de 10 : 10 × 6 = ?',c:[50,60,70,80],a:60,mascot:'bounce',svg:'ten'},
    {q:'🦭 Table de 10 : 10 × 7 = ?',c:[60,70,80,90],a:70,mascot:'wiggle',svg:'ten'},
    {q:'🪼 Table de 10 : 10 × 8 = ?',c:[70,80,90,100],a:80,mascot:'swim',svg:'ten'},
    {q:'🐿️ Table de 10 : 10 × 9 = ?',c:[80,90,100,110],a:90,mascot:'bounce',svg:'ten'},
    {q:'🦭 Table de 10 : 10 × 10 = ?',c:[90,100,110,120],a:100,mascot:'wiggle',svg:'ten'},
  ],
  
  // ── Tables CE2 (×6, ×7, ×8, ×9) ──
  tables_ce2: [
    {q:'🪼 Table de 6 : 6 × 1 = ?',c:[5,6,7,8],a:6,mascot:'swim',svg:'star'},
    {q:'🐿️ Table de 6 : 6 × 2 = ?',c:[10,12,14,16],a:12,mascot:'bounce',svg:'star'},
    {q:'🦭 Table de 6 : 6 × 3 = ?',c:[15,18,21,24],a:18,mascot:'wiggle',svg:'star'},
    {q:'🪼 Table de 6 : 6 × 4 = ?',c:[20,24,28,32],a:24,mascot:'swim',svg:'star'},
    {q:'🐿️ Table de 6 : 6 × 5 = ?',c:[25,30,35,40],a:30,mascot:'bounce',svg:'star'},
    {q:'🦭 Table de 6 : 6 × 6 = ?',c:[30,36,42,48],a:36,mascot:'wiggle',svg:'star'},
    {q:'🪼 Table de 6 : 6 × 7 = ?',c:[36,42,48,54],a:42,mascot:'swim',svg:'star'},
    {q:'🐿️ Table de 6 : 6 × 8 = ?',c:[42,48,54,60],a:48,mascot:'bounce',svg:'star'},
    {q:'🦭 Table de 6 : 6 × 9 = ?',c:[48,54,60,66],a:54,mascot:'wiggle',svg:'star'},
    {q:'🪼 Table de 6 : 6 × 10 = ?',c:[50,60,70,80],a:60,mascot:'swim',svg:'star'},
    {q:'🐿️ Table de 7 : 7 × 1 = ?',c:[6,7,8,9],a:7,mascot:'bounce',svg:'star'},
    {q:'🦭 Table de 7 : 7 × 2 = ?',c:[12,14,16,18],a:14,mascot:'wiggle',svg:'star'},
    {q:'🪼 Table de 7 : 7 × 3 = ?',c:[18,21,24,27],a:21,mascot:'swim',svg:'star'},
    {q:'🐿️ Table de 7 : 7 × 4 = ?',c:[24,28,32,36],a:28,mascot:'bounce',svg:'star'},
    {q:'🦭 Table de 7 : 7 × 5 = ?',c:[30,35,40,45],a:35,mascot:'wiggle',svg:'star'},
    {q:'🪼 Table de 7 : 7 × 6 = ?',c:[36,42,48,54],a:42,mascot:'swim',svg:'star'},
    {q:'🐿️ Table de 7 : 7 × 7 = ?',c:[42,49,56,63],a:49,mascot:'bounce',svg:'star'},
    {q:'🦭 Table de 7 : 7 × 8 = ?',c:[48,56,64,72],a:56,mascot:'wiggle',svg:'star'},
    {q:'🪼 Table de 7 : 7 × 9 = ?',c:[54,63,72,81],a:63,mascot:'swim',svg:'star'},
    {q:'🐿️ Table de 7 : 7 × 10 = ?',c:[60,70,80,90],a:70,mascot:'bounce',svg:'star'},
    {q:'🦭 Table de 8 : 8 × 1 = ?',c:[7,8,9,10],a:8,mascot:'wiggle',svg:'star'},
    {q:'🪼 Table de 8 : 8 × 2 = ?',c:[14,16,18,20],a:16,mascot:'swim',svg:'star'},
    {q:'🐿️ Table de 8 : 8 × 3 = ?',c:[21,24,27,30],a:24,mascot:'bounce',svg:'star'},
    {q:'🦭 Table de 8 : 8 × 4 = ?',c:[28,32,36,40],a:32,mascot:'wiggle',svg:'star'},
    {q:'🪼 Table de 8 : 8 × 5 = ?',c:[35,40,45,50],a:40,mascot:'swim',svg:'star'},
    {q:'🐿️ Table de 8 : 8 × 6 = ?',c:[42,48,54,60],a:48,mascot:'bounce',svg:'star'},
    {q:'🦭 Table de 8 : 8 × 7 = ?',c:[49,56,63,70],a:56,mascot:'wiggle',svg:'star'},
    {q:'🪼 Table de 8 : 8 × 8 = ?',c:[56,64,72,80],a:64,mascot:'swim',svg:'star'},
    {q:'🐿️ Table de 8 : 8 × 9 = ?',c:[63,72,81,90],a:72,mascot:'bounce',svg:'star'},
    {q:'🦭 Table de 8 : 8 × 10 = ?',c:[70,80,90,100],a:80,mascot:'wiggle',svg:'star'},
    {q:'🪼 Table de 9 : 9 × 1 = ?',c:[8,9,10,11],a:9,mascot:'swim',svg:'star'},
    {q:'🐿️ Table de 9 : 9 × 2 = ?',c:[16,18,20,22],a:18,mascot:'bounce',svg:'star'},
    {q:'🦭 Table de 9 : 9 × 3 = ?',c:[24,27,30,33],a:27,mascot:'wiggle',svg:'star'},
    {q:'🪼 Table de 9 : 9 × 4 = ?',c:[32,36,40,44],a:36,mascot:'swim',svg:'star'},
    {q:'🐿️ Table de 9 : 9 × 5 = ?',c:[40,45,50,55],a:45,mascot:'bounce',svg:'star'},
    {q:'🦭 Table de 9 : 9 × 6 = ?',c:[48,54,60,66],a:54,mascot:'wiggle',svg:'star'},
    {q:'🪼 Table de 9 : 9 × 7 = ?',c:[56,63,70,77],a:63,mascot:'swim',svg:'star'},
    {q:'🐿️ Table de 9 : 9 × 8 = ?',c:[64,72,80,88],a:72,mascot:'bounce',svg:'star'},
    {q:'🦭 Table de 9 : 9 × 9 = ?',c:[72,81,90,99],a:81,mascot:'wiggle',svg:'star'},
    {q:'🪼 Table de 9 : 9 × 10 = ?',c:[80,90,100,110],a:90,mascot:'swim',svg:'star'},
  ],
  
  // ── Géométrie ──
  géométrie: [
    {q:'🐿️ Combien de côtés a un carré ?',c:[3,4,5,6],a:4,mascot:'bounce',svg:'square'},
    {q:'🪼 Combien de côtés a un triangle ?',c:[2,3,4,5],a:3,mascot:'swim',svg:'triangle'},
    {q:'🦭 Un cercle a combien de côtés ?',c:[0,1,2,4],a:0,mascot:'wiggle',svg:'circle'},
    {q:'🐿️ Combien de côtés a un rectangle ?',c:[3,4,5,6],a:4,mascot:'bounce',svg:'rectangle'},
    {q:'🪼 Comment s\'appelle une forme avec 5 côtés ?',c:['carré','pentagone','hexagone','octogone'],a:'pentagone',mascot:'swim',svg:'diamond'},
    {q:'🦭 Comment s\'appelle une forme avec 6 côtés ?',c:['carré','pentagone','hexagone','octogone'],a:'hexagone',mascot:'wiggle',svg:'diamond'},
    {q:'🐿️ Un triangle a combien d\'angles ?',c:[2,3,4,5],a:3,mascot:'bounce',svg:'triangle'},
    {q:'🪼 Un carré a combien d\'angles droits ?',c:[2,3,4,5],a:4,mascot:'swim',svg:'square'},
    {q:'🐿️ Comment s\'appelle un carré en 3D ?',c:['cube','pyramide','sphère','cylindre'],a:'cube',mascot:'bounce',svg:'cube3d'},
    {q:'🪼 Quelle forme est la Terre ?',c:['carrée','plate','ronde','triangle'],a:'ronde',mascot:'swim',svg:'sphere3d'},
    {q:'🦭 Un losange a combien de côtés ?',c:[2,3,4,5],a:4,mascot:'wiggle',svg:'diamond'},
    {q:'🐿️ Combien de sommets a un triangle ?',c:[2,3,4,5],a:3,mascot:'bounce',svg:'triangle'},
    {q:'🪼 Un cube a combien de faces ?',c:[4,6,8,12],a:6,mascot:'swim',svg:'cube3d'},
    {q:'🦭 Quelle forme n\'a pas de côtés ?',c:['carré','triangle','cercle','hexagone'],a:'cercle',mascot:'wiggle',svg:'circle'},
    {q:'🐿️ Un rectangle a combien de côtés égaux ?',c:[2,4,0,8],a:2,mascot:'bounce',svg:'rectangle'},
  ],
  
  // ── Mesures ──
  mesures: [
    {q:'🪼 Quelle heure est-il sur cette horloge ? (aiguilles à 3 et 12)',c:['3h','6h','9h','12h'],a:'3h',mascot:'swim',svg:'clock'},
    {q:'🐿️ Quelle heure est-il ? (aiguilles à 6 et 12)',c:['3h','6h','9h','12h'],a:'6h',mascot:'bounce',svg:'clock'},
    {q:'🦭 Quelle heure est-il ? (aiguilles à 9 et 12)',c:['3h','6h','9h','12h'],a:'9h',mascot:'wiggle',svg:'clock'},
    {q:'🪼 Lequel est le plus long ? 🖐️ main ou 📏 règle',c:['main','règle','pareil','dépend'],a:'règle',mascot:'swim',svg:'hand'},
    {q:'🐿️ Nonisette mesure 2 crayons de long. Câlin mesure 3 crayons. Qui est plus grand ?',c:['Noisette','Câlin','Pareils','On ne sait pas'],a:'Câlin',mascot:'bounce',svg:'pencil'},
    {q:'🦭 L\'ours pèse 50 kg. Le lapin pèse 2 kg. Qui pèse le plus ?',c:['Ours','Lapin','Pareils','On ne sait pas'],a:'Ours',mascot:'wiggle',svg:'balance'},
    {q:'🪼 La température monte quand il fait... ?',c:['plus froid','plus chaud','pareil','mouillé'],a:'plus chaud',mascot:'swim',svg:'thermometer'},
    {q:'🐿️ Noisette a unthermomètre. Il montre 20°. Il fait... ?',c:['très froid','frais','chaud','très chaud'],a:'frais',mascot:'bounce',svg:'thermometer'},
    {q:'🦭 La petite aiguille montre le... ?',c:['minutes','secondes','heures','jours'],a:'heures',mascot:'wiggle',svg:'clock'},
    {q:'🪼 La grande aiguille montre le... ?',c:['heures','minutes','secondes','mois'],a:'minutes',mascot:'swim',svg:'clock'},
  ],
  
  // ── Logique et patterns ──
  logique: [
    {q:'🐿️ Quel nombre vient après ? 2, 4, 6, 8, ...',c:[9,10,11,12],a:10,mascot:'bounce',svg:'star'},
    {q:'🪼 Quel nombre vient après ? 5, 10, 15, 20, ...',c:[22,24,25,30],a:25,mascot:'swim',svg:'star'},
    {q:'🦭 Quel nombre vient après ? 10, 20, 30, 40, ...',c:[45,50,55,60],a:50,mascot:'wiggle',svg:'star'},
    {q:'🐿️ Complète : 3, 6, 9, 12, ...',c:[14,15,16,18],a:15,mascot:'bounce',svg:'star'},
    {q:'🪼 Quel nombre vient après ? 1, 3, 5, 7, ...',c:[8,9,10,11],a:9,mascot:'swim',svg:'star'},
    {q:'🦭 Trouve le nombre manquant : 2, 4, _, 8',c:[5,6,7,8],a:6,mascot:'wiggle',svg:'star'},
    {q:'🐿️ Trouve le nombre manquant : 5, _, 15, 20',c:[8,10,12,14],a:10,mascot:'bounce',svg:'star'},
    {q:'🪼 Quel nombre vient après ? 100, 200, 300, ...',c:[400,500,600,700],a:400,mascot:'swim',svg:'star'},
    {q:'🦭 Quelle est la suite ? 🔺🔺🔺🟦🟦🟦... ?',c:['🔺','🔺🔺','🟦','🟦🟦'],a:'🔺',mascot:'wiggle',svg:'triangle'},
    {q:'🐿️ Complète : 🔴🔴🔵🔴🔴🔵... ?',c:['🔴','🔵','🟢','🔴🔵'],a:'🔴',mascot:'bounce',svg:'square'},
  ],
  
  // ── Tables CE1 (×2, ×3, ×4, ×5, ×10) complètes ──
  tables_ce1: [
    {q:'🪼 Table de 2 : 2 × 1 = ?',c:[1,2,3,4],a:2,mascot:'swim',svg:'socks'},
    {q:'🐿️ Table de 2 : 2 × 2 = ?',c:[2,4,6,8],a:4,mascot:'bounce',svg:'socks'},
    {q:'🦭 Table de 2 : 2 × 3 = ?',c:[4,6,8,10],a:6,mascot:'wiggle',svg:'socks'},
    {q:'🪼 Table de 2 : 2 × 4 = ?',c:[6,8,10,12],a:8,mascot:'swim',svg:'socks'},
    {q:'🐿️ Table de 2 : 2 × 5 = ?',c:[8,10,12,14],a:10,mascot:'bounce',svg:'socks'},
    {q:'🦭 Table de 2 : 2 × 6 = ?',c:[10,12,14,16],a:12,mascot:'wiggle',svg:'socks'},
    {q:'🪼 Table de 2 : 2 × 7 = ?',c:[12,14,16,18],a:14,mascot:'swim',svg:'socks'},
    {q:'🐿️ Table de 2 : 2 × 8 = ?',c:[14,16,18,20],a:16,mascot:'bounce',svg:'socks'},
    {q:'🦭 Table de 2 : 2 × 9 = ?',c:[16,18,20,22],a:18,mascot:'wiggle',svg:'socks'},
    {q:'🪼 Table de 2 : 2 × 10 = ?',c:[18,20,22,24],a:20,mascot:'swim',svg:'socks'},
    {q:'🦭 Table de 3 : 3 × 1 = ?',c:[2,3,4,5],a:3,mascot:'wiggle',svg:'clover'},
    {q:'🪼 Table de 3 : 3 × 2 = ?',c:[4,6,8,9],a:6,mascot:'swim',svg:'clover'},
    {q:'🐿️ Table de 3 : 3 × 3 = ?',c:[6,9,12,15],a:9,mascot:'bounce',svg:'clover'},
    {q:'🦭 Table de 3 : 3 × 4 = ?',c:[9,12,15,18],a:12,mascot:'wiggle',svg:'clover'},
    {q:'🪼 Table de 3 : 3 × 5 = ?',c:[12,15,18,21],a:15,mascot:'swim',svg:'clover'},
    {q:'🐿️ Table de 4 : 4 × 1 = ?',c:[3,4,5,6],a:4,mascot:'bounce',svg:'square'},
    {q:'🦭 Table de 4 : 4 × 2 = ?',c:[6,8,10,12],a:8,mascot:'wiggle',svg:'square'},
    {q:'🪼 Table de 4 : 4 × 3 = ?',c:[8,12,16,20],a:12,mascot:'swim',svg:'square'},
    {q:'🐿️ Table de 4 : 4 × 4 = ?',c:[12,16,20,24],a:16,mascot:'bounce',svg:'square'},
    {q:'🦭 Table de 4 : 4 × 5 = ?',c:[16,20,24,28],a:20,mascot:'wiggle',svg:'square'},
    {q:'🪼 Table de 5 : 5 × 1 = ?',c:[4,5,6,7],a:5,mascot:'swim',svg:'hand'},
    {q:'🐿️ Table de 5 : 5 × 2 = ?',c:[8,10,12,15],a:10,mascot:'bounce',svg:'hand'},
    {q:'🦭 Table de 5 : 5 × 3 = ?',c:[10,15,20,25],a:15,mascot:'wiggle',svg:'hand'},
    {q:'🪼 Table de 5 : 5 × 4 = ?',c:[15,20,25,30],a:20,mascot:'swim',svg:'hand'},
    {q:'🐿️ Table de 5 : 5 × 5 = ?',c:[20,25,30,35],a:25,mascot:'bounce',svg:'hand'},
    {q:'🦭 Table de 10 : 10 × 1 = ?',c:[5,10,15,20],a:10,mascot:'wiggle',svg:'ten'},
    {q:'🪼 Table de 10 : 10 × 2 = ?',c:[10,20,30,40],a:20,mascot:'swim',svg:'ten'},
    {q:'🐿️ Table de 10 : 10 × 3 = ?',c:[20,30,40,50],a:30,mascot:'bounce',svg:'ten'},
    {q:'🦭 Table de 10 : 10 × 4 = ?',c:[30,40,50,60],a:40,mascot:'wiggle',svg:'ten'},
    {q:'🪼 Table de 10 : 10 × 5 = ?',c:[40,50,60,70],a:50,mascot:'swim',svg:'ten'},
    {q:'🐿️ Noisette a 3 sacs de 4 noisettes. Combien en tout ?',c:[10,12,14,8],a:12,mascot:'bounce',svg:'clover'},
    {q:'🪼 Bulle voit 5 groupes de 2 étoiles. Combien au total ?',c:[8,10,12,6],a:10,mascot:'swim',svg:'star'},
    {q:'🦭 Câlin range 4 rangées de 5 poissons. Combien en tout ?',c:[15,20,25,18],a:20,mascot:'wiggle',svg:'fish'},
    {q:'🐿️ 3 écureuils ont chacun 3 noisettes. Combien en tout ?',c:[6,9,12,15],a:9,mascot:'bounce',svg:'clover'},
    {q:'🪼 10 méduses ont chacune 2 tentacules. Combien en tout ?',c:[15,20,25,18],a:20,mascot:'swim',svg:'fish'},
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

// === ENRICHED FRENCH DATA ===
const frenchData = {
  // Phonétique - sons simples
  phonetique: [
    {q:'🦉 hibou → quel son entends-tu à la fin ?',c:['[ou]','[an]','[in]','[on]'],a:'[ou]',mascot:'wiggle',svg:'bird'},
    {q:'🐱 chat → quel son au début ?',c:['[a]','[ch]','[t]','[é]'],a:'[ch]',mascot:'bounce',svg:'cat'},
    {q:'🐟 poisson → quel son à la fin ?',c:['[on]','[oi]','[in]','[é]'],a:'[on]',mascot:'swim',svg:'fish'},
    {q:'🌳 forêt → quel son dans le mot ?',c:['[fé]','[ré]','[sé]','[ké]'],a:'[fé]',mascot:'bounce',svg:'tree'},
    {q:'🦊 renard → quel son au début ?',c:['[r]','[an]','[é]','[d]'],a:'[r]',mascot:'wiggle',svg:'dog'},
    {q:'🐰 lapin → quel son à la fin ?',c:['[an]','[in]','[on]','[un]'],a:'[an]',mascot:'bounce',svg:'dog'},
    {q:'🦋 papillon → quel son à la fin ?',c:['[on]','[ion]','[an]','[in]'],a:'[on]',mascot:'swim',svg:'butterfly'},
    {q:'🐸 grenouille → quel son au milieu ?',c:['[nou]','[nou]','[nou]','[nou]'],a:'[nou]',mascot:'wiggle',svg:'frog'},
    {q:'🐝 abeille → quel son au début ?',c:['[a]','[b]','[é]','[i]'],a:'[b]',mascot:'bounce',svg:'butterfly'},
    {q:'🦁 lion → quel son à la fin ?',c:['[on]','[ion]','[an]','[in]'],a:'[on]',mascot:'wiggle',svg:'dog'},
  ],
  
  // Lecture - histoires courtes
  lecture: [
    {q:'📖 Dans "Noisette l\'écureuil", que trouve Noisette pour se nourrir ?',c:['des pommes','des noisettes','des glands','des fruits'],a:'des noisettes',mascot:'bounce',svg:'tree'},
    {q:'🏫 Dans "Une journée à l\'école", où va Emilie le matin ?',c:['à la ferme','à l\'école','au cinéma','à la plage'],a:'à l\'école',mascot:'wiggle',svg:'book'},
    {q:'🌲 Dans "La forêt enchantée", que trouvent les enfants ?',c:['un dragon','une fée','un robot','un monstre'],a:'une fée',mascot:'swim',svg:'tree'},
    {q:'🐄 Dans "Les animaux de la ferme", quel animal fait "meuh" ?',c:['le canard','la vache','le cochon','le cheval'],a:'la vache',mascot:'bounce',svg:'dog'},
    {q:'🚀 Dans "L\'aventure dans l\'espace", comment s\'appelle la fusée ?',c:['Etoile','Boule','Lune','Aurore'],a:'Aurore',mascot:'wiggle',svg:'rocket'},
    {q:'🐿️ Noisette enterre des noisettes pour... ?',c:['jouer','les manger plus tard','les vendre','les échanger'],a:'les manger plus tard',mascot:'bounce',svg:'tree'},
    {q:'📚 À l\'école, Emilie apprend à... ?',c:['danser','lire et écrire','nager','piloter'],a:'lire et écrire',mascot:'wiggle',svg:'book'},
    {q:'🌟 Dans la forêt enchantée, les enfants découvrent... ?',c:['un trésor','des fleurs magiques','un lac','une montagne'],a:'des fleurs magiques',mascot:'swim',svg:'flower'},
    {q:'🐔 Quel animal pond des œufs à la ferme ?',c:['le chien','la vache','la poule','le chat'],a:'la poule',mascot:'bounce',svg:'bird'},
    {q:'🌙 Dans l\'espace, que voit Emilie depuis la fusée ?',c:['des voitures','des planètes','des maisons','des arbres'],a:'des planètes',mascot:'wiggle',svg:'planet'},
  ],
  
  // Orthographe - mots fréquents CE1
  orthographe: [
    {q:'🐿️ Comment écrit-on le mot "aussi" ?',c:['ausi','aussi','osì','auci'],a:'aussi',mascot:'bounce',svg:'pencil'},
    {q:'🪼 Quel est le bon mot : "avec" ou "avec" ?',c:['avec','avèc','avék','avê'],a:'avec',mascot:'swim',svg:'pencil'},
    {q:'🦭 Comment écrit-on "beaucoup" ?',c:['bEAUCOUP','bEauxCOUp','bcp','beaucou'],a:'beaucoup',mascot:'wiggle',svg:'pencil'},
    {q:'🐿️ Comment écrit-on "chez" ?',c:['ché','chéz','ché','chez'],a:'chez',mascot:'bounce',svg:'pencil'},
    {q:'🪼 Quel mot est correct : "comme" ou "com" ?',c:['com','comme','komm','comm'],a:'comme',mascot:'swim',svg:'pencil'},
    {q:'🦭 Comment écrit-on "alors" ?',c:['alor','allors','alors','alor'],a:'alors',mascot:'wiggle',svg:'pencil'},
    {q:'🐿️ Comment écrit-on "bien" ?',c:['bin','bien','byn','biene'],a:'bien',mascot:'bounce',svg:'pencil'},
    {q:'🪼 Le mot "grand" s\'écrit avec... ?',c:['1 lettre','4 lettres','5 lettres','6 lettres'],a:'5 lettres',mascot:'swim',svg:'pencil'},
    {q:'🦭 Comment écrit-on "petit" ?',c:['ptit','petit','pétit','petîte'],a:'petit',mascot:'wiggle',svg:'pencil'},
    {q:'🐿️ Le mot "main" contient... ?',c:['3 lettres','4 lettres','5 lettres','6 lettres'],a:'4 lettres',mascot:'bounce',svg:'pencil'},
    {q:'🪼 Comment écrit-on "maman" ?',c:['maman','mamam','maman','maman'],a:'maman',mascot:'swim',svg:'pencil'},
    {q:'🦭 Comment écrit-on "papa" ?',c:['papa','papà','papa','pappa'],a:'papa',mascot:'wiggle',svg:'pencil'},
    {q:'🐿️ Le mot "ami" s\'écrit... ?',c:['ami','amie','ammi','amii'],a:'ami',mascot:'bounce',svg:'pencil'},
    {q:'🪼 Comment écrit-on "jamais" ?',c:['jamais','jamè','jaméis','jamès'],a:'jamais',mascot:'swim',svg:'pencil'},
    {q:'🦭 Comment écrit-on "toujours" ?',c:['toujour','toujours','toujourz','toujour'],a:'toujours',mascot:'wiggle',svg:'pencil'},
  ],
  
  // Grammaire
  grammaire: [
    {q:'🐿️ Dans "Le chat mange", quel est le verbe ?',c:['chat','mange','le','un'],a:'mange',mascot:'bounce',svg:'cat'},
    {q:'🪼 Quel est le nom dans "Une fille joue" ?',c:['une','fille','joue','et'],a:'fille',mascot:'swim',svg:'book'},
    {q:'🦭 "Noisette est content." Quel mot est un adjectif ?',c:['Noisette','est','content','.'],a:'content',mascot:'wiggle',svg:'dog'},
    {q:'🐿️ Quelle majuscule manque ? "___emilie joue"',c:['e','a','i','E'],a:'E',mascot:'bounce',svg:'book'},
    {q:'🪼 Quel point manque à la fin ? "Il fait beau"',c:['.','?','!',':'],a:'.',mascot:'swim',svg:'book'},
    {q:'🦭 Dans "La petite fille", combien y a-t-il de noms ?',c:[1,2,3,4],a:2,mascot:'wiggle',svg:'book'},
    {q:'🐿️ "Le chien court." Quelle est la phrase ?',c:['nom','verbe','adjectif','phrase complète'],a:'phrase complète',mascot:'bounce',svg:'dog'},
    {q:'🪼 Quel article avant "arbre" ?',c:['le','la','un','une'],a:'le',mascot:'swim',svg:'tree'},
    {q:'🦭 "Elle chante." Quel pronom ?',c:['elle','chante','un','et'],a:'elle',mascot:'wiggle',svg:'book'},
    {q:'🐿️ Dans "grand", quelle est la dernière lettre ?',c:['a','d','n','r'],a:'d',mascot:'bounce',svg:'pencil'},
  ],
  
  // Conjugaison
  conjugaison: [
    {q:'🦭 Je _____ content. (être)',c:['est','suis','sommes','sont'],a:'suis',mascot:'wiggle',svg:'book'},
    {q:'🐿️ Tu _____ un livre. (avoir)',c:['ai','as','avons','avez'],a:'as',mascot:'bounce',svg:'book'},
    {q:'🪼 Il _____ à l\'école. (aller)',c:['va','vas','vais','allons'],a:'va',mascot:'swim',svg:'book'},
    {q:'🦭 Nous _____ dans le parc. (jouer)',c:['joue','joues','jouons','jouez'],a:'jouons',mascot:'wiggle',svg:'book'},
    {q:'🐿️ Vous _____ bien. (travailler)',c:['travaille','travailles','travaillons','travaillez'],a:'travaillez',mascot:'bounce',svg:'book'},
    {q:'🪼 Ils _____ football. (jouer)',c:['joue','joues','jouons','jouent'],a:'jouent',mascot:'swim',svg:'book'},
    {q:'🦭 Je _____ une histoire. (lire)',c:['lis','lit','lisons','lisez'],a:'lis',mascot:'wiggle',svg:'book'},
    {q:'🐿️ Tu _____ très vite. (courir)',c:['court','coures','cours','courent'],a:'cours',mascot:'bounce',svg:'book'},
    {q:'🪼 Elle _____ de la musique. (écouter)',c:['écoute','écoutes','écoutons','écoutez'],a:'écoute',mascot:'swim',svg:'book'},
    {q:'🦭 Nous _____ à la maison. (être)',c:['est','suis','sommes','sont'],a:'sommes',mascot:'wiggle',svg:'book'},
    {q:'🐿️ Tu _____ un cahier. (avoir)',c:['ai','as','avons','avez'],a:'as',mascot:'bounce',svg:'book'},
    {q:'🪼 Je _____ du pain. (manger)',c:['manges','mange','mangent','mangez'],a:'mange',mascot:'swim',svg:'book'},
  ],
  
  // Vocabulaire thématique
  vocabulaire_animations: [
    {q:'🐱 Comment appelle-t-on le petit du chat ?',c:['chiot','chatonnet','kitt','minou'],a:'chatonnet',mascot:'bounce',svg:'cat'},
    {q:'🐕 Comment appelle-t-on le petit du chien ?',c:['kidd','chiot','puppy','kit'],a:'chiot',mascot:'wiggle',svg:'dog'},
    {q:'🐦 Comment appelle-t-on le petit de l\'oiseau ?',c:['oiselet','petit','oisillon','baby'],a:'oisillon',mascot:'swim',svg:'bird'},
    {q:'🐟 Le poisson respire avec... ?',c:['des poumons','des branchies','une trompe','des ailes'],a:'des branchies',mascot:'bounce',svg:'fish'},
    {q:'🐇 Le lapin a des... ?',c:['plumes','écailles','poils','carapace'],a:'poils',mascot:'wiggle',svg:'dog'},
    {q:'🦋 Le papillon a... ailes ?',c:[2,4,6,8],a:4,mascot:'swim',svg:'butterfly'},
    {q:'🐝 L\'abeille fait du... ?',c:['nectar','miel','sucre','cire'],a:' miel',mascot:'bounce',svg:'butterfly'},
    {q:'🐸 La grenouille fait... ?',c:['miaou','ouik','cocorico','croac'],a:'croac',mascot:'wiggle',svg:'frog'},
    {q:'🐔 La poule fait... ?',c:['coin coin','meuh','cocorico','bêê'],a:'cocorico',mascot:'swim',svg:'bird'},
    {q:'🐄 La vache fait... ?',c:['miaou','meuh','houhou','bêê'],a:'meuh',mascot:'bounce',svg:'dog'},
  ],
  
  vocabulaire_ecole: [
    {q:'📚 Comment s\'appelle le livre où tu écris ?',c:['cahier','stylo','gomme','crayon'],a:'cahier',mascot:'bounce',svg:'book'},
    {q:'✏️ Comment s\'appelle l\'objet pour écrire ?',c:['gomme','crayon','cahier','tableau'],a:'crayon',mascot:'swim',svg:'pencil'},
    {q:'🧽 À quoi sert la gomme ?',c:['écrire','effacer','colorier','mesurer'],a:'effacer',mascot:'wiggle',svg:'pencil'},
    {q:'🎒 Comment s\'appelle le sac pour l\'école ?',c:['boîte','cartable','valise','sac vert'],a:'cartable',mascot:'bounce',svg:'book'},
    {q:'📋 Sur quoi écrit le maître ?',c:['table','chaise','tableau','sol'],a:'tableau',mascot:'swim',svg:'book'},
    {q:'🪑 Dans la classe, tu es assis sur une... ?',c:['table','chaise','lit','bureau'],a:'chaise',mascot:'wiggle',svg:'book'},
    {q:'⏰ Dans la classe, il y a une horloge pour... ?',c:['jouer','voir l\'heure','dessiner','chanter'],a:'voir l\'heure',mascot:'bounce',svg:'clock'},
    {q:'🧮 Comment s\'appelle l\'objet pour compter ?',c:['règle','calculatrice','crayon','gomme'],a:'calculatrice',mascot:'swim',svg:'book'},
  ],
  
  vocabulaire_famille: [
    {q:'👩 Ta mère c\'est ta... ?',c:['sœur','maman','fille','amie'],a:'maman',mascot:'bounce',svg:'body'},
    {q:'👨 Ton père c\'est ton... ?',c:['frère','papa','oncle','fils'],a:'papa',mascot:'wiggle',svg:'body'},
    {q:'👧 Ta _____ c\'est une fille dans ta famille.',c:['frère','sœur','cousin','oncle'],a:'sœur',mascot:'swim',svg:'body'},
    {q:'👦 Ton _____ c\'est un garçon dans ta famille.',c:['frère','sœur','tante','cousine'],a:'frère',mascot:'bounce',svg:'body'},
    {q:'👴 Le père de ton papa c\'est ton... ?',c:['oncle','grand-père','cousin','frère'],a:'grand-père',mascot:'wiggle',svg:'body'},
    {q:'👵 La mère de ta maman c\'est ta... ?',c:['tante','mamie','cousine','sœur'],a:'mamie',mascot:'swim',svg:'body'},
  ],
  
  vocabulaire_nature: [
    {q:'🌳 Comment s\'appelle un grand arbre ?',c:['fleur','buisson','arbre','plante'],a:'arbre',mascot:'bounce',svg:'tree'},
    {q:'🌻 Comment s\'appelle une fleur jaune ?',c:['rose','tulipe','marguerite','tournesol'],a:'tournesol',mascot:'swim',svg:'flower'},
    {q:'☀️ La nuit, où va le soleil ?',c:['dans la mer','sous la terre','il reste','personne ne sait'],a:'sous la terre',mascot:'wiggle',svg:'sun'},
    {q:'🌧️ Quand il pleut, les nuages... ?',c:['disparaissent','pleurent','brillent','dansent'],a:'pleurent',mascot:'bounce',svg:'cloud'},
    {q:'🌈 Quand il pleut et que le soleil revient, on voit... ?',c:['un bonhomme','un arc-en-ciel','une montagne','un lac'],a:'un arc-en-ciel',mascot:'swim',svg:'sun'},
    {q:'🍂 En automne, les feuilles... ?',c:['poussent','fleurissent','tombent','verdissent'],a:'tombent',mascot:'wiggle',svg:'tree'},
    {q:'❄️ En hiver, il fait... ?',c:['chaud','frais','froid','très chaud'],a:'froid',mascot:'bounce',svg:'snow'},
  ],
  
  vocabulaire_corps: [
    {q:'🧠 Avec quoi penses-tu ?',c:['le cœur','l\'estomac','le cerveau','les poumons'],a:'le cerveau',mascot:'bounce',svg:'brain'},
    {q:'❤️ Qu\'est-ce qui bat dans ta poitrine ?',c:['le foie','le cerveau','le cœur','l\'estomac'],a:'le cœur',mascot:'swim',svg:'heart'},
    {q:'👃 Avec quoi sens-tu les odeurs ?',c:['les oreilles','le nez','les yeux','la bouche'],a:'le nez',mascot:'wiggle',svg:'body'},
    {q:'👂 Avec quoi entends-tu ?',c:['les yeux','le nez','les oreilles','la bouche'],a:'les oreilles',mascot:'bounce',svg:'body'},
    {q:'👀 Avec quoi vois-tu ?',c:['la bouche','le nez','les yeux','les oreilles'],a:'les yeux',mascot:'swim',svg:'eye'},
    {q:'👅 Avec quoi goûtes-tu ?',c:['le nez','les oreilles','la langue','les yeux'],a:'la langue',mascot:'wiggle',svg:'body'},
    {q:'✋ Combien as-tu de doigts sur une main ?',c:[4,5,6,10],a:5,mascot:'bounce',svg:'hand'},
    {q:'🦶 Combien as-tu de pieds ?',c:[1,2,3,4],a:2,mascot:'swim',svg:'body'},
  ],
  
  // Default FRENCH for backward compatibility
  default: [
    {q:'🦭 Câlin pense à un animal de la mer qui a des pinces. C\'est un...',c:['requin','crabe','dauphin','méduse'],a:'crabe',mascot:'wiggle',svg:'fish'},
    {q:'🐿️ Comment s\'appelle la maison d\'un écureuil dans un arbre ?',c:['tanière','nid','terrier','grotte'],a:'nid',mascot:'bounce',svg:'tree'},
    {q:'🪼 Quel mot signifie le contraire de "chaud" ?',c:['tiède','doux','froid','chaud'],a:'froid',mascot:'swim',svg:'thermometer'},
    {q:'🦭 Lequel est un animal de la mer ?',c:['renard','phoque','lapin','écureuil'],a:'phoque',mascot:'wiggle',svg:'fish'},
    {q:'🐿️ Qu\'est-ce qu\'une forêt ?',c:['une petite fleur','un grand nombre d\'arbres','une montagne','une rivière'],a:'un grand nombre d\'arbres',mascot:'bounce',svg:'tree'},
    {q:'🦭 Je (manger) → Je...',c:['manges','mange','mangent','mangez'],a:'mange',mascot:'wiggle',svg:'book'},
    {q:'🐿️ Tu (courir) → Tu...',c:['courez','coures','cours','courent'],a:'cours',mascot:'bounce',svg:'book'},
    {q:'🪼 Elle (nager) → Elle...',c:['nagent','nage','nages','nagez'],a:'nage',mascot:'swim',svg:'book'},
    {q:'🦭 Nous (jouer) → Nous...',c:['jouons','jouez','jouent','joues'],a:'jouons',mascot:'wiggle',svg:'book'},
    {q:'🐿️ Ils (chanter) → Ils...',c:['chante','chantons','chantez','chantent'],a:'chantent',mascot:'bounce',svg:'book'},
  ]
};

// For backward compatibility
const FRENCH = frenchData.default;

// === ENRICHED SCIENCE DATA ===
const scienceData = {
  // Corps humain
  corps_humain: [
    {q:'🧠 Comment s\'appelle l\'organe qui pense ?',c:['cœur','cerveau','poumon','estomac'],a:'cerveau',mascot:'bounce',svg:'brain'},
    {q:'❤️ Qu\'est-ce qui pompe le sang dans ton corps ?',c:['le cerveau','le cœur','les poumons','le foie'],a:'le cœur',mascot:'swim',svg:'heart'},
    {q:'🫁 Les _____ aident à respirer.',c:['cœur','cerveau','poumons','estomac'],a:'poumons',mascot:'wiggle',svg:'lungs'},
    {q:'👁️ Avec quoi voies-tu ?',c:['le nez','les oreilles','les yeux','la bouche'],a:'les yeux',mascot:'bounce',svg:'eye'},
    {q:'👃 Avec quoi sens-tu les odeurs ?',c:['les yeux','la bouche','le nez','les oreilles'],a:'le nez',mascot:'swim',svg:'body'},
    {q:'👂 Avec quoi entends-tu ta maman ?',c:['le nez','les yeux','les oreilles','la langue'],a:'les oreilles',mascot:'wiggle',svg:'body'},
    {q:'👅 Avec quoi goûtes-tu une pizza ?',c:['le nez','les oreilles','les yeux','la langue'],a:'la langue',mascot:'bounce',svg:'body'},
    {q:'✋ Avec quoi touches-tu les choses ?',c:['les yeux','la bouche','la peau','le nez'],a:'la peau',mascot:'swim',svg:'body'},
    {q:'🦴 Combien de os a le corps humain ? (environ)',c:['100','200','300','400'],a:'200',mascot:'wiggle',svg:'body'},
    {q:'💪 Quel organe transforme la nourriture ?',c:['le cœur','le cerveau','l\'estomac','les poumons'],a:'l\'estomac',mascot:'bounce',svg:'body'},
  ],
  
  // Les 5 sens
  cinq_sens: [
    {q:'👀 Le sens de la vue utilise... ?',c:['les oreilles','les yeux','le nez','la peau'],a:'les yeux',mascot:'bounce',svg:'eye'},
    {q:'👂 Le sens de l\'ouïe utilise... ?',c:['les yeux','les oreilles','le nez','la bouche'],a:'les oreilles',mascot:'swim',svg:'body'},
    {q:'👃 Le sens de l\'odorat utilise... ?',c:['les yeux','les oreilles','le nez','la peau'],a:'le nez',mascot:'wiggle',svg:'body'},
    {q:'👅 Le sens du goût utilise... ?',c:['le nez','la peau','la langue','les oreilles'],a:'la langue',mascot:'bounce',svg:'body'},
    {q:'✋ Le sens du toucher utilise... ?',c:['les yeux','la langue','le nez','la peau'],a:'la peau',mascot:'swim',svg:'body'},
    {q:'👀 Quel sens te permet de voir les couleurs ?',c:['l\'ouïe','le toucher','la vue','l\'odorat'],a:'la vue',mascot:'wiggle',svg:'eye'},
    {q:'👂 Quel sens te permet d\'écouter de la musique ?',c:['la vue','le toucher','l\'ouïe','le goût'],a:'l\'ouïe',mascot:'bounce',svg:'body'},
    {q:'👃 Quel sens te permet de sentir une fleur ?',c:['le goût','l\'odorat','le toucher','la vue'],a:'l\'odorat',mascot:'swim',svg:'flower'},
    {q:'👅 Quel sens te permet de goûter une pomme ?',c:['l\'odorat','la vue','le goût','l\'ouïe'],a:'le goût',mascot:'wiggle',svg:'flower'},
    {q:'✋ Quel sens te permet de sentir la chaleur du soleil ?',c:['le goût','la vue','le toucher','l\'odorat'],a:'le toucher',mascot:'bounce',svg:'sun'},
  ],
  
  // Animaux - classification
  animaux_classification: [
    {q:'🐕 Le chien est un... ?',c:['oiseau','poisson','mammifère','insecte'],a:'mammifère',mascot:'bounce',svg:'dog'},
    {q:'🐦 L\'oiseau a des... pour voler.',c:['poils','plumes','écailles','carapace'],a:'plumes',mascot:'wiggle',svg:'bird'},
    {q:'🐟 Le poisson vit dans... ?',c:['la forêt','la mer','le désert','la montagne'],a:'la mer',mascot:'swim',svg:'fish'},
    {q:'🐝 L\'abeille est un... ?',c:['mammifère','oiseau','insecte','poisson'],a:'insecte',mascot:'bounce',svg:'butterfly'},
    {q:'🦁 Le lion rugit. C\'est un... ?',c:['oiseau','reptile','mammifère','poisson'],a:'mammifère',mascot:'wiggle',svg:'dog'},
    {q:'🐍 Le serpent rampe. C\'est un... ?',c:['mammifère','reptile','oiseau','insecte'],a:'reptile',mascot:'swim',svg:'dog'},
    {q:'🦋 Le papillon a... pattes ?',c:[2,4,6,8],a:6,mascot:'bounce',svg:'butterfly'},
    {q:'🐟 Le requin est un... ?',c:['mammifère','reptile','poisson','oiseau'],a:'poisson',mascot:'wiggle',svg:'fish'},
    {q:'🐄 La vache donne du lait. C\'est un... ?',c:['poisson','oiseau','mammifère','insecte'],a:'mammifère',mascot:'swim',svg:'dog'},
    {q:'🦅 L\'aigle est un... ?',c:['mammifère','poisson','oiseau','reptile'],a:'oiseau',mascot:'bounce',svg:'bird'},
  ],
  
  // Animaux - modes de vie
  animaux_vie: [
    {q:'🐇 Comment se déplace le lapin ?',c:['il vole','il rampe','il saute','il roule'],a:'il saute',mascot:'bounce',svg:'dog'},
    {q:'🐟 Comment se déplace le poisson ?',c:['il marche','il saute','il nage','il vole'],a:'il nage',mascot:'swim',svg:'fish'},
    {q:'🦅 Comment se déplace l\'oiseau ?',c:['il rampe','il nage','il vole','il roule'],a:'il vole',mascot:'wiggle',svg:'bird'},
    {q:'🐍 Comment se déplace le serpent ?',c:['il saute','il rampe','il vole','il roule'],a:'il rampe',mascot:'bounce',svg:'dog'},
    {q:'🐕 Que mange le chien ?',c:['de l\'herbe','de la viande et des os','des poissons','des feuilles'],a:'de la viande et des os',mascot:'wiggle',svg:'dog'},
    {q:'🐄 Que mange la vache ?',c:['de la viande','du poisson','de l\'herbe','des insectes'],a:'de l\'herbe',mascot:'swim',svg:'dog'},
    {q:'🦋 Que mange le papillon ?',c:['des graines','du nectar des fleurs','des feuilles','de la viande'],a:'du nectar des fleurs',mascot:'bounce',svg:'butterfly'},
    {q:'🐝 Que fait l\'abeille ?',c:['elle chasse','elle collectionne le pollen','elle dort','elle vole sans but'],a:'elle collectionne le pollen',mascot:'wiggle',svg:'butterfly'},
    {q:'🦁 Le lion est un... ?',c:['herbivore','carnivore','omnivore','insectivore'],a:'carnivore',mascot:'swim',svg:'dog'},
    {q:'🐘 L\'éléphant est... ?',c:['carnivore','herbivore','omnivore','insectivore'],a:'herbivore',mascot:'bounce',svg:'dog'},
  ],
  
  // Végétaux
  vegetaux: [
    {q:'🌱 De quelle partie de la plante la tige sort-elle ?',c:['la feuille','la fleur','la graine','le fruit'],a:'la graine',mascot:'bounce',svg:'seed'},
    {q:'🌻 La racine est sous... ?',c:['les feuilles','la terre','la fleur','le tronc'],a:'la terre',mascot:'swim',svg:'plant'},
    {q:'🍎 Le pommes poussent sur... ?',c:['le sol','un arbre','l\'eau','la pierre'],a:'un arbre',mascot:'wiggle',svg:'tree'},
    {q:'🌸 Les pétales font partie de... ?',c:['la racine','la tige','la feuille','la fleur'],a:'la fleur',mascot:'bounce',svg:'flower'},
    {q:'🌿 Les feuilles sont vertes grâce à... ?',c:['l\'eau','la terre','la chlorophylle','le soleil'],a:'la chlorophylle',mascot:'swim',svg:'plant'},
    {q:'🌱 Pour pousser, une plante a besoin de... ?',c:['seulement soleil','seulement eau','soleil ET eau','rien'],a:'soleil ET eau',mascot:'wiggle',svg:'plant'},
    {q:'🥕 La carotte est un... ?',c:['fruit','légume-racine','fleur','tige'],a:'légume-racine',mascot:'bounce',svg:'plant'},
    {q:'🌻 Le tournesol tourne vers... ?',c:['la lune','le soleil','la terre','le vent'],a:'le soleil',mascot:'swim',svg:'flower'},
    {q:'🍊 L\'orange est un... ?',c:['légume','fruit','graine','feuille'],a:'fruit',mascot:'wiggle',svg:'flower'},
    {q:'🌲 Lepin est un... ?',c:['plante à fleurs','arbre','buisson','herbage'],a:'arbre',mascot:'bounce',svg:'tree'},
  ],
  
  // Météo et saisons
  meteo_saisons: [
    {q:'☀️ En quelle saison fait-il le plus chaud ?',c:['hiver','printemps','été','automne'],a:'été',mascot:'bounce',svg:'sun'},
    {q:'❄️ En quelle saison peut-on faire des bonshommes de neige ?',c:['été','printemps','automne','hiver'],a:'hiver',mascot:'wiggle',svg:'snow'},
    {q:'🍂 En quelle saison les feuilles tombent-elles ?',c:['printemps','été','automne','hiver'],a:'automne',mascot:'swim',svg:'tree'},
    {q:'🌸 En quelle saison les fleurs apparaissent-elles ?',c:['hiver','printemps','été','automne'],a:'printemps',mascot:'bounce',svg:'flower'},
    {q:'🌧️ Quand il pleut, les nuages sont... ?',c:['rouges','verts','gris','blancs'],a:'gris',mascot:'wiggle',svg:'cloud'},
    {q:'⛈️ Pendant un orage, on peut voir des... ?',c:['des fleurs','des arcs-en-ciel','des éclairs','des papillons'],a:'des éclairs',mascot:'swim',svg:'sun'},
    {q:'🌈 L\'arc-en-ciel apparaît après... ?',c:['la neige','la pluie','le vent','le brouillard'],a:'la pluie',mascot:'bounce',svg:'sun'},
    {q:'🌬️ Quand il fait très froid, l\'eau peut devenir... ?',c:['solide','gaz','liquide','vapeur'],a:'solide',mascot:'wiggle',svg:'snow'},
    {q:'☁️ Un nuage est fait de... ?',c:['fumée','poussière','vapeur d\'eau','smog'],a:'vapeur d\'eau',mascot:'swim',svg:'cloud'},
    {q:'🌤️ En été, les jours sont plus... ?',c:['courts','longs','froids','noirs'],a:'longs',mascot:'bounce',svg:'sun'},
    {q:'🌧️ L\'eau qui tombe du ciel s\'appelle... ?',c:['neige','pluie','grêle','bruine'],a:'pluie',mascot:'wiggle',svg:'rain'},
    {q:'❄️ Les flocons de neige sont... ?',c:['ronds','en forme de flocon','carrés','longs'],a:'en forme de flocon',mascot:'swim',svg:'snow'},
  ],
  
  // Cycle de l'eau
  cycle_eau: [
    {q:'💧 L\'eau des océans s\'évapore sous l\'effet du... ?',c:['vent','soleil','pluie','neige'],a:'soleil',mascot:'bounce',svg:'sun'},
    {q:'☁️ La vapeur d\'eau forme les... ?',c:['fleuves','lacs','nuages','montagnes'],a:'nuages',mascot:'swim',svg:'cloud'},
    {q:'🌧️ Les nuages relâchent l\'eau sous forme de... ?',c:['soleil','vent','pluie','neige'],a:'pluie',mascot:'wiggle',svg:'rain'},
    {q:'🏞️ La pluie tombe et remplit les... ?',c:['nuages','montagnes','fleuves et lacs','forêts'],a:'fleuves et lakes',mascot:'bounce',svg:'watercycle'},
    {q:'🌊 L\'évaporation fait remonter l\'eau vers... ?',c:['le sol','les montagnes','le ciel','la mer'],a:'le ciel',mascot:'swim',svg:'sun'},
    {q:'🔄 Le cycle de l\'eau recommence toujours car... ?',c:['l\'eau disparaît','l\'eau se transforme mais ne disparaît pas','l\'eau diminue','l\'eau augmente'],a:'l\'eau se transforme mais ne disparaît pas',mascot:'wiggle',svg:'watercycle'},
  ],
  
  // Default SCIENCE
  default: [
    {q:'🐿️ Noisette est un écureuil. Que mange-t-il principalement ?',c:['de la viande','des noisettes','du poisson','des insectes'],a:'des noisettes',mascot:'bounce',svg:'tree'},
    {q:'🪼 Comment s\'appelle le bébé du lion ?',c:['lionceau','ourson','chaton','veau'],a:'lionceau',mascot:'swim',svg:'dog'},
    {q:'🦭 Les phoques vivent...',c:['dans la forêt','dans la mer et sur la glace','dans le désert','dans les arbres'],a:'dans la mer et sur la glace',mascot:'wiggle',svg:'fish'},
    {q:'🐿️ Quel animal fait "coâ coâ" ?',c:['canard','grenouille','cochon','vache'],a:'grenouille',mascot:'bounce',svg:'frog'},
    {q:'🦭 Câlin dit : combien de doigts a une main ?',c:[4,5,6,7],a:5,mascot:'wiggle',svg:'hand'},
    {q:'🐿️ Quel organe fait battre notre sang ?',c:['le foie','le cerveau','le cœur','le poumon'],a:'le cœur',mascot:'bounce',svg:'heart'},
    {q:'🪼 En quelle saison les feuilles tombent-elles ?',c:['printemps','été','automne','hiver'],a:'automne',mascot:'swim',svg:'tree'},
    {q:'🐿️ Les plantes ont besoin de...',c:['soleil et eau','sable','glace','sel'],a:'soleil et eau',mascot:'bounce',svg:'plant'},
  ]
};

// For backward compatibility
const SCIENCE = scienceData.default;

// === NEW MODULE: LE MONDE ===
const mondeData = {
  // Géographie - France
  geographie_france: [
    {q:'🗺️ La France est un... ?',c:['continent','pays','océan','capitale'],a:'pays',mascot:'bounce',svg:'franmap'},
    {q:'🏙️ Quelle est la capitale de la France ?',c:['Lyon','Marseille','Paris','Bordeaux'],a:'Paris',mascot:'wiggle',svg:'franmap'},
    {q:'🌊 La France a des côtés sur... ?',c:['un océan seulement','une mer seulement','un océan ET une mer','aucune'],a:'un océan ET une mer',mascot:'swim',svg:'globe'},
    {q:'🏔️ Dans quelle montagne trouves-tu le Mont Blanc ?',c:['les Pyrénées','les Alpes','le Jura','le Massif Central'],a:'les Alpes',mascot:'bounce',svg:'globe'},
    {q:'🌊 Quel fleuve traverse Paris ?',c:['la Loire','le Rhône','la Seine','le Rhin'],a:'la Seine',mascot:'wiggle',svg:'globe'},
    {q:'🌊 Le plus long fleuve de France est... ?',c:['la Seine','la Loire','le Rhône','la Garonne'],a:'la Loire',mascot:'swim',svg:'globe'},
    {q:'🏖️ La France a des bords de mer appelé... ?',c:['montagnes','plages','forêts','déserts'],a:'plages',mascot:'bounce',svg:'globe'},
    {q:'🗻 Le Sud de la France a des... ?',c:['plaines','collines','montagnes','lacs'],a:'montagnes',mascot:'wiggle',svg:'globe'},
  ],
  
  // Géographie - Continents
  geographie_continents: [
    {q:'🌍 Combien y a-t-il de continents ?',c:[4,5,6,7],a:6,mascot:'bounce',svg:'globe'},
    {q:'🌍 L\'Europe est un... ?',c:['pays','continent','océan','île'],a:'continent',mascot:'wiggle',svg:'globe'},
    {q:'🦁 Sur quel continent vit le lion sauvage ?',c:['Europe','Asie','Afrique','Amérique'],a:'Afrique',mascot:'swim',svg:'globe'},
    {q:'🐼 Sur quel continent vit le panda ?',c:['Europe','Amérique','Asie','Afrique'],a:'Asie',mascot:'bounce',svg:'globe'},
    {q:'🦅 Le condor vit sur quel continent ?',c:['Europe','Afrique','Amérique','Océanie'],a:'Amérique',mascot:'wiggle',svg:'globe'},
    {q:'🏄 Quel océan sépare l\'Europe de l\'Amérique ?',c:['Océan Indien','Océan Atlantique','Océan Pacifique','Océan Arctique'],a:'Océan Atlantique',mascot:'swim',svg:'globe'},
    {q:'🐨 Sur quel continent vit le kangourou ?',c:['Afrique','Amérique','Europe','Océanie'],a:'Océanie',mascot:'bounce',svg:'globe'},
    {q:'🌏 L\'Asie est le plus... continent.',c:['petit','froid','grand','plat'],a:'grand',mascot:'wiggle',svg:'globe'},
  ],
  
  // Géographie - Océans
  geographie_oceans: [
    {q:'🌊 Combien y a-t-il d\'océans ?',c:[3,4,5,6],a:5,mascot:'bounce',svg:'globe'},
    {q:'🌊 Le plus grand océan est... ?',c:['Atlantique','Arctique','Pacifique','Indien'],a:'Pacifique',mascot:'wiggle',svg:'globe'},
    {q:'🌊 L\'océan qui touche la France à l\'ouest est... ?',c:['Pacifique','Indien','Atlantique','Arctique'],a:'Atlantique',mascot:'swim',svg:'globe'},
    {q:'🌊 L\'océan glacial Arctique est... ?',c:['le plus chaud','le plus froid','le plus grand','le plus profond'],a:'le plus froid',mascot:'bounce',svg:'globe'},
    {q:'🏝️ Une île est entourée de... ?',c:['montagnes','forêts','eau','désert'],a:'eau',mascot:'wiggle',svg:'globe'},
  ],
  
  // Histoire - Préhistoire
  histoire_prehistoire: [
    {q:'⛏️ Les hommes préhistoriques utilisaient des outils en... ?',c:['plastique','métal','pierre','bois'],a:'pierre',mascot:'bounce',svg:'castle'},
    {q:'🦣 Le mammouth était un animal avec... ?',c:['des plumes','des écailles','des défenses','des ailes'],a:'des défenses',mascot:'wiggle',svg:'dog'},
    {q:'🏠 Comment vivaient les hommes des cavernes ?',c:['dans des maisons','dans des grottes','sur des arbres','dans l\'eau'],a:'dans des grottes',mascot:'swim',svg:'castle'},
    {q:'🦴 Les hommes préhistoriques chassaient pour... ?',c:['s\'amuser','manger','se réchauffer','construire'],a:'manger',mascot:'bounce',svg:'castle'},
    {q:'🎨 Que peignaient les hommes sur les murs des grottes ?',c:['des nombres','des lettres','des animaux','des voitures'],a:'des animaux',mascot:'wiggle',svg:'castle'},
  ],
  
  // Histoire - Antiquité
  histoire_antiquite: [
    {q:'🏛️ Les pyramides sont en... ?',c:['Grèce','Égypte','Rome','France'],a:'Égypte',mascot:'bounce',svg:'pyramid'},
    {q:'👑 En Égypte ancienne, le chef s\'appelait... ?',c:['roi','empereur','pharaon','prince'],a:'pharaon',mascot:'wiggle',svg:'pyramid'},
    {q:'🐍 Quel animal était sacré en Égypte ?',c:['le chien','le chat','le serpent','le lion'],a:'le chat',mascot:'swim',svg:'cat'},
    {q:'🏛️ Les Grecs ont inventé... ?',c:['la roue','lesOlympiques','l\'imprimerie','l\'avion'],a:'lesOlympiques',mascot:'bounce',svg:'globe'},
    {q:'🏛️ Comment s\'appelait le roi de Rome ?',c:['pharaon','empereur','sultan','tsar'],a:'empereur',mascot:'wiggle',svg:'castle'},
  ],
  
  // Histoire - Moyen Âge
  histoire_moyen_age: [
    {q:'🏰 Comment s\'appelaient les grandes maisons du Moyen Âge ?',c:['granges','châteaux forts','écoles','marchés'],a:'châteaux forts',mascot:'bounce',svg:'castle'},
    {q:'⚔️ Comment s\'appelait le guerrier à cheval du Moyen Âge ?',c:['pirate','soldat','chevalier','cowboy'],a:'chevalier',mascot:'wiggle',svg:'castle'},
    {q:'👑 Au Moyen Âge, qui gouvernait un royaume ?',c:['le professeur','le roi','le fermier','le boulanger'],a:'le roi',mascot:'swim',svg:'castle'},
    {q:'⛪ Au Moyen Âge, les gens allaient à... ?',c:['l\'école','la boulangerie','l\'eglise','le cinéma'],a:'l\'eglise',mascot:'bounce',svg:'castle'},
    {q:'🐉 Dans les histoires, quel animal crachait du feu ?',c:['le lion','le dragon','le cheval','le chien'],a:'le dragon',mascot:'wiggle',svg:'castle'},
  ],
  
  // Histoire - France moderne
  histoire_moderne: [
    {q:'🚩 De quelle couleur est le drapeau français ?',c:['rouge et blanc','bleu blanc rouge','vert blanc rouge','jaune blanc noir'],a:'bleu blanc rouge',mascot:'bounce',svg:'globe'},
    {q:'🎭 Quel personnage symbolise la République française ?',c:['Mickey','Marianne','Cendrillon','Belle'],a:'Marianne',mascot:'wiggle',svg:'globe'},
    {q:'🏛️ La France est une... ?',c:['monarchie','dictature','République','anarchie'],a:'République',mascot:'swim',svg:'globe'},
    {q:'📜 La Déclaration des droits de l\'homme a été écrite en... ?',c:['1789','1799','1889','1989'],a:'1789',mascot:'bounce',svg:'globe'},
  ],
  
  // L'Univers - Système solaire
  univers_systeme: [
    {q:'🌞 Comment s\'appelle l\'étoile au centre de notre système ?',c:['la Lune','le Soleil','Mars','Jupiter'],a:'le Soleil',mascot:'bounce',svg:'sun'},
    {q:'🌍 Quelle est notre planète ?',c:['Mars','Vénus','Terre','Saturne'],a:'Terre',mascot:'wiggle',svg:'planet'},
    {q:'🌙 La Lune brille la nuit parce qu\'elle reflète... ?',c:['sa propre lumière','la lumière du Soleil','les étoiles','les nuages'],a:'la lumière du Soleil',mascot:'swim',svg:'planet'},
    {q:'🪐 Combien de planètes dans notre système solaire ?',c:[6,7,8,9],a:8,mascot:'bounce',svg:'solarsystem'},
    {q:'🔥 La planète la plus proche du Soleil est... ?',c:['la Terre','Vénus','Mercure','Mars'],a:'Mercure',mascot:'wiggle',svg:'planet'},
    {q:'🪐 La planète avec des anneaux est... ?',c:['Jupiter','Mars','Saturne','Neptune'],a:'Saturne',mascot:'swim',svg:'planet'},
    {q:'🌙 Combien de phases de la Lune y a-t-il ? (environ)',c:[4,7,12,28],a:4,mascot:'bounce',svg:'planet'},
    {q:'⭐ Les étoiles sont... ?',c:['des planètes','des soleils','des lunes','des météorites'],a:'des soleils',mascot:'wiggle',svg:'sun'},
    {q:'🌍 Pourquoi voit-on le jour et la nuit ?',c:['la Lune bouge','la Terre tourne','le Soleil disparaît','les étoiles se cachent'],a:'la Terre tourne',mascot:'swim',svg:'planet'},
    {q:'🚀 Qui a été le premier homme sur la Lune ?',c:['Jean-Luc','Neil Armstrong','Tintin','Pierre'],a:'Neil Armstrong',mascot:'bounce',svg:'rocket'},
    {q:'🪐 La Terre tourne autour du... ?',c:['Lune','Soleil','Mars','Jupiter'],a:'Soleil',mascot:'wiggle',svg:'solarsystem'},
    {q:'⭐ La nuit, on voit des étoiles parce que... ?',c:['elles dorment','le Soleil se couche','elles brillent plus','il fait froid'],a:'le Soleil se couche',mascot:'swim',svg:'sun'},
  ],
  
  // Géologie - Roches et volcans
  geologie: [
    {q:'🔥 Un volcan peut... ?',c:['neiger','entrer en éruption','flotter','chanter'],a:'entrer en éruption',mascot:'bounce',svg:'volcano'},
    {q:'🔥 Quand un volcan entre en éruption, il crache... ?',c:['de l\'eau','de la glace','de la lave','du vent'],a:'de la lave',mascot:'wiggle',svg:'volcano'},
    {q:'🪨 Les roches peuvent être... ?',c:['moutes','dures ou tendres','transparentes','invisibles'],a:'dures ou tendres',mascot:'swim',svg:'volcano'},
    {q:'🦴 Un fossile est... ?',c:['un os vivant','un os ancien','une plante','un animal'],a:'un os ancien',mascot:'bounce',svg:'fossil'},
    {q:'🔥 Le magma est de la roche... ?',c:['solide','liquide','gazeuse','fluide'],a:'liquide',mascot:'wiggle',svg:'volcano'},
    {q:'🏔️ Comment s\'appellent les montagnes formées par les volcans ?',c:['plaines','chaînes','cônes','vallées'],a:'cônes',mascot:'swim',svg:'volcano'},
    {q:'🪨 Les rochers sont faits de... ?',c:['plastique','métal','minéraux','verre'],a:'minéraux',mascot:'bounce',svg:'volcano'},
    {q:'🌋 La montagne en forme de cône est souvent un... ?',c:['colline','volcan','plaine','vallée'],a:'volcan',mascot:'wiggle',svg:'volcano'},
  ],
  
  // Frise chronologique
  frise_chronologique: [
    {q:'📅 Quel événement est le plus ancien ?',c:['la Révolution française','les pyramides','la Première Guerre mondiale','l\'homme sur la Lune'],a:'les pyramides',mascot:'bounce',svg:'timeline'},
    {q:'📅 Quel événement est le plus récent ?',c:['les chevaliers','la Révolution française','l\'homme sur la Lune','les pyramides'],a:'l\'homme sur la Lune',mascot:'wiggle',svg:'timeline'},
    {q:'⏰ La préhistoire était avant... ?',c:['aujourd\'hui','l\'Antiquité','le Moyen Âge','la Renaissance'],a:'l\'Antiquité',mascot:'swim',svg:'timeline'},
    {q:'🏰 Le Moyen Âge est venu après... ?',c:['la préhistoire','l\'Antiquité','les temps modernes','l\'espace'],a:'l\'Antiquité',mascot:'bounce',svg:'timeline'},
    {q:'📜 L\'Égypte ancienne est à peu près à la même époque que... ?',c:['les chevaliers','les hommes des cavernes','la conquête spatiale','les smartphones'],a:'les hommes des cavernes',mascot:'wiggle',svg:'timeline'},
  ],
  
  // Default Le Monde
  default: [
    {q:'🗺️ Comment s\'appelle notre planète ?',c:['Mars','Vénus','Terre','Lune'],a:'Terre',mascot:'bounce',svg:'globe'},
    {q:'🏛️ Les pyramides sont en... ?',c:['Grèce','Égypte','Rome','France'],a:'Égypte',mascot:'wiggle',svg:'pyramid'},
    {q:'🌞 Comment s\'appelle notre étoile ?',c:['la Lune','le Soleil','Mars','Jupiter'],a:'le Soleil',mascot:'swim',svg:'sun'},
    {q:'🏰 Les chevaliers vivaient au... ?',c:['Moyen Âge','Antiquité','Préhistoire','Aujourd\'hui'],a:'Moyen Âge',mascot:'bounce',svg:'castle'},
  ]
};

// State for Le Monde module
let currentMondeCategory = 'geographie_france';

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
  else if (screen === 'module-select') app.innerHTML = moduleSelectHTML();
  else if (screen === 'math' || screen === 'french' || screen === 'science' || screen === 'monde') {
    if (done) app.innerHTML = resultHTML();
    else app.innerHTML = quizHTML();
  } else if (screen === 'trophy') app.innerHTML = trophyHTML();
  else if (screen === 'parental') app.innerHTML = parentalHTML();
  attachListeners();
  initStickerAlbum();
}

// Module selector screen
function moduleSelectHTML() {
  const data = getModuleData(module);
  const categories = Object.keys(data).filter(k => k !== 'default');
  
  const moduleInfo = {
    math: { title: '🔢 Maths', color: '#3b82f6', mascot: '🪼', icon: '🧮' },
    french: { title: '📖 Français', color: '#ec4899', mascot: '🦭', icon: '📚' },
    science: { title: '🔬 Sciences', color: '#22c55e', mascot: '🐿️', icon: '🔬' },
    monde: { title: '🌍 Le Monde', color: '#f59e0b', mascot: '✨', icon: '🌍' }
  };
  
  const info = moduleInfo[module] || moduleInfo.math;
  
  return `<div class="module-header screen-transition">
    <button class="back-btn" data-action="home">🏠</button>
    <h2 class="module-title" style="color: ${info.color}">${info.title}</h2>
    <span class="badge-count" style="background: ${info.color}; color: white;">${categories.length} sections</span>
  </div>
  
  <div class="card" style="margin-bottom: 16px;">
    <div style="text-align: center; margin-bottom: 15px;">
      <span style="font-size: 3rem;">${info.icon}</span>
      <p style="color: #666; font-size: 0.9rem;">Choisis une activité ci-dessous</p>
    </div>
    
    <div class="category-tabs" style="display: flex; flex-direction: column; gap: 10px;">
      ${categories.map(cat => {
        const catData = data[cat];
        const catNames = {
          // Math
          addition: '➕ Additions', soustraction: '➖ Soustractions',
          table_1: '⭐ Table ×1', table_2: '🧦 Table ×2', table_3: '🍀 Table ×3',
          table_4: '◻️ Table ×4', table_5: '✋ Table ×5', table_10: '🔟 Table ×10',
          tables_ce1: '✖️ Tables CE1', tables_ce2: '✖️ Tables CE2',
          géométrie: '📐 Géométrie', mesures: '📏 Mesures', logique: '🧩 Logique',
          // French
          phonetique: '🔤 Phonétique', lecture: '📖 Lecture',
          orthographe: '✏️ Orthographe', grammaire: '📝 Grammaire',
          conjugaison: '📐 Conjugaison', vocabulaire_animations: '🐾 Animaux',
          vocabulaire_ecole: '🏫 École', vocabulaire_famille: '👨‍👩‍👧 Famille',
          vocabulaire_nature: '🌳 Nature', vocabulaire_corps: '🧠 Corps',
          // Science
          corps_humain: '🧠 Corps humain', cinq_sens: '👁️ 5 Sens',
          animaux_classification: '🦁 Classification', animaux_vie: '🦎 Modes de vie',
          vegetaux: '🌱 Végétaux', meteo_saisons: '☀️ Météo & Saisons',
          cycle_eau: '💧 Cycle de l\'eau',
          // Monde
          geographie_france: '🇫🇷 Géographie France', geographie_continents: '🌍 Continents',
          geographie_oceans: '🌊 Océans', histoire_prehistoire: '⛏️ Préhistoire',
          histoire_antiquite: '🏛️ Antiquité', histoire_moyen_age: '🏰 Moyen Âge',
          histoire_moderne: '🏛️ France moderne', univers_systeme: '🚀 Système solaire',
          geologie: '🌋 Géologie', frise_chronologique: '📅 Frise chronologique'
        };
        return `<button class="category-tab ${currentMathCategory === cat ? 'active' : ''}" 
                    data-category="${cat}" onclick="startModuleFromCategory('${cat}')"
                    style="padding: 15px; text-align: left;">
          <span style="font-size: 1.2rem;">${catNames[cat] || cat}</span>
          <span style="margin-left: auto; color: #999; font-size: 0.8rem;">${catData.length} questions</span>
        </button>`;
      }).join('')}
    </div>
  </div>`;
}

function getModuleData(mod) {
  if (mod === 'math') return mathData;
  if (mod === 'french') return frenchData;
  if (mod === 'science') return scienceData;
  if (mod === 'monde') return mondeData;
  return {};
}

function startModuleFromCategory(category) {
  currentMathCategory = category;
  const data = getModuleData(module);
  const exercises = shuffle(data[category].slice());
  currentExercise = exercises[0];
  qIdx = 0;
  score = 0;
  done = false;
  
  // Update category display
  document.querySelectorAll('.category-tab').forEach(t => t.classList.remove('active'));
  document.querySelector(`[data-category="${category}"]`)?.classList.add('active');
  
  render();
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
    <button class="subject-btn btn-monde" data-subject="monde" style="background: linear-gradient(135deg, #3498db, #2ecc71);">
      <span class="emoji">🌍</span><span>Le Monde</span>
      <span class="card-mascot">✨</span>
    </button>
    <button class="subject-btn btn-trophy" data-subject="trophy">
      <span class="emoji">🏆</span><span>Trophées</span>
    </button>
    <button class="subject-btn btn-minigames" onclick="screen='mini-games';render()" style="background: linear-gradient(135deg, #9b59b6, #8e44ad);">
      <span class="emoji">🎮</span><span>Mini-Jeux</span>
      <span class="card-mascot">🚀</span>
    </button>
  </div>
  
  <button class="parental-link" data-action="parental">👨‍👩‍👧 Espace parents</button>`;
}

function quizHTML() {
  const ex = exercises[qIdx];
  const prog = ((qIdx) / exercises.length) * 100;
  
  const moduleInfo = {
    math: { title: '🔢 Maths avec 🪼 Bulle', color: 'math', emoji: '🪼' },
    french: { title: '📖 Français avec 🦭 Câlin', color: 'french', emoji: '🦭' },
    science: { title: '🔬 Sciences avec 🐿️ Noisette', color: 'science', emoji: '🐿️' },
    monde: { title: '🌍 Le Monde avec ✨', color: 'monde', emoji: '✨' }
  };
  
  const info = moduleInfo[module] || moduleInfo.math;
  const mascotClass = ex.mascot || 'bounce';
  const gridClass = typeof ex.a === 'number' && ex.c.length === 4 ? 'grid2' : '';
  
  // Display SVG icon if available
  const svgIcon = ex.svg && svgIcons[ex.svg] ? `<div style="margin-bottom: 10px;">${svgIcons[ex.svg]}</div>` : '';
  
  return `<div class="module-header screen-transition">
    <button class="back-btn" data-action="back">⬅️</button>
    <h2 class="module-title ${info.color}">${info.title}</h2>
    <span class="badge-count badge-${info.color}">${qIdx + 1}/${exercises.length}</span>
  </div>
  
  <div class="progress-bar"><div class="progress-fill progress-${info.color}" style="width:${prog}%"></div></div>
  
  <div class="question-card" style="position: relative;">
    <span class="quiz-mascot ${mascotClass}">${info.emoji}</span>
    ${svgIcon}
    <span class="exercise-mascot ${mascotClass}" style="margin-bottom: 15px;">${info.emoji}</span>
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
    <p style="color:#9ca3af;font-size:14px;margin-bottom:16px">Code: <strong>1234</strong></p>
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
  
  // Show module selector first for all modules
  screen = 'module-select';
  playBeep(500, 0.1, 'sine');
  
  // Set default category for each module
  if (sub === 'math') currentMathCategory = 'addition';
  else if (sub === 'french') currentMathCategory = 'phonetique';
  else if (sub === 'science') currentMathCategory = 'corps_humain';
  else if (sub === 'monde') currentMathCategory = 'geographie_france';
  
  render();
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
    screen = 'trophy'; 
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
