import { useState, useEffect, useCallback } from 'react';
import { useCameraPermissions } from 'expo-camera';

/**
 * Hook for managing camera permissions
 * @returns {Object} Permission state and helper functions
 */
export default function useCameraPermissions() {
  const [permission, requestPermission] = useCameraPermissions();
  const [hasPermission, setHasPermission] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    if (permission) {
      setHasPermission(permission.granted);
      setIsLoading(false);
    }
  }, [permission]);

  const requestCameraPermission = useCallback(async () => {
    try {
      const result = await requestPermission();
      setHasPermission(result.granted);
      return result.granted;
    } catch (error) {
      console.error('Failed to request camera permission:', error);
      return false;
    }
  }, [requestPermission]);

  return {
    hasPermission,
    isLoading,
    requestCameraPermission,
    permission,
  };
}
