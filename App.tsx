
import React, { useState, useEffect, useMemo } from 'react';
import { 
  TaskStatus, 
  HousekeepingRecord, 
  ViewState, 
  RecordType
} from './types';
import { 
  SOCIETY_CONFIG, 
  TIERED_TASKS, 
  STATUS_COLORS 
} from './constants';
import ProgressBar from './components/ProgressBar';
import { generateCleaningReport } from './services/geminiService';

const App: React.FC = () => {
  // Persistence Layer
  const [records, setRecords] = useState<HousekeepingRecord[]>(() => {
    const saved = localStorage.getItem('society_records_v5');
    return saved ? JSON.parse(saved) : [];
  });

  // Navigation State
  const [currentView, setCurrentView] = useState<ViewState>('DASHBOARD');
  const [selectedBlock, setSelectedBlock] = useState<string | null>(null);
  const [selectedFloor, setSelectedFloor] = useState<number | null>(null);
  const [selectedRecordId, setSelectedRecordId] = useState<string | null>(null);

  // Search/AI
  const [searchTerm, setSearchTerm] = useState('');
  const [aiReport, setAiReport] = useState<string | null>(null);
  const [isGeneratingReport, setIsGeneratingReport] = useState(false);

  useEffect(() => {
    localStorage.setItem('society_records_v5', JSON.stringify(records));
  }, [records]);

  // Record Accessor
  const getRecord = (id: string, type: RecordType, label: string, block?: string, floor?: number): HousekeepingRecord => {
    const existing = records.find(r => r.id === id);
    if (existing) return existing;

    const newRecord: HousekeepingRecord = {
      id,
      type,
      label,
      status: TaskStatus.PENDING,
      tasks: TIERED_TASKS[type].map((t, idx) => ({ id: `${idx}`, label: t, isDone: false })),
      notes: '',
      lastUpdated: new Date().toISOString(),
      block,
      floor,
      verifiedByAdmin: false,
      adminNotes: ''
    };
    return newRecord;
  };

  const updateRecord = (updated: HousekeepingRecord) => {
    setRecords(prev => {
      const filtered = prev.filter(r => r.id !== updated.id);
      return [...filtered, { ...updated, lastUpdated: new Date().toISOString() }];
    });
  };

  const stats = useMemo(() => {
    const totalFlatsCount = SOCIETY_CONFIG.blocks.length * SOCIETY_CONFIG.floorsPerBlock * SOCIETY_CONFIG.flatsPerFloor;
    const totalFloorsCount = SOCIETY_CONFIG.blocks.length * SOCIETY_CONFIG.floorsPerBlock;
    const totalBlocksCount = SOCIETY_CONFIG.blocks.length;
    const totalPossibleRecords = 1 + totalBlocksCount + totalFloorsCount + totalFlatsCount;
    
    const completed = records.filter(r => r.status === TaskStatus.COMPLETED).length;
    const issues = records.filter(r => r.status === TaskStatus.ISSUE).length;
    const verified = records.filter(r => r.verifiedByAdmin).length;
    
    return { 
      completion: (completed / totalPossibleRecords) * 100,
      completed,
      issues,
      verified,
      totalPossibleRecords
    };
  }, [records]);

  const handleGenerateAIReport = async () => {
    setIsGeneratingReport(true);
    const report = await generateCleaningReport(records);
    setAiReport(report);
    setCurrentView('AI_REPORT');
    setIsGeneratingReport(false);
  };

  const filteredDatabaseRecords = useMemo(() => {
    return records.filter(r => 
      r.label.toLowerCase().includes(searchTerm.toLowerCase()) || 
      r.id.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (r.notes && r.notes.toLowerCase().includes(searchTerm.toLowerCase()))
    ).sort((a, b) => new Date(b.lastUpdated || 0).getTime() - new Date(a.lastUpdated || 0).getTime());
  }, [records, searchTerm]);

  // UI Components
  const renderDashboard = () => (
    <div className="space-y-6 pb-28">
      <header className="bg-white p-6 shadow-sm border-b rounded-b-[2rem]">
        <div className="flex justify-between items-start">
          <div>
            <h1 className="text-2xl font-bold text-slate-800">SocietyCare</h1>
            <p className="text-slate-500 text-[10px] font-black uppercase tracking-widest mt-1">Housekeeping Hub</p>
          </div>
          <div className="bg-blue-50 p-2 rounded-xl">
             <i className="fas fa-building-circle-check text-blue-600"></i>
          </div>
        </div>
        <div className="mt-6">
          <ProgressBar percentage={stats.completion} label="Today's Completion" />
        </div>
      </header>

      <div className="px-4 grid grid-cols-3 gap-3">
        <div className="bg-white border border-slate-100 p-3 rounded-2xl shadow-sm">
          <p className="text-slate-400 text-[9px] font-black uppercase mb-1">Done</p>
          <p className="text-xl font-bold text-slate-800">{stats.completed}</p>
        </div>
        <div className="bg-white border border-slate-100 p-3 rounded-2xl shadow-sm">
          <p className="text-rose-500 text-[9px] font-black uppercase mb-1">Issues</p>
          <p className="text-xl font-bold text-slate-800">{stats.issues}</p>
        </div>
        <div className="bg-white border border-slate-100 p-3 rounded-2xl shadow-sm">
          <p className="text-emerald-500 text-[9px] font-black uppercase mb-1">Verified</p>
          <p className="text-xl font-bold text-slate-800">{stats.verified}</p>
        </div>
      </div>

      <div className="px-4 space-y-4">
        <div className="bg-white p-5 rounded-3xl border border-slate-100 shadow-sm">
          <h3 className="text-[10px] font-black uppercase text-slate-400 mb-4 tracking-widest">Global Areas</h3>
          <button 
            onClick={() => { setSelectedRecordId('SOCIETY'); setCurrentView('TASK_DETAIL'); }}
            className="w-full bg-blue-50 text-blue-700 p-4 rounded-2xl flex items-center justify-between font-bold mb-3 active:scale-[0.98] transition-all"
          >
            <div className="flex items-center space-x-3">
               <div className="w-8 h-8 bg-white rounded-lg flex items-center justify-center shadow-sm">
                 <i className="fas fa-road-spikes"></i>
               </div>
               <span>Main Driveway</span>
            </div>
            <span className="text-[9px] bg-blue-600 text-white px-2 py-0.5 rounded-full uppercase font-black">Weekly</span>
          </button>
          
          <button 
            onClick={() => setCurrentView('BLOCK_SELECT')}
            className="w-full bg-slate-900 text-white p-5 rounded-2xl flex items-center justify-between font-bold shadow-lg active:scale-[0.98] transition-all"
          >
            <div className="flex items-center space-x-3">
               <div className="w-8 h-8 bg-white/10 rounded-lg flex items-center justify-center">
                 <i className="fas fa-building-user"></i>
               </div>
               <span>Resident Blocks 1-6</span>
            </div>
            <i className="fas fa-chevron-right text-slate-500 text-xs"></i>
          </button>
        </div>
      </div>

      <div className="px-4">
        <div className="flex justify-between items-center mb-4">
          <h3 className="text-slate-700 font-black text-[10px] uppercase tracking-widest">Recent Check-ins</h3>
          <button onClick={() => setCurrentView('DATABASE')} className="text-blue-600 text-[9px] font-black uppercase tracking-[0.1em]">Database</button>
        </div>
        <div className="space-y-3">
          {records.slice(-3).reverse().map((r, i) => (
            <div key={i} className="bg-white p-4 rounded-2xl border border-slate-100 shadow-sm flex items-center justify-between">
              <div className="flex items-center space-x-3">
                <div className={`w-10 h-10 rounded-xl flex items-center justify-center text-sm ${STATUS_COLORS[r.status]}`}>
                   <i className={`fas ${r.type === 'FLAT' ? 'fa-trash' : r.type === 'FLOOR' ? 'fa-spray-can' : 'fa-building-shield'}`}></i>
                </div>
                <div>
                  <p className="font-bold text-slate-800 text-sm tracking-tight">{r.label}</p>
                  <p className="text-[10px] text-slate-400 font-medium">{new Date(r.lastUpdated || '').toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})}</p>
                </div>
              </div>
              <div className="flex flex-col items-end">
                {r.verifiedByAdmin ? (
                  <span className="text-[8px] bg-emerald-100 text-emerald-700 px-2 py-0.5 rounded-full font-black uppercase mb-1 border border-emerald-200">Verified</span>
                ) : (
                  <span className={`text-[8px] px-2 py-0.5 rounded-full font-black uppercase mb-1 ${STATUS_COLORS[r.status]}`}>{r.status}</span>
                )}
              </div>
            </div>
          ))}
          {records.length === 0 && <div className="text-center py-10 text-slate-300 italic text-sm">Waiting for logs...</div>}
        </div>
      </div>
    </div>
  );

  const renderBlockSelect = () => (
    <div className="p-6 space-y-6 pb-28">
      <div className="flex items-center space-x-3">
        <button onClick={() => setCurrentView('DASHBOARD')} className="p-2 -ml-2 text-slate-400 active:text-slate-900"><i className="fas fa-chevron-left text-xl"></i></button>
        <h1 className="text-2xl font-bold tracking-tight">Select Block</h1>
      </div>
      <div className="grid grid-cols-2 gap-4">
        {SOCIETY_CONFIG.blocks.map(block => (
          <button 
            key={block}
            onClick={() => { setSelectedBlock(block); setCurrentView('FLOOR_SELECT'); }}
            className="h-32 bg-white border border-slate-100 rounded-[2.5rem] flex flex-col items-center justify-center space-y-2 shadow-sm active:bg-blue-50 active:border-blue-200 transition-all group"
          >
            <div className="w-12 h-12 bg-slate-50 text-slate-300 rounded-2xl flex items-center justify-center group-active:bg-blue-100 group-active:text-blue-600 transition-colors">
               <i className="fas fa-city text-xl"></i>
            </div>
            <span className="font-black text-[10px] uppercase tracking-widest text-slate-400 group-active:text-blue-700 transition-colors">{block}</span>
          </button>
        ))}
      </div>
    </div>
  );

  const renderFloorSelect = () => (
    <div className="p-6 space-y-6 pb-28">
      <div className="flex items-center space-x-3 mb-4">
        <button onClick={() => setCurrentView('BLOCK_SELECT')} className="p-2 -ml-2 text-slate-400"><i className="fas fa-chevron-left text-xl"></i></button>
        <h1 className="text-2xl font-bold tracking-tight">{selectedBlock}</h1>
      </div>

      <div className="bg-indigo-900 p-6 rounded-[2.5rem] text-white shadow-xl relative overflow-hidden">
         <div className="absolute top-0 right-0 w-32 h-32 bg-white/5 rounded-full -mr-16 -mt-16 blur-3xl"></div>
         <h3 className="text-[10px] font-black text-indigo-300 uppercase tracking-widest mb-4">Ground Floor Maintenance</h3>
         <button 
            onClick={() => { setSelectedRecordId(`${selectedBlock}-COMMON`); setCurrentView('TASK_DETAIL'); }}
            className="w-full bg-white/10 hover:bg-white/20 p-4 rounded-2xl flex items-center justify-between font-bold border border-white/10 active:scale-95 transition-all"
         >
            <span>Lobby Brooming</span>
            <div className="flex items-center space-x-2">
              <span className="text-[9px] font-black uppercase opacity-60">Daily</span>
              <i className="fas fa-broom text-indigo-300"></i>
            </div>
         </button>
      </div>

      <div className="space-y-4">
        <h3 className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2">Residential Floors</h3>
        <div className="grid grid-cols-4 gap-3">
          {Array.from({ length: SOCIETY_CONFIG.floorsPerBlock }).map((_, i) => (
            <button 
              key={i}
              onClick={() => { setSelectedFloor(i + 1); setCurrentView('FLAT_LIST'); }}
              className="h-16 bg-white border border-slate-100 rounded-2xl flex flex-col items-center justify-center font-bold text-slate-600 active:bg-slate-900 active:text-white transition-all shadow-sm"
            >
              <span className="text-[8px] font-black opacity-40 uppercase">F</span>
              <span className="text-lg leading-none">{i + 1}</span>
            </button>
          ))}
        </div>
      </div>
    </div>
  );

  const renderFlatList = () => {
    const blockNum = selectedBlock ? selectedBlock.split(' ')[1] : '';
    
    return (
      <div className="p-6 space-y-6 pb-28">
        <div className="flex items-center space-x-3 mb-4">
          <button onClick={() => setCurrentView('FLOOR_SELECT')} className="p-2 -ml-2 text-slate-400"><i className="fas fa-chevron-left text-xl"></i></button>
          <div>
            <h1 className="text-2xl font-bold tracking-tight">Floor {selectedFloor}</h1>
            <p className="text-[10px] text-slate-400 uppercase font-black tracking-[0.2em]">{selectedBlock}</p>
          </div>
        </div>

        <div className="bg-white p-5 rounded-[2.5rem] border border-slate-100 shadow-sm">
           <h3 className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-4">Corridor Work</h3>
           <button 
              onClick={() => { setSelectedRecordId(`${selectedBlock}-F${selectedFloor}-COMMON`); setCurrentView('TASK_DETAIL'); }}
              className="w-full bg-emerald-50 text-emerald-800 p-4 rounded-2xl flex items-center justify-between font-bold border border-emerald-100 active:scale-95 transition-all"
           >
              <div className="flex items-center space-x-3">
                <i className="fas fa-bucket"></i>
                <span>Brooming & Mopping</span>
              </div>
              <span className="text-[9px] font-black uppercase opacity-60">Daily</span>
           </button>
        </div>

        <div className="space-y-3">
          <h3 className="text-[10px] font-black text-slate-400 uppercase tracking-widest mt-6">Unit Trash Pickup</h3>
          {Array.from({ length: SOCIETY_CONFIG.flatsPerFloor }).map((_, i) => {
            const wingLetter = String.fromCharCode(65 + i); 
            const flatId = `${blockNum}${wingLetter}${selectedFloor}`; 
            const rec = records.find(r => r.id === flatId);
            return (
              <button 
                key={flatId}
                onClick={() => { setSelectedRecordId(flatId); setCurrentView('TASK_DETAIL'); }}
                className="w-full bg-white p-5 rounded-2xl border border-slate-100 shadow-sm flex items-center justify-between active:scale-[0.98] transition-all"
              >
                <div className="flex items-center space-x-4">
                  <div className={`w-10 h-10 rounded-xl flex items-center justify-center text-lg ${rec ? STATUS_COLORS[rec.status] : 'bg-slate-50 text-slate-200'}`}>
                    <i className="fas fa-door-open"></i>
                  </div>
                  <div className="text-left">
                    <p className="font-bold text-slate-800 text-sm tracking-tight">Unit {flatId}</p>
                    <p className="text-[9px] text-slate-400 font-black uppercase tracking-widest">Garbage Collect</p>
                  </div>
                </div>
                {rec?.status === 'COMPLETED' ? (
                  <div className="w-8 h-8 bg-emerald-100 text-emerald-600 rounded-full flex items-center justify-center">
                    <i className="fas fa-check"></i>
                  </div>
                ) : (
                  <i className="fas fa-chevron-right text-slate-200 text-xs"></i>
                )}
              </button>
            );
          })}
        </div>
      </div>
    );
  };

  const renderTaskDetail = () => {
    let type: RecordType = 'FLAT';
    let label = `Flat ${selectedRecordId}`;
    let b = selectedBlock || '';
    let f = selectedFloor || 0;

    if (selectedRecordId === 'SOCIETY') {
      type = 'SOCIETY';
      label = 'Common Driveway';
    } else if (selectedRecordId?.includes('COMMON')) {
      if (selectedRecordId.includes('-F')) {
        type = 'FLOOR';
        label = `Block ${b.split(' ')[1]} • Floor ${selectedFloor}`;
      } else {
        type = 'BLOCK';
        label = `${selectedBlock} Lobby`;
      }
    }

    const rec = getRecord(selectedRecordId!, type, label, b, f);
    
    const toggleTask = (taskId: string) => {
      const updatedTasks = rec.tasks.map(t => t.id === taskId ? { ...t, isDone: !t.isDone } : t);
      const allDone = updatedTasks.every(t => t.isDone);
      const newStatus = allDone ? TaskStatus.COMPLETED : TaskStatus.IN_PROGRESS;
      updateRecord({ ...rec, tasks: updatedTasks, status: newStatus });
    };

    const handleNotesChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
      updateRecord({ ...rec, notes: e.target.value });
    };

    const handleAdminVerify = () => {
      updateRecord({ ...rec, verifiedByAdmin: !rec.verifiedByAdmin });
    };

    return (
      <div className="min-h-screen bg-slate-50 pb-28 flex flex-col">
        <header className="bg-white p-6 sticky top-0 z-10 shadow-sm border-b flex items-center justify-between">
           <button onClick={() => setCurrentView(type === 'FLAT' || type === 'FLOOR' ? 'FLAT_LIST' : type === 'BLOCK' ? 'FLOOR_SELECT' : 'DASHBOARD')} className="p-2 -ml-2 text-slate-400"><i className="fas fa-arrow-left"></i></button>
           <div className="text-center flex-1">
             <h2 className="font-bold text-slate-800 text-lg">{rec.label}</h2>
             <p className="text-[9px] text-slate-400 font-black uppercase tracking-[0.2em]">{type} LOG</p>
           </div>
           <div className={`w-3 h-3 rounded-full ${rec.status === 'COMPLETED' ? 'bg-emerald-500' : 'bg-slate-300'}`}></div>
        </header>

        <div className="p-6 space-y-6 flex-1">
          <div className="bg-white rounded-[2rem] border border-slate-100 overflow-hidden shadow-sm">
            {rec.tasks.map((task) => (
              <div 
                key={task.id} 
                onClick={() => toggleTask(task.id)}
                className={`p-6 flex items-center justify-between border-b last:border-0 active:bg-slate-50 transition-colors ${task.isDone ? 'bg-emerald-50/10' : ''}`}
              >
                <div className="flex flex-col">
                  <span className={`text-sm font-bold text-slate-700 ${task.isDone ? 'line-through opacity-40' : ''}`}>{task.label}</span>
                  <span className="text-[9px] text-slate-400 font-black uppercase mt-1 tracking-widest">{task.label.includes('Daily') ? 'Required: Daily' : 'Required: Weekly'}</span>
                </div>
                <div className={`w-8 h-8 rounded-xl border-2 flex items-center justify-center transition-all ${task.isDone ? 'bg-emerald-500 border-emerald-500 text-white' : 'border-slate-100 text-transparent'}`}>
                  <i className="fas fa-check text-sm"></i>
                </div>
              </div>
            ))}
          </div>

          <div className="space-y-4">
             <h3 className="text-[10px] font-black text-slate-400 uppercase tracking-widest ml-1">Staff Observation</h3>
             <textarea 
               value={rec.notes}
               onChange={handleNotesChange}
               placeholder="Add remarks (e.g., 'Locked flat', 'Water leakage found')..."
               className="w-full h-32 bg-white border border-slate-100 rounded-[1.5rem] p-5 text-sm text-slate-700 outline-none shadow-sm focus:ring-2 focus:ring-blue-500 transition-all resize-none"
             />
          </div>

          <div className="grid grid-cols-2 gap-4">
             <button 
               onClick={() => updateRecord({...rec, status: TaskStatus.ISSUE})}
               className="bg-rose-50 text-rose-700 p-4 rounded-2xl font-black text-[10px] uppercase tracking-widest active:scale-95 transition-all border border-rose-100"
             >
                <i className="fas fa-triangle-exclamation block mb-2 text-xl"></i>
                Flag Issue
             </button>
             <button 
               onClick={() => setCurrentView(type === 'FLAT' || type === 'FLOOR' ? 'FLAT_LIST' : type === 'BLOCK' ? 'FLOOR_SELECT' : 'DASHBOARD')}
               className="bg-slate-900 text-white p-4 rounded-2xl font-black text-[10px] uppercase tracking-widest active:scale-95 transition-all shadow-lg"
             >
                <i className="fas fa-check-double block mb-2 text-xl"></i>
                Submit Log
             </button>
          </div>

          <div className="pt-6 border-t border-slate-200 mt-4">
             <div className="bg-slate-100 p-6 rounded-[2rem] border border-slate-200 flex items-center justify-between">
                <div>
                   <h4 className="font-black text-[10px] uppercase text-slate-500 tracking-[0.2em]">Admin Audit</h4>
                   <p className="text-xs text-slate-700 font-bold mt-1">Verified by Supervisor</p>
                </div>
                <button 
                  onClick={handleAdminVerify}
                  className={`w-14 h-14 rounded-2xl flex items-center justify-center text-2xl transition-all ${rec.verifiedByAdmin ? 'bg-emerald-600 text-white shadow-xl rotate-[15deg]' : 'bg-white text-slate-200 border border-slate-300'}`}
                >
                  <i className="fas fa-stamp"></i>
                </button>
             </div>
          </div>
        </div>
      </div>
    );
  };

  const renderDatabase = () => (
    <div className="min-h-screen bg-slate-50 pb-28">
      <header className="bg-white p-6 sticky top-0 z-10 shadow-sm border-b">
        <h1 className="text-2xl font-bold text-slate-800 tracking-tight">System Audit Log</h1>
        <p className="text-[10px] text-slate-400 font-black uppercase tracking-widest mt-1 mb-6">Local DB (v5.0)</p>
        
        <div className="relative">
           <i className="fas fa-search absolute left-4 top-1/2 -translate-y-1/2 text-slate-400"></i>
           <input 
              type="text" 
              placeholder="Search Block, Flat, or Keyword..." 
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full bg-slate-50 border border-slate-100 rounded-2xl py-3 pl-12 pr-4 text-sm focus:ring-2 focus:ring-blue-500 outline-none transition-all"
           />
        </div>
      </header>

      <div className="p-4 space-y-4">
        {filteredDatabaseRecords.length === 0 ? (
          <div className="text-center py-20 text-slate-300">
             <i className="fas fa-box-open text-4xl mb-4 opacity-10"></i>
             <p className="text-sm font-bold uppercase tracking-widest">No matching logs</p>
          </div>
        ) : (
          filteredDatabaseRecords.map((r, i) => (
            <div 
              key={i} 
              onClick={() => {
                setSelectedRecordId(r.id);
                setSelectedBlock(r.block || null);
                setSelectedFloor(r.floor || null);
                setCurrentView('TASK_DETAIL');
              }}
              className="bg-white p-5 rounded-[2rem] border border-slate-100 shadow-sm space-y-4 active:bg-slate-50 transition-colors"
            >
              <div className="flex justify-between items-start">
                 <div>
                    <h4 className="font-bold text-slate-800 text-base">{r.label}</h4>
                    <p className="text-[9px] font-black text-slate-400 uppercase tracking-widest">{r.type} • ID: {r.id}</p>
                 </div>
                 <div className="flex flex-col items-end">
                    {r.verifiedByAdmin ? (
                      <span className="text-[8px] bg-emerald-500 text-white px-2 py-0.5 rounded-full font-black uppercase flex items-center"><i className="fas fa-shield-check mr-1"></i>Verified</span>
                    ) : (
                      <span className={`text-[8px] px-2 py-0.5 rounded-full font-black uppercase ${STATUS_COLORS[r.status]}`}>{r.status}</span>
                    )}
                 </div>
              </div>
              
              {r.notes && (
                <div className="p-4 bg-slate-50 rounded-2xl text-[11px] text-slate-600 border-l-4 border-slate-200 font-medium">
                  {r.notes}
                </div>
              )}
              
              <div className="flex justify-between items-center text-[10px] text-slate-400 border-t border-slate-50 pt-3">
                 <span className="font-bold uppercase tracking-tight">Sync Time: {new Date(r.lastUpdated || '').toLocaleString([], {month:'short', day:'numeric', hour:'2-digit', minute:'2-digit'})}</span>
                 <i className="fas fa-eye text-slate-200"></i>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );

  const renderAIReport = () => (
    <div className="min-h-screen bg-slate-50 pb-28">
      <header className="bg-white p-6 sticky top-0 z-10 shadow-sm border-b flex items-center space-x-3">
        <button onClick={() => setCurrentView('DASHBOARD')} className="p-2 -ml-2 text-slate-400"><i className="fas fa-chevron-left"></i></button>
        <h1 className="text-xl font-bold tracking-tight">Operations Intelligence</h1>
      </header>
      <div className="p-6">
        <div className="bg-white p-8 rounded-[3rem] border border-slate-100 shadow-2xl prose prose-slate max-w-none">
           <div className="flex items-center space-x-3 text-blue-600 mb-8">
              <div className="w-12 h-12 bg-blue-50 rounded-2xl flex items-center justify-center text-2xl">
                 <i className="fas fa-brain-circuit"></i>
              </div>
              <div>
                <span className="font-black text-[10px] tracking-[0.3em] uppercase block">AI Analysis</span>
                <span className="text-xs font-bold text-slate-400">Gemini Flash 3</span>
              </div>
           </div>
           <div className="whitespace-pre-wrap text-slate-700 text-sm leading-relaxed font-medium">
             {aiReport || "Scanning local records and analyzing housekeeping efficiency..."}
           </div>
        </div>
        <button 
          onClick={() => setCurrentView('DASHBOARD')}
          className="w-full mt-10 bg-blue-600 text-white p-5 rounded-[2rem] font-black text-xs uppercase tracking-[0.2em] shadow-xl shadow-blue-100 active:scale-95 transition-all"
        >
          Return to Hub
        </button>
      </div>
    </div>
  );

  return (
    <div className="max-w-md mx-auto bg-slate-50 min-h-screen relative shadow-2xl overflow-hidden flex flex-col font-sans">
      <div className="flex-1 overflow-y-auto">
        {currentView === 'DASHBOARD' && renderDashboard()}
        {currentView === 'BLOCK_SELECT' && renderBlockSelect()}
        {currentView === 'FLOOR_SELECT' && renderFloorSelect()}
        {currentView === 'FLAT_LIST' && renderFlatList()}
        {currentView === 'TASK_DETAIL' && renderTaskDetail()}
        {currentView === 'AI_REPORT' && renderAIReport()}
        {currentView === 'DATABASE' && renderDatabase()}
      </div>

      <nav className="fixed bottom-0 left-0 right-0 max-w-md mx-auto bg-white/95 backdrop-blur-xl border-t border-slate-100 flex items-center justify-around py-4 pb-8 z-50 shadow-[0_-10px_40px_-15px_rgba(0,0,0,0.1)]">
        <button 
          onClick={() => setCurrentView('DASHBOARD')} 
          className={`flex flex-col items-center space-y-1.5 flex-1 transition-all ${currentView === 'DASHBOARD' ? 'text-blue-600 scale-110' : 'text-slate-300'}`}
        >
          <i className="fas fa-compass text-xl"></i>
          <span className="text-[8px] font-black uppercase tracking-widest">Dash</span>
        </button>
        
        <button 
          onClick={() => setCurrentView('BLOCK_SELECT')} 
          className={`flex flex-col items-center space-y-1.5 flex-1 transition-all ${['BLOCK_SELECT', 'FLOOR_SELECT', 'FLAT_LIST', 'TASK_DETAIL'].includes(currentView) ? 'text-blue-600 scale-110' : 'text-slate-300'}`}
        >
          <i className="fas fa-scanner-gun text-xl"></i>
          <span className="text-[8px] font-black uppercase tracking-widest">Tasks</span>
        </button>

        <button 
          onClick={() => setCurrentView('DATABASE')} 
          className={`flex flex-col items-center space-y-1.5 flex-1 transition-all ${currentView === 'DATABASE' ? 'text-blue-600 scale-110' : 'text-slate-300'}`}
        >
          <i className="fas fa-database text-xl"></i>
          <span className="text-[8px] font-black uppercase tracking-widest">Audit</span>
        </button>

        <button 
          onClick={handleGenerateAIReport} 
          disabled={isGeneratingReport}
          className={`flex flex-col items-center space-y-1.5 flex-1 transition-all ${currentView === 'AI_REPORT' ? 'text-blue-600 scale-110' : 'text-slate-300'} disabled:opacity-20`}
        >
          {isGeneratingReport ? <i className="fas fa-spinner fa-spin text-xl"></i> : <i className="fas fa-microchip-ai text-xl"></i>}
          <span className="text-[8px] font-black uppercase tracking-widest">Insights</span>
        </button>
      </nav>
    </div>
  );
};

export default App;
