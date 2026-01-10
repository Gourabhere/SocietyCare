# 3D Image to Perspective Viewer - Implementation Guide

## Project Overview

A React Native Android application that transforms 2D images into immersive 3D experiences with real-time perspective control through head tracking.

## Architecture

### Technology Stack

**Core Framework:**
- React Native with Expo 50
- React Navigation 6 (Bottom Tabs + Stack)
- Zustand (State Management)

**3D Rendering:**
- Three.js via WebView for cross-platform 3D graphics
- Custom vertex displacement based on depth maps

**AI/ML Integration Points:**
- Depth Estimation: TensorFlow.js or ONNX Runtime (simulated)
- Face Detection: MediaPipe or TensorFlow.js (simulated)

**Camera & Image:**
- Expo Camera (front camera for head tracking, rear for capture)
- Expo Image Picker (gallery selection)

## Key Components

### 1. Screens (`src/screens/`)

#### HomeScreen.js
- **Purpose**: Main navigation hub
- **Features**: 
  - Quick action buttons (Take Photo, Upload)
  - Recent project cards
  - Feature highlights
- **State**: Uses Zustand store for image/model state

#### ImageUploadScreen.js
- **Purpose**: Image capture and selection
- **Features**:
  - Real-time camera capture (rear camera)
  - Gallery image picker
  - Permission handling
  - Camera flip functionality
- **Camera**: Uses Expo Camera with `facing` prop

#### ProcessingScreen.js
- **Purpose**: Progress indication during AI processing
- **Features**:
  - Step-by-step progress display
  - Animated progress bar
  - Processing status updates
- **Animation**: Uses setInterval for simulated progress

#### Viewer3DScreen.js
- **Purpose**: 3D model viewing with head tracking
- **Features**:
  - Three.js rendering in WebView
  - Front camera overlay for head tracking
  - Real-time perspective adjustment
  - FPS counter (optional)
  - Control buttons (reset, settings)
- **Integration**: 
  - WebView receives head position via `postMessage`
  - Three.js responds with smooth rotation

#### SettingsScreen.js
- **Purpose**: App configuration
- **Features**:
  - Camera resolution selection
  - Depth model quality
  - Head tracking toggle
  - FPS display toggle
  - Data reset

### 2. Services (`src/services/`)

#### depthEstimationService.js
- **Current State**: Simulated implementation
- **Purpose**: Generate depth maps from 2D images
- **Key Functions**:
  - `generateDepthMap(imageUri)` - Main entry point
  - `validateDepthMap(depthMap)` - Quality check
  - `normalizeDepthMap(depthMap)` - 0-1 normalization
  - `exportDepthMapAsImage(depthMap)` - Visualization export

**Integration Ready**: Contains commented examples for:
- MiDaS model via TensorFlow.js
- ONNX Runtime integration

#### faceDetectionService.js
- **Current State**: Simulated implementation
- **Purpose**: Detect head position for perspective control
- **Key Functions**:
  - `initializeFaceDetection()` - Setup detector
  - `startHeadTracking(callback)` - Start tracking loop
  - `stopHeadTracking()` - Cleanup resources
  - `extractHeadPosition(faceData, width, height)` - Calculate position

**Integration Ready**: Contains examples for:
- MediaPipe Face Detection
- TensorFlow.js Face Landmarks

#### 3dModelingService.js
- **Purpose**: Convert 2D + depth into 3D geometry
- **Key Functions**:
  - `create3DModel(imageUri, depthMap)` - Main conversion
  - `generateVerticesFromDepth(depthMap)` - Create mesh vertices
  - `generateIndices(width, height)` - Create triangle faces
  - `generateNormals(depthMap)` - Calculate lighting normals
  - `exportModel(model, format)` - Export OBJ/GLTF

**Output**: Mesh data with:
- Vertices (x, y, z positions)
- Indices (triangle definitions)
- Normals (for lighting)
- UVs (texture mapping)

### 3. Hooks (`src/hooks/`)

#### useCameraPermissions.js
- Manages Expo Camera permissions
- Provides `hasPermission` state
- Handles permission requests

#### useHeadTracking.js
- Main head tracking logic
- Smoothing algorithm (moving average)
- Position history management
- Sensitivity application
- Error handling

#### useDepthEstimation.js
- Depth estimation orchestration
- Progress tracking
- Validation and normalization
- Statistics generation
- Export capabilities

### 4. State Management (`src/store/appStore.js`)

