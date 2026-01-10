# Facility Management & 3D Viewer Projects

This repository contains **TWO separate applications**:

---

## 📱 1. Facility Keeper - Housekeeping Management System (React Web App)

A web-based application for facility management staff to track cleaning duties across residential complexes.

**Technology:** React 19 + TypeScript + Vite  
**Location:** `/` (root directory)

### Quick Start
```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build
```

### Features

**For Staff Users:**
- ✅ View assigned cleaning tasks
- ✅ Complete tasks with photo proof
- ✅ Add notes to task completion
- ✅ Track personal activity history
- ✅ Navigate hierarchical structure (Society → Block → Floor → Flat)

**For Admin Users:**
- ✅ Verify completed tasks
- ✅ Monitor all staff activities
- ✅ View comprehensive progress reports
- ✅ Access real-time dashboard

**Technical Features:**
- 🔐 Secure task management
- 📸 AI-powered reports via Google Generative AI
- 💾 Local storage for offline work
- 🔄 Real-time updates
- 📊 Progress tracking and analytics

### Documentation
- [Repository Overview](REPO_README.md) - Complete repository structure
- [Implementation Checklist](CHECKLIST.md) - Feature implementation status
- [3D Viewer Summary](3D_VIEWER_SUMMARY.md) - Implementation completion status

---

## 🎯 2. 3D Image to Perspective Viewer (React Native Android App)

A mobile application that converts 2D images into 3D models with AI depth estimation and head tracking.

**Technology:** React Native + Expo  
**Location:** `/3d-viewer`

### Quick Start
```bash
# Navigate to 3d-viewer directory
cd 3d-viewer

# Install dependencies
npm install

# Start Expo development server
npm start

# Run on Android
npm run android
```

### Features
- 📸 Image capture and gallery upload
- 🤖 AI depth estimation (simulated, ready for ML integration)
- 🎮 Interactive 3D viewer with Three.js
- 👤 Real-time head tracking for perspective control
- ⚙️ Customizable settings (quality, sensitivity)
- 📊 Performance monitoring (FPS counter)

### Documentation
- [3D Viewer Documentation](3d-viewer/README.md) - Complete guide
- [Implementation Guide](3D_VIEWER_IMPLEMENTATION.md) - Detailed technical notes

---

## 📊 Project Comparison

| Feature | Facility Keeper | 3D Viewer |
|---------|---------------|------------|
| **Platform** | Web (React) | Mobile Android (React Native) |
| **Purpose** | Task Management | 3D Image Viewing |
| **Status** | ✅ Production | 🚧 Development |
| **AI/ML** | Gemini Reports | Depth Estimation, Face Detection |
| **3D Graphics** | None | Three.js |
| **Backend** | Local / Optional | Local / Optional |
| **Location** | `/` | `/3d-viewer` |

---

## 📁 Repository Structure

```
project-root/
│
├── # Facility Keeper (Web App)
├── App.tsx                    # React app entry
├── package.json               # Dependencies
├── vite.config.ts             # Vite config
├── components/                # React components
├── services/                 # Business logic
├── constants.ts              # App constants
├── types.ts                 # TypeScript types
│
├── # 3D Viewer (Mobile App)
├── 3d-viewer/
│   ├── App.js                 # React Native entry
│   ├── package.json           # Dependencies
│   ├── app.json              # Expo config
│   ├── src/
│   │   ├── screens/          # UI screens
│   │   ├── components/       # Reusable components
│   │   ├── services/         # AI/ML services
│   │   ├── hooks/            # Custom hooks
│   │   ├── utils/            # Utilities
│   │   ├── store/            # Zustand state
│   │   └── navigation/      # App navigation
│   ├── assets/              # Static assets
│   └── README.md            # 3D viewer docs
│
├── # Documentation
├── README.md                # This file (overview)
├── REPO_README.md          # Repository structure
├── CHECKLIST.md            # Implementation checklist
├── 3D_VIEWER_IMPLEMENTATION.md  # 3D viewer technical guide
├── FLUTTER_README.md       # Legacy Flutter docs
├── PROJECT_INFO.md         # Project metadata
├── IMPLEMENTATION_SUMMARY.md  # Implementation notes
└── SUPABASE_SETUP.md       # Backend setup (legacy)
```

---

## 🚀 Getting Started

### Option 1: Run Facility Keeper (Web App)

The web app is already set up in the root directory.

```bash
# Install dependencies (if not already done)
npm install

# Start development server
npm run dev

# Open browser to http://localhost:5173
```

### Option 2: Run 3D Viewer (Mobile App)

The mobile app is in the `3d-viewer` subdirectory.

```bash
# Navigate to 3d-viewer
cd 3d-viewer

# Install dependencies
npm install

# Start Expo development server
npm start

# Scan QR code with Expo Go app on Android device
# Or run on Android emulator
npm run android
```

---

## 🛠️ Technology Stack

### Facility Keeper (Web)
- **Frontend:** React 19, TypeScript
- **Build Tool:** Vite 6
- **AI Integration:** Google Generative AI
- **Styling:** CSS (Tailwind-ready structure)
- **State:** React Hooks + Context

### 3D Viewer (Mobile)
- **Framework:** React Native with Expo 50
- **Navigation:** React Navigation 6
- **3D Engine:** Three.js via WebView
- **State:** Zustand
- **Camera:** Expo Camera
- **AI/ML:** TensorFlow.js / MediaPipe (integration ready)

---

## 📝 Development Workflow

### Facility Keeper Development

1. Make changes to React components in root directory
2. Update services or types as needed
3. Run `npm run dev` for hot reload
4. Test in browser
5. Commit changes

### 3D Viewer Development

1. Navigate to `3d-viewer/` directory
2. Edit React Native screens or services
3. Run `npm start` for Expo development server
4. Test on Android device or emulator
5. Commit changes

---

## 🧪 Testing

### Facility Keeper
```bash
# Run tests (if configured)
npm test
```

### 3D Viewer
```bash
cd 3d-viewer

# Run tests (if configured)
npm test
```

---

## 🚢 Deployment

### Facility Keeper

Deploy the web app to any static hosting service:

```bash
# Build for production
npm run build

# Deploy 'dist' folder to:
# - Vercel
# - Netlify
# - GitHub Pages
# - Or any static hosting
```

### 3D Viewer

Build Android APK or App Bundle:

```bash
cd 3d-viewer

# Install EAS CLI (if not installed)
npm install -g eas-cli

# Build APK for testing
eas build --platform android --profile preview

# Build App Bundle for production
eas build --platform android --profile production
```

---

## 📄 License

Both projects are proprietary software. All rights reserved.

---

## 📞 Support

- **Facility Keeper:** See [REPO_README.md](REPO_README.md)
- **3D Viewer:** See [3d-viewer/README.md](3d-viewer/README.md)

For issues, questions, or contributions, please contact the development team.

---

**Last Updated:** January 2025  
**Maintained By:** Development Team
