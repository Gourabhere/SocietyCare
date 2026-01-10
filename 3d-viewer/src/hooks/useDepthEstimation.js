import { useState, useEffect, useCallback } from 'react';
import * as depthEstimationService from '../services/depthEstimationService';
import useAppStore from '../store/appStore';

/**
 * Hook for depth estimation functionality
 * @returns {Object} Depth estimation state and functions
 */
export default function useDepthEstimation() {
  const {
    selectedImage,
    processedDepthMap,
    setProcessedDepthMap,
    setProcessingProgress,
    isProcessing,
    setProcessing,
    processingError,
    setProcessingError,
  } = useAppStore();

  const [depthMapQuality, setDepthMapQuality] = useState('medium');
  const [processingTime, setProcessingTime] = useState(null);

  /**
   * Generate depth map from selected image
   */
  const generateDepthMap = useCallback(async () => {
    if (!selectedImage) {
      setProcessingError('No image selected');
      return;
    }

    try {
      setProcessing(true);
      setProcessingError(null);
      setProcessingProgress(0);

      const startTime = Date.now();

      // Simulate progress updates
      const progressInterval = setInterval(() => {
        setProcessingProgress((prev) => Math.min(prev + 10, 90));
      }, 200);

      // Generate depth map
      const depthMap = await depthEstimationService.generateDepthMap(
        selectedImage.uri
      );

      clearInterval(progressInterval);
      
      const endTime = Date.now();
      setProcessingTime(endTime - startTime);

      setProcessedDepthMap(depthMap);
      setProcessingProgress(100);
      setProcessing(false);

      return depthMap;

    } catch (error) {
      console.error('Depth estimation error:', error);
      setProcessingError(error.message);
      setProcessing(false);
      setProcessingProgress(0);
      return null;
    }
  }, [
    selectedImage,
    setProcessedDepthMap,
    setProcessingProgress,
    setProcessing,
    setProcessingError,
  ]);

  /**
   * Validate depth map
   */
  const validateDepthMap = useCallback(() => {
    if (!processedDepthMap) {
      return { isValid: false, error: 'No depth map generated' };
    }

    const isValid = depthEstimationService.validateDepthMap(processedDepthMap);
    
    if (!isValid) {
      return { isValid: false, error: 'Invalid depth map' };
    }

    return { isValid: true, error: null };
  }, [processedDepthMap]);

  /**
   * Normalize depth map
   */
  const normalizeDepthMap = useCallback(() => {
    if (!processedDepthMap) {
      return null;
    }

    return depthEstimationService.normalizeDepthMap(processedDepthMap);
  }, [processedDepthMap]);

  /**
   * Export depth map as image
   */
  const exportDepthMap = useCallback(async () => {
    if (!processedDepthMap) {
      console.error('No depth map to export');
      return null;
    }

    try {
      const imageBuffer = await depthEstimationService.exportDepthMapAsImage(
        processedDepthMap
      );
      
      console.log('Depth map exported');
      return imageBuffer;
      
    } catch (error) {
      console.error('Export error:', error);
      return null;
    }
  }, [processedDepthMap]);

  /**
   * Get depth map statistics
   */
  const getDepthStats = useCallback(() => {
    if (!processedDepthMap || !processedDepthMap.data) {
      return null;
    }

    const { data, minDepth, maxDepth } = processedDepthMap;
    
    const sum = data.reduce((acc, val) => acc + val, 0);
    const avgDepth = sum / data.length;
    
    // Calculate standard deviation
    const variance = data.reduce((acc, val) => {
      return acc + Math.pow(val - avgDepth, 2);
    }, 0) / data.length;
    const stdDev = Math.sqrt(variance);

    return {
      min: minDepth,
      max: maxDepth,
      average: avgDepth,
      standardDeviation: stdDev,
      pointCount: data.length,
      width: processedDepthMap.width,
      height: processedDepthMap.height,
      processingTime,
    };
  }, [processedDepthMap, processingTime]);

  /**
   * Reset depth estimation state
   */
  const resetDepthEstimation = useCallback(() => {
    setProcessedDepthMap(null);
    setProcessingProgress(0);
    setProcessingError(null);
    setProcessingTime(null);
  }, [
    setProcessedDepthMap,
    setProcessingProgress,
    setProcessingError,
  ]);

  return {
    processedDepthMap,
    isProcessing,
    processingError,
    processingTime,
    depthMapQuality,
    setDepthMapQuality,
    generateDepthMap,
    validateDepthMap,
    normalizeDepthMap,
    exportDepthMap,
    getDepthStats,
    resetDepthEstimation,
  };
}
