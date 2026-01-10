# Facility Management & 3D Viewer Projects

This repository contains two separate applications:

## 📱 1. Facility Keeper - Housekeeping Management (React Web App)

A comprehensive web-based application for facility and housekeeping management staff to track cleaning duties across residential complexes.

**Location:** `/` (root directory)

**Technology Stack:**
- React 19 with TypeScript
- Vite for build tooling
- Google Generative AI for reports

**Quick Start:**
```bash
npm install
npm run dev
```

**Documentation:**
- [README.md](README.md) - Main project documentation
- [CHECKLIST.md](CHECKLIST.md) - Implementation checklist

---

## 🎯 2. 3D Image to Perspective Viewer (React Native Android App)

A React Native mobile application that converts 2D images into 3D models with AI depth estimation and head tracking for immersive viewing.

**Location:** `/3d-viewer`

**Technology Stack:**
- React Native with Expo 50
- Three.js for 3D rendering
- TensorFlow.js / MediaPipe for AI (ready for integration)
- Zustand for state management

**Quick Start:**
```bash
cd 3d-viewer
npm install
npm start
```

**Documentation:**
- [3d-viewer/README.md](3d-viewer/README.md) - Complete 3D viewer documentation

---

## 📊 Comparison

| Feature | Facility Keeper | 3D Viewer |
|---------|---------------|------------|
| **Platform** | Web (React) | Mobile Android (React Native) |
| **Purpose** | Task Management | 3D Image Viewing |
| **AI/ML** | Gemini AI Reports | Depth Estimation, Face Detection |
| **3D Graphics** | None | Three.js |
| **Camera** | Photo Upload | Capture + Head Tracking |
| **Backend** | Supabase | Local / Optional |
| **Status** | ✅ Complete | 🚧 In Development |

---

## 🚀 Getting Started

### Option 1: Run Facility Keeper (Web App)

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build
```

### Option 2: Run 3D Viewer (Mobile App)

```bash
# Navigate to 3D viewer directory
cd 3d-viewer

# Install dependencies
npm install

# Start Expo development server
npm start

# Run on Android (requires emulator or device)
npm run android
```

---

## 📁 Repository Structure

```
project-root/
├── # Facility Keeper (Web App)
├── App.tsx                    # React web app entry
├── package.json               # Web app dependencies
├── vite.config.ts             # Vite configuration
├── components/                # React components
├── services/                 # Web app services
├── types.ts                  # TypeScript types
│
├── # 3D Viewer (Mobile App)
├── 3d-viewer/
│   ├── App.js                 # React Native entry
│   ├── package.json           # Mobile app dependencies
│   ├── app.json              # Expo configuration
│   ├── src/
│   │   ├── screens/          # UI screens
│   │   ├── components/       # Reusable components
│   │   ├── services/         # AI/ML services
│   │   ├── hooks/            # Custom React hooks
│   │   ├── utils/            # Utility functions
│   │   ├── store/            # Zustand state management
│   │   └── navigation/      # App navigation
│   └── assets/              # Static assets
│
├── # Documentation
├── README.md                # Facility Keeper docs
├── CHECKLIST.md            # Implementation checklist
├── REPO_README.md         # This file (repo overview)
└── 3d-viewer/README.md   # 3D Viewer docs
```

---

## 🛠️ Development Workflow

### Working on Facility Keeper

All changes should be made in the root directory:

```bash
# Make changes to React components
# Edit services
# Update types

# Run development server
npm run dev

# Run tests (if available)
npm test
```

### Working on 3D Viewer

All changes should be made in the `3d-viewer/` directory:

```bash
cd 3d-viewer

# Edit React Native screens
# Update services
# Add components

# Run with Expo
npm start

# Test on Android
npm run android
```

---

## 📦 Installation Requirements

### Facility Keeper (Web App)
- Node.js 14+ 
- npm or yarn
- Modern web browser

### 3D Viewer (Mobile App)
- Node.js 14+
- npm or yarn
- Expo CLI (`npm install -g expo-cli`)
- Expo Go app (for testing)
- Android Studio (for building APK)
- Android device or emulator

---

## 🔄 CI/CD

Both projects are designed to be deployable independently:

### Facility Keeper Deployment
- Vercel, Netlify, or any static hosting
- `npm run build` produces optimized static files
- Supabase backend required for full functionality

### 3D Viewer Deployment
- EAS Build for production APK
- `eas build --platform android`
- Google Play Store for distribution

---

## 🤝 Contributing

### Facility Keeper
1. Create feature branch: `git checkout -b feature/new-feature`
2. Make changes in root directory
3. Test web functionality
4. Commit and push

### 3D Viewer
1. Create feature branch: `git checkout -b feature/3d-new-feature`
2. Make changes in `3d-viewer/` directory
3. Test on Android device/emulator
4. Commit and push

---

## 📝 Project Status

### Facility Keeper
- ✅ Task management system
- ✅ Photo documentation
- ✅ Real-time dashboard
- ✅ Activity logging
- ✅ AI-powered reports
- 🔄 Production ready

### 3D Viewer
- ✅ Project structure setup
- ✅ Navigation system
- ✅ Camera integration
- ✅ Image picker
- ✅ State management
- ✅ 3D rendering foundation
- 🚧 Depth estimation (simulated)
- 🚧 Face detection (simulated)
- 🚧 Head tracking (simulated)
- 🔄 In development

**Note:** The 3D Viewer's AI/ML services are simulated for demonstration. They can be replaced with actual TensorFlow.js or MediaPipe implementations as outlined in the code comments.

---

## 📞 Support

For questions or issues:
- Facility Keeper: See [README.md](README.md)
- 3D Viewer: See [3d-viewer/README.md](3d-viewer/README.md)

---

## 📄 License

Both projects are proprietary software. All rights reserved.

---

**Last Updated:** January 2025  
**Maintained By:** Development Team
