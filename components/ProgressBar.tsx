
import React from 'react';

interface ProgressBarProps {
  percentage: number;
  label?: string;
  color?: string;
}

const ProgressBar: React.FC<ProgressBarProps> = ({ percentage, label, color = 'bg-blue-600' }) => {
  return (
    <div className="w-full">
      {label && <div className="flex justify-between mb-1 text-sm font-medium text-slate-700">
        <span>{label}</span>
        <span>{Math.round(percentage)}%</span>
      </div>}
      <div className="w-full bg-slate-200 rounded-full h-2.5">
        <div 
          className={`${color} h-2.5 rounded-full transition-all duration-500`} 
          style={{ width: `${percentage}%` }}
        ></div>
      </div>
    </div>
  );
};

export default ProgressBar;
