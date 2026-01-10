# Components Directory

This directory contains reusable React Native components for the 3D Viewer app.

## Components to Implement

Based on the ticket requirements, the following components may be useful:

### ImagePicker.js
- Unified interface for camera/gallery selection
- Image preview after selection
- Re-capture option

### CameraCapture.js
- Real-time camera view
- Capture button
- Flash control
- Camera flip functionality
- Grid overlay for composition

### View3DRenderer.js
- Three.js WebView wrapper
- Loading states
- Error handling
- Gesture controls (manual rotation/zoom)

### HeadTrackingOverlay.js
- Small camera preview for face tracking
- Face detection visualization
- Confidence indicator
- Tracking status display

### LoadingIndicator.js
- Animated loading spinner
- Progress text
- Step indicators

## Usage Example

```javascript
import ImagePicker from '../components/ImagePicker';

<ImagePicker
  onImageSelected={(uri) => console.log(uri)}
  mode="camera" // or 'gallery'
/>
```

## Component Guidelines

- Follow React Native best practices
- Use const where possible
- PropTypes or TypeScript for type checking
- Consistent styling
- Reusable and configurable
