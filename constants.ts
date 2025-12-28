
import { SocietyStructure, TaskStatus } from './types';

export const SOCIETY_CONFIG: SocietyStructure = {
  blocks: ['Block 1', 'Block 2', 'Block 3', 'Block 4', 'Block 5', 'Block 6'],
  floorsPerBlock: 12,
  flatsPerFloor: 5
};

export const TIERED_TASKS = {
  SOCIETY: [
    "Driveway Brooming (Weekly)"
  ],
  BLOCK: [
    "Ground Floor Lobby Brooming (Daily)"
  ],
  FLOOR: [
    "Residential Floor Brooming (Daily)",
    "Residential Floor Mopping (Daily)"
  ],
  FLAT: [
    "Door-to-Door Garbage Collection (Daily)"
  ]
};

export const STATUS_COLORS = {
  [TaskStatus.PENDING]: 'bg-slate-200 text-slate-700',
  [TaskStatus.IN_PROGRESS]: 'bg-blue-100 text-blue-700',
  [TaskStatus.COMPLETED]: 'bg-emerald-100 text-emerald-700',
  [TaskStatus.ISSUE]: 'bg-rose-100 text-rose-700'
};
