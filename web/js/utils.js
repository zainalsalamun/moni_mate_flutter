// ── UTILS ────────────────────────────────────────────────────

function uuid(){ return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g,c=>{const r=Math.random()*16|0;return(c=='x'?r:(r&0x3|0x8)).toString(16)}) }

function formatRp(n){
  if(isNaN(n)||n===null)return 'Rp 0';
  return 'Rp '+Math.abs(n).toLocaleString('id-ID');
}
function cleanNum(s){ return parseFloat(String(s).replace(/[^0-9]/g,''))||0 }
function formatNumInput(val){ return String(val).replace(/[^0-9]/g,'').replace(/\B(?=(\d{3})+(?!\d))/g,'.') }

function formatDate(iso){
  const d=new Date(iso);
  const months=['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
  return `${d.getDate()} ${months[d.getMonth()]} ${d.getFullYear()}`;
}
function formatMonthYear(d){
  const months=['Januari','Februari','Maret','April','Mei','Juni','Juli','Agustus','September','Oktober','November','Desember'];
  return `${months[d.getMonth()]} ${d.getFullYear()}`;
}
function isToday(iso){ const d=new Date(iso),n=new Date(); return d.toDateString()===n.toDateString() }
function isYesterday(iso){ const d=new Date(iso),y=new Date(); y.setDate(y.getDate()-1); return d.toDateString()===y.toDateString() }
function groupLabel(iso){
  if(isToday(iso))return 'Hari Ini';
  if(isYesterday(iso))return 'Kemarin';
  return formatDate(iso);
}

function showToast(msg, dur=2500){
  const t=document.getElementById('toast');
  t.textContent=msg; t.classList.add('show');
  setTimeout(()=>t.classList.remove('show'), dur);
}

function openModal(title, html){
  document.getElementById('modalTitle').textContent=title;
  document.getElementById('modalBody').innerHTML=html;
  document.getElementById('modalOverlay').classList.add('open');
}
function closeModal(){ document.getElementById('modalOverlay').classList.remove('open') }

// Category colors & icons
const CAT_COLORS = {
  makan:'#6F86D6',minum:'#654444',transport:'#48C6EF',hiburan:'#22C55E',
  gaji:'#F59E0B',belanja:'#E879F9',kesehatan:'#FB7185',pendidikan:'#8B5CF6',
  tagihan:'#FFA500',freelance:'#8B5CF6',investasi:'#10B981',bonus:'#EC4899',
  hadiah:'#EC4899',tabungan:'#4CAF50',donasi:'#26A69A',lainnya:'#A0AEC0',lainnya_masuk:'#A0AEC0'
};
const CAT_EMOJI = {
  makan:'🍽️',minum:'☕',transport:'🚗',hiburan:'🎮',gaji:'💼',belanja:'🛍️',
  kesehatan:'🏥',pendidikan:'🎓',tagihan:'🧾',freelance:'💻',investasi:'📈',
  bonus:'🎁',hadiah:'🎁',tabungan:'🏦',donasi:'🤲',lainnya:'📦',lainnya_masuk:'📦'
};
function getCatColor(id){ return CAT_COLORS[id]||'#A0AEC0' }
function getCatEmoji(id){ return CAT_EMOJI[id]||'📦' }

function goalIcon(title){
  const t=title.toLowerCase();
  if(t.includes('motor')||t.includes('kendaraan'))return'🛵';
  if(t.includes('mobil'))return'🚗';
  if(t.includes('darurat')||t.includes('kesehatan'))return'🏥';
  if(t.includes('liburan')||t.includes('travel'))return'✈️';
  if(t.includes('rumah')||t.includes('kpr'))return'🏠';
  if(t.includes('nikah')||t.includes('wedding'))return'❤️';
  if(t.includes('pendidikan')||t.includes('kuliah'))return'🎓';
  if(t.includes('gadget')||t.includes('laptop'))return'💻';
  return'🏦';
}

function calcMonthly(goal){
  const now=new Date(), target=new Date(goal.targetDate);
  let m=(target.getFullYear()-now.getFullYear())*12+target.getMonth()-now.getMonth();
  if(m<=0)m=1;
  const rem=goal.targetAmount-goal.currentAmount;
  return rem<=0?0:rem/m;
}

// Achievements
function getAchievements(goals){
  const completed=goals.filter(g=>g.status==='completed').length;
  return [
    {title:'Getting Started',sub:'Buat target pertama',emoji:'⭐',color:'#26A69A',unlocked:goals.length>0},
    {title:'First Save',sub:'Lakukan tabungan pertama',emoji:'💰',color:'#9C27B0',unlocked:goals.some(g=>g.currentAmount>0)},
    {title:'Halfway There',sub:'Capai 50% dari satu target',emoji:'🔓',color:'#FB923C',unlocked:goals.some(g=>(g.currentAmount/g.targetAmount)>=0.5)},
    {title:'Goal Achieved',sub:'Selesaikan 1 target',emoji:'🏆',color:'#FFC107',unlocked:completed>=1},
    {title:'Financial Guru',sub:'Selesaikan 5 target',emoji:'💎',color:'#0288D1',unlocked:completed>=5},
  ];
}

// Execute recurring transactions
function executeRecurring(){
  const recs=RecurDB.getAll(); const now=new Date(); let changed=false;
  recs.forEach(r=>{
    if(!r.isActive)return;
    const next=new Date(r.nextExecutionDate);
    if(next<=now){
      TxDB.add({id:uuid(),type:r.type,category:r.category,amount:r.amount,description:r.title+' (Auto)',date:now.toISOString()});
      // Advance next date
      const nd=new Date(r.nextExecutionDate);
      if(r.repeatType==='daily')nd.setDate(nd.getDate()+r.interval);
      else if(r.repeatType==='weekly')nd.setDate(nd.getDate()+7*r.interval);
      else if(r.repeatType==='monthly')nd.setMonth(nd.getMonth()+r.interval);
      else if(r.repeatType==='yearly')nd.setFullYear(nd.getFullYear()+r.interval);
      r.nextExecutionDate=nd.toISOString();
      RecurDB.save(r); changed=true;
    }
  });
  return changed;
}
