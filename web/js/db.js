// ── DATABASE (localStorage) ──────────────────────────────────
const DB_KEYS = {
  transactions:'mm_tx', goals:'mm_goals', contributions:'mm_contrib',
  categories:'mm_cats', budgets:'mm_budgets', recurring:'mm_recurring',
  settings:'mm_settings'
};

function dbGet(key){ try{return JSON.parse(localStorage.getItem(DB_KEYS[key]))||[]}catch{return []} }
function dbGetObj(key){ try{return JSON.parse(localStorage.getItem(DB_KEYS[key]))||{}}catch{return {}} }
function dbSet(key,val){ localStorage.setItem(DB_KEYS[key], JSON.stringify(val)) }

// Transactions
const TxDB = {
  getAll(){ return dbGet('transactions') },
  add(tx){ const all=this.getAll(); all.push(tx); dbSet('transactions',all) },
  delete(id){ dbSet('transactions', this.getAll().filter(t=>t.id!==id)) },
  clear(){ dbSet('transactions',[]) }
};

// Goals
const GoalDB = {
  getAll(){ return dbGet('goals') },
  add(g){ const all=this.getAll(); all.push(g); dbSet('goals',all) },
  save(g){ const all=this.getAll(); const i=all.findIndex(x=>x.id===g.id); if(i>=0)all[i]=g; dbSet('goals',all) },
  delete(id){ dbSet('goals', this.getAll().filter(g=>g.id!==id)) }
};

// Contributions
const ContribDB = {
  getAll(){ return dbGet('contributions') },
  add(c){ const all=this.getAll(); all.push(c); dbSet('contributions',all) },
  byGoal(goalId){ return this.getAll().filter(c=>c.goalId===goalId) },
  deleteByGoal(goalId){ dbSet('contributions', this.getAll().filter(c=>c.goalId!==goalId)) }
};

// Categories
const CatDB = {
  getAll(){ return dbGet('categories') },
  add(c){ const all=this.getAll(); all.push(c); dbSet('categories',all) },
  delete(id){ dbSet('categories', this.getAll().filter(c=>c.id!==id)) }
};

// Budgets
const BudgetDB = {
  getAll(){ return dbGet('budgets') },
  add(b){ const all=this.getAll(); all.push(b); dbSet('budgets',all) },
  save(b){ const all=this.getAll(); const i=all.findIndex(x=>x.id===b.id); if(i>=0)all[i]=b; else all.push(b); dbSet('budgets',all) },
  delete(id){ dbSet('budgets', this.getAll().filter(b=>b.id!==id)) }
};

// Recurring
const RecurDB = {
  getAll(){ return dbGet('recurring') },
  add(r){ const all=this.getAll(); all.push(r); dbSet('recurring',all) },
  save(r){ const all=this.getAll(); const i=all.findIndex(x=>x.id===r.id); if(i>=0)all[i]=r; dbSet('recurring',all) },
  delete(id){ dbSet('recurring', this.getAll().filter(r=>r.id!==id)) }
};

// Settings
const Settings = {
  get(){ return dbGetObj('settings') },
  save(s){ dbSet('settings',s) },
  update(key,val){ const s=this.get(); s[key]=val; this.save(s) }
};