**Zustand Store Structure:**
```javascript
{
  // Image & Processing
  selectedImage: null,
  processedDepthMap: null,
  processed3DModel: null,
  processingProgress: 0,
  isProcessing: false,
  processingError: null,
  
  // Head Tracking
  headPosition: { x: 0, y: 0, z: 0 },
  isHeadTrackingActive: false,
  headTrackingSensitivity: 1.0,
  
  // Settings
  settings: {
    cameraResolution: 'high',
    depthModelQuality: 'medium',
    headTrackingEnabled: true,
    autoPlay: true,
    showFPS: false,
  }
}
```

### 5. Utilities (`src/utils/`)

#### imageUtils.js
- Image resizing and compression
- Base64 conversion
- Dimension extraction
- Rotation and cropping
- Validation functions

#### mathUtils.js
- Math functions for 3D operations
- Clamping, lerp, mapping
- 3D distance calculations
- Matrix transformations
- Easing functions
- Rotation calculations

## Data Flow

### Image Upload Flow

```
User Action → HomeScreen → ImageUploadScreen
                              ↓
                        Capture/Select Image
                              ↓
                    Store image URI in Zustand
                              ↓
                    Navigate to ProcessingScreen
```

### Processing Flow

```
ProcessingScreen
      ↓
generateDepthMap() ← depthEstimationService
      ↓
      Simulated progress updates
      ↓
create3DModel() ← 3dModelingService
      ↓
    Store in Zustand
      ↓
Navigate to Viewer3DScreen
```

### Head Tracking Flow

```
Viewer3DScreen mounts
      ↓
useHeadTracking() hook initializes
      ↓
faceDetectionService.startHeadTracking()
      ↓
Continuous position updates (simulated)
      ↓
Smooth with moving average
      ↓
Apply sensitivity
      ↓
Update Zustand headPosition
      ↓
Viewer3DScreen posts to WebView
      ↓
Three.js receives message
      ↓
Apply rotation to 3D mesh
      ↓
Render frame
```

## Integration with Real ML Models

### Depth Estimation Integration

To replace simulated depth estimation with real ML:

**Option 1: TensorFlow.js**
```javascript
// In depthEstimationService.js
import * as tf from '@tensorflow/tfjs-react-native';

export async function generateDepthMapWithModel(imageUri) {
  await tf.ready();
  
  // Load model
  const model = await tf.loadGraphModel(
    'https://tfhub.dev/google/midas/v2_1_small/1'
  );
  
  // Load and preprocess image
  const image = await loadImageAsTensor(imageUri);
  const resized = tf.image.resizeBilinear(image, [384, 384]);
  const normalized = resized.div(255.0);
  const batched = normalized.expandDims(0);
  
  // Run inference
  const prediction = model.predict(batched);
  const depth = await prediction.data();
  
  // Post-process and return
  return processDepthOutput(depth);
}
```

**Option 2: ONNX Runtime**
```javascript
import * as ort from 'onnxruntime-react-native';

export async function generateDepthMapWithONNX(imageUri) {
  // Load session
  const session = await ort.InferenceSession.create('model.onnx');
  
  // Prepare input tensor
  const tensor = await prepareInputTensor(imageUri);
  
  // Run inference
  const outputs = await session.run({ input: tensor });
  
  // Extract depth data
  const depth = outputs.output.data;
  
  return processDepthOutput(depth);
}
```

### Face Detection Integration

To replace simulated face detection with real ML:

**Option 1: MediaPipe**
```javascript
// In faceDetectionService.js
import { FaceDetection } from '@mediapipe/tasks-vision';

export async function initializeMediaPipeFaceDetection() {
  const faceDetection = await FaceDetection.createFromOptions(
    visionBaseOptions,
    {
      baseOptions: {
        modelAssetPath: 'face_detection_short_range.tflite',
        delegate: 'GPU',
      },
      minDetectionConfidence: 0.5,
    }
  );
  return faceDetection;
}

export async function detectFaceWithMediaPipe(image) {
  const result = await faceDetector.detect(image);
  
  if (result.detections.length > 0) {
    const face = result.detections[0];
    return {
      boundingBox: face.boundingBox,
      landmarks: face.keypoints,
      confidence: face.categories[0].score,
    };
  }
}
```

**Option 2: TensorFlow.js**
```javascript
import * as faceLandmarksDetection from '@tensorflow-models/face-landmarks-detection';

export async function loadTensorFlowFaceModel() {
  await tf.ready();
  const model = await faceLandmarksDetection.load(
    faceLandmarksDetection.SupportedPackages.mediapipeFacemesh,
    { maxFaces: 1 }
  );
  return model;
}
```

## Three.js Integration Details

The `Viewer3DScreen.js` uses Three.js embedded in a WebView:

