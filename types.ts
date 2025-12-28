
export enum TaskStatus {
  PENDING = 'PENDING',
  IN_PROGRESS = 'IN_PROGRESS',
  COMPLETED = 'COMPLETED',
  ISSUE = 'ISSUE'
}

export type RecordType = 'SOCIETY' | 'BLOCK' | 'FLOOR' | 'FLAT';

export interface HousekeepingTask {
  id: string;
  label: string;
  isDone: boolean;
}

export interface HousekeepingRecord {
  id: string; // Unique ID (e.g., 'SOCIETY', 'B1', 'B1-F1', '1B1')
  type: RecordType;
  label: string;
  status: TaskStatus;
  tasks: HousekeepingTask[];
  notes: string;
  lastUpdated?: string;
  verifiedByAdmin?: boolean;
  adminNotes?: string;
  block?: string;
  floor?: number;
}

export interface SocietyStructure {
  blocks: string[];
  floorsPerBlock: number;
  flatsPerFloor: number;
}

export type ViewState = 'DASHBOARD' | 'BLOCK_SELECT' | 'FLOOR_SELECT' | 'FLAT_LIST' | 'TASK_DETAIL' | 'AI_REPORT' | 'DATABASE';
