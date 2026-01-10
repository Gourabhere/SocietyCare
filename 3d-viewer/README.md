# 3D Perspective Viewer - React Native Android App

A React Native mobile application that allows users to upload or capture images, convert them to 3D using AI depth estimation, and view them with real-time perspective changes based on head position detected via front camera.

## 🚀 Features

### Core Functionality
- **Image Input**: Upload from device gallery or capture with camera
- **AI Depth Estimation**: Generate depth maps using machine learning models
- **3D Rendering**: Interactive 3D viewer with Three.js via WebView
- **Head Tracking**: Real-time perspective adjustment based on head position
- **Smooth Animations**: Fluid transitions and perspective changes

### User Interface
- Intuitive home screen with quick actions
- Processing screen with progress indicators
- 3D viewer with head tracking overlay
- Settings screen for customization

## 🛠️ Tech Stack

- **Framework**: React Native with Expo (~50.0.0)
- **Navigation**: React Navigation 6
- **3D Rendering**: Three.js via WebView
- **Camera**: Expo Camera
- **Image Picker**: Expo Image Picker
- **State Management**: Zustand
- **Animations**: React Native Reanimated

### Dependencies
```json
{
  "expo": "~50.0.0",
  "expo-camera": "~14.0.0",
  "expo-image-picker": "~14.7.0",
  "@react-navigation/native": "^6.1.9",
  "@react-navigation/bottom-tabs": "^6.5.11",
  "react-native-webview": "13.6.4",
  "zustand": "^4.4.7"
}
```

## 📁 Project Structure

```
3d-viewer/
├── App.js                          # Main app entry point
├── package.json                     # Dependencies
├── app.json                        # Expo configuration
├── src/
│   ├── screens/                     # UI screens
│   │   ├── HomeScreen.js
│   │   ├── ImageUploadScreen.js
│   │   ├── ProcessingScreen.js
│   │   ├── Viewer3DScreen.js
│   │   └── SettingsScreen.js
│   ├── components/                  # Reusable components
│   ├── services/                   # Business logic
│   │   ├── depthEstimationService.js
│   │   ├── faceDetectionService.js
│   │   ├── 3dModelingService.js
│   │   └── imageProcessingService.js
│   ├── hooks/                      # Custom hooks
│   │   ├── useCameraPermissions.js
│   │   ├── useHeadTracking.js
│   │   └── useDepthEstimation.js
│   ├── utils/                      # Utility functions
│   │   ├── imageUtils.js
│   │   ├── mathUtils.js
│   │   └── cameraUtils.js
│   ├── store/                      # State management
│   │   └── appStore.js
│   └── navigation/                 # Navigation
│       └── AppNavigator.js
└── assets/                         # Static assets
```

## 🚦 Getting Started

### Prerequisites
- Node.js (v14 or higher)
- npm or yarn
- Expo Go app (for development)
- Android Studio (for building APK)
- Android device or emulator

### Installation

1. Navigate to the 3d-viewer directory:
```bash
cd 3d-viewer
```

2. Install dependencies:
```bash
npm install
```

3. Start the development server:
```bash
npm start
```

4. Run on Android:
```bash
npm run android
```

Or scan the QR code with Expo Go app on your Android device.

## 🎯 Usage Guide

### 1. Capture or Upload Image
- Tap "Take Photo" to capture with camera
- Tap "Upload from Gallery" to select existing image

### 2. Processing
- Wait for AI depth estimation to complete
- Progress steps: Analyzing → Depth Map → 3D Model → Complete

### 3. 3D Viewer
- Move your head to change perspective
- Toggle head tracking on/off
- Reset perspective to center
- Adjust settings as needed

## ⚙️ Settings

- **Camera Resolution**: Low, Medium, High
- **Depth Model Quality**: Low, Medium, High
- **Head Tracking**: Enable/disable
- **Auto Play**: Auto-start playback
- **Show FPS**: Display performance metrics

## 🔧 Development

### Key Services

#### Depth Estimation Service
- Generates depth maps from 2D images
- Currently simulated (ready for ML model integration)
- Supports TensorFlow.js and ONNX Runtime models

#### Face Detection Service
- Tracks head position in real-time
- Currently simulated (ready for MediaPipe integration)
- Provides smooth position updates

#### 3D Modeling Service
- Converts 2D + depth to 3D meshes
- Generates vertices, normals, and UVs
- Exports to OBJ, GLTF formats

### Integration with ML Models

The app is designed to integrate with:

**Depth Estimation Models:**
- MiDaS (Intel)
- LeRes
- DINO-based estimators

**Face Detection Models:**
- MediaPipe Face Detection
- TensorFlow.js Face Detection

To integrate actual models:
1. Uncomment the ML integration code in services
2. Load model weights from CDN or bundle
3. Configure model parameters
4. Test on target devices

## 📱 Building for Production

### Android APK
```bash
cd 3d-viewer
eas build --platform android
```

### Android App Bundle
```bash
eas build --platform android --profile production
```

## 🔐 Permissions

The app requires:
- **Camera**: For image capture and head tracking
- **Storage**: For image selection and saving
- **Internet**: For ML model loading (if using CDN)

Permissions are configured in:
- Android: `app.json` → `android.permissions`
- iOS: `app.json` → `ios.infoPlist`

## 🎨 Customization

### Theming
Update colors in screen stylesheets:
- Primary: `#2196F3` (Blue)
- Success: `#4CAF50` (Green)
- Error: `#FF5252` (Red)

### 3D Rendering
Modify `Viewer3DScreen.js` → `getThreeJSContent()` to:
- Change Three.js rendering parameters
- Adjust lighting and materials
- Add custom shaders
- Implement different 3D effects

## 🐛 Troubleshooting

### Camera not working
- Check permissions in device settings
- Ensure Expo Go has camera access
- Try restarting the app

### Processing is slow
- Lower depth model quality in settings
- Use lower camera resolution
- Close other apps

### Head tracking not smooth
- Check lighting conditions
- Ensure face is visible to front camera
- Adjust sensitivity in settings

## 🚀 Performance Optimization

For better performance:
1. Use medium or low quality settings on older devices
2. Reduce depth map resolution
3. Limit FPS in settings
4. Close background apps

## 📚 API Reference

### State Management (Zustand)
```javascript
import useAppStore from './src/store/appStore';

const {
  selectedImage,
  processedDepthMap,
  headPosition,
  setHeadPosition,
  // ... other state and actions
} = useAppStore();
```

### Head Tracking Hook
```javascript
import useHeadTracking from './src/hooks/useHeadTracking';

const {
  isInitialized,
  currentHeadPosition,
  resetHeadPosition,
  isActive,
} = useHeadTracking();
```

### Depth Estimation Hook
```javascript
import useDepthEstimation from './src/hooks/useDepthEstimation';

const {
  processedDepthMap,
  isProcessing,
  generateDepthMap,
  getDepthStats,
} = useDepthEstimation();
```

## 🤝 Contributing

1. Follow existing code style
2. Add comments for complex logic
3. Test on multiple devices
4. Update documentation

## 📄 License

Proprietary - All rights reserved

## 🙏 Acknowledgments

- Three.js - 3D rendering library
- Expo - React Native framework
- React Navigation - Navigation solution
- Zustand - State management

---

**Built with React Native & Expo**  
**3D Powered by Three.js**