```javascript
// Key Three.js setup
scene = new THREE.Scene();
camera = new THREE.PerspectiveCamera(75, aspect, 0.1, 1000);
renderer = new THREE.WebGLRenderer({ antialias: true });

// Depth-based displacement
geometry = new THREE.PlaneGeometry(width, height, segmentsX, segmentsY);
const positions = geometry.attributes.position;

// Apply depth to Z values
for (let i = 0; i < positions.count; i++) {
  const depth = getDepthAtPosition(x, y);
  positions.setZ(i, depth * scale);
}

// Smooth rotation based on head position
targetRotationX = -headPosition.x * 0.5;
targetRotationY = headPosition.y * 0.3;
plane.rotation.y += (targetRotationX - plane.rotation.y) * 0.1;
plane.rotation.x += (targetRotationY - plane.rotation.x) * 0.1;
```

## Performance Optimization

### 1. Depth Map Resolution
- Low: 320x240 (fast, less accurate)
- Medium: 640x480 (balanced)
- High: 1024x768 (slow, more accurate)

### 2. Mesh Segmentation
- Low: 32x24 vertices (very fast, blocky)
- Medium: 64x48 vertices (balanced)
- High: 128x96 vertices (slow, smooth)

### 3. Smoothing Window
- 3-5 frames: Fast response, more jitter
- 7-10 frames: Balanced
- 15+ frames: Very smooth, laggy

### 4. Head Tracking FPS
- 15 FPS: Very fast, smoother
- 30 FPS: Standard (recommended)
- 60 FPS: Very smooth, battery intensive

## Testing Checklist

### Functionality Testing
- [ ] Camera capture works
- [ ] Gallery picker works
- [ ] Image displays correctly
- [ ] Processing completes successfully
- [ ] 3D viewer renders model
- [ ] Head tracking responds to movement
- [ ] Settings save/restore correctly
- [ ] Navigation works smoothly

### Performance Testing
- [ ] App loads within 3 seconds
- [ ] Processing completes within 10 seconds
- [ ] 3D viewer maintains 30+ FPS
- [ ] Head tracking is smooth, not jittery
- [ ] No memory leaks during extended use

### Permission Testing
- [ ] Camera permission requested on first use
- [ ] Permission denial handled gracefully
- [ ] Re-requesting permission works

### Edge Cases
- [ ] Large images (>10MB) handled
- [ ] Very small images (<100x100) handled
- [ ] No face detected in camera
- [ ] Poor lighting conditions
- [ ] Rapid head movements

## Deployment

### Development
```bash
cd 3d-viewer
npm install
npm start
# Scan QR with Expo Go
```

### Production Build (APK)
```bash
cd 3d-viewer
npm install -g eas-cli
eas build --platform android
```

### Production Build (App Bundle)
```bash
eas build --platform android --profile production
```

## Troubleshooting

### Common Issues

**Issue**: Camera not starting
- **Cause**: Missing permissions
- **Fix**: Check device settings, reinstall app

**Issue**: Processing stuck at 0%
- **Cause**: Service not initialized
- **Fix**: Check console logs, verify imports

**Issue**: 3D viewer shows blank screen
- **Cause**: Three.js error, image loading failed
- **Fix**: Check WebView logs, verify image URI

**Issue**: Head tracking not responding
- **Cause**: Tracking not active, permissions denied
- **Fix**: Check toggle, enable in settings, grant camera permission

**Issue**: Choppy/jittery movement
- **Cause**: Low smoothing window, high sensitivity
- **Fix**: Increase smoothing window, decrease sensitivity

## Future Enhancements

### Phase 2 Features
- [ ] Actual ML model integration
- [ ] Multiple depth estimation models
- [ ] Advanced face tracking (pose, iris)
- [ ] 3D model export/save
- [ ] Share 3D models
- [ ] Batch processing
- [ ] Image gallery with thumbnails
- [ ] Video to 3D conversion

### Phase 3 Features
- [ ] Augmented Reality (AR) mode
- [ ] Gestures for 3D manipulation
- [ ] Multi-person head tracking
- [ ] Voice commands
- [ ] Cloud processing option
- [ ] Offline mode with cached models
- [ ] Advanced lighting controls
- [ ] Custom shaders and effects

## References

- [Expo Documentation](https://docs.expo.dev/)
- [React Native](https://reactnative.dev/)
- [Three.js](https://threejs.org/)
- [TensorFlow.js](https://www.tensorflow.org/js)
- [MediaPipe](https://google.github.io/mediapipe/)
- [Zustand](https://github.com/pmndrs/zustand)

---

**Implementation Status**: 🚧 In Development  
**Last Updated**: January 2025
