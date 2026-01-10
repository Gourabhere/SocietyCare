import React, { useRef, useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Alert,
  StatusBar,
  Dimensions,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { CameraView, useCameraPermissions } from 'expo-camera';
import { WebView } from 'react-native-webview';
import { Ionicons } from '@expo/vector-icons';
import useAppStore from '../store/appStore';

const { width, height } = Dimensions.get('window');

const Viewer3DScreen = () => {
  const navigation = useNavigation();
  const webViewRef = useRef(null);
  const [permission, requestPermission] = useCameraPermissions();
  const [cameraReady, setCameraReady] = useState(false);
  const [isHeadTrackingEnabled, setIsHeadTrackingEnabled] = useState(true);
  const [fps, setFps] = useState(0);
  const frameCount = useRef(0);
  const lastFrameTime = useRef(Date.now());

  const {
    selectedImage,
    processed3DModel,
    headPosition,
    setHeadPosition,
    isHeadTrackingActive,
    setHeadTrackingActive,
    headTrackingSensitivity,
    settings,
  } = useAppStore();

  useEffect(() => {
    setHeadTrackingActive(true);
    return () => {
      setHeadTrackingActive(false);
    };
  }, []);

  // FPS counter
  useEffect(() => {
    const interval = setInterval(() => {
      const now = Date.now();
      const delta = now - lastFrameTime.current;
      if (delta > 0) {
        setFps(Math.round((frameCount.current * 1000) / delta));
      }
      frameCount.current = 0;
      lastFrameTime.current = now;
    }, 1000);

    return () => clearInterval(interval);
  }, []);

  const handleHeadPositionChange = (newPosition) => {
    if (!isHeadTrackingEnabled) return;

    // Normalize head position (-1 to 1)
    const normalizedX = (newPosition.x - 0.5) * 2;
    const normalizedY = (newPosition.y - 0.5) * 2;
    
    // Apply sensitivity
    const adjustedX = normalizedX * headTrackingSensitivity;
    const adjustedY = normalizedY * headTrackingSensitivity;

    // Update head position
    setHeadPosition({
      x: Math.max(-1, Math.min(1, adjustedX)),
      y: Math.max(-1, Math.min(1, adjustedY)),
      z: headPosition.z,
    });

    frameCount.current++;

    // Send to WebView for 3D rendering
    if (webViewRef.current) {
      webViewRef.current.postMessage(JSON.stringify({
        type: 'headPosition',
        position: {
          x: adjustedX,
          y: adjustedY,
          z: headPosition.z,
        },
      }));
    }
  };

  const toggleHeadTracking = () => {
    setIsHeadTrackingEnabled(!isHeadTrackingEnabled);
  };

  const resetPerspective = () => {
    setHeadPosition({ x: 0, y: 0, z: 0 });
    if (webViewRef.current) {
      webViewRef.current.postMessage(JSON.stringify({
        type: 'headPosition',
        position: { x: 0, y: 0, z: 0 },
      }));
    }
  };

  // Three.js HTML content
  const getThreeJSContent = () => {
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body {
            margin: 0;
            overflow: hidden;
            background: #000;
          }
          canvas {
            display: block;
          }
        </style>
      </head>
      <body>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
        <script>
          let scene, camera, renderer, plane;
          let targetRotationX = 0;
          let targetRotationY = 0;

          function init() {
            // Scene setup
            scene = new THREE.Scene();
            
            // Camera
            camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
            camera.position.z = 5;

            // Renderer
            renderer = new THREE.WebGLRenderer({ antialias: true });
            renderer.setSize(window.innerWidth, window.innerHeight);
            renderer.setClearColor(0x000000);
            document.body.appendChild(renderer.domElement);

            // Create 3D plane with image
            const textureLoader = new THREE.TextureLoader();
            textureLoader.crossOrigin = 'anonymous';
            
            textureLoader.load('${selectedImage?.uri || ''}', (texture) => {
              // Create depth-based geometry
              const geometry = new THREE.PlaneGeometry(8, 6, 64, 48);
              
              // Apply depth displacement (simulated)
              const positions = geometry.attributes.position;
              for (let i = 0; i < positions.count; i++) {
                const x = positions.getX(i);
                const y = positions.getY(i);
                // Simulated depth based on distance from center
                const distance = Math.sqrt(x * x + y * y);
                const depth = Math.sin(distance * 0.5) * 0.5;
                positions.setZ(i, depth);
              }
              geometry.computeVertexNormals();

              const material = new THREE.MeshBasicMaterial({
                map: texture,
                side: THREE.DoubleSide,
              });

              plane = new THREE.Mesh(geometry, material);
              scene.add(plane);

              animate();
            });

            // Handle resize
            window.addEventListener('resize', onWindowResize, false);
          }

          function onWindowResize() {
            camera.aspect = window.innerWidth / window.innerHeight;
            camera.updateProjectionMatrix();
            renderer.setSize(window.innerWidth, window.innerHeight);
          }

          function animate() {
            requestAnimationFrame(animate);

            if (plane) {
              // Smooth rotation based on head position
              plane.rotation.y += (targetRotationX - plane.rotation.y) * 0.1;
              plane.rotation.x += (targetRotationY - plane.rotation.x) * 0.1;
            }

            renderer.render(scene, camera);
          }

          // Listen for messages from React Native
          document.addEventListener('message', function(event) {
            try {
              const data = JSON.parse(event.data);
              if (data.type === 'headPosition') {
                targetRotationX = -data.position.x * 0.5;
                targetRotationY = data.position.y * 0.3;
              }
            } catch (e) {
              console.error('Error parsing message:', e);
            }
          });

          // Initialize
          init();
        </script>
      </body>
      </html>
    `;
  };

  if (!permission) {
    return <View style={styles.container} />;
  }

  if (!permission.granted) {
    return (
      <View style={styles.container}>
        <View style={styles.permissionContainer}>
          <Ionicons name="camera-outline" size={64} color="#2196F3" />
          <Text style={styles.permissionTitle}>Camera Permission Required</Text>
          <Text style={styles.permissionText}>
            Front camera access is needed for head tracking to adjust 3D perspective.
          </Text>
          <TouchableOpacity style={styles.permissionButton} onPress={requestPermission}>
            <Text style={styles.permissionButtonText}>Grant Permission</Text>
          </TouchableOpacity>
        </View>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <StatusBar barStyle="light-content" />

      {/* 3D Viewer (WebView) */}
      <WebView
        ref={webViewRef}
        source={{ html: getThreeJSContent() }}
        style={styles.webView}
        javaScriptEnabled={true}
        domStorageEnabled={true}
        startInLoadingState={true}
        scalesPageToFit={true}
      />

      {/* Head Tracking Camera Overlay */}
      {isHeadTrackingEnabled && (
        <View style={styles.cameraOverlay}>
          <CameraView
            style={styles.camera}
            facing="front"
            onCameraReady={() => setCameraReady(true)}
          >
            {/* Simulated head detection visualization */}
            <View style={styles.faceDetectionBox}>
              <View style={styles.faceGuide}>
                <View style={styles.faceCorner} />
                <View style={[styles.faceCorner, { right: 0 }]} />
                <View style={[styles.faceCorner, { bottom: 0 }]} />
                <View style={[styles.faceCorner, { right: 0, bottom: 0 }]} />
                <View style={styles.faceCenter} />
              </View>
            </View>
          </CameraView>
          
          {/* Simulated head tracking updates */}
          <View style={StyleSheet.absoluteFill}>
            <View style={styles.trackingArea} onTouchMove={(e) => {
              const { locationX, locationY } = e.nativeEvent;
              handleHeadPositionChange({
                x: locationX / width,
                y: locationY / height,
                z: 0,
              });
            }} />
          </View>
        </View>
      )}

      {/* Controls Overlay */}
      <View style={styles.controlsOverlay}>
        {/* Header */}
        <View style={styles.header}>
          <TouchableOpacity
            style={styles.headerButton}
            onPress={() => navigation.goBack()}
          >
            <Ionicons name="arrow-back" size={24} color="white" />
          </TouchableOpacity>

          <View style={styles.headerTitle}>
            <Text style={styles.titleText}>3D Viewer</Text>
            <Text style={styles.subtitleText}>Head Tracking Active</Text>
          </View>

          <TouchableOpacity
            style={styles.headerButton}
            onPress={toggleHeadTracking}
          >
            <Ionicons 
              name={isHeadTrackingEnabled ? "eye" : "eye-off"} 
              size={24} 
              color="white" 
            />
          </TouchableOpacity>
        </View>

        {/* Head Position Indicator */}
        <View style={styles.positionIndicator}>
          <Text style={styles.positionLabel}>Head Position</Text>
          <View style={styles.positionValues}>
            <View style={styles.positionValue}>
              <Text style={styles.positionAxis}>X</Text>
              <Text style={styles.positionNumber}>{headPosition.x.toFixed(2)}</Text>
            </View>
            <View style={styles.positionValue}>
              <Text style={styles.positionAxis}>Y</Text>
              <Text style={styles.positionNumber}>{headPosition.y.toFixed(2)}</Text>
            </View>
          </View>
        </View>

        {/* Bottom Controls */}
        <View style={styles.bottomControls}>
          <TouchableOpacity
            style={styles.controlButton}
            onPress={resetPerspective}
          >
            <Ionicons name="refresh" size={24} color="#2196F3" />
            <Text style={styles.controlButtonText}>Reset</Text>
          </TouchableOpacity>

          {settings.showFPS && (
            <View style={styles.fpsContainer}>
              <Text style={styles.fpsText}>{fps} FPS</Text>
            </View>
          )}

          <TouchableOpacity
            style={styles.controlButton}
            onPress={() => {
              // Toggle settings
              navigation.navigate('Settings');
            }}
          >
            <Ionicons name="settings" size={24} color="#2196F3" />
            <Text style={styles.controlButtonText}>Settings</Text>
          </TouchableOpacity>
        </View>
      </View>

      {/* Head Tracking Status */}
      <View style={styles.trackingStatus}>
        <View style={[
          styles.statusDot, 
          isHeadTrackingEnabled ? styles.statusDotActive : styles.statusDotInactive
        ]} />
        <Text style={styles.statusText}>
          {isHeadTrackingEnabled ? 'Tracking Active' : 'Tracking Paused'}
        </Text>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000',
  },
  webView: {
    flex: 1,
  },
  cameraOverlay: {
    position: 'absolute',
    top: 100,
    right: 20,
    width: 120,
    height: 160,
    borderRadius: 12,
    overflow: 'hidden',
    backgroundColor: 'rgba(0, 0, 0, 0.3)',
    borderWidth: 2,
    borderColor: 'rgba(255, 255, 255, 0.2)',
  },
  camera: {
    flex: 1,
  },
  faceDetectionBox: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  },
  faceGuide: {
    flex: 1,
    margin: 20,
    position: 'relative',
  },
  faceCorner: {
    position: 'absolute',
    width: 20,
    height: 20,
    borderColor: '#4CAF50',
    borderWidth: 2,
    borderRadius: 4,
  },
  faceCenter: {
    position: 'absolute',
    top: '50%',
    left: '50%',
    marginTop: -15,
    marginLeft: -15,
    width: 30,
    height: 30,
    borderRadius: 15,
    backgroundColor: 'rgba(76, 175, 80, 0.3)',
    borderWidth: 2,
    borderColor: '#4CAF50',
  },
  trackingArea: {
    backgroundColor: 'transparent',
  },
  controlsOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    justifyContent: 'space-between',
    paddingTop: 50,
    paddingBottom: 20,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
  },
  headerButton: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  headerTitle: {
    alignItems: 'center',
  },
  titleText: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold',
  },
  subtitleText: {
    color: 'rgba(255, 255, 255, 0.7)',
    fontSize: 12,
  },
  positionIndicator: {
    alignSelf: 'center',
    backgroundColor: 'rgba(0, 0, 0, 0.6)',
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.2)',
  },
  positionLabel: {
    color: 'white',
    fontSize: 12,
    textAlign: 'center',
    marginBottom: 8,
  },
  positionValues: {
    flexDirection: 'row',
    gap: 24,
  },
  positionValue: {
    alignItems: 'center',
  },
  positionAxis: {
    color: '#2196F3',
    fontSize: 12,
    fontWeight: 'bold',
  },
  positionNumber: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold',
  },
  bottomControls: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingHorizontal: 20,
  },
  controlButton: {
    backgroundColor: 'rgba(0, 0, 0, 0.6)',
    paddingHorizontal: 20,
    paddingVertical: 12,
    borderRadius: 12,
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.2)',
  },
  controlButtonText: {
    color: 'white',
    fontSize: 14,
    fontWeight: '600',
  },
  fpsContainer: {
    backgroundColor: 'rgba(0, 0, 0, 0.6)',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 8,
    alignSelf: 'center',
  },
  fpsText: {
    color: '#4CAF50',
    fontSize: 12,
    fontWeight: 'bold',
  },
  trackingStatus: {
    position: 'absolute',
    top: 110,
    left: 20,
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(0, 0, 0, 0.6)',
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 12,
  },
  statusDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    marginRight: 8,
  },
  statusDotActive: {
    backgroundColor: '#4CAF50',
  },
  statusDotInactive: {
    backgroundColor: '#999',
  },
  statusText: {
    color: 'white',
    fontSize: 12,
    fontWeight: '600',
  },
  permissionContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 40,
    backgroundColor: '#000',
  },
  permissionTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: 'white',
    marginTop: 24,
    marginBottom: 12,
    textAlign: 'center',
  },
  permissionText: {
    fontSize: 16,
    color: 'rgba(255, 255, 255, 0.8)',
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
});

export default Viewer3DScreen;
