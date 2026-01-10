import { useState, useEffect, useCallback, useRef } from 'react';
import * as faceDetectionService from '../services/faceDetectionService';
import useAppStore from '../store/appStore';

/**
 * Hook for head tracking functionality
 * @returns {Object} Head tracking state and controls
 */
export default function useHeadTracking() {
  const {
    isHeadTrackingActive,
    setHeadTrackingActive,
    setHeadPosition,
    headTrackingSensitivity,
    settings,
  } = useAppStore();

  const [isInitialized, setIsInitialized] = useState(false);
  const [currentHeadPosition, setCurrentHeadPosition] = useState({ x: 0, y: 0, z: 0 });
  const [trackingError, setTrackingError] = useState(null);
  const positionHistoryRef = useRef([]);

  // Initialize face detection service
  useEffect(() => {
    let mounted = true;

    const initialize = async () => {
      try {
        if (settings.headTrackingEnabled) {
          await faceDetectionService.initializeFaceDetection();
          if (mounted) {
            setIsInitialized(true);
          }
        }
      } catch (error) {
        console.error('Failed to initialize head tracking:', error);
        if (mounted) {
          setTrackingError(error.message);
        }
      }
    };

    initialize();

    return () => {
      mounted = false;
    };
  }, [settings.headTrackingEnabled]);

  // Start/stop tracking based on active state
  useEffect(() => {
    let mounted = true;

    const handleTracking = async () => {
      if (!isInitialized || !settings.headTrackingEnabled) {
        return;
      }

      try {
        if (isHeadTrackingActive) {
          await faceDetectionService.startHeadTracking((position) => {
            if (mounted) {
              handleHeadPositionUpdate(position);
            }
          });
        } else {
          await faceDetectionService.stopHeadTracking();
        }
      } catch (error) {
        console.error('Tracking error:', error);
        if (mounted) {
          setTrackingError(error.message);
        }
      }
    };

    handleTracking();

    return () => {
      mounted = false;
    };
  }, [isHeadTrackingActive, isInitialized, settings.headTrackingEnabled]);

  /**
   * Handle head position updates with smoothing
   */
  const handleHeadPositionUpdate = useCallback((position) => {
    if (!position) return;

    // Apply smoothing to reduce jitter
    const smoothedX = smoothValue(position.x, 'x');
    const smoothedY = smoothValue(position.y, 'y');
    const smoothedZ = smoothValue(position.z || 0, 'z');

    const smoothedPosition = {
      x: smoothedX,
      y: smoothedY,
      z: smoothedZ,
    };

    // Apply sensitivity
    const adjustedPosition = {
      x: (smoothedX - 0.5) * 2 * headTrackingSensitivity,
      y: (smoothedY - 0.5) * 2 * headTrackingSensitivity,
      z: smoothedZ,
    };

    // Clamp to valid range
    const clampedPosition = {
      x: Math.max(-1, Math.min(1, adjustedPosition.x)),
      y: Math.max(-1, Math.min(1, adjustedPosition.y)),
      z: adjustedPosition.z,
    };

    setCurrentHeadPosition(clampedPosition);
    setHeadPosition(clampedPosition);
  }, [headTrackingSensitivity, setHeadPosition]);

  /**
   * Smooth value using moving average
   */
  const smoothValue = useCallback((newValue, axis) => {
    const history = positionHistoryRef.current;
    
    if (!history[axis]) {
      history[axis] = [];
    }
    
    history[axis].push(newValue);
    
    // Keep last 5 values
    if (history[axis].length > 5) {
      history[axis].shift();
    }
    
    // Calculate average
    const sum = history[axis].reduce((acc, val) => acc + val, 0);
    return sum / history[axis].length;
  }, []);

  /**
   * Manually update head position (for testing)
   */
  const setManualHeadPosition = useCallback((position) => {
    const clampedPosition = {
      x: Math.max(-1, Math.min(1, position.x)),
      y: Math.max(-1, Math.min(1, position.y)),
      z: position.z || 0,
    };
    
    setCurrentHeadPosition(clampedPosition);
    setHeadPosition(clampedPosition);
  }, [setHeadPosition]);

  /**
   * Reset head position to center
   */
  const resetHeadPosition = useCallback(() => {
    const resetPosition = { x: 0, y: 0, z: 0 };
    setCurrentHeadPosition(resetPosition);
    setHeadPosition(resetPosition);
    
    // Clear position history
    positionHistoryRef.current = { x: [], y: [], z: [] };
  }, [setHeadPosition]);

  return {
    isInitialized,
    currentHeadPosition,
    trackingError,
    setManualHeadPosition,
    resetHeadPosition,
    isActive: isHeadTrackingActive,
  };
}
