import React, { useEffect, useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Image,
  ActivityIndicator,
  Dimensions,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { Ionicons } from '@expo/vector-icons';
import useAppStore from '../store/appStore';
import { generateDepthMap } from '../services/depthEstimationService';
import { create3DModel } from '../services/3dModelingService';

const { width } = Dimensions.get('window');

const ProcessingScreen = () => {
  const navigation = useNavigation();
  const {
    selectedImage,
    processingProgress,
    setProcessingProgress,
    setProcessedDepthMap,
    setProcessed3DModel,
    setProcessing,
    setProcessingError,
    resetProcessing,
  } = useAppStore();
  const processingIntervalRef = useRef(null);

  useEffect(() => {
    startProcessing();
    return () => {
      if (processingIntervalRef.current) {
        clearInterval(processingIntervalRef.current);
      }
    };
  }, []);

  const startProcessing = async () => {
    try {
      setProcessing(true);
      setProcessingError(null);
      setProcessingProgress(0);

      // Simulate processing progress
      processingIntervalRef.current = setInterval(() => {
        setProcessingProgress(prev => {
          if (prev >= 90) {
            clearInterval(processingIntervalRef.current);
            return 90;
          }
          return prev + Math.random() * 5;
        });
      }, 200);

      // Step 1: Generate depth map (simulated)
      const depthMap = await generateDepthMap(selectedImage.uri);
      setProcessedDepthMap(depthMap);
      setProcessingProgress(50);

      // Step 2: Create 3D model (simulated)
      const model3D = await create3DModel(selectedImage.uri, depthMap);
      setProcessed3DModel(model3D);
      setProcessingProgress(100);

      // Clear interval and navigate
      if (processingIntervalRef.current) {
        clearInterval(processingIntervalRef.current);
      }

      setProcessing(false);

      // Navigate to 3D viewer after short delay
      setTimeout(() => {
        navigation.replace('Viewer3D');
      }, 500);

    } catch (error) {
      console.error('Processing error:', error);
      setProcessingError(error.message);
      setProcessing(false);
      if (processingIntervalRef.current) {
        clearInterval(processingIntervalRef.current);
      }
    }
  };

  const getProcessingStep = () => {
    if (processingProgress < 30) {
      return {
        step: 'Analyzing Image',
        icon: 'scan',
        description: 'Detecting objects and edges...',
      };
    } else if (processingProgress < 60) {
      return {
        step: 'Generating Depth Map',
        icon: 'layers',
        description: 'Estimating depth using AI model...',
      };
    } else if (processingProgress < 90) {
      return {
        step: 'Creating 3D Model',
        icon: 'cube',
        description: 'Building 3D point cloud and mesh...',
      };
    } else {
      return {
        step: 'Finalizing',
        icon: 'checkmark-circle',
        description: 'Preparing 3D viewer...',
      };
    }
  };

  const { step, icon, description } = getProcessingStep();

  return (
    <View style={styles.container}>
      <View style={styles.content}>
        {/* Original Image Preview */}
        <View style={styles.imageContainer}>
          {selectedImage && (
            <Image source={{ uri: selectedImage.uri }} style={styles.previewImage} />
          )}
          <View style={styles.imageOverlay} />
        </View>

        {/* Processing Status */}
        <View style={styles.statusContainer}>
          <View style={styles.iconContainer}>
            <Ionicons name={icon} size={48} color="#2196F3" />
          </View>

          <Text style={styles.stepText}>{step}</Text>
          <Text style={styles.descriptionText}>{description}</Text>

          {/* Progress Bar */}
          <View style={styles.progressContainer}>
            <View style={styles.progressBackground}>
              <View 
                style={[
                  styles.progressFill, 
                  { width: `${processingProgress}%` }
                ]} 
              />
            </View>
            <Text style={styles.progressText}>
              {Math.round(processingProgress)}%
            </Text>
          </View>

          {/* Processing Steps */}
          <View style={styles.stepsList}>
            <View style={[
              styles.stepItem,
              processingProgress >= 0 && styles.stepItemActive
            ]}>
              <Ionicons 
                name="scan" 
                size={20} 
                color={processingProgress > 30 ? '#4CAF50' : '#2196F3'} 
              />
              <Text style={[
                styles.stepItemText,
                processingProgress > 30 && styles.stepItemTextCompleted
              ]}>
                Analyze Image
              </Text>
            </View>

            <View style={[
              styles.stepItem,
              processingProgress >= 30 && styles.stepItemActive
            ]}>
              <Ionicons 
                name="layers" 
                size={20} 
                color={processingProgress > 60 ? '#4CAF50' : '#2196F3'} 
              />
              <Text style={[
                styles.stepItemText,
                processingProgress > 60 && styles.stepItemTextCompleted
              ]}>
                Generate Depth
              </Text>
            </View>

            <View style={[
              styles.stepItem,
              processingProgress >= 60 && styles.stepItemActive
            ]}>
              <Ionicons 
                name="cube" 
                size={20} 
                color={processingProgress > 90 ? '#4CAF50' : '#2196F3'} 
              />
              <Text style={[
                styles.stepItemText,
                processingProgress > 90 && styles.stepItemTextCompleted
              ]}>
                Create 3D Model
              </Text>
            </View>

            <View style={[
              styles.stepItem,
              processingProgress >= 90 && styles.stepItemActive
            ]}>
              <Ionicons 
                name="checkmark-circle" 
                size={20} 
                color={processingProgress >= 100 ? '#4CAF50' : '#2196F3'} 
              />
              <Text style={[
                styles.stepItemText,
                processingProgress >= 100 && styles.stepItemTextCompleted
              ]}>
                Complete
              </Text>
            </View>
          </View>
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  content: {
    flex: 1,
  },
  imageContainer: {
    position: 'relative',
    width: width,
    height: width * 0.75,
  },
  previewImage: {
    width: '100%',
    height: '100%',
    resizeMode: 'cover',
  },
  imageOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(33, 150, 243, 0.2)',
  },
  statusContainer: {
    flex: 1,
    backgroundColor: 'white',
    borderTopLeftRadius: 32,
    borderTopRightRadius: 32,
    marginTop: -32,
    padding: 32,
    elevation: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: -4 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
  },
  iconContainer: {
    width: 100,
    height: 100,
    borderRadius: 50,
    backgroundColor: '#E3F2FD',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 24,
  },
  stepText: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    textAlign: 'center',
    marginBottom: 8,
  },
  descriptionText: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
    marginBottom: 32,
  },
  progressContainer: {
    marginBottom: 32,
  },
  progressBackground: {
    height: 8,
    backgroundColor: '#E0E0E0',
    borderRadius: 4,
    overflow: 'hidden',
    marginBottom: 8,
  },
  progressFill: {
    height: '100%',
    backgroundColor: '#2196F3',
    borderRadius: 4,
  },
  progressText: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#2196F3',
    textAlign: 'center',
  },
  stepsList: {
    gap: 16,
  },
  stepItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    backgroundColor: '#F5F5F5',
    borderRadius: 12,
    opacity: 0.5,
  },
  stepItemActive: {
    opacity: 1,
    backgroundColor: '#E3F2FD',
  },
  stepItemText: {
    marginLeft: 12,
    fontSize: 16,
    color: '#666',
  },
  stepItemTextCompleted: {
    color: '#4CAF50',
    fontWeight: '600',
  },
});

export default ProcessingScreen;
