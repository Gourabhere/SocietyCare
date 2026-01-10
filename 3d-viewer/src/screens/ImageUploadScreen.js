import React, { useState, useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Image,
  Alert,
  ActivityIndicator,
  SafeAreaView,
} from 'react-native';
import { useNavigation, useRoute } from '@react-navigation/native';
import { CameraView, useCameraPermissions } from 'expo-camera';
import * as ImagePicker from 'expo-image-picker';
import { Ionicons } from '@expo/vector-icons';
import useAppStore from '../store/appStore';

const ImageUploadScreen = () => {
  const navigation = useNavigation();
  const route = useRoute();
  const { mode } = route.params || { mode: null };
  const [permission, requestPermission] = useCameraPermissions();
  const [facing, setFacing] = useState('back');
  const [isCapturing, setIsCapturing] = useState(false);
  const cameraRef = useRef(null);
  const { setSelectedImage } = useAppStore();

  const handleImageSelected = (uri) => {
    setSelectedImage({ uri });
    navigation.navigate('Processing');
  };

  const pickFromGallery = async () => {
    try {
      const result = await ImagePicker.launchImageLibraryAsync({
        mediaTypes: ImagePicker.MediaTypeOptions.Images,
        allowsEditing: true,
        aspect: [4, 3],
        quality: 0.8,
      });

      if (!result.canceled && result.assets && result.assets[0]) {
        handleImageSelected(result.assets[0].uri);
      }
    } catch (error) {
      Alert.alert('Error', 'Failed to pick image from gallery');
      console.error(error);
    }
  };

  const takePicture = async () => {
    if (!cameraRef.current) return;

    try {
      setIsCapturing(true);
      const photo = await cameraRef.current.takePictureAsync({
        quality: 0.8,
        skipProcessing: false,
      });

      if (photo?.uri) {
        handleImageSelected(photo.uri);
      }
    } catch (error) {
      Alert.alert('Error', 'Failed to capture image');
      console.error(error);
    } finally {
      setIsCapturing(false);
    }
  };

  const toggleCameraFacing = () => {
    setFacing(current => (current === 'back' ? 'front' : 'back'));
  };

  if (!permission) {
    return (
      <View style={styles.container}>
        <ActivityIndicator size="large" color="#2196F3" />
      </View>
    );
  }

  if (!permission.granted) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.permissionContainer}>
          <Ionicons name="camera-outline" size={64} color="#2196F3" />
          <Text style={styles.permissionTitle}>Camera Permission Required</Text>
          <Text style={styles.permissionText}>
            We need your permission to use the camera to capture images for 3D conversion.
          </Text>
          <TouchableOpacity style={styles.permissionButton} onPress={requestPermission}>
            <Text style={styles.permissionButtonText}>Grant Permission</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.galleryButton} onPress={pickFromGallery}>
            <Text style={styles.galleryButtonText}>Or Use Gallery</Text>
          </TouchableOpacity>
        </View>
      </SafeAreaView>
    );
  }

  // If mode is gallery or user wants to pick from gallery
  if (mode === 'gallery') {
    pickFromGallery();
    return (
      <View style={styles.container}>
        <ActivityIndicator size="large" color="#2196F3" />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <CameraView 
        ref={cameraRef}
        style={styles.camera}
        facing={facing}
      >
        <View style={styles.overlay}>
          {/* Top Controls */}
          <View style={styles.topControls}>
            <TouchableOpacity 
              style={styles.backButton} 
              onPress={() => navigation.goBack()}
            >
              <Ionicons name="arrow-back" size={24} color="white" />
            </TouchableOpacity>
            <TouchableOpacity 
              style={styles.galleryButtonTop}
              onPress={pickFromGallery}
            >
              <Ionicons name="images" size={24} color="white" />
            </TouchableOpacity>
          </View>

          {/* Center Guide */}
          <View style={styles.guideContainer}>
            <View style={styles.guideFrame}>
              <View style={styles.guideCorner} />
              <View style={[styles.guideCorner, { right: 0 }]} />
              <View style={[styles.guideCorner, { bottom: 0 }]} />
              <View style={[styles.guideCorner, { right: 0, bottom: 0 }]} />
            </View>
            <Text style={styles.guideText}>Frame your subject</Text>
          </View>

          {/* Bottom Controls */}
          <View style={styles.bottomControls}>
            <TouchableOpacity 
              style={styles.flipButton} 
              onPress={toggleCameraFacing}
            >
              <Ionicons 
                name={facing === 'back' ? 'camera-reverse' : 'camera'} 
                size={28} 
                color="white" 
              />
            </TouchableOpacity>

            <TouchableOpacity 
              style={styles.captureButton} 
              onPress={takePicture}
              disabled={isCapturing}
            >
              {isCapturing ? (
                <ActivityIndicator color="#2196F3" />
              ) : (
                <View style={styles.captureInner} />
              )}
            </TouchableOpacity>

            <View style={styles.placeholder} />
          </View>
        </View>
      </CameraView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'black',
  },
  camera: {
    flex: 1,
  },
  overlay: {
    flex: 1,
    justifyContent: 'space-between',
    backgroundColor: 'rgba(0, 0, 0, 0.3)',
  },
  topControls: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    padding: 20,
    paddingTop: 50,
  },
  backButton: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  galleryButtonTop: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  guideContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  guideFrame: {
    width: 280,
    height: 280,
    position: 'relative',
  },
  guideCorner: {
    position: 'absolute',
    width: 60,
    height: 60,
    borderColor: 'white',
    borderWidth: 3,
    borderRadius: 8,
  },
  guideText: {
    color: 'white',
    fontSize: 16,
    marginTop: 20,
    fontWeight: '600',
    textShadowColor: 'rgba(0, 0, 0, 0.5)',
    textShadowOffset: { width: 0, height: 2 },
    textShadowRadius: 4,
  },
  bottomControls: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    alignItems: 'center',
    paddingBottom: 50,
    paddingHorizontal: 20,
  },
  flipButton: {
    width: 50,
    height: 50,
    borderRadius: 25,
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  captureButton: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: 'white',
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 4,
    borderColor: 'rgba(255, 255, 255, 0.3)',
  },
  captureInner: {
    width: 64,
    height: 64,
    borderRadius: 32,
    backgroundColor: '#2196F3',
  },
  placeholder: {
    width: 50,
  },
  permissionContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 40,
    backgroundColor: '#f5f5f5',
  },
  permissionTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    marginTop: 24,
    marginBottom: 12,
  },
  permissionText: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
    marginBottom: 32,
    lineHeight: 24,
  },
  permissionButton: {
    backgroundColor: '#2196F3',
    paddingHorizontal: 40,
    paddingVertical: 16,
    borderRadius: 12,
    minWidth: 200,
  },
  permissionButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
    textAlign: 'center',
  },
  galleryButton: {
    marginTop: 16,
    borderWidth: 2,
    borderColor: '#2196F3',
    paddingHorizontal: 40,
    paddingVertical: 14,
    borderRadius: 12,
    minWidth: 200,
  },
  galleryButtonText: {
    color: '#2196F3',
    fontSize: 16,
    fontWeight: 'bold',
    textAlign: 'center',
  },
});

export default ImageUploadScreen;
