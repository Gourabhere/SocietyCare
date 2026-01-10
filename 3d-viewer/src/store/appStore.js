import create from 'zustand';

const useAppStore = create((set, get) => ({
  // Image state
  selectedImage: null,
  processedDepthMap: null,
  processed3DModel: null,
  processingProgress: 0,
  isProcessing: false,
  processingError: null,

  // Head tracking state
  headPosition: { x: 0, y: 0, z: 0 },
  isHeadTrackingActive: false,
  headTrackingSensitivity: 1.0,

  // Settings
  settings: {
    cameraResolution: 'high',
    depthModelQuality: 'medium', // low, medium, high
    headTrackingEnabled: true,
    autoPlay: true,
    showFPS: false,
  },

  // Actions
  setSelectedImage: (image) => set({ selectedImage: image }),
  
  setProcessedDepthMap: (depthMap) => set({ processedDepthMap: depthMap }),
  
  setProcessed3DModel: (model) => set({ processed3DModel: model }),
  
  setProcessingProgress: (progress) => set({ processingProgress: progress }),
  
  setProcessing: (isProcessing) => set({ isProcessing }),
  
  setProcessingError: (error) => set({ processingError: error }),

  setHeadPosition: (position) => set({ headPosition: position }),
  
  setHeadTrackingActive: (isActive) => set({ isHeadTrackingActive: isActive }),
  
  setHeadTrackingSensitivity: (sensitivity) => set({ headTrackingSensitivity: sensitivity }),

  updateSettings: (newSettings) => set((state) => ({
    settings: { ...state.settings, ...newSettings }
  })),

  resetProcessing: () => set({
    processedDepthMap: null,
    processed3DModel: null,
    processingProgress: 0,
    isProcessing: false,
    processingError: null,
  }),

  resetAll: () => set({
    selectedImage: null,
    processedDepthMap: null,
    processed3DModel: null,
    processingProgress: 0,
    isProcessing: false,
    processingError: null,
    headPosition: { x: 0, y: 0, z: 0 },
    isHeadTrackingActive: false,
  }),
}));

export default useAppStore;
