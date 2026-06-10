// === STATE ===
let stars = 0;
let badges = [];
let screen = 'home';

// === DATA ===
const MATH = [
  {q:'7+5=?',c:[12,11,13,10],a:12},{q:'14+8=?',c:[22,20,24,21],a:22},
  {q:'25+13=?',c:[38,37,39,36],a:38},{q:'36+24=?',c:[60,59,61,58],a:60},
  {q:'15-7=?',c:[8,7,9,6],a:8},{q:'23-9=?',c:[14,13,15,12],a:14},
  {q:'41-16=?',c:[25,24,26,23],a:25},{q:'3×4=?',c:[12,9,15,11],a:12},
  {q:'5×6=?',c:[30,25,35,28],a:30},{q:'Un carré a combien de côtés?',c:[4,3,5,6],a:4}
];
const FRENCH = [
  {q:'Féminin de "chanteur"?',c:['chanteuse','chanteure','chanteusse','chanteurus'],a:'chanteuse'},
  {q:'"Le chien ___ dans le jardin"',c:['court','courent','coures','couru'],a:'court'},
  {q:'Quel mot est un animal?',c:['papillon','maison','table','soleil'],a:'papillon'},
  {q:'"chanter" 1ère pers présent',c:['je chante','je chantes','je chanti','je chantez'],a:'je chante'},
  {q:'Mot au pluriel?',c:['les chats','un chat','le chat','ma chatte'],a:'les chats'},
  {q:'"Elle ___ un livre"',c:['lit','li','lis','lire'],a:'lit'},
  {q:'Contraire de "grand"?',c:['petit','moyen','large','gros'],a:'petit'},
  {q:'Lettre muette dans "chat"?',c:['t','c','h','a'],a:'t'},
  {q:'"Les enfants ___ à l\'école"',c:['vont','va','vais','allez'],a:'vont'},
  {q:'Famille de "fleur"?',c:['fleuriste','soleil','pluie','arbre'],a:'fleuriste'}
];
const SCIENCE = [
  {q:'Nombre de saisons?',c:['4','3','6','2'],a:'4'},
  {q:'Animal qui pond des œufs?',c:['poule','chat','chien','lapin'],a:'poule'},
  {q:'Les plantes ont besoin de...',c:['soleil et eau','sable','glace','sel'],a:'soleil et eau'},
  {q:'Nombre de dents de lait?',c:['20','32','16','28'],a:'20'},
  {q:'Organe qui fait battre le sang?',c:['cœur','cerveau','foie','poumons'],a:'cœur'},
  {q:'Saison après l\'hiver?',c:['printemps','été','automne','neige'],a:'printemps'},
  {q:'Nourriture du lapin?',c:['carottes','viande','poisson','fromage'],a:'carottes'},
  {q:'Qu\'est-ce qui tombe en hiver?',c:['neige','feuilles','fleurs','sable'],a:'neige'}
];

// === MODULE STATE ===
let module = null;
let qIdx = 0;
let sel = null;
let score = 0;
let done = false;
let exercises = [];

// === RENDER ===
function render() {
  const app = document.getElementById('app');
  if (screen === 'home') app.innerHTML = homeHTML();
  else if (screen === 'math' || screen === 'french' || screen === 'science') {
    if (done) app.innerHTML = resultHTML();
    else app.innerHTML = quizHTML();
  } else if (screen === 'trophy') app.innerHTML = trophyHTML();
  else if (screen === 'parental') app.innerHTML = parentalHTML();
  attachListeners();
}

function homeHTML() {
  return `<div class="header">
    <span class="star">🌟</span>
    <h1>Bonjour Emilie !</h1>
    <p>Qu'est-ce qu'on apprend aujourd'hui ?</p>
    <div class="stats">
      <span class="stat-pill stat-stars">⭐ ${stars} étoiles</span>
      <span class="stat-pill stat-badges">🏅 ${badges.length} badges</span>
    </div>
  </div>
  <div class="grid">
    <button class="subject-btn btn-math" data-subject="math">
      <span class="emoji">🔢</span><span>Maths</span>
    </button>
    <button class="subject-btn btn-french" data-subject="french">
      <span class="emoji">📖</span><span>Français</span>
    </button>
    <button class="subject-btn btn-science" data-subject="science">
      <span class="emoji">🔬</span><span>Sciences</span>
    </button>
    <button class="subject-btn btn-trophy" data-subject="trophy">
      <span class="emoji">🏆</span><span>Mes Trophées</span>
    </button>
  </div>
  <button class="parental-link" data-action="parental">👨‍👩‍👧 Espace parents</button>`;
}

function quizHTML() {
  const ex = exercises[qIdx];
  const prog = ((qIdx) / exercises.length) * 100;
  const cls = module === 'math' ? 'math' : module === 'french' ? 'french' : 'science';
  const gridClass = typeof ex.a === 'number' && exercises.length === 10 ? 'grid2' : '';
  return `<div class="module-header">
    <button class="back-btn" data-action="back">⬅️</button>
    <h2 class="module-title ${cls}">${module === 'math' ? '🔢 Maths' : module === 'french' ? '📖 Français' : '🔬 Sciences'}</h2>
    <span class="badge-count badge-${cls}">${qIdx + 1}/${exercises.length}</span>
  </div>
  <div class="progress-bar"><div class="progress-fill progress-${cls}" style="width:${prog}%"></div></div>
  <div class="question-card"><p>${ex.q}</p></div>
  <div class="choices ${gridClass}">
    ${ex.c.map(c => `<button class="choice-btn ${getBtnClass(c)}" data-choice='${JSON.stringify(c)}'>${c}</button>`).join('')}
  </div>`;
}

function resultHTML() {
  const emoji = score >= 8 ? '🏆' : score >= 5 ? '😊' : '💪';
  const cls = module === 'math' ? 'blue' : module === 'french' ? 'pink' : 'green';
  return `<div class="card result-screen">
    <span class="result-emoji">${emoji}</span>
    <h2 class="result-title">Bravo Emilie !</h2>
    <p class="result-score">Tu as eu <strong>${score}/${exercises.length}</strong> bonnes réponses !</p>
    <p class="result-stars">+${score * 2} ⭐ étoiles gagnées</p>
    <button class="primary-btn btn-${cls}" data-action="home">🏠 Retour à l'accueil</button>
  </div>`;
}

function trophyHTML() {
  return `<div class="module-header">
    <button class="back-btn" data-action="back">⬅️</button>
    <h2 class="module-title trophy">🏆 Mes Trophées</h2>
  </div>
  <div class="trophies-grid">
    <div class="trophy-card"><span class="trophy-icon">⭐</span><div class="trophy-value">${stars}</div><div class="trophy-label">étoiles</div></div>
    <div class="trophy-card"><span class="trophy-icon">🏅</span><div class="trophy-value">${badges.length}</div><div class="trophy-label">badges</div></div>
  </div>
  <div class="card">
    <h3 style="font-weight:900;margin-bottom:12px">🏅 Mes Badges</h3>
    ${badges.length ? `<div class="badges-list">${badges.map(b => `<div class="badge-item">${b}</div>`).join('')}</div>` : `<p class="empty-msg">Continue les exercices pour gagner des badges ! 💪</p>`}
  </div>`;
}

function parentalHTML() {
  return `<div class="card parental-lock">
    <div style="font-size:40px;margin-bottom:16px">👨‍👩‍👧</div>
    <h2 style="font-size:22px;font-weight:900;margin-bottom:8px">Espace Parents</h2>
    <p style="color:#9ca3af;font-size:14px;margin-bottom:16px">Code: <strong>1234</strong></p>
    <input type="password" maxlength="4" class="pin-input" id="pin" placeholder="••••">
    <p class="error-msg" id="error" style="display:none">Code incorrect !</p>
    <button class="primary-btn btn-purple" data-action="unlock">Entrer</button>
    <button class="parental-link" data-action="back">Retour</button>
    ${badges.length ? `<div class="parent-info"><strong>📊 Statistiques</strong><br>⭐ ${stars} étoiles | 🏅 ${badges.length} badges<br><br><strong>Badges:</strong> ${badges.join(', ')}</div>` : ''}
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
  qIdx = 0; sel = null; score = 0; done = false;
  exercises = shuffle(sub === 'math' ? MATH.slice() : sub === 'french' ? FRENCH.slice() : SCIENCE.slice()).slice(0, 10);
  screen = sub;
  render();
}

function handleChoice(choice) {
  if (sel) return;
  sel = choice;
  const ex = exercises[qIdx];
  const correct = JSON.stringify(choice) === JSON.stringify(ex.a);
  if (correct) { score++; stars += 2; }
  render();
  setTimeout(() => {
    if (qIdx + 1 >= exercises.length) {
      done = true;
      if (module === 'math' && score >= 8 && !badges.includes('🏆 Super Mathématicien·ne !')) badges.push('🏆 Super Mathématicien·ne !');
      if (module === 'french' && score >= 8 && !badges.includes('📚 Championne de Français !')) badges.push('📚 Championne de Français !');
      if (module === 'science' && score >= 6 && !badges.includes('🔬 Petite Scientifique !')) badges.push('🔬 Petite Scientifique !');
    } else { qIdx++; sel = null; }
    render();
  }, 1200);
}

function unlockParental() {
  const pin = document.getElementById('pin').value;
  const err = document.getElementById('error');
  if (pin === '1234') { screen = 'trophy'; render(); }
  else { err.style.display = 'block'; document.getElementById('pin').classList.add('error'); setTimeout(() => { err.style.display = 'none'; document.getElementById('pin').classList.remove('error'); }, 2000); }
}

function shuffle(arr) {
  return arr.sort(() => Math.random() - 0.5);
}

// === INIT ===
render();
